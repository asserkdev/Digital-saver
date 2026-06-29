import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/health_analysis_service.dart';
import '../models/health_models.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sleep = HealthAnalysisService.generateTypicalSleepData();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Sleep', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1e3a5f),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SleepHero(sleep: sleep),
            const SizedBox(height: 16),
            _SleepStages(sleep: sleep),
            const SizedBox(height: 16),
            _SleepDonut(sleep: sleep),
            const SizedBox(height: 16),
            _SleepTips(score: sleep.qualityScore),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SleepHero extends StatelessWidget {
  final SleepData sleep;
  const _SleepHero({required this.sleep});

  Color get _color {
    if (sleep.qualityScore >= 80) return const Color(0xFF22C55E);
    if (sleep.qualityScore >= 60) return const Color(0xFF2563eb);
    if (sleep.qualityScore >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1e3a5f), Color(0xFF7c3aed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.bedtime, color: Colors.white, size: 36),
          const SizedBox(height: 16),
          Text(
            sleep.duration,
            style: const TextStyle(
              color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold, height: 1,
            ),
          ),
          const Text('total sleep', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quality: ', style: TextStyle(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sleep.qualityLabel} (${sleep.qualityScore}/100)',
                  style: TextStyle(color: _color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeInfo(label: 'Bedtime', time: _formatTime(sleep.bedtime)),
              Container(width: 1, height: 30, color: Colors.white24),
              _TimeInfo(label: 'Wake up', time: _formatTime(sleep.wakeTime)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

class _TimeInfo extends StatelessWidget {
  final String label, time;
  const _TimeInfo({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

class _SleepStages extends StatelessWidget {
  final SleepData sleep;
  const _SleepStages({required this.sleep});

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
          const Text('Sleep Stages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          _StageBar(label: 'Deep Sleep', minutes: sleep.deepSleepMinutes, color: const Color(0xFF1e3a5f), total: sleep.totalMinutes),
          const SizedBox(height: 10),
          _StageBar(label: 'REM Sleep', minutes: sleep.remSleepMinutes, color: const Color(0xFF7c3aed), total: sleep.totalMinutes),
          const SizedBox(height: 10),
          _StageBar(label: 'Light Sleep', minutes: sleep.lightSleepMinutes, color: const Color(0xFF2563eb), total: sleep.totalMinutes),
          const SizedBox(height: 10),
          _StageBar(label: 'Awake', minutes: sleep.awakeMinutes, color: Colors.grey.shade400, total: sleep.totalMinutes + sleep.awakeMinutes),
        ],
      ),
    );
  }
}

class _StageBar extends StatelessWidget {
  final String label;
  final int minutes, total;
  final Color color;
  const _StageBar({required this.label, required this.minutes, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final frac = total > 0 ? (minutes / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 13)),
              ],
            ),
            Text('${h > 0 ? '${h}h ' : ''}${m}m', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: frac,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _SleepDonut extends StatelessWidget {
  final SleepData sleep;
  const _SleepDonut({required this.sleep});

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
        children: [
          const Text('Stage Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(value: sleep.deepSleepMinutes.toDouble(), color: const Color(0xFF1e3a5f), title: 'Deep', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: sleep.remSleepMinutes.toDouble(), color: const Color(0xFF7c3aed), title: 'REM', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: sleep.lightSleepMinutes.toDouble(), color: const Color(0xFF2563eb), title: 'Light', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: sleep.awakeMinutes.toDouble(), color: Colors.grey.shade300, title: '', radius: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepTips extends StatelessWidget {
  final int score;
  const _SleepTips({required this.score});

  List<String> get tips {
    if (score >= 80) {
      return ['Great sleep! Keep your consistent schedule.', 'Your deep sleep ratio is healthy.'];
    } else if (score >= 60) {
      return ['Try sleeping 30 min earlier for better deep sleep.', 'Avoid screens 1 hour before bed.'];
    } else {
      return ['Your sleep quality needs improvement.', 'Maintain a consistent sleep/wake schedule.', 'Reduce caffeine after 2 PM.'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7c3aed).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Color(0xFF7c3aed), size: 20),
              SizedBox(width: 8),
              Text('Sleep Tips', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7c3aed), fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF7c3aed), fontWeight: FontWeight.bold)),
                Expanded(child: Text(t, style: TextStyle(color: Colors.grey[700], fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
