import '../../domain/entities/station.dart';
import '../../domain/entities/station_connection.dart';
import '../../domain/repositories/metro_repository.dart';
import '../datasources/metro_database.dart';
import '../models/station_entity.dart';
import '../models/station_connection_entity.dart';

class MetroRepositoryImpl implements IMetroRepository {
  final AppDatabase database;

  MetroRepositoryImpl(this.database);

  @override
  Future<List<Station>> getAllStations() async {
    final entities = await database.stationDao.getAllStations();
    return entities.map((e) => _mapStation(e)).toList();
  }

  @override
  Future<List<StationConnection>> getAllConnections() async {
    final entities = await database.stationDao.getAllConnections();
    return entities.map((e) => _mapConnection(e)).toList();
  }

  @override
  Future<List<Station>> getStationsByLine(int lineId) async {
    final entities = await database.stationDao.getStationsByLine(lineId);
    return entities.map((e) => _mapStation(e)).toList();
  }

  Station _mapStation(StationEntity entity) {
    return Station(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      lineId: entity.lineId,
      isInterchange: entity.isInterchange,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  StationConnection _mapConnection(StationConnectionEntity entity) {
    return StationConnection(
      fromStationId: entity.fromStationId,
      toStationId: entity.toStationId,
      cost: entity.cost,
    );
  }
}
