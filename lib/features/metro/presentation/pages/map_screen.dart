import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gap/gap.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/metro_cubit.dart';
import '../bloc/metro_state.dart';
import '../../domain/entities/station.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _cairoCenter = const LatLng(30.0444, 31.2357);
  LatLng? _userLocation;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied)
        return;

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MetroCubit, MetroState>(
        builder: (context, state) {
          final stations = state.stations;
          final routeResult = state.routeResult;

          // Station Markers
          final markers = stations.map((s) {
            final isSource = state.sourceStation?.id == s.id;
            final isDestination = state.destinationStation?.id == s.id;

            return Marker(
              point: LatLng(s.latitude, s.longitude),
              width: 30,
              height: 30,
              child: GestureDetector(
                onTap: () => _showStationSheet(context, s),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSource
                        ? Colors.green
                        : isDestination
                        ? Colors.red
                        : _getLineColor(s.lineId),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: Colors.black26),
                    ],
                  ),
                  child: Icon(
                    isSource
                        ? Icons.flag
                        : isDestination
                        ? Icons.location_on
                        : Icons.train,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            );
          }).toList();

          // Station Labels (show when zoomed in)
          final labelMarkers = _currentZoom > 13
              ? stations.map((s) {
                  return Marker(
                    point: LatLng(s.latitude, s.longitude),
                    width: 120,
                    height: 40,
                    child: Transform.translate(
                      offset: const Offset(0, 25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s.getName(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList()
              : <Marker>[];

          // User Location Marker
          final userMarker = _userLocation != null
              ? [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ]
              : <Marker>[];

          // Route Polyline
          final polylines = routeResult != null && routeResult.path.isNotEmpty
              ? _buildRoutePolylines(routeResult.path, stations)
              : <Polyline>[];

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _cairoCenter,
                  initialZoom: 12.0,
                  onPositionChanged: (position, hasGesture) {
                    setState(() {
                      _currentZoom = position.zoom ?? 12.0;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.metro_masr',
                  ),
                  if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: [...markers, ...userMarker]),
                  if (labelMarkers.isNotEmpty)
                    MarkerLayer(markers: labelMarkers),
                ],
              ),

              // Top Controls
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),

              // Recenter Button
              Positioned(
                bottom: 30,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'recenter',
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: _zoomToUser,
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Polyline> _buildRoutePolylines(
    List<Station> path,
    List<Station> allStations,
  ) {
    if (path.length < 2) return [];

    final polylines = <Polyline>[];

    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      polylines.add(
        Polyline(
          points: [
            LatLng(current.latitude, current.longitude),
            LatLng(next.latitude, next.longitude),
          ],
          color: _getLineColor(current.lineId),
          strokeWidth: 5.0,
        ),
      );
    }

    return polylines;
  }

  Future<void> _zoomToUser() async {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      await _getUserLocation();
      if (_userLocation != null) {
        _mapController.move(_userLocation!, 15.0);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('location_disabled'.tr())));
        }
      }
    }
  }

  void _showStationSheet(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              station.getName(context),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const Gap(8),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MetroCubit>().selectSource(station);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.flag, size: 18),
                    label: Text('start_journey'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<MetroCubit>().selectDestination(station);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.location_on, size: 18),
                    label: Text('end_journey'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLineColor(int lineId) {
    switch (lineId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
