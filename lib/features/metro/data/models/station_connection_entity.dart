import 'package:floor/floor.dart';
import 'station_entity.dart';

@Entity(
  tableName: 'station_connections',
  primaryKeys: ['fromStationId', 'toStationId'],
  foreignKeys: [
    ForeignKey(
      childColumns: ['fromStationId'],
      parentColumns: ['id'],
      entity: StationEntity,
    ),
    ForeignKey(
      childColumns: ['toStationId'],
      parentColumns: ['id'],
      entity: StationEntity,
    ),
  ],
)
class StationConnectionEntity {
  final int fromStationId;
  final int toStationId;
  final int cost; // Cost or Time

  StationConnectionEntity({
    required this.fromStationId,
    required this.toStationId,
    required this.cost,
  });
}
