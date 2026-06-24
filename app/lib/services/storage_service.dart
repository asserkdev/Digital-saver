import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:digital_saver/models/health_models.dart';

class StorageService extends ChangeNotifier {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  late Database _db;
  
  Locale _locale = const Locale('en');
  List<EmergencyContact> _emergencyContacts = [];
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  int _heartRateThreshold = 100;
  int _systolicThreshold = 140;
  String? _userId;
  String? _userName;
  int? _userAge;
  String? _userGender;

  Locale get locale => _locale;
  List<EmergencyContact> get contacts => _emergencyContacts;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get heartRateThreshold => _heartRateThreshold;
  int get systolicThreshold => _systolicThreshold;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _userId = _prefs.getString('userId') ?? const Uuid().v4();
    _userName = _prefs.getString('userName');
    _userAge = _prefs.getInt('userAge');
    _userGender = _prefs.getString('userGender');
    
    final localeCode = _prefs.getString('locale') ?? 'en';
    _locale = Locale(localeCode);
    _isDarkMode = _prefs.getBool('darkMode') ?? false;
    _notificationsEnabled = _prefs.getBool('notifications') ?? true;
    _heartRateThreshold = _prefs.getInt('hrThreshold') ?? 100;
    _systolicThreshold = _prefs.getInt('systolicThreshold') ?? 140;

    final contactsJson = _prefs.getString('emergencyContacts');
    if (contactsJson != null) {
      final List<dynamic> decoded = jsonDecode(contactsJson);
      _emergencyContacts = decoded.map((e) => EmergencyContact.fromJson(e)).toList();
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'digital_saver.db');
    
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE health_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          heart_rate INTEGER, sp_o2 INTEGER, systolic INTEGER, diastolic INTEGER,
          confidence REAL, status INTEGER, timestamp TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE alerts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alert_type INTEGER, severity INTEGER, latitude REAL, longitude REAL, timestamp TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE daily_stats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT, steps INTEGER, calories INTEGER, distance REAL,
          active_minutes INTEGER, sleep_hours REAL, avg_heart_rate INTEGER,
          avg_bp_sys INTEGER, avg_bp_dia INTEGER, health_score INTEGER
        )
      ''');
    });

    await _prefs.setString('userId', _userId!);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool('notifications', value);
    notifyListeners();
  }

  Future<void> setHeartRateThreshold(int value) async {
    _heartRateThreshold = value;
    await _prefs.setInt('hrThreshold', value);
    notifyListeners();
  }

  Future<void> setSystolicThreshold(int value) async {
    _systolicThreshold = value;
    await _prefs.setInt('systolicThreshold', value);
    notifyListeners();
  }

  Future<void> addContact(EmergencyContact contact) async {
    _emergencyContacts.add(contact);
    await _saveContacts();
    notifyListeners();
  }

  Future<void> removeContact(int index) async {
    if (index >= 0 && index < _emergencyContacts.length) {
      _emergencyContacts.removeAt(index);
      await _saveContacts();
      notifyListeners();
    }
  }

  Future<void> _saveContacts() async {
    final encoded = jsonEncode(_emergencyContacts.map((c) => c.toJson()).toList());
    await _prefs.setString('emergencyContacts', encoded);
  }

  Future<void> saveDailyStats({
    required DateTime date, required int steps, required int calories,
    required double distance, required int activeMinutes, required double sleepHours,
    required int avgHeartRate, required int avgBpSys, required int avgBpDia,
    required int healthScore,
  }) async {
    await _db.insert('daily_stats', {
      'date': date.toIso8601String().split('T')[0],
      'steps': steps, 'calories': calories, 'distance': distance,
      'active_minutes': activeMinutes, 'sleep_hours': sleepHours,
      'avg_heart_rate': avgHeartRate, 'avg_bp_sys': avgBpSys,
      'avg_bp_dia': avgBpDia, 'health_score': healthScore,
    });
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return await _db.query('daily_stats', where: 'date >= ?', whereArgs: [weekAgo.toIso8601String().split('T')[0]], orderBy: 'date ASC');
  }
}
