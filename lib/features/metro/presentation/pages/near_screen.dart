import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metro_masr/features/metro/presentation/bloc/metro_cubit.dart';
import 'package:metro_masr/features/metro/domain/entities/station.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NearScreen extends StatefulWidget {
  const NearScreen({super.key});

  @override
  State<NearScreen> createState() => _NearScreenState();
}

class _NearScreenState extends State<NearScreen> {
  Position? _currentPosition;
  List<Station> _sortedStations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLocate();
  }

  Future<void> _checkPermissionAndLocate() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
        _sortStations();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sortStations() {
    if (_currentPosition == null) return;

    final cubit = context.read<MetroCubit>();
    final allStations = cubit.state.stations;

    final distanceMap = <int, double>{};

    for (var s in allStations) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        s.latitude,
        s.longitude,
      );
      distanceMap[s.id] = distance;
    }

    final sorted = List<Station>.from(allStations);
    sorted.sort((a, b) => distanceMap[a.id]!.compareTo(distanceMap[b.id]!));

    if (mounted) {
      setState(() {
        _sortedStations = sorted.take(15).toList(); // Show more stations
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Loading and Error states should also have the background to be consistent
    Widget bodyContent;

    if (_loading) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const Gap(16),
            Text(
              "loading_location".tr(),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    } else if (_currentPosition == null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_disabled_rounded,
                  size: 64,
                  color: theme.primaryColor,
                ),
              ).animate().scale(curve: Curves.easeOutBack),
              const Gap(24),
              Text(
                "enable_location".tr(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkPermissionAndLocate,
                  child: Text("retry".tr()),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: _sortedStations.length,
        itemBuilder: (context, index) {
          final station = _sortedStations[index];
          final dist = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            station.latitude,
            station.longitude,
          );

          return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.08,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.read<MetroCubit>().selectSource(station);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "selected_start".tr(args: [station.getName(context)]),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _getLineColor(
                              station.lineId,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.train_rounded,
                            color: _getLineColor(station.lineId),
                            size: 28,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.getName(context),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const Gap(4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: theme.primaryColor,
                                  ),
                                  const Gap(4),
                                  Text(
                                    "km_away".tr(
                                      args: [(dist / 1000).toStringAsFixed(1)],
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(
                              isDark ? 0.2 : 0.1,
                            ),
                            shape: BoxShape.circle,
                            border: isDark
                                ? Border.all(
                                    color: theme.primaryColor.withOpacity(0.3),
                                  )
                                : null,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: isDark
                                ? theme.colorScheme.primary
                                : theme.primaryColor,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(delay: (index * 50).ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
        },
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true, // Allow background to go behind app bar
      appBar: AppBar(
        title: Text(
          "near_tab".tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Transparent for gradient
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: "show_on_map".tr(),
            onPressed: () => context.push('/map'),
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _checkPermissionAndLocate();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Layer 1: Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          // Layer 2: Content
          SafeArea(child: bodyContent),
        ],
      ),
    );
  }

  Color _getLineColor(int lineId) {
    switch (lineId) {
      case 1:
        return const Color(0xFF1565C0);
      case 2:
        return const Color(0xFFD32F2F);
      case 3:
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }
}
