# Fix advanced_simulator.py - Establish Patient 3 Baseline First

## Current Status
- ✅ Diagnosis complete: Missing baseline training for patient 3 on Render backend.
- Backend blocks ML predictions without baseline → "UNKNOWN" responses.

## Steps to Complete

### 1. [✅] Backend Fixed - Run Baseline Trainer (5-10s)
```bash
cd sensors
python baseline_trainer.py
```
Expected: "TRAINING_COMPLETED", "Personal baseline established!"

**Note**: Fixed 422 error in `backend/routes/train.py` (now accepts JSON body).

### 2. [ ] Verify Training Success
- Check output for 🎉 SUCCESS
- Baseline saved to Render's `patient_data/3/baseline.json`

### 3. [ ] Test Advanced Simulator (After Trainer)
```bash
python advanced_simulator.py
```
Expected: `[High Risk #3] MONITORING | HIGH_RISK | Score: 0.65`

**Redeploy backend to Render** if testing remote (git push / manual deploy).

### 4. [ ] [Optional] Local Backend Test (if Render slow)
```bash
cd backend
pip install -r requirements.txt
uvicorn api.server:app --host 0.0.0.0 --port 8000 --reload
```
Update simulators to `BACKEND_URL = "http://localhost:8000"`

## Progress Tracking
- Update checkboxes as completed.

Once Step 3 ✅: Task complete! Delete this file or mark as done.

