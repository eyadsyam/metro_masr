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
        return const Color(0xFF1565C0); // Line 1 Blue
      case 2:
        return const Color(0xFFD32F2F); // Line 2 Red
      case 3:
        return const Color(0xFF2E7D32); // Line 3 Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (routeResult.path.isEmpty) return const SizedBox();

    // Preprocess path to specific visual steps
    final visualSteps = _buildVisualSteps(routeResult.path);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visualSteps.length,
      itemBuilder: (context, index) {
        final step = visualSteps[index];
        final isStart = index == 0;
        final isEnd = index == visualSteps.length - 1;

        // Determine line colors
        // Before line: logic depends on previous step's 'toLine'
        Color beforeColor = Colors.grey;
        if (!isStart) {
          final prev = visualSteps[index - 1];
          // If previous was transfer, the connecting line is the line we transferred INTO.
          // If we merge transfer into one node, the "outgoing" line of TransferNode is the 'toLine'.
          beforeColor = _getLineColor(prev.exitLineId);
        }

        // After line: logic depends on current step's 'toLine' (unless end)
        Color afterColor = Colors.grey;
        if (!isEnd) {
          afterColor = _getLineColor(step.exitLineId);
        }

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: isStart,
          isLast: isEnd,
          beforeLineStyle: LineStyle(color: beforeColor, thickness: 4),
          afterLineStyle: LineStyle(color: afterColor, thickness: 4),
          indicatorStyle: IndicatorStyle(
            width: 24,
            height: 24,
            color: step.isTransfer
                ? Colors.orange
                : _getLineColor(step.enterLineId),
            padding: const EdgeInsets.all(4),
            indicator: _buildIndicator(step, isStart, isEnd),
          ),
          endChild: _buildStepContent(context, step, isStart, isEnd),
        );
      },
    );
  }

  Widget _buildIndicator(VisualStep step, bool isStart, bool isEnd) {
    final color = _getLineColor(step.enterLineId);

    if (step.isTransfer) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange, width: 3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.swap_calls, size: 14, color: Colors.orange),
      );
    }

    // Normal Station
    return Container(
      decoration: BoxDecoration(
        color: (isStart || isEnd) ? color : Colors.white,
        border: Border.all(color: color, width: 3),
        shape: BoxShape.circle,
      ),
      child: (isStart || isEnd)
          ? const Icon(Icons.circle, size: 8, color: Colors.white)
          : null,
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    VisualStep step,
    bool isStart,
    bool isEnd,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            step.station.getName(context),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: (isStart || isEnd || step.isTransfer)
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (isStart)
            Text(
              "${'depart'.tr()} - ${'line'.tr()} ${step.enterLineId}",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: _getLineColor(step.enterLineId),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (step.isTransfer)
            Text(
              "${'switch_line'.tr()} ${step.enterLineId} ➔ ${step.exitLineId}",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ).animate().shimmer(duration: 2000.ms),
          if (isEnd)
            Text(
              'arrive'.tr(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: _getLineColor(
                  step.enterLineId,
                ), // Use enter line as it is the arrival line
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  List<VisualStep> _buildVisualSteps(List<Station> path) {
    final steps = <VisualStep>[];
    for (int i = 0; i < path.length; i++) {
      final current = path[i];

      // Check if next is a transfer match
      if (i < path.length - 1) {
        final next = path[i + 1];
        if (current.nameEn == next.nameEn && current.lineId != next.lineId) {
          // It is a transfer!
          // Add a single step representing the transfer
          steps.add(
            VisualStep(
              station: current,
              isTransfer: true,
              enterLineId: current.lineId,
              exitLineId: next.lineId,
            ),
          );
          i++; // Skip the next station (the duplicate/partner)
          continue;
        }
      }

      // Normal step
      steps.add(
        VisualStep(
          station: current,
          isTransfer: false,
          enterLineId: current.lineId,
          exitLineId: current.lineId, // Exit same as enter for normal steps
        ),
      );
    }
    return steps;
  }
}

class VisualStep {
  final Station station;
  final bool isTransfer;
  final int enterLineId;
  final int exitLineId;

  VisualStep({
    required this.station,
    required this.isTransfer,
    required this.enterLineId,
    required this.exitLineId,
  });
}
