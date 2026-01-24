import 'package:flutter_test/flutter_test.dart';
import 'package:metro_masr/features/metro/domain/entities/station.dart';
import 'package:metro_masr/features/metro/domain/entities/station_connection.dart';
import 'package:metro_masr/features/metro/domain/repositories/metro_repository.dart';
import 'package:metro_masr/features/metro/domain/usecases/find_shortest_path_usecase.dart';

// Simple Mock Repository
class MockMetroRepository implements IMetroRepository {
  @override
  Future<List<Station>> getAllStations() async {
    return [
      const Station(
        id: 1,
        nameAr: 'A',
        nameEn: 'A',
        lineId: 1,
        isInterchange: false,
        latitude: 0,
        longitude: 0,
      ),
      const Station(
        id: 2,
        nameAr: 'B',
        nameEn: 'B',
        lineId: 1,
        isInterchange: false,
        latitude: 0,
        longitude: 0,
      ),
      const Station(
        id: 3,
        nameAr: 'C',
        nameEn: 'C',
        lineId: 2,
        isInterchange: false,
        latitude: 0,
        longitude: 0,
      ),
    ];
  }

  @override
  Future<List<StationConnection>> getAllConnections() async {
    return [
      const StationConnection(
        fromStationId: 1,
        toStationId: 2,
        cost: 1,
      ), // A -> B
      const StationConnection(
        fromStationId: 2,
        toStationId: 3,
        cost: 5,
      ), // B -> C (Transfer)
    ];
  }

  @override
  Future<List<Station>> getStationsByLine(int lineId) async {
    return [];
  }
}

void main() {
  late FindShortestPathUseCase useCase;
  late MockMetroRepository mockRepository;

  setUp(() {
    mockRepository = MockMetroRepository();
    useCase = FindShortestPathUseCase(mockRepository);
  });

  test('should find shortest path from A to C', () async {
    // Arrange
    final start = const Station(
      id: 1,
      nameAr: 'A',
      nameEn: 'A',
      lineId: 1,
      isInterchange: false,
      latitude: 0,
      longitude: 0,
    );
    final end = const Station(
      id: 3,
      nameAr: 'C',
      nameEn: 'C',
      lineId: 2,
      isInterchange: false,
      latitude: 0,
      longitude: 0,
    );

    // Act
    final result = await useCase(start, end);

    // Assert
    expect(result.path.length, 3); // A, B, C
    expect(result.path[0].id, 1);
    expect(result.path[2].id, 3);

    // Price for 3 stations: 8 EGP
    expect(result.totalPrice, 8);
  });
}
