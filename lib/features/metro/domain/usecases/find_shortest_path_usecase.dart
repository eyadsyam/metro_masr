import 'dart:collection';
import '../entities/station.dart';
import '../entities/station_connection.dart';
import '../entities/route_result.dart';
import '../repositories/metro_repository.dart';

class FindShortestPathUseCase {
  final IMetroRepository repository;

  FindShortestPathUseCase(this.repository);

  Future<RouteResult> call(Station startNode, Station endNode) async {
    // Validation: Cannot select same station
    if (startNode.id == endNode.id) {
      throw Exception('Source and destination cannot be the same station');
    }

    final allStations = await repository.getAllStations();
    final allConnections = await repository.getAllConnections();

    // Build Graph
    // map stationId -> list of connections
    final graph = <int, List<StationConnection>>{};
    for (var conn in allConnections) {
      if (!graph.containsKey(conn.fromStationId)) {
        graph[conn.fromStationId] = [];
      }
      graph[conn.fromStationId]!.add(conn);

      // Assuming undirected graph for metro usually, but let's see.
      // If connections are one-way in DB, we need to handle that.
      // Usually metro tracks are bidirectional but described as edges.
      // Seeder should add both directions or we treat as undirected.
      // Let's assume the DB has explicit edges for both ways OR we add reverse edge here.
      // For safety, let's treat as directed based on DB, but if DB only has A->B, we might need B->A.
      // I'll assume Seeder adds bidirectional or I add reverse here.
      // Let's add reverse connection here to be safe for a Metro system.
      if (!graph.containsKey(conn.toStationId)) {
        graph[conn.toStationId] = [];
      }
      graph[conn.toStationId]!.add(
        StationConnection(
          fromStationId: conn.toStationId,
          toStationId: conn.fromStationId,
          cost: conn.cost,
        ),
      );
    }

    // Dijkstra Data Structures
    final distances = <int, int>{};
    final previous = <int, int>{};
    final queue = SplayTreeSet<MapEntry<int, int>>(
      (a, b) => a.value.compareTo(b.value) == 0
          ? a.key.compareTo(b.key)
          : a.value.compareTo(b.value),
    );

    // Initialize
    for (var station in allStations) {
      if (station.id == startNode.id) {
        distances[station.id] = 0;
        queue.add(MapEntry(station.id, 0));
      } else {
        distances[station.id] = 999999; // Infinity
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.first;
      queue.remove(current);
      final u = current.key;

      if (u == endNode.id) break; // Found target

      final neighbors = graph[u] ?? [];
      for (var neighbor in neighbors) {
        final v = neighbor.toStationId;
        final alt = distances[u]! + neighbor.cost;
        if (alt < distances[v]!) {
          queue.remove(MapEntry(v, distances[v]!));
          distances[v] = alt;
          previous[v] = u;
          queue.add(MapEntry(v, alt));
        }
      }
    }

    // Reconstruct Path using path reconstruction from 'previous' map
    final path = <Station>[];
    int? curr = endNode.id;
    if (previous.containsKey(curr) || curr == startNode.id) {
      while (curr != null) {
        final stationToAdd = allStations.firstWhere((s) => s.id == curr);
        path.insert(0, stationToAdd);
        curr = previous[curr];
      }
    }

    if (path.isEmpty) {
      return RouteResult(
        path: [],
        totalPrice: 0,
        totalStations: 0,
        estimatedTimeMinutes: 0,
        transferInstructions: [],
      );
    }

    // --- LOGIC REFINEMENT ---

    // 1. Calculate Stations Count for Pricing
    // We must subtract "Transfer Steps" from the count given my Seeder logic (where Transfer is an edge between 2 nodes).
    // If we go 119 -> 210 (Sadat L1 to Sadat L2), that is a move in graph, but physically 0 travel distance.
    // So we iterate and detect "Line Changes" where station name is same (or purely based on IDs if we have mapping).
    // The safest is to count "unique station names" or just distinct locations.
    // Or we simply check if edge cost was 0 (or close to 0) in the graph construction.
    // Since we don't have the edge cost explicitly in the 'path' list, we infer from Line ID changes on same/connected station.

    int pricingCount =
        1; // Start station counts? "Up to 9 stations" usually means path size.
    // Let's assume path.length is the base.

    int transfersCount = 0;
    final transferInstructions = <String>[];

    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      // Check if this step is a Transfer
      // In my Seeder, Transfers are edges between stations with isInterchange=true (usually) and different LineIDs
      // e.g. Sadat(119, Line1) -> Sadat(210, Line2)
      // If names match, it's definitely a transfer.
      bool isTransfer =
          (current.nameEn == next.nameEn) && (current.lineId != next.lineId);

      if (isTransfer) {
        transfersCount++;
        transferInstructions.add(
          "At ${current.nameEn}, switch to ${next.lineId == 1
              ? 'Line 1 (Blue)'
              : next.lineId == 2
              ? 'Line 2 (Red)'
              : 'Line 3 (Green)'}",
        );
      } else {
        pricingCount++;
      }
    }

    // Pricing
    int price = 0;
    if (pricingCount <= 9) {
      price = 8;
    } else if (pricingCount <= 16) {
      price = 10;
    } else if (pricingCount <= 23) {
      price = 15;
    } else {
      price = 20;
    }

    // Time Estimate: 2 min per station hop, 5 min per transfer
    int totalTime = (pricingCount * 2) + (transfersCount * 5);

    return RouteResult(
      path: path,
      totalPrice: price.toDouble(),
      totalStations: pricingCount,
      estimatedTimeMinutes: totalTime,
      transferInstructions: transferInstructions,
    );
  }

  int calculatePrice(int stationsCount) {
    if (stationsCount <= 9) return 8;
    if (stationsCount <= 16) return 10;
    if (stationsCount <= 23) return 15;
    return 20;
  }
}
