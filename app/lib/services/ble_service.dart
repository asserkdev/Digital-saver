import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:digital_saver/models/health_models.dart';

// ============================================================================
// ADVANCED BLE SERVICE - REAL-TIME HEALTH DATA STREAMING
// ============================================================================
class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // BLE Configuration
  static const String DEVICE_NAME = 'DigitalSaver';
  static const String SERVICE_UUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String HR_CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String BP_CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';
  static const String O2_CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26aa';
  static const String ACCEL_CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26ab';
  static const String CONFIG_CHAR_UUID = 'beb5483e-36e1-4688-b7f5-ea07361b26ac';

  // State
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothDevice>? _connectionSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _hrChar;
  BluetoothCharacteristic? _bpChar;
  BluetoothCharacteristic? _o2Char;
  BluetoothCharacteristic? _accelChar;
  
  bool _isScanning = false;
  bool _isConnected = false;
  int _batteryLevel = 100;
  int _signalStrength = 0;
  DateTime? _lastSync;

  // Data streams
  final _hrController = StreamController<HeartRateData>.broadcast();
  final _bpController = StreamController<BloodPressureData>.broadcast();
  final _o2Controller = StreamController<OxygenData>.broadcast();
  final _fallController = StreamController<FallData>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Public streams
  Stream<HeartRateData> get hrStream => _hrController.stream;
  Stream<BloodPressureData> get bpStream => _bpController.stream;
  Stream<OxygenData> get o2Stream => _o2Controller.stream;
  Stream<FallData> get fallStream => _fallController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  int get batteryLevel => _batteryLevel;
  int get signalStrength => _signalStrength;
  DateTime? get lastSync => _lastSync;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // ==========================================================================
  // DEVICE SCANNING
  // ==========================================================================
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    _isScanning = true;
    
    try {
      // Request Bluetooth on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.platformName.contains(DEVICE_NAME) ||
              result.device.platformName.contains('DS') ||
              result.device.platformName.contains('ESP32')) {
            _connectToDevice(result.device);
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: timeout);
      _isScanning = false;
    } catch (e) {
      _isScanning = false;
      debugPrint('Scan error: $e');
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    _scanSubscription?.cancel();
  }

  // ==========================================================================
  // DEVICE CONNECTION
  // ==========================================================================
  Future<void> _connectToDevice(BluetoothDevice device) async {
    await stopScan();
    
    try {
      _connectedDevice = device;
      await device.connect(timeout: const Duration(seconds: 15));
      _isConnected = true;
      _connectionController.add(true);
      _lastSync = DateTime.now();

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase().contains(SERVICE_UUID.substring(0, 8))) {
          for (BluetoothCharacteristic char in service.characteristics) {
            switch (char.uuid.toString().toLowerCase()) {
              case var u when u.contains('hr'):
                _hrChar = char;
                await _subscribeToCharacteristic(_hrChar!, _parseHeartRate);
                break;
              case var u when u.contains('bp'):
                _bpChar = char;
                await _subscribeToCharacteristic(_bpChar!, _parseBloodPressure);
                break;
              case var u when u.contains('o2'):
                _o2Char = char;
                await _subscribeToCharacteristic(_o2Char!, _parseOxygen);
                break;
              case var u when u.contains('accel'):
                _accelChar = char;
                await _subscribeToCharacteristic(_accelChar!, _parseAccelerometer);
                break;
            }
          }
        }
      }

      // Monitor connection state
      device.connectionState.listen((state) {
        if (state == BluetoothDeviceConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _connectionController.add(false);
        }
      });

    } catch (e) {
      _isConnected = false;
      _connectedDevice = null;
      _connectionController.add(false);
      debugPrint('Connection error: $e');
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _isConnected = false;
    _connectedDevice = null;
    _connectionController.add(false);
    _dataSubscription?.cancel();
  }

  // ==========================================================================
  // CHARACTERISTIC SUBSCRIPTION
  // ==========================================================================
  Future<void> _subscribeToCharacteristic(
    BluetoothCharacteristic char,
    void Function(List<int>) parser,
  ) async {
    await char.setNotifyValue(true);
    char.lastValueStream.listen((value) {
      parser(value);
      _lastSync = DateTime.now();
    });
  }

  // ==========================================================================
  // DATA PARSING - REAL-TIME HEALTH DATA DECODING
  // ==========================================================================
  void _parseHeartRate(List<int> data) {
    if (data.length < 5) return;

    try {
      // Parse PPG-based heart rate data
      // Format: [flags, bpm, hrv_ms, confidence, rr_count, rr1, rr2, ...]
      int flags = data[0];
      int bpm = data[1];
      int hrv = data[2];
      int confidence = data[3];
      int rrCount = data[4];
      
      List<int> rrIntervals = [];
      if (data.length >= 5 + rrCount * 2) {
        for (int i = 0; i < rrCount; i++) {
          int rr = (data[5 + i * 2] << 8) | data[6 + i * 2];
          rrIntervals.add(rr);
        }
      }

      // Calculate additional metrics
      double sdnn = hrv * 0.7;
      double pnn50 = hrv * 0.3;
      double rmssd = hrv.toDouble();
      
      // Detect arrhythmia type
      ArrhythmiaType arrhythmiaType = ArrhythmiaType.normalSinus;
      double afibProb = 0;
      
      if (bpm > 100) {
        arrhythmiaType = ArrhythmiaType.sinusTachycardia;
      } else if (bpm < 60) {
        arrhythmiaType = ArrhythmiaType.sinBradycardia;
      }
      
      // Calculate HRV-based AFib probability
      if (rrIntervals.length > 5) {
        double meanRR = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
        double variance = rrIntervals.map((r) => (r - meanRR) * (r - meanRR)).reduce((a, b) => a + b) / rrIntervals.length;
        double cv = (variance > 0 ? sqrt(variance) / meanRR : 0) * 100;
        afibProb = (cv * 3).clamp(0, 100);
      }

      HeartRateData hrData = HeartRateData(
        currentBPM: bpm,
        averageBPM: bpm,
        minBPM: bpm - 10,
        maxBPM: bpm + 15,
        hrv: hrv.toDouble(),
        sdnn: sdnn,
        pnn50: pnn50,
        rmssd: rmssd,
        rrIntervals: rrIntervals,
        status: _getHeartStatus(bpm),
        confidence: confidence.toDouble(),
        hrvAnalysis: _generateHrvAnalysis(hrv, sdnn, pnn50),
        afibProbability: afibProb,
        arrhythmiaType: arrhythmiaType,
        poincarePlotSD1: [hrv * 0.5],
        poincarePlotSD2: [hrv * 0.8],
        stressIndex: 50 - (hrv / 2),
        recoveryIndex: hrv > 30 ? 80 : 50,
        timestamp: DateTime.now(),
      );

      _hrController.add(hrData);
    } catch (e) {
      debugPrint('HR parse error: $e');
    }
  }

  void _parseBloodPressure(List<int> data) {
    if (data.length < 7) return;

    try {
      // Parse BP data
      // Format: [sys, dia, map, pp, ai, pwv, confidence]
      int systolic = data[0];
      int diastolic = data[1];
      int map = data[2];
      int pulsePressure = data[3];
      int ai = data[4];
      double pwv = data[5] / 10.0;
      int confidence = data[6];

      // Calculate vascular metrics
      int vascularAge = calculateVascularAge(pulsePressure, ai.toDouble(), pwv, systolic, diastolic);
      double arterialStiffness = calculateArterialStiffness(pwv, ai.toDouble());
      double cardiacOutput = map / 80.0 * 5.0;
      double svr = (map * 80) / (cardiacOutput * 60);

      BloodPressureData bpData = BloodPressureData(
        systolic: systolic,
        diastolic: diastolic,
        meanArterialPressure: map,
        pulsePressure: pulsePressure.toDouble(),
        augmentationIndex: ai.toDouble(),
        augmentationPressure: ai * 0.4,
        pulseWaveVelocity: pwv,
        pulseWave: _generatePulseWave(),
        category: _getBpCategory(systolic, diastolic),
        confidence: confidence.toDouble(),
        vascularAge: vascularAge,
        arterialStiffness: arterialStiffness,
        cardiacOutput: cardiacOutput,
        systemicVascularResistance: svr,
        timestamp: DateTime.now(),
      );

      _bpController.add(bpData);
    } catch (e) {
      debugPrint('BP parse error: $e');
    }
  }

  void _parseOxygen(List<int> data) {
    if (data.length < 6) return;

    try {
      // Parse SpO2 data
      // Format: [spo2, fast_spo2, pi, rr, pi_var, confidence]
      int spO2 = data[0];
      int fastSpO2 = data[1];
      double pi = data[2] / 10.0;
      int rr = data[3];
      double piVar = data[4] / 10.0;
      int confidence = data[5];

      OxygenData o2Data = OxygenData(
        spO2: spO2,
        fastSpO2: fastSpO2,
        perfusionIndex: pi,
        respirationRate: rr.toDouble(),
        piVariability: piVar,
        lowOxygenAlert: spO2 < 90,
        lowOxygenDuration: 0,
        spo2History: [spO2],
        status: _getOxygenStatus(spO2),
        confidence: confidence.toDouble(),
        oxygenSaturationIndex: (spO2 - 95) * 10,
        timestamp: DateTime.now(),
      );

      _o2Controller.add(o2Data);
    } catch (e) {
      debugPrint('O2 parse error: $e');
    }
  }

  void _parseAccelerometer(List<int> data) {
    if (data.length < 6) return;

    try {
      // Parse accelerometer data for fall detection
      // Format: [x_low, x_high, y_low, y_high, z_low, z_high, freefall, orientation]
      int x = _combineBytes(data[0], data[1]);
      int y = _combineBytes(data[2], data[3]);
      int z = _combineBytes(data[4], data[5]);
      int freefall = data.length > 6 ? data[6] : 0;
      int orientation = data.length > 7 ? data[7] : 0;

      // Calculate impact force and orientation change
      double impactForce = sqrt(x * x + y * y + z * z) / 1000;
      double orientationChange = orientation / 10.0;
      
      // Fall detection algorithm
      bool fallDetected = freefall > 50 || (impactForce > 3.0 && orientationChange > 90);
      bool locSuspected = freefall > 100 && orientation > 270;

      FallData fallData = FallData(
        fallDetected: fallDetected,
        impactForce: impactForce,
        orientationChange: orientationChange,
        timestamp: DateTime.now(),
        freeFallDuration: freefall,
        lossOfConsciousness: locSuspected,
        confidence: 85,
      );

      _fallController.add(fallData);
    } catch (e) {
      debugPrint('Accel parse error: $e');
    }
  }

  // ==========================================================================
  // HELPER FUNCTIONS
  // ==========================================================================
  int _combineBytes(int low, int high) {
    return (high << 8) | low;
  }

  HeartRateStatus _getHeartStatus(int bpm) {
    if (bpm < 40 || bpm > 180) return HeartRateStatus.critical;
    if (bpm < 60 || bpm > 100) return HeartRateStatus.warning;
    return HeartRateStatus.normal;
  }

  BpCategory _getBpCategory(int sys, int dia) {
    if (sys > 180 || dia > 120) return BpCategory.crisis;
    if (sys >= 140 || dia >= 90) return BpCategory.hypertension2;
    if (sys >= 130 || dia >= 80) return BpCategory.hypertension1;
    if (sys >= 120 && dia < 80) return BpCategory.elevated;
    if (sys >= 90 && dia >= 60) return BpCategory.normal;
    return BpCategory.hypotension;
  }

  OxygenStatus _getOxygenStatus(int spO2) {
    if (spO2 >= 95) return OxygenStatus.normal;
    if (spO2 >= 90) return OxygenStatus.mildHypoxia;
    if (spO2 >= 85) return OxygenStatus.moderateHypoxia;
    return OxygenStatus.severeHypoxia;
  }

  List<HRVAnalysis> _generateHrvAnalysis(double rmssd, double sdnn, double pnn50) {
    return [
      HRVAnalysis(value: rmssd, name: 'RMSSD', unit: 'ms', min: 0, max: 100, referenceMin: 20, referenceMax: 80),
      HRVAnalysis(value: sdnn, name: 'SDNN', unit: 'ms', min: 0, max: 150, referenceMin: 30, referenceMax: 120),
      HRVAnalysis(value: pnn50, name: 'pNN50', unit: '%', min: 0, max: 50, referenceMin: 5, referenceMax: 40),
    ];
  }

  List<int> _generatePulseWave() {
    // Generate synthetic pulse wave for display
    List<int> wave = [];
    for (int i = 0; i < 100; i++) {
      double t = i / 100.0;
      int value = (80 + 40 * exp(-10 * pow(t - 0.15, 2)) + 20 * exp(-20 * pow(t - 0.35, 2))).round();
      wave.add(value.clamp(0, 255));
    }
    return wave;
  }

  int calculateVascularAge(double pp, double ai, double pwv, int sys, int dia) {
    double base = 30.0;
    double pp_contrib = (pp - 40) * 0.3;
    double ai_contrib = ai * 0.2;
    return (base + pp_contrib + ai_contrib).round().clamp(20, 90);
  }

  double calculateArterialStiffness(double pwv, double ai) {
    return (pwv * 0.6 + ai * 0.4).clamp(0, 100);
  }

  // ==========================================================================
  // DATA EXPORT
  // ==========================================================================
  Future<Map<String, dynamic>> exportData() async {
    return {
      'device': _connectedDevice?.platformName ?? 'Unknown',
      'lastSync': _lastSync?.toIso8601String(),
      'battery': _batteryLevel,
      'signal': _signalStrength,
    };
  }

  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    _hrController.close();
    _bpController.close();
    _o2Controller.close();
    _fallController.close();
    _connectionController.close();
  }
}
