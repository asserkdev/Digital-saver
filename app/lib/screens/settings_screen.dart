import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Profile', style: AppTheme.titleLarge.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Configure your health profile', style: AppTheme.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Appearance
          _SectionTitle('Appearance'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.dark_mode_rounded, title: 'Dark Mode', trailing: Switch(value: storage.isDarkMode, onChanged: storage.setDarkMode, activeColor: AppTheme.primaryColor)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.language_rounded, title: 'Language', subtitle: _getLanguageName(storage.locale.languageCode), onTap: () => _showLanguageDialog(context, storage), trailing: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notifications
          _SectionTitle('Notifications'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.notifications_rounded, title: 'Notifications', trailing: Switch(value: storage.notificationsEnabled, onChanged: storage.setNotificationsEnabled, activeColor: AppTheme.primaryColor)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.favorite_rounded, title: 'Heart Rate Alerts', subtitle: 'Alert when abnormal HR detected', trailing: const Icon(Icons.chevron_right)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.water_drop_rounded, title: 'BP Alerts', subtitle: 'Alert when BP is elevated', trailing: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Thresholds
          _SectionTitle('Health Thresholds'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _ThresholdSlider(title: 'Heart Rate Alert', value: storage.heartRateThreshold.toDouble(), min: 80, max: 140, unit: 'BPM', onChanged: (v) => storage.setHeartRateThreshold(v.toInt())),
                const SizedBox(height: 20),
                _ThresholdSlider(title: 'Systolic BP Alert', value: storage.systolicThreshold.toDouble(), min: 120, max: 180, unit: 'mmHg', onChanged: (v) => storage.setSystolicThreshold(v.toInt())),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Emergency Contacts
          _SectionTitle('Emergency Contacts'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.contacts_rounded, title: 'Manage Contacts', subtitle: '${storage.contacts.length} contacts', trailing: const Icon(Icons.chevron_right)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.local_hospital_rounded, title: 'Emergency Services', subtitle: 'Call 123 (Egypt)', trailing: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About
          _SectionTitle('About'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _SettingsTile(icon: Icons.info_rounded, title: 'About', subtitle: 'Version 2.0.0', onTap: () => _showAboutDialog(context)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy', trailing: const Icon(Icons.chevron_right)),
                const Divider(height: 1),
                _SettingsTile(icon: Icons.description_rounded, title: 'Terms of Service', trailing: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final names = {'en': 'English', 'ar': 'العربية', 'es': 'Español', 'fr': 'Français', 'de': 'Deutsch', 'zh': '中文', 'ja': '日本語', 'ru': 'Русский'};
    return names[code] ?? code;
  }

  void _showLanguageDialog(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(ctx).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Select Language', style: AppTheme.headlineSmall),
            const SizedBox(height: 16),
            ...['en', 'ar', 'es', 'fr', 'de', 'zh', 'ja', 'ru'].map((code) => ListTile(
              title: Text(_getLanguageName(code)),
              leading: Radio(value: code, groupValue: storage.locale.languageCode, onChanged: (v) { if (v != null) { storage.setLocale(Locale(v)); Navigator.pop(ctx); } }),
              onTap: () { storage.setLocale(Locale(code)); Navigator.pop(ctx); },
            )),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Digital Saver',
      applicationVersion: '2.0.0',
      applicationIcon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.favorite, color: AppTheme.primaryColor, size: 48)),
      children: [const Text('Professional health monitoring app with emergency alerts.')],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title, style: AppTheme.titleMedium);
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  String? subtitle;
  Widget? trailing;
  VoidCallback? onTap;

  _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppTheme.primaryColor, size: 20)),
      title: Text(title, style: AppTheme.titleMedium),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTheme.bodySmall) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  final String title;
  final double value, min, max;
  final String unit;
  final ValueChanged<double> onChanged;

  const _ThresholdSlider({required this.title, required this.value, required this.min, required this.max, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('${value.toInt()} $unit', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), onChanged: onChanged, activeColor: AppTheme.primaryColor),
      ],
    );
  }
}
