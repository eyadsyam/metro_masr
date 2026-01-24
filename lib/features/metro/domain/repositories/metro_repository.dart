import '../entities/station.dart';
import '../entities/route_result.dart';
import '../entities/station_connection.dart';

abstract class IMetroRepository {
  Future<List<Station>> getAllStations();
  Future<List<Station>> getStationsByLine(int lineId);
  Future<List<StationConnection>> getAllConnections();
}
