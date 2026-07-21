# 📱 Digital Saver App - Code Entry & Flashing Guide

## Cambric Digital Saver Ecosystem

**© 2026 Cambric. All Rights Reserved.**
**Product:** Digital Saver | **Watch:** Onyx | **Company:** Cambric

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [App Architecture](#app-architecture)
3. [Code Structure](#code-structure)
4. [Configuration](#configuration)
5. [API Integration](#api-integration)
6. [BLE Communication](#ble-communication)
7. [Data Sync](#data-sync)
8. [Security Implementation](#security-implementation)
9. [Testing Procedures](#testing-procedures)
10. [Deployment](#deployment)
11. [Troubleshooting](#troubleshooting)

---

## 🔍 Overview

The **Digital Saver** Flutter application provides a complete health monitoring experience with seamless connectivity to the **Onyx Smartwatch**. This guide covers the complete codebase structure and how to modify/customize the application.

### Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Framework | Flutter | 3.24+ |
| Language | Dart | 3.5+ |
| Backend | Supabase | 2.x |
| State Management | Provider | 6.1+ |
| Local Storage | SharedPreferences | 2.x |
| Bluetooth | flutter_blue_plus | 1.32+ |
| Charts | fl_chart | 0.69+ |

---

## 🏗️ App Architecture

### Directory Structure

```
app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart  # Colors, dimensions, URLs
│   │   │   └── api_constants.dart  # API endpoints
│   │   ├── theme/
│   │   │   ├── app_theme.dart      # Light theme
│   │   │   └── dark_theme.dart      # Dark theme
│   │   └── utils/
│   │       ├── date_utils.dart      # Date formatting
│   │       └── validators.dart      # Input validation
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── health_data_model.dart
│   │   │   └── device_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   └── health_repository.dart
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       ├── health_provider.dart
│   │       └── settings_provider.dart
│   │
│   ├── services/
│   │   ├── supabase_service.dart    # Database operations
│   │   ├── ble_service.dart         # Bluetooth Low Energy
│   │   ├── storage_service.dart     # Local storage
│   │   ├── notification_service.dart # Push notifications
│   │   └── analytics_service.dart   # Usage tracking
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   └── notifications_screen.dart
│   │   ├── health/
│   │   │   ├── heart_screen.dart
│   │   │   ├── sleep_screen.dart
│   │   │   ├── activity_screen.dart
│   │   │   └── blood_pressure_screen.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── profile_screen.dart
│   │       ├── device_screen.dart
│   │       └── about_screen.dart
│   │
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   └── app_card.dart
│       ├── charts/
│       │   ├── heart_rate_chart.dart
│       │   ├── sleep_chart.dart
│       │   └── activity_chart.dart
│       └── dialogs/
│           ├── loading_dialog.dart
│           └── error_dialog.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
│
└── pubspec.yaml
```

---

## 📁 Code Structure

### Entry Point (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/health_provider.dart';
import 'data/providers/settings_provider.dart';
import 'services/ble_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    debug: !kReleaseMode,
  );
  
  // Initialize services
  await StorageService.init();
  await NotificationService.init();
  
  runApp(const DigitalSaverApp());
}

class DigitalSaverApp extends StatelessWidget {
  const DigitalSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BleService()),
      ],
      child: MaterialApp(
        title: 'Digital Saver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
```

### Constants (app_constants.dart)

```dart
class AppConstants {
  // App Info
  static const String appName = 'Digital Saver';
  static const String companyName = 'Cambric';
  static const String watchName = 'Onyx';
  static const String appVersion = '2.0.0';
  
  // Supabase Configuration
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.digitalsaver.com';
  
  // BLE Configuration
  static const String bleServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String bleCharacteristicUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  
  // Watch Device Names
  static const List<String> watchKeywords = [
    'onyx',
    'digital saver',
    'cambric',
    'smartwatch',
    'health watch',
  ];
  
  // Timing
  static const Duration bleScanTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Limits
  static const int maxHealthRecords = 10000;
  static const int maxContacts = 10;
  static const int maxHistoryDays = 365;
  
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFDC2626);
}
```

---

## ⚙️ Configuration

### Environment Setup

Create a `.env` file in the project root:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# API Keys
GOOGLE_MAPS_API_KEY=your-maps-key
ONESIGNAL_APP_ID=your-onesignal-id

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_BETA_FEATURES=false

# Debug
DEBUG_MODE=false
```

### Build Configuration

#### Android (android/app/build.gradle)

```gradle
android {
    defaultConfig {
        applicationId "com.cambric.digitalsaver"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "2.0.0"
        
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            signingConfig signingConfigs.release
        }
        debug {
            debuggable true
            applicationIdSuffix ".debug"
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Digital Saver needs Bluetooth to connect to your Onyx Smartwatch for health monitoring.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Digital Saver needs Bluetooth to connect to your Onyx Smartwatch for health monitoring.</string>

<key>NSHealthShareUsageDescription</key>
<string>Digital Saver can read health data from Apple Health for better tracking.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>Digital Saver can write health data to Apple Health for comprehensive tracking.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Digital Saver needs your location to send emergency alerts with your position.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Digital Saver needs continuous location access for emergency SOS alerts.</string>

<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>location</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 🔌 API Integration

### Supabase Database Schema

```sql
-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Profiles Table
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES users(id),
    email TEXT,
    display_name TEXT,
    age INTEGER,
    gender TEXT,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    blood_type TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    medical_conditions TEXT,
    allergies TEXT,
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    notification_enabled BOOLEAN DEFAULT true,
    data_sharing_consent BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Health Data Table
CREATE TABLE health_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) NOT NULL,
    device_id TEXT,
    data_type TEXT NOT NULL, -- heart_rate, sleep, activity, etc.
    value JSONB NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL,
    source TEXT DEFAULT 'device', -- device, manual, api
    quality_score INTEGER DEFAULT 100,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Emergency Alerts Table
CREATE TABLE emergency_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) NOT NULL,
    alert_type TEXT NOT NULL, -- sos, fall, heart_anomaly
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status TEXT DEFAULT 'active', -- active, acknowledged, resolved
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Device Registry Table
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    device_type TEXT NOT NULL, -- onyx_watch, scale, bp_monitor
    device_name TEXT,
    device_model TEXT,
    firmware_version TEXT,
    last_sync_at TIMESTAMPTZ,
    battery_level INTEGER,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for Performance
CREATE INDEX idx_health_data_user_id ON health_data(user_id);
CREATE INDEX idx_health_data_recorded_at ON health_data(recorded_at);
CREATE INDEX idx_health_data_type ON health_data(data_type);
CREATE INDEX idx_emergency_alerts_status ON emergency_alerts(status);
```

### API Service (supabase_service.dart)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/health_data_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Auth
  static Future<User?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }
  
  static Future<User?> signUp(String email, String password, String name) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': name},
    );
    return response.user;
  }
  
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // User Profile
  static Future<UserModel?> getProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return UserModel.fromJson(response);
  }
  
  static Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _client
        .from('user_profiles')
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }
  
  // Health Data
  static Future<List<HealthDataModel>> getHealthData({
    required String userId,
    required String dataType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    var query = _client
        .from('health_data')
        .select()
        .eq('user_id', userId)
        .eq('data_type', dataType)
        .order('recorded_at', ascending: false)
        .limit(limit);
    
    if (startDate != null) {
      query = query.gte('recorded_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('recorded_at', endDate.toIso8601String());
    }
    
    final response = await query;
    return response.map((e) => HealthDataModel.fromJson(e)).toList();
  }
  
  static Future<void> saveHealthData({
    required String userId,
    required String dataType,
    required Map<String, dynamic> value,
    DateTime? recordedAt,
    String source = 'device',
  }) async {
    await _client.from('health_data').insert({
      'user_id': userId,
      'data_type': dataType,
      'value': value,
      'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
      'source': source,
    });
  }
  
  // Emergency Alerts
  static Future<void> sendEmergencyAlert({
    required String userId,
    required String alertType,
    double? latitude,
    double? longitude,
  }) async {
    await _client.from('emergency_alerts').insert({
      'user_id': userId,
      'alert_type': alertType,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'active',
    });
  }
}
```

---

## 📡 BLE Communication

### BLE Service (ble_service.dart)

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/app_constants.dart';
import '../models/device_model.dart';

enum BleState { idle, scanning, connecting, connected, error }

class BleService extends ChangeNotifier {
  BleState _state = BleState.idle;
  String? _error;
  BluetoothDevice? _connectedDevice;
  List<DeviceModel> _discoveredDevices = [];
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  
  // Data
  Map<String, dynamic> _latestHealthData = {};
  
  BleState get state => _state;
  String? get error => _error;
  DeviceModel? get connectedDevice => _connectedDevice;
  List<DeviceModel> get discoveredDevices => _discoveredDevices;
  Map<String, dynamic> get latestHealthData => _latestHealthData;
  
  // Start scanning for devices
  Future<void> startScan() async {
    if (_state == BleState.scanning) return;
    
    _state = BleState.scanning;
    _error = null;
    _discoveredDevices = [];
    notifyListeners();
    
    // Check Bluetooth is on
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      _state = BleState.error;
      _error = 'Bluetooth is turned off';
      notifyListeners();
      return;
    }
    
    // Start scan
    await FlutterBluePlus.startScan(
      timeout: AppConstants.bleScanTimeout,
      androidUsesFineLocation: true,
    );
    
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        _processDevice(result);
      }
    });
    
    // Auto-stop after timeout
    Future.delayed(AppConstants.bleScanTimeout, () {
      if (_state == BleState.scanning) {
        stopScan();
      }
    });
  }
  
  void _processDevice(ScanResult result) {
    final name = result.device.platformName.toLowerCase();
    
    // Check if it's an Onyx watch or compatible device
    final isCompatible = AppConstants.watchKeywords.any(
      (keyword) => name.contains(keyword)
    );
    
    if (isCompatible || name.isNotEmpty) {
      final device = DeviceModel(
        id: result.device.remoteId.str,
        name: result.device.platformName,
        rssi: result.rssi,
        isOnyx: isCompatible,
      );
      
      // Update or add device
      final existingIndex = _discoveredDevices.indexWhere(
        (d) => d.id == device.id
      );
      if (existingIndex >= 0) {
        _discoveredDevices[existingIndex] = device;
      } else {
        _discoveredDevices.add(device);
      }
      notifyListeners();
    }
  }
  
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();
    _state = BleState.idle;
    notifyListeners();
  }
  
  Future<void> connect(String deviceId) async {
    _state = BleState.connecting;
    _error = null;
    notifyListeners();
    
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: const Duration(seconds: 15));
      
      _connectedDevice = _discoveredDevices.firstWhere(
        (d) => d.id == deviceId
      );
      
      // Discover services
      await device.discoverServices();
      
      // Listen for disconnection
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _state = BleState.idle;
          _connectedDevice = null;
          notifyListeners();
        }
      });
      
      _state = BleState.connected;
      notifyListeners();
    } catch (e) {
      _state = BleState.error;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _state = BleState.idle;
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> readHealthData() async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }
    
    // Find health service and characteristic
    final services = await _connectedDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid.str == AppConstants.bleServiceUuid) {
        for (var char in service.characteristics) {
          if (char.uuid.str == AppConstants.bleCharacteristicUuid) {
            final value = await char.read();
            _latestHealthData = _parseHealthData(value);
            notifyListeners();
            return _latestHealthData;
          }
        }
      }
    }
    throw Exception('Health service not found');
  }
  
  Map<String, dynamic> _parseHealthData(List<int> data) {
    // Protocol: [type, length, ...data]
    final type = data[0];
    switch (type) {
      case 0x01: // Heart Rate
        return {
          'type': 'heart_rate',
          'bpm': data[2],
          'confidence': data[3],
          'timestamp': DateTime.now().toIso8601String(),
        };
      case 0x02: // SpO2
        return {
          'type': 'spo2',
          'percentage': data[2],
          'timestamp': DateTime.now().toIso8601String(),
        };
      case 0x03: // Steps
        final steps = (data[2] << 8) | data[3];
        return {
          'type': 'steps',
          'count': steps,
          'timestamp': DateTime.now().toIso8601String(),
        };
      default:
        return {'raw': data};
    }
  }
  
  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
```

---

## 🔒 Security Implementation

### Security Service (security_service.dart)

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Session Management
  static Future<void> saveSession(String token) async {
    await _secureStorage.write(key: 'session_token', value: token);
  }
  
  static Future<String?> getSession() async {
    return await _secureStorage.read(key: 'session_token');
  }
  
  static Future<void> clearSession() async {
    await _secureStorage.delete(key: 'session_token');
  }
  
  // Biometric Authentication
  static Future<bool> isBiometricAvailable() async {
    // Check if device supports biometrics
    return true; // Implement actual check
  }
  
  static Future<bool> authenticateWithBiometric() async {
    // Use local_auth package
    // return await auth.authenticate(...);
    return true;
  }
  
  // Data Encryption
  static String encryptData(String data, String key) {
    // Use AES-256 encryption
    // This is a simplified example
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final hashed = Hmac(sha256, keyBytes).convert(bytes);
    return base64.encode(hashed.bytes);
  }
  
  static String decryptData(String encryptedData, String key) {
    // Decrypt AES-256 encrypted data
    // Implementation depends on encryption method used
    return encryptedData;
  }
  
  // API Signature
  static String generateApiSignature(String payload, String secret) {
    final bytes = utf8.encode(payload + secret);
    return sha256.convert(bytes).toString();
  }
  
  // Input Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }
  
  // Data Sanitization
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp(r'[\'"]'), '')
        .trim();
  }
}
```

### Error Handling

```dart
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic details;
  
  AppException(this.code, this.message, [this.details]);
  
  @override
  String toString() => '[$code] $message';
}

class NetworkException extends AppException {
  NetworkException([String? message]) 
      : super('NETWORK_ERROR', message ?? 'Network connection failed');
}

class AuthException extends AppException {
  AuthException([String? message]) 
      : super('AUTH_ERROR', message ?? 'Authentication failed');
}

class BluetoothException extends AppException {
  BluetoothException([String? message]) 
      : super('BLUETOOTH_ERROR', message ?? 'Bluetooth operation failed');
}

class StorageException extends AppException {
  StorageException([String? message]) 
      : super('STORAGE_ERROR', message ?? 'Storage operation failed');
}

// Error Handler
class ErrorHandler {
  static String handle(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    if (error is NetworkException) {
      return 'Please check your internet connection';
    }
    if (error is AuthException) {
      return 'Please sign in again';
    }
    return 'An unexpected error occurred';
  }
  
  static void log(dynamic error) {
    // Send to crash reporting service
    print('Error: $error');
  }
}
```

---

## 🧪 Testing Procedures

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_saver/services/security_service.dart';

void main() {
  group('SecurityService', () {
    test('validateEmail returns true for valid email', () {
      expect(SecurityService.isValidEmail('test@example.com'), true);
    });
    
    test('validateEmail returns false for invalid email', () {
      expect(SecurityService.isValidEmail('invalid'), false);
    });
    
    test('isStrongPassword validates password strength', () {
      expect(SecurityService.isStrongPassword('Password123'), true);
      expect(SecurityService.isStrongPassword('weak'), false);
    });
    
    test('sanitizeInput removes dangerous characters', () {
      expect(SecurityService.sanitizeInput('<script>alert()</script>'), 
             'scriptalert()/script');
    });
  });
}
```

### Widget Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_saver/widgets/app_button.dart';

void main() {
  testWidgets('AppButton displays label', (tester) async {
    await tester.pumpWidget(
      AppButton(
        label: 'Test Button',
        onPressed: () {},
      ),
    );
    
    expect(find.text('Test Button'), findsOneWidget);
  });
}
```

---

## 🚀 Deployment

### Build Commands

```bash
# Web
flutter build web

# Android (Debug)
flutter build apk --debug

# Android (Release)
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# Windows (requires Windows)
flutter build windows --release
```

### Release Checklist

```
□ Version bumped in pubspec.yaml
□ Version bumped in android/app/build.gradle
□ Version bumped in ios/Runner/Info.plist
□ Changelog updated
□ All tests passing
□ No console warnings in release mode
□ Privacy policy updated
□ Terms of service updated
□ App Store listing prepared
□ Play Store listing prepared
```

---

## 🔧 Troubleshooting

### Common Build Issues

| Issue | Solution |
|-------|----------|
| `dart:io not found` | Run `flutter pub get` |
| `minSdkVersion too low` | Update in android/app/build.gradle |
| `code signing error` | Check Apple Developer certificates |
| `multidex error` | Enable multidex in build.gradle |

### Common Runtime Issues

| Issue | Solution |
|-------|----------|
| `Supabase connection failed` | Check network and API keys |
| `BLE not discovering devices` | Enable location permission |
| `Session expired` | Re-authenticate user |
| `Data not syncing` | Check offline queue status |

---

**Version:** 1.0.0  
**Last Updated:** July 2026  
**Document Owner:** Cambric Engineering Team  
**Copyright © 2026 Cambric. All Rights Reserved.**
