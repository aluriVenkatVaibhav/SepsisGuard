import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key});

  double avg(List<double> list) =>
      list.isNotEmpty ? list.reduce((a, b) => a + b) / list.length : 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final avgHR = avg(appState.heartRateHistory);
    final avgTemp = avg(appState.temperatureHistory);
    final avgSpO2 = avg(appState.spo2History);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryItem("HR Avg", "${avgHR.toStringAsFixed(0)} bpm"),

        _summaryItem("Temp Avg", "${avgTemp.toStringAsFixed(1)}°C"),

        _summaryItem("SpO2 Avg", "${avgSpO2.toStringAsFixed(0)}%"),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
