import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'range_indicator.dart';

class AnalyticsVitalCard extends StatelessWidget {
  final String title;
  final String unit;
  final Color color;
  final List<double> history;
  final String? bucketLabel;

  const AnalyticsVitalCard({
    super.key,
    required this.title,
    required this.unit,
    required this.color,
    required this.history,
    this.bucketLabel,
  });

  double minVal(List<double> data) => data.reduce((a, b) => a < b ? a : b);

  double maxVal(List<double> data) => data.reduce((a, b) => a > b ? a : b);

  String detectTrend(List<double> data) {
    if (data.length < 6) return "Stable";

    final mid = data.length ~/ 2;

    final firstAvg = data.sublist(0, mid).reduce((a, b) => a + b) / mid;

    final secondAvg =
        data.sublist(mid).reduce((a, b) => a + b) / (data.length - mid);

    if (secondAvg > firstAvg * 1.02) return "Rising";
    if (secondAvg < firstAvg * 0.98) return "Falling";

    return "Stable";
  }

  String detectAnomaly(double value) {
    if (title == "Heart Rate" && value > 110) return "High HR Spike";
    if (title == "Temperature" && value > 38) return "Fever Detected";
    if (title == "SpO2" && value < 92) return "Low Oxygen";
    if (title == "Respiratory Rate" && value > 24) {
      return "Respiration Elevated";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox();

    final min = minVal(history);
    final max = maxVal(history);
    final current = history.last;

    final trend = detectTrend(history);
    final anomaly = detectAnomaly(current);

    double padding = (max - min).abs() * 0.2 + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (bucketLabel != null) ...[
                    Text(
                      "Bucket: $bucketLabel",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  _trendIndicator(trend),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Range Indicator
          RangeIndicator(
            min: min,
            max: max,
            current: current,
            unit: unit,
            color: color,
          ),

          const SizedBox(height: 16),

          /// Graph
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                minY: min - padding,
                maxY: max + padding,
                minX: 0,
                maxX: history.length.toDouble() - 1,
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: history
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Anomaly Warning
          if (anomaly.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              anomaly,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trendIndicator(String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case "Rising":
        icon = Icons.trending_up;
        color = Colors.orange;
        break;

      case "Falling":
        icon = Icons.trending_down;
        color = Colors.green;
        break;

      default:
        icon = Icons.trending_flat;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          trend,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
