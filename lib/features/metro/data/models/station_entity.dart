import 'package:floor/floor.dart';
import 'line_entity.dart';

@Entity(
  tableName: 'stations',
  foreignKeys: [
    ForeignKey(
      childColumns: ['lineId'],
      parentColumns: ['id'],
      entity: LineEntity,
    ),
  ],
)
class StationEntity {
  @primaryKey
  final int id;

  final String nameAr;
  final String nameEn;
  final String? landmarkAr;
  final String? landmarkEn;
  final int lineId;
  final bool isInterchange;
  final double latitude;
  final double longitude;

  StationEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.landmarkAr,
    this.landmarkEn,
    required this.lineId,
    required this.isInterchange,
    required this.latitude,
    required this.longitude,
  });
}
