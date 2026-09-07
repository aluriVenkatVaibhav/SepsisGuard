# SepsisGuard - Current Project Status

SepsisGuard is a real-time sepsis risk monitoring system with BLE sensor ingestion, backend ML inference, and Flutter dashboard/analytics visualization.

## Current Status (April 2026)

The core pipeline is stable and working end-to-end:

`BLE Sensor -> Flutter App -> Backend API/WS -> ML Model -> Response -> Dashboard/Analytics UI`

### Working Now

- Real-time vitals ingestion and posting to backend on packet arrival
- Backend ML prediction flow with `final_score`, `status`, and `sepsis_phase`
- WebSocket updates from backend to Flutter for live monitoring
- Dashboard risk card updates with current model output
- Analytics timeline loading by range (`day`, `week`, `month`)
- Patient switching with timeline/vitals refresh
- Training controls from dashboard (`start`/`stop`) with backend integration

## Major Improvements Implemented

### 1) Live Data Reliability

- Removed app-side dependence on fixed 40s sampling alignment
- Ingestion is now event-driven: data is processed when packet is received
- BLE service made persistent/singleton to prevent duplicate listeners
- Added one-time BLE characteristic read after connect for fast initial refresh
- Dashboard now revalidates connections on app resume

### 2) Stream/Connection Stability

- WebSocket service made singleton with connection guards
- Prevented duplicate WS subscriptions
- Added safe WS cleanup handling
- Avoided unnecessary stream teardown during dashboard lifecycle changes

### 3) Model Output Consistency

- Removed local heuristic risk overwrite from vitals update path
- App prediction state now tracks backend ML output as source-of-truth
- Dashboard and analytics sepsis panel both read from unified prediction state

### 4) Analytics Correctness

- Fixed range reset behavior that forced `day` unexpectedly
- Added proper range-aware chart labels:
  - `day` -> `HH:mm`
  - `week` -> `EEE HH:mm`
  - `month` -> `dd MMM`
- Added visible bucket labels across analytics cards:
  - Day: `5m`
  - Week: `30m`
  - Month: `1h`
- Fixed respiratory anomaly detection key mismatch
- Improved summary warning/critical logic with vital-specific thresholds

### 5) True Prediction Timeline (Model Risk History)

- Added backend prediction timeline APIs:
  - `/prediction-timeline/day/{patient_id}`
  - `/prediction-timeline/week/{patient_id}`
  - `/prediction-timeline/month/{patient_id}`
- Added DB-level prediction aggregation by range/time bucket
- Flutter analytics risk chart now uses stored model risk history
  (`predictions.current_risk_score`) instead of reconstructed risk

### 6) Confidence Integration

- Backend now exposes baseline confidence context in ML response
- Flutter maps baseline confidence (`0..100`) to UI confidence (`0..1`)
- Dashboard confidence indicator now reflects model/baseline signal better

### 7) Training UX + Control Reliability

- Start/Stop training buttons now validate backend response status
- Added loading-safe button behavior to prevent duplicate clicks
- Added user feedback via snackbars for start/stop success and failure
- Training windows progress now updates live from backend response
  (`status=TRAINING`, `windows_collected`)

### 8) BLE-to-Model Delay and Timestamp Robustness

- Added HTTP timeout for sensor-data uploads to prevent stuck requests
- BLE packet handling is serialized to preserve ordering under network jitter
- App now supports microcontroller payload aliases:
  - `uneasy` -> mapped to movement
  - `ts` (seconds since boot) -> converted to absolute UTC timestamp
- Sensor reboot handling added (`ts` reset detection and re-anchoring)
- Backend normalizes naive timestamps to UTC before DB/ML processing
- WebSocket broadcast hardened to avoid global failure on stale clients

## File Areas Updated (High Level)

- Flutter:
  - `app/lib/services/bluetooth_service.dart`
  - `app/lib/services/websocket_service.dart`
  - `app/lib/services/app_state.dart`
  - `app/lib/services/api_service.dart`
  - `app/lib/screens/dashboard/dashboard_screen.dart`
  - `app/lib/screens/analytics_screen.dart`
  - `app/lib/widgets/risk_timeline_card.dart`
  - `app/lib/widgets/analytics_summary.dart`
  - `app/lib/widgets/analytics_vital_card.dart`
  - `app/pubspec.yaml` (added `intl`)
- Backend:
  - `backend/api/server.py`
  - `backend/services/data_service.py`
  - `backend/services/ml_service.py`
  - `backend/database/queries.py`
  - `backend/websocket/manager.py`

## Known Remaining Gaps / Next Steps

- Add robust user-facing error states (baseline missing, API failures, WS disconnect)
- Add local persistence for last prediction/vitals snapshot
- Add smoothing layer for displayed risk (without mutating stored raw model score)
- Add reconnect backoff and explicit connection status badges in UI
- Add packet sequence-number dedupe (`seq`) end-to-end for retry-safe idempotency
- Optional: richer trend/trajectory visualizations for clinician workflows

## Quick Validation Checklist

- Open app while sensor is already streaming -> dashboard updates without tab-switch workaround
- Verify BLE payload with `ts` and `uneasy` is parsed and reaches backend correctly
- Verify delayed/lossy network does not freeze ingestion (timeout + ordered queue behavior)
- Switch Day/Week/Month in analytics -> chart labels and bucket context update correctly
- Confirm risk timeline reflects backend prediction history when available
- Verify prediction status/phase/score consistency between dashboard and analytics

