import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gap/gap.dart';
import '../bloc/metro_cubit.dart';
import '../bloc/metro_state.dart';
import '../widgets/floating_input_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/saved_route.dart';
import '../widgets/station_search_sheet.dart';
import '../widgets/lively_background.dart';
import '../../../../core/state/user_cubit.dart';
import '../../../../core/state/user_state.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Helper to open station picker
  void _openStationPicker(
    BuildContext context,
    List<Station> stations,
    bool isSource,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationSearchSheet(
        stations: stations,
        onSelected: (station) {
          if (isSource) {
            context.read<MetroCubit>().selectSource(station);
          } else {
            context.read<MetroCubit>().selectDestination(station);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getDynamicGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greetingKey;
    if (hour < 12) {
      greetingKey = 'welcome_morning_user';
    } else if (hour < 18) {
      greetingKey = 'welcome_afternoon_user';
    } else {
      greetingKey = 'welcome_evening_user';
    }

    final userState = context.read<UserCubit>().state;
    String userName = "Traveler"; // Fallback
    if (userState is UserAuthenticated) {
      // Split by space and take first name
      userName = userState.name.split(' ').first;
    }

    return greetingKey.tr(args: [userName]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<MetroCubit, MetroState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MetroStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          } else if (state.status == MetroStatus.routeCalculated) {
            context.push('/details');
          }
        },
        builder: (context, state) {
          if (state.status == MetroStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Layer 1: Lively Wallpaper
              const Positioned.fill(child: LivelyBackground()),

              // Layer 2: Main Content Area
              Positioned.fill(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(10),

                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Greeting / Title
                            Expanded(
                              child:
                                  Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'where_to'.tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const Gap(4),
                                          Text(
                                            _getDynamicGreeting(context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white
                                                            .withOpacity(0.7)
                                                      : Colors.black
                                                            .withOpacity(0.6),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                        ],
                                      )
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideX(begin: -0.2, end: 0),
                            ),

                            // Saved Routes Icon
                            _buildTopIconBtn(
                              Icons.bookmark_rounded,
                              () => context.push('/saved'),
                              Theme.of(context).colorScheme.secondary,
                            ).animate().scale(delay: 350.ms),
                          ],
                        ),

                        const Gap(32),

                        // Main Input Card with Pulse Animation
                        FloatingInputCard(
                              stations: state.stations,
                              source: state.sourceStation,
                              destination: state.destinationStation,
                              onSourceChanged: (s) =>
                                  context.read<MetroCubit>().selectSource(s),
                              onDestinationChanged: (s) => context
                                  .read<MetroCubit>()
                                  .selectDestination(s),
                              onSwap: () =>
                                  context.read<MetroCubit>().swapStations(),
                              onSourceTap: () => _openStationPicker(
                                context,
                                state.stations,
                                true,
                              ),
                              onDestinationTap: () => _openStationPicker(
                                context,
                                state.stations,
                                false,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            )
                            .then()
                            .shimmer(
                              delay: 1000.ms,
                              duration: 2000.ms,
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),

                        const Gap(24),

                        // Calculate Button & Find Place
                        Row(
                          children: [
                            Expanded(
                              child:
                                  SizedBox(
                                        height: 60,
                                        child: ElevatedButton(
                                          onPressed:
                                              (state.sourceStation != null &&
                                                  state.destinationStation !=
                                                      null)
                                              ? () => context
                                                    .read<MetroCubit>()
                                                    .findRoute()
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            shadowColor: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.4),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.directions_subway_rounded,
                                              ),
                                              const Gap(12),
                                              Text(
                                                "calc_btn".tr(),
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 600.ms)
                                      .slideX(begin: -0.2, end: 0)
                                      .then(delay: 500.ms)
                                      .shimmer(
                                        duration: 1500.ms,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                            ),
                            const Gap(16),
                            // "Find Place" integrated here
                            GestureDetector(
                                  onTap: () {
                                    context.push('/place-search', extra: false);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor
                                              .withOpacity(isDark ? 0.4 : 0.7),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              isDark ? 0.1 : 0.5,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.explore_rounded,
                                          color: isDark
                                              ? Colors.white
                                              : Theme.of(context).primaryColor,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 700.ms)
                                .scale(begin: const Offset(0.8, 0.8)),
                          ],
                        ).animate().fadeIn(delay: 600.ms),

                        // Quick Actions REMOVED as per request
                        // Mid-screen is now cleaner.
                        const Gap(220),
                      ],
                    ),
                  ),
                ),
              ),

              // Layer 3: Bottom Sheet (Recent Routes Only)
              DraggableScrollableSheet(
                initialChildSize: 0.35, // Increased initial size slightly
                minChildSize: 0.25,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Gap(24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'recent_routes'.tr(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                            if (state.recentRoutes.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // Show confirmation dialog before clearing
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("clear_history".tr()),
                                      content: Text(
                                        "confirm_clear_history".tr(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("cancel".tr()),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<MetroCubit>()
                                                .clearRecentRoutes();
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "clear".tr(),
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  "clear".tr(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(16),
                        if (state.recentRoutes.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  const Gap(12),
                                  Text(
                                    "no_routes_yet".tr(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.recentRoutes.length,
                            separatorBuilder: (_, __) => const Gap(12),
                            itemBuilder: (context, index) {
                              return _buildRecentRouteTile(
                                context,
                                state.recentRoutes[index],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper to get localized station name
  String _getStationName(
    BuildContext context,
    int stationId,
    List<Station> stations,
  ) {
    try {
      final station = stations.firstWhere((s) => s.id == stationId);
      return station.getName(context);
    } catch (_) {
      return "Station";
    }
  }

  Widget _buildTopIconBtn(IconData icon, VoidCallback onTap, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).cardColor.withOpacity(isDark ? 0.3 : 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRouteTile(BuildContext context, SavedRoute route) {
    final theme = Theme.of(context);
    final isAr = context.locale.languageCode == 'ar';
    final metro = context.read<MetroCubit>();
    final stations = metro.state.stations;

    final sourceName = _getStationName(
      context,
      route.sourceStationId,
      stations,
    );
    final destName = _getStationName(
      context,
      route.destinationStationId,
      stations,
    );
    final routeTitle = "$sourceName → $destName";

    return GestureDetector(
      onTap: () {
        try {
          final start = stations.firstWhere(
            (s) => s.id == route.sourceStationId,
          );
          final end = stations.firstWhere(
            (s) => s.id == route.destinationStationId,
          );

          metro.selectSource(start);
          metro.selectDestination(end);
          metro.findRoute();
          // Listener will navigate - DO NOT PUSH HERE
        } catch (e) {
          print("Error selecting recent route: $e");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : theme.primaryColor,
                size: 20,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeTitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd(
                      context.locale.languageCode,
                    ).format(route.savedAt),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAr
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
