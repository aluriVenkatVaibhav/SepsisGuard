import 'package:flutter/material.dart';
import '../services/app_state.dart';

class ClinicalInsightPanel extends StatelessWidget {
  final AppState appState;

  const ClinicalInsightPanel({super.key, required this.appState});

  List<String> generateInsights() {
    final v = appState.vitals;
    List<String> insights = [];

    if (v.temperature > 38) {
      insights.add("Elevated body temperature contributing to risk");
    }

    if (v.heartRate > 100) {
      insights.add("High heart rate detected (tachycardia)");
    }

    if (v.respiratoryRate > 22) {
      insights.add("Respiratory distress indicators present");
    }

    if (v.spo2 < 94) {
      insights.add("Reduced oxygen saturation observed");
    }

    if (insights.isEmpty) {
      insights.add("All vitals within normal physiological limits");
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = generateInsights();

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
            "Clinical Insights",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...insights.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6),
                  const SizedBox(width: 8),
                  Expanded(child: Text(text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
