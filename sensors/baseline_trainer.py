import requests
import random
import time
from datetime import datetime, timezone, timedelta

# Toggle: LOCAL for dev, RENDER for prod
LOCAL_BACKEND = "http://localhost:8000"
RENDER_BACKEND = "https://sepsis-detection-backend.onrender.com"
BASE_URL = RENDER_BACKEND  # Use full base for prod, LOCAL_BACKEND for dev
PATIENT_ID = 3

print("🏥 Baseline Trainer for Patient", PATIENT_ID)
print("✅ Fully automatic training start/stop")
print("Target:", BASE_URL, "\n")

_window_index = 0
_start_ts = datetime.now(timezone.utc)

def generate_normal_baseline(window_num):
    """Normal human vitals - stable for high-confidence baseline"""
    hr = random.randint(72, 78)
    temp = round(random.uniform(36.7, 36.9), 1)
    rr = random.randint(14, 16)
    spo2 = random.randint(98, 99)
    hrv = random.randint(55, 60)
    rrv = random.randint(18, 22)
    movement = round(random.uniform(8.0, 12.0), 2)
    
    timestamp = (_start_ts + timedelta(seconds=40 * _window_index)).isoformat()
    
    return {
        "patient_id": PATIENT_ID,
        "hr": hr,
        "temp": temp,
        "rr": rr,
        "spo2": spo2,
        "hrv": hrv,
        "rrv": rrv,
        "movement": movement,
        "timestamp": timestamp,
        "packet_seq": _window_index
    }

def main():
    # Step 1: Start training (POST /train-start body={"patient_id": 3})
    print("1️⃣ Starting training mode...")
    response = requests.post(f"{BASE_URL}/train-start", json={"patient_id": PATIENT_ID})
    print("Start response:", response.status_code, response.json())
    
    if response.status_code != 200:
        print("❌ Failed to start training")
        return
    
    time.sleep(1)
    
    # Step 2: Send 5 stable normal windows
    print("\n2️⃣ Sending 5 NORMAL baseline windows...")
    global _window_index
    _window_index = 0
    
    collected = 0
    for i in range(10):  # Send extra to ensure 5 collected
        vitals = generate_normal_baseline(i)
        response = requests.post(f"{BASE_URL}/sensor-data", json=vitals, timeout=15)
        
        try:
            data = response.json()
            if data.get('status') == 'TRAINING':
                collected += 1
                print(f"   Window {collected}/5: Collected OK ({data['windows_collected']})")
            else:
                print(f"   Window: {data}")
        except:
            print(f"   Window {i+1}: HTTP {response.status_code}")
        
        _window_index += 1
        time.sleep(3)
    
    print(f"Total training windows sent: {collected}")
    
    # Step 3: Stop training & build model
    print("\n3️⃣ Finalizing baseline + personal model...")
    response = requests.post(f"{BASE_URL}/train-stop", json={"patient_id": PATIENT_ID})
    
    try:
        result = response.json()
        print("✅ RESULT:", result)
        if 'TRAINING_COMPLETED' in str(result):
            print("🎉 SUCCESS - Personal baseline established!")
        else:
            print("⚠️  Check result above")
    except:
        print("Response:", response.status_code, response.text)
    
    print("\n🚀 Ready for testing:")
    print("python advanced_simulator.py")
    print("High risk scores will now be much higher vs personal baseline!")

if __name__ == "__main__":
    main()

