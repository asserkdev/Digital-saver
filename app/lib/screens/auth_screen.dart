import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cambric_auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthScreen({super.key, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _currentTab = 0; // 0 = Sign In, 1 = Sign Up

  // Sign In
  final _signInEmail = TextEditingController();
  final _signInPassword = TextEditingController();
  final _signInFormKey = GlobalKey<FormState>();

  // Sign Up
  final _signUpName = TextEditingController();
  final _signUpEmail = TextEditingController();
  final _signUpPassword = TextEditingController();
  final _signUpConfirm = TextEditingController();
  final _signUpFormKey = GlobalKey<FormState>();

  // Local state for errors and loading
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _signInEmail.dispose();
    _signInPassword.dispose();
    _signUpName.dispose();
    _signUpEmail.dispose();
    _signUpPassword.dispose();
    _signUpConfirm.dispose();
    super.dispose();
  }

  void _setError(String msg) {
    setState(() => _error = msg);
  }

  void _clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  void _setLoading(bool val) {
    setState(() => _isLoading = val);
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    _clearError();
    _setLoading(true);

    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithEmail(
      _signInEmail.text.trim(),
      _signInPassword.text,
    );

    _setLoading(false);

    if (success && mounted) {
      widget.onAuthSuccess?.call();
      Navigator.pop(context);
    } else if (auth.error != null) {
      _setError(auth.error!);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    _clearError();
    _setLoading(true);

    final auth = context.read<AuthProvider>();
    final success = await auth.signUpWithEmail(
      _signUpEmail.text.trim(),
      _signUpPassword.text,
      displayName: _signUpName.text.trim(),
    );

    _setLoading(false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Check email to confirm.'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      widget.onAuthSuccess?.call();
      Navigator.pop(context);
    } else if (auth.error != null) {
      _setError(auth.error!);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _clearError();
    _setLoading(true);

    final auth = context.read<AuthProvider>();
    await auth.signInWithGoogle();

    // Don't set loading false here - OAuth will update state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF2563EB), Color(0xFF7C3AED)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 30),
              _buildTitle(),
              const SizedBox(height: 50),
              Expanded(child: _buildWhiteCard()),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: const Icon(Icons.favorite, color: Color(0xFF2563EB), size: 50),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text('CAMBRIC', style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6), letterSpacing: 4,
        )).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text('Digital Saver', style: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
        )).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 8),
        Text('Health Monitoring System', style: GoogleFonts.inter(
          fontSize: 16, color: Colors.white.withOpacity(0.7),
        )).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildWhiteCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 24),
          Expanded(child: _currentTab == 0 ? _buildSignInForm() : _buildSignUpForm()),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton('Sign In', 0)),
          Expanded(child: _tabButton('Sign Up', 1)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A5F))),
            const SizedBox(height: 8),
            Text('Sign in to your Cambric account', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            const SizedBox(height: 32),
            TextFormField(
              controller: _signInEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Email', Icons.email_outlined),
              validator: (v) => v == null || v.trim().isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _signInPassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration('Password', Icons.lock_outlined),
              validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
              onFieldSubmitted: (_) => _handleSignIn(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showResetDialog(),
                child: Text('Forgot password?', style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontWeight: FontWeight.w500)),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _errorBox(_error!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Text('Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 28),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create account', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A5F))),
            const SizedBox(height: 8),
            Text('Join Cambric health ecosystem', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            const SizedBox(height: 32),
            TextFormField(
              controller: _signUpName,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Full Name', Icons.person_outlined),
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _signUpEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Email', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _signUpPassword,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Password', Icons.lock_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _signUpConfirm,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration('Confirm Password', Icons.lock_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != _signUpPassword.text) return 'Passwords do not match';
                return null;
              },
              onFieldSubmitted: (_) => _handleSignUp(),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              _errorBox(_error!),
              const SizedBox(height: 16),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("By signing up, you agree to Cambric's Terms of Service and Privacy Policy", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)), textAlign: TextAlign.center),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Text('Create Account', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 28),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: GoogleFonts.inter(color: const Color(0xFFDC2626), fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13))),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFFDB4437)),
        label: Text(_currentTab == 0 ? 'Continue with Google' : 'Sign up with Google', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDB4437),
          side: BorderSide(color: const Color(0xFFDB4437).withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showResetDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              await context.read<AuthProvider>().resetPassword(email);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Color(0xFF22C55E)),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
