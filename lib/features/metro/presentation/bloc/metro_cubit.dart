import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/usecases/find_shortest_path_usecase.dart';
import '../../domain/usecases/get_all_stations_usecase.dart';
import '../../data/services/routes_storage_service.dart';

import 'metro_state.dart';

class MetroCubit extends Cubit<MetroState> {
  final GetAllStationsUseCase getAllStationsUseCase;
  final FindShortestPathUseCase findShortestPathUseCase;

  MetroCubit({
    required this.getAllStationsUseCase,
    required this.findShortestPathUseCase,
  }) : super(const MetroState()) {
    loadStations();
  }

  Future<void> loadStations() async {
    emit(state.copyWith(status: MetroStatus.loading));
    try {
      final stations = await getAllStationsUseCase();

      // Load recent routes too
      await loadRecentRoutes();

      // Emit loaded first
      emit(
        state.copyWith(status: MetroStatus.stationsLoaded, stations: stations),
      );

      // Then try to locate user
      _autoLocateNearestStation(stations);
    } catch (e) {
      emit(
        state.copyWith(
          status: MetroStatus.error,
          errorMessage: 'Failed to load stations: $e',
        ),
      );
    }
  }

  Future<void> loadRecentRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageService = RoutesStorageService(prefs);
      final recent = await storageService.getRecentRoutes();
      emit(state.copyWith(recentRoutes: recent));
    } catch (e) {
      print('Error loading recent routes: $e');
    }
  }

  Future<void> _autoLocateNearestStation(List<Station> stations) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();

      Station? nearest;
      double minDistance = double.infinity;

      for (var s in stations) {
        final dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          s.latitude,
          s.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearest = s;
        }
      }

      if (nearest != null) {
        emit(state.copyWith(sourceStation: nearest));
      }
    } catch (e) {
      print("Location auto-detect failed: $e");
    }
  }

  void selectSource(Station? station) {
    emit(
      state.copyWith(
        sourceStation: station,
        status: MetroStatus.stationsLoaded, // Reset status to prevent auto-jump
      ),
    );
  }

  void selectDestination(Station? station) {
    if (state.sourceStation == station) return;
    emit(
      state.copyWith(
        destinationStation: station,
        status: MetroStatus.stationsLoaded, // Reset status to prevent auto-jump
      ),
    );
  }

  void swapStations() {
    final oldSource = state.sourceStation;
    final oldDest = state.destinationStation;
    emit(
      state.copyWith(
        sourceStation: oldDest,
        destinationStation: oldSource,
        status: MetroStatus.stationsLoaded,
        clearRoute: true,
      ),
    );
  }

  Future<void> findRoute() async {
    if (state.sourceStation == null || state.destinationStation == null) {
      emit(
        state.copyWith(
          status: MetroStatus.error,
          errorMessage: 'Please select both Source and Destination stations.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: MetroStatus.loading));

    try {
      final result = await findShortestPathUseCase(
        state.sourceStation!,
        state.destinationStation!,
      );

      emit(
        state.copyWith(
          routeResult: result,
          status: MetroStatus.routeCalculated,
        ),
      );

      // Add to recent routes
      await _addToRecentRoutes();
    } catch (e) {
      emit(
        state.copyWith(
          status: MetroStatus.error,
          errorMessage: 'Failed to calculate route: $e',
        ),
      );
    }
  }

  Future<void> _addToRecentRoutes() async {
    if (state.sourceStation == null || state.destinationStation == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final storageService = RoutesStorageService(prefs);

      final route = SavedRoute(
        id: '${state.sourceStation!.id}_${state.destinationStation!.id}',
        sourceStationName: state.sourceStation!.nameEn,
        destinationStationName: state.destinationStation!.nameEn,
        sourceStationId: state.sourceStation!.id,
        destinationStationId: state.destinationStation!.id,
        savedAt: DateTime.now(),
      );

      await storageService.addRecentRoute(route);
      await loadRecentRoutes(); // Update state with new list
    } catch (e) {
      // Silently fail - don't disrupt user experience
      print('Failed to add recent route: $e');
    }
  }

  Future<void> clearRecentRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageService = RoutesStorageService(prefs);
      await storageService.clearRecentRoutes();
      emit(state.copyWith(recentRoutes: []));
    } catch (e) {
      print('Failed to clear recent routes: $e');
    }
  }
}
