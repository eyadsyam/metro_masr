import 'package:equatable/equatable.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/entities/saved_route.dart';

enum MetroStatus { initial, loading, stationsLoaded, routeCalculated, error }

class MetroState extends Equatable {
  final MetroStatus status;
  final List<Station> stations;
  final List<SavedRoute> recentRoutes;
  final RouteResult? routeResult;
  final String? errorMessage;

  // Selection state
  final Station? sourceStation;
  final Station? destinationStation;

  const MetroState({
    this.status = MetroStatus.initial,
    this.stations = const [],
    this.recentRoutes = const [],
    this.routeResult,
    this.errorMessage,
    this.sourceStation,
    this.destinationStation,
  });

  MetroState copyWith({
    MetroStatus? status,
    List<Station>? stations,
    List<SavedRoute>? recentRoutes,
    RouteResult? routeResult,
    String? errorMessage,
    Station? sourceStation,
    Station? destinationStation,
    bool clearRoute = false,
  }) {
    return MetroState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      recentRoutes: recentRoutes ?? this.recentRoutes,
      routeResult: clearRoute ? null : (routeResult ?? this.routeResult),
      errorMessage: errorMessage,
      sourceStation: sourceStation ?? this.sourceStation,
      destinationStation: destinationStation ?? this.destinationStation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stations,
    recentRoutes,
    routeResult,
    errorMessage,
    sourceStation,
    destinationStation,
  ];
}
