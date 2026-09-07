import 'dart:convert';
import 'dart:async';
import 'dart:collection';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:permission_handler/permission_handler.dart';

import 'api_service.dart';
import '../models/patient_vitals.dart';
import 'app_state.dart';

class BluetoothService {
  BluetoothService._internal();
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;

  ble.BluetoothDevice? device;
  ble.BluetoothCharacteristic? jsonCharacteristic;
  StreamSubscription<List<int>>? _notifySub;
  bool _isScanning = false;
  bool _isConnected = false;
  Future<void> _packetChain = Future.value();
  DateTime? _sensorBootEpochUtc;
  double? _lastSensorTsSeconds;
  final Set<String> _recentPacketKeys = <String>{};
  final Queue<String> _recentPacketQueue = Queue<String>();

  final String deviceName = "nRF52840_ArduinoBLE";

  /// 🔐 Permissions
  Future<void> requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  /// 🔍 Scan
  Future<void> startScan(AppState appState) async {
    if (_isScanning || _isConnected) return;
    _isScanning = true;
    await requestPermissions();

    await ble.FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    ble.FlutterBluePlus.scanResults.listen((results) async {
      for (var r in results) {
        if (r.device.platformName == deviceName) {
          device = r.device;

          await ble.FlutterBluePlus.stopScan();
          _isScanning = false;
          await connect(appState);
          break;
        }
      }
    });
  }

  /// 🔗 Connect
  Future<void> connect(AppState appState) async {
    if (device == null || _isConnected) return;

    try {
      await device!.connect();
      _isConnected = true;

      List<ble.BluetoothService> services = await device!.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          final uuid = characteristic.uuid.toString().toLowerCase();

          if (uuid == "19b10010-e8f2-537e-4f6c-d104768a1214") {
            jsonCharacteristic = characteristic;

            await characteristic.setNotifyValue(true);

            listenForData(appState);
            await _readLatestValueOnce(appState);
          }
        }
      }
    } catch (_) {
      _isConnected = false;
      _isScanning = false;
      // Silent fail (can log if needed)
    }
  }

  /// 📥 Listen for JSON data
  void listenForData(AppState appState) {
    if (_notifySub != null) return;
    _notifySub = jsonCharacteristic?.lastValueStream.listen((value) {
      final patientIdAtReceipt = appState.selectedPatient.backendId;
      _packetChain = _packetChain.then(
        (_) => _handleIncomingPacket(value, appState, patientIdAtReceipt),
      );
    });
  }

  Future<void> _readLatestValueOnce(AppState appState) async {
    try {
      final value = await jsonCharacteristic?.read();
      if (value != null && value.isNotEmpty) {
        final patientIdAtRead = appState.selectedPatient.backendId;
        await _handleIncomingPacket(value, appState, patientIdAtRead);
      }
    } catch (_) {
      // Optional one-time read can fail on some peripherals; ignore.
    }
  }

  Future<void> _handleIncomingPacket(
    List<int> value,
    AppState appState,
    int patientIdAtReceipt,
  ) async {
    try {
      String jsonString = utf8.decode(value);
      Map<String, dynamic> data = jsonDecode(jsonString);

      double heartRate = (data["hr"] as num).toDouble();
      double respRate = (data["rr"] as num).toDouble();
      double temperature = (data["temp"] as num).toDouble();
      double spo2 = (data["spo2"] as num).toDouble();
      final movementRaw = data["movement"] ?? data["uneasy"];
      double movement = (movementRaw as num?)?.toDouble() ?? 0.0;

      double hrv = (data["hrv"] as num?)?.toDouble() ?? 0;
      double rrv = (data["rrv"] as num?)?.toDouble() ?? 0;
      DateTime? packetTimestamp;
      final ts = data["timestamp"];
      if (ts is String) {
        packetTimestamp = DateTime.tryParse(ts)?.toUtc();
      }
      final sensorTsRaw = data["ts"];
      final sensorTsSeconds = (sensorTsRaw as num?)?.toDouble();
      int? packetSeq;
      if (sensorTsSeconds != null) {
        if (_sensorBootEpochUtc == null) {
          _sensorBootEpochUtc = DateTime.now().toUtc().subtract(
            Duration(milliseconds: (sensorTsSeconds * 1000).round()),
          );
        } else if (_lastSensorTsSeconds != null &&
            sensorTsSeconds < _lastSensorTsSeconds!) {
          // Sensor likely rebooted; reset anchor.
          _sensorBootEpochUtc = DateTime.now().toUtc().subtract(
            Duration(milliseconds: (sensorTsSeconds * 1000).round()),
          );
        }
        _lastSensorTsSeconds = sensorTsSeconds;
        packetSeq = (sensorTsSeconds * 1000).round();
        packetTimestamp = _sensorBootEpochUtc!.add(
          Duration(milliseconds: (sensorTsSeconds * 1000).round()),
        );
      }
      final packetKey = _buildPacketKey(
        patientIdAtReceipt: patientIdAtReceipt,
        packetSeq: packetSeq,
        packetTimestamp: packetTimestamp,
        heartRate: heartRate,
        respRate: respRate,
        spo2: spo2,
        temperature: temperature,
      );
      if (_isDuplicatePacket(packetKey)) {
        return;
      }

      final vitals = PatientVitals(
        heartRate: heartRate,
        respiratoryRate: respRate,
        temperature: temperature,
        spo2: spo2,
        movement: movement,
        hrv: hrv,
        rrv: rrv,
      );

      final stillSamePatient =
          appState.selectedPatient.backendId == patientIdAtReceipt;
      if (stillSamePatient) {
        appState.updateVitals(vitals);
      }

      final response = await ApiService.sendSensorData(
        patientId: patientIdAtReceipt,
        heartRate: heartRate,
        respRate: respRate,
        temperature: temperature,
        spo2: spo2,
        hrv: hrv,
        rrv: rrv,
        movement: movement,
        timestamp: packetTimestamp,
        packetSeq: packetSeq,
      );

      if (stillSamePatient && response != null && response["status"] == "TRAINING") {
        final windows = (response["windows_collected"] as num?)?.toInt() ?? 0;
        appState.setTrainingProgress(windows);
      }
    } catch (_) {
      // Ignore malformed packets silently
    }
  }

  String _buildPacketKey({
    required int patientIdAtReceipt,
    required int? packetSeq,
    required DateTime? packetTimestamp,
    required double heartRate,
    required double respRate,
    required double spo2,
    required double temperature,
  }) {
    return [
      patientIdAtReceipt,
      packetSeq ?? packetTimestamp?.toIso8601String() ?? "no_ts",
      heartRate.toStringAsFixed(3),
      respRate.toStringAsFixed(3),
      spo2.toStringAsFixed(3),
      temperature.toStringAsFixed(3),
    ].join("|");
  }

  bool _isDuplicatePacket(String packetKey) {
    if (_recentPacketKeys.contains(packetKey)) {
      return true;
    }
    _recentPacketKeys.add(packetKey);
    _recentPacketQueue.add(packetKey);
    if (_recentPacketQueue.length > 256) {
      final oldest = _recentPacketQueue.removeFirst();
      _recentPacketKeys.remove(oldest);
    }
    return false;
  }
}
