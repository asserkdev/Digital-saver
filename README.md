# Digital Saver - Smartwatch Health Monitoring System

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [App Structure](#1-app-structure) | Flutter app code organization |
| 2 | [Features](#2-features) | Core capabilities |
| 3 | [Quick Start](#3-quick-start) | Run the app |
| 4 | [Hardware](#4-hardware) | DIY watch components |
| 5 | [Firmware](#5-firmware-esp32) | ESP32 watch code |
| 6 | [Documentation](#6-documentation) | Guides |
| 7 | [Budget](#7-budget) | Cost breakdown |
| 8 | [Disclaimer](#8-disclaimer) | Important notice |

---

## 1. App Structure

```
app/                    # Flutter mobile app (20 Dart files)
├── main.dart          # App entry point
├── screens/           # UI screens (7 screens)
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── heart_screen.dart
│   ├── blood_pressure_screen.dart
│   ├── activity_screen.dart
│   ├── sleep_screen.dart
│   └── settings_screen.dart
├── services/          # Business logic
│   ├── ble_advanced_service.dart
│   ├── health_analysis_service.dart
│   ├── emergency_service.dart
│   └── storage_service.dart
├── models/            # Data models
│   └── health_models.dart
├── widgets/           # Reusable UI components
├── theme/             # App theme
└── i18n/             # Translations (10 languages)

hardware/              # DIY smartwatch
├── firmware/esp32/    # Arduino/ESP32 code
└── schematic/         # Circuit diagrams

docs/                  # Documentation
```

### App Files
- `main.dart` - Entry point
- `screens/` - 7 professional screens
- `services/` - BLE, health analysis, emergency
- `models/` - Comprehensive health models
- `widgets/` - Custom UI components
- `theme/` - Material Design 3 theme
- `i18n/` - 10 language translations

---

## 2. Features

- **Heart Rate Monitoring** - Real-time PPG-based heart rate detection
- **Blood Pressure Estimation** - PPG waveform analysis for BP estimation
- **Fall Detection** - Accelerometer-based loss of consciousness
- **Arrhythmia Detection** - Irregular heartbeat pattern recognition
- **AFib Detection** - Atrial fibrillation screening algorithm
- **HRV Analysis** - Heart rate variability with RMSSD, SDNN, pNN50
- **Emergency Alerts** - Automatic SMS/call to emergency contacts with GPS
- **Multi-language Support** - 10 languages including Arabic RTL
- **Sleep Analysis** - Deep/Light/REM sleep stages tracking
- **Activity Tracking** - Steps, calories, hourly activity charts
- **Health Score** - Comprehensive 0-100 health assessment

---

## 3. Quick Start

### Run the App
```bash
# Install dependencies
flutter pub get

# Run on device
flutter run
```

### Flash Firmware
```bash
cd hardware/firmware/esp32
pio run --target upload
```

---

## 4. Hardware

| Component | Model | Price (EGP) |
|-----------|-------|-------------|
| MCU | ESP32-WROOM-32 | 180 |
| PPG Sensor | MAX30102 | 220 |
| Accelerometer | MPU6050 | 45 |
| Display | 1.3" OLED I2C | 85 |
| Battery | 500mAh LiPo | 75 |
| Charger | TP4056 | 25 |

**Total: ~2,810 EGP**

---

## 5. Firmware (ESP32)

See `hardware/firmware/esp32/` for Arduino/PlatformIO code.

---

## 6. Documentation

- `SPEC.md` - Complete project specification
- `docs/assembly-guide.md` - Watch assembly instructions
- `docs/user-manual.md` - User guide
- `docs/troubleshooting.md` - Problem solving

---

## 7. Budget

| Category | Cost (EGP) |
|----------|-------------|
| Electronics | 1,000 |
| Battery & Charger | 400 |
| Tools & Supplies | 900 |
| Contingency | 510 |
| **Total** | **2,810** |

**Remaining from 10,000 EGP: ~7,190 EGP**

---

## 8. Disclaimer

**WARNING:** This is a **wellness tool**, NOT a medical device.

- Do not use for self-diagnosis
- Does not replace professional care
- In emergencies, call local emergency services

---

**Version:** 2.0.0 | **License:** MIT
