import 'package:flutter/material.dart';
import '../services/app_state.dart';

class HealthScoreCard extends StatelessWidget {
  final AppState appState;

  const HealthScoreCard({super.key, required this.appState});

  double calculateScore() {
    final v = appState.vitals;

    double score = 100;

    if (v.heartRate > 100) score -= 15;
    if (v.temperature > 38) score -= 20;
    if (v.respiratoryRate > 22) score -= 15;
    if (v.spo2 < 94) score -= 20;

    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final score = calculateScore();

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Patient Health Score",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 14,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                    ),
                  ),

                  Text(
                    score.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
