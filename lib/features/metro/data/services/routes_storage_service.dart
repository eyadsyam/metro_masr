import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/saved_route.dart';

class RoutesStorageService {
  static const String _savedRoutesKey = 'saved_routes';
  static const String _recentRoutesKey = 'recent_routes';

  final SharedPreferences _prefs;

  RoutesStorageService(this._prefs);

  // Saved Routes
  Future<List<SavedRoute>> getSavedRoutes() async {
    final jsonString = _prefs.getString(_savedRoutesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => SavedRoute.fromJson(json)).toList();
  }

  Future<void> saveRoute(SavedRoute route) async {
    final routes = await getSavedRoutes();

    // Check if already saved
    if (routes.any((r) => r.id == route.id)) return;

    routes.insert(0, route);

    // Keep only last 20
    if (routes.length > 20) {
      routes.removeRange(20, routes.length);
    }

    final jsonString = json.encode(routes.map((r) => r.toJson()).toList());
    await _prefs.setString(_savedRoutesKey, jsonString);
  }

  Future<void> removeRoute(String routeId) async {
    final routes = await getSavedRoutes();
    routes.removeWhere((r) => r.id == routeId);

    final jsonString = json.encode(routes.map((r) => r.toJson()).toList());
    await _prefs.setString(_savedRoutesKey, jsonString);
  }

  Future<bool> isRouteSaved(int sourceId, int destId) async {
    final routes = await getSavedRoutes();
    return routes.any(
      (r) => r.sourceStationId == sourceId && r.destinationStationId == destId,
    );
  }

  // Recent Routes
  Future<List<SavedRoute>> getRecentRoutes() async {
    final jsonString = _prefs.getString(_recentRoutesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => SavedRoute.fromJson(json)).toList();
  }

  Future<void> addRecentRoute(SavedRoute route) async {
    final routes = await getRecentRoutes();

    // Remove if already exists
    routes.removeWhere((r) => r.id == route.id);

    // Add to beginning
    routes.insert(0, route);

    // Keep only last 10
    if (routes.length > 10) {
      routes.removeRange(10, routes.length);
    }

    final jsonString = json.encode(routes.map((r) => r.toJson()).toList());
    await _prefs.setString(_recentRoutesKey, jsonString);
  }

  Future<void> clearRecentRoutes() async {
    await _prefs.remove(_recentRoutesKey);
  }
}
