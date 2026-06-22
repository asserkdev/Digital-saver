# Digital Saver - Smartwatch Health Monitoring System

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [Features](#1-features) | Core capabilities of the system |
| 2 | [Project Structure](#2-project-structure) | File organization |
| 3 | [Quick Start](#3-quick-start) | Get started quickly |
| 4 | [Hardware Components](#4-hardware-components) | Parts needed for DIY watch |
| 5 | [Mobile App](#5-mobile-app) | Flutter application features |
| 6 | [Firmware](#6-firmware-esp32) | ESP32 watch code |
| 7 | [Documentation](#7-documentation) | Assembly and user guides |
| 8 | [Budget](#8-budget) | Cost breakdown (~3,810 EGP) |
| 9 | [Disclaimer](#9-medical-disclaimer) | Important medical notice |

---

## 1. Features

- **Heart Rate Monitoring** - Real-time PPG-based heart rate detection
- **Blood Pressure Estimation** - PPG waveform analysis for BP estimation
- **Fall Detection** - Accelerometer-based loss of consciousness detection
- **Arrhythmia Detection** - Irregular heartbeat pattern recognition
- **AFib Detection** - Atrial fibrillation screening algorithm
- **HRV Analysis** - Heart rate variability with RMSSD, SDNN, pNN50
- **Emergency Alerts** - Automatic SMS/call to emergency contacts with GPS
- **Multi-language Support** - 10 languages including Arabic RTL
- **Sleep Analysis** - Deep/Light/REM sleep stages tracking
- **Activity Tracking** - Steps, calories, hourly activity charts
- **Health Score** - Comprehensive 0-100 health assessment

---

## 2. Project Structure

```
Digital-saver/
├── SPEC.md                    # Detailed project specification
├── README.md                  # This file
├── hardware/
│   ├── schematic/             # Circuit schematics
│   ├── pcb/                   # PCB design files
│   ├── enclosure/             # 3D print files (.stl)
│   └── firmware/
│       └── esp32/            # Arduino/PlatformIO code
├── mobile_app/
│   └── digital_saver/        # Flutter application
└── docs/
    ├── assembly-guide.md      # Watch assembly instructions
    ├── user-manual.md        # User guide
    └── troubleshooting.md    # Problem solving
```

---

## 3. Quick Start

### Hardware Setup
1. Order components (see Hardware Components section)
2. Assemble the smartwatch (see [Assembly Guide](docs/assembly-guide.md))
3. Flash firmware using PlatformIO or Arduino IDE

### Mobile App Setup
```bash
cd mobile_app/digital_saver
flutter pub get
flutter run
```

---

## 4. Hardware Components

| Component | Model | Purpose | Price (EGP) |
|-----------|-------|---------|-------------|
| Main MCU | ESP32-WROOM-32 | Processing + BLE | 180 |
| PPG Sensor | MAX30102 | Heart rate + SpO2 | 220 |
| Accelerometer | MPU6050 | Fall detection | 45 |
| Display | 1.3" OLED I2C | User interface | 85 |
| Battery | 500mAh LiPo | Power supply | 75 |
| Charger | TP4056 | LiPo charging | 25 |

**Total: ~2,810 EGP** (within 10,000 EGP budget)

---

## 5. Mobile App

### Screens
- **Dashboard** - Health score, metrics overview, recommendations
- **Heart** - HRV analysis, AFib detection, HR trend chart
- **Blood Pressure** - Vascular age, BP categories, trends
- **Activity** - Steps, calories, hourly chart
- **Sleep** - Sleep stages, score, insights
- **Settings** - Profile, language, thresholds, contacts

### Supported Languages
English, Arabic, Spanish, French, German, Chinese, Japanese, Russian, Portuguese, Hindi

### Advanced Features
- Professional Material Design 3 UI
- Dark/Light mode support
- Real-time BLE connection
- Custom health score algorithm
- Trend analysis and predictions

---

## 6. Firmware (ESP32)

### Requirements
- Arduino IDE or PlatformIO
- ESP32 board package
- Libraries: MAX30105, Adafruit GFX, MPU6050

### Upload
```bash
cd hardware/firmware/esp32
pio run --target upload
```

---

## 7. Documentation

- [SPEC.md](SPEC.md) - Complete project specification
- [Assembly Guide](docs/assembly-guide.md) - Watch assembly instructions
- [User Manual](docs/user-manual.md) - How to use the system
- [Troubleshooting](docs/troubleshooting.md) - Problem solving guide

---

## 8. Budget

| Category | Cost (EGP) |
|----------|-------------|
| Electronics | 1,000 |
| Battery & Charger | 400 |
| Tools & Supplies | 900 |
| Contingency | 510 |
| **Total** | **2,810** |

**Remaining from 10,000 EGP: ~7,190 EGP**

---

## 9. Medical Disclaimer

**WARNING:** This device is a **wellness/screening tool** and is **NOT** a medical device.

- Do not use for self-diagnosis
- Does not replace professional medical care
- Always consult healthcare professionals
- In emergencies, call local emergency services

---

**Version:** 2.0.0 | **License:** MIT
