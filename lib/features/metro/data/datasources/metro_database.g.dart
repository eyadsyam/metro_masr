// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metro_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  StationDao? _stationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `stations` (`id` INTEGER NOT NULL, `nameAr` TEXT NOT NULL, `nameEn` TEXT NOT NULL, `lineId` INTEGER NOT NULL, `isInterchange` INTEGER NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, FOREIGN KEY (`lineId`) REFERENCES `LineEntity` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LineEntity` (`id` INTEGER NOT NULL, `nameAr` TEXT NOT NULL, `nameEn` TEXT NOT NULL, `colorHex` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `station_connections` (`fromStationId` INTEGER NOT NULL, `toStationId` INTEGER NOT NULL, `cost` INTEGER NOT NULL, FOREIGN KEY (`fromStationId`) REFERENCES `stations` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`toStationId`) REFERENCES `stations` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`fromStationId`, `toStationId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  StationDao get stationDao {
    return _stationDaoInstance ??= _$StationDao(database, changeListener);
  }
}

class _$StationDao extends StationDao {
  _$StationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _stationEntityInsertionAdapter = InsertionAdapter(
            database,
            'stations',
            (StationEntity item) => <String, Object?>{
                  'id': item.id,
                  'nameAr': item.nameAr,
                  'nameEn': item.nameEn,
                  'lineId': item.lineId,
                  'isInterchange': item.isInterchange ? 1 : 0,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                }),
        _lineEntityInsertionAdapter = InsertionAdapter(
            database,
            'LineEntity',
            (LineEntity item) => <String, Object?>{
                  'id': item.id,
                  'nameAr': item.nameAr,
                  'nameEn': item.nameEn,
                  'colorHex': item.colorHex
                }),
        _stationConnectionEntityInsertionAdapter = InsertionAdapter(
            database,
            'station_connections',
            (StationConnectionEntity item) => <String, Object?>{
                  'fromStationId': item.fromStationId,
                  'toStationId': item.toStationId,
                  'cost': item.cost
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StationEntity> _stationEntityInsertionAdapter;

  final InsertionAdapter<LineEntity> _lineEntityInsertionAdapter;

  final InsertionAdapter<StationConnectionEntity>
      _stationConnectionEntityInsertionAdapter;

  @override
  Future<List<StationEntity>> getAllStations() async {
    return _queryAdapter.queryList('SELECT * FROM stations',
        mapper: (Map<String, Object?> row) => StationEntity(
            id: row['id'] as int,
            nameAr: row['nameAr'] as String,
            nameEn: row['nameEn'] as String,
            lineId: row['lineId'] as int,
            isInterchange: (row['isInterchange'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double));
  }

  @override
  Future<StationEntity?> getStationById(int id) async {
    return _queryAdapter.query('SELECT * FROM stations WHERE id = ?1',
        mapper: (Map<String, Object?> row) => StationEntity(
            id: row['id'] as int,
            nameAr: row['nameAr'] as String,
            nameEn: row['nameEn'] as String,
            lineId: row['lineId'] as int,
            isInterchange: (row['isInterchange'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double),
        arguments: [id]);
  }

  @override
  Future<List<StationEntity>> getStationsByLine(int lineId) async {
    return _queryAdapter.queryList('SELECT * FROM stations WHERE lineId = ?1',
        mapper: (Map<String, Object?> row) => StationEntity(
            id: row['id'] as int,
            nameAr: row['nameAr'] as String,
            nameEn: row['nameEn'] as String,
            lineId: row['lineId'] as int,
            isInterchange: (row['isInterchange'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double),
        arguments: [lineId]);
  }

  @override
  Future<List<StationConnectionEntity>> getAllConnections() async {
    return _queryAdapter.queryList('SELECT * FROM station_connections',
        mapper: (Map<String, Object?> row) => StationConnectionEntity(
            fromStationId: row['fromStationId'] as int,
            toStationId: row['toStationId'] as int,
            cost: row['cost'] as int));
  }

  @override
  Future<List<LineEntity>> getAllLines() async {
    return _queryAdapter.queryList('SELECT * FROM LineEntity',
        mapper: (Map<String, Object?> row) => LineEntity(
            id: row['id'] as int,
            nameAr: row['nameAr'] as String,
            nameEn: row['nameEn'] as String,
            colorHex: row['colorHex'] as String));
  }

  @override
  Future<int?> getStationsCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM stations',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertStation(StationEntity station) async {
    await _stationEntityInsertionAdapter.insert(
        station, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertLine(LineEntity line) async {
    await _lineEntityInsertionAdapter.insert(line, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertConnection(StationConnectionEntity connection) async {
    await _stationConnectionEntityInsertionAdapter.insert(
        connection, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertStations(List<StationEntity> stations) async {
    await _stationEntityInsertionAdapter.insertList(
        stations, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertLines(List<LineEntity> lines) async {
    await _lineEntityInsertionAdapter.insertList(
        lines, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertConnections(
      List<StationConnectionEntity> connections) async {
    await _stationConnectionEntityInsertionAdapter.insertList(
        connections, OnConflictStrategy.replace);
  }
}
