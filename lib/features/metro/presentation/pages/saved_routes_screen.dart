import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/entities/station.dart';
import '../bloc/metro_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/user_cubit.dart';

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  List<SavedRoute> _savedRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);

    try {
      final routesMap = await context.read<UserCubit>().getSavedRoutes();

      final routesList = routesMap.map((map) {
        return SavedRoute(
          id: map['id'].toString(),
          sourceStationId: map['source_station_id'] as int? ?? 0,
          destinationStationId: map['destination_station_id'] as int? ?? 0,
          sourceStationName: map['from_station'] ?? "Unknown",
          destinationStationName: map['to_station'] ?? "Unknown",
          savedAt: DateTime.tryParse(map['saved_at'] ?? "") ?? DateTime.now(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _savedRoutes = routesList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading routes: $e");
      if (mounted) {
        setState(() {
          _savedRoutes = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeRoute(String routeId) async {
    try {
      await context.read<UserCubit>().deleteRoute(routeId);
      await _loadRoutes();
    } catch (e) {
      print("Error removing route: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error_removing_route'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'saved'.tr(),
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedRoutes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _savedRoutes.length,
              itemBuilder: (context, index) {
                final route = _savedRoutes[index];
                return _buildRouteCard(context, route);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          const Gap(16),
          Text(
            'no_saved_routes'.tr(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const Gap(8),
          Text(
            'save_favorite_routes'.tr(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, SavedRoute route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Load this route
            final cubit = context.read<MetroCubit>();
            final allStations = cubit.state.stations;

            final source = allStations.firstWhere(
              (s) => s.id == route.sourceStationId,
            );
            final dest = allStations.firstWhere(
              (s) => s.id == route.destinationStationId,
            );

            cubit.selectSource(source);
            cubit.selectDestination(dest);
            await cubit.findRoute();

            if (context.mounted) {
              context.pop();
              context.push('/details');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final metroState = context.watch<MetroCubit>().state;
                          final stations = metroState.stations;

                          String sourceName = route.sourceStationName;
                          String destName = route.destinationStationName;

                          if (stations.isNotEmpty) {
                            try {
                              final source = stations.firstWhere(
                                (s) => s.id == route.sourceStationId,
                              );
                              sourceName = source.getName(context);
                              final dest = stations.firstWhere(
                                (s) => s.id == route.destinationStationId,
                              );
                              destName = dest.getName(context);
                            } catch (_) {
                              // If not found, fallback to the names in the route object
                            }
                          }

                          return Text(
                            '$sourceName → $destName',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                      ),
                      const Gap(4),
                      Text(
                        _formatDate(route.savedAt),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  onPressed: () => _removeRoute(route.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today'.tr();
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr();
    } else if (difference.inDays < 7) {
      return 'days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
