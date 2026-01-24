import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'package:gap/gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/metro_cubit.dart';
import '../bloc/metro_state.dart';
import '../widgets/journey_timeline.dart';
import '../../domain/entities/saved_route.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/route_result.dart';
import '../../../../core/state/user_cubit.dart';

class RouteDetailsScreen extends StatefulWidget {
  const RouteDetailsScreen({super.key});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStatus();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Auto-dismiss after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkmark Animation
                SizedBox(
                  height: 120,
                  width: 120,
                  child:
                      Icon(
                            Icons.check_circle_outline_rounded,
                            size: 100,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 400.ms),
                ),
                const Gap(16),
                Text(
                  'route_saved'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadSavedStatus() async {
    await _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final state = context.read<MetroCubit>().state;
    if (state.sourceStation != null && state.destinationStation != null) {
      final saved = await context.read<UserCubit>().isRouteSaved(
        state.sourceStation!.id,
        state.destinationStation!.id,
      );
      if (mounted) {
        setState(() => _isSaved = saved);
      }
    }
  }

  Future<void> _toggleSave() async {
    final state = context.read<MetroCubit>().state;
    if (state.sourceStation == null || state.destinationStation == null) return;
    final result = state.routeResult;

    final routeId =
        '${state.sourceStation!.id}_${state.destinationStation!.id}';

    try {
      if (_isSaved) {
        // Remove the route
        try {
          // Use UserCubit to delete (handles both guest and authenticated)
          await context.read<UserCubit>().deleteRoute(routeId);

          setState(() => _isSaved = false);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('route_removed'.tr())));
          }
        } catch (removeError) {
          print("Error removing route: $removeError");
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('error_generic'.tr())));
          }
        }
      } else {
        // Save
        if (result != null) {
          final pathNames = result.path.map((s) => s.getName(context)).toList();

          try {
            // Use UserCubit's saveRoute which handles both guest and authenticated users
            await context.read<UserCubit>().saveRoute(
              routeId: routeId,
              sourceId: state.sourceStation!.id,
              destId: state.destinationStation!.id,
              fromStation: state.sourceStation!.getName(context),
              toStation: state.destinationStation!.getName(context),
              path: pathNames,
              totalStations: result.totalStations,
              price: result.totalPrice,
              estimatedTime: result.estimatedTimeMinutes,
            );

            setState(() => _isSaved = true);
            if (mounted) {
              _showSuccessDialog(context);
            }
          } on SocketException catch (e) {
            // Network error
            print("Network error saving route: $e");
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('error_network'.tr())));
            }
          } on PostgrestException catch (e) {
            // Supabase/Database error
            print("Database error saving route: ${e.message}");
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('error_save_route'.tr())));
            }
          } on FormatException catch (e) {
            // Data format error
            print("Format error saving route: $e");
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('error_save_route'.tr())));
            }
          } catch (saveError) {
            // Generic error
            print("Unexpected error saving route: $saveError");
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('error_generic'.tr())));
            }
          }
        }
      }
    } catch (e) {
      print("Error toggling save: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error_generic'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = context.locale.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'route_result'.tr(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved
                ? Colors.amber
                : (isDark ? Colors.white : Colors.black87),
          ),
          onPressed: _toggleSave,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocBuilder<MetroCubit, MetroState>(
        builder: (context, state) {
          if (state.routeResult == null ||
              state.sourceStation == null ||
              state.destinationStation == null) {
            return Center(
              child: Text(
                'select_both_stations'.tr(),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 18,
                ),
              ),
            );
          }
          final result = state.routeResult!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source & Destination Header (Compact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.cardColor.withOpacity(0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _stationCircle(Colors.blue),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          "${state.sourceStation!.getName(context)} → ${state.destinationStation!.getName(context)}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _stationCircle(Colors.red),
                    ],
                  ),
                ),

                const Gap(24),

                // 1. Premium Summary Card (As per image concept)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                          : [const Color(0xFF1E40AF), const Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E40AF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Left side: Total Fare
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'total_fare'.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  "${result.totalPrice.toInt()} ${'price_egp'.tr()}",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Vertical Divider
                          Container(
                            height: 60,
                            width: 1,
                            color: Colors.white24,
                          ),
                          const Gap(24),
                          // Right side: Duration
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'duration'.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  "${result.estimatedTimeMinutes} ${'time_min'.tr()}",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),
                      const Divider(color: Colors.white24, thickness: 1),
                      const Gap(20),
                      // Bottom row: Stations & Switches
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryIconItem(
                            Icons.train_rounded,
                            "${result.totalStations} ${'stations'.tr()}",
                          ),
                          _summaryIconItem(
                            Icons.swap_calls_rounded,
                            "${result.transferInstructions.isEmpty ? 0 : result.transferInstructions.length} ${'switches'.tr()}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(32),

                // 2. Journey Narrative
                Text(
                  "journey_details".tr(),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87,
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    _generateNarrative(
                      context,
                      result,
                      state.sourceStation!,
                      state.destinationStation!,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      height: 1.6,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),

                const Gap(32),

                // 3. Timeline View
                Text(
                  "timeline_view".tr(),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Gap(16),
                JourneyTimeline(routeResult: result),
                const Gap(60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stationCircle(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
      ),
    );
  }

  Widget _summaryIconItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _generateNarrative(
    BuildContext context,
    RouteResult result,
    Station start,
    Station end,
  ) {
    final isAr = context.locale.languageCode == 'ar';

    if (isAr) {
      String narrative = "هتركب الخط ${_getLineNameAr(start.lineId)}";

      if (result.transferInstructions.isEmpty) {
        narrative += ". المشوار مباشر وسهل.";
      } else {
        // Find transfer stations from path
        for (int i = 0; i < result.path.length - 1; i++) {
          final curr = result.path[i];
          final next = result.path[i + 1];
          // Check if same station name but different line
          if (curr.nameAr == next.nameAr && curr.lineId != next.lineId) {
            narrative +=
                " وهتحول في ${curr.nameAr} للخط ${_getLineNameAr(next.lineId)}";
          }
        }
        narrative += ".";
      }
      return narrative;
    } else {
      String narrative = "Ride Line ${_getLineNameEn(start.lineId)}";
      if (result.transferInstructions.isEmpty) {
        narrative += ". The journey is direct.";
      } else {
        for (int i = 0; i < result.path.length - 1; i++) {
          final curr = result.path[i];
          final next = result.path[i + 1];
          if (curr.nameEn == next.nameEn && curr.lineId != next.lineId) {
            narrative +=
                " and switch at ${curr.nameEn} to Line ${_getLineNameEn(next.lineId)}";
          }
        }
        narrative += ".";
      }
      return narrative;
    }
  }

  String _getLineNameAr(int id) {
    if (id == 1) return "الأول";
    if (id == 2) return "الثاني";
    return "الثالث";
  }

  String _getLineNameEn(int id) {
    if (id == 1) return "1";
    if (id == 2) return "2";
    return "3";
  }
}
