import requests
import time
from datetime import datetime, timezone, timedelta

API_URL = "https://sepsis-detection-backend.onrender.com/sensor-data"
PATIENT_ID = 3

WINDOW_SECONDS = 40
_window_index = 0
_start_ts = datetime.now(timezone.utc)


def send(data):
    global _window_index
    try:
        # Logical window timestamp for backend derivative/trajectory timing
        data["timestamp"] = (
            _start_ts + timedelta(seconds=WINDOW_SECONDS * _window_index)
        ).isoformat()
        r = requests.post(API_URL, json=data)
        print("Sent:", data)
        print("Response:", r.json(), "\n")
    except Exception as e:
        print("Error:", e)
    finally:
        _window_index += 1


# -----------------------------
# PHASE 1: NORMAL (BASELINE)
# -----------------------------
print("=== PHASE 1: BASELINE (NORMAL) ===")

for _ in range(6):  # 5 needed + 1 extra
    data = {
        "patient_id": PATIENT_ID,
        "hr": 75,
        "rr": 16,
        "spo2": 98,
        "temp": 36.8,
        "hrv": 60,
        "rrv": 3,
        "movement": 0.8
    }
    send(data)
    time.sleep(2)


# -----------------------------
# PHASE 2: MILD STRESS
# -----------------------------
print("=== PHASE 2: MILD STRESS ===")

for _ in range(5):
    data = {
        "patient_id": PATIENT_ID,
        "hr": 95,
        "rr": 20,
        "spo2": 94,
        "temp": 37.8,
        "hrv": 40,
        "rrv": 2,
        "movement": 0.5
    }
    send(data)
    time.sleep(2)


# -----------------------------
# PHASE 3: CRITICAL CONDITION
# -----------------------------
print("=== PHASE 3: CRITICAL ===")

for _ in range(5):
    data = {
        "patient_id": PATIENT_ID,
        "hr": 140,
        "rr": 30,
        "spo2": 85,
        "temp": 39.5,
        "hrv": 10,
        "rrv": 1,
        "movement": 0.1
    }
    send(data)
    time.sleep(2)


# -----------------------------
# PHASE 4: RECOVERY
# -----------------------------
print("=== PHASE 4: RECOVERY ===")

for _ in range(5):
    data = {
        "patient_id": PATIENT_ID,
        "hr": 85,
        "rr": 18,
        "spo2": 96,
        "temp": 37.0,
        "hrv": 50,
        "rrv": 3,
        "movement": 0.6
    }
    send(data)
    time.sleep(2)