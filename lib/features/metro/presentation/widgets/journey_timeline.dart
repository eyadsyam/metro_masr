import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/entities/station.dart';

class JourneyTimeline extends StatelessWidget {
  final RouteResult routeResult;

  const JourneyTimeline({super.key, required this.routeResult});

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

  @override
  Widget build(BuildContext context) {
    final path = routeResult.path;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: path.length,
      itemBuilder: (context, index) {
        final station = path[index];
        final isStart = index == 0;
        final isEnd = index == path.length - 1;

        bool isTransferStep = false;
        Color lineColor = Colors.grey;

        if (!isEnd) {
          final nextStation = path[index + 1];
          if (station.id == nextStation.id &&
              station.lineId != nextStation.lineId) {
            // Transfer Step
            lineColor = Colors.orange;
            isTransferStep = true;
          } else {
            lineColor = _getLineColor(station.lineId);
          }
        }

        // Previous line color (for top line)
        Color prevLineColor = Colors.grey;
        if (!isStart) {
          final prevStation = path[index - 1];
          if (prevStation.id == station.id &&
              prevStation.lineId != station.lineId) {
            prevLineColor = Colors.orange;
          } else {
            prevLineColor = _getLineColor(prevStation.lineId);
          }
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: isStart,
          isLast: isEnd,
          beforeLineStyle: LineStyle(color: prevLineColor, thickness: 4),
          afterLineStyle: LineStyle(color: lineColor, thickness: 4),
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isStart
                ? _getLineColor(station.lineId)
                : (isEnd
                      ? _getLineColor(station.lineId)
                      : (isTransferStep
                            ? Colors.orange
                            : _getLineColor(station.lineId))),
            padding: const EdgeInsets.all(6),
            indicator: Container(
              decoration: BoxDecoration(
                color: isTransferStep
                    ? Colors.white
                    : (isStart || isEnd
                          ? _getLineColor(station.lineId)
                          : Colors.white),
                border: Border.all(
                  color: isTransferStep
                      ? Colors.orange
                      : _getLineColor(station.lineId),
                  width: 3,
                ),
                shape: BoxShape.circle,
              ),
              child: isTransferStep
                  ? const Icon(Icons.swap_calls, size: 12, color: Colors.orange)
                  : (isStart || isEnd
                        ? const Icon(Icons.circle, size: 8, color: Colors.white)
                        : null),
            ),
          ),
          endChild: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  station.getName(context),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: (isStart || isEnd || isTransferStep)
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (isStart)
                  Text(
                    "${'depart'.tr()} - ${'line'.tr()} ${station.lineId}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _getLineColor(station.lineId),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (isEnd)
                  Text(
                    'arrive'.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _getLineColor(station.lineId),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (isTransferStep)
                  Text(
                    'switch_line'.tr(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().shimmer(),
              ],
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
        );
      },
    );
  }
}
