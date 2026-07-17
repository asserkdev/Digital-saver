import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// User profile data stored locally
class CambricUserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? metadata;

  CambricUserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
    this.lastLogin,
    this.metadata,
  });

  factory CambricUserProfile.fromJson(Map<String, dynamic> json) {
    return CambricUserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt?.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
  };
}

// Auth Provider - uses local storage + simulated auth
class AuthProvider extends ChangeNotifier {
  CambricUserProfile? _profile;
  bool _loading = true;
  String? _error;

  CambricUserProfile? get profile => _profile;
  bool get isAuthenticated => _profile != null;
  bool get loading => _loading;
  String? get error => _error;

  AuthProvider() {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    _loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('cambric_session');
      
      if (sessionJson != null) {
        final data = jsonDecode(sessionJson);
        _profile = CambricUserProfile.fromJson(data);
      }
    } catch (e) {
      // Ignore errors
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _error = 'Please enter email and password';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create session from email (simulated auth)
      final userId = email.hashCode.toString();
      _profile = CambricUserProfile(
        id: userId,
        email: email,
        displayName: email.split('@').first,
        lastLogin: DateTime.now(),
      );

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cambric_session', jsonEncode(_profile!.toJson()));

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    if (email.isEmpty || password.isEmpty) {
      _error = 'Please enter email and password';
      notifyListeners();
      return false;
    }
    
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create new account (simulated)
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      _profile = CambricUserProfile(
        id: userId,
        email: email,
        displayName: displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cambric_session', jsonEncode(_profile!.toJson()));

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    // For demo - simulate Google sign in
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    
    _profile = CambricUserProfile(
      id: 'google_user',
      email: 'user@gmail.com',
      displayName: 'Google User',
      lastLogin: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cambric_session', jsonEncode(_profile!.toJson()));

    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cambric_session');

    _profile = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile({String? displayName}) async {
    if (_profile == null) return;

    _profile = CambricUserProfile(
      id: _profile!.id,
      email: _profile!.email,
      displayName: displayName ?? _profile!.displayName,
      avatarUrl: _profile!.avatarUrl,
      createdAt: _profile!.createdAt,
      lastLogin: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cambric_session', jsonEncode(_profile!.toJson()));

    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // Simulated - in real app would send email
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
