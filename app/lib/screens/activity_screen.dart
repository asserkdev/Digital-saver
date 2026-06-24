import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:digital_saver/theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity', style: AppTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Activity Score
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.healthyGreen.withOpacity(0.1), AppTheme.healthyGreen.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.healthyGreen.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_run_rounded, color: AppTheme.healthyGreen, size: 32),
                    const SizedBox(width: 12),
                    Text('Activity Score', style: AppTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 150, width: 150,
                      child: CircularProgressIndicator(
                        value: 0.85,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(AppTheme.healthyGreen),
                      ),
                    ),
                    Column(
                      children: [
                        Text('85', style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.healthyGreen)),
                        Text('Score', style: AppTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.healthyGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_walk_rounded, color: AppTheme.healthyGreen),
                      const SizedBox(width: 8),
                      Text('Walking', style: TextStyle(color: AppTheme.healthyGreen, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Goals Progress
          Text('Daily Goals', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _GoalProgress(icon: Icons.directions_walk_rounded, title: 'Steps', current: 8542, goal: 10000, unit: 'steps', color: AppTheme.healthyGreen),
                const SizedBox(height: 16),
                _GoalProgress(icon: Icons.local_fire_department_rounded, title: 'Calories', current: 423, goal: 500, unit: 'kcal', color: AppTheme.warningOrange),
                const SizedBox(height: 16),
                _GoalProgress(icon: Icons.timer_rounded, title: 'Active Minutes', current: 45, goal: 60, unit: 'min', color: AppTheme.primaryColor),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Row
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.straighten_rounded, value: '6.2', label: 'Distance (km)', color: AppTheme.infoBlue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.favorite_rounded, value: '58', label: 'Resting HR', color: AppTheme.dangerRed)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Hourly Chart
          Text('Hourly Activity', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${(v / 1000).toStringAsFixed(0)}k', style: AppTheme.bodySmall))),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final hours = ['6a', '8a', '10a', '12p', '2p', '4p', '6p'];
                    if (v.toInt() < hours.length) return Text(hours[v.toInt()], style: AppTheme.bodySmall);
                    return const Text('');
                  })),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1200, color: Colors.grey, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3400, color: AppTheme.healthyGreen.withOpacity(0.5), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2100, color: AppTheme.healthyGreen.withOpacity(0.5), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8900, color: AppTheme.healthyGreen, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5600, color: AppTheme.healthyGreen, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 4200, color: AppTheme.healthyGreen, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3100, color: AppTheme.healthyGreen.withOpacity(0.5), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))]),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Weekly Overview
          Text('This Week', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildWeeklyBars(),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildWeeklyBars() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = [7500, 12000, 8900, 5400, 10200, 8200, 3200];
    return days.asMap().entries.map((e) {
      final progress = values[e.key] / 10000;
      return Column(
        children: [
          Container(
            width: 30, height: 80,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 30,
                height: 80 * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: values[e.key] >= 10000 ? AppTheme.healthyGreen : AppTheme.warningOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(e.value, style: AppTheme.labelSmall),
        ],
      );
    }).toList();
  }
}

class _GoalProgress extends StatelessWidget {
  final IconData icon;
  final String title;
  final int current, goal;
  final String unit;
  final Color color;

  const _GoalProgress({required this.icon, required this.title, required this.current, required this.goal, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(title, style: AppTheme.titleMedium),
            const Spacer(),
            Text('$current / $goal $unit', style: AppTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearPercentIndicator(
            lineHeight: 8,
            percent: (current / goal).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}
