# SepsisGuard – Real-Time Sepsis Detection System

A real-time healthcare monitoring system for early detection of sepsis using IoT sensors, BLE communication, a Flutter mobile application, on-device machine learning, and cloud-based backend services.

---

## Overview

SepsisGuard continuously monitors patient vitals and provides early risk prediction for sepsis. Physiological data is collected via sensors connected to a microcontroller and transmitted using Bluetooth Low Energy (BLE) to a mobile application. An on-device machine learning model processes this data in real time, and results are stored in a cloud-based backend for monitoring and analysis.

---

## System Architecture

Sensors → Microcontroller → BLE → Flutter App → ML Model → Prediction → Cloud Backend → Database

---

## Features

- Real-time BLE data communication from IoT device  
- Flutter-based mobile application  
- Live monitoring of vital parameters  
- On-device machine learning prediction  
- Risk classification (Normal / Warning / Critical)  
- Cloud-based backend and database integration  
- Storage of both raw sensor data and prediction results  

---

## Tech Stack

### Mobile App
- Flutter (Dart)
- BLE communication (Flutter BLE libraries)

### Backend
- Cloud-based APIs (FastAPI / Node.js / etc.)
- RESTful architecture

### Database
- Cloud database (MySQL / MongoDB / etc.)

### Hardware
- Microcontroller with physiological sensors
- BLE module for wireless communication

### Machine Learning
- On-device ML model for sepsis risk prediction

---

## Data Flow

1. Sensors collect physiological data (heart rate, temperature, SpO2, etc.)
2. Microcontroller transmits data via BLE
3. Flutter app receives and parses raw data
4. Data is preprocessed and passed to ML model
5. Model outputs sepsis risk prediction
6. App displays real-time vitals and alerts
7. Data + prediction sent to cloud backend
8. Stored in database for analysis

---

## Project Structure

SepsisGuard/
│
├── mobile_app/        # Flutter application  
├── backend/           # API services  
├── database/          # Schema / scripts  
├── docs/              # Diagrams / reports  
└── README.md  

---

## Setup Instructions

### 1. Clone the Repository
git clone https://github.com/your-username/SepsisGuard.git  
cd SepsisGuard  

### 2. Run Flutter App
cd mobile_app  
flutter pub get  
flutter run  

### 3. Backend Setup (Example)
cd backend  
pip install -r requirements.txt  
uvicorn main:app --reload  

---

## Future Improvements

- Advanced analytics dashboard  
- Real-time cloud streaming  
- Push notifications for critical alerts  
- Improved ML model accuracy  
- Multi-device support  

---

## Contributors

- Vaibhav Aluri – BLE Integration, Mobile App Development, Backend & Database  
- Team Member(s) – ML Model Development, Sensor & Microcontroller Integration  

---

## License

This project is for academic and research purposes.### Database
- Cloud database (MySQL / MongoDB / etc.)

### Hardware
- Microcontroller with physiological sensors
- BLE module for wireless communication

### Machine Learning
- On-device ML model for sepsis risk prediction

---

## 🔄 Data Flow

1. Sensors collect physiological data (heart rate, temperature, SpO2, etc.)
2. Microcontroller transmits data via BLE
3. Flutter app receives and parses raw data
4. Data is preprocessed and passed to ML model
5. Model outputs sepsis risk prediction
6. App displays real-time vitals and alerts
7. Data + prediction sent to cloud backend
8. Stored in database for analysis

---

## 📂 Project Structure

SepsisGuard/
│
├── mobile_app/        # Flutter application  
├── backend/           # API services  
├── database/          # Schema / scripts  
├── docs/              # Diagrams / reports  
└── README.md  

---

## ⚙️ Setup Instructions

### 1. Clone the Repository
git clone https://github.com/your-username/SepsisGuard.git  
cd SepsisGuard  

### 2. Run Flutter App
cd mobile_app  
flutter pub get  
flutter run  

### 3. Backend Setup (Example)
cd backend  
pip install -r requirements.txt  
uvicorn main:app --reload  

---

## 📊 Future Improvements

- Advanced analytics dashboard  
- Real-time cloud streaming  
- Push notifications for critical alerts  
- Improved ML model accuracy  
- Multi-device support  

---

## 🤝 Contributors

- Vaibhav Aluri – BLE Integration, Mobile App Development, Backend & Database  
- Team Member(s) – ML Model Development, Sensor & Microcontroller Integration  

---

## 📜 License

This project is for academic and research purposes.
