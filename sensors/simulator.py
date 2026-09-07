import requests
import random
import time
from datetime import datetime, timezone, timedelta

API_URL = "https://sepsis-detection-backend.onrender.com/sensor-data"
PATIENT_ID = 3

WINDOW_SECONDS = 40
_window_index = 0
_start_ts = datetime.now(timezone.utc)


def generate_vitals():
    hr = random.randint(70, 120)
    rr = random.randint(14, 28)
    temp = round(random.uniform(36.5, 39.0), 1)
    spo2 = random.randint(90, 100)

    hrv = random.randint(40, 80)
    rrv = random.randint(1, 5)

    movement = round(random.uniform(0.0, 1.0), 2)

    return {
        "patient_id": PATIENT_ID,
        "hr": hr,
        "rr": rr,
        "spo2": spo2,
        "temp": temp,
        "hrv": hrv,
        "rrv": rrv,
        "movement": movement,
        # Logical window timestamp for backend derivative/trajectory timing
        "timestamp": (_start_ts + timedelta(seconds=WINDOW_SECONDS * _window_index)).isoformat(),
    }


while True:
    vitals = generate_vitals()

    try:
        r = requests.post(API_URL, json=vitals)

        print("Sent:", vitals)
        print("Response:", r.status_code)

    except Exception as e:
        print("Error:", e)

    _window_index += 1
    time.sleep(40)