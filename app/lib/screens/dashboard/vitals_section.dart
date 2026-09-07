import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import 'metric_tile.dart';

class VitalsSection extends StatelessWidget {
  const VitalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Heart Rate",
                value: "${appState.vitals.heartRate.toStringAsFixed(0)} bpm",
                icon: Icons.favorite,
                color: const Color(0xFFE53935),
                history: appState.heartRateHistory,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: MetricTile(
                title: "Respiratory",
                value:
                    "${appState.vitals.respiratoryRate.toStringAsFixed(0)} rpm",
                icon: Icons.air,
                color: const Color(0xFF26A69A),
                history: appState.respiratoryHistory,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Temperature",
                value: "${appState.vitals.temperature.toStringAsFixed(1)} °C",
                icon: Icons.thermostat,
                color: const Color(0xFFFFA726),
                history: appState.temperatureHistory,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: MetricTile(
                title: "SpO2",
                value: "${appState.vitals.spo2.toStringAsFixed(0)} %",
                icon: Icons.water_drop,
                color: const Color(0xFF42A5F5),
                history: appState.spo2History,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "HRV",
                value: "${appState.vitals.hrv.toStringAsFixed(0)} ms",
                icon: Icons.favorite_border,
                color: Colors.purple,
                history: appState.hrvHistory,
              ),
            ),
            Expanded(
              child: MetricTile(
                title: "RRV",
                value: "${appState.vitals.rrv.toStringAsFixed(0)}",
                icon: Icons.monitor_heart,
                color: Colors.indigo,
                history: appState.rrvHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
