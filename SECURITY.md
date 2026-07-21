# 🔒 Security Documentation

## Cambric Digital Saver Security

**© 2026 Cambric. All Rights Reserved.**

---

## Table of Contents

1. [Security Architecture](#security-architecture)
2. [Authentication](#authentication)
3. [Data Protection](#data-protection)
4. [Network Security](#network-security)
5. [Device Security](#device-security)
6. [Error Handling](#error-handling)
7. [Privacy](#privacy)
8. [Compliance](#compliance)

---

## Security Architecture

### Overview

The Digital Saver ecosystem implements a multi-layered security approach:

```
┌─────────────────────────────────────────────────────────────┐
│                     SECURITY LAYERS                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   APP UI    │  │   NETWORK   │  │   CLOUD     │        │
│  │   Security  │  │   Security  │  │   Security  │        │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤        │
│  │ - Biometrics│  │ - TLS 1.3   │  │ - Row Level │        │
│  │ - Session   │  │ - Certificate│  │   Security  │        │
│  │   Timeout   │  │   Pinning   │  │ - Encryption│        │
│  │ - Input     │  │ - API Keys  │  │ - Audit Log │        │
│  │   Validation│  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Security Principles

| Principle | Implementation |
|-----------|----------------|
| **Least Privilege** | Users can only access their own data |
| **Defense in Depth** | Multiple security layers |
| **Secure by Default** | Security enabled from start |
| **Fail Securely** | Errors default to deny |
| **Privacy First** | Minimize data collection |

---

## Authentication

### User Authentication

The app uses **Supabase Auth** with the following security measures:

#### Password Requirements

```dart
// Password policy
const PasswordPolicy = {
  minLength: 8,           // Minimum 8 characters
  requireUppercase: true, // At least one uppercase
  requireLowercase: true, // At least one lowercase
  requireNumbers: true,    // At least one number
  requireSpecialChars: false, // Optional special chars
  maxLength: 128,         // Maximum 128 characters
};
```

#### Session Management

```dart
class SessionManager {
  // Session timeout: 24 hours of inactivity
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Refresh token rotation enabled
  // Access token: 1 hour expiry
  // Refresh token: 7 days expiry
  
  // Secure session storage (encrypted)
  // Web: localStorage with encryption
  // Mobile: Keychain (iOS) / Keystore (Android)
}
```

#### Biometric Authentication

```dart
class BiometricService {
  // Optional second factor
  static const bool requireBiometric = false;
  
  // Supported methods:
  // - Fingerprint (Android/iOS)
  // - Face ID (iOS)
  // - Face Unlock (Android)
  
  Future<bool> authenticate() async {
    return await LocalAuth.authenticate(
      localizedReason: 'Authenticate to access Digital Saver',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false, // Allow fallback to PIN
      ),
    );
  }
}
```

---

## Data Protection

### Data Encryption

#### At Rest

| Data Type | Encryption | Method |
|-----------|------------|--------|
| Passwords | ✅ | bcrypt (Supabase) |
| Health Data | ✅ | AES-256 (Supabase) |
| Personal Info | ✅ | AES-256 (Supabase) |
| Session Tokens | ✅ | Encrypted storage |
| Local Cache | ⚠️ | Optional encryption |

#### In Transit

```
All data transmission uses TLS 1.3

┌─────────────────────────────────────────┐
│         TLS 1.3 Connection               │
├─────────────────────────────────────────┤
│                                          │
│   App ──────────────────────► Supabase   │
│        │                                │
│        │  Certificate Validation        │
│        │  (Supabase Certificate)         │
│        │                                │
│        │  Encrypted Payload              │
│        │  (AES-256-GCM)                 │
│        │                                │
│   App ◄──────────────────────► Supabase   │
│                                          │
└─────────────────────────────────────────┘
```

### Sensitive Data Handling

```dart
class DataProtectionService {
  // Never log sensitive data
  void safeLog(String message, {Map? data}) {
    // Remove sensitive fields before logging
    final safeData = _removeSensitiveData(data);
    _logger.info(message, safeData);
  }
  
  // Mask sensitive display data
  String maskPhoneNumber(String phone) {
    if (phone.length < 4) return '****';
    return '****${phone.substring(phone.length - 4)}';
  }
  
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '****';
    final name = parts[0];
    if (name.length < 2) return '****@${parts[1]}';
    return '${name[0]}****@${parts[1]}';
  }
  
  Map<String, dynamic> _removeSensitiveData(Map? data) {
    if (data == null) return {};
    
    const sensitiveFields = [
      'password', 'token', 'secret', 'apiKey',
      'creditCard', 'ssn', 'fullName',
    ];
    
    return Map.fromEntries(
      data.entries.where((e) => 
        !sensitiveFields.contains(e.key.toLowerCase())
      ),
    );
  }
}
```

---

## Network Security

### API Security

```dart
class ApiSecurity {
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  
  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Certificate pinning (production)
  static const bool enableCertificatePinning = true;
  
  // CORS configuration
  static const List<String> allowedOrigins = [
    'https://digitalsaver.example.com',
    'https://cambric.example.com',
  ];
}
```

### Error Response Security

```dart
// Never expose internal errors to users
class SecureErrorHandler {
  String handleError(dynamic error, {bool isDebug = false}) {
    if (isDebug) {
      // Log full error for debugging
      _logFullError(error);
      return error.toString();
    }
    
    // Generic error for production
    _logErrorHash(error); // Log hash for debugging
    
    switch (error.type) {
      case ErrorType.network:
        return 'Connection error. Please check your internet.';
      case ErrorType.auth:
        return 'Authentication failed. Please sign in again.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data.';
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred.';
    }
  }
}
```

---

## Device Security

### BLE Communication Security

```dart
class BleSecurity {
  // Bonding required for health data
  static const bool requireBonding = true;
  
  // Connection encryption
  static const bool requireEncryption = true;
  
  // MAC address randomization (Android)
  static const bool randomizeMac = true;
  
  // Secure pairing method
  static const SecurePairingMethod pairingMethod = 
    SecurePairingMethod.passkeyEntry;
}
```

### Watch Security Features

```
Onyx Smartwatch Security:
├── Encrypted firmware storage
├── Secure boot process
├── Debug port disabled in production
├── Unique device ID per watch
├── BLE bonding with app required
└── Remote wipe capability
```

---

## Error Handling

### Global Error Handler

```dart
class AppErrorHandler {
  // Catch all unhandled errors
  static void handleError(FlutterErrorDetails details) {
    // 1. Log error (with sanitized data)
    _logError(details);
    
    // 2. Report to analytics (non-blocking)
    _reportError(details);
    
    // 3. Show user-friendly message
    _showErrorMessage(details);
    
    // 4. Attempt recovery if possible
    _attemptRecovery(details);
  }
  
  // Async error handling
  static Future<void> handleAsyncError(Object error, StackTrace stack) async {
    final errorInfo = await _processError(error, stack);
    
    if (errorInfo.isCritical) {
      // Send immediate alert
      await _sendCriticalAlert(errorInfo);
    } else {
      // Queue for batch reporting
      await _queueErrorReport(errorInfo);
    }
  }
}
```

### Validation

```dart
class InputValidation {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ).hasMatch(email);
  }
  
  // Phone validation
  static bool isValidPhone(String phone) {
    // Accept international formats
    return RegExp(r'^\+?[1-9]\d{6,14}$').hasMatch(phone);
  }
  
  // Sanitize user input
  static String sanitize(String input) {
    return input
      .trim()
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('/', '&#x2F;');
  }
  
  // Length limits
  static const maxNameLength = 100;
  static const maxBioLength = 500;
  static const maxPhoneLength = 20;
}
```

---

## Privacy

### Data Collection

| Data Type | Collected | Purpose | Retention |
|-----------|-----------|---------|-----------|
| Email | ✅ | Account | Until deletion |
| Name | ✅ | Identification | Until deletion |
| Health Data | ✅ | Monitoring | 2 years |
| Location | ⚠️ Optional | Emergency | 30 days |
| Device Info | ✅ | Support | 1 year |
| Usage Analytics | ⚠️ Optional | Improvement | 1 year |

### User Rights

```
GDPR & Privacy Rights:
├── Right to Access     - View all your data
├── Right to Rectify    - Correct inaccurate data
├── Right to Erase      - Delete your account
├── Right to Portability - Export your data
├── Right to Object     - Opt out of processing
└── Right to Restrict   - Limit data use
```

### Privacy Features

```dart
class PrivacyService {
  // Anonymize data for analytics
  Future<void> enablePrivacyMode() async {
    // Remove personally identifiable info
    await analytics.setUserProperty('anonymous', true);
    
    // Disable usage tracking
    await analytics.setAnalyticsCollectionEnabled(false);
  }
  
  // Export all user data (GDPR compliance)
  Future<String> exportAllData(String userId) async {
    final healthData = await _getHealthData(userId);
    final profile = await _getProfile(userId);
    final settings = await _getSettings(userId);
    
    return jsonEncode({
      'export_date': DateTime.now().toIso8601String(),
      'health_data': healthData,
      'profile': profile,
      'settings': settings,
    });
  }
  
  // Delete all user data (GDPR compliance)
  Future<void> deleteAllData(String userId) async {
    await _deleteHealthData(userId);
    await _deleteProfile(userId);
    await _deleteSettings(userId);
    await _deleteAccount(userId);
  }
}
```

---

## Compliance

### Regulatory Compliance

| Regulation | Status | Notes |
|------------|--------|-------|
| GDPR | ✅ Compliant | EU data protection |
| HIPAA | ⚠️ Partial | Health data handling |
| COPPA | ✅ Compliant | No data from under 13 |
| CCPA | ✅ Compliant | California privacy |
| PDPL | ✅ Compliant | Egypt data protection |

### Security Certifications (Target)

| Certification | Target Date | Status |
|--------------|-------------|--------|
| ISO 27001 | Q1 2027 | Planned |
| SOC 2 Type II | Q2 2027 | Planned |
| CE Mark | Q4 2026 | In Progress |
| FCC | Q4 2026 | In Progress |
| RoHS | Q4 2026 | In Progress |

---

## Reporting Security Issues

If you discover a security vulnerability, please report it to:

**Email:** security@cambric.example.com

**Response Timeline:**
- Acknowledgment: 24 hours
- Initial Assessment: 3 days
- Fix Target: 30 days (critical), 90 days (medium/low)

**Please include:**
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

---

**Version:** 1.0  
**Last Updated:** July 2026  
**Document Owner:** Cambric Security Team  
**© 2026 Cambric. All Rights Reserved.**
