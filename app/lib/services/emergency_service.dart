import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:digital_saver/models/health_models.dart';

// ============================================================================
// EMERGENCY SERVICE - AUTOMATIC ALERTS WITH GPS & SMS
// ============================================================================
class EmergencyService extends ChangeNotifier {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // State
  bool _emergencyActive = false;
  Position? _lastLocation;
  Timer? _alertTimer;
  int _alertCount = 0;
  static const int _maxAlerts = 3;
  
  List<HealthAlert> _alertHistory = [];
  List<EmergencyContact> _contacts = [];
  
  // Callbacks
  Function(HealthAlert)? onAlertTriggered;
  Function()? onEmergencyCancelled;

  // Getters
  bool get emergencyActive => _emergencyActive;
  Position? get lastLocation => _lastLocation;
  List<HealthAlert> get alertHistory => List.unmodifiable(_alertHistory);
  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
  }

  // ==========================================================================
  // PERMISSIONS
  // ==========================================================================
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission != LocationPermission.denied &&
           permission != LocationPermission.deniedForever;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkPermissions();
      if (!hasPermission) return null;
      
      _lastLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _lastLocation;
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  // ==========================================================================
  // EMERGENCY CONTACTS MANAGEMENT
  // ==========================================================================
  void addContact(EmergencyContact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void updateContact(int index, EmergencyContact contact) {
    if (index >= 0 && index < _contacts.length) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  void removeContact(int index) {
    if (index >= 0 && index < _contacts.length) {
      _contacts.removeAt(index);
      notifyListeners();
    }
  }

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere((c) => c.isPrimary);
    } catch (e) {
      return _contacts.isNotEmpty ? _contacts.first : null;
    }
  }

  // ==========================================================================
  // EMERGENCY TRIGGER - AUTOMATIC OR MANUAL
  // ==========================================================================
  Future<void> triggerEmergency({
    required AlertType type,
    required AlertSeverity severity,
    HealthAlert? existingAlert,
  }) async {
    if (_emergencyActive) return;
    
    _emergencyActive = true;
    _alertCount = 0;
    notifyListeners();

    try {
      // Get location
      Position? location = await getCurrentLocation();
      
      // Build emergency message
      final String message = _buildEmergencyMessage(
        type: type,
        severity: severity,
        location: location,
        alert: existingAlert,
      );
      
      // Create alert
      HealthAlert alert = HealthAlert(
        id: _generateId(),
        type: type,
        severity: severity,
        value: existingAlert?.value ?? 0,
        message: message,
        timestamp: DateTime.now(),
        latitude: location?.latitude,
        longitude: location?.longitude,
        acknowledged: false,
        actions: _getDefaultActions(type),
      );
      
      // Show notification
      await _showEmergencyNotification(alert);
      
      // Send to contacts
      for (final contact in _contacts) {
        if (contact.smsEnabled) {
          await _sendSms(contact.phone, message);
        }
      }
      
      // Start auto-dial timer
      _startAutoDialTimer();

      _alertHistory.insert(0, alert);
      if (_alertHistory.length > 50) _alertHistory.removeLast();
      
      onAlertTriggered?.call(alert);
      
    } catch (e) {
      debugPrint('Emergency trigger error: $e');
      _emergencyActive = false;
      notifyListeners();
    }
  }

  void _startAutoDialTimer() {
    _alertTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      _alertCount++;
      
      // Auto-dial after 3 attempts
      if (_alertCount >= _maxAlerts) {
        final primary = primaryContact;
        if (primary != null && primary.callEnabled) {
          await callNumber(primary.phone);
        }
        
        // Auto-call emergency services
        await callEmergencyServices();
        
        _emergencyActive = false;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  // ==========================================================================
  // SMS & CALL
  // ==========================================================================
  Future<void> _sendSms(String phone, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('SMS error: $e');
    }
  }

  Future<void> callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Call error: $e');
    }
  }

  Future<void> callEmergencyServices() async {
    // Try local emergency number based on region
    const numbers = ['123', '112', '911', '999'];
    for (final number in numbers) {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        break;
      }
    }
  }

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================
  Future<void> _showEmergencyNotification(HealthAlert alert) async {
    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Critical health emergency notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    await _notifications.show(
      0,
      _getAlertTitle(alert.type),
      _getAlertBody(alert.type),
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  Future<void> cancelNotification() async {
    await _notifications.cancel(0);
  }

  // ==========================================================================
  // CANCEL EMERGENCY
  // ==========================================================================
  void cancelEmergency() {
    _alertTimer?.cancel();
    _alertCount = 0;
    _emergencyActive = false;
    cancelNotification();
    notifyListeners();
    onEmergencyCancelled?.call();
  }

  void acknowledgeAlert(String alertId) {
    final index = _alertHistory.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alertHistory[index] = HealthAlert(
        id: _alertHistory[index].id,
        type: _alertHistory[index].type,
        severity: _alertHistory[index].severity,
        value: _alertHistory[index].value,
        message: _alertHistory[index].message,
        timestamp: _alertHistory[index].timestamp,
        latitude: _alertHistory[index].latitude,
        longitude: _alertHistory[index].longitude,
        acknowledged: true,
        actions: _alertHistory[index].actions,
      );
      notifyListeners();
    }
  }

  // ==========================================================================
  // HELPER FUNCTIONS
  // ==========================================================================
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }

  String _buildEmergencyMessage({
    required AlertType type,
    required AlertSeverity severity,
    Position? location,
    HealthAlert? alert,
  }) {
    final timestamp = DateTime.now();
    final timeStr = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    final dateStr = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    
    final conditionEmoji = _getConditionEmoji(type);
    final conditionText = _getConditionText(type);
    
    final severityText = _getSeverityText(severity);
    
    final buffer = StringBuffer();
    buffer.writeln('🚨 DIGITAL SAVER EMERGENCY 🚨');
    buffer.writeln();
    buffer.writeln('$severityText $conditionEmoji');
    buffer.writeln('$conditionText');
    buffer.writeln();
    buffer.writeln('📅 Date: $dateStr');
    buffer.writeln('⏰ Time: $timeStr');
    
    if (alert?.value != null && alert!.value > 0) {
      buffer.writeln('📊 Value: ${alert.value}');
    }
    
    if (location != null) {
      buffer.writeln();
      buffer.writeln('📍 Location:');
      buffer.writeln('https://maps.google.com/?q=${location.latitude},${location.longitude}');
      buffer.writeln('Lat: ${location.latitude.toStringAsFixed(6)}');
      buffer.writeln('Lng: ${location.longitude.toStringAsFixed(6)}');
    } else {
      buffer.writeln();
      buffer.writeln('⚠️ Location unavailable');
    }
    
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━');
    buffer.writeln('Please check on the wearer IMMEDIATELY.');
    buffer.writeln();
    buffer.writeln('Emergency: 123 (Egypt)');
    buffer.writeln('Europe: 112 | US: 911');
    buffer.writeln('━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('Sent by Digital Saver App');

    return buffer.toString();
  }

  String _getConditionEmoji(AlertType type) {
    switch (type) {
      case AlertType.fall: return '🫥';
      case AlertType.afib: 
      case AlertType.arrhythmia: return '❤️';
      case AlertType.tachycardia: return '💓';
      case AlertType.bradycardia: return '💔';
      case AlertType.hypertension: return '🩸';
      case AlertType.hypotension: return '🩸';
      case AlertType.lowOxygen: return '🫁';
      case AlertType.manual: return '🆘';
    }
  }

  String _getConditionText(AlertType type) {
    switch (type) {
      case AlertType.fall: return 'FALL DETECTED - Possible loss of consciousness';
      case AlertType.afib: return 'ATRIAL FIBRILLATION DETECTED';
      case AlertType.arrhythmia: return 'IRREGULAR HEARTBEAT DETECTED';
      case AlertType.tachycardia: return 'FAST HEART RATE DETECTED';
      case AlertType.bradycardia: return 'SLOW HEART RATE DETECTED';
      case AlertType.hypertension: return 'HIGH BLOOD PRESSURE DETECTED';
      case AlertType.hypotension: return 'LOW BLOOD PRESSURE DETECTED';
      case AlertType.lowOxygen: return 'LOW OXYGEN LEVEL DETECTED';
      case AlertType.manual: return 'MANUAL EMERGENCY ALERT';
    }
  }

  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.emergency: return '⚠️⚠️⚠️ IMMEDIATE ACTION REQUIRED ⚠️⚠️⚠️';
      case AlertSeverity.critical: return '⚠️⚠️ CRITICAL ALERT ⚠️⚠️';
      case AlertSeverity.warning: return '⚡ WARNING ⚡';
      case AlertSeverity.info: return 'ℹ️ INFO ℹ️';
    }
  }

  String _getAlertTitle(AlertType type) {
    switch (type) {
      case AlertType.fall: return '🚨 Fall Detected!';
      case AlertType.afib: return '❤️ AFib Detected!';
      case AlertType.arrhythmia: return '❤️ Arrhythmia!';
      case AlertType.tachycardia: return '💓 Fast Heart Rate!';
      case AlertType.bradycardia: return '💔 Slow Heart Rate!';
      case AlertType.hypertension: return '🩸 High BP!';
      case AlertType.hypotension: return '🩸 Low BP!';
      case AlertType.lowOxygen: return '🫁 Low Oxygen!';
      case AlertType.manual: return '🆘 Emergency Alert!';
    }
  }

  String _getAlertBody(AlertType type) {
    switch (type) {
      case AlertType.fall: return 'Possible loss of consciousness. Emergency contacts notified.';
      case AlertType.afib: return 'Atrial fibrillation detected. Seek medical attention.';
      case AlertType.arrhythmia: return 'Irregular heartbeat pattern detected.';
      case AlertType.tachycardia: return 'Heart rate above normal range.';
      case AlertType.bradycardia: return 'Heart rate below normal range.';
      case AlertType.hypertension: return 'Blood pressure is critically high.';
      case AlertType.hypotension: return 'Blood pressure is critically low.';
      case AlertType.lowOxygen: return 'Oxygen saturation below safe levels.';
      case AlertType.manual: return 'Emergency alert sent to contacts.';
    }
  }

  List<String> _getDefaultActions(AlertType type) {
    return [
      'Emergency contacts notified',
      'Location shared',
      'Call emergency services',
    ];
  }

  void dispose() {
    _alertTimer?.cancel();
    _notifications.cancelAll();
    super.dispose();
  }
}
