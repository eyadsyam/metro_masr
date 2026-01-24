import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/data_sync_service.dart';
import '../services/connectivity_service.dart';
import 'user_state.dart';

/// User Cubit
/// Manages user authentication state and provides unified interface
/// for both guest and authenticated users
class UserCubit extends Cubit<UserState> {
  final AuthService _authService;
  final LocalStorageService _localStorage;
  final DataSyncService _dataSyncService;
  final ConnectivityService _connectivityService;

  StreamSubscription? _authSubscription;
  AppUser? _currentUser;

  UserCubit({
    required AuthService authService,
    required LocalStorageService localStorage,
    required DataSyncService dataSyncService,
    required ConnectivityService connectivityService,
  }) : _authService = authService,
       _localStorage = localStorage,
       _dataSyncService = dataSyncService,
       _connectivityService = connectivityService,
       super(const UserInitial());

  /// Get current user
  AppUser? get currentUser => _currentUser;

  /// Check if user is authenticated (not guest)
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;

  /// Check if user is in guest mode
  bool get isGuest => _currentUser != null && _currentUser!.isGuest;

  /// Initialize user state
  Future<void> initialize() async {
    emit(const UserLoading());

    try {
      // Try to get current user (from session or local storage)
      AppUser? user = await _authService.getCurrentUser();

      // If no user found, try to load from cache (offline scenario)
      if (user == null && !_connectivityService.isConnected) {
        user = _localStorage.getCachedUser();
      }

      if (user != null) {
        _currentUser = user;
        await _localStorage.cacheUser(user);

        // Initialize sync for authenticated users
        if (!user.isGuest && _connectivityService.isConnected) {
          await _dataSyncService.initializeSync(user.id);
        }

        emit(
          UserAuthenticated(
            id: user.id,
            name: user.name,
            email: user.email,
            avatarUrl: user.avatarUrl,
            isGuest: user.isGuest,
          ),
        );
      } else {
        emit(const UserUnauthenticated());
      }

      // Listen to auth state changes
      _listenToAuthChanges();
    } catch (e) {
      print('Error initializing user: $e');
      emit(UserError(e.toString()));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(const UserLoading());

    try {
      final user = await _authService.signInWithGoogle();
      _currentUser = user;

      // Cache user data
      await _localStorage.cacheUser(user);

      // Initialize sync
      if (_connectivityService.isConnected) {
        await _dataSyncService.initializeSync(user.id);
      }

      emit(
        UserAuthenticated(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
          isGuest: false,
        ),
      );
    } catch (e) {
      print('Google sign-in error: $e');
      emit(UserError('Failed to sign in with Google: ${e.toString()}'));
      emit(const UserUnauthenticated());
    }
  }

  /// Continue as guest
  Future<void> continueAsGuest(String guestName) async {
    emit(const UserLoading());

    try {
      final user = await _authService.continueAsGuest(guestName);
      _currentUser = user;

      // Cache user data
      await _localStorage.cacheUser(user);

      emit(
        UserAuthenticated(
          id: user.id,
          name: user.name,
          email: null,
          avatarUrl: null,
          isGuest: true,
        ),
      );
    } catch (e) {
      print('Guest mode error: $e');
      emit(UserError('Failed to continue as guest: ${e.toString()}'));
      emit(const UserUnauthenticated());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const UserLoading());

    try {
      await _authService.signOut();
      await _localStorage.clearAllCache();
      _currentUser = null;

      emit(const UserUnauthenticated());
    } catch (e) {
      print('Sign out error: $e');
      emit(UserError('Failed to sign out: ${e.toString()}'));
    }
  }

  /// Save route (handles both guest and authenticated users)
  /// Offline-first: Always saves to local, then syncs to Supabase if online
  Future<void> saveRoute({
    required String routeId,
    required int sourceId,
    required int destId,
    required String fromStation,
    required String toStation,
    required List<String> path,
    required int totalStations,
    required double price,
    required int estimatedTime,
  }) async {
    try {
      // Prepare route data for local storage
      final localRouteData = {
        'id': routeId,
        'source_station_id': sourceId,
        'destination_station_id': destId,
        'from_station': fromStation,
        'to_station': toStation,
        'path': path,
        'total_stations': totalStations,
        'price': price,
        'estimated_time': estimatedTime,
        'saved_at': DateTime.now().toIso8601String(),
      };

      // 1. ALWAYS save to local storage first (offline-first)
      await _localStorage.saveGuestRoute(localRouteData);

      // 2. If authenticated (not guest), try to sync to Supabase
      if (_currentUser != null && !_currentUser!.isGuest) {
        // Only sync if online
        if (_connectivityService.isConnected) {
          try {
            final supabaseRouteData = {
              'user_id': _currentUser!.id,
              'from_station': fromStation,
              'to_station': toStation,
              'path': path,
              'total_stations': totalStations,
              'price': price,
              'estimated_time': estimatedTime,
              'created_at': DateTime.now().toIso8601String(),
            };

            // Try to insert to Supabase
            await _dataSyncService.supabase
                .from('saved_routes')
                .insert(supabaseRouteData);
            print("✅ Route saved to both local and Supabase");
          } catch (supabaseError) {
            // Supabase sync failed, but local save succeeded
            print(
              "⚠️ Route saved locally, Supabase sync failed: $supabaseError",
            );
            // Don't throw - local save is enough for offline-first
          }
        } else {
          print("📴 Offline: Route saved locally, will sync when online");
        }
      } else {
        print("👤 Guest mode: Route saved locally only");
      }
    } catch (e) {
      print("❌ CRITICAL SAVE ERROR: $e");
      rethrow;
    }
  }

  /// Get saved routes (handles both guest and authenticated users)
  /// Offline-first: Returns local data immediately, syncs in background if online
  Future<List<Map<String, dynamic>>> getSavedRoutes() async {
    if (_currentUser == null) {
      return [];
    }

    try {
      // Always get local routes first (offline-first)
      final localRoutes = _localStorage.getGuestRoutes();

      // If authenticated and online, try to sync with Supabase
      if (!_currentUser!.isGuest && _connectivityService.isConnected) {
        try {
          final syncedRoutes = await _dataSyncService.getSavedRoutes(
            _currentUser!.id,
          );
          return syncedRoutes;
        } catch (syncError) {
          // Sync failed, return local data
          print('Sync failed, using local routes: $syncError');
          return localRoutes;
        }
      }

      // Guest or offline: return local data
      return localRoutes;
    } catch (e) {
      print('Error getting saved routes: $e');
      return [];
    }
  }

  /// Check if a route is saved
  Future<bool> isRouteSaved(int sourceId, int destId) async {
    return _localStorage.isRouteSaved(sourceId, destId);
  }

  /// Delete saved route
  /// Offline-first: Always deletes from local, then syncs to Supabase if online
  Future<void> deleteRoute(String routeId) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      // Always delete from local first
      await _localStorage.deleteGuestRoute(routeId);

      // If authenticated and online, try to delete from Supabase
      if (!_currentUser!.isGuest && _connectivityService.isConnected) {
        try {
          await _dataSyncService.deleteRouteForUser(
            userId: _currentUser!.id,
            routeId: routeId,
          );
        } catch (syncError) {
          // Sync failed, but local deletion succeeded
          print('Could not delete from Supabase (offline?): $syncError');
        }
      }
    } catch (e) {
      print('Error deleting route: $e');
      rethrow;
    }
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen(
      (user) async {
        if (user != null && !_authService.isGuestMode()) {
          _currentUser = user;
          await _localStorage.cacheUser(user);

          if (_connectivityService.isConnected) {
            await _dataSyncService.initializeSync(user.id);
          }

          emit(
            UserAuthenticated(
              id: user.id,
              name: user.name,
              email: user.email,
              avatarUrl: user.avatarUrl,
              isGuest: false,
            ),
          );
        } else if (_authService.isGuestMode()) {
          // Keep guest state
          return;
        } else {
          _currentUser = null;
          emit(const UserUnauthenticated());
        }
      },
      onError: (error) {
        print('Auth state change error: $error');
      },
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
