# 🖥️ Onyx Smartwatch - Complete Build Guide

## Cambric Digital Saver Ecosystem

**© 2026 Cambric. All Rights Reserved.**
**Product:** Onyx Smartwatch | **Platform:** Digital Saver | **Company:** Cambric

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Hardware Components](#hardware-components)
3. [Tools & Equipment Guide](#tools--equipment-guide)
4. [Bill of Materials (BOM)](#bill-of-materials-bom)
5. [PCB Design](#pcb-design)
6. [Firmware Setup](#firmware-setup)
7. [Sensor Integration](#sensor-integration)
8. [Assembly Guide](#assembly-guide)
9. [Testing & Calibration](#testing--calibration)
10. [外壳设计 (Case Design)](#外壳设计-case-design)
11. [Production Guide](#production-guide)
12. [Troubleshooting](#troubleshooting)
13. [Safety Guidelines](#safety-guidelines)

---

## 🔍 Overview

The **Onyx Smartwatch** is a medical-grade health monitoring wearable developed by **Cambric** as part of the Digital Saver health ecosystem. It features real-time heart rate monitoring, blood oxygen tracking, step counting, and sleep analysis.

### Key Features
- **Heart Rate Monitor** - MAX30102 pulse oximeter
- **Motion Tracking** - MPU6050 accelerometer/gyroscope
- **Blood Oxygen (SpO2)** - MAX30102 sensor
- **Step Counting** - Accelerometer-based algorithm
- **Sleep Analysis** - Movement pattern recognition
- **Emergency Alerts** - SOS button with GPS
- **Bluetooth LE** - Seamless smartphone connectivity
- **7-Day Battery** - Optimized power management

---

## 🔧 Hardware Components

### Core Components

| Component | Model | Purpose | Price (EGP) |
|-----------|-------|--------|-------------|
| Main MCU | ESP32-WROOM-32 | Processing & Bluetooth | 120 |
| Heart Rate | MAX30102 | Pulse oximetry | 180 |
| Motion | MPU6050 | Accelerometer/Gyro | 45 |
| Display | 1.3" OLED I2C | User interface | 85 |
| Battery | 350mAh LiPo | Power | 35 |
| Buck/Boost | TP4056/MT3608 | Power management | 25 |
| Crystal | 32.768kHz | Real-time clock | 5 |
| PCB | Custom 4-layer | Circuit board | 50 |

### Supporting Components

| Component | Value | Quantity | Price (EGP) |
|-----------|-------|----------|-------------|
| Resistors | 10K, 100R, 1K | 20 | 5 |
| Capacitors | 100nF, 10µF | 15 | 8 |
| Diodes | 1N4007, SS34 | 5 | 5 |
| LEDs | Red/Green/Blue | 3 | 6 |
| Buttons | 6x6x5mm | 4 | 8 |
| Connector | JST-PH 2-pin | 3 | 15 |
| Enclosure | 3D Printed | 1 | - |

### Total Cost: ~**592 EGP** per unit

---

## 🔧 Tools & Equipment Guide

### Essential Tools (Cannot Build Without)

| Item | Specifications | Price (EGP) | Where to Buy |
|------|---------------|--------------|--------------|
| **Soldering Iron Kit** | 60W, adjustable 200-450°C | 350-500 | RoboDyn Egypt |
| **Solder Wire** | 60/40 leaded, 0.8mm, 100g | 80 | RoboDyn Egypt |
| **Soldering Flux** | Rosin flux pen | 50 | RoboDyn Egypt |
| **Digital Multimeter** | DC/AC, continuity tester | 200-400 | RoboDyn Egypt |
| **USB-C Cable** | For ESP32 upload | 50-100 | Any shop |
| **Precision Screwdriver Set** | 4-6 pieces, PH0, PH1 | 80-150 | RoboDyn Egypt |
| **Wire Strippers** | For 20-30 AWG wire | 80-150 | RoboDyn Egypt |
| **Flush Cutters** | For component leads | 60-100 | RoboDyn Egypt |
| **Tweezers Set** | 2-3 pieces, anti-static | 50-100 | RoboDyn Egypt |

### Recommended Tool Kit (All-in-One)
- **Yihua 936D+ Soldering Station** ~450 EGP
- Includes: Iron, stand, sponge, tips

### Soldering Accessories

| Item | Use | Price (EGP) |
|------|-----|--------------|
| **Brass Wool** | Clean iron tip | 40 |
| **Solder Wick** | Remove excess solder | 30 |
| **Helping Hands** | Hold components | 80 |
| **IPA (99%)** | Clean PCBs | 40 |
| **Double-Sided Tape** | Mount components | 25 |
| **Hot Glue Gun** | Secure battery, wires | 60 |

### Testing & Debugging Tools

| Item | Use | Price (EGP) |
|------|-----|--------------|
| **Logic Analyzer** | Debug I2C, SPI | 400-800 |
| **USB-Serial Converter** | Upload firmware | 50-100 |

### Tool Buying Checklist

```
□ Soldering Station (60W+)
□ Solder Wire (60/40, 0.8mm)
□ Flux Pen
□ Brass Wool (for cleaning iron)
□ Digital Multimeter
□ Precision Screwdriver Set
□ Wire Strippers
□ Flush Cutters
□ Tweezers Set
□ Helping Hands
□ Solder Wick
□ Isopropyl Alcohol (99%)
□ Double-Sided Tape
□ Hot Glue Gun
□ USB-C Cable
□ Jumper Wires
□ Hookup Wire (various colors)
```

**Estimated Tool Total: ~1,500-2,000 EGP**

### How to Solder (Step by Step)

**Basic Through-Hole Soldering:**
1. Clean tip on brass wool
2. Set iron to 350°C (lead solder) or 380°C (lead-free)
3. Heat BOTH component lead AND pad for 2 seconds
4. Touch solder to joint (NOT the iron)
5. Remove solder, then iron
6. Inspect joint: should be shiny, cone-shaped

**I2C Connections (Female Headers):**
1. Place female headers on ESP32 pins
2. Hold headers flat against PCB
3. Solder ONE pin
4. Check alignment, adjust if crooked
5. Solder remaining pins

### Testing with Multimeter

**Continuity Test (Check for Shorts):**
1. Set multimeter to continuity mode (beeper icon)
2. Touch probes together - should beep
3. Probe component leads - check connections
4. If beeps between VCC and GND = BAD (short circuit!)

**Measure Voltage:**
1. Set to DC voltage (20V range)
2. Black probe to GND
3. Red probe to point to test
4. Read display

**Check ESP32 3.3V Power:**
- ESP32 3V3 pin should read: 3.2V - 3.4V (GOOD)
- If reads 0V = no power
- If reads 5V = WRONG VOLTAGE (will damage sensors!)

---

## 📦 Bill of Materials (BOM)

### Essential Components

```
ESP32-WROOM-32 x1
├── Package: SMD Module
├── Flash: 4MB
├── Bluetooth: BLE 4.2
└── WiFi: 802.11 b/g/n

MAX30102 x1
├── I2C Address: 0x57
├── LED Drive Current: 0-50mA
├── Sample Rate: 100-1000Hz
└── Cable: 4-pin JST

MPU6050 x1
├── I2C Address: 0x68
├── Accelerometer: ±16g
├── Gyroscope: ±2000°/s
└── Cable: 4-pin JST

OLED Display 1.3" x1
├── Resolution: 128x64
├── Interface: I2C (SSD1306)
├── Address: 0x3C
└── Cable: 4-pin JST

LiPo Battery 350mAh x1
├── Voltage: 3.7V
├── Connector: JST-PH 2-pin
└── Dimensions: 35x20x5mm
```

---

## 🔌 PCB Design

### Pin Mapping

```
ESP32 GPIO Map:
├── I2C_SDA (GPIO21) ─── MAX30102 SDA, MPU6050 SDA, OLED SDA
├── I2C_SCL (GPIO22) ─── MAX30102 SCL, MPU6050 SCL, OLED SCL
├── GPIO27 ─── MAX30102 INT (interrupt)
├── GPIO25 ─── Battery ADC (via voltage divider)
├── GPIO26 ─── Button 1 (Power/Menu)
├── GPIO33 ─── Button 2 (Back)
├── GPIO32 ─── Button 3 (SOS/Emergency)
├── GPIO15 ─── Button 4 (Confirm)
├── GPIO05 ─── Vibrating Motor
├── GPIO18 ─── Green LED
├── GPIO19 ─── Blue LED
├── GPIO02 ─── Red LED (Charging)
├── GPIO04 ─── OLED Reset
└── GND ─── Common Ground
```

### Power Circuit

```
                    5V USB
                       │
                   ┌──┴──┐
                   │TP4056│ USB-C
                   └──┬──┘
                      │
           ┌──────────┼──────────┐
           │          │          │
        Battery    LDO 3.3V    Sensors
        (3.7V)      │          (3.3V)
           │         │            │
           └─────────┴────────────┘
                    GND
```

### Schematic Notes

1. **Pull-up Resistors**: 4.7K resistors on I2C lines (SDA, SCL)
2. **Decoupling Capacitors**: 100nF near each IC VCC pin
3. **Voltage Divider**: 100K + 100K for battery ADC (max 3.3V input)
4. **LED Current Limiting**: 330R resistors on indicator LEDs

### Detailed Wiring (MAX30102 → ESP32)

| MAX30102 | ESP32 | Wire Color | Notes |
|----------|-------|------------|-------|
| VCC | 3V3 | Red | 3.3V power |
| GND | GND | Black | Ground |
| SDA | GPIO 21 (SDA) | Yellow | I2C Data |
| SCL | GPIO 22 (SCL) | Orange | I2C Clock |
| INT | GPIO 26/27 | Blue | Interrupt output |

**I2C Address:** MAX30102 = 0x57

### Detailed Wiring (MPU6050 → ESP32)

| MPU6050 | ESP32 | Wire Color | Notes |
|---------|-------|------------|-------|
| VCC | 3V3 | Red | 3.3V power |
| GND | GND | Black | Ground |
| SDA | GPIO 21 (SDA) | Yellow | I2C Data (shared) |
| SCL | GPIO 22 (SCL) | Orange | I2C Clock (shared) |
| INT | GPIO 27 | Purple | Interrupt output |

**I2C Address:** MPU6050 = 0x68 (or 0x69 if AD0 is HIGH)

### Button Circuit (Pull-Down Resistor)

```
         10kΩ
  3V3 ───/\/\/────┬──── Button ──── GND
                  │
                  └──── GPIO (Input)
```

| Button | ESP32 GPIO | Function |
|--------|------------|----------|
| Button 1 (Mode) | GPIO 17/26 | Cycle through modes |
| Button 2 (Emergency) | GPIO 34/32 | Send emergency alert |
| Button 3 (Back) | GPIO 35/33 | Go back / Dismiss |

### LED Wiring

| LED | ESP32 GPIO | Resistor | Notes |
|-----|------------|----------|-------|
| Red LED | GPIO 4/2 | 330Ω | Status indicator |
| Green LED | GPIO 16/18 | 330Ω | Status indicator |

### Vibration Motor (via Transistor)

```
         1kΩ
GPIO ───/\/\/────┬──── Base (NPN: 2N2222)
                 │
              Collector ─── Motor ─── 3V3
                 │
              Emitter ─── GND
```

---

## 💻 Firmware Setup

### Development Environment

#### Arduino IDE Setup

1. **Install Arduino IDE 2.x**
   ```
   Download: https://www.arduino.cc/en/software
   ```

2. **Add ESP32 Board Support**
   ```arduino
   // File → Preferences → Additional Board Manager URLs:
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```

3. **Install Board Package**
   ```
   Tools → Board → Board Manager → ESP32 → Install (version 2.0.17+)
   ```

4. **Install Required Libraries**
   ```arduino
   Sketch → Include Library → Manage Libraries:
   ├── Wire.h (built-in)
   ├── SparkFun MAX3010x Pulse and Proximity Sensor Library
   ├── Adafruit MPU6050
   ├── Adafruit SSD1306
   ├── NimBLE-Arduino
   └── esp_sleep.h (built-in)
   ```

#### VS Code + PlatformIO (Recommended)

1. **Install PlatformIO**
   ```
   Code → Extensions → PlatformIO IDE
   ```

2. **Create New Project**
   ```bash
   pio project init --board esp32dev
   ```

3. **platformio.ini Configuration**
   ```ini
   [env:esp32dev]
   platform = espressif32
   board = esp32dev
   framework = arduino
   monitor_speed = 115200
   
   lib_deps = 
       sparkfun/SparkFun MAX3010x Pulse and Proximity Sensor Library@^1.1.2
       adafruit/Adafruit MPU6050@^2.2.6
       adafruit/Adafruit SSD1306@^2.5.9
       h2zero/NimBLE-Arduino@^1.4.1
   
   build_flags =
       -DCORE_DEBUG_LEVEL=0
       -DBOARD_HAS_PSRAM
   ```

### Uploading Firmware

#### Via USB

1. Connect watch to PC via USB-C cable
2. Put ESP32 in bootloader mode:
   - Hold BOOT button
   - Press and release EN/RESET button
   - Release BOOT button
3. Select correct COM port in Arduino IDE
4. Click Upload (Ctrl+U)

#### Via OTA (Over-The-Air)

1. Flash initial firmware via USB
2. Enable OTA in code:
   ```cpp
   ArduinoOTA.begin();
   ```
3. Upload via network from Arduino IDE

#### Via Bluetooth

1. Use ESP32's built-in BLE for updates
2. Implement custom OTA handler
3. Maximum payload: 512KB per transfer

### Firmware Architecture

```
DigitalSaverWatch/
├── DigitalSaverWatch.ino          # Main firmware sketch
├── platformio.ini                 # PlatformIO configuration
├── Config.h                       # Pin definitions
├── Sensors/
│   ├── HeartRateSensor.h         # MAX30102 interface
│   ├── MotionSensor.h            # MPU6050 interface
│   └── BatteryMonitor.h          # Power management
├── Services/
│   ├── BLEService.h               # Bluetooth communication
│   ├── DataLogger.h               # Storage operations
│   └── AlertService.h             # Emergency alerts
├── UI/
│   ├── DisplayManager.h           # OLED control
│   ├── WatchFace.h               # Watch face rendering
│   └── MenuSystem.h              # Navigation
└── Utils/
    ├── SleepAnalyzer.h            # Sleep detection
    ├── StepCounter.h             # Pedometer
    └── HeartRateAnalyzer.h       # HRV calculation
```

### Key Firmware Functions

#### Heart Rate Measurement

```cpp
#include "MAX30105.h"
#include "heartRate.h"

MAX30105 particleSensor;

void initHeartRate() {
    if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
        Serial.println("MAX30105 not found!");
        while (1);
    }
    particleSensor.setup();
    particleSensor.setPulseAmplitudeRed(0x0A);
    particleSensor.setPulseAmplitudeGreen(0);
    particleSensor.setPulseAmplitudeIR(0);
}

float getHeartRate() {
    long irValue = particleSensor.getIR();
    if (checkForBeat(irValue) == true) {
        // Calculate BPM from inter-beat intervals
    }
    return bpm;
}
```

#### Motion Detection

```cpp
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

Adafruit_MPU6050 mpu;

void initMotion() {
    if (!mpu.begin()) {
        Serial.println("MPU6050 not found!");
        while (1);
    }
    mpu.setAccelerometerRange(MPU6050_RANGE_16_G);
    mpu.setGyroRange(MPU6050_RANGE_250_DEG);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
}

void getMotionData(sensors_event_t* a, sensors_event_t* g) {
    mpu.getEvent(a, g);
}
```

#### Sleep Analysis Algorithm

```cpp
class SleepAnalyzer {
private:
    static const int WINDOW_SIZE = 300; // 5 min windows
    static const int LIGHT_THRESHOLD = 0.15;
    static const int DEEP_THRESHOLD = 0.05;
    
    int lightSleepMinutes = 0;
    int deepSleepMinutes = 0;
    int awakeMinutes = 0;
    
public:
    void analyzeWindow(float avgMotion) {
        if (avgMotion < DEEP_THRESHOLD) {
            deepSleepMinutes += 5;
        } else if (avgMotion < LIGHT_THRESHOLD) {
            lightSleepMinutes += 5;
        } else {
            awakeMinutes += 5;
        }
    }
};
```

---

## 🔧 Sensor Integration

### MAX30102 Connection

```
ESP32          MAX30102
──────         ────────
GPIO21 (SDA) → SDA
GPIO22 (SCL) → SCL
3.3V       → VIN
GND        → GND
GPIO27     → INT
```

**Calibration Procedure:**
1. Place sensor on wrist
2. Ensure skin contact
3. Wait 30 seconds for stabilization
4. Verify IR reading > 50,000
5. Check pulse detection indicator

### MPU6050 Connection

```
ESP32          MPU6050
──────         ────────
GPIO21 (SDA) → SDA
GPIO22 (SCL) → SCL
3.3V       → VCC
GND        → GND
```

**Calibration Procedure:**
1. Place watch flat on table
2. Run calibration sketch for 10 seconds
3. Store offset values in EEPROM
4. Verify X/Y acceleration ≈ 0, Z ≈ 9.8

### OLED Display Connection

```
ESP32          OLED (SSD1306)
──────         ───────────────
GPIO21 (SDA) → SDA
GPIO22 (SCL) → SCL
3.3V       → VCC
GND        → GND
GPIO04     → RST
```

---

## 🛠️ Assembly Guide

### Step 1: PCB Preparation

1. **Clean PCB**
   - Use IPA (isopropyl alcohol) 99%
   - Remove flux residue with brush
   - Dry with compressed air

2. **Visual Inspection**
   - Check for solder bridges
   - Verify all components placed
   - Test continuity on power rails

3. **Program ESP32**
   - Upload firmware via USB
   - Test basic functions
   - Mark PCB with version number

### Step 2: Sensor Installation

1. **MAX30102 Module**
   ```
   1. Position sensor on top of PCB
   2. Solder 4-pin header
   3. Apply thermal paste to back
   4. Secure with Kapton tape
   ```

2. **MPU6050 Module**
   ```
   1. Solder to PCB
   2. Ensure flat orientation
   3. Verify I2C communication
   ```

3. **Display Module**
   ```
   1. Attach FPC connector
   2. Secure with latch
   3. Test display output
   ```

### Step 3: Power System

1. **Battery Connection**
   ```
   Red Wire → TP4056 B+
   Black Wire → TP4056 B-
   ```

2. **Power-On Test**
   ```
   1. Connect battery
   2. Press power button
   3. Verify 3.3V on rails
   4. Check charging LED
   ```

### Step 4: Enclosure Assembly

1. **3D Printed Case**
   - Material: PETG or PLA+
   - Print settings: 0.2mm layer height
   - Infill: 20%
   - Walls: 3 perimeters

2. **Assembly Sequence**
   ```
   1. Insert PCB into bottom case
   2. Connect display ribbon cable
   3. Install battery (adhesive backed)
   4. Route wires carefully
   5. Snap top case into place
   6. Install watch band
   ```

---

## ✅ Testing & Calibration

### Pre-Assembly Tests

| Test | Equipment | Pass Criteria |
|------|-----------|---------------|
| Power On | Multimeter | 3.3V ± 0.1V |
| ESP32 Flash | USB + IDE | Firmware uploads |
| I2C Scan | Logic Analyzer | All devices detected |
| Display Test | USB | Shows test pattern |

### Post-Assembly Tests

| Test | Method | Pass Criteria |
|------|--------|---------------|
| Heart Rate | Compare to oximeter | ±5 BPM |
| SpO2 | Compare to pulse oximeter | ±2% |
| Steps | 1000 step walk test | 950-1050 |
| Battery Life | Discharge test | >6 hours |
| Bluetooth | Pair with phone | Stable connection |

### Calibration Sequence

```cpp
// Calibration sketch - run once per device
void calibrate() {
    Serial.println("Starting calibration...");
    
    // Heart Rate Zero Point
    delay(5000); // Wait for stable reading
    int hrZero = readHeartRate();
    Serial.printf("HR Zero: %d\n", hrZero);
    
    // Accelerometer Zero
    sensors_event_t a, g;
    mpu.getEvent(&a, &g);
    int accXZero = a.acceleration.x;
    int accYZero = a.acceleration.y;
    int accZZero = a.acceleration.z - 9.8; // Subtract gravity
    Serial.printf("Acc Zero: %d, %d, %d\n", accXZero, accYZero, accZZero);
    
    // Save to EEPROM
    EEPROM.put(0, hrZero);
    EEPROM.put(4, accXZero);
    EEPROM.put(8, accYZero);
    EEPROM.put(12, accZZero);
    EEPROM.commit();
}
```

---

## 🎨 外壳设计 (Case Design)

### Design Requirements

- **Material**: PETG or resin (biocompatible)
- **Water Resistance**: IP67 rating
- **Weight**: < 45g with band
- **Size**: 42mm diameter, 12mm thickness
- **Comfort**: Rounded edges, breathable band

### 3D Design Guidelines

```
Case Dimensions:
├── Outer Diameter: 42mm
├── Inner Diameter: 40mm
├── Thickness: 10mm
├── Lug Width: 20mm
├── Button Protrusion: 2mm
└── Sensor Window: 8mm circle
```

### Recommended Design Software

1. **Fusion 360** (Free for hobbyists)
2. **SolidWorks** (Professional)
3. **FreeCAD** (Open source)
4. **Onshape** (Cloud-based)

### Export Settings

```
STL Export:
├── Resolution: 0.01mm
├── Format: Binary STL
└── Units: Millimeters

3MF Export (for PrusaSlicer):
├── Include supports: Yes
├── Infill: 20%
└── Layer height: 0.2mm
```

---

## 🏭 Production Guide

### Small Batch (10-50 units)

1. **PCB Fabrication**
   - Use JLCPCB or PCBWay
   - 4-layer board, 1.6mm
   - HASL finish
   - Minimum order: 5 units

2. **Component Sourcing**
   - Use LCSC Electronics (LCSC.com)
   - Order 10% extra for defects
   - Verify compatibility

3. **Assembly**
   - Hand solder SMD components
   - Use solder paste + hot air
   - Inspect under microscope

### Medium Batch (50-200 units)

1. **PCB + Stencil**
   - Order stencil with PCB
   - Use solder paste dispenser
   - Reflow in oven (T-962)

2. **Automated Testing**
   - Build test fixtures
   - Programatic calibration
   - Batch logging

### Quality Control Checklist

```
□ Visual inspection (microscope)
□ Continuity test (power rails)
□ I2C device detection
□ Firmware upload test
□ Display functionality
□ Heart rate sensor test
□ Motion sensor test
□ Battery charging test
□ Bluetooth pairing test
□ Water resistance test
□ Drop test (1m)
□ Battery life test
```

---

## 🔧 Troubleshooting

### Common Issues

#### ESP32 Won't Boot
```
Symptoms: No LED activity, no serial output

Causes:
├── Power supply issue
├── Short circuit
├── Corrupted bootloader
└── Damaged ESP32

Solutions:
1. Check 3.3V rail voltage
2. Measure current draw (>500mA = short)
3. Re-flash bootloader via USB
4. Replace ESP32 module
```

#### Heart Rate Sensor Not Detected
```
Symptoms: I2C scan shows no device at 0x57

Causes:
├── Cold solder joint
├── Damaged module
├── Wrong I2C address
└── Wire connection issue

Solutions:
1. Check SDA/SCL connections
2. Verify 3.3V to module
3. Run I2C scanner sketch
4. Replace MAX30102 module
```

#### Poor Heart Rate Accuracy
```
Symptoms: Erratic readings, large variations

Causes:
├── Loose sensor placement
├── Dark skin pigmentation
├── Ambient light interference
└── Motion artifacts

Solutions:
1. Apply even pressure
2. Cover sensor with finger
3. Use anti-ambient light paste
4. Add motion filtering
```

#### Battery Drains Quickly
```
Symptoms: Less than 6 hours battery life

Causes:
├── ESP32 high power mode
├── Always-on display
├── Unoptimized sleep
└── Faulty battery

Solutions:
1. Enable deep sleep between readings
2. Reduce display brightness
3. Optimize BLE advertising interval
4. Test with new battery
```

#### Bluetooth Disconnects
```
Symptoms: Intermittent connection drops

Causes:
├── Weak signal
├── Power management issues
├── Antenna interference
└── Large data payloads

Solutions:
1. Move phone closer
2. Reduce advertising interval
3. Add delay between packets
4. Check antenna connection
```

---

## ⚠️ Safety Guidelines

### Electrical Safety

```
⚡ WARNING: Lipo Battery Handling

• Never short circuit battery terminals
• Do not puncture or crush battery
• Avoid extreme temperatures (>45°C)
• Use protected battery with PCM
• Unplug when not in use for extended periods
• Never charge unattended
```

### Medical Disclaimer

```
🏥 IMPORTANT - NOT A MEDICAL DEVICE

The Onyx Smartwatch is designed for wellness and fitness 
tracking purposes only. It is NOT:

✗ FDA approved
✗ Clinically validated
✗ A substitute for professional medical care
✗ Certified for diagnostic use

Always consult healthcare professionals for medical 
advice. Do not make health decisions based solely on 
data from this device.
```

### Regulatory Compliance

```
CE/FCC Certification Required for Sale:
├── EMC: EN 301 489-1/17
├── RF: EN 300 328
├── Safety: IEC 60950-1
├── SAR: EN 62479
└── RoHS: Restriction of Hazardous Substances
```

---

## 📞 Support

**Cambric Technical Support**
- Email: support@cambric.example.com
- Documentation: https://cambric.example.com/docs
- Firmware Updates: https://github.com/Cambric-software/Onyx-Firmware

**Community Forum**
- https://community.cambric.example.com

---

## 📄 License

Copyright © 2026 Cambric. All Rights Reserved.

This documentation and associated firmware are proprietary 
to Cambric. Unauthorized reproduction or distribution is 
prohibited.

---

**Version:** 1.0.0  
**Last Updated:** July 2026  
**Document Owner:** Cambric Engineering Team
