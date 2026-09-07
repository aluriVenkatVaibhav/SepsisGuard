import 'package:flutter/material.dart';

class AnalyticsSummary extends StatelessWidget {
  final List<double> hr;
  final List<double> resp;
  final List<double> temp;
  final List<double> spo2;

  const AnalyticsSummary({
    super.key,
    required this.hr,
    required this.resp,
    required this.temp,
    required this.spo2,
  });

  double current(List<double> data) => data.isEmpty ? 0 : data.last;

  bool _isCriticalHeartRate(double v) => v > 120 || v < 50;
  bool _isWarningHeartRate(double v) => v > 100 || v < 60;

  bool _isCriticalResp(double v) => v > 30 || v < 8;
  bool _isWarningResp(double v) => v > 22 || v < 12;

  bool _isCriticalTemp(double v) => v >= 39.0 || v < 35.0;
  bool _isWarningTemp(double v) => v >= 37.5 || v < 36.0;

  bool _isCriticalSpo2(double v) => v < 90;
  bool _isWarningSpo2(double v) => v < 94;

  @override
  Widget build(BuildContext context) {
    int stable = 0;
    int warning = 0;
    int critical = 0;

    final hrValue = current(hr);
    final respValue = current(resp);
    final tempValue = current(temp);
    final spo2Value = current(spo2);

    for (final result in [
      _status(_isCriticalHeartRate(hrValue), _isWarningHeartRate(hrValue)),
      _status(_isCriticalResp(respValue), _isWarningResp(respValue)),
      _status(_isCriticalTemp(tempValue), _isWarningTemp(tempValue)),
      _status(_isCriticalSpo2(spo2Value), _isWarningSpo2(spo2Value)),
    ]) {
      if (result == "critical") {
        critical++;
      } else if (result == "warning") {
        warning++;
      } else {
        stable++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _chip("Stable", stable, Colors.green),
          _chip("Warning", warning, Colors.orange),
          _chip("Critical", critical, Colors.red),
        ],
      ),
    );
  }

  Widget _chip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _status(bool critical, bool warning) {
    if (critical) return "critical";
    if (warning) return "warning";
    return "stable";
  }
}
