import requests
import random
import time
from datetime import datetime, timezone, timedelta

API_URL = "https://sepsis-detection-backend.onrender.com/sensor-data"
PATIENT_ID = 3

PHASES = ["Normal", "Mild", "Risky"]

WINDOW_SECONDS = 40
_window_index = 0
_phase_packets = 0
_current_phase = 0

_start_ts = datetime.now(timezone.utc)

def generate_vitals(phase):
    """Generate realistic vitals for each phase"""

    if phase == 0:  # NORMAL
        return {
            "hr": random.randint(70, 85),
            "temp": round(random.uniform(36.5, 37.2), 1),
            "rr": random.randint(12, 18),
            "spo2": random.randint(97, 100),
            "hrv": random.randint(45, 65),
            "rrv": random.randint(15, 25),
            "movement": round(random.uniform(5.0, 15.0), 2),
        }

    elif phase == 1:  # MILD
        return {
            "hr": random.randint(95, 110),
            "temp": round(random.uniform(37.5, 38.3), 1),
            "rr": random.randint(18, 26),
            "spo2": random.randint(92, 96),
            "hrv": random.randint(25, 40),
            "rrv": random.randint(8, 15),
            "movement": round(random.uniform(2.0, 8.0), 2),
        }

    else:  # RISKY
        return {
            "hr": random.randint(130, 160),
            "temp": round(random.uniform(39.0, 40.5), 1),
            "rr": random.randint(30, 40),
            "spo2": random.randint(85, 91),
            "hrv": random.randint(5, 15),
            "rrv": random.randint(2, 6),
            "movement": round(random.uniform(0.0, 3.0), 2),
        }


def build_payload(phase):
    vitals = generate_vitals(phase)

    return {
        "patient_id": PATIENT_ID,
        **vitals,
        "timestamp": (_start_ts + timedelta(seconds=WINDOW_SECONDS * _window_index)).isoformat(),
        "packet_seq": _window_index,
        "ground_truth_phase": PHASES[phase]  # 👈 important for validation
    }


print("\n🚨 ADVANCED SEPSIS SIMULATOR")
print("Phases: Normal → Mild → Risky")
print("Packets per phase: 5\n")

try:
    while _current_phase < 3:

        payload = build_payload(_current_phase)

        try:
            response = requests.post(API_URL, json=payload, timeout=10)

            if response.status_code == 200:
                data = response.json()

                ml_data = data.get("ml", {})
                predicted_phase = ml_data.get("sepsis_phase", "UNKNOWN")
                score = ml_data.get("final_score", 0)
                status = ml_data.get("status", "UNKNOWN")

                # 🔥 VALIDATION LOG
                print(f"\n📦 Packet {_window_index}")
                print(f"   ▶ Ground Truth : {PHASES[_current_phase]}")
                print(f"   ▶ Predicted    : {predicted_phase}")
                print(f"   ▶ Status       : {status}")
                print(f"   ▶ Score        : {score:.2f}")

                # ✅ Check correctness
                if predicted_phase.lower() == PHASES[_current_phase].lower():
                    print("   ✅ MATCH")
                else:
                    print("   ❌ MISMATCH")

            else:
                print(f"[ERROR {response.status_code}] {response.text[:80]}")

        except Exception as e:
            print(f"[SEND FAILED] {e}")

        _window_index += 1
        _phase_packets += 1

        # 🔁 Phase switch after 5 packets
        if _phase_packets == 5:
            print(f"\n✅ Phase '{PHASES[_current_phase]}' COMPLETE\n")
            _phase_packets = 0
            _current_phase += 1
            time.sleep(2)

        time.sleep(3)

    print("\n🏁 ALL PHASES COMPLETED")
    print("👉 Check app UI + backend logs for validation")

except KeyboardInterrupt:
    print("\n⏹️ Simulation stopped")