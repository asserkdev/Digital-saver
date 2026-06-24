import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:digital_saver/theme/app_theme.dart';
import 'package:digital_saver/services/ble_service.dart';
import 'package:digital_saver/services/health_analysis_service.dart';
import 'package:digital_saver/i18n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ble = context.watch<BleService>();
    final health = context.watch<HealthAnalysisService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get latest metrics
    final latestHR = health.heartRateHistory.isNotEmpty ? health.heartRateHistory.last : _demoHR();
    final latestBP = health.bpHistory.isNotEmpty ? health.bpHistory.last : _demoBP();
    final latestO2 = health.oxygenHistory.isNotEmpty ? health.oxygenHistory.last : _demoO2();
    
    // Calculate comprehensive score
    final score = health.calculateComprehensiveScore(latestHR, latestBP, latestO2, _demoActivity());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.appName, style: AppTheme.headlineMedium),
                  Text(t.tagline, style: AppTheme.bodyMedium.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _SettingsPage())),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.settings_rounded, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Health Score Circle
          Center(
            child: CircularPercentIndicator(
              radius: 80,
              lineWidth: 12,
              percent: score.overallScore / 100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${score.overallScore}', style: AppTheme.headlineLarge.copyWith(color: _scoreColor(score.overallScore))),
                  Text(t.healthScore, style: AppTheme.bodySmall),
                ],
              ),
              progressColor: _scoreColor(score.overallScore),
              backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
          ),
          
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: _scoreColor(score.overallScore).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(_gradeText(score.grade), style: TextStyle(color: _scoreColor(score.overallScore), fontWeight: FontWeight.w600)),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Metrics Grid
          Row(
            children: [
              Expanded(child: _MetricCard(title: t.heartRate, value: '${latestHR.currentBPM}', unit: t.bpm, icon: Icons.favorite_rounded, color: AppTheme.dangerRed, status: latestHR.status, trend: health.heartRateTrend)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: t.bloodPressure, value: '${latestBP.systolic}/${latestBP.diastolic}', unit: t.mmhg, icon: Icons.water_drop_rounded, color: AppTheme.infoBlue, status: _bpStatus(latestBP), trend: health.bpTrend)),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: _MetricCard(title: t.oxygen, value: '${latestO2.spO2}', unit: t.percent, icon: Icons.air_rounded, color: AppTheme.healthyGreen, status: _o2Status(latestO2), trend: health.oxygenTrend)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(title: t.hrv, value: latestHR.hrv.toStringAsFixed(0), unit: t.ms, icon: Icons.show_chart_rounded, color: AppTheme.primaryColor, status: latestHR.status)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Heart Rate Gauge
          _SectionCard(
            title: t.heartRate,
            child: SizedBox(
              height: 180,
              child: SfRadialGauge(
                enableLoadingAnimation: true,
                animationDuration: 2000,
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 40,
                    maximum: 200,
                    startAngle: 150,
                    endAngle: 30,
                    showLabels: true,
                    axisLineStyle: AxisLineStyle(thickness: 0.15, thicknessUnit: GaugeSizeUnit.factor, color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 40, endValue: 60, color: AppTheme.infoBlue.withOpacity(0.3)),
                      GaugeRange(startValue: 60, endValue: 100, color: AppTheme.healthyGreen.withOpacity(0.3)),
                      GaugeRange(startValue: 100, endValue: 150, color: AppTheme.warningOrange.withOpacity(0.3)),
                      GaugeRange(startValue: 150, endValue: 200, color: AppTheme.dangerRed.withOpacity(0.3)),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: latestHR.currentBPM.toDouble(),
                        enableAnimation: true,
                        animationType: AnimationType.easeOutBack,
                        needleColor: AppTheme.primaryColor,
                        knobStyle: const KnobStyle(knobRadius: 0.08, sizeUnit: GaugeSizeUnit.factor),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${latestHR.currentBPM}', style: AppTheme.headlineLarge.copyWith(fontWeight: FontWeight.bold)),
                            Text(t.bpm, style: AppTheme.bodySmall),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          _SectionCard(
            title: 'Quick Stats',
            child: Row(
              children: [
                _QuickStat(icon: Icons.directions_walk_rounded, value: '8,542', label: t.steps, color: AppTheme.healthyGreen),
                _QuickStat(icon: Icons.local_fire_department_rounded, value: '423', label: t.calories, color: AppTheme.warningOrange),
                _QuickStat(icon: Icons.nights_stay_rounded, value: '7h 23m', label: t.sleep, color: AppTheme.primaryColor),
                _QuickStat(icon: Icons.self_improvement_rounded, value: 'Low', label: t.stress, color: AppTheme.infoBlue),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recommendations
          if (score.recommendations.isNotEmpty)
            _SectionCard(
              title: t.recommendations,
              child: Column(
                children: score.recommendations.take(3).map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppTheme.warningOrange),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rec, style: AppTheme.bodyMedium)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return AppTheme.healthyGreen;
    if (score >= 70) return AppTheme.primaryColor;
    if (score >= 50) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String _gradeText(grade) {
    switch (grade.toString()) {
      case 'HealthGrade.excellent': return 'Excellent';
      case 'HealthGrade.good': return 'Good';
      case 'HealthGrade.fair': return 'Fair';
      case 'HealthGrade.poor': return 'Poor';
      default: return 'Critical';
    }
  }

  _bpStatus(bp) {
    return bp.category.toString().contains('normal') ? _HeartRateStatus.normal : _HeartRateStatus.warning;
  }

  _o2Status(o2) {
    return o2.status.toString().contains('normal') ? _HeartRateStatus.normal : _HeartRateStatus.warning;
  }

  // Demo data generators
  _demoHR() => _HeartRateData(currentBPM: 72, averageBPM: 70, minBPM: 58, maxBPM: 95, hrv: 45, sdnn: 32, pnn50: 15, rmssd: 45, rrIntervals: [], status: _HeartRateStatus.normal, confidence: 85, hrvAnalysis: [], afibProbability: 5, arrhythmiaType: null, poincarePlotSD1: [], poincarePlotSD2: [], stressIndex: 40, recoveryIndex: 80, timestamp: DateTime.now());
  _demoBP() => _BloodPressureData(systolic: 118, diastolic: 76, meanArterialPressure: 90, pulsePressure: 42, augmentationIndex: 25, augmentationPressure: 10, pulseWaveVelocity: 7.5, pulseWave: [], category: _BpCategory.normal, confidence: 80, vascularAge: 35, arterialStiffness: 5.5, cardiacOutput: 5.0, systemicVascularResistance: 15, timestamp: DateTime.now());
  _demoO2() => _OxygenData(spO2: 98, fastSpO2: 97, perfusionIndex: 5.5, respirationRate: 16, piVariability: 2.0, lowOxygenAlert: false, lowOxygenDuration: 0, spo2History: [98], status: _OxygenStatus.normal, confidence: 90, oxygenSaturationIndex: 30, timestamp: DateTime.now());
  _demoActivity() => _ActivityData(steps: 8542, distanceKm: 6.2, caloriesBurned: 423, activeMinutes: 45, restingMinutes: 0, moderateMinutes: 30, vigorousMinutes: 15, stepsGoal: 10000, caloriesGoal: 500, activeMinutesGoal: 60, restingHeartRate: 58, vo2Max: 42, currentActivity: null, activityScore: 85, segments: [], hourlySteps: [], cadence: 95, timestamp: DateTime.now());
}

// Mock classes for demo data
class _HeartRateStatus { static const normal = _HeartRateStatus._('normal'); static const warning = _HeartRateStatus._('warning'); static const critical = _HeartRateStatus._('critical'); final String name; const _HeartRateStatus._(this.name); @override String toString() => name; }
class _BpCategory { static const normal = _BpCategory._('normal'); final String name; const _BpCategory._(this.name); @override String toString() => name; }
class _OxygenStatus { static const normal = _OxygenStatus._('normal'); final String name; const _OxygenStatus._(this.name); @override String toString() => name; }
class _HeartRateData { final int currentBPM, averageBPM, minBPM, maxBPM; final double hrv, sdnn, pnn50, rmssd, confidence, stressIndex, recoveryIndex; final List rrIntervals, hrvAnalysis, poincarePlotSD1, poincarePlotSD2; final dynamic status, arrhythmiaType; final DateTime timestamp; _HeartRateData({required this.currentBPM, required this.averageBPM, required this.minBPM, required this.maxBPM, required this.hrv, required this.sdnn, required this.pnn50, required this.rmssd, required this.rrIntervals, required this.status, required this.confidence, required this.hrvAnalysis, required this.afibProbability, this.arrhythmiaType, required this.poincarePlotSD1, required this.poincarePlotSD2, required this.stressIndex, required this.recoveryIndex, required this.timestamp}); double get afibProbability => 5.0; }
class _BloodPressureData { final int systolic, diastolic, meanArterialPressure, confidence, vascularAge; final double pulsePressure, augmentationIndex, augmentationPressure, pulseWaveVelocity, arterialStiffness, cardiacOutput, systemicVascularResistance; final List pulseWave; final dynamic category; final DateTime timestamp; _BloodPressureData({required this.systolic, required this.diastolic, required this.meanArterialPressure, required this.pulsePressure, required this.augmentationIndex, required this.augmentationPressure, required this.pulseWaveVelocity, required this.pulseWave, required this.category, required this.confidence, required this.vascularAge, required this.arterialStiffness, required this.cardiacOutput, required this.systemicVascularResistance, required this.timestamp}); }
class _OxygenData { final int spO2, fastSpO2, lowOxygenDuration; final double perfusionIndex, respirationRate, piVariability, confidence, oxygenSaturationIndex; final bool lowOxygenAlert; final List spo2History; final dynamic status; final DateTime timestamp; _OxygenData({required this.spO2, required this.fastSpO2, required this.perfusionIndex, required this.respirationRate, required this.piVariability, required this.lowOxygenAlert, required this.lowOxygenDuration, required this.spo2History, required this.status, required this.confidence, required this.oxygenSaturationIndex, required this.timestamp}); }
class _ActivityData { final int steps, caloriesBurned, activeMinutes, restingMinutes, moderateMinutes, vigorousMinutes, stepsGoal, caloriesGoal, activeMinutesGoal, restingHeartRate; final double distanceKm, vo2Max, activityScore, cadence; final dynamic currentActivity; final List segments, hourlySteps; final DateTime timestamp; _ActivityData({required this.steps, required this.distanceKm, required this.caloriesBurned, required this.activeMinutes, required this.restingMinutes, required this.moderateMinutes, required this.vigorousMinutes, required this.stepsGoal, required this.caloriesGoal, required this.activeMinutesGoal, required this.restingHeartRate, required this.vo2Max, this.currentActivity, required this.activityScore, required this.segments, required this.hourlySteps, required this.cadence, required this.timestamp}); }
class HealthGrade { static const excellent = HealthGrade._('excellent'); static const good = HealthGrade._('good'); static const fair = HealthGrade._('fair'); static const poor = HealthGrade._('poor'); final String name; const HealthGrade._(this.name); @override String toString() => name; }

// Widgets
class _MetricCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;
  final dynamic status;
  final dynamic trend;

  const _MetricCard({required this.title, required this.value, required this.unit, required this.icon, required this.color, required this.status, this.trend});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != null && trend.direction.toString() != 'stable') Icon(trend.direction.toString() == 'up' ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.bodySmall.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(unit, style: AppTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status?.toString() == 'normal' ? 'Normal' : 'Warning', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
          child: child,
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _QuickStat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Settings')), body: const Center(child: Text('Settings Screen')));
}
