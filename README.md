# Digital Saver App

## 📁 All Files: [app/](app/) | [hardware/](hardware/) | [docs/](docs/)

---

## app/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/ble_advanced_service.dart';
import 'package:digital_saver/services/health_analysis_service.dart';
import 'package:digital_saver/services/storage_service.dart';
import 'package:digital_saver/services/emergency_service.dart';
import 'package:digital_saver/screens/main_screen.dart';
import 'package:digital_saver/i18n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final storageService = StorageService();
  await storageService.init();
  
  final bleService = BleAdvancedService();
  final healthAnalysis = HealthAnalysisService();
  final emergencyService = EmergencyService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => storageService),
        ChangeNotifierProvider(create: (_) => bleService),
        ChangeNotifierProvider(create: (_) => healthAnalysis),
        ChangeNotifierProvider(create: (_) => emergencyService),
      ],
      child: const DigitalSaverApp(),
    ),
  );
}

class DigitalSaverApp extends StatelessWidget {
  const DigitalSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    
    return MaterialApp(
      title: 'Digital Saver',
      debugShowCheckedModeBanner: false,
      locale: storage.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
```

## All Files

| File | Description |
|------|-------------|
| [app/main.dart](app/main.dart) | Entry point |
| [app/screens/main_screen.dart](app/screens/) | Navigation + 5 tabs |
| [app/screens/dashboard_screen.dart](app/screens/) | Health score, metrics |
| [app/screens/heart_screen.dart](app/screens/) | HRV, AFib, arrhythmia |
| [app/screens/blood_pressure_screen.dart](app/screens/) | BP, vascular age |
| [app/screens/activity_screen.dart](app/screens/) | Steps, calories |
| [app/screens/sleep_screen.dart](app/screens/) | Sleep stages |
| [app/screens/settings_screen.dart](app/screens/) | Profile, language |
| [app/services/](app/services/) | BLE, analysis, storage |
| [app/models/](app/models/) | Health models |
| [app/widgets/](app/widgets/) | UI components |
| [app/theme/](app/theme/) | Material Design 3 |
| [app/i18n/](app/i18n/) | 10 languages |

**Run:** `flutter pub get && flutter run`

---

⚠️ **Disclaimer:** Wellness tool, NOT medical device.
