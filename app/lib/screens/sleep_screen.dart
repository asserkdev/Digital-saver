import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:digital_saver/theme/app_theme.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sleep', style: AppTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Sleep Score
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nights_stay_rounded, color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 12),
                    Text('Sleep Score', style: AppTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 12,
                  percent: 0.82,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('82', style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      Text('Good', style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor)),
                    ],
                  ),
                  progressColor: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Total Sleep
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.bed_rounded, color: AppTheme.primaryColor, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Sleep', style: AppTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text('7h 23m', style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.healthyGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.healthyGreen, size: 20),
                      const SizedBox(width: 8),
                      Text('On Target', style: TextStyle(color: AppTheme.healthyGreen, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sleep Stages
          Text('Sleep Stages', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                // Visual bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        _StageSegment(flex: 15, color: const Color(0xFF4A148C), label: 'Deep'),
                        _StageSegment(flex: 45, color: const Color(0xFF2196F3), label: 'Light'),
                        _StageSegment(flex: 25, color: const Color(0xFFFF9800), label: 'REM'),
                        _StageSegment(flex: 15, color: Colors.grey, label: 'Awake'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SleepStageDetail(label: 'Deep', value: '1h 45m', color: const Color(0xFF4A148C), icon: Icons.nightlight_round),
                    _SleepStageDetail(label: 'Light', value: '4h 30m', color: const Color(0xFF2196F3), icon: Icons.nights_stay_outlined),
                    _SleepStageDetail(label: 'REM', value: '1h 30m', color: const Color(0xFFFF9800), icon: Icons.remove_red_eye_outlined),
                    _SleepStageDetail(label: 'Awake', value: '38m', color: Colors.grey, icon: Icons.visibility_off_outlined),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sleep Insights
          Text('Sleep Insights', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _InsightRow(icon: Icons.access_time_rounded, title: 'Sleep Duration', value: '7h 23m', status: 'Good', color: AppTheme.healthyGreen),
                const Divider(height: 24),
                _InsightRow(icon: Icons.schedule_rounded, title: 'Time Asleep', value: '7h 23m', status: '92%', color: AppTheme.primaryColor),
                const Divider(height: 24),
                _InsightRow(icon: Icons.bedtime_rounded, title: 'Bedtime', value: '10:45 PM', status: 'On Time', color: AppTheme.infoBlue),
                const Divider(height: 24),
                _InsightRow(icon: Icons.wb_sunny_rounded, title: 'Wake Time', value: '6:08 AM', status: 'On Time', color: AppTheme.warningOrange),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sleep Tips
          Text('Sleep Tips', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _TipRow(icon: Icons.phone_android_rounded, tip: 'Avoid screens 1 hour before bed'),
                const SizedBox(height: 12),
                _TipRow(icon: Icons.local_cafe_rounded, tip: 'Limit caffeine after 2 PM'),
                const SizedBox(height: 12),
                _TipRow(icon: Icons.thermostat_rounded, tip: 'Keep bedroom cool (65-68°F)'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StageSegment extends StatelessWidget {
  final int flex;
  final Color color;
  final String label;

  const _StageSegment({required this.flex, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(color: color),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SleepStageDetail extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _SleepStageDetail({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String title, value, status;
  final Color color;

  const _InsightRow({required this.icon, required this.title, required this.value, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodyMedium),
              Text(value, style: AppTheme.titleMedium),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String tip;

  const _TipRow({required this.icon, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(tip, style: AppTheme.bodyMedium)),
      ],
    );
  }
}
