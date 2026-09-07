import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/patient_vitals.dart';
import 'app_state.dart';

class WebSocketService {
  WebSocketService._internal();
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketChannel? channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isConnecting = false;

  void connect(AppState appState) {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;
    channel = WebSocketChannel.connect(
      Uri.parse('wss://sepsis-detection-backend.onrender.com/ws'),
    );

    _subscription = channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data["patient_id"] != appState.selectedPatient.backendId) {
        return; // ✅ ADD
      }

      double heartRate = (data["hr"] as num).toDouble();
      double respRate = (data["rr"] as num).toDouble();
      double temperature = (data["temp"] as num).toDouble();
      double spo2 = (data["spo2"] as num).toDouble();
      double movement = (data["movement"] as num?)?.toDouble() ?? 0.0;

      double hrv = (data["hrv"] as num?)?.toDouble() ?? 0;
      double rrv = (data["rrv"] as num?)?.toDouble() ?? 0;

      final vitals = PatientVitals(
        heartRate: heartRate,
        respiratoryRate: respRate,
        temperature: temperature,
        spo2: spo2,
        movement: movement,
        hrv: hrv,
        rrv: rrv,
      );

      final ml = data["ml"];

      appState.updateVitals(vitals);

      if (ml != null && ml["phase"] == "MONITORING") {
        // Backend contract: `final_score` (not `score`)
        final rawScore = ml["final_score"] ?? ml["score"];
        if (rawScore == null) return;
        final baselineConfidenceRaw = ml["baseline_confidence"];
        double? confidence;
        if (baselineConfidenceRaw is num) {
          confidence = (baselineConfidenceRaw.toDouble() / 100.0).clamp(0.0, 1.0);
        }

        appState.updatePrediction(
          finalScore: (rawScore as num).toDouble(),
          status: ml["status"]?.toString() ?? "",
          phase: ml["sepsis_phase"]?.toString() ?? "",
          confidence: confidence,
        );
      }
    }, onDone: () {
      _isConnected = false;
      _isConnecting = false;
    }, onError: (_) {
      _isConnected = false;
      _isConnecting = false;
    });
    _isConnected = true;
    _isConnecting = false;
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    channel?.sink.close();
    channel = null;
    _isConnected = false;
    _isConnecting = false;
  }
}
