import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

/// Local Storage Service
/// Handles caching of user data and saved routes for offline access
/// Each user has isolated storage using userId prefix
class LocalStorageService {
  final SharedPreferences _prefs;
  String? _currentUserId;

  LocalStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys for local storage
  static const String _keyUserCache = 'user_cache';
  static const String _keyLastSyncTime = 'last_sync_time';

  /// Set current user ID for storage isolation
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Get user-specific key
  String _getUserKey(String baseKey) {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return 'guest_${baseKey}';
    }
    return 'user_${_currentUserId}_$baseKey';
  }

  /// Cache user data
  Future<void> cacheUser(AppUser user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_keyUserCache, userJson);
      setCurrentUserId(user.id);
    } catch (e) {
      print('Error caching user: $e');
    }
  }

  /// Get cached user
  AppUser? getCachedUser() {
    try {
      final userJson = _prefs.getString(_keyUserCache);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = AppUser.fromJson(userMap);
        setCurrentUserId(user.id);
        return user;
      }
      return null;
    } catch (e) {
      print('Error getting cached user: $e');
      return null;
    }
  }

  /// Clear user cache
  Future<void> clearUserCache() async {
    await _prefs.remove(_keyUserCache);
    _currentUserId = null;
  }

  /// Cache saved routes (for authenticated users)
  Future<void> cacheSavedRoutes(List<Map<String, dynamic>> routes) async {
    try {
      final routesJson = jsonEncode(routes);
      final key = _getUserKey('saved_routes_cache');
      await _prefs.setString(key, routesJson);
    } catch (e) {
      print('Error caching routes: $e');
    }
  }

  /// Get cached saved routes
  List<Map<String, dynamic>> getCachedSavedRoutes() {
    try {
      final key = _getUserKey('saved_routes_cache');
      final routesJson = _prefs.getString(key);
      if (routesJson != null) {
        final routesList = jsonDecode(routesJson) as List<dynamic>;
        return routesList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting cached routes: $e');
      return [];
    }
  }

  /// Save guest route (local only, never synced)
  Future<void> saveGuestRoute(Map<String, dynamic> route) async {
    try {
      final routes = getGuestRoutes();

      // Check if route already exists (by id)
      final existingIndex = routes.indexWhere((r) => r['id'] == route['id']);

      if (existingIndex != -1) {
        routes[existingIndex] = route;
      } else {
        routes.add(route);
      }

      final routesJson = jsonEncode(routes);
      final key = _getUserKey('routes');
      await _prefs.setString(key, routesJson);
    } catch (e) {
      print('Error saving guest route: $e');
    }
  }

  /// Get guest routes (local only)
  List<Map<String, dynamic>> getGuestRoutes() {
    try {
      final key = _getUserKey('routes');
      final routesJson = _prefs.getString(key);
      if (routesJson != null) {
        final routesList = jsonDecode(routesJson) as List<dynamic>;
        return routesList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting guest routes: $e');
      return [];
    }
  }

  /// Check if route exists locally
  bool isRouteSaved(int sourceId, int destId) {
    try {
      final routes = getGuestRoutes();
      return routes.any(
        (r) =>
            r['source_station_id'] == sourceId &&
            r['destination_station_id'] == destId,
      );
    } catch (e) {
      print('Error checking if route saved: $e');
      return false;
    }
  }

  /// Delete guest route
  Future<void> deleteGuestRoute(String routeId) async {
    try {
      final routes = getGuestRoutes();
      routes.removeWhere((route) => route['id'] == routeId);

      final routesJson = jsonEncode(routes);
      final key = _getUserKey('routes');
      await _prefs.setString(key, routesJson);
    } catch (e) {
      print('Error deleting guest route: $e');
    }
  }

  /// Clear all guest routes
  Future<void> clearGuestRoutes() async {
    final key = _getUserKey('routes');
    await _prefs.remove(key);
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    await _prefs.setString(_keyLastSyncTime, DateTime.now().toIso8601String());
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(_keyLastSyncTime);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  /// Clear all cache (for logout)
  Future<void> clearAllCache() async {
    if (_currentUserId != null) {
      final keysToRemove = _prefs
          .getKeys()
          .where(
            (key) =>
                key.startsWith('user_${_currentUserId}_') ||
                key.startsWith('guest_'),
          )
          .toList();

      for (final key in keysToRemove) {
        await _prefs.remove(key);
      }
    }

    await _prefs.remove(_keyUserCache);
    await _prefs.remove(_keyLastSyncTime);
    _currentUserId = null;
  }
}
