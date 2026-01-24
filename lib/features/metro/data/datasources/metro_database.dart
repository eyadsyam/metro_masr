import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/station_entity.dart';
import '../models/line_entity.dart';
import '../models/station_connection_entity.dart';
import 'station_dao.dart';

part 'metro_database.g.dart';

@Database(
  version: 1,
  entities: [StationEntity, LineEntity, StationConnectionEntity],
)
abstract class AppDatabase extends FloorDatabase {
  StationDao get stationDao;
}
