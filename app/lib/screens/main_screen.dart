import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/ble_service.dart';
import 'package:digital_saver/i18n/app_localizations.dart';
import 'package:digital_saver/screens/dashboard_screen.dart';
import 'package:digital_saver/screens/heart_screen.dart';
import 'package:digital_saver/screens/bp_screen.dart';
import 'package:digital_saver/screens/activity_screen.dart';
import 'package:digital_saver/screens/sleep_screen.dart';
import 'package:digital_saver/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HeartScreen(),
    const BpScreen(),
    const ActivityScreen(),
    const SleepScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ble = context.watch<BleService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Connection Status Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: _ConnectionBar(
                isConnected: ble.isConnected,
                deviceName: ble.connectedDevice?.platformName ?? 'Digital Saver Watch',
                battery: ble.batteryLevel,
                lastSync: ble.lastSync,
                onTap: () => _showConnectionSheet(context),
              ),
            ),
            // Screen Content
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        labels: [t.navDashboard, t.navHeart, t.navBP, t.navActivity, t.navSleep],
      ),
    );
  }

  void _showConnectionSheet(BuildContext context) {
    final ble = context.read<BleService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Icon(Icons.watch, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(ble.isConnected ? 'Watch Connected' : 'Connect Watch', style: AppTheme.headlineSmall),
            const SizedBox(height: 24),
            if (ble.isConnected) ...[
              _InfoRow('Device', ble.connectedDevice?.platformName ?? 'Unknown'),
              _InfoRow('Battery', '${ble.batteryLevel}%'),
              _InfoRow('Signal', '${ble.signalStrength}%'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () { ble.disconnect(); Navigator.pop(ctx); },
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ] else ...[
              if (ble.isScanning)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () => ble.startScan(),
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Scan for Devices'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConnectionBar extends StatelessWidget {
  final bool isConnected;
  final String deviceName;
  final int battery;
  final DateTime? lastSync;
  final VoidCallback onTap;

  const _ConnectionBar({
    required this.isConnected,
    required this.deviceName,
    required this.battery,
    this.lastSync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isConnected ? AppTheme.healthyGreen : Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConnected ? Icons.watch_rounded : Icons.watch_off_rounded,
                color: isConnected ? AppTheme.healthyGreen : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deviceName, style: AppTheme.titleMedium),
                  Text(
                    isConnected
                        ? (lastSync != null ? 'Synced ${_timeAgo(lastSync!)}' : 'Connected')
                        : 'Tap to connect',
                    style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isConnected) ...[
              Icon(_batteryIcon(battery), color: _batteryColor(battery), size: 20),
              const SizedBox(width: 8),
              Text('$battery%', style: AppTheme.labelSmall.copyWith(color: _batteryColor(battery))),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level > 80) return Icons.battery_full_rounded;
    if (level > 50) return Icons.battery_5_bar_rounded;
    if (level > 20) return Icons.battery_3_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }

  Color _batteryColor(int level) {
    if (level > 50) return AppTheme.healthyGreen;
    if (level > 20) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> labels;

  const _BottomNav({required this.currentIndex, required this.onTap, required this.labels});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icons = [Icons.dashboard_rounded, Icons.favorite_rounded, Icons.water_drop_rounded, Icons.directions_run_rounded, Icons.bedtime_rounded];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) => _NavItem(
              icon: icons[i],
              label: labels[i],
              isSelected: currentIndex == i,
              onTap: () => onTap(i),
            )),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? AppTheme.primaryColor : (isDark ? Colors.grey[500] : Colors.grey[400]);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: color)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(value, style: AppTheme.titleMedium),
        ],
      ),
    );
  }
}
