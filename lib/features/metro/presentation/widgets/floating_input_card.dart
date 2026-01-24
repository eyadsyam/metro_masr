import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/station.dart';
import 'station_search_sheet.dart';

class FloatingInputCard extends StatelessWidget {
  final List<Station> stations;
  final Station? source;
  final Station? destination;
  final ValueChanged<Station> onSourceChanged;
  final ValueChanged<Station> onDestinationChanged;
  final VoidCallback onSwap;
  final VoidCallback? onSourceTap;
  final VoidCallback? onDestinationTap;

  const FloatingInputCard({
    super.key,
    required this.stations,
    required this.source,
    required this.destination,
    required this.onSourceChanged,
    required this.onDestinationChanged,
    required this.onSwap,
    this.onSourceTap,
    this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Column(
                children: [
                  _buildInput(
                    context,
                    'source_station'.tr(),
                    Icons.circle_outlined,
                    source,
                    (s) => onSourceChanged(s),
                    isArabic,
                    onSourceTap,
                    true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      height: 1,
                    ),
                  ),
                  _buildInput(
                    context,
                    'destination_station'.tr(),
                    Icons.location_on_rounded,
                    destination,
                    (s) => onDestinationChanged(s),
                    isArabic,
                    onDestinationTap,
                    false,
                  ),
                ],
              ),
              Positioned(
                right: isArabic ? null : 0,
                left: isArabic ? 0 : null,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onSwap,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    String hint,
    IconData icon,
    Station? value,
    ValueChanged<Station> onSelected,
    bool isArabic,
    VoidCallback? customTap,
    bool isTop,
  ) {
    return InkWell(
      onTap:
          customTap ??
          () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => StationSearchSheet(
                stations: stations,
                onSelected: (s) {
                  onSelected(s);
                  Navigator.pop(context);
                },
              ),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (value != null
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor)
                            .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: value != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? value.getName(context)
                        : 'select_station'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: value != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
