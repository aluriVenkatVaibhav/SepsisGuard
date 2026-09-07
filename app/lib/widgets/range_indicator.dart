import 'package:flutter/material.dart';

class RangeIndicator extends StatelessWidget {
  final double min;
  final double max;
  final double current;
  final String unit;
  final Color color;

  const RangeIndicator({
    super.key,
    required this.min,
    required this.max,
    required this.current,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (current - min) / ((max - min) == 0 ? 1 : (max - min));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${min.toStringAsFixed(1)} $unit"),

            Text(
              "${current.toStringAsFixed(1)} $unit",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            Text("${max.toStringAsFixed(1)} $unit"),
          ],
        ),

        const SizedBox(height: 6),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),

                Positioned(
                  left: ratio.clamp(0, 1) * width - 10,
                  child: Icon(Icons.arrow_drop_down, color: color),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
