import 'package:flutter/material.dart';
import '../services/app_state.dart';

class SepsisRiskPanel extends StatelessWidget {
  final AppState appState;

  const SepsisRiskPanel({super.key, required this.appState});

  String riskLevel(double score) {
    if (score > 0.7) return "HIGH";
    if (score > 0.4) return "MEDIUM";
    return "LOW";
  }

  Color riskColor(double score) {
    if (score > 0.7) return Colors.red;
    if (score > 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final risk = appState.prediction.riskScore;
    final status = appState.prediction.stage;
    final sepsisPhase = appState.prediction.sepsisPhase;
    final level = riskLevel(risk);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sepsis Early Warning",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Risk Level", style: TextStyle(color: Colors.grey[600])),
              Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: riskColor(risk),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Status", style: TextStyle(color: Colors.grey[600])),
              Text(status),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sepsis Phase", style: TextStyle(color: Colors.grey[600])),
              Text(sepsisPhase),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Prediction Window"),
              const Text("30–60 minutes"),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text("Risk Score"), Text(risk.toStringAsFixed(2))],
          ),
        ],
      ),
    );
  }
}
