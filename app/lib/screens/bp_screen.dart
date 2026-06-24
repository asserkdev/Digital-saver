import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/health_analysis_service.dart';

class BpScreen extends StatelessWidget {
  const BpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthAnalysisService>();
    final latestBP = health.bpHistory.isNotEmpty ? health.bpHistory.last : _demoBP();
    final bpAnalysis = health.analyzeBloodPressure(health.bpHistory);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Blood Pressure', style: AppTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Main BP Display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.infoBlue.withOpacity(0.1), AppTheme.infoBlue.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.infoBlue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop_rounded, color: AppTheme.infoBlue, size: 32),
                    const SizedBox(width: 12),
                    Text('Blood Pressure', style: AppTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BPGauge(value: latestBP.systolic.toDouble(), label: 'SYS', color: _bpColor(latestBP.category)),
                    const SizedBox(width: 40),
                    Text('/', style: AppTheme.headlineLarge.copyWith(color: Colors.grey)),
                    const SizedBox(width: 40),
                    _BPGauge(value: latestBP.diastolic.toDouble(), label: 'DIA', color: _bpColor(latestBP.category)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: _bpColor(latestBP.category).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(_bpCategoryText(latestBP.category), style: TextStyle(color: _bpColor(latestBP.category), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _MetricTile(title: 'MAP', value: '${latestBP.meanArterialPressure}', unit: 'mmHg', icon: Icons.speed, color: AppTheme.primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: _MetricTile(title: 'PP', value: latestBP.pulsePressure.toStringAsFixed(0), unit: 'mmHg', icon: Icons.favorite_border, color: AppTheme.secondaryColor)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Vascular Health
          Text('Vascular Health', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Row(
              children: [
                Expanded(
                  child: _VascularMetric('Vascular Age', '${bpAnalysis.vascularAge}', 'years', AppTheme.primaryColor),
                ),
                Container(height: 60, width: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                Expanded(
                  child: _VascularMetric('Arterial\nStiffness', bpAnalysis.arterialStiffness.toStringAsFixed(1), '', _stiffnessColor(bpAnalysis.arterialStiffness)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // BP Trend
          Text('BP Trend', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: AppTheme.bodySmall))),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 60, maxY: 160,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(20, (i) => FlSpot(i.toDouble(), 120 + (i % 3) * 5)),
                    isCurved: true, color: AppTheme.dangerRed, barWidth: 3, dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.dangerRed.withOpacity(0.1)),
                  ),
                  LineChartBarData(
                    spots: List.generate(20, (i) => FlSpot(i.toDouble(), 78 + (i % 2) * 3)),
                    isCurved: true, color: AppTheme.infoBlue, barWidth: 3, dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend('Systolic', AppTheme.dangerRed),
              const SizedBox(width: 24),
              _Legend('Diastolic', AppTheme.infoBlue),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // BP Categories Guide
          Text('BP Categories', style: AppTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                _BpCategoryRow('Normal', '<120', 'and', '<80', AppTheme.healthyGreen),
                const Divider(height: 24),
                _BpCategoryRow('Elevated', '120-129', 'and', '<80', AppTheme.infoBlue),
                const Divider(height: 24),
                _BpCategoryRow('Stage 1', '130-139', 'or', '80-89', AppTheme.warningOrange),
                const Divider(height: 24),
                _BpCategoryRow('Stage 2', '≥140', 'or', '≥90', AppTheme.dangerRed),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _bpColor(category) {
    final s = category.toString();
    if (s.contains('normal')) return AppTheme.healthyGreen;
    if (s.contains('elevated')) return AppTheme.infoBlue;
    if (s.contains('1')) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _bpCategoryText(category) {
    final s = category.toString();
    if (s.contains('normal')) return 'Normal';
    if (s.contains('elevated')) return 'Elevated';
    if (s.contains('1')) return 'Stage 1 Hypertension';
    if (s.contains('2')) return 'Stage 2 Hypertension';
    return 'Crisis';
  }

  Color _stiffnessColor(double s) => s < 25 ? AppTheme.healthyGreen : (s < 35 ? AppTheme.warningOrange : AppTheme.dangerRed);

  _demoBP() => _BloodPressureData(systolic: 118, diastolic: 76, meanArterialPressure: 90, pulsePressure: 42, augmentationIndex: 25, augmentationPressure: 10, pulseWaveVelocity: 7.5, pulseWave: [], category: _BpCategory.normal, confidence: 80, vascularAge: 35, arterialStiffness: 5.5, cardiacOutput: 5.0, systemicVascularResistance: 15, timestamp: DateTime.now());
}

class _BloodPressureData {
  final int systolic, diastolic, meanArterialPressure, confidence, vascularAge;
  final double pulsePressure, augmentationIndex, augmentationPressure, pulseWaveVelocity, arterialStiffness, cardiacOutput, systemicVascularResistance;
  final List pulseWave;
  final dynamic category;
  final DateTime timestamp;
  _BloodPressureData({required this.systolic, required this.diastolic, required this.meanArterialPressure, required this.pulsePressure, required this.augmentationIndex, required this.augmentationPressure, required this.pulseWaveVelocity, required this.pulseWave, required this.category, required this.confidence, required this.vascularAge, required this.arterialStiffness, required this.cardiacOutput, required this.systemicVascularResistance, required this.timestamp});
}

class _BpCategory { static const normal = _BpCategory._('normal'); final String name; const _BpCategory._(this.name); @override String toString() => name; }

class _BPGauge extends StatelessWidget {
  final double value, min, max;
  final String label;
  final Color color;
  const _BPGauge({required this.value, required this.label, required this.color, this.min = 40, this.max = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, height: 100,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: min, maximum: max,
            startAngle: 135, endAngle: 45,
            showLabels: false, showTicks: false,
            axisLineStyle: AxisLineStyle(thickness: 8, color: Colors.grey.withOpacity(0.2), cornerStyle: CornerStyle.bothCurve),
            pointers: <GaugePointer>[
              RangePointer(
                value: value, width: 8, cornerStyle: CornerStyle.bothCurve,
                gradient: SweepGradient(colors: [color.withOpacity(0.5), color]),
                enableAnimation: true, animationType: AnimationType.easeOutBack,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(value.toInt().toString(), style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: color)),
                angle: 90, positionFactor: 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  const _MetricTile({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: AppTheme.bodySmall),
            ],
          ),
          Text(title, style: AppTheme.labelSmall),
        ],
      ),
    );
  }
}

class _VascularMetric extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _VascularMetric(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
            if (unit.isNotEmpty) Text(unit, style: AppTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}

class _BpCategoryRow extends StatelessWidget {
  final String category, sys, connector, dia, unit;
  final Color color;
  const _BpCategoryRow(this.category, this.sys, this.connector, this.dia, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: Text(category, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(sys, style: AppTheme.bodySmall, textAlign: TextAlign.center)),
        Text(connector, style: AppTheme.bodySmall),
        Expanded(child: Text(dia, style: AppTheme.bodySmall, textAlign: TextAlign.center)),
      ],
    );
  }
}
