import 'package:flutter_test/flutter_test.dart';
import 'package:metro_masr/features/metro/domain/entities/station.dart';
import 'package:metro_masr/features/metro/domain/entities/station_connection.dart';
import 'package:metro_masr/features/metro/domain/repositories/metro_repository.dart';
import 'package:metro_masr/features/metro/domain/usecases/find_shortest_path_usecase.dart';

class MockMetroRepository implements IMetroRepository {
  final List<Station> _stations;
  final List<StationConnection> _connections;

  MockMetroRepository(this._stations, this._connections);

  @override
  Future<List<Station>> getAllStations() async => _stations;

  @override
  Future<List<StationConnection>> getAllConnections() async => _connections;

  @override
  Future<List<Station>> getStationsByLine(int lineId) async =>
      _stations.where((s) => s.lineId == lineId).toList();
}

void main() {
  late FindShortestPathUseCase useCase;

  Station st(int id, String name, int line, {bool interchange = false}) {
    return Station(
      id: id,
      nameAr: name,
      nameEn: name,
      lineId: line,
      isInterchange: interchange,
      latitude: 0,
      longitude: 0,
    );
  }

  void addEdges(List<StationConnection> list, int u, int v, int cost) {
    list.add(StationConnection(fromStationId: u, toStationId: v, cost: cost));
    list.add(StationConnection(fromStationId: v, toStationId: u, cost: cost));
  }

  group('Metro Logic Tests', () {
    test('1. Short Trip (3 stations) -> 8 EGP', () async {
      // Setup Linear path: 1-2-3
      final stations = [st(1, 'S1', 1), st(2, 'S2', 1), st(3, 'S3', 1)];
      final conns = <StationConnection>[];
      addEdges(conns, 1, 2, 1);
      addEdges(conns, 2, 3, 1);

      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));

      final result = await useCase(stations[0], stations[2]); // S1 -> S3

      expect(result.path.map((e) => e.id).toList(), [1, 2, 3]);
      expect(result.totalStations, 3);
      expect(result.totalPrice, 8.0);
    });

    test('2. Medium Trip (12 stations) -> 10 EGP', () async {
      final stations = List.generate(12, (i) => st(i + 1, 'S${i + 1}', 1));
      final conns = <StationConnection>[];
      for (int i = 0; i < 11; i++) {
        addEdges(conns, i + 1, i + 2, 1);
      }

      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));
      final result = await useCase(stations.first, stations.last);

      expect(result.totalStations, 12);
      expect(result.totalPrice, 10.0);
    });

    test('3. Long Trip (25 stations) -> 20 EGP', () async {
      final stations = List.generate(25, (i) => st(i + 1, 'S${i + 1}', 1));
      final conns = <StationConnection>[];
      for (int i = 0; i < 24; i++) {
        addEdges(conns, i + 1, i + 2, 1);
      }

      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));
      final result = await useCase(stations.first, stations.last);

      expect(result.totalStations, 25);
      expect(result.totalPrice, 20.0);
    });

    test('4. Interchange Logic (Line 1 -> Line 2)', () async {
      // Path: A(L1) -> B(L1/Interchange) -> C(L2/Interchange) -> D(L2)
      // B and C represent the same physical location but on different lines (Interchange nodes)
      final stations = [
        st(1, 'A', 1),
        st(2, 'InterchangeStation', 1, interchange: true), // Sadat L1
        st(3, 'InterchangeStation', 2, interchange: true), // Sadat L2
        st(4, 'D', 2),
      ];
      final conns = <StationConnection>[];
      addEdges(conns, 1, 2, 1); // A -> SadatL1
      addEdges(
        conns,
        2,
        3,
        5,
      ); // SadatL1 -> SadatL2 (Transfer cost, but 0 stations distance physically)
      addEdges(conns, 3, 4, 1); // SadatL2 -> D

      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));

      final result = await useCase(stations[0], stations[3]); // A -> D

      // Path length in nodes: 4 (A, Int1, Int2, D)
      // Pricing Logic should subtract the transfer step (Int1->Int2)
      // Station Count for Price: 4 nodes - 1 transfer = 3 stations.
      expect(result.totalStations, 3);
      expect(result.totalPrice, 8.0); // 3 stations <= 9 -> 8 EGP

      // Verify Transfer Instruction
      expect(result.transferInstructions.isNotEmpty, true);
      expect(result.transferInstructions.first, contains('switch to Line 2'));
    });

    test('5. Same Station -> rejected before routing', () async {
      final stations = [st(1, 'A', 1)];
      final conns = <StationConnection>[];
      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));

      // The use case refuses a trip that starts and ends at one station;
      // MetroCubit.findRoute checks this first and shows a clear message.
      expect(
        () => useCase(stations[0], stations[0]),
        throwsA(isA<Exception>()),
      );
    });

    test('6. Reverse Route -> Same Price', () async {
      final stations = [st(1, 'A', 1), st(2, 'B', 1)];
      final conns = <StationConnection>[];
      addEdges(conns, 1, 2, 1);

      useCase = FindShortestPathUseCase(MockMetroRepository(stations, conns));

      final res1 = await useCase(stations[0], stations[1]);
      final res2 = await useCase(stations[1], stations[0]);

      expect(res1.totalPrice, res2.totalPrice);
      expect(res1.totalStations, res2.totalStations);
    });
  });
}
