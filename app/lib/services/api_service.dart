import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sepsis-detection-backend.onrender.com";

  static Future<Map<String, dynamic>?> getLatestVitals(int patientId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/latest-vitals/$patientId"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("API ERROR: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> startTraining(int patientId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/train-start?patient_id=$patientId"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> stopTraining(int patientId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/train-stop?patient_id=$patientId"),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> fetchTimeline(String range, int patientId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/timeline/$range/$patientId"),
    );

    final json = jsonDecode(response.body);
    return json["data"];
  }

  Future<List<dynamic>> fetchPredictionTimeline(String range, int patientId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/prediction-timeline/$range/$patientId"),
    );

    final json = jsonDecode(response.body);
    return json["data"];
  }

  /// ✅ FINAL SENSOR DATA POST
  static Future<Map<String, dynamic>?> sendSensorData({
    required int patientId,
    required double heartRate,
    required double respRate,
    required double spo2,
    required double temperature,
    double? hrv,
    double? rrv,
    double? movement,
    DateTime? timestamp,
    int? packetSeq,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/sensor-data"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": patientId,
          "hr": heartRate,
          "rr": respRate,
          "spo2": spo2,
          "temp": temperature,
          "hrv": hrv,
          "rrv": rrv,
          "movement": movement ?? 0.0,
          "timestamp": (timestamp ?? DateTime.now()).toIso8601String(),
          "packet_seq": packetSeq,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        print("❌ Upload failed: ${response.body}");
        return null;
      } else {
        print("✅ Data uploaded successfully");
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print("❌ POST sensor error: $e");
      return null;
    }
    return null;
  }
}
