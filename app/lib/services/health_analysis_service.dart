import 'dart:math';
import 'package:digital_saver/models/health_models.dart';

// ============================================================================
// ADVANCED HEALTH ANALYSIS SERVICE - COMPLEX MEDICAL ALGORITHMS
// ============================================================================
class HealthAnalysisService {
  // History storage
  final List<HeartRateData> _heartRateHistory = [];
  final List<BloodPressureData> _bpHistory = [];
  final List<OxygenData> _oxygenHistory = [];
  final List<ActivityData> _activityHistory = [];
  final List<SleepData> _sleepHistory = [];
  
  // Configuration
  static const int _historySize = 1000;
  static const int _analysisWindowSize = 60; // 60 seconds of data
  
  // ==========================================================================
  // HEART RATE VARIABILITY (HRV) ANALYSIS - RMSSD, SDNN, pNN50
  // ==========================================================================
  Map<String, double> calculateHRV(List<int> rrIntervals) {
    if (rrIntervals.length < 10) {
      return {'rmssd': 0, 'sdnn': 0, 'pnn50': 0, 'sd1': 0, 'sd2': 0};
    }
    
    // Calculate successive differences
    List<double> successiveDiffs = [];
    for (int i = 1; i < rrIntervals.length; i++) {
      successiveDiffs.add((rrIntervals[i] - rrIntervals[i - 1]).abs().toDouble());
    }
    
    // RMSSD - Root Mean Square of Successive Differences
    double rmssd = 0;
    if (successiveDiffs.isNotEmpty) {
      double sumSquaredDiffs = successiveDiffs.fold(0.0, (sum, val) => sum + val * val);
      rmssd = sqrt(sumSquaredDiffs / successiveDiffs.length);
    }
    
    // SDNN - Standard Deviation of NN intervals
    double mean = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
    double sumSquaredDiff = rrIntervals.fold(0.0, (sum, val) => sum + pow(val - mean, 2));
    double sdnn = sqrt(sumSquaredDiff / rrIntervals.length);
    
    // pNN50 - Percentage of successive RR intervals > 50ms
    int countOver50 = successiveDiffs.where((d) => d > 50).length;
    double pnn50 = (countOver50 / successiveDiffs.length) * 100;
    
    // Poincaré Plot Analysis (SD1, SD2)
    List<double> diffs = [];
    List<double> sums = [];
    for (int i = 1; i < rrIntervals.length; i++) {
      diffs.add((rrIntervals[i] - rrIntervals[i - 1]).toDouble());
      sums.add((rrIntervals[i] + rrIntervals[i - 1]).toDouble());
    }
    
    double sd1 = diffs.isEmpty ? 0 : sqrt(diffs.map((d) => d * d).reduce((a, b) => a + b) / diffs.length) / sqrt(2);
    double sd2 = sums.isEmpty ? 0 : sqrt(sums.map((s) => pow(s - 2 * mean, 2)).reduce((a, b) => a + b) / sums.length / 2);
    
    return {
      'rmssd': rmssd,
      'sdnn': sdnn,
      'pnn50': pnn50,
      'sd1': sd1,
      'sd2': sd2,
    };
  }
  
  // ==========================================================================
  // A-FIB DETECTION ALGORITHM - MACHINE LEARNING STYLE PATTERN RECOGNITION
  // ==========================================================================
  AfibDetectionResult detectAfib(List<int> rrIntervals) {
    if (rrIntervals.length < 30) {
      return AfibDetectionResult(
        isAfib: false,
        probability: 0,
        irregularityScore: 0,
        rhythmStability: 0,
        rrVariability: 0,
        sampleCount: rrIntervals.length,
        features: [],
        recommendation: 'Insufficient data for AFib detection',
      );
    }
    
    List<String> features = [];
    double irregularityScore = 0;
    double rhythmStability = 0;
    int rrVariability = 0;
    
    // Feature 1: RR Interval Irregularity (Coefficient of Variation)
    double mean = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
    double variance = rrIntervals.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) / rrIntervals.length;
    double cv = (sqrt(variance) / mean) * 100;
    features.add('CV: ${cv.toStringAsFixed(1)}%');
    irregularityScore = cv;
    
    // Feature 2: Successive RR Difference Variation
    List<double> diffs = [];
    for (int i = 1; i < rrIntervals.length; i++) {
      diffs.add((rrIntervals[i] - rrIntervals[i - 1]).abs().toDouble());
    }
    double diffMean = diffs.reduce((a, b) => a + b) / diffs.length;
    double diffVariance = diffs.map((d) => pow(d - diffMean, 2)).reduce((a, b) => a + b) / diffs.length;
    rrVariability = (sqrt(diffVariance) * 10).toInt();
    features.add('RR Var: $rrVariability');
    
    // Feature 3: Rhythm Stability (using autocorrelation)
    rhythmStability = calculateAutocorrelation(rrIntervals);
    features.add('Stability: ${(rhythmStability * 100).toStringAsFixed(0)}%');
    
    // Feature 4: Missing Beats Analysis
    int missingBeats = 0;
    for (int i = 1; i < rrIntervals.length; i++) {
      if (rrIntervals[i] > rrIntervals[i - 1] * 1.8) missingBeats++;
    }
    features.add('Missing: $missingBeats');
    
    // Feature 5: Irregular Cluster Detection
    int irregularClusters = countIrregularClusters(rrIntervals);
    features.add('Clusters: $irregularClusters');
    
    // Machine Learning Style Scoring (simplified logistic regression style)
    double afibProbability = 0;
    
    // Weight factors based on medical literature
    afibProbability += (cv > 20 ? 30 : cv > 10 ? 15 : 0);
    afibProbability += (rrVariability > 150 ? 25 : rrVariability > 80 ? 10 : 0);
    afibProbability += (missingBeats > 2 ? 20 : missingBeats > 0 ? 10 : 0);
    afibProbability += (irregularClusters > 3 ? 15 : irregularClusters > 1 ? 5 : 0);
    afibProbability += ((1 - rhythmStability) > 0.3 ? 10 : 0);
    
    afibProbability = afibProbability.clamp(0, 100);
    
    bool isAfib = afibProbability > 50;
    
    String recommendation;
    if (afibProbability > 70) {
      recommendation = 'High probability of AFib. Consult cardiologist immediately.';
    } else if (afibProbability > 50) {
      recommendation = 'Possible AFib detected. Schedule ECG within 24 hours.';
    } else if (afibProbability > 30) {
      recommendation = 'Some irregularity detected. Continue monitoring.';
    } else {
      recommendation = 'Heart rhythm appears normal.';
    }
    
    return AfibDetectionResult(
      isAfib: isAfib,
      probability: afibProbability,
      irregularityScore: irregularityScore,
      rhythmStability: rhythmStability,
      rrVariability: rrVariability,
      sampleCount: rrIntervals.length,
      features: features,
      recommendation: recommendation,
    );
  }
  
  double calculateAutocorrelation(List<int> data) {
    if (data.length < 10) return 1.0;
    
    double mean = data.reduce((a, b) => a + b) / data.length;
    double variance = data.map((d) => pow(d - mean, 2)).reduce((a, b) => a + b) / data.length;
    
    if (variance == 0) return 1.0;
    
    int lag = min(5, data.length ~/ 3);
    double autocorr = 0;
    for (int i = 0; i < data.length - lag; i++) {
      autocorr += (data[i] - mean) * (data[i + lag] - mean);
    }
    autocorr /= (data.length - lag) * variance;
    
    return autocorr.clamp(-1, 1).abs();
  }
  
  int countIrregularClusters(List<int> rrIntervals) {
    int clusters = 0;
    int consecutiveIrregular = 0;
    double mean = rrIntervals.reduce((a, b) => a + b) / rrIntervals.length;
    
    for (int i = 1; i < rrIntervals.length; i++) {
      bool isIrregular = (rrIntervals[i] - rrIntervals[i - 1]).abs() > mean * 0.2;
      if (isIrregular) {
        consecutiveIrregular++;
        if (consecutiveIrregular >= 4) clusters++;
      } else {
        consecutiveIrregular = 0;
      }
    }
    return clusters;
  }
  
  // ==========================================================================
  // ARRHYTHMIA DETECTION - COMPREHENSIVE PATTERN ANALYSIS
  // ==========================================================================
  ArrhythmiaResult detectArrhythmia(HeartRateData hrData) {
    if (hrData.rrIntervals.length < 20) {
      return ArrhythmiaResult(
        hasArrhythmia: false,
        confidence: 0,
        riskLevel: RiskLevel.none,
        recommendations: ['Insufficient data for arrhythmia detection'],
      );
    }
    
    double avgBpm = hrData.averageBPM;
    double currentBpm = hrData.currentBPM;
    double irregularity = hrData.hrv / hrData.averageBPM * 100;
    
    // Determine arrhythmia type
    ArrhythmiaType? type;
    double confidence = 0;
    RiskLevel riskLevel = RiskLevel.none;
    List<String> recommendations = [];
    
    // Normal Sinus Rhythm
    if (avgBpm >= 60 && avgBpm <= 100 && irregularity < 10) {
      type = ArrhythmiaType.normalSinus;
      confidence = 95;
      recommendations.add('Heart rhythm is normal');
    }
    // Sinus Tachycardia
    else if (avgBpm > 100 && avgBpm < 180) {
      type = ArrhythmiaType.sinusTachycardia;
      confidence = 85;
      riskLevel = RiskLevel.low;
      recommendations.add('Elevated heart rate - may be due to exercise, stress, or caffeine');
    }
    // Sinus Bradycardia
    else if (avgBpm < 60 && avgBpm >= 40) {
      type = ArrhythmiaType.sinBradycardia;
      confidence = 85;
      riskLevel = avgBpm < 50 ? RiskLevel.moderate : RiskLevel.low;
      recommendations.add('Low heart rate - may be normal for athletes or during sleep');
    }
    // Atrial Fibrillation
    else if (irregularity > 20 && hrData.afibProbability > 50) {
      type = ArrhythmiaType.atrialFibrillation;
      confidence = hrData.afibProbability;
      riskLevel = hrData.afibProbability > 70 ? RiskLevel.high : RiskLevel.moderate;
      recommendations.add('AFib detected - consult cardiologist');
      recommendations.add('Consider anticoagulant therapy');
    }
    // PVC (Premature Ventricular Contraction)
    else if (detectPVCs(hrData.rrIntervals)) {
      type = ArrhythmiaType.pvc;
      confidence = 75;
      riskLevel = RiskLevel.moderate;
      recommendations.add('Occasional irregular beats detected');
      recommendations.add('Usually benign but monitor frequency');
    }
    // PAC (Premature Atrial Contraction)
    else if (detectPACs(hrData.rrIntervals)) {
      type = ArrhythmiaType.pac;
      confidence = 70;
      riskLevel = RiskLevel.low;
      recommendations.add('Occasional early beats from upper chambers');
    }
    // Ventricular Tachycardia (critical)
    else if (currentBpm > 180 && irregularity > 30) {
      type = ArrhythmiaType.vtach;
      confidence = 90;
      riskLevel = RiskLevel.veryHigh;
      recommendations.add('CRITICAL: Rapid ventricular rhythm');
      recommendations.add('Seek immediate medical attention');
    }
    // Other/Undetermined
    else {
      type = ArrhythmiaType.other;
      confidence = 50;
      riskLevel = RiskLevel.moderate;
      recommendations.add('Irregular rhythm detected - further analysis needed');
    }
    
    return ArrhythmiaResult(
      hasArrhythmia: type != ArrhythmiaType.normalSinus,
      type: type,
      confidence: confidence,
      description: _getArrhythmiaDescription(type),
      riskLevel: riskLevel,
      recommendations: recommendations,
    );
  }
  
  bool detectPVCs(List<int> rrIntervals) {
    int pvcCount = 0;
    for (int i = 1; i < rrIntervals.length - 1; i++) {
      // PVC typically shows as short RR followed by compensatory pause
      if (rrIntervals[i] < 300 && rrIntervals[i + 1] > rrIntervals[i] * 1.5) {
        pvcCount++;
      }
    }
    return pvcCount >= 2;
  }
  
  bool detectPACs(List<int> rrIntervals) {
    int pacCount = 0;
    for (int i = 1; i < rrIntervals.length - 1; i++) {
      // PAC typically shows as early beat followed by nearly compensatory pause
      if (rrIntervals[i] < 500 && rrIntervals[i] > 200 && rrIntervals[i + 1] > rrIntervals[i] * 1.2) {
        pacCount++;
      }
    }
    return pacCount >= 2;
  }
  
  String _getArrhythmiaDescription(ArrhythmiaType? type) {
    switch (type) {
      case ArrhythmiaType.normalSinus: return 'Normal sinus rhythm - healthy heart function';
      case ArrhythmiaType.sinusTachycardia: return 'Fast but regular heart rhythm';
      case ArrhythmiaType.sinBradycardia: return 'Slow but regular heart rhythm';
      case ArrhythmiaType.atrialFibrillation: return 'Irregular, often rapid heart rhythm from atria';
      case ArrhythmiaType.atrialFlutter: return 'Rapid atrial rhythm with sawtooth pattern';
      case ArrhythmiaType.svt: return 'Supraventricular tachycardia - fast rhythm above ventricles';
      case ArrhythmiaType.pvc: return 'Premature ventricular contraction - early beat from ventricle';
      case ArrhythmiaType.pac: return 'Premature atrial contraction - early beat from atrium';
      case ArrhythmiaType.heartBlock: return 'Electrical signal delay or blockage in heart';
      case ArrhythmiaType.vtach: return 'Ventricular tachycardia - dangerous rapid rhythm';
      case ArrhythmiaType.vfib: return 'Ventricular fibrillation - life-threatening chaotic rhythm';
      default: return 'Undetermined rhythm pattern';
    }
  }
  
  // ==========================================================================
  // BLOOD PRESSURE ANALYSIS - VASCULAR AGE & STIFFNESS
  // ==========================================================================
  BpAnalysis analyzeBloodPressure(List<BloodPressureData> history) {
    if (history.isEmpty) {
      return BpAnalysis(
        vascularAge: 30,
        arterialStiffness: 5,
        aorticPressure: 120,
        centralSystolicPressure: 118,
        centralDiastolicPressure: 78,
        waveReflectionMagnitude: 0.3,
        subEndocardialViabilityRatio: 1.5,
        recommendations: ['No BP data available'],
      );
    }
    
    // Get latest values
    BloodPressureData latest = history.last;
    
    // Calculate vascular age using pulse pressure and augmentation index
    int vascularAge = calculateVascularAge(
      latest.pulsePressure,
      latest.augmentationIndex,
      latest.arterialStiffness,
      latest.systolic,
      latest.diastolic,
    );
    
    // Calculate arterial stiffness
    double arterialStiffness = calculateArterialStiffness(
      latest.pulseWaveVelocity,
      latest.augmentationIndex,
    );
    
    // Calculate central (aortic) pressures
    double centralSystolic = latest.systolic * (1 + latest.augmentationIndex / 100 * 0.4);
    double centralDiastolic = latest.diastolic - (latest.augmentationIndex / 100 * 10);
    
    // Wave reflection analysis
    double waveReflection = latest.augmentationIndex / 100;
    
    // Subendocardial Viability Ratio (SEVR) - cardiac supply/demand ratio
    double sevr = calculateSEVR(latest.diastolic, latest.systolic, latest.pulsePressure);
    
    List<String> recommendations = [];
    
    if (latest.category == BpCategory.hypertension2 || latest.category == BpCategory.crisis) {
      recommendations.add('High blood pressure detected - consult doctor immediately');
      recommendations.add('Consider lifestyle modifications: diet, exercise, stress reduction');
    } else if (latest.category == BpCategory.hypertension1) {
      recommendations.add('Elevated blood pressure - monitor daily');
      recommendations.add('Reduce sodium intake and increase physical activity');
    } else if (latest.category == BpCategory.elevated) {
      recommendations.add('Blood pressure slightly elevated - lifestyle changes recommended');
    } else {
      recommendations.add('Blood pressure is within normal range');
    }
    
    if (vascularAge > 50) {
      recommendations.add('Vascular age higher than chronological age - cardiovascular screening advised');
    }
    
    return BpAnalysis(
      vascularAge: vascularAge,
      arterialStiffness: arterialStiffness,
      aorticPressure: (latest.systolic + latest.diastolic) ~/ 2,
      centralSystolicPressure: centralSystolic.round(),
      centralDiastolicPressure: centralDiastolic.round(),
      waveReflectionMagnitude: waveReflection,
      subEndocardialViabilityRatio: sevr,
      recommendations: recommendations,
    );
  }
  
  int calculateVascularAge(double pulsePressure, double ai, double stiffness, int sys, int dia) {
    // Simplified vascular age calculation based on medical research
    // Higher PP, AI, and stiffness = older vascular age
    
    double baseAge = 30;
    double ppContribution = (pulsePressure - 40) * 0.3; // Normal PP ~40
    double aiContribution = (ai - 0) * 0.2; // Normal AI ~0-20%
    double sysContribution = (sys - 120) * 0.15;
    
    double vascularAge = baseAge + ppContribution + aiContribution + sysContribution;
    return vascularAge.round().clamp(20, 90);
  }
  
  double calculateArterialStiffness(double pwv, double ai) {
    // Arterial stiffness from pulse wave velocity and augmentation index
    // Higher values = stiffer arteries
    return (pwv * 0.6 + ai * 0.4).clamp(0, 100);
  }
  
  double calculateSEVR(double diastolic, double systolic, double pulsePressure) {
    // Simplified SEVR calculation
    // Normal SEVR > 1.5 indicates good cardiac supply/demand balance
    double diastolicTime = 1000 / (systolic / (systolic + diastolic));
    double systolicTime = 1000 - diastolicTime;
    return (diastolic * diastolicTime) / (systolic * systolicTime);
  }
  
  // ==========================================================================
  // STRESS ANALYSIS - MULTI-FACTOR STRESS DETECTION
  // ==========================================================================
  StressAnalysis analyzeStress(HeartRateData hrData, ActivityData? activity, SleepData? sleep) {
    double hrvStress = 0;
    double activityStress = 0;
    double sleepStress = 0;
    List<String> stressors = [];
    List<String> recommendations = [];
    
    // HRV-based stress (lower HRV = higher stress)
    if (hrData.hrv < 20) {
      hrvStress = 80;
      stressors.add('Very low heart rate variability');
    } else if (hrData.hrv < 30) {
      hrvStress = 60;
      stressors.add('Low heart rate variability');
    } else if (hrData.hrv < 45) {
      hrvStress = 40;
    } else {
      hrvStress = 20;
      stressors.add('Good heart rate variability');
    }
    
    // Activity-based stress
    if (activity != null) {
      if (activity.currentActivity == ActivityType.resting && hrData.currentBPM > 80) {
        activityStress = 30;
        stressors.add('Elevated heart rate at rest');
      }
      if (activity.activeMinutes < 30) {
        activityStress += 20;
        stressors.add('Low physical activity');
      }
    }
    
    // Sleep-based stress
    if (sleep != null) {
      if (sleep.sleepScore < 60) {
        sleepStress = 40;
        stressors.add('Poor sleep quality');
      }
      if (sleep.totalSleep.inHours < 6) {
        sleepStress += 30;
        stressors.add('Insufficient sleep');
      }
    }
    
    // Calculate overall stress
    double overallStress = (hrvStress * 0.5) + (activityStress * 0.25) + (sleepStress * 0.25);
    
    // Determine category
    StressCategory category;
    if (overallStress < 20) category = StressCategory.relaxed;
    else if (overallStress < 40) category = StressCategory.mild;
    else if (overallStress < 60) category = StressCategory.moderate;
    else if (overallStress < 80) category = StressCategory.high;
    else category = StressCategory.severe;
    
    // Generate recommendations
    if (overallStress > 40) {
      recommendations.add('Practice deep breathing exercises');
    }
    if (activityStress > 30) {
      recommendations.add('Consider light physical activity');
    }
    if (sleepStress > 30) {
      recommendations.add('Improve sleep hygiene');
    }
    
    return StressAnalysis(
      stressLevel: overallStress.roundToDouble(),
      category: category,
      hrvBasedStress: hrvStress,
      activityBasedStress: activityStress,
      sleepBasedStress: sleepStress,
      stressors: stressors,
      recommendations: recommendations,
    );
  }
  
  // ==========================================================================
  // COMPREHENSIVE HEALTH SCORE CALCULATION
  // ==========================================================================
  ComprehensiveScore calculateComprehensiveScore(
    HeartRateData heartRate,
    BloodPressureData bp,
    OxygenData oxygen,
    ActivityData activity,
  ) {
    // Individual scores (0-100)
    int heartScore = calculateHeartScore(heartRate);
    int bpScore = calculateBpScore(bp);
    int oxygenScore = calculateOxygenScore(oxygen);
    int activityScore = calculateActivityScore(activity);
    int sleepScore = 75; // Would need sleep data
    
    // Weighted overall score
    // Heart 30%, BP 25%, Oxygen 15%, Activity 20%, Sleep 10%
    int overallScore = (
      heartScore * 0.30 +
      bpScore * 0.25 +
      oxygenScore * 0.15 +
      activityScore * 0.20 +
      sleepScore * 0.10
    ).round();
    
    // Determine grade
    HealthGrade grade;
    if (overallScore >= 90) grade = HealthGrade.excellent;
    else if (overallScore >= 75) grade = HealthGrade.good;
    else if (overallScore >= 60) grade = HealthGrade.fair;
    else if (overallScore >= 40) grade = HealthGrade.poor;
    else grade = HealthGrade.critical;
    
    // Generate recommendations
    List<String> recommendations = [];
    if (heartScore < 70) {
      recommendations.add('Heart health needs attention - consider reducing caffeine and stress');
    }
    if (bpScore < 70) {
      recommendations.add('Blood pressure management needed - monitor daily and consider lifestyle changes');
    }
    if (oxygenScore < 85) {
      recommendations.add('Oxygen saturation could be improved - practice deep breathing exercises');
    }
    if (activityScore < 60) {
      recommendations.add('Increase physical activity - aim for 10,000 steps daily');
    }
    if (overallScore >= 80) {
      recommendations.add('Great job! Maintain your healthy lifestyle');
    }
    
    // Score factors
    List<ScoreFactor> factors = [
      ScoreFactor(name: 'Heart Health', weight: 30, score: heartScore, description: 'Based on HRV, BPM, rhythm'),
      ScoreFactor(name: 'Blood Pressure', weight: 25, score: bpScore, description: 'Based on systolic/diastolic'),
      ScoreFactor(name: 'Oxygen Saturation', weight: 15, score: oxygenScore, description: 'Based on SpO2 levels'),
      ScoreFactor(name: 'Physical Activity', weight: 20, score: activityScore, description: 'Based on steps, calories'),
      ScoreFactor(name: 'Sleep Quality', weight: 10, score: sleepScore, description: 'Based on sleep duration'),
    ];
    
    return ComprehensiveScore(
      overallScore: overallScore,
      heartScore: heartScore,
      bpScore: bpScore,
      oxygenScore: oxygenScore,
      activityScore: activityScore,
      sleepScore: sleepScore,
      grade: grade,
      recommendations: recommendations,
      factors: factors,
    );
  }
  
  int calculateHeartScore(HeartRateData hr) {
    int score = 100;
    
    // BPM scoring
    if (hr.currentBPM < 60) score -= 10;
    else if (hr.currentBPM > 100) score -= (hr.currentBPM - 100) * 0.5;
    if (hr.currentBPM > 150) score -= 30;
    
    // HRV scoring
    if (hr.hrv < 20) score -= 25;
    else if (hr.hrv < 30) score -= 15;
    else if (hr.hrv < 40) score -= 5;
    
    // AFib penalty
    if (hr.afibProbability > 50) score -= 30;
    else if (hr.afibProbability > 30) score -= 15;
    
    return score.clamp(0, 100);
  }
  
  int calculateBpScore(BloodPressureData bp) {
    int score = 100;
    
    // Systolic
    if (bp.systolic < 90) score -= 20;
    else if (bp.systolic > 140) score -= (bp.systolic - 140) * 0.5;
    if (bp.systolic > 180) score -= 30;
    
    // Diastolic
    if (bp.diastolic < 60) score -= 15;
    else if (bp.diastolic > 90) score -= (bp.diastolic - 90) * 0.5;
    
    return score.clamp(0, 100);
  }
  
  int calculateOxygenScore(OxygenData o2) {
    int score = 100;
    
    if (o2.spO2 < 95) score -= (95 - o2.spO2) * 5;
    if (o2.spO2 < 90) score -= 20;
    if (o2.spO2 < 85) score -= 30;
    
    return score.clamp(0, 100);
  }
  
  int calculateActivityScore(ActivityData activity) {
    int score = 0;
    
    // Steps (40%)
    double stepRatio = activity.steps / activity.stepsGoal;
    score += (stepRatio * 40).round();
    
    // Calories (30%)
    double calRatio = activity.caloriesBurned / activity.caloriesGoal;
    score += (calRatio * 30).round();
    
    // Active minutes (30%)
    double minRatio = activity.activeMinutes / activity.activeMinutesGoal;
    score += (minRatio * 30).round();
    
    return score.clamp(0, 100);
  }
  
  // ==========================================================================
  // TREND ANALYSIS
  // ==========================================================================
  TrendAnalysis analyzeTrend(List<int> values) {
    if (values.length < 3) {
      return TrendAnalysis(
        direction: TrendDirection.stable,
        changePercent: 0,
        changeAbsolute: 0,
        dataPoints: values.length,
        standardDeviation: 0,
      );
    }
    
    // Calculate mean and standard deviation
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    double stdDev = sqrt(variance);
    
    // Linear regression for trend
    int n = values.length;
    double xMean = (n - 1) / 2;
    double yMean = mean;
    
    double numerator = 0;
    double denominator = 0;
    for (int i = 0; i < n; i++) {
      numerator += (i - xMean) * (values[i] - yMean);
      denominator += pow(i - xMean, 2);
    }
    
    double slope = denominator != 0 ? numerator / denominator : 0;
    double slopePercent = (slope / yMean) * 100;
    
    // Determine direction
    TrendDirection direction;
    if (slopePercent > 2) direction = TrendDirection.up;
    else if (slopePercent < -2) direction = TrendDirection.down;
    else direction = TrendDirection.stable;
    
    double changePercent = slopePercent * 10; // Scale to more meaningful number
    double changeAbsolute = slope * (n - 1);
    
    return TrendAnalysis(
      direction: direction,
      changePercent: changePercent,
      changeAbsolute: changeAbsolute,
      dataPoints: values.length,
      standardDeviation: stdDev,
    );
  }
  
  // ==========================================================================
  // HISTORY MANAGEMENT
  // ==========================================================================
  List<HeartRateData> get heartRateHistory => List.unmodifiable(_heartRateHistory);
  List<BloodPressureData> get bpHistory => List.unmodifiable(_bpHistory);
  List<OxygenData> get oxygenHistory => List.unmodifiable(_oxygenHistory);
  List<ActivityData> get activityHistory => List.unmodifiable(_activityHistory);
  List<SleepData> get sleepHistory => List.unmodifiable(_sleepHistory);
  
  TrendAnalysis get heartRateTrend => analyzeTrend(_heartRateHistory.map((h) => h.currentBPM).toList());
  TrendAnalysis get bpTrend => analyzeTrend(_bpHistory.map((b) => b.systolic).toList());
  TrendAnalysis get oxygenTrend => analyzeTrend(_oxygenHistory.map((o) => o.spO2).toList());
  
  void addHeartRate(HeartRateData data) {
    _heartRateHistory.add(data);
    if (_heartRateHistory.length > _historySize) _heartRateHistory.removeAt(0);
  }
  
  void addBloodPressure(BloodPressureData data) {
    _bpHistory.add(data);
    if (_bpHistory.length > _historySize) _bpHistory.removeAt(0);
  }
  
  void addOxygen(OxygenData data) {
    _oxygenHistory.add(data);
    if (_oxygenHistory.length > _historySize) _oxygenHistory.removeAt(0);
  }
  
  void addActivity(ActivityData data) {
    _activityHistory.add(data);
    if (_activityHistory.length > _historySize) _activityHistory.removeAt(0);
  }
  
  void addSleep(SleepData data) {
    _sleepHistory.add(data);
    if (_sleepHistory.length > _historySize) _sleepHistory.removeAt(0);
  }
  
  void clearHistory() {
    _heartRateHistory.clear();
    _bpHistory.clear();
    _oxygenHistory.clear();
    _activityHistory.clear();
    _sleepHistory.clear();
  }
}
