// Domain Entity: StationConnection
import 'package:equatable/equatable.dart';

class StationConnection extends Equatable {
  final int fromStationId;
  final int toStationId;
  final int cost; // Could be time or just a weight. Prompt says "cost/time".

  const StationConnection({
    required this.fromStationId,
    required this.toStationId,
    required this.cost,
  });

  @override
  List<Object?> get props => [fromStationId, toStationId, cost];
}
