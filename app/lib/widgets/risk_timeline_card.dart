import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RiskTimelineCard extends StatelessWidget {
  final List<double> history;
  final List<DateTime> timestamps;
  final String selectedRange;

  const RiskTimelineCard({
    super.key,
    required this.history,
    required this.timestamps,
    required this.selectedRange,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox();
    final count = history.length < timestamps.length
        ? history.length
        : timestamps.length;
    if (count == 0) return const SizedBox();

    final spots = List<FlSpot>.generate(
      count,
      (i) => FlSpot(i.toDouble(), history[i]),
    );

    final labelStep = count <= 6 ? 1 : (count / 5).ceil();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Risk Prediction Timeline",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Bucket: ${_bucketLabel(selectedRange)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 1,
                minX: 0,
                maxX: (count - 1).toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: labelStep.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.round();
                        if (idx < 0 || idx >= count) {
                          return const SizedBox.shrink();
                        }

                        final dt = timestamps[idx];
                        final text = _formatForRange(dt, selectedRange);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            text,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatForRange(DateTime dt, String range) {
    switch (range) {
      case "day":
        return DateFormat("HH:mm").format(dt);
      case "week":
        return DateFormat("EEE HH:mm").format(dt);
      case "month":
        return DateFormat("dd MMM").format(dt);
      default:
        return DateFormat("HH:mm").format(dt);
    }
  }

  String _bucketLabel(String range) {
    switch (range) {
      case "day":
        return "5m";
      case "week":
        return "30m";
      case "month":
        return "1h";
      default:
        return "N/A";
    }
  }
}
