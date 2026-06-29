import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/ble_service.dart';
import '../services/health_analysis_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _ring = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleService>();
    final parts = ble.bloodPressure.split('/');
    final sys = parts.length == 2 ? double.tryParse(parts[0]) ?? 120 : 120.0;
    final dia = parts.length == 2 ? double.tryParse(parts[1]) ?? 80 : 80.0;
    final score = ble.isConnected
        ? HealthAnalysisService.calculateHealthScore(
            hr: ble.heartRate, spo2: ble.oxygen,
            sysBP: sys, diaBP: dia, hrv: ble.hrv)
        : 82;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _appBar(ble),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              if (!ble.isConnected) _ConnectBanner(ble: ble),
              if (ble.isConnected && ble.demoMode) _DemoBanner(),
              const SizedBox(height: 16),
              _ScoreCard(animation: _ring, score: score),
              const SizedBox(height: 16),
              _VitalsGrid(ble: ble),
              const SizedBox(height: 16),
              _AlertsCard(ble: ble),
              const SizedBox(height: 16),
              _TodaySummary(ble: ble),
              const SizedBox(height: 100),
            ])),
          ),
        ],
      ),
    );
  }

  SliverAppBar _appBar(BleService ble) => SliverAppBar(
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    pinned: true,
    title: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Digital Saver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
        Text('Health Monitor', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.normal)),
      ]),
    ]),
    actions: [
      GestureDetector(
        onTap: ble.isConnected ? ble.disconnect : ble.startScan,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ble.isConnected ? AppColors.success.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ble.isConnected ? AppColors.success : Colors.grey,
            )),
            const SizedBox(width: 6),
            Text(
              ble.isConnected ? (ble.demoMode ? 'Demo' : 'Live') : 'Offline',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: ble.isConnected ? AppColors.success : Colors.grey),
            ),
          ]),
        ),
      ),
    ],
  );
}

class _ConnectBanner extends StatelessWidget {
  final BleService ble;
  const _ConnectBanner({required this.ble});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: AppColors.gradientPrimary,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.coloredCard(AppColors.primary),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.watch_outlined, color: Colors.white, size: 22),
        SizedBox(width: 10),
        Text('Connect Your Watch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
      const SizedBox(height: 8),
      const Text(
        'Pair your Digital Saver smartwatch via Bluetooth to see live health data from your ESP32 watch.',
        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: ble.startScan,
          icon: const Icon(Icons.bluetooth_searching, size: 16),
          label: const Text('Scan & Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        )),
        const SizedBox(width: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onPressed: ble.enableDemoMode,
          child: const Text('Demo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ]),
    ]),
  );
}

class _DemoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: const Row(children: [
      Icon(Icons.science_outlined, color: AppColors.warning, size: 16),
      SizedBox(width: 8),
      Expanded(child: Text(
        'Demo Mode — simulated data. Connect your watch for real readings.',
        style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500),
      )),
    ]),
  );
}

class _ScoreCard extends StatelessWidget {
  final Animation<double> animation;
  final int score;
  const _ScoreCard({required this.animation, required this.score});

  Color get _c => score >= 80 ? AppColors.success : score >= 60 ? AppColors.primary : score >= 40 ? AppColors.warning : AppColors.danger;
  String get _label => score >= 80 ? 'Excellent' : score >= 60 ? 'Good' : score >= 40 ? 'Fair' : 'Needs Care';
  String get _msg => score >= 80 ? 'All vitals looking great! Keep up the good work.' : score >= 60 ? 'Most vitals are within healthy range.' : 'Some readings need your attention.';

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: AppShadows.card,
    ),
    child: Column(children: [
      const Text('Health Score', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      const SizedBox(height: 20),
      AnimatedBuilder(
        animation: animation,
        builder: (_, __) => SizedBox(
          width: 170, height: 170,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: const Size(170, 170),
              painter: _RingPainter(progress: animation.value * (score / 100), color: _c),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                '${(animation.value * score).round()}',
                style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1),
              ),
              Text('/100', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: _c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(_label, style: TextStyle(color: _c, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      const SizedBox(height: 10),
      Text(_msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
    ]),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 20) / 2;
    canvas.drawCircle(c, r, Paint()..color = Colors.grey.shade100..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);
    final fg = Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: [color.withOpacity(0.6), color],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

class _VitalsGrid extends StatelessWidget {
  final BleService ble;
  const _VitalsGrid({required this.ble});

  String get _sysVal {
    final p = ble.bloodPressure.split('/');
    return p.isNotEmpty ? p[0] : '--';
  }
  String get _diaUnit {
    final p = ble.bloodPressure.split('/');
    return p.length == 2 ? '${p[1]} mmHg' : 'mmHg';
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Expanded(child: _VitalCard(
        label: 'Heart Rate', value: ble.isConnected && ble.heartRate > 0 ? '${ble.heartRate.round()}' : '--',
        unit: 'BPM', icon: Icons.favorite, gradient: AppColors.gradientHeart,
        badge: _hrBadge(ble.heartRate),
      )),
      const SizedBox(width: 12),
      Expanded(child: _VitalCard(
        label: 'Oxygen SpO₂', value: ble.isConnected && ble.oxygen > 0 ? '${ble.oxygen.round()}' : '--',
        unit: '%', icon: Icons.air, gradient: AppColors.gradientOxy,
        badge: _o2Badge(ble.oxygen),
      )),
    ]),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _VitalCard(
        label: 'Blood Pressure', value: ble.isConnected ? _sysVal : '--',
        unit: _diaUnit, icon: Icons.water_drop, gradient: AppColors.gradientBP,
        badge: _bpBadge(ble.bloodPressure),
      )),
      const SizedBox(width: 12),
      Expanded(child: _VitalCard(
        label: 'HRV Index', value: ble.isConnected && ble.hrv > 0 ? '${ble.hrv.round()}' : '--',
        unit: 'ms RMSSD', icon: Icons.show_chart, gradient: AppColors.gradientPrimary,
        badge: _hrvBadge(ble.hrv),
      )),
    ]),
  ]);

  _Badge? _hrBadge(double hr) {
    if (hr == 0) return null;
    if (hr < 60) return const _Badge('LOW', AppColors.warning);
    if (hr > 100) return const _Badge('HIGH', AppColors.danger);
    return const _Badge('NORMAL', AppColors.success);
  }
  _Badge? _o2Badge(double o2) {
    if (o2 == 0) return null;
    if (o2 >= 95) return const _Badge('NORMAL', AppColors.success);
    if (o2 >= 90) return const _Badge('LOW', AppColors.warning);
    return const _Badge('CRITICAL', AppColors.danger);
  }
  _Badge? _bpBadge(String bp) {
    final p = bp.split('/');
    if (p.length != 2) return null;
    final s = double.tryParse(p[0]) ?? 120;
    if (s < 120) return const _Badge('NORMAL', AppColors.success);
    if (s < 130) return const _Badge('ELEVATED', AppColors.warning);
    if (s < 140) return const _Badge('HIGH', AppColors.danger);
    return const _Badge('CRISIS', AppColors.dangerDark);
  }
  _Badge? _hrvBadge(double hrv) {
    if (hrv == 0) return null;
    if (hrv >= 50) return const _Badge('GREAT', AppColors.success);
    if (hrv >= 30) return const _Badge('GOOD', AppColors.primary);
    return const _Badge('LOW', AppColors.warning);
  }
}

class _Badge {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);
}

class _VitalCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Gradient gradient;
  final _Badge? badge;
  const _VitalCard({required this.label, required this.value, required this.unit, required this.icon, required this.gradient, this.badge});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 16)),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: badge!.color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(badge!.label, style: TextStyle(color: badge!.color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
      ]),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1)),
      Text(unit, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _AlertsCard extends StatelessWidget {
  final BleService ble;
  const _AlertsCard({required this.ble});

  @override
  Widget build(BuildContext context) {
    if (!ble.isConnected) return const SizedBox.shrink();
    final alerts = HealthAnalysisService.getAlerts(
      hr: ble.heartRate, spo2: ble.oxygen, bp: ble.bloodPressure,
      hrv: ble.hrv, fallDetected: ble.fallDetected, irregularHR: ble.irregularHeartbeat,
    );
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
          SizedBox(width: 8),
          Text('Health Alerts', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 14)),
        ]),
        const SizedBox(height: 10),
        ...alerts.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            Expanded(child: Text(a, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4))),
          ]),
        )),
      ]),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final BleService ble;
  const _TodaySummary({required this.ble});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Today's Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(icon: Icons.directions_walk, label: 'Steps', value: ble.isConnected ? '${ble.steps}' : '--', color: AppColors.stepAmber),
        _Stat(icon: Icons.local_fire_department, label: 'Calories', value: ble.isConnected ? '${ble.calories.round()} kcal' : '--', color: AppColors.heartRed),
        _Stat(icon: Icons.thermostat, label: 'Temp', value: ble.isConnected && ble.temperature > 0 ? '${ble.temperature.toStringAsFixed(1)}°' : '--', color: AppColors.accent),
        _Stat(icon: Icons.bedtime, label: 'Sleep', value: '7h 20m', color: AppColors.sleepPurple),
      ]),
    ]),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Stat({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20)),
    const SizedBox(height: 6),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
  ]);
}
