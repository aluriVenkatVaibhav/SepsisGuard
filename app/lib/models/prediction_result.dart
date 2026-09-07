class PredictionResult {
  double riskScore; // 0 to 1
  String stage; // e.g., "Stable", "Sepsis", "Severe"
  String sepsisPhase; // e.g., "PHASE_0" -> "PHASE_3"
  double confidence; // 0 to 1

  PredictionResult({
    required this.riskScore,
    required this.stage,
    required this.sepsisPhase,
    required this.confidence,
  });
}
