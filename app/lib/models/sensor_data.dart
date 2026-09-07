class SensorData {
  String? timestamp;
  double? hr;
  double? temp;
  double? rr;
  double? spo2;
  double? hrv;
  double? rrv;
  double? movement;

  SensorData({
    this.timestamp,
    this.hr,
    this.temp,
    this.rr,
    this.spo2,
    this.hrv,
    this.rrv,
    this.movement,
  });

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp,
      "hr": hr,
      "temp": temp,
      "rr": rr,
      "spo2": spo2,
      "hrv": hrv,
      "rrv": rrv,
      "movement": movement,
    };
  }
}
