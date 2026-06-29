import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_service.dart';
import '../services/health_analysis_service.dart';

class BpScreen extends StatelessWidget {
  const BpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, ble, _) {
        final bp = ble.bloodPressure;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          appBar: AppBar(
            title: const Text('Blood Pressure', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1e3a5f),
            elevation: 0,
          ),
          body: ble.isConnected
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _BpHero(bp: bp),
                      const SizedBox(height: 16),
                      _VascularCard(bp: bp),
                      const SizedBox(height: 16),
                      _BpCategoryChart(current: bp.category),
                      const SizedBox(height: 16),
                      _BpAdvancedGrid(bp: bp),
                      const SizedBox(height: 100),
                    ],
                  ),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Connect your watch to view BP data',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _BpHero extends StatelessWidget {
  final bp;
  const _BpHero({required this.bp});

  Color get _catColor {
    switch (bp.category) {
      case 'Normal': return const Color(0xFF22C55E);
      case 'Elevated': return const Color(0xFFF59E0B);
      case 'High Stage 1': return const Color(0xFFF97316);
      default: return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2563eb), const Color(0xFF1e3a5f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.water_drop, color: Colors.white, size: 36),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bp.systolic > 0 ? '${bp.systolic}' : '--',
                style: const TextStyle(
                  color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold, height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('/', style: TextStyle(color: Colors.white60, fontSize: 32)),
              ),
              Text(
                bp.diastolic > 0 ? '${bp.diastolic}' : '--',
                style: const TextStyle(
                  color: Colors.white70, fontSize: 48, fontWeight: FontWeight.bold, height: 1,
                ),
              ),
            ],
          ),
          const Text('mmHg  (Systolic / Diastolic)',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _catColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bp.category,
              style: TextStyle(color: _catColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _VascularCard extends StatelessWidget {
  final bp;
  const _VascularCard({required this.bp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vascular Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CircleStat(
                label: 'MAP',
                value: bp.map > 0 ? '${bp.map}' : '--',
                unit: 'mmHg',
                color: const Color(0xFF2563eb),
              ),
              _CircleStat(
                label: 'Pulse Press.',
                value: bp.pulsePressure > 0 ? '${bp.pulsePressure}' : '--',
                unit: 'mmHg',
                color: const Color(0xFF7c3aed),
              ),
              _CircleStat(
                label: 'Vasc. Age',
                value: bp.systolic > 0 ? '${bp.vascularAge}' : '--',
                unit: 'yrs',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleStat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _CircleStat({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
          ),
          child: Center(
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 6),
        Text(unit, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BpCategoryChart extends StatelessWidget {
  final String current;
  const _BpCategoryChart({required this.current});

  @override
  Widget build(BuildContext context) {
    final categories = HealthAnalysisService.bpCategoryInfo();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BP Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...categories.map((cat) {
            final isActive = cat['label'] == current;
            final color = Color(cat['color'] as int);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? color : Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    '${cat['systolic']} / ${cat['diastolic']}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_left, color: color, size: 18),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BpAdvancedGrid extends StatelessWidget {
  final bp;
  const _BpAdvancedGrid({required this.bp});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _InfoTile(
          label: 'Augmentation Index',
          value: bp.augmentationIndex > 0 ? '${bp.augmentationIndex.toStringAsFixed(0)}%' : '--',
          icon: Icons.show_chart,
          color: const Color(0xFF2563eb),
        ),
        _InfoTile(
          label: 'Pulse Wave Velocity',
          value: bp.pulseWaveVelocity > 0 ? '${bp.pulseWaveVelocity.toStringAsFixed(1)} m/s' : '--',
          icon: Icons.speed,
          color: const Color(0xFF7c3aed),
        ),
        _InfoTile(
          label: 'Confidence',
          value: bp.confidence > 0 ? '${bp.confidence}%' : '--',
          icon: Icons.verified,
          color: const Color(0xFF22C55E),
        ),
        _InfoTile(
          label: 'Resp. Rate',
          value: '--',
          icon: Icons.air,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _InfoTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10), maxLines: 2),
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
