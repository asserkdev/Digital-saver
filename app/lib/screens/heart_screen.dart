import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/health_analysis_service.dart';

class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthAnalysisService>();
    final latestHR = health.heartRateHistory.isNotEmpty ? health.heartRateHistory.last : _demoHR();
    final afibResult = health.detectAfib(latestHR.rrIntervals);
    final arrhythmiaResult = health.detectArrhythmia(latestHR);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heart', style: AppTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Main HR Display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.dangerRed.withOpacity(0.1), AppTheme.dangerRed.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.dangerRed.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, color: AppTheme.dangerRed, size: 32),
                    const SizedBox(width: 12),
                    Text('Heart Rate', style: AppTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 40, maximum: 200,
                        startAngle: 180, endAngle: 0,
                        showLabels: false, showTicks: false,
                        axisLineStyle: AxisLineStyle(thickness: 20, color: isDark ? Colors.grey[800] : Colors.grey[200], cornerStyle: CornerStyle.bothCurve),
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: latestHR.currentBPM.toDouble(),
                            width: 20, cornerStyle: CornerStyle.bothCurve,
                            gradient: const SweepGradient(colors: [AppTheme.dangerRed, AppTheme.dangerRed]),
                            enableAnimation: true, animationType: AnimationType.easeOutBack,
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${latestHR.currentBPM}', style: AppTheme.headlineLarge.copyWith(fontSize: 56, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
                                Text('BPM', style: AppTheme.titleMedium.copyWith(color: Colors.grey)),
                              ],
                            ),
                            angle: 90, positionFactor: 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Min', value: '${latestHR.minBPM}', icon: Icons.arrow_downward, color: AppTheme.infoBlue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Avg', value: '${latestHR.averageBPM}', icon: Icons.trending_flat, color: AppTheme.healthyGreen)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Max', value: '${latestHR.maxBPM}', icon: Icons.arrow_upward, color: AppTheme.warningOrange)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // HRV Analysis
          _SectionTitle('HRV Analysis'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HrvMetric('RMSSD', '${latestHR.hrv.toStringAsFixed(1)}', 'ms'),
                    _HrvMetric('SDNN', '${latestHR.sdnn.toStringAsFixed(1)}', 'ms'),
                    _HrvMetric('pNN50', '${latestHR.pnn50.toStringAsFixed(1)}', '%'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Status: ${latestHR.hrvDescription}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // AFib Detection
          _SectionTitle('AFib Detection'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AFib Probability', style: AppTheme.titleMedium),
                        Text('${afibResult.probability.toStringAsFixed(1)}%', style: AppTheme.headlineMedium.copyWith(color: _afibColor(afibResult.probability), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: _afibColor(afibResult.probability).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(_afibIcon(afibResult.probability), color: _afibColor(afibResult.probability), size: 20),
                          const SizedBox(width: 8),
                          Text(_afibStatus(afibResult.probability), style: TextStyle(color: _afibColor(afibResult.probability), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: afibResult.probability / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_afibColor(afibResult.probability)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(afibResult.recommendation, style: AppTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // HR Trend Chart
          _SectionTitle('Heart Rate Trend'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: AppTheme.bodySmall))),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                borderData: FlBorderData(show: false),
                minY: 50, maxY: 120,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(20, (i) => FlSpot(i.toDouble(), 70 + (i % 5) * 5 + (i * 0.5))),
                    isCurved: true, color: AppTheme.dangerRed, barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppTheme.dangerRed.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _afibColor(double p) => p < 20 ? AppTheme.healthyGreen : (p < 50 ? AppTheme.warningOrange : AppTheme.dangerRed);
  IconData _afibIcon(double p) => p < 20 ? Icons.check_circle : (p < 50 ? Icons.warning : Icons.error);
  String _afibStatus(double p) => p < 20 ? 'Normal' : (p < 50 ? 'Moderate' : 'High Risk');

  _demoHR() => _HeartRateData(currentBPM: 72, averageBPM: 70, minBPM: 58, maxBPM: 95, hrv: 45, sdnn: 32, pnn50: 15, rmssd: 45, rrIntervals: [], status: null, confidence: 85, hrvAnalysis: [], afibProbability: 0, arrhythmiaType: null, poincarePlotSD1: [], poincarePlotSD2: [], stressIndex: 40, recoveryIndex: 80, timestamp: DateTime.now());
}

class _HeartRateData {
  final int currentBPM, averageBPM, minBPM, maxBPM;
  final double hrv, sdnn, pnn50, rmssd, confidence, stressIndex, recoveryIndex;
  final List rrIntervals, hrvAnalysis, poincarePlotSD1, poincarePlotSD2;
  final dynamic status, arrhythmiaType, afibProbability;
  final DateTime timestamp;
  _HeartRateData({required this.currentBPM, required this.averageBPM, required this.minBPM, required this.maxBPM, required this.hrv, required this.sdnn, required this.pnn50, required this.rmssd, required this.rrIntervals, required this.status, required this.confidence, required this.hrvAnalysis, required this.afibProbability, this.arrhythmiaType, required this.poincarePlotSD1, required this.poincarePlotSD2, required this.stressIndex, required this.recoveryIndex, required this.timestamp});
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: AppTheme.titleLarge);
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}

class _HrvMetric extends StatelessWidget {
  final String label, value, unit;
  const _HrvMetric(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        Text(unit, style: AppTheme.bodySmall),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}
