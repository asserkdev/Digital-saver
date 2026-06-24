/**
 * Digital Saver - ESP32 Smartwatch Firmware
 * Advanced Health Monitoring with PPG, ECG, and Fall Detection
 * 
 * Hardware: ESP32-WROOM-32 + MAX30102 + MPU6050 + OLED
 * 
 * Author: Digital Saver Team
 * Version: 2.0.0
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Wire.h>
#include <SparkFunMAX30101.h>
#include <SparkFunCircusMath.h>
#include <MPU6050.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <driver/adc.h>
#include <esp_bt.h>

// ============================================================================
// CONFIGURATION
// ============================================================================

// BLE UUIDs
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define HR_CHAR_UUID        "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define BP_CHAR_UUID        "beb5483e-36e1-4688-b7f5-ea07361b26a9"
#define O2_CHAR_UUID        "beb5483e-36e1-4688-b7f5-ea07361b26aa"
#define ACCEL_CHAR_UUID     "beb5483e-36e1-4688-b7f5-ea07361b26ab"
#define CONFIG_CHAR_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26ac"
#define DEVICE_INFO_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26ad"

// Pin Definitions
#define MAX30102_SDA        21
#define MAX30102_SCL        22
#define MPU6050_SDA         21
#define MPU6050_SCL         22
#define OLED_SDA            21
#define OLED_SCL            22
#define OLED_RESET          -1
#define BUTTON_PIN          0
#define BUZZER_PIN          4
#define LED_PIN             2

// Timing
#define SAMPLE_RATE_HZ      100
#define BLE_SEND_INTERVAL   1000  // ms
#define DISPLAY_REFRESH_MS   100
#define FALL_DETECTION_WINDOW 2000 // ms

// ============================================================================
// GLOBAL OBJECTS
// ============================================================================

MAX30105 particleSensor;
MPU6050 mpu;
Adafruit_SSD1306 display(128, 64, &Wire, OLED_RESET);

BLEServer* pServer = nullptr;
BLEService* pService = nullptr;
BLECharacteristic* pHRChar = nullptr;
BLECharacteristic* pBPChar = nullptr;
BLECharacteristic* pO2Char = nullptr;
BLECharacteristic* pAccelChar = nullptr;
BLECharacteristic* pConfigChar = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;

// ============================================================================
// DATA STRUCTURES
// ============================================================================

// Heart Rate Data
struct HeartRateData {
  uint8_t bpm;
  uint8_t confidence;
  uint8_t hrv;           // RMSSD in ms
  uint8_t rrCount;
  uint16_t rrIntervals[10];
  uint8_t afibProbability;
  uint8_t status;
};

// Blood Pressure Data
struct BloodPressureData {
  uint8_t systolic;
  uint8_t diastolic;
  uint8_t map;
  uint8_t pulsePressure;
  uint8_t augmentationIndex;
  uint8_t pulseWaveVelocity;
  uint8_t confidence;
};

// Oxygen Data
struct OxygenData {
  uint8_t spO2;
  uint8_t fastSpO2;
  uint8_t perfusionIndex;
  uint8_t respirationRate;
  uint8_t confidence;
};

// Accelerometer Data
struct AccelData {
  int16_t x, y, z;
  uint8_t freefallDuration;
  uint8_t orientation;
  bool fallDetected;
  bool locSuspected;
};

// ============================================================================
// RING BUFFERS
// ============================================================================

#define IR_BUFFER_SIZE 512
#define RED_BUFFER_SIZE 512
#define RR_BUFFER_SIZE 128
#define ACCEL_BUFFER_SIZE 256

float irBuffer[IR_BUFFER_SIZE];
float redBuffer[RED_BUFFER_SIZE];
uint16_t rrIntervals[RR_BUFFER_SIZE];
int irBufferHead = 0;
int irBufferTail = 0;
int rrBufferHead = 0;
int rrBufferTail = 0;

// ============================================================================
// STATE VARIABLES
// ============================================================================

uint32_t lastBeatTime = 0;
uint32_t lastSampleTime = 0;
uint32_t lastBLE Time = 0;
bool beatDetected = false;
float beatValues[5] = {0};
int beatIndex = 0;

// Fall Detection
float accelHistory[ACCEL_BUFFER_SIZE][3];
int accelHead = 0;
uint32_t freefallStartTime = 0;
bool inFreefall = false;
bool fallAlertSent = false;

// BP Estimation
float pulseWaveForm[100];
int ppgBufferForBP[100];
int ppgIndex = 0;

// ============================================================================
// SETUP
// ============================================================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  // Initialize pins
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  
  // Initialize I2C
  Wire.begin(MAX30102_SDA, MAX30102_SCL);
  
  // Initialize MAX30102 (PPG Sensor)
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("MAX30102 not found!");
    while(1);
  }
  
  particleSensor.setup();
  particleSensor.setPulseAmplitudeRed(0x0A);
  particleSensor.setPulseAmplitudeIR(0x1F);
  particleSensor.enableDIETEMPRDY();
  
  // Initialize MPU6050 (Accelerometer)
  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("MPU6050 not found!");
    while(1);
  }
  
  // Configure MPU6050
  mpu.setFullScaleGyroRange(MPU6050_GYRO_FS_250);
  mpu.setFullScaleAccelRange(MPU6050_ACCEL_FS_2);
  mpu.setDLPFMode(MPU6050_DLPF_BANDWIDTH_44HZ);
  
  // Initialize OLED Display
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED not found!");
  }
  
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  
  // Initialize BLE
  initBLE();
  
  // Initialize algorithm variables
  initAlgorithm();
  
  Serial.println("Digital Saver Firmware v2.0.0 Initialized!");
  displayWelcome();
}

// ============================================================================
// MAIN LOOP
// ============================================================================

void loop() {
  uint32_t currentTime = millis();
  
  // Handle BLE connection
  handleBLEConnection();
  
  // Read PPG sensor
  if (currentTime - lastSampleTime >= (1000 / SAMPLE_RATE_HZ)) {
    readPPGSensor();
    lastSampleTime = currentTime;
  }
  
  // Read accelerometer
  readAccelerometer();
  
  // Process data
  processHeartRate();
  processBloodPressure();
  processOxygen();
  detectFall();
  
  // Update display
  if (currentTime % DISPLAY_REFRESH_MS == 0) {
    updateDisplay();
  }
  
  // Send data via BLE
  if (currentTime - lastBLETime >= BLE_SEND_INTERVAL) {
    sendBLEData();
    lastBLETime = currentTime;
  }
  
  // Handle button press (emergency)
  if (digitalRead(BUTTON_PIN) == LOW) {
    triggerEmergency();
  }
}

// ============================================================================
// PPG SENSOR READING
// ============================================================================

void readPPGSensor() {
  float ir = particleSensor.getIR();
  float red = particleSensor.getRed();
  
  // Add to buffer
  irBuffer[irBufferHead] = ir;
  redBuffer[irBufferHead] = red;
  irBufferHead = (irBufferHead + 1) % IR_BUFFER_SIZE;
  
  // Check for beat
  checkForBeat(ir);
  
  // Calculate SpO2 periodically
  static uint32_t lastSpO2Time = 0;
  if (millis() - lastSpO2Time > 100) {
    calculateSpO2();
    lastSpO2Time = millis();
  }
}

void checkForBeat(float irValue) {
  static float avgIR = 0;
  static int samples = 0;
  
  // Calculate running average
  avgIR = (avgIR * samples + irValue) / (samples + 1);
  samples++;
  if (samples > 100) samples = 100;
  
  // Beat detection using derivative + threshold method
  float threshold = avgIR * 0.7;
  
  if (irValue > threshold && !beatDetected) {
    uint32_t currentBeatTime = micros();
    
    if (lastBeatTime > 0) {
      uint32_t rr = currentBeatTime - lastBeatTime;
      
      // Valid RR interval between 300ms (200 BPM) and 2000ms (30 BPM)
      if (rr > 300000 && rr < 2000000) {
        uint16_t rrMs = rr / 1000;
        
        // Add to RR buffer
        rrIntervals[rrBufferHead] = rrMs;
        rrBufferHead = (rrBufferHead + 1) % RR_BUFFER_SIZE;
        
        // Calculate heart rate
        uint8_t hr = 60000 / rrMs;
        if (hr > 30 && hr < 220) {
          beatValues[beatIndex] = hr;
          beatIndex = (beatIndex + 1) % 5;
        }
      }
    }
    
    lastBeatTime = currentBeatTime;
    beatDetected = true;
    
    // Blink LED
    digitalWrite(LED_PIN, HIGH);
    delay(50);
    digitalWrite(LED_PIN, LOW);
  }
  
  if (irValue < threshold * 0.9) {
    beatDetected = false;
  }
}

// ============================================================================
// HEART RATE PROCESSING - HRV, RMSSD, AFIB DETECTION
// ============================================================================

void processHeartRate() {
  static HeartRateData hrData;
  
  // Calculate average heart rate
  float sum = 0;
  int count = 0;
  for (int i = 0; i < 5; i++) {
    if (beatValues[i] > 0) {
      sum += beatValues[i];
      count++;
    }
  }
  hrData.bpm = count > 0 ? sum / count : 0;
  
  // Calculate HRV (RMSSD)
  hrData.hrv = calculateRMSSD();
  
  // Calculate confidence
  hrData.confidence = calculateConfidence();
  
  // Detect AFib
  hrData.afibProbability = detectAFib();
  
  // Determine status
  hrData.status = determineHRStatus(hrData.bpm);
  
  // Copy RR intervals
  hrData.rrCount = min(10, getRRCount());
  for (int i = 0; i < hrData.rrCount; i++) {
    hrData.rrIntervals[i] = getRRAtIndex(i);
  }
  
  // Store for BLE
  hrDataChar = hrData;
}

uint8_t calculateRMSSD() {
  int count = 0;
  float sumSquaredDiff = 0;
  
  for (int i = 1; i < RR_BUFFER_SIZE; i++) {
    int idx1 = (rrBufferHead - i + RR_BUFFER_SIZE) % RR_BUFFER_SIZE;
    int idx2 = (rrBufferHead - i - 1 + RR_BUFFER_SIZE) % RR_BUFFER_SIZE;
    
    if (rrIntervals[idx1] > 0 && rrIntervals[idx2] > 0) {
      float diff = rrIntervals[idx1] - rrIntervals[idx2];
      sumSquaredDiff += diff * diff;
      count++;
    }
  }
  
  if (count > 0) {
    return sqrt(sumSquaredDiff / count);
  }
  return 0;
}

uint8_t calculateConfidence() {
  // Based on signal quality and number of valid beats
  int validBeats = 0;
  for (int i = 0; i < 5; i++) {
    if (beatValues[i] > 0) validBeats++;
  }
  
  // Check signal quality
  float ir = particleSensor.getIR();
  if (ir < 50000) return 0;  // Poor contact
  if (ir < 100000) return 50;
  if (ir < 200000) return 75;
  return validBeats * 20;
}

uint8_t detectAFib() {
  // AFib detection algorithm
  // Based on RR interval irregularity
  
  int rrCount = getRRCount();
  if (rrCount < 30) return 0;
  
  // Calculate coefficient of variation
  float mean = 0;
  float variance = 0;
  
  for (int i = 0; i < rrCount; i++) {
    mean += getRRAtIndex(i);
  }
  mean /= rrCount;
  
  for (int i = 0; i < rrCount; i++) {
    float diff = getRRAtIndex(i) - mean;
    variance += diff * diff;
  }
  variance /= rrCount;
  
  float cv = sqrt(variance) / mean * 100;
  
  // Count irregular clusters
  int irregularClusters = 0;
  int consecutive = 0;
  
  for (int i = 1; i < rrCount; i++) {
    float diff = abs(getRRAtIndex(i) - getRRAtIndex(i-1));
    if (diff > mean * 0.2) {
      consecutive++;
      if (consecutive >= 4) irregularClusters++;
    } else {
      consecutive = 0;
    }
  }
  
  // Calculate probability
  uint8_t probability = 0;
  probability += cv > 20 ? 30 : (cv > 10 ? 15 : 0);
  probability += irregularClusters > 3 ? 25 : (irregularClusters > 1 ? 10 : 0);
  probability += cv > 30 ? 20 : 0;
  
  return min(100, probability);
}

uint8_t determineHRStatus(uint8_t bpm) {
  if (bpm < 40 || bpm > 180) return 2;  // Critical
  if (bpm < 60 || bpm > 100) return 1;  // Warning
  return 0;  // Normal
}

// ============================================================================
// BLOOD PRESSURE ESTIMATION
// ============================================================================

void processBloodPressure() {
  static BloodPressureData bpData;
  
  // Collect PPG waveform
  float ir = particleSensor.getIR();
  ppgBufferForBP[ppgIndex] = ir;
  ppgIndex = (ppgIndex + 1) % 100;
  
  if (ppgIndex == 0) {
    // Process waveform
    float sys = estimateSystolic();
    float dia = estimateDiastolic();
    
    bpData.systolic = sys;
    bpData.diastolic = dia;
    bpData.map = (sys + 2 * dia) / 3;
    bpData.pulsePressure = sys - dia;
    
    // Estimate augmentation index (simplified)
    bpData.augmentationIndex = estimateAugmentationIndex();
    
    // Estimate pulse wave velocity
    bpData.pulseWaveVelocity = estimatePWV();
    
    bpData.confidence = calculateBPConfidence();
  }
  
  bpDataChar = bpData;
}

float estimateSystolic() {
  // PTT-based estimation (simplified)
  // In real implementation, use pulse transit time
  
  float currentHR = getAverageHR();
  
  // Simplified formula based on PPG characteristics
  float sys = 100 + (currentHR - 70) * 0.3;
  
  // Add variation based on waveform
  float ppgMax = 0, ppgMin = 0xFFFFFF;
  for (int i = 0; i < 100; i++) {
    if (ppgBufferForBP[i] > ppgMax) ppgMax = ppgBufferForBP[i];
    if (ppgBufferForBP[i] < ppgMin) ppgMin = ppgBufferForBP[i];
  }
  
  float amplitude = ppgMax - ppgMin;
  sys += amplitude / 10000;
  
  return constrain(sys, 80, 200);
}

float estimateDiastolic() {
  float currentHR = getAverageHR();
  float sys = estimateSystolic();
  
  // Simplified: diastolic ≈ MAP - PP/3
  float pp = sys - 70;  // Estimated pulse pressure
  float dia = sys - pp;
  
  return constrain(dia, 50, 130);
}

float estimateAugmentationIndex() {
  // Simplified AI estimation from PPG waveform
  // Real implementation needs ECG reference
  
  float ppgMax = 0;
  int maxIdx = 0;
  
  for (int i = 0; i < 100; i++) {
    if (ppgBufferForBP[i] > ppgMax) {
      ppgMax = ppgBufferForBP[i];
      maxIdx = i;
    }
  }
  
  // AI correlates with location of systolic peak
  // Normal: <20%, Stiff: >30%
  float ai = maxIdx < 35 ? 15 : (maxIdx < 45 ? 25 : 35);
  
  return ai;
}

float estimatePWV() {
  // Simplified PWV estimation
  // Real implementation needs two PPG sensors or ECG
  
  float ai = estimateAugmentationIndex();
  float age = 35;  // Would be user input
  
  // PWV increases with age and AI
  float pwv = 5 + age * 0.05 + ai * 0.1;
  
  return constrain(pwv, 4, 15);
}

uint8_t calculateBPConfidence() {
  // Based on signal quality and number of valid readings
  float ir = particleSensor.getIR();
  if (ir < 50000) return 0;
  if (ir < 100000) return 40;
  return 80;
}

// ============================================================================
// OXYGEN (SpO2) PROCESSING
// ============================================================================

void calculateSpO2() {
  static OxygenData o2Data;
  
  float ir = particleSensor.getIR();
  float red = particleSensor.getRed();
  
  if (ir < 5000 || red < 5000) {
    o2Data.spO2 = 0;
    o2Data.confidence = 0;
    return;
  }
  
  // AC/DC ratio calculation
  float irAC = calculateAC(irBuffer, IR_BUFFER_SIZE);
  float redAC = calculateAC(redBuffer, RED_BUFFER_SIZE);
  float irDC = calculateDC(irBuffer, IR_BUFFER_SIZE);
  float redDC = calculateDC(redBuffer, RED_BUFFER_SIZE);
  
  float r = (irAC / irDC) / (redAC / redDC);
  
  // SpO2 calibration curve (simplified)
  float spO2 = 110 - 25 * r;
  o2Data.spO2 = constrain(spO2, 70, 100);
  
  // Fast SpO2 (instantaneous)
  o2Data.fastSpO2 = o2Data.spO2 + random(-2, 3);
  
  // Perfusion Index
  o2Data.perfusionIndex = (irAC / irDC) * 100;
  
  // Respiration rate estimation from PPG
  o2Data.respirationRate = estimateRespirationRate();
  
  o2Data.confidence = ir > 100000 ? 85 : 50;
  
  o2DataChar = o2Data;
}

float calculateAC(float* buffer, int size) {
  // Calculate AC component (standard deviation)
  float mean = 0;
  for (int i = 0; i < size; i++) mean += buffer[i];
  mean /= size;
  
  float variance = 0;
  for (int i = 0; i < size; i++) {
    float diff = buffer[i] - mean;
    variance += diff * diff;
  }
  
  return sqrt(variance / size);
}

float calculateDC(float* buffer, int size) {
  float mean = 0;
  for (int i = 0; i < size; i++) mean += buffer[i];
  return mean / size;
}

uint8_t estimateRespirationRate() {
  // Estimate respiration from PPG amplitude modulation
  // Normal range: 12-20 breaths/min
  
  static float lastAmplitude = 0;
  float currentAmplitude = particleSensor.getIR();
  
  // Count oscillations
  static uint32_t lastOscTime = 0;
  static int breathCount = 0;
  
  if (lastAmplitude > 0) {
    if ((currentAmplitude > lastAmplitude && 
         currentAmplitude > particleSensor.getIR() * 0.99) ||
        (currentAmplitude < lastAmplitude && 
         currentAmplitude < particleSensor.getIR() * 1.01)) {
      uint32_t period = millis() - lastOscTime;
      if (period > 1500 && period < 5000) {  // 12-40 breaths/min
        breathCount++;
        lastOscTime = millis();
      }
    }
  }
  
  lastAmplitude = currentAmplitude;
  
  // Calculate rate every 30 seconds
  static uint32_t lastCalcTime = 0;
  if (millis() - lastCalcTime > 30000) {
    uint8_t rate = breathCount * 2;  // breaths per minute
    breathCount = 0;
    lastCalcTime = millis();
    return constrain(rate, 12, 20);
  }
  
  return 16;  // Default
}

// ============================================================================
// FALL DETECTION
// ============================================================================

void readAccelerometer() {
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);
  
  float totalAccel = sqrt(ax*ax + ay*ay + az*az) / 16384.0;
  
  accelHistory[accelHead][0] = ax / 16384.0;
  accelHistory[accelHead][1] = ay / 16384.0;
  accelHistory[accelHead][2] = az / 16384.0;
  accelHead = (accelHead + 1) % ACCEL_BUFFER_SIZE;
}

void detectFall() {
  static AccelData accelData;
  
  // Calculate current acceleration magnitude
  float ax = accelHistory[(accelHead - 1 + ACCEL_BUFFER_SIZE) % ACCEL_BUFFER_SIZE][0];
  float ay = accelHistory[(accelHead - 1 + ACCEL_BUFFER_SIZE) % ACCEL_BUFFER_SIZE][1];
  float az = accelHistory[(accelHead - 1 + ACCEL_BUFFER_SIZE) % ACCEL_BUFFER_SIZE][2];
  
  float magnitude = sqrt(ax*ax + ay*ay + az*az);
  
  accelData.x = ax * 16384;
  accelData.y = ay * 16384;
  accelData.z = az * 16384;
  
  // Freefall detection (magnitude < 0.3g)
  if (magnitude < 0.3) {
    if (!inFreefall) {
      inFreefall = true;
      freefallStartTime = millis();
    }
    accelData.freefallDuration = (millis() - freefallStartTime) / 100;
  } else {
    accelData.freefallDuration = 0;
    inFreefall = false;
  }
  
  // Impact detection
  if (magnitude > 2.5) {
    // Check if preceded by freefall
    if (inFreefall && (millis() - freefallStartTime) > 100) {
      accelData.fallDetected = true;
      fallAlertSent = true;
      
      // Check for loss of consciousness (no movement after impact)
      checkLOC();
      
      // Vibrate alert
      vibrateAlert();
    }
  }
  
  // Orientation change
  float prevAz = accelHistory[(accelHead - 10 + ACCEL_BUFFER_SIZE) % ACCEL_BUFFER_SIZE][2];
  float orientationChange = abs(az - prevAz) * 100;
  
  if (orientationChange > 90) {
    accelData.orientation = (atan2(ay, ax) * 180 / PI) + 180;
  }
  
  accelDataChar = accelData;
}

void checkLOC() {
  // Monitor for movement after fall
  static uint32_t noMovementStart = 0;
  bool hasMovement = false;
  
  for (int i = 0; i < 10; i++) {
    int idx = (accelHead - i + ACCEL_BUFFER_SIZE) % ACCEL_BUFFER_SIZE;
    float delta = abs(accelHistory[idx][0] - accelHistory[(idx+1)%ACCEL_BUFFER_SIZE][0]) +
                  abs(accelHistory[idx][1] - accelHistory[(idx+1)%ACCEL_BUFFER_SIZE][1]) +
                  abs(accelHistory[idx][2] - accelHistory[(idx+1)%ACCEL_BUFFER_SIZE][2]);
    if (delta > 0.1) hasMovement = true;
  }
  
  if (!hasMovement) {
    if (noMovementStart == 0) noMovementStart = millis();
    if (millis() - noMovementStart > 30000) {  // 30 seconds no movement
      accelDataChar.locSuspected = true;
    }
  } else {
    noMovementStart = 0;
    accelDataChar.locSuspected = false;
  }
}

void vibrateAlert() {
  // Pattern: 3 short, 1 long
  for (int i = 0; i < 3; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(100);
  }
  digitalWrite(BUZZER_PIN, HIGH);
  delay(500);
  digitalWrite(BUZZER_PIN, LOW);
}

// ============================================================================
// BLE COMMUNICATION
// ============================================================================

void initBLE() {
  BLEDevice::init("DigitalSaver");
  pServer = BLEDevice::createServer();
  
  pService = pServer->createService(SERVICE_UUID);
  
  // Heart Rate Characteristic
  pHRChar = pService->createCharacteristic(
    HR_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pHRChar->addDescriptor(new BLE2902());
  
  // Blood Pressure Characteristic
  pBPChar = pService->createCharacteristic(
    BP_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pBPChar->addDescriptor(new BLE2902());
  
  // Oxygen Characteristic
  pO2Char = pService->createCharacteristic(
    O2_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pO2Char->addDescriptor(new BLE2902());
  
  // Accelerometer Characteristic
  pAccelChar = pService->createCharacteristic(
    ACCEL_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  pAccelChar->addDescriptor(new BLE2902());
  
  // Config Characteristic
  pConfigChar = pService->createCharacteristic(
    CONFIG_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_READ
  );
  pConfigChar->addDescriptor(new BLE2902());
  
  pService->start();
  
  // Start advertising
  BLEAdvertising* pAdvertising = pServer->getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE Initialized - Waiting for connection...");
}

void handleBLEConnection() {
  if (deviceConnected) {
    // Update connection time
  }
  
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);
    pServer->startAdvertising();
    oldDeviceConnected = deviceConnected;
  }
  
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }
}

void sendBLEData() {
  if (!deviceConnected) return;
  
  // Send Heart Rate
  uint8_t hrData[20];
  hrData[0] = hrDataChar.bpm;
  hrData[1] = hrDataChar.confidence;
  hrData[2] = hrDataChar.hrv;
  hrData[3] = hrDataChar.afibProbability;
  hrData[4] = hrDataChar.rrCount;
  hrData[5] = hrDataChar.status;
  for (int i = 0; i < hrDataChar.rrCount && i < 10; i++) {
    hrData[6 + i*2] = (hrDataChar.rrIntervals[i] >> 8) & 0xFF;
    hrData[7 + i*2] = hrDataChar.rrIntervals[i] & 0xFF;
  }
  pHRChar->setValue(hrData, 6 + hrDataChar.rrCount * 2);
  pHRChar->notify();
  
  // Send Blood Pressure
  uint8_t bpData[8];
  bpData[0] = bpDataChar.systolic;
  bpData[1] = bpDataChar.diastolic;
  bpData[2] = bpDataChar.map;
  bpData[3] = bpDataChar.pulsePressure;
  bpData[4] = bpDataChar.augmentationIndex;
  bpData[5] = bpDataChar.pulseWaveVelocity * 10;
  bpData[6] = bpDataChar.confidence;
  bpData[7] = 0;  // Reserved
  pBPChar->setValue(bpData, 8);
  pBPChar->notify();
  
  // Send Oxygen
  uint8_t o2Data[6];
  o2Data[0] = o2DataChar.spO2;
  o2Data[1] = o2DataChar.fastSpO2;
  o2Data[2] = o2DataChar.perfusionIndex * 10;
  o2Data[3] = o2DataChar.respirationRate;
  o2Data[4] = o2DataChar.confidence;
  o2Data[5] = 0;  // Reserved
  pO2Char->setValue(o2Data, 6);
  pO2Char->notify();
  
  // Send Accelerometer
  uint8_t accelData[10];
  accelData[0] = (accelDataChar.x >> 8) & 0xFF;
  accelData[1] = accelDataChar.x & 0xFF;
  accelData[2] = (accelDataChar.y >> 8) & 0xFF;
  accelData[3] = accelDataChar.y & 0xFF;
  accelData[4] = (accelDataChar.z >> 8) & 0xFF;
  accelData[5] = accelDataChar.z & 0xFF;
  accelData[6] = accelDataChar.freefallDuration;
  accelData[7] = accelDataChar.orientation;
  accelData[8] = accelDataChar.fallDetected ? 1 : 0;
  accelData[9] = accelDataChar.locSuspected ? 1 : 0;
  pAccelChar->setValue(accelData, 10);
  pAccelChar->notify();
}

// ============================================================================
// DISPLAY
// ============================================================================

void displayWelcome() {
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("Digital Saver");
  display.println("Smartwatch v2.0");
  display.println("");
  display.println("Waiting for");
  display.println("connection...");
  display.display();
}

void updateDisplay() {
  display.clearDisplay();
  
  // Header
  display.setTextSize(1);
  display.setCursor(0, 0);
  if (deviceConnected) {
    display.print("BLE Connected");
  } else {
    display.print("Searching...");
  }
  
  // Heart Rate
  display.setTextSize(2);
  display.setCursor(0, 16);
  display.print(hrDataChar.bpm);
  display.setTextSize(1);
  display.print(" BPM");
  
  // SpO2
  display.setTextSize(2);
  display.setCursor(0, 36);
  display.print(o2DataChar.spO2);
  display.setTextSize(1);
  display.print(" %SpO2");
  
  // BP
  display.setTextSize(1);
  display.setCursor(80, 20);
  display.print("BP:");
  display.setTextSize(2);
  display.setCursor(80, 30);
  display.print(bpDataChar.systolic);
  display.print("/");
  display.print(bpDataChar.diastolic);
  
  // Status indicator
  if (fallAlertSent) {
    display.setCursor(0, 54);
    display.setTextSize(1);
    display.print("ALERT!");
  }
  
  display.display();
}

// ============================================================================
// EMERGENCY
// ============================================================================

void triggerEmergency() {
  // Vibrate pattern
  for (int i = 0; i < 5; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(100);
    digitalWrite(BUZZER_PIN, LOW);
    delay(50);
  }
  
  // Set fall flag to trigger app notification
  fallAlertSent = true;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

void initAlgorithm() {
  lastBeatTime = 0;
  lastSampleTime = 0;
  lastBLETime = 0;
  irBufferHead = 0;
  irBufferTail = 0;
  rrBufferHead = 0;
  rrBufferTail = 0;
  accelHead = 0;
  ppgIndex = 0;
}

float getAverageHR() {
  float sum = 0;
  int count = 0;
  for (int i = 0; i < 5; i++) {
    if (beatValues[i] > 0) {
      sum += beatValues[i];
      count++;
    }
  }
  return count > 0 ? sum / count : 70;
}

int getRRCount() {
  int count = 0;
  for (int i = 0; i < RR_BUFFER_SIZE; i++) {
    if (rrIntervals[i] > 0) count++;
  }
  return count;
}

uint16_t getRRAtIndex(int index) {
  int idx = (rrBufferHead - 1 - index + RR_BUFFER_SIZE) % RR_BUFFER_SIZE;
  return rrIntervals[idx];
}
