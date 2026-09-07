import requests
import random
import time
from datetime import datetime, timezone, timedelta

# ---------------- CONFIG ----------------
LOCAL_BACKEND = "http://localhost:8000/sensor-data"
RENDER_BACKEND = "https://sepsis-detection-backend.onrender.com/sensor-data"

BACKEND_URL = LOCAL_BACKEND   # 🔁 Change to RENDER_BACKEND for production
PATIENT_ID = 3

WINDOW_SECONDS = 40
TARGET_TIME = 400  # ⏱️ Total baseline duration (recommended)

# ---------------- INIT ----------------
print("📡 Advanced Baseline Trainer")
print(f"✅ Backend: {BACKEND_URL}")
print(f"👤 Patient ID: {PATIENT_ID}")
print("🎯 Goal: Build realistic personalized baseline")
print(f"⏱️ Target Time: {TARGET_TIME} seconds (~{TARGET_TIME//40} windows)")
print("👉 Start training in app NOW\n")

_window_index = 0
_start_ts = datetime.now(timezone.utc)
program_start_time = time.time()


# ---------------- HELPERS ----------------
def clamp(val, low, high):
    return max(low, min(val, high))


def generate_baseline_vitals():
    """Realistic NORMAL human baseline with natural variation"""

    global _window_index

    vitals = {
        "patient_id": PATIENT_ID,

        # Core vitals (Gaussian variation)
        "hr": clamp(int(random.gauss(78, 4)), 60, 100),
        "temp": clamp(round(random.gauss(36.8, 0.2), 1), 36.0, 37.5),
        "rr": clamp(int(random.gauss(15, 2)), 10, 20),
        "spo2": clamp(int(random.gauss(98, 1)), 95, 100),

        # Variability signals (important for your model)
        "hrv": clamp(int(random.gauss(55, 8)), 30, 80),
        "rrv": clamp(int(random.gauss(20, 3)), 10, 30),

        # Movement (low but not zero)
        "movement": round(random.uniform(5.0, 12.0), 2),

        # Timestamp for backend windowing
        "timestamp": (_start_ts + timedelta(seconds=WINDOW_SECONDS * _window_index)).isoformat(),

        "packet_seq": _window_index
    }

    _window_index += 1
    return vitals


# ---------------- MAIN LOOP ----------------
print("📤 Sending baseline data...\n")

try:
    while True:
        vitals = generate_baseline_vitals()

        try:
            r = requests.post(BACKEND_URL, json=vitals, timeout=10)

            if r.status_code == 200:
                data = r.json()
                status = data.get("status", "UNKNOWN")

                if status == "TRAINING":
                    windows = data.get("windows_collected", "?")
                    print(f"🎓 #{vitals['packet_seq']:03d} TRAINING [{windows}] | HR:{vitals['hr']} RR:{vitals['rr']} Temp:{vitals['temp']}")
                else:
                    print(f"📊 #{vitals['packet_seq']:03d} MONITORING")

            else:
                print(f"⚠️ HTTP {r.status_code}")

        except Exception as e:
            print(f"🌐 Error: {e}")

        # ---------------- TIMER ----------------
        elapsed = int(time.time() - program_start_time)
        minutes = elapsed // 60
        seconds = elapsed % 60

        print(f"⏱️ Time: {minutes:02d}:{seconds:02d}", end=" | ")

        # ---------------- PROGRESS ----------------
        progress = min(100, (elapsed / TARGET_TIME) * 100)
        print(f"📊 Progress: {progress:.1f}% ({elapsed}/{TARGET_TIME}s)")

        # ---------------- AUTO STOP ----------------
        if elapsed >= TARGET_TIME:
            print("\n✅ Baseline training complete!")
            print("👉 Now STOP training in app and run advanced simulator\n")
            break

        time.sleep(3)

except KeyboardInterrupt:
    print(f"\n⏹️ Stopped manually at {_window_index} packets")
    print("💡 Make sure baseline is sufficient before testing")