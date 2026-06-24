import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/ble_service.dart';
import 'package:digital_saver/services/health_analysis_service.dart';
import 'package:digital_saver/services/emergency_service.dart';
import 'package:digital_saver/services/storage_service.dart';
import 'package:digital_saver/screens/main_screen.dart';
import 'package:digital_saver/i18n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final storage = StorageService();
  await storage.init();
  
  final ble = BleService();
  final health = HealthAnalysisService();
  final emergency = EmergencyService();
  await emergency.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => storage),
        ChangeNotifierProvider(create: (_) => ble),
        ChangeNotifierProvider(create: (_) => health),
        ChangeNotifierProvider(create: (_) => emergency),
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
