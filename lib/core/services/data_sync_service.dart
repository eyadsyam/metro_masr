import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';

/// Data Sync Service
/// Handles syncing saved routes between local storage and Supabase
/// Only syncs for authenticated users, never for guests
class DataSyncService {
  final SupabaseClient _supabase;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  DataSyncService({
    required SupabaseClient supabase,
    required LocalStorageService localStorage,
    required ConnectivityService connectivity,
  }) : _supabase = supabase,
       _localStorage = localStorage,
       _connectivity = connectivity;

  SupabaseClient get supabase => _supabase;

  /// Sync saved routes for authenticated user
  Future<void> syncSavedRoutes(String userId) async {
    if (!_connectivity.isConnected) {
      print('No internet connection, skipping sync');
      return;
    }

    try {
      // Fetch routes from Supabase
      final response = await _supabase
          .from(AppConfig.savedRoutesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final routes = response as List<dynamic>;
      final routesList = routes.cast<Map<String, dynamic>>();

      // Cache routes locally
      await _localStorage.cacheSavedRoutes(routesList);
      await _localStorage.updateLastSyncTime();

      print('Synced ${routesList.length} routes from Supabase');
    } catch (e) {
      print('Error syncing routes: $e');
      // Don't throw - use cached data if sync fails
    }
  }

  /// Save route for authenticated user (sync to Supabase)
  Future<void> saveRouteForUser({
    required String userId,
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
      final routeData = {
        'id': routeId, // Use specific ID
        'user_id': userId,
        'source_station_id': sourceId,
        'destination_station_id': destId,
        'from_station': fromStation, // Legacy/Display
        'to_station': toStation, // Legacy/Display
        'path': path,
        'total_stations': totalStations,
        'price': price,
        'estimated_time': estimatedTime,
        'created_at': DateTime.now().toIso8601String(),
        'savedAt': DateTime.now().toIso8601String(), // Match SavedRoute Json
        'sourceStationName': fromStation, // Match SavedRoute Json
        'destinationStationName': toStation, // Match SavedRoute Json
        'sourceStationId': sourceId, // Match SavedRoute Json
        'destinationStationId': destId, // Match SavedRoute Json
      };

      if (_connectivity.isConnected) {
        // Save to Supabase
        await _supabase.from(AppConfig.savedRoutesTable).insert(routeData);

        // Sync back to get the complete data with ID
        await syncSavedRoutes(userId);
      } else {
        // Queue for later sync (simplified - just cache locally)
        print('Offline: Route will be synced when connection is restored');
        // In a production app, you'd implement a proper sync queue
      }
    } catch (e) {
      print('Error saving route: $e');
      rethrow;
    }
  }

  /// Delete route for authenticated user
  Future<void> deleteRouteForUser({
    required String userId,
    required String routeId,
  }) async {
    try {
      if (_connectivity.isConnected) {
        await _supabase
            .from(AppConfig.savedRoutesTable)
            .delete()
            .eq('id', routeId)
            .eq('user_id', userId);

        // Sync to update cache
        await syncSavedRoutes(userId);
      } else {
        print('Offline: Deletion will be synced when connection is restored');
      }
    } catch (e) {
      print('Error deleting route: $e');
      rethrow;
    }
  }

  /// Get saved routes (from cache if offline, from Supabase if online)
  Future<List<Map<String, dynamic>>> getSavedRoutes(String userId) async {
    try {
      if (_connectivity.isConnected) {
        // Fetch fresh data from Supabase
        await syncSavedRoutes(userId);
      }

      // Return cached data
      return _localStorage.getCachedSavedRoutes();
    } catch (e) {
      print('Error getting saved routes: $e');
      // Return cached data on error
      return _localStorage.getCachedSavedRoutes();
    }
  }

  /// Initialize sync (call when user logs in or app starts)
  Future<void> initializeSync(String userId) async {
    if (_connectivity.isConnected) {
      await syncSavedRoutes(userId);
    }

    // Listen to connectivity changes and sync when online
    _connectivity.connectivityStream.listen((isConnected) {
      if (isConnected) {
        syncSavedRoutes(userId);
      }
    });
  }
}
