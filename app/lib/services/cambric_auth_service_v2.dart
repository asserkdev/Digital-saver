import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CambricAuth {
  // Use the Supabase instance that's already initialized in main.dart
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static Stream<AuthState> get authState => client.auth.onAuthStateChange;
}

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

  factory CambricUserProfile.fromUser(User user) {
    // Safety check - ensure user has an ID
    if (user.id.isEmpty) {
      throw Exception('User ID is empty');
    }
    return CambricUserProfile(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: user.createdAt.isNotEmpty ? DateTime.tryParse(user.createdAt) : null,
      lastLogin: DateTime.now(),
      metadata: user.userMetadata,
    );
  }

  factory CambricUserProfile.fromProfile(Map<String, dynamic> data) {
    // Safety check - ensure data has an ID
    final id = data['id'];
    if (id == null || (id is String && id.isEmpty)) {
      throw Exception('Profile data missing ID');
    }
    return CambricUserProfile(
      id: id,
      email: data['email'],
      displayName: data['display_name'],
      avatarUrl: data['avatar_url'],
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at']) : null,
      lastLogin: data['last_sync_at'] != null ? DateTime.tryParse(data['last_sync_at']) : null,
      metadata: data,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'last_login': lastLogin?.toIso8601String(),
  };
}

/// Simplified AuthProvider with reliable session handling
/// Uses standard Supabase Auth session management
class AuthProvider extends ChangeNotifier {
  SupabaseClient? _client;
  User? _user;
  CambricUserProfile? _profile;
  bool _loading = true; // Start true for initial check
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;
  bool _initialized = false;

  User? get user => _user;
  CambricUserProfile? get profile => _profile;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Wait for Supabase to be fully initialized
    // On web, this might take a moment after Supabase.initialize() returns
    int waitCount = 0;
    while (_client == null && waitCount < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        _client = Supabase.instance.client;
      } catch (e) {
        // Ignore errors, will retry
      }
      waitCount++;
    }
    
    if (_client == null) {
      await Future.delayed(const Duration(seconds: 1));
      _client = Supabase.instance.client;
    }
    
    if (_client == null) {
      _error = 'Failed to connect to server';
      _loading = false;
      notifyListeners();
      return;
    }

    // Check for existing session first
    _checkExistingSession();

    // Then listen for auth changes
    _authSubscription = _client!.auth.onAuthStateChange.listen(_handleAuthChange);
    
    // Fallback: mark as initialized after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!_initialized) {
        _initialized = true;
        _loading = false;
        notifyListeners();
      }
    });
  }

  void _checkExistingSession() {
    try {
      final session = _client!.auth.currentSession;
      if (session != null && session.user != null) {
        _user = session.user;
        _profile = CambricUserProfile.fromUser(_user!);
        // Verify this user belongs to Digital Saver by checking our database
        _verifyAndLoadProfile();
      } else {
        _initialized = true;
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      // Session check failed, that's OK
      _initialized = true;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _verifyAndLoadProfile() async {
    try {
      // Check if user exists in Digital Saver's database
      final result = await _client!
          .from('digital_saver_user_profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();
      
      if (result != null) {
        // User exists, load profile
        _profile = CambricUserProfile.fromProfile(result);
      }
      // If user doesn't exist yet, they'll have an empty profile
      // This is fine - they can use the app with basic auth
      
      _initialized = true;
      _loading = false;
      notifyListeners();
    } catch (e) {
      // Database check failed, but user IS authenticated via Supabase
      // Just continue without profile data
      _initialized = true;
      _loading = false;
      notifyListeners();
    }
  }

  void _handleAuthChange(AuthState data) {
    try {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            _user = session!.user;
            _profile = CambricUserProfile.fromUser(_user!);
            _error = null;
            _initialized = true;
            _loading = false;
            // Verify user belongs to Digital Saver
            _verifyAndLoadProfile();
          }
          break;

        case AuthChangeEvent.tokenRefreshed:
          if (session?.user != null) {
            _user = session!.user;
            _profile = CambricUserProfile.fromUser(_user!);
          }
          break;

        case AuthChangeEvent.signedOut:
          _user = null;
          _profile = null;
          break;

        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            _user = session!.user;
            _profile = CambricUserProfile.fromUser(_user!);
            _loadFullProfile();
          }
          break;

        case AuthChangeEvent.passwordRecovery:
          // Password recovery email was sent - no action needed
          break;

        case AuthChangeEvent.userDeleted:
          // User account was deleted - sign out
          _user = null;
          _profile = null;
          break;

        case AuthChangeEvent.mfaChallengeVerified:
          // MFA challenge completed - refresh user
          if (session?.user != null) {
            _user = session!.user;
            _profile = CambricUserProfile.fromUser(_user!);
          }
          break;
      }
    } catch (e) {
      // Ignore errors in auth state handler - prevents crashes
      _initialized = true;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFullProfile() async {
    if (_user == null) return;

    try {
      final result = await _client!
          .from('digital_saver_user_profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();

      if (result != null) {
        _profile = CambricUserProfile.fromProfile(result);
        notifyListeners();
      }
    } catch (e) {
      // Profile load failed, user still authenticated
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user != null) {
        _user = response.user;
        _profile = CambricUserProfile.fromUser(_user!);
        _loading = false;
        _initialized = true;
        notifyListeners();
        await _createUserProfile();
        return true;
      }

      _error = 'Sign up pending. Please check your email to confirm.';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      if (result.user != null) {
        _user = result.user;
        _profile = CambricUserProfile.fromUser(_user!);
        _loading = false;
        _initialized = true;
        _error = null;
        notifyListeners();
        // Load profile in background
        _loadFullProfile();
        return true;
      }

      _error = 'Sign in failed';
      _loading = false;
      notifyListeners();
      return false;
    } on TimeoutException {
      _error = 'Connection timed out. Please check your internet.';
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _parseError(e);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://cambric-software.github.io/Digital-saver/',
      );
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();

    try {
      await _client!.auth.signOut();
    } catch (e) {
      // Continue with local sign out
    }
    
    _user = null;
    _profile = null;
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? displayName,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_user == null) return false;

    try {
      final updates = <String, dynamic>{
        'id': _user!.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updates['display_name'] = displayName;
        await _client!.auth.updateUser(
          UserAttributes(data: {'display_name': displayName}),
        );
      }

      if (additionalData != null) {
        updates.addAll(additionalData);
      }

      await _client!.from('digital_saver_user_profiles').upsert(updates);

      if (displayName != null && _profile != null) {
        _profile = CambricUserProfile(
          id: _profile!.id,
          email: _profile!.email,
          displayName: displayName,
          avatarUrl: _profile!.avatarUrl,
          createdAt: _profile!.createdAt,
          lastLogin: _profile!.lastLogin,
          metadata: {...?_profile!.metadata, ...?additionalData},
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _client!.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://cambric-software.github.io/Digital-saver/',
      );
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserProfile() async {
    if (_user == null) return;

    try {
      await _client!.from('digital_saver_user_profiles').upsert({
        'id': _user!.id,
        'email': _user!.email,
        'display_name': _profile?.displayName ?? _user!.email?.split('@').first,
        'created_at': DateTime.now().toIso8601String(),
        'last_sync_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation failed, not critical
    }
  }

  String _parseError(dynamic e) {
    if (e is AuthException) {
      return e.message;
    }
    if (e is Exception) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return 'Invalid email or password';
      }
      if (msg.contains('email not confirmed')) {
        return 'Please confirm your email first';
      }
      if (msg.contains('user already registered')) {
        return 'This email is already registered';
      }
      if (msg.contains('weak password')) {
        return 'Password is too weak';
      }
    }
    return 'An error occurred. Please try again.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
