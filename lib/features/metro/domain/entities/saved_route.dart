import 'package:equatable/equatable.dart';

class SavedRoute extends Equatable {
  final String id;
  final String sourceStationName;
  final String destinationStationName;
  final int sourceStationId;
  final int destinationStationId;
  final DateTime savedAt;

  const SavedRoute({
    required this.id,
    required this.sourceStationName,
    required this.destinationStationName,
    required this.sourceStationId,
    required this.destinationStationId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceStationName': sourceStationName,
      'destinationStationName': destinationStationName,
      'sourceStationId': sourceStationId,
      'destinationStationId': destinationStationId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedRoute.fromJson(Map<String, dynamic> json) {
    return SavedRoute(
      id: json['id'] as String,
      sourceStationName: json['sourceStationName'] as String,
      destinationStationName: json['destinationStationName'] as String,
      sourceStationId: json['sourceStationId'] as int,
      destinationStationId: json['destinationStationId'] as int,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, sourceStationId, destinationStationId];
}
