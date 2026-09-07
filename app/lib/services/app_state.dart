import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_vitals.dart';
import '../models/prediction_result.dart';
import 'api_service.dart';

class Patient {
  final int backendId;
  final String id;
  final String name;

  Patient({required this.backendId, required this.id, required this.name});
}

class AppState extends ChangeNotifier {
  /// ---------------- PATIENTS ----------------

  List<Patient> patients = [
    Patient(backendId: 1, id: "SG-1021", name: "John Doe"),
    Patient(backendId: 2, id: "SG-2045", name: "Emily Smith"),
    Patient(backendId: 3, id: "SG-3099", name: "Michael Brown"),
  ];

  bool isTraining = false;
  int trainingWindows = 0;

  late Patient selectedPatient;

  /// ---------------- THEME ----------------

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// ---------------- VITALS ----------------

  PatientVitals vitals = PatientVitals(
    heartRate: 75,
    respiratoryRate: 18,
    temperature: 36.8,
    spo2: 98,
    movement: 0.0,
    hrv: 50,
    rrv: 3,
  );

  bool get criticalAlert {
    return prediction.riskScore > 0.75;
  }

  /// ---------------- ML PREDICTION ----------------

  PredictionResult prediction = PredictionResult(
    riskScore: 0.25,
    stage: "Stable",
    sepsisPhase: "PHASE_0",
    confidence: 0.85,
  );

  void updatePrediction({
    required double finalScore,
    required String status,
    required String phase,
    double? confidence,
  }) {
    prediction = PredictionResult(
      riskScore: finalScore,
      stage: status,
      sepsisPhase: phase,
      confidence: ((confidence ?? prediction.confidence).clamp(0.0, 1.0) as num)
          .toDouble(),
    );

    riskHistory.add(finalScore);
    if (riskHistory.length > 300) {
      riskHistory.removeAt(0);
    }

    notifyListeners();
  }

  /// ---------------- HISTORY STORAGE ----------------

  List<double> heartRateHistory = [];
  List<double> respiratoryHistory = [];
  List<double> temperatureHistory = [];
  List<double> spo2History = [];
  List<double> hrvHistory = [];
  List<double> rrvHistory = [];

  List<double> timelineHeartRate = [];
  List<double> timelineTemp = [];
  List<double> timelineSpo2 = [];
  List<double> timelineResp = [];
  List<double> timelineHRV = [];
  List<double> timelineRRV = [];

  List<DateTime> timelineTimestamps = [];
  List<double> timelineModelRisk = [];
  List<DateTime> timelineModelRiskTimestamps = [];

  /// NEW → Risk history for analytics timeline

  List<double> riskHistory = [];

  /// ---------------- CONSTRUCTOR ----------------

  AppState() {
    selectedPatient = patients.first;

    _loadPreferences();

    _generateInitialData();

    //_startLiveSimulation();
  }

  /// ---------------- PERSISTENCE ----------------

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString("theme");

    if (savedTheme == "dark") {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == "light") {
      _themeMode = ThemeMode.light;
    }

    final savedPatientId = prefs.getString("patient");

    if (savedPatientId != null) {
      selectedPatient = patients.firstWhere((p) => p.id == savedPatientId);
    }

    notifyListeners();
  }

  Future<void> fetchLatestVitals() async {
    final data = await ApiService.getLatestVitals(selectedPatient.backendId);

    if (data == null) return;

    vitals = PatientVitals(
      heartRate: (data["hr"] as num?)?.toDouble() ?? 0,
      respiratoryRate: (data["rr"] as num?)?.toDouble() ?? 0,
      temperature: (data["temp"] as num?)?.toDouble() ?? 0,
      spo2: (data["spo2"] as num?)?.toDouble() ?? 0,
      movement: (data["movement"] as num?)?.toDouble() ?? 0.0,
      hrv: (data["hrv"] as num?)?.toDouble() ?? 0,
      rrv: (data["rrv"] as num?)?.toDouble() ?? 0,
    );

    heartRateHistory.add(vitals.heartRate);
    respiratoryHistory.add(vitals.respiratoryRate);
    temperatureHistory.add(vitals.temperature);
    spo2History.add(vitals.spo2);
    hrvHistory.add(vitals.hrv);
    rrvHistory.add(vitals.rrv);

    if (heartRateHistory.length > 30) heartRateHistory.removeAt(0);
    if (respiratoryHistory.length > 30) respiratoryHistory.removeAt(0);
    if (temperatureHistory.length > 30) temperatureHistory.removeAt(0);
    if (spo2History.length > 30) spo2History.removeAt(0);
    if (hrvHistory.length > 30) hrvHistory.removeAt(0);
    if (rrvHistory.length > 30) rrvHistory.removeAt(0);

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("theme", isDarkMode ? "dark" : "light");

    await prefs.setString("patient", selectedPatient.id);
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;

    _savePreferences();

    notifyListeners();
  }

  void setTrainingState(bool value) {
    isTraining = value;
    if (!value) {
      trainingWindows = 0;
    }
    notifyListeners();
  }

  void setTrainingProgress(int windows) {
    isTraining = true;
    trainingWindows = windows;
    notifyListeners();
  }

  void switchPatient(Patient patient) async {
    selectedPatient = patient;

    await _savePreferences();

    /// 🔥 CLEAR DATA
    heartRateHistory.clear();
    respiratoryHistory.clear();
    temperatureHistory.clear();
    spo2History.clear();
    hrvHistory.clear();
    rrvHistory.clear();

    timelineHeartRate.clear();
    timelineSpo2.clear();
    timelineTemp.clear();
    timelineResp.clear();
    timelineHRV.clear();
    timelineRRV.clear();
    timelineTimestamps.clear(); // ✅ ADD THIS
    timelineModelRisk.clear();
    timelineModelRiskTimestamps.clear();

    riskHistory.clear();
    isTraining = false;
    trainingWindows = 0;
    prediction = PredictionResult(
      riskScore: 0.0,
      stage: "Loading...",
      sepsisPhase: "PHASE_0",
      confidence: 0.0,
    );

    /// 🔥 FETCH NEW DATA
    await fetchLatestVitals();
    await fetchTimeline("day");

    notifyListeners();

    /// 🔥 DEBUG LOG
    print("Switched to patient: ${selectedPatient.backendId}");
  }

  /// ---------------- INITIAL DATA GENERATION ----------------

  void _generateInitialData() {
    final random = Random();

    for (int i = 0; i < 20; i++) {
      heartRateHistory.add(70 + random.nextInt(20).toDouble());

      respiratoryHistory.add(16 + random.nextInt(6).toDouble());

      temperatureHistory.add(36 + random.nextDouble());

      spo2History.add(95 + random.nextInt(4).toDouble());

      hrvHistory.add(50 + random.nextInt(20).toDouble());

      rrvHistory.add(2 + random.nextInt(3).toDouble());
    }
  }

  /// ---------------- LIVE SIMULATION ----------------

  // void _startLiveSimulation() {
  //   Timer.periodic(const Duration(seconds: 2), (_) {
  //     final random = Random();

  //     updateVitals(
  //       PatientVitals(
  //         heartRate: 70 + random.nextInt(40).toDouble(),
  //         respiratoryRate: 16 + random.nextInt(10).toDouble(),
  //         temperature: 36 + random.nextDouble() * 2,
  //         spo2: 94 + random.nextInt(5).toDouble(),
  //       ),
  //     );
  //   });
  // }

  /// ---------------- UPDATE VITALS ----------------

  void updateVitals(PatientVitals newVitals) {
    vitals = newVitals;

    heartRateHistory.add(newVitals.heartRate);
    respiratoryHistory.add(newVitals.respiratoryRate);
    temperatureHistory.add(newVitals.temperature);
    spo2History.add(newVitals.spo2);
    hrvHistory.add(newVitals.hrv);
    rrvHistory.add(newVitals.rrv);

    /// Limit history size

    if (heartRateHistory.length > 300) {
      heartRateHistory.removeAt(0);
      respiratoryHistory.removeAt(0);
      temperatureHistory.removeAt(0);
      spo2History.removeAt(0);
      hrvHistory.removeAt(0);
      rrvHistory.removeAt(0);
    }

    notifyListeners();
  }

  Future<void> fetchTimeline(String range) async {
    final api = ApiService();
    final rows = await api.fetchTimeline(range, selectedPatient.backendId);
    final riskRows = await api.fetchPredictionTimeline(
      range,
      selectedPatient.backendId,
    );

    timelineHeartRate.clear();
    timelineSpo2.clear();
    timelineTemp.clear();
    timelineResp.clear();
    timelineHRV.clear(); // ✅ ADD THIS
    timelineRRV.clear(); // ✅ ADD THIS
    timelineTimestamps.clear(); // ✅ ADD THIS
    timelineModelRisk.clear();
    timelineModelRiskTimestamps.clear();

    for (var row in rows) {
      timelineTimestamps.add(DateTime.parse(row[0].toString())); // ✅ ADD

      timelineHeartRate.add((row[1] as num?)?.toDouble() ?? 0);
      timelineSpo2.add((row[2] as num?)?.toDouble() ?? 0);
      timelineTemp.add((row[3] as num?)?.toDouble() ?? 0);
      timelineResp.add((row[4] as num?)?.toDouble() ?? 0);
      timelineHRV.add((row[5] as num?)?.toDouble() ?? 0);
      timelineRRV.add((row[6] as num?)?.toDouble() ?? 0);
    }

    for (var row in riskRows) {
      timelineModelRiskTimestamps.add(DateTime.parse(row[0].toString()));
      timelineModelRisk.add(
        (((row[1] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0) as num).toDouble(),
      );
    }

    print("Timeline rows: $rows");
    print("HR timeline: $timelineHeartRate");

    notifyListeners();
  }
}
