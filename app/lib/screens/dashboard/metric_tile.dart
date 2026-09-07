import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<double> history;

  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    double minY = 0;
    double maxY = 0;

    if (history.isNotEmpty) {
      minY = history.reduce((a, b) => a < b ? a : b);
      maxY = history.reduce((a, b) => a > b ? a : b);
      double padding = (maxY - minY) * 0.15;
      minY -= padding;
      maxY += padding;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),

          const SizedBox(height: 12),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                minX: 0,
                maxX: history.isNotEmpty ? (history.length - 1).toDouble() : 0,
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
                    barWidth: 2,
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
}
