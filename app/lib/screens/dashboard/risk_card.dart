import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../widgets/animated_ring.dart';

class RiskCard extends StatelessWidget {
  final Animation<double> glowAnimation;
  final int seconds;

  const RiskCard({
    super.key,
    required this.glowAnimation,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final risk = appState.prediction.riskScore;
    final confidence = appState.prediction.confidence;
    final status = appState.prediction.stage;
    final sepsisPhase = appState.prediction.sepsisPhase;

    final riskPercent = (risk * 100).toStringAsFixed(0);

    Color riskColor = risk > 0.7
        ? const Color(0xFFE53935)
        : risk > 0.4
        ? const Color(0xFFFFA726)
        : const Color(0xFF43A047);

    bool isHighRisk = risk > 0.7;

    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: riskColor.withOpacity(0.1),
            boxShadow: isHighRisk
                ? [
                    BoxShadow(
                      color: riskColor.withOpacity(glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedRiskRing(progress: risk, color: riskColor, size: 150),
                Text(
                  "$riskPercent%",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text("Model Confidence"),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: riskColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Status: $status",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: riskColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Sepsis Phase: $sepsisPhase",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(
            "Updated $seconds sec ago",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
