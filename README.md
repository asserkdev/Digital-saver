# Digital Saver - Smartwatch Health Monitoring App

A professional health monitoring smartwatch with emergency alerts.

**⚠️ Disclaimer:** Wellness tool, NOT medical device.

## Quick Links

| Folder | Description |
|--------|-------------|
| **[app/](app/)** | Flutter mobile app (20 files) |
| **[hardware/](hardware/)** | DIY smartwatch (ESP32) |
| **[docs/](docs/)** | Assembly & user guides |

## App Files

```
app/
├── main.dart                    # Entry point
├── screens/                     # 7 UI screens
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── heart_screen.dart
│   ├── blood_pressure_screen.dart
│   ├── activity_screen.dart
│   ├── sleep_screen.dart
│   └── settings_screen.dart
├── services/                     # Business logic
├── models/                       # Data models
├── widgets/                      # UI components
├── theme/                        # Material Design 3
└── i18n/                        # 10 languages
```

## Features

- Heart Rate + HRV + AFib Detection
- Blood Pressure Estimation
- Fall Detection
- Emergency SMS/Call with GPS
- Sleep & Activity Tracking
- 10 Languages (Arabic RTL)
- Health Score 0-100

## Run

```bash
flutter pub get
flutter run
```

## Budget

**Total: ~2,810 EGP** (within 10,000 EGP)

---

**Version:** 2.0.0 | **License:** MIT
