import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

import '../widgets/health_score_card.dart';
import '../widgets/sepsis_risk_panel.dart';
import '../widgets/risk_timeline_card.dart';
import '../widgets/analytics_summary.dart';
import '../widgets/analytics_vital_card.dart';
import '../widgets/clinical_insight_panel.dart';
import '../widgets/export_report_button.dart';

enum TimeRange { day, week, month }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  TimeRange selectedRange = TimeRange.day;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchTimeline("day");
    });
  }

  void changeRange(TimeRange range) {
    setState(() {
      selectedRange = range;
    });

    final appState = Provider.of<AppState>(context, listen: false);

    switch (range) {
      case TimeRange.day:
        appState.fetchTimeline("day");
        break;
      case TimeRange.week:
        appState.fetchTimeline("week");
        break;
      case TimeRange.month:
        appState.fetchTimeline("month");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedRiskHistory = appState.timelineModelRisk.isNotEmpty
        ? appState.timelineModelRisk
        : appState.riskHistory;
    final selectedRiskTimestamps = appState.timelineModelRiskTimestamps.isNotEmpty
        ? appState.timelineModelRiskTimestamps
        : _fallbackRiskTimestamps(appState, selectedRiskHistory.length);
    final bucketLabel = _bucketLabel(selectedRange);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Analytics",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// Range selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _rangeButton("Day", TimeRange.day),
                  _rangeButton("Week", TimeRange.week),
                  _rangeButton("Month", TimeRange.month),
                ],
              ),

              const SizedBox(height: 30),

              /// Health Score
              HealthScoreCard(appState: appState),

              const SizedBox(height: 30),

              /// Sepsis Risk Panel
              SepsisRiskPanel(appState: appState),

              const SizedBox(height: 30),

              /// Risk Timeline
              RiskTimelineCard(
                history: selectedRiskHistory,
                timestamps: selectedRiskTimestamps,
                selectedRange: _rangeApiValue(selectedRange),
              ),

              const SizedBox(height: 30),

              /// Analytics Summary
              AnalyticsSummary(
                hr: appState.timelineHeartRate,
                resp: appState.timelineResp,
                temp: appState.timelineTemp,
                spo2: appState.timelineSpo2,
              ),

              const SizedBox(height: 30),

              /// Clinical insights
              ClinicalInsightPanel(appState: appState),

              const SizedBox(height: 30),

              /// Heart Rate
              AnalyticsVitalCard(
                title: "Heart Rate",
                unit: "bpm",
                color: Colors.red,
                history: appState.timelineHeartRate,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 20),

              /// Temperature
              AnalyticsVitalCard(
                title: "Temperature",
                unit: "°C",
                color: Colors.orange,
                history: appState.timelineTemp,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 20),

              /// SpO2
              AnalyticsVitalCard(
                title: "SpO2",
                unit: "%",
                color: Colors.blue,
                history: appState.timelineSpo2,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 20),

              /// Respiratory Rate
              AnalyticsVitalCard(
                title: "Respiratory Rate",
                unit: "rpm",
                color: Colors.teal,
                history: appState.timelineResp,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 30),

              AnalyticsVitalCard(
                title: "HRV",
                unit: "ms",
                color: Colors.purple,
                history: appState.timelineHRV,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 20),

              AnalyticsVitalCard(
                title: "RRV",
                unit: "",
                color: Colors.indigo,
                history: appState.timelineRRV,
                bucketLabel: bucketLabel,
              ),

              const SizedBox(height: 40),

              /// Export report
              ExportReportButton(appState: appState),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rangeButton(String label, TimeRange range) {
    bool active = selectedRange == range;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active
            ? Theme.of(context).primaryColor
            : Colors.grey.shade300,
        foregroundColor: active ? Colors.white : Colors.black,
      ),
      onPressed: () => changeRange(range),
      child: Text(label),
    );
  }

  String _rangeApiValue(TimeRange range) {
    switch (range) {
      case TimeRange.day:
        return "day";
      case TimeRange.week:
        return "week";
      case TimeRange.month:
        return "month";
    }
  }

  String _bucketLabel(TimeRange range) {
    switch (range) {
      case TimeRange.day:
        return "5m";
      case TimeRange.week:
        return "30m";
      case TimeRange.month:
        return "1h";
    }
  }

  List<DateTime> _fallbackRiskTimestamps(AppState appState, int count) {
    if (appState.timelineTimestamps.length == count && count > 0) {
      return appState.timelineTimestamps;
    }

    if (count == 0) return [];
    final now = DateTime.now();
    return List<DateTime>.generate(
      count,
      (i) => now.subtract(Duration(minutes: count - i)),
    );
  }
}
