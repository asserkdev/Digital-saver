import 'dart:math';

// ============================================================================
// ADVANCED HEALTH MODELS - COMPREHENSIVE HEALTH DATA STRUCTURES
// ============================================================================

// Heart Rate Status
enum HeartRateStatus { normal, elevated, warning, critical, unknown }

// Blood Pressure Category
enum BpCategory { hypotension, normal, elevated, hypertension1, hypertension2, crisis }

// Oxygen Status
enum OxygenStatus { normal, mildHypoxia, moderateHypoxia, severeHypoxia }

// Activity Type
enum ActivityType { resting, sedentary, walking, jogging, running, cycling, swimming }

// Sleep Quality
enum SleepQuality { veryPoor, poor, fair, good, excellent }

// Alert Types
enum AlertType { fall, arrhythmia, afib, tachycardia, bradycardia, hypertension, hypotension, lowOxygen, manual }
enum AlertSeverity { info, warning, critical, emergency }

// Health Grade
enum HealthGrade { excellent, good, fair, poor, critical }

// Arrhythmia Types
enum ArrhythmiaType { normalSinus, sinusTachycardia, sinusBradycardia, atrialFibrillation, atrialFlutter, svt, pvc, pac, heartBlock, vtach, vfib, other }

// ============================================================================
// HEART RATE DATA - COMPREHENSIVE CARDIAC ANALYSIS
// ============================================================================
class HeartRateData {
  final int currentBPM;
  final int averageBPM;
  final int minBPM;
  final int maxBPM;
  final double hrv; // Heart Rate Variability (RMSSD in ms)
  final double sdnn; // Standard deviation of NN intervals
  final double pnn50; // Percentage of successive RR intervals > 50ms
  final double rmssd; // Root mean square of successive differences
  final List<int> rrIntervals; // Raw RR intervals
  final HeartRateStatus status;
  final double confidence;
  final List<HRVAnalysis> hrvAnalysis;
  final double afibProbability;
  final ArrhythmiaType arrhythmiaType;
  final List<double> poincarePlotSD1;
  final List<double> poincarePlotSD2;
  final double stressIndex;
  final double recoveryIndex;
  final DateTime timestamp;
  
  HeartRateData({
    required this.currentBPM,
    required this.averageBPM,
    required this.minBPM,
    required this.maxBPM,
    required this.hrv,
    required this.sdnn,
    required this.pnn50,
    required this.rmssd,
    required this.rrIntervals,
    required this.status,
    required this.confidence,
    required this.hrvAnalysis,
    required this.afibProbability,
    required this.arrhythmiaType,
    required this.poincarePlotSD1,
    required this.poincarePlotSD2,
    required this.stressIndex,
    required this.recoveryIndex,
    required this.timestamp,
  });
  
  String get hrvDescription {
    if (hrv >= 60) return 'Excellent';
    if (hrv >= 40) return 'Good';
    if (hrv >= 20) return 'Moderate';
    return 'Low';
  }
}

class HRVAnalysis {
  final double value;
  final String name;
  final String unit;
  final double min;
  final double max;
  final double referenceMin;
  final double referenceMax;
  
  HRVAnalysis({
    required this.value,
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    required this.referenceMin,
    required this.referenceMax,
  });
  
  double get normalizedValue => ((value - min) / (max - min)).clamp(0.0, 1.0);
  bool get isNormal => value >= referenceMin && value <= referenceMax;
}

// ============================================================================
// BLOOD PRESSURE DATA - VASCULAR HEALTH ANALYSIS
// ============================================================================
class BloodPressureData {
  final int systolic;
  final int diastolic;
  final int meanArterialPressure;
  final double pulsePressure;
  final double augmentationIndex;
  final double augmentationPressure;
  final double pulseWaveVelocity;
  final List<int> pulseWave;
  final BpCategory category;
  final double confidence;
  final int vascularAge;
  final double arterialStiffness;
  final double cardiacOutput;
  final double systemicVascularResistance;
  final DateTime timestamp;
  
  BloodPressureData({
    required this.systolic,
    required this.diastolic,
    required this.meanArterialPressure,
    required this.pulsePressure,
    required this.augmentationIndex,
    required this.augmentationPressure,
    required this.pulseWaveVelocity,
    required this.pulseWave,
    required this.category,
    required this.confidence,
    required this.vascularAge,
    required this.arterialStiffness,
    required this.cardiacOutput,
    required this.systemicVascularResistance,
    required this.timestamp,
  });
}

class BpAnalysis {
  final int vascularAge;
  final double arterialStiffness;
  final double aorticPressure;
  final double centralSystolicPressure;
  final double centralDiastolicPressure;
  final double waveReflectionMagnitude;
  final double subEndocardialViabilityRatio;
  final List<String> recommendations;
}

// ============================================================================
// OXYGEN DATA - COMPREHENSIVE OXYGENATION ANALYSIS
// ============================================================================
class OxygenData {
  final int spO2;
  final int fastSpO2;
  final double perfusionIndex;
  final double respirationRate;
  final double piVariability;
  final bool lowOxygenAlert;
  final int lowOxygenDuration;
  final List<int> spo2History;
  final OxygenStatus status;
  final double confidence;
  final double oxygenSaturationIndex;
  final DateTime timestamp;
  
  OxygenData({
    required this.spO2,
    required this.fastSpO2,
    required this.perfusionIndex,
    required this.respirationRate,
    required this.piVariability,
    required this.lowOxygenAlert,
    required this.lowOxygenDuration,
    required this.spo2History,
    required this.status,
    required this.confidence,
    required this.oxygenSaturationIndex,
    required this.timestamp,
  });
}

// ============================================================================
// ACTIVITY DATA - COMPREHENSIVE MOVEMENT ANALYSIS
// ============================================================================
class ActivityData {
  final int steps;
  final double distanceKm;
  final int caloriesBurned;
  final int activeMinutes;
  final int restingMinutes;
  final int moderateMinutes;
  final int vigorousMinutes;
  final int stepsGoal;
  final int caloriesGoal;
  final int activeMinutesGoal;
  final int restingHeartRate;
  final double vo2Max;
  final ActivityType currentActivity;
  final double activityScore;
  final List<ActivitySegment> segments;
  final List<int> hourlySteps;
  final double cadence;
  final DateTime timestamp;
  
  ActivityData({
    required this.steps,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.restingMinutes,
    required this.moderateMinutes,
    required this.vigorousMinutes,
    required this.stepsGoal,
    required this.caloriesGoal,
    required this.activeMinutesGoal,
    required this.restingHeartRate,
    required this.vo2Max,
    required this.currentActivity,
    required this.activityScore,
    required this.segments,
    required this.hourlySteps,
    required this.cadence,
    required this.timestamp,
  });
}

class ActivitySegment {
  final DateTime start;
  final DateTime end;
  final ActivityType type;
  final int duration;
  final int calories;
  final double distance;
  final int steps;
}

// ============================================================================
// SLEEP DATA - COMPREHENSIVE SLEEP ANALYSIS
// ============================================================================
class SleepData {
  final Duration totalSleep;
  final Duration deepSleep;
  final Duration lightSleep;
  final Duration remSleep;
  final Duration awakeTime;
  final Duration sleepLatency;
  final Duration wakeAfterSleepOnset;
  final int sleepScore;
  final SleepQuality quality;
  final List<SleepStage> stages;
  final int sleepCycles;
  final double sleepEfficiency;
  final DateTime bedTime;
  final DateTime wakeTime;
  
  SleepData({
    required this.totalSleep,
    required this.deepSleep,
    required this.lightSleep,
    required this.remSleep,
    required this.awakeTime,
    required this.sleepLatency,
    required this.wakeAfterSleepOnset,
    required this.sleepScore,
    required this.quality,
    required this.stages,
    required this.sleepCycles,
    required this.sleepEfficiency,
    required this.bedTime,
    required this.wakeTime,
  });
  
  String get totalSleepString {
    final hours = totalSleep.inHours;
    final minutes = totalSleep.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class SleepStage {
  final DateTime start;
  final DateTime end;
  final String stage; // awake, rem, light, deep
  final int duration;
  final double quality;
}

// ============================================================================
// FALL DETECTION DATA
// ============================================================================
class FallData {
  final bool fallDetected;
  final double impactForce;
  final double orientationChange;
  final DateTime timestamp;
  final int freeFallDuration;
  final bool lossOfConsciousness;
  final double confidence;
  
  FallData({
    required this.fallDetected,
    required this.impactForce,
    required this.orientationChange,
    required this.timestamp,
    required this.freeFallDuration,
    required this.lossOfConsciousness,
    required this.confidence,
  });
}

// ============================================================================
// COMPREHENSIVE HEALTH METRICS
// ============================================================================
class HealthMetrics {
  final HeartRateData heartRate;
  final BloodPressureData bloodPressure;
  final OxygenData oxygen;
  final ActivityData activity;
  final SleepData sleep;
  final FallData? fall;
  final int healthScore;
  final HealthGrade grade;
  final List<String> recommendations;
  final DateTime timestamp;
  
  HealthMetrics({
    required this.heartRate,
    required this.bloodPressure,
    required this.oxygen,
    required this.activity,
    required this.sleep,
    this.fall,
    required this.healthScore,
    required this.grade,
    required this.recommendations,
    required this.timestamp,
  });
}

// ============================================================================
// EMERGENCY CONTACT
// ============================================================================
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String relationship;
  final bool isPrimary;
  final bool smsEnabled;
  final bool callEnabled;
  
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
    required this.isPrimary,
    required this.smsEnabled,
    required this.callEnabled,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'email': email,
    'relationship': relationship, 'isPrimary': isPrimary,
    'smsEnabled': smsEnabled, 'callEnabled': callEnabled,
  };
  
  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    id: json['id'], name: json['name'], phone: json['phone'],
    email: json['email'], relationship: json['relationship'],
    isPrimary: json['isPrimary'], smsEnabled: json['smsEnabled'],
    callEnabled: json['callEnabled'],
  );
}

// ============================================================================
// HEALTH ALERT
// ============================================================================
class HealthAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final double value;
  final String message;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final bool acknowledged;
  final List<String> actions;
  
  HealthAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.value,
    required this.message,
    required this.timestamp,
    this.latitude,
    this.longitude,
    required this.acknowledged,
    required this.actions,
  });
}

// ============================================================================
// ARRHYTHMIA RESULT
// ============================================================================
class ArrhythmiaResult {
  final bool hasArrhythmia;
  final ArrhythmiaType? type;
  final double confidence;
  final String? description;
  final RiskLevel riskLevel;
  final List<String> recommendations;
  
  ArrhythmiaResult({
    required this.hasArrhythmia,
    this.type,
    required this.confidence,
    this.description,
    required this.riskLevel,
    required this.recommendations,
  });
}

enum RiskLevel { none, low, moderate, high, veryHigh }

// ============================================================================
// TREND ANALYSIS
// ============================================================================
class TrendAnalysis {
  final TrendDirection direction;
  final double changePercent;
  final double changeAbsolute;
  final int dataPoints;
  final double standardDeviation;
  
  TrendAnalysis({
    required this.direction,
    required this.changePercent,
    required this.changeAbsolute,
    required this.dataPoints,
    required this.standardDeviation,
  });
}

enum TrendDirection { up, down, stable }

// ============================================================================
// COMPREHENSIVE HEALTH SCORE
// ============================================================================
class ComprehensiveScore {
  final int overallScore;
  final int heartScore;
  final int bpScore;
  final int oxygenScore;
  final int activityScore;
  final int sleepScore;
  final HealthGrade grade;
  final List<String> recommendations;
  final List<ScoreFactor> factors;
  
  ComprehensiveScore({
    required this.overallScore,
    required this.heartScore,
    required this.bpScore,
    required this.oxygenScore,
    required this.activityScore,
    required this.sleepScore,
    required this.grade,
    required this.recommendations,
    required this.factors,
  });
}

class ScoreFactor {
  final String name;
  final int weight;
  final int score;
  final String description;
  
  ScoreFactor({
    required this.name,
    required this.weight,
    required this.score,
    required this.description,
  });
}

// ============================================================================
// DEVICE DATA
// ============================================================================
class DeviceData {
  final String id;
  final String name;
  final String platform;
  final int batteryLevel;
  final int signalStrength;
  final DateTime lastSync;
  final String firmwareVersion;
  final bool isConnected;
  
  DeviceData({
    required this.id,
    required this.name,
    required this.platform,
    required this.batteryLevel,
    required this.signalStrength,
    required this.lastSync,
    required this.firmwareVersion,
    required this.isConnected,
  });
}

// ============================================================================
// DAILY SUMMARY
// ============================================================================
class DailySummary {
  final DateTime date;
  final int avgHeartRate;
  final int minHeartRate;
  final int maxHeartRate;
  final double avgHrv;
  final int avgSystolic;
  final int avgDiastolic;
  final int avgSpO2;
  final int steps;
  final int calories;
  final double distance;
  final int activeMinutes;
  final Duration totalSleep;
  final int healthScore;
  final int afibEpisodes;
  final int arrhythmiaEpisodes;
  final int fallEvents;
  final List<HealthAlert> alerts;
  
  DailySummary({
    required this.date,
    required this.avgHeartRate,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.avgHrv,
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgSpO2,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.activeMinutes,
    required this.totalSleep,
    required this.healthScore,
    required this.afibEpisodes,
    required this.arrhythmiaEpisodes,
    required this.fallEvents,
    required this.alerts,
  });
}

// ============================================================================
// AIFB DETECTION RESULT
// ============================================================================
class AfibDetectionResult {
  final bool isAfib;
  final double probability;
  final double irregularityScore;
  final double rhythmStability;
  final int rrVariability;
  final int sampleCount;
  final List<String> features;
  final String recommendation;
  
  AfibDetectionResult({
    required this.isAfib,
    required this.probability,
    required this.irregularityScore,
    required this.rhythmStability,
    required this.rrVariability,
    required this.sampleCount,
    required this.features,
    required this.recommendation,
  });
}

// ============================================================================
// STRESS ANALYSIS
// ============================================================================
class StressAnalysis {
  final double stressLevel; // 0-100
  final StressCategory category;
  final double hrvBasedStress;
  final double activityBasedStress;
  final double sleepBasedStress;
  final List<String> stressors;
  final List<String> recommendations;
  
  StressAnalysis({
    required this.stressLevel,
    required this.category,
    required this.hrvBasedStress,
    required this.activityBasedStress,
    required this.sleepBasedStress,
    required this.stressors,
    required this.recommendations,
  });
}

enum StressCategory { relaxed, mild, moderate, high, severe }
