# 🚀 Digital Saver & Onyx Watch - 2026 Upgrade Guide

## Cambric Technology Advancement Roadmap

**© 2026 Cambric. All Rights Reserved.**
**Products:** Digital Saver App | Onyx Smartwatch | Cambric Health Platform

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Technology Roadmap](#technology-roadmap)
3. [Hardware Upgrades](#hardware-upgrades)
4. [Software Upgrades](#software-upgrades)
5. [Sensor Technology](#sensor-technology)
6. [Connectivity](#connectivity)
7. [AI & Machine Learning](#ai--machine-learning)
8. [Security Enhancements](#security-enhancements)
9. [Manufacturing](#manufacturing)
10. [Cost Analysis](#cost-analysis)
11. [Timeline](#timeline)

---

## 🎯 Executive Summary

This document outlines Cambric's comprehensive upgrade strategy for the **Digital Saver** health monitoring ecosystem, covering the **Onyx Smartwatch** hardware, **Digital Saver** mobile application, and supporting infrastructure through 2026 and beyond.

### Key Objectives

| Objective | Target | Current State |
|-----------|--------|---------------|
| Battery Life | 14 days | 7 days |
| Heart Rate Accuracy | ±2 BPM | ±5 BPM |
| SpO2 Accuracy | ±1% | ±2% |
| Water Resistance | 5ATM | IP67 |
| Connectivity | 5G/WiFi 6 | BLE 4.2 |
| AI Analysis | Real-time | Batch |

---

## 🔧 Technology Roadmap

### 2026 Q3 (Current Phase)

```
┌─────────────────────────────────────────────────────────────┐
│                    Q3 2026 UPGRADES                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📱 APP (v2.0 → v2.1)                                      │
│  ├── Supabase Backend Optimization                         │
│  ├── Enhanced Error Handling                                │
│  ├── Offline Mode Improvements                              │
│  └── Security Patch v2                                      │
│                                                             │
│  ⌚ WATCH (v1.0 → v1.1)                                    │
│  ├── MAX30102 Firmware Update                               │
│  ├── Power Optimization                                     │
│  ├── BLE Range Extension                                    │
│  └── New Watch Face                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2026 Q4 (Planned Phase)

```
┌─────────────────────────────────────────────────────────────┐
│                    Q4 2026 UPGRADES                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📱 APP (v2.1 → v3.0)                                      │
│  ├── AI Health Predictions                                  │
│  ├── Multi-Device Support                                   │
│  ├── Family Sharing                                          │
│  ├── Advanced Analytics Dashboard                            │
│  └── Wear OS Support                                        │
│                                                             │
│  ⌚ WATCH (v1.1 → v2.0) - ONYX PRO                          │
│  ├── New Hardware: MAX86178 (SpO2+)                         │
│  ├── New Hardware: BMA400 (Motion)                          │
│  ├── AMOLED Display (1.4")                                  │
│  ├── 14-Day Battery                                          │
│  ├── 5ATM Water Resistance                                   │
│  └── GPS Built-in                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⌚ Hardware Upgrades

### Onyx → Onyx Pro Comparison

| Component | Onyx (Current) | Onyx Pro (2026 Q4) | Upgrade Benefit |
|-----------|----------------|---------------------|-----------------|
| **MCU** | ESP32-WROOM | ESP32-S3 | AI acceleration |
| **Flash** | 4MB | 8MB | More features |
| **Heart Rate** | MAX30102 | MAX86178 | Medical grade |
| **SpO2** | MAX30102 | Dedicated + | ±1% accuracy |
| **Motion** | MPU6050 | BMA400 | Lower power |
| **Display** | 1.3" OLED | 1.4" AMOLED | Always-on |
| **Battery** | 350mAh | 450mAh | 14-day life |
| **GPS** | None | Built-in | Location tracking |
| **NFC** | None | NTAG | Payments |
| **Water** | IP67 | 5ATM | Swimming |
| **Cost** | 592 EGP | ~850 EGP | +43% |

### Detailed Component Analysis

#### 1. Microcontroller Upgrade

**ESP32-S3 vs ESP32-WROOM**

| Specification | ESP32-WROOM | ESP32-S3 |
|---------------|-------------|----------|
| CPU | Single Core | Dual Core |
| Clock Speed | 240 MHz | 240 MHz |
| SRAM | 520 KB | 512 KB |
| Flash | 4 MB | 8 MB |
| WiFi | 802.11 b/g/n | 802.11 b/g/n |
| Bluetooth | 4.2 | 5.0 |
| AI Acceleration | ❌ | ✅ |
| USB OTG | ❌ | ✅ |
| Price | 25 EGP | 45 EGP |

**Why Upgrade:**
- ESP32-S3 has dedicated AI acceleration for on-device ML
- USB OTG enables direct firmware updates
- Bluetooth 5.0 improves range and stability
- Better power management

#### 2. Heart Rate & SpO2 Sensor

**MAX86178 - Medical Grade Module**

```cpp
// MAX86178 Features:
// - Integrated LED drivers
// - Low noise 18-bit ADC
// - Medical-grade SpO2 (FDA cleared)
// - Heart rate variability (HRV) 
// - Skin temperature
// - Ambient light rejection

#include "max86178.h"

class HealthSensor {
    MAX86178 sensor;
    
    void init() {
        sensor.begin(Wire);
        sensor.setMode(MAX86178_HR_SPO2_MODE);
        sensor.setPulseWidth(MAX86178_PW_411_US);
        sensor.setSampleRate(400); // 400Hz
        sensor.setLEDCurrent(LED1, 50); // 50mA
        sensor.setLEDRange(LED1, 100); // 100mA max
    }
    
    HealthData read() {
        int irValue = sensor.readIR();
        int redValue = sensor.readRed();
        int temp = sensor.readTemperature();
        
        return HealthData {
            heartRate: calculateHR(irValue),
            spo2: calculateSpO2(irValue, redValue),
            hrv: calculateHRV(irValue),
            temperature: temp,
            confidence: sensor.getConfidence(),
        };
    }
};
```

#### 3. Motion Sensor

**BMA400 - Ultra-Low Power Accelerometer**

```cpp
// BMA400 Features:
// - Ultra-low power: 3.5µA at 100Hz
// - Built-in step counter
// - Activity recognition
// - Tap/double-tap detection
// - Tilt detection
// - 14-bit resolution

#include "bma400.h"

class MotionSensor {
    BMA400 accelerometer;
    
    void init() {
        accelerometer.begin(Wire);
        accelerometer.setRange(BMA400_16G_RANGE);
        accelerometer.setOdr(BMA400_ODR_100HZ);
        accelerometer.setPowerMode(BMA400_NORMAL_MODE);
    }
    
    MotionData read() {
        int16_t x, y, z;
        accelerometer.getAcceleration(x, y, z);
        
        return MotionData {
            steps: accelerometer.getStepCount(),
            activity: accelerometer.getCurrentActivity(),
            x: x, y: y, z: z,
        };
    }
};
```

#### 4. Display Upgrade

**1.4" AMOLED vs 1.3" OLED**

| Specification | Current OLED | AMOLED Upgrade |
|---------------|--------------|----------------|
| Size | 1.3" | 1.4" |
| Resolution | 128x64 | 176x184 |
| Technology | SSD1306 OLED | AMOLED |
| Colors | Monochrome | 65K colors |
| Always-On | No | Yes |
| Brightness | 300 cd/m² | 500 cd/m² |
| Power (active) | 25mW | 15mW |
| Power (aod) | 0mW | 2mW |
| Price | 85 EGP | 120 EGP |

**Always-On Display Code:**

```cpp
#include "display.h"

class WatchDisplay {
    AMOLED_1_4 display;
    
    void showWatchFace() {
        // AOD mode - only update every minute
        if (shouldUpdateAOD()) {
            display.setBrightness(10); // Very dim
            display.drawWatchFace();
            display.updatePartial(); // Only changed pixels
        }
    }
    
    void showActiveMode() {
        display.setBrightness(200); // Full brightness
        display.clear();
        display.drawWatchFace();
        display.updateFull();
    }
};
```

---

## 📱 Software Upgrades

### Digital Saver App v3.0 Features

#### 1. AI Health Predictions

```dart
// Health Prediction Service
class HealthPredictionService {
    // Local ML Model for predictions
    static const bool USE_ON_DEVICE_AI = true;
    
    // Predict heart issues 30 minutes ahead
    Future<HealthAlert?> predictHeartAnomaly({
        required List<HeartRateReading> recentData,
        required UserProfile user,
    }) async {
        if (USE_ON_DEVICE_AI) {
            // Use TensorFlow Lite on device
            return await _runOnDevicePrediction(recentData, user);
        } else {
            // Cloud prediction
            return await _cloudPrediction(recentData, user);
        }
    }
    
    // Sleep quality prediction
    Future<SleepPrediction> predictSleepQuality({
        required List<ActivityData> dayActivities,
        required List<HeartRateData> eveningData,
    }) async {
        final features = extractFeatures(dayActivities, eveningData);
        return _predict(model, features);
    }
}
```

#### 2. Family Sharing

```dart
// Family Management
class FamilyService {
    // Share health data with family members
    Future<void> shareWithFamily({
        required String familyMemberEmail,
        required List<DataType> dataToShare,
        required PermissionLevel permission,
    }) async {
        // Permission levels:
        // - VIEW: Can see data
        // - ALERT: Can receive alerts
        // - MANAGE: Can manage settings
        
        await supabase.from('family_sharing').insert({
            'owner_id': currentUser.id,
            'member_email': familyMemberEmail,
            'data_types': dataToShare,
            'permission': permission,
            'created_at': DateTime.now(),
        });
        
        // Send invitation email
        await sendInvitation(familyMemberEmail);
    }
    
    // Emergency contact auto-alert
    Future<void> triggerEmergencyAlert(EmergencyAlert alert) async {
        // Get all family members with alert permission
        final contacts = await getEmergencyContacts();
        
        for (var contact in contacts) {
            await sendSMS(
                phone: contact.phone,
                message: _formatEmergencyMessage(alert),
            );
        }
    }
}
```

#### 3. Multi-Device Support

```dart
// Device Management
class DeviceManager {
    // Support multiple Onyx watches
    List<Device> registeredDevices = [];
    
    Future<void> registerDevice(Device device) async {
        if (registeredDevices.length >= 5) {
            throw Exception('Maximum 5 devices allowed');
        }
        
        await supabase.from('devices').insert({
            'user_id': currentUser.id,
            'device_type': device.type,
            'device_name': device.name,
            'firmware_version': device.firmwareVersion,
        });
        
        registeredDevices.add(device);
    }
    
    // Sync data from any connected device
    Future<void> syncAllDevices() async {
        for (var device in registeredDevices) {
            if (await bleService.isConnected(device.id)) {
                await _syncDevice(device);
            }
        }
    }
}
```

---

## 📊 Sensor Technology

### Advanced Sensors for v2.0

#### 1. ECG (Electrocardiogram)

```cpp
// AD8233 ECG Module
// Detects heart rhythm abnormalities
// AFib detection

class ECGSensor {
    AD8233 ecg;
    static const int SAMPLE_RATE = 125; // Hz
    static const int BUFFER_SIZE = 256;
    
    void init() {
        ecg.begin();
        ecg.setSampleRate(SAMPLE_RATE);
    }
    
    // Simple QRS detection
    int detectQRS(List<int> signal) {
        int qrsCount = 0;
        int threshold = calculateThreshold(signal);
        
        for (int i = 1; i < signal.length - 1; i++) {
            // QRS detection algorithm
            if (signal[i] > threshold &&
                signal[i] > signal[i-1] &&
                signal[i] > signal[i+1]) {
                qrsCount++;
            }
        }
        
        return qrsCount;
    }
    
    // Calculate heart rate from R-R intervals
    float calculateHRFromECG(List<int> rrIntervals) {
        int totalInterval = 0;
        for (var interval in rrIntervals) {
            totalInterval += interval;
        }
        return 60000 / (totalInterval / rrIntervals.length);
    }
    
    // Detect AFib
    bool detectAFib(List<int> rrIntervals) {
        // Check R-R interval variability
        double variance = calculateVariance(rrIntervals);
        double mean = calculateMean(rrIntervals);
        
        // High variability indicates possible AFib
        return (variance / mean) > 0.3;
    }
};
```

#### 2. Blood Pressure Estimation

```cpp
// Non-invasive blood pressure estimation
// Uses pulse transit time (PTT) and PPG

class BloodPressureEstimator {
    // Calibration data stored from initial setup
    float calibrationCoef;
    int baselineHR;
    int baselineSpO2;
    
    BloodPressure estimate(int currentHR, int currentSpO2, float ptt) {
        // Simplified formula - needs calibration
        float hrRatio = currentHR / baselineHR;
        float spo2Ratio = currentSpO2 / baselineSpO2;
        
        // PTT inversely related to BP
        float pttRatio = baselinePTT / ptt;
        
        // Estimate values (requires medical validation)
        int systolic = baselineSystolic * (hrRatio * pttRatio);
        int diastolic = baselineDiastolic * (spo2Ratio * pttRatio);
        
        return BloodPressure {
            systolic: systolic.clamp(70, 200),
            diastolic: diastolic.clamp(40, 130),
            map: calculateMAP(systolic, diastolic),
            confidence: calculateConfidence(currentHR, currentSpO2),
        };
    }
};
```

#### 3. Stress Detection

```cpp
// Stress level detection using multiple biomarkers
enum StressLevel { LOW, MODERATE, HIGH, VERY_HIGH }

class StressDetector {
    // Weight factors for different metrics
    static const float HR_WEIGHT = 0.3;
    static const float HRV_WEIGHT = 0.4;
    static const float ACTIVITY_WEIGHT = 0.2;
    static const float SLEEP_WEIGHT = 0.1;
    
    StressLevel detect({
        required int heartRate,
        required int hrv,
        required ActivityLevel activity,
        required int sleepHours,
    }) {
        // Normalize values to 0-100 scale
        float hrScore = normalizeHR(heartRate);
        float hrvScore = normalizeHRV(hrv);
        float activityScore = normalizeActivity(activity);
        float sleepScore = normalizeSleep(sleepHours);
        
        // Calculate weighted stress score
        float stressScore = 
            (hrScore * HR_WEIGHT) +
            ((100 - hrvScore) * HRV_WEIGHT) +
            (activityScore * ACTIVITY_WEIGHT) +
            ((100 - sleepScore) * SLEEP_WEIGHT);
        
        if (stressScore < 25) return StressLevel.LOW;
        if (stressScore < 50) return StressLevel.MODERATE;
        if (stressScore < 75) return StressLevel.HIGH;
        return StressLevel.VERY_HIGH;
    }
    
    // Personalized response
    void handleStress(StressLevel level) {
        switch (level) {
            case StressLevel.VERY_HIGH:
                sendAlert("High stress detected. Consider taking a break.");
                suggestBreathingExercise();
                break;
            // ... other levels
        }
    }
};
```

---

## 📡 Connectivity

### 5G and WiFi 6 Integration (Future)

#### Onyx Pro+ (2027)

```cpp
// Future connectivity options

class ConnectivityManager {
    enum ConnectionType { BLE, WIFI, CELLULAR };
    
    ConnectionType selectBestConnection() {
        // Priority: Cellular > WiFi > BLE
        
        if (cellularAvailable()) {
            // 5G for critical data
            return ConnectionType.CELLULAR;
        }
        
        if (wifiAvailable()) {
            // WiFi 6 for bulk sync
            return ConnectionType.WIFI;
        }
        
        return ConnectionType.BLE;
    }
    
    // Adaptive sync based on connection
    Future<void> syncData() async {
        switch (selectBestConnection()) {
            case ConnectionType.CELLULAR:
                // Real-time sync, high bandwidth
                await syncEverything();
                break;
            case ConnectionType.WIFI:
                // Full sync, no data limits
                await syncAllHealthData();
                await syncFirmwareUpdates();
                break;
            case ConnectionType.BLE:
                // Minimal sync, battery saver
                await syncRecentData();
                break;
        }
    }
};
```

---

## 🤖 AI & Machine Learning

### On-Device AI Processing

```cpp
// TensorFlow Lite for Microcontrollers
#include "tensorflow_lite.h"

class AIModel {
    tflite::MicroInterpreter* interpreter;
    TfLiteTensor* input;
    TfLiteTensor* output;
    
    void init() {
        // Load model from flash
        const tflite::Model* model = tflite::GetModel(model_data);
        
        // Setup interpreter
        static tflite::MicroOpResolver resolver;
        resolver.AddBuiltin(
            tflite::BuiltinOperator_DEPTHWISE_CONV_2D,
            tflite::ops::micro::Register_DEPTHWISE_CONV_2D()
        );
        // ... add other ops
        
        interpreter = new tflite::MicroInterpreter(model, resolver, tensor_arena);
        interpreter->AllocateTensors();
        
        input = interpreter->input(0);
        output = interpreter->output(0);
    }
    
    // Heart anomaly detection
    bool detectAnomaly(List<int> hrData) {
        // Fill input tensor
        for (int i = 0; i < hrData.length; i++) {
            input->data.f[i] = hrData[i] / 200.0; // Normalize
        }
        
        // Run inference
        interpreter->Invoke();
        
        // Get output (probability of anomaly)
        float probability = output->data.f[0];
        
        return probability > 0.7; // 70% threshold
    }
};
```

### Cloud AI Services

```dart
// Cloud-based advanced analysis
class CloudAI {
    static const String endpoint = 'https://ai.digitalsaver.com';
    
    // Send data for advanced analysis
    Future<AIMedicalReport> analyzeHealthData({
        required String userId,
        required List<HealthData> historicalData,
        required UserProfile profile,
    }) async {
        final response = await dio.post(
            '$endpoint/analyze',
            data: {
                'user_id': userId,
                'data': historicalData,
                'profile': profile.toJson(),
                'analysis_type': 'comprehensive',
            },
        );
        
        return AIMedicalReport.fromJson(response.data);
    }
    
    // Weekly health summary with AI insights
    Future<WeeklySummary> generateWeeklySummary(String userId) async {
        final response = await dio.get('$endpoint/summary/weekly/$userId');
        return WeeklySummary.fromJson(response.data);
    }
    
    // Personalized recommendations
    Future<List<Recommendation>> getRecommendations(String userId) async {
        final response = await dio.get('$endpoint/recommendations/$userId');
        return (response.data as List)
            .map((e) => Recommendation.fromJson(e))
            .toList();
    }
}
```

---

## 🔒 Security Enhancements

### v2.0 Security Architecture

```dart
class SecurityV2 {
    // 1. End-to-End Encryption
    Future<void> setupE2EEncryption() async {
        // Generate key pair
        final keyPair = await KeyGenerator.generate(
            algorithm: KeyAlgorithm.ed25519,
        );
        
        // Store private key securely
        await SecureStorage.write(
            key: 'private_key',
            value: keyPair.privateKey,
        );
        
        // Upload public key to server
        await supabase.from('user_keys').upsert({
            'user_id': currentUser.id,
            'public_key': keyPair.publicKey,
        });
    }
    
    // 2. Biometric Authentication
    Future<bool> authenticateBiometric() async {
        final result = await LocalAuth.authenticate(
            localizedReason: 'Authenticate to access Digital Saver',
            options: const AuthenticationOptions(
                biometricOnly: true,
                stickyAuth: true,
            ),
        );
        return result;
    }
    
    // 3. Anomaly Detection
    Future<bool> detectSecurityAnomaly() async {
        // Check for unusual patterns
        final loginHistory = await getRecentLogins();
        final currentLocation = await getCurrentLocation();
        
        for (var login in loginHistory) {
            if (isUnusualLocation(login.location, currentLocation)) {
                await sendSecurityAlert(
                    type: AlertType.LOCATION_ANOMALY,
                    details: 'Login from unusual location',
                );
                return true;
            }
        }
        
        return false;
    }
    
    // 4. Data Privacy
    Future<void> exportAllData() async {
        // GDPR compliance - export all user data
        final healthData = await supabase
            .from('health_data')
            .select()
            .eq('user_id', currentUser.id);
            
        final profile = await supabase
            .from('user_profiles')
            .select()
            .eq('id', currentUser.id);
            
        final export = {
            'export_date': DateTime.now().toIso8601String(),
            'health_data': healthData,
            'profile': profile,
        };
        
        await downloadFile(
            filename: 'digitalsaver_export.json',
            content: jsonEncode(export),
        );
    }
}
```

---

## 🏭 Manufacturing

### Production Cost Analysis

#### Current Onyx (v1.0)

| Component | Unit Cost (EGP) | Qty | Total |
|-----------|-----------------|-----|-------|
| ESP32-WROOM-32 | 25 | 1 | 25 |
| MAX30102 | 120 | 1 | 120 |
| MPU6050 | 30 | 1 | 30 |
| OLED 1.3" | 85 | 1 | 85 |
| PCB (4-layer) | 50 | 1 | 50 |
| Battery 350mAh | 35 | 1 | 35 |
| TP4056 | 10 | 1 | 10 |
| Components | 50 | 1 | 50 |
| Case (3D print) | 30 | 1 | 30 |
| Assembly | 100 | 1 | 100 |
| Testing | 30 | 1 | 30 |
| **Total** | | | **555 EGP** |

#### Onyx Pro (v2.0)

| Component | Unit Cost (EGP) | Qty | Total |
|-----------|-----------------|-----|-------|
| ESP32-S3 | 45 | 1 | 45 |
| MAX86178 | 200 | 1 | 200 |
| BMA400 | 60 | 1 | 60 |
| AMOLED 1.4" | 120 | 1 | 120 |
| PCB (6-layer) | 80 | 1 | 80 |
| Battery 450mAh | 50 | 1 | 50 |
| GPS Module | 45 | 1 | 45 |
| Components | 70 | 1 | 70 |
| Case (injection) | 25 | 1 | 25 |
| Assembly | 120 | 1 | 120 |
| Testing | 50 | 1 | 50 |
| **Total** | | | **865 EGP** |

### Production Scaling

```
┌─────────────────────────────────────────────────────────────┐
│                    COST vs VOLUME                           │
├──────────────┬──────────────┬──────────────┬────────────────┤
│   Volume     │  Onyx v1.0  │  Onyx Pro    │   Savings      │
├──────────────┼──────────────┼──────────────┼────────────────┤
│    10        │    555 EGP   │    865 EGP   │     Base       │
│   100        │    420 EGP   │    680 EGP   │    25% off     │
│   500        │    350 EGP   │    550 EGP   │    37% off     │
│  1000        │    290 EGP   │    450 EGP   │    48% off     │
│  5000        │    250 EGP   │    380 EGP   │    55% off     │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

---

## 📅 Timeline

### 2026 Implementation Schedule

```
JULY 2026 ────────────────────────────────
│ July 1-15: App v2.0.1 Security Patch
│ July 16-31: App v2.1 Beta Testing
└────────────────────────────────────────

AUGUST 2026 ──────────────────────────────
│ August 1-15: Onyx v1.1 Firmware Release
│ August 16-31: App v2.1 Public Release
│              Performance Optimization
└────────────────────────────────────────

SEPTEMBER 2026 ───────────────────────────
│ September 1-20: Onyx Pro Hardware Design
│ September 21-30: Onyx Pro Prototype
└────────────────────────────────────────

OCTOBER 2026 ─────────────────────────────
│ October 1-15: Onyx Pro Testing & Calibration
│ October 16-31: Onyx Pro FCC/CE Certification
│              App v3.0 Beta (AI Features)
└────────────────────────────────────────

NOVEMBER 2026 ────────────────────────────
│ November 1-15: Onyx Pro Mass Production
│ November 16-30: Onyx Pro Launch
│              App v3.0 Public Release
└────────────────────────────────────────

DECEMBER 2026 ────────────────────────────
│ December 1-31: Holiday Campaign
│              Customer Feedback Analysis
│              2027 Planning
└────────────────────────────────────────
```

---

## 📊 Success Metrics

| Metric | 2026 Target | 2027 Target |
|--------|-------------|--------------|
| Active Users | 10,000 | 100,000 |
| Devices Sold | 5,000 | 50,000 |
| Data Points | 100M | 1B |
| Battery Life | 14 days | 21 days |
| Accuracy (HR) | ±2 BPM | ±1 BPM |
| Customer Satisfaction | 4.5/5 | 4.8/5 |
| Emergency Saves | 50 | 500 |

---

## 📞 Support & Contact

**Cambric Engineering Team**
- Technical Documentation: docs.cambric.example.com
- Firmware Updates: github.com/cambric-software/onyx-firmware
- App Source: Private repository (contact for access)
- Support Email: engineering@cambric.example.com

**Business Inquiries**
- Sales: sales@cambric.example.com
- Partnerships: partners@cambric.example.com
- Press: press@cambric.example.com

---

**Document Version:** 2.0  
**Last Updated:** July 2026  
**Next Review:** October 2026  
**Copyright © 2026 Cambric. All Rights Reserved.**
