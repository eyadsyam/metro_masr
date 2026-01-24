import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/station.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StationSearchSheet extends StatefulWidget {
  final List<Station> stations;
  final ValueChanged<Station> onSelected;

  const StationSearchSheet({
    super.key,
    required this.stations,
    required this.onSelected,
  });

  @override
  State<StationSearchSheet> createState() => _StationSearchSheetState();
}

class _StationSearchSheetState extends State<StationSearchSheet> {
  late List<Station> _filteredStations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStations = widget.stations;
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStations = widget.stations;
      } else {
        _filteredStations = widget.stations
            .where(
              (s) =>
                  s.nameEn.toLowerCase().contains(query.toLowerCase()) ||
                  s.nameAr.contains(query),
            )
            .toList();
      }
    });
  }

  Color _getLineColor(int id) {
    if (id == 1) return const Color(0xFF1565C0);
    if (id == 2) return const Color(0xFFD32F2F);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Gap(12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),

          // Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    autofocus: true,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "search_station".tr(),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredStations.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
                final station = _filteredStations[index];
                final landmark = station.getLandmark(context);

                return Card(
                      elevation: 0,
                      color: colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => widget.onSelected(station),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getLineColor(
                              station.lineId,
                            ).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.train_rounded,
                            color: _getLineColor(station.lineId),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          station.getName(context),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${'line'.tr()} ${station.lineId}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (landmark != null)
                              Text(
                                landmark,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (index * 10).ms)
                    .slideX(begin: 0.05, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
