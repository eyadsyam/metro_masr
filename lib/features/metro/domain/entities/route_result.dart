// Domain Entity: RouteResult
import 'package:equatable/equatable.dart';
import 'station.dart';

class RouteResult extends Equatable {
  final List<Station> path;
  final double totalPrice;
  final int totalStations;
  final int estimatedTimeMinutes;
  final List<String> transferInstructions;

  const RouteResult({
    required this.path,
    required this.totalPrice,
    required this.totalStations,
    required this.estimatedTimeMinutes,
    required this.transferInstructions,
  });

  @override
  List<Object?> get props => [
    path,
    totalPrice,
    totalStations,
    estimatedTimeMinutes,
    transferInstructions,
  ];
}
