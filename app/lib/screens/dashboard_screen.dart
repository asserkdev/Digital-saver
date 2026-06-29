import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_service.dart';
import '../services/health_analysis_service.dart';
import '../models/health_models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, ble, _) {
        final score = ble.isConnected ? ble.healthScore : 0;
        final alerts = ble.isConnected
            ? HealthAnalysisService.healthAlerts(
                hr: ble.heartRate,
                bp: ble.bloodPressure,
                o2: ble.oxygen,
              )
            : <String>[];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1e3a5f),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1e3a5f), Color(0xFF2563eb)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            ble.isConnected
                                ? (ble.demoMode ? 'Demo Mode' : 'Watch Connected')
                                : 'No Device',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _HealthScoreRing(score: score),
                        ],
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'Digital Saver',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                actions: [
                  _ConnectionButton(ble: ble),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (alerts.isNotEmpty) ...[
                      _AlertBanner(alerts: alerts),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Vitals',
                      style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,
                        color: Color(0xFF1e3a5f),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _VitalCard(
                          icon: Icons.favorite,
                          color: const Color(0xFFEF4444),
                          title: 'Heart Rate',
                          value: ble.isConnected && ble.heartRate.bpm > 0
                              ? '${ble.heartRate.bpm}'
                              : '--',
                          unit: 'BPM',
                          subtitle: ble.isConnected
                              ? HealthAnalysisService.heartRateZone(ble.heartRate.bpm)
                              : 'No data',
                        ),
                        _VitalCard(
                          icon: Icons.water_drop,
                          color: const Color(0xFF2563eb),
                          title: 'Blood Pressure',
                          value: ble.isConnected && ble.bloodPressure.systolic > 0
                              ? '${ble.bloodPressure.systolic}/${ble.bloodPressure.diastolic}'
                              : '--/--',
                          unit: 'mmHg',
                          subtitle: ble.isConnected ? ble.bloodPressure.category : 'No data',
                        ),
                        _VitalCard(
                          icon: Icons.air,
                          color: const Color(0xFF22C55E),
                          title: 'Blood Oxygen',
                          value: ble.isConnected && ble.oxygen.spO2 > 0
                              ? '${ble.oxygen.spO2}'
                              : '--',
                          unit: '%',
                          subtitle: ble.isConnected ? ble.oxygen.spO2Status : 'No data',
                        ),
                        _VitalCard(
                          icon: Icons.directions_run,
                          color: const Color(0xFFF59E0B),
                          title: 'Steps',
                          value: ble.isConnected
                              ? '${ble.activity.steps}'
                              : '--',
                          unit: 'steps',
                          subtitle: ble.isConnected
                              ? '${(ble.activity.progress * 100).round()}% of goal'
                              : 'No data',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (ble.isConnected) ...[
                      const Text(
                        'Quick Insights',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3a5f),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InsightCard(
                        icon: Icons.psychology,
                        color: const Color(0xFF7c3aed),
                        title: 'Stress Index',
                        value:
                            '${HealthAnalysisService.stressIndex(ble.heartRate).round()}',
                        label: _stressLabel(
                            HealthAnalysisService.stressIndex(ble.heartRate)),
                      ),
                      const SizedBox(height: 12),
                      _InsightCard(
                        icon: Icons.monitor_heart,
                        color: const Color(0xFFEF4444),
                        title: 'HRV (RMSSD)',
                        value: '${ble.heartRate.hrv} ms',
                        label: ble.heartRate.hrv > 30 ? 'Good recovery' : 'Low — rest needed',
                      ),
                    ],
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _stressLabel(double stress) {
    if (stress < 30) return 'Relaxed';
    if (stress < 60) return 'Moderate';
    return 'High Stress';
  }
}

class _HealthScoreRing extends StatelessWidget {
  final int score;
  const _HealthScoreRing({required this.score});

  Color get _color {
    if (score >= 80) return const Color(0xFF22C55E);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(_color),
              ),
              Text(
                '$score',
                style: TextStyle(
                  color: _color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Health Score',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  final BleService ble;
  const _ConnectionButton({required this.ble});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        ble.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
        color: ble.isConnected ? Colors.greenAccent : Colors.white,
      ),
      onSelected: (val) {
        if (val == 'scan') ble.startScan();
        if (val == 'demo') ble.enableDemoMode();
        if (val == 'disconnect') ble.disconnect();
      },
      itemBuilder: (_) => [
        if (!ble.isConnected) ...[
          const PopupMenuItem(value: 'scan', child: Text('Scan for Watch')),
          const PopupMenuItem(value: 'demo', child: Text('Demo Mode')),
        ] else
          const PopupMenuItem(value: 'disconnect', child: Text('Disconnect')),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final List<String> alerts;
  const _AlertBanner({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'Health Alerts',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alerts.map(
            (a) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('• $a', style: const TextStyle(color: Color(0xFF991B1B))),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value, unit, subtitle;
  const _VitalCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value, label;
  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
