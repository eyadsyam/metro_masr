import 'package:floor/floor.dart';
import '../models/station_entity.dart';
import '../models/line_entity.dart';
import '../models/station_connection_entity.dart';

@dao
abstract class StationDao {
  @Query('SELECT * FROM stations')
  Future<List<StationEntity>> getAllStations();

  @Query('SELECT * FROM stations WHERE id = :id')
  Future<StationEntity?> getStationById(int id);

  @Query('SELECT * FROM stations WHERE lineId = :lineId')
  Future<List<StationEntity>> getStationsByLine(int lineId);

  @Query('SELECT * FROM station_connections')
  Future<List<StationConnectionEntity>> getAllConnections();

  @Query('SELECT * FROM LineEntity')
  Future<List<LineEntity>> getAllLines();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertStation(StationEntity station);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertLine(LineEntity line);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertConnection(StationConnectionEntity connection);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertStations(List<StationEntity> stations);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertLines(List<LineEntity> lines);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertConnections(List<StationConnectionEntity> connections);

  @Query('SELECT COUNT(*) FROM stations')
  Future<int?> getStationsCount();
}
