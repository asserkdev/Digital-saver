# 🏥 Digital Saver — Complete Master Guide
## Egyptian Government Smartwatch Health Monitoring System

> **Version 2.0.0** · Budget: 10,000 EGP · Egyptian Government Funded

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Architecture](#2-system-architecture)
3. [Complete Hardware Guide](#3-complete-hardware-guide)
4. [Full Wiring & Connections](#4-full-wiring--connections)
5. [Step-by-Step Assembly](#5-step-by-step-assembly)
6. [Firmware Setup](#6-firmware-setup)
7. [Flutter App Guide](#7-flutter-app-guide)
8. [Features & Capabilities](#8-features--capabilities)
9. [Troubleshooting](#9-troubleshooting)
10. [Google Play Publishing](#10-google-play-publishing)
11. [Release Notes](#11-release-notes)

---

## 1. Project Overview

### What is Digital Saver?

Digital Saver is an Egyptian Government-funded smartwatch health monitoring system that provides real-time health data to users who cannot afford commercial medical wearables. It monitors heart rate, blood oxygen, estimated blood pressure, activity, fall detection, and sleep — sending emergency alerts to family/medical contacts when critical readings are detected.

| Property | Value |
|----------|-------|
| Project | Smartwatch Health Monitoring System |
| Target Users | Elderly, at-risk populations in Egypt |
| Government Budget | 10,000 EGP |
| Hardware Core | ESP32-WROOM-32 + MAX30102 + MPU6050 |
| App Platform | Flutter (Android 6.0+ · API 23+) |
| Communication | Bluetooth Low Energy (BLE 4.2) |
| Languages | Arabic, English + 8 more |

### Key Features at a Glance

| Feature | Technology |
|---------|-----------|
| ❤️ Heart Rate | MAX30102 PPG (photoplethysmography) |
| 🫁 Blood Oxygen SpO₂ | MAX30102 Red/IR ratio |
| 🩸 Blood Pressure (estimated) | PPG waveform analysis algorithm |
| 📊 HRV Analysis | RMSSD, SDNN, pNN50, Stress Index |
| 💔 AFib Detection | RR interval irregularity analysis |
| 🏃 Activity / Steps | MPU6050 6-axis accelerometer |
| 😴 Sleep Tracking | Motion + heart rate fusion |
| 🚨 Fall Detection | Threshold-based g-force algorithm |
| 📱 Emergency SOS | Auto SMS + phone call to contacts |
| 🌐 Multi-language | Arabic, English, French, German, Spanish + more |
| 🔋 Battery Life | ~24–36 hours on 500mAh LiPo |

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   DIGITAL SAVER SYSTEM                  │
├──────────────────────────┬──────────────────────────────┤
│     WATCH HARDWARE       │       MOBILE APP             │
│                          │                              │
│  ┌─────────────────┐     │  ┌────────────────────────┐  │
│  │  ESP32-WROOM-32 │     │  │   Flutter App          │  │
│  │  240MHz Dual    │◄───BLE►│                        │  │
│  │  Core + BLE 4.2 │     │  │  6 Screens:            │  │
│  └────────┬────────┘     │  │  • Dashboard           │  │
│           │ I2C Bus      │  │  • Heart Rate          │  │
│    ┌──────┼──────┐       │  │  • Blood Pressure      │  │
│    ▼      ▼      ▼       │  │  • Activity            │  │
│  MAX30102 MPU6050 OLED   │  │  • Sleep               │  │
│  HR + SpO2 Accel  0.96"  │  │  • Settings            │  │
│    │               │    │  │                        │  │
│  TP4056  Vibration LEDs  │  │  Services:             │  │
│  Charger  Motor          │  │  • BleService          │  │
│  ┌──────┐               │  │  • HealthAnalysis      │  │
│  │LiPo  │               │  │  • EmergencyService    │  │
│  │500mAh│               │  │  • StorageService      │  │
│  └──────┘               │  └────────────────────────┘  │
└──────────────────────────┴──────────────────────────────┘
```

### BLE Protocol

| Property | Value |
|----------|-------|
| Device Name | `Digital Saver` |
| Service UUID | `4fafc201-1fb5-459e-8fcc-c5c9c331914b` |
| Characteristic UUID | `beb5483e-36e1-4688-b7f5-ea07361b26a8` |
| Data Format | JSON string |
| Update Rate | 1 Hz (every second) |

**JSON Data Packet Example:**
```json
{
  "hr": 72,
  "spo2": 98,
  "bps": 118,
  "bpd": 76,
  "hrv": 45.2,
  "steps": 6234,
  "cal": 312.5,
  "temp": 36.7,
  "irreg": 0,
  "fall": 0,
  "ax": 0.01,
  "ay": 0.02,
  "az": 0.98
}
```

---

## 3. Complete Hardware Guide

### 3.1 Bill of Materials — Core Watch Components

| # | Component | Specification | Qty | Unit Price | Total | Source |
|---|-----------|---------------|-----|------------|-------|--------|
| 1 | **ESP32-WROOM-32 DevKit** | 240MHz, 4MB flash, WiFi+BT 4.2 | 1 | 350 EGP | 350 EGP | RoboDyn Egypt |
| 2 | **MAX30102 Module** | PPG: HR + SpO₂, I2C, 3.3V | 2 | 280 EGP | 560 EGP | RoboDyn Egypt |
| 3 | **MPU6050 Module** | 6-axis gyro+accel, I2C, 3.3V | 2 | 120 EGP | 240 EGP | RoboDyn Egypt |
| 4 | **OLED 1.3" SH1106** | 128×64, I2C, SPI option | 1 | 180 EGP | 180 EGP | RoboDyn / AliExpress |
| 5 | **OLED 0.96" SSD1306** | 128×64, I2C backup | 1 | 110 EGP | 110 EGP | RoboDyn Egypt |
| 6 | **LiPo Battery 502035** | 3.7V, 400mAh, protection | 2 | 120 EGP | 240 EGP | RoboDyn Egypt |
| 7 | **LiPo Battery 503450** | 3.7V, 1000mAh (larger option) | 1 | 180 EGP | 180 EGP | RoboDyn Egypt |
| 8 | **TP4056 w/ Protection** | 1A LiPo charger, USB-C | 3 | 35 EGP | 105 EGP | RoboDyn Egypt |
| 9 | **Vibration Motor** | 3V ERM, coin type, 65mA | 2 | 25 EGP | 50 EGP | RoboDyn Egypt |
| 10 | **Tactile Buttons 6×6mm** | 4-pin SMD, 6mm height | 10 | 5 EGP | 50 EGP | Any electronics |
| 11 | **Slide Switch SS12D00G3** | 3-pin, PCB mount | 5 | 8 EGP | 40 EGP | Any electronics |
| 12 | **Red LEDs 3mm** | 2.0–2.2V forward, 20mA | 5 | 2 EGP | 10 EGP | Any electronics |
| 13 | **Green LEDs 3mm** | 2.0–2.2V forward, 20mA | 5 | 2 EGP | 10 EGP | Any electronics |
| 14 | **NPN Transistor 2N2222** | Motor driver (x10 pack) | 1 pack | 20 EGP | 20 EGP | Any electronics |
| 15 | **Resistor Kit** | 220Ω, 330Ω, 1kΩ, 4.7kΩ, 10kΩ | 1 | 45 EGP | 45 EGP | Any electronics |
| 16 | **Capacitor Kit** | 100nF, 10µF electrolytic | 1 | 35 EGP | 35 EGP | Any electronics |
| 17 | **Schottky Diode 1N5817** | Battery reverse protection | 5 | 3 EGP | 15 EGP | Any electronics |
| 18 | **USB-C Breakout Board** | For charging port | 3 | 25 EGP | 75 EGP | RoboDyn Egypt |

**Core Components Subtotal: ~2,315 EGP**

### 3.2 Upgraded Add-on Sensors

| # | Component | Specification | Qty | Unit Price | Total | Why Add It |
|---|-----------|---------------|-----|------------|-------|-----------|
| 19 | **AD8232 ECG Module** | Single-lead ECG, 3.3V | 1 | 350 EGP | 350 EGP | Real ECG, not estimated |
| 20 | **GPS NEO-6M Module** | UART, 3.3V, ceramic antenna | 1 | 350 EGP | 350 EGP | Location in emergencies |
| 21 | **DS18B20 Temp Sensor** | 1-Wire, ±0.5°C accuracy | 2 | 40 EGP | 80 EGP | Body temperature |
| 22 | **BMP280 Pressure+Temp** | I2C, altitude, weather | 1 | 120 EGP | 120 EGP | Barometric monitoring |
| 23 | **MLX90614 IR Thermometer** | Non-contact, ±0.5°C | 1 | 280 EGP | 280 EGP | Contactless body temp |

**Add-on Sensors Subtotal: ~1,180 EGP**

### 3.3 Enclosure & Wearable Parts

| # | Component | Specification | Qty | Unit Price | Total | Source |
|---|-----------|---------------|-----|------------|-------|--------|
| 24 | **Custom PCB 2-layer** | 45×40mm, 1.2mm, HASL | 5 pcs | 80 EGP | 400 EGP | JLCPCB.com |
| 25 | **PCB Stencil** | For solder paste application | 1 | 60 EGP | 60 EGP | JLCPCB.com |
| 26 | **3D Printed Case — PLA** | 45×40×15mm watch body | 3 | 150 EGP | 450 EGP | Local 3D print shop |
| 27 | **3D Printed Case — Resin** | High-detail professional finish | 2 | 200 EGP | 400 EGP | Local 3D print shop |
| 28 | **Watch Band — Silicone** | 22mm, adjustable, black | 5 | 50 EGP | 250 EGP | Amazon.eg |
| 29 | **Watch Glass Round** | 36mm sapphire-coated acrylic | 3 | 40 EGP | 120 EGP | Watch repair shops |
| 30 | **Watch Strap Lugs** | 22mm stainless steel | 10 pairs | 15 EGP | 150 EGP | AliExpress |
| 31 | **Charging Pads (Pogo pins)** | Magnetic 2-pin, spring-loaded | 3 pairs | 30 EGP | 90 EGP | AliExpress |
| 32 | **Epoxy Resin** | Crystal clear, 2-part, 50ml | 2 | 80 EGP | 160 EGP | Hardware store |
| 33 | **Foam tape 1mm** | For sensor mounting (waterproof) | 1 roll | 30 EGP | 30 EGP | Hardware store |

**Enclosure Subtotal: ~2,110 EGP**

---

## 4. Full Wiring & Connections

### 4.1 ESP32 Pin Map

```
                    ESP32-WROOM-32 DevKit v4
                   ┌─────────────────────────┐
              3V3 ─┤ 3V3             GND      ├─ GND
              EN  ─┤ EN              23 (GPIO)├─ [free]
         GPIO 36 ─┤ VP              22 (SCL) ├─ I2C CLOCK
         GPIO 39 ─┤ VN              1 (TX)   ├─ UART TX
         GPIO 34 ─┤ 34 (BTN3)       3 (RX)   ├─ UART RX  
         GPIO 35 ─┤ 35 (BTN2)      21 (SDA)  ├─ I2C DATA
         GPIO 32 ─┤ 32              19       ├─ [free]
         GPIO 33 ─┤ 33              18       ├─ [free]
         GPIO 25 ─┤ 25 (MOTOR)      5 (SCK)  ├─ [free]
         GPIO 26 ─┤ 26 (HR_INT)     17 (TX2) ├─ GPS TX
         GPIO 27 ─┤ 27 (IMU_INT)    16 (RX2) ├─ GPS RX
         GPIO 14 ─┤ 14 (ECG_LO+)   4 (GPIO) ├─ LED RED
         GPIO 12 ─┤ 12 (ECG_LO-)   2 (GPIO) ├─ ONBOARD LED
         GPIO 13 ─┤ 13 (ECG_OUT)  15 (GPIO) ├─ TEMP SENSOR
              GND ─┤ GND            16 (GPIO)├─ LED GREEN
              VIN ─┤ VIN (5V USB)   17       ├─ BTN1 (MODE)
                   └─────────────────────────┘
```

### 4.2 I2C Bus (All Devices Share GPIO 21/22)

All I2C devices connect to **GPIO 21 (SDA)** and **GPIO 22 (SCL)**. Each has a unique address:

| Device | I2C Address | Notes |
|--------|-------------|-------|
| MAX30102 | `0x57` | Cannot change |
| MPU6050 | `0x68` (AD0=LOW) or `0x69` (AD0=HIGH) | Pull AD0 pin |
| OLED SSD1306 | `0x3C` (SA0=LOW) or `0x3D` (SA0=HIGH) | Most default to 0x3C |
| OLED SH1106 | `0x3C` | Fixed |
| BMP280 | `0x76` (SDO=LOW) or `0x77` (SDO=HIGH) | Jumper on board |

**I2C Bus Scan Code (test before soldering):**
```cpp
#include <Wire.h>
void setup() {
  Serial.begin(115200);
  Wire.begin(21, 22);
}
void loop() {
  for (byte a = 1; a < 127; a++) {
    Wire.beginTransmission(a);
    if (Wire.endTransmission() == 0) {
      Serial.printf("Found I2C device at 0x%02X\n", a);
    }
  }
  delay(3000);
}
```

### 4.3 MAX30102 Wiring (Heart Rate + SpO₂)

```
MAX30102 Module          ESP32-WROOM-32
┌──────────┐             ┌─────────────┐
│   VCC    ├─── RED ────►│ 3V3         │
│   GND    ├─── BLACK ──►│ GND         │
│   SDA    ├─── YELLOW ─►│ GPIO 21     │  ← I2C Data
│   SCL    ├─── ORANGE ─►│ GPIO 22     │  ← I2C Clock
│   INT    ├─── BLUE ───►│ GPIO 26     │  ← Interrupt
└──────────┘             └─────────────┘
```

**Important:** The MAX30102 MUST be on the underside of the watch, touching the user's wrist. Green/IR LEDs face down into skin. No daylight should reach the sensor while measuring.

**Sensor Placement:**
- Mount sensor face-down toward wrist
- Pressure: gentle contact, not too tight (cuts circulation)
- Use foam padding around sensor edge to block ambient light

### 4.4 MPU6050 Wiring (6-Axis Motion)

```
MPU6050 Module           ESP32-WROOM-32
┌──────────┐             ┌─────────────┐
│   VCC    ├─── RED ────►│ 3V3         │
│   GND    ├─── BLACK ──►│ GND         │
│   SDA    ├─── YELLOW ─►│ GPIO 21     │  ← SHARED I2C Data
│   SCL    ├─── ORANGE ─►│ GPIO 22     │  ← SHARED I2C Clock
│   INT    ├─── PURPLE ─►│ GPIO 27     │  ← Interrupt
│   AD0    ├─── GND ────►│ GND         │  ← Sets address 0x68
└──────────┘             └─────────────┘
```

### 4.5 OLED Display Wiring (SSD1306 / SH1106)

```
OLED 0.96" or 1.3"       ESP32-WROOM-32
┌──────────┐             ┌─────────────┐
│   VCC    ├─── RED ────►│ 3V3         │
│   GND    ├─── BLACK ──►│ GND         │
│   SCL    ├─── ORANGE ─►│ GPIO 22     │  ← SHARED I2C Clock
│   SDA    ├─── YELLOW ─►│ GPIO 21     │  ← SHARED I2C Data
└──────────┘             └─────────────┘

Pin order on most modules (left to right):
  GND · VCC · SCL · SDA
```

### 4.6 Power System Wiring

```
USB 5V Power
     │
     ▼
┌──────────────────────────────┐
│         TP4056 Module        │
│                              │
│  USB+ IN ── [USB-C Breakout] │
│  USB- IN ── [USB-C Breakout] │
│                              │
│  B+ ──►── Battery (+) RED   │
│  B- ──►── Battery (-) BLACK │
│                              │
│  OUT+ ──►── ESP32 VIN (5V)  │◄── Only when USB connected
│  OUT- ──►── ESP32 GND       │
└──────────────────────────────┘

Battery directly also goes:
  Battery(+) ──► Schottky 1N5817 ──► ESP32 VIN
  Battery(-) ──► ESP32 GND

⚠️  POLARITY IS CRITICAL — red = (+), black = (-)
⚠️  NEVER reverse battery leads (destroys ESP32)
⚠️  Always use LiPo with built-in protection circuit
```

**Expected voltages (check with multimeter):**
| Point | Expected Voltage |
|-------|----------------|
| Battery terminals | 3.5–4.2V |
| TP4056 OUT+ (charging) | 5.0V |
| ESP32 VIN | 3.5–5.0V |
| ESP32 3V3 pin | 3.2–3.4V |
| All sensor VCC pins | 3.2–3.4V |

### 4.7 Vibration Motor Wiring (via Transistor)

```
GPIO 25 ──── 1kΩ ──────┬──── Base (NPN 2N2222)
                        │
                    Collector ──── Motor (+) ──── 3V3
                        │
                    Emitter ─────── GND

Also add: Diode 1N4007 across motor terminals (flyback protection)
  Motor(+) ─── Cathode │◄─── Anode ─── Motor(-)
```

**Why the transistor?** The ESP32 GPIO can only supply 12mA. The vibration motor needs 65–80mA. The 2N2222 transistor acts as a switch, using the 12mA GPIO signal to control 3.3V power directly from the battery.

### 4.8 Buttons Wiring (Pull-Up)

```
Button 1 (MODE):
3V3 ─── 10kΩ ──┬── GPIO 17 (INPUT_PULLUP)
                │
              [BTN] ─── GND

Button 2 (BACK):
3V3 ─── 10kΩ ──┬── GPIO 35 (INPUT ONLY — no internal pull-up)
                │
              [BTN] ─── GND

Button 3 (EMERGENCY):
3V3 ─── 10kΩ ──┬── GPIO 34 (INPUT ONLY — no internal pull-up)
                │
              [BTN] ─── GND
```

⚠️ **Important:** GPIO 34, 35, 36, 39 are **input-only** on ESP32. They have **no internal pull-up**. You MUST add external 10kΩ resistors to 3V3.

### 4.9 LED Wiring

```
Red LED (Status):
3V3 ─── 330Ω ─── LED(+) ─── LED(-) ─── GPIO 4

Green LED (Connected):
3V3 ─── 330Ω ─── LED(+) ─── LED(-) ─── GPIO 16

LED State Table:
┌──────────────────┬─────────┬──────────┐
│ State            │ Red LED │ Green LED│
├──────────────────┼─────────┼──────────┤
│ Booting          │ ON      │ OFF      │
│ BLE Advertising  │ Blink   │ OFF      │
│ App Connected    │ OFF     │ ON       │
│ Measuring        │ Blink   │ Blink    │
│ Emergency        │ Fast    │ OFF      │
│ Charging         │ ON      │ OFF      │
│ Charged Full     │ OFF     │ ON       │
└──────────────────┴─────────┴──────────┘
```

### 4.10 AD8232 ECG Wiring (Optional Upgrade)

```
AD8232 Module            ESP32-WROOM-32
┌──────────┐             ┌─────────────┐
│   3V3    ├─── RED ────►│ 3V3         │
│   GND    ├─── BLACK ──►│ GND         │
│   OUTPUT ├─── GREEN ──►│ GPIO 13     │  ← ADC input
│   LO-    ├─── BLUE ───►│ GPIO 12     │  ← Lead-off detect
│   LO+    ├─── PURPLE ─►│ GPIO 14     │  ← Lead-off detect
└──────────┘             └─────────────┘

Lead placement:
  RA (Right Arm electrode) ── white lead
  LA (Left Arm electrode)  ── black lead
  RL (Right Leg/ground)    ── red lead
```

### 4.11 GPS NEO-6M Wiring (Optional Upgrade)

```
GPS NEO-6M Module        ESP32-WROOM-32
┌──────────┐             ┌─────────────┐
│   VCC    ├─── RED ────►│ 3V3         │
│   GND    ├─── BLACK ──►│ GND         │
│   TX     ├─── YELLOW ─►│ GPIO 16 RX2 │  ← UART2 Receive
│   RX     ├─── ORANGE ─►│ GPIO 17 TX2 │  ← UART2 Transmit
└──────────┘             └─────────────┘

Firmware: Serial2.begin(9600, SERIAL_8N1, 16, 17);
```

### 4.12 Complete Connection Summary

```
                         3V3 RAIL (3.3V)
                              │
         ┌────────────────────┼─────────────────────┐
         │                    │                     │
    MAX30102             MPU6050                  OLED
    VCC ◄─┤            VCC ◄─┤                VCC ◄─┤
    GND ►─┤            GND ►─┤                GND ►─┤
    SDA ◄─►─────────── SDA ◄─►──────────── SDA ◄─►──┐
    SCL ◄─►─────────── SCL ◄─►──────────── SCL ◄─►──┤
    INT ►─┤ GPIO26     INT ►─┤ GPIO27                │
         │                    │                   GPIO 21 (SDA)
         │                    │                   GPIO 22 (SCL)
         └──────────────────── ALL GND ────────────────┘
                              │
                         GND RAIL
                              │
              ┌───────────────┼───────────────┐
              │               │               │
           TP4056          ESP32          Buttons/LEDs
         Battery+/−       VIN / GND       GPIO 4,16,17,34,35
              │               │
         USB-C Port      UART/BLE
```

---

## 5. Step-by-Step Assembly

### Phase 1: Prepare & Test (Days 1–2)

**Day 1 — Component Verification**

1. Unbox all components, inspect for damage
2. Set multimeter to DC voltage (20V range)
3. Connect ESP32 to USB, measure GPIO 3V3: should be **3.2–3.4V**
4. Run I2C scanner code to verify addresses of all modules
5. Do NOT solder anything yet

**Day 2 — Breadboard Prototype**

```
Breadboard Layout:
  Left rail  = 3V3 (red)
  Right rail = GND (black)

  Row 1-6:   ESP32 (bridge the center gap)
  Row 10-14: MAX30102
  Row 16-20: MPU6050
  Row 22-26: OLED display
  Row 28-30: TP4056 (use JST leads, not direct connection)
```

Run firmware and verify Serial Monitor shows:
```
[OK] I2C initialized (SDA:21, SCL:22)
[OK] Display initialized
[OK] MAX30102 initialized
[OK] MPU6050 initialized
[OK] BLE initialized - waiting for connection...
```

### Phase 2: PCB Design & Ordering (Days 3–5)

**PCB Schematic (simplified):**

| Net | Connections |
|-----|-------------|
| VCC_3V3 | ESP32.3V3, MAX30102.VCC, MPU6050.VCC, OLED.VCC |
| GND | All component GND pins |
| I2C_SDA | ESP32.GPIO21, MAX30102.SDA, MPU6050.SDA, OLED.SDA |
| I2C_SCL | ESP32.GPIO22, MAX30102.SCL, MPU6050.SCL, OLED.SCL |
| MOTOR | ESP32.GPIO25 → 1kΩ → 2N2222.Base |
| LED_R | ESP32.GPIO4 → 330Ω → LED.Anode |
| LED_G | ESP32.GPIO16 → 330Ω → LED.Anode |
| BTN1 | ESP32.GPIO17 ← 10kΩ ← 3V3, BTN → GND |
| BATT+ | LiPo(+) → TP4056.B+ |
| BATT− | LiPo(−) → TP4056.B− |
| USB_5V | USB-C → TP4056.IN+ |

Order from JLCPCB.com: ~80 EGP for 5 pieces, 1.2mm, 2-layer, green soldermask.

### Phase 3: Soldering (Days 6–7)

**Soldering Order (critical — follow this sequence):**

1. **Surface-mount resistors** (smallest first)
2. **Surface-mount capacitors** (decoupling caps near ICs)
3. **Diodes** (observe cathode/anode marking)
4. **Transistors** (2N2222 — EBC pinout)
5. **Pin headers** for ESP32 socket (so ESP32 is removable)
6. **Connectors** — JST for battery, USB-C breakout
7. **Through-hole components** — LEDs, buttons, slide switch
8. **Modules** — MAX30102, MPU6050 into their sockets last

**Soldering Tips:**
- Iron temperature: 350°C for leaded solder, 370°C for lead-free
- Clean tip before each joint (brass wool, not water)
- Heat pad + lead simultaneously (2 seconds), then touch solder
- Good joint = shiny, volcano-shaped, no cold joints
- Inspect with magnifier under bright light

### Phase 4: Assembly into Case (Day 8)

**Component Placement (top view):**
```
    ┌─────────────────────────────────────┐
    │  ┌───────────────────────────────┐  │
    │  │         OLED Display          │  │  ← Top layer, visible through glass
    │  └───────────────────────────────┘  │
    │                                     │
    │  ┌───────────────────────────────┐  │
    │  │        ESP32-WROOM-32         │  │  ← Center, in socket
    │  └───────────────────────────────┘  │
    │                                     │
    │  ┌─────────┐  ┌─────────────────┐   │
    │  │TP4056   │  │   LiPo Battery  │   │  ← Back layer
    │  │Charger  │  │   (flat side)   │   │
    │  └─────────┘  └─────────────────┘   │
    │                                     │
    │  [BTN1]    [BTN2]    [BTN3]  [SW]   │  ← Sides of case
    └─────────────────────────────────────┘
                    │
              (BOTTOM FACE — wrist side)
    ┌─────────────────────────────────────┐
    │  ┌─────────────────────────────┐    │
    │  │     MAX30102 PPG Sensor     │    │  ← Must touch wrist skin
    │  │   (IR + Red LEDs face down) │    │
    │  └─────────────────────────────┘    │
    │                                     │
    │  ┌─────────┐                        │
    │  │MPU6050  │                        │
    │  └─────────┘                        │
    └─────────────────────────────────────┘
```

**Mounting steps:**
1. Apply double-sided foam tape to MAX30102 sensor (sensor face away from tape)
2. Stick MAX30102 to back plate, sensor facing out (toward wrist)
3. Use hot glue around LiPo battery edges only (never on battery face/top)
4. Secure ESP32 in socket, route wires through PCB channels
5. Mount OLED on front, secure with small M2 screws or adhesive
6. Apply epoxy around watch glass edge after everything works
7. Attach watch band with lug pins

### Phase 5: Firmware Upload (Day 9)

```bash
# 1. Install Arduino IDE (arduino.cc)
# 2. Add ESP32 board:
#    File > Preferences > Additional URLs:
#    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

# 3. Install libraries (Tools > Manage Libraries):
#    - Adafruit SSD1306
#    - Adafruit GFX Library
#    - SparkFun MAX3010x Pulse and Proximity Sensor
#    - MPU6050 (by Electronic Cats or Jeff Rowberg)

# 4. Select board: Tools > Board > ESP32 > "ESP32 Dev Module"
# 5. Upload speed: 921600

# 6. If upload fails:
#    Hold BOOT button > click Upload > release BOOT when "Connecting..." appears

# 7. Verify in Serial Monitor (115200 baud):
#    [OK] System ready!
#    [BLE] Advertising...
```

### Phase 6: App Pairing & Testing (Day 10)

1. Install Digital Saver APK on Android phone (enable Unknown Sources)
2. Turn on watch (slide switch)
3. Open app → tap "Scan & Connect"
4. Select "Digital Saver" from the list
5. Watch should vibrate once (connection confirmed)
6. Press finger on MAX30102 sensor — heart rate should appear within 10 seconds

---

## 6. Firmware Setup

### Required Arduino Libraries

```
Adafruit SSD1306        (OLED display)
Adafruit GFX Library    (Graphics primitives)
SparkFun MAX3010x       (Heart rate + SpO2)
ESP32 BLE Arduino       (Bluetooth — included with ESP32 core)
```

### Key Firmware Constants

```cpp
// BLE UUIDs (must match app exactly)
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// GPIO pins
#define I2C_SDA 21
#define I2C_SCL 22
#define HEART_RATE_INT 26   // MAX30102 interrupt
#define MOTION_INT 27       // MPU6050 interrupt
#define VIBRATION_MOTOR 25
#define LED_RED 4
#define LED_GREEN 16
#define BUTTON_MODE 17
#define BUTTON_EMERGENCY 34
#define BUTTON_BACK 35

// Health thresholds
#define FALL_THRESHOLD 2.5      // g-force delta for fall detection
#define IRREGULAR_THRESHOLD 0.2  // RR interval coefficient of variation
```

### MAX30102 Optimal Settings

```cpp
byte ledBrightness = 60;   // 4mA current — good for dark skin
byte sampleAverage = 4;    // Reduce noise with averaging
byte ledMode = 2;          // Mode 2 = Red + IR (for SpO2)
int sampleRate = 400;      // 400 samples/sec
int pulseWidth = 69;       // 69µs — fast read
int adcRange = 4096;       // 4096 range — good sensitivity

particleSensor.setup(ledBrightness, sampleAverage, ledMode,
                     sampleRate, pulseWidth, adcRange);
```

---

## 7. Flutter App Guide

### Project Structure

```
app/
├── lib/
│   ├── main.dart                    ← App entry + NavigationBar
│   ├── theme/
│   │   └── app_theme.dart           ← Colors, gradients, shadows
│   ├── models/
│   │   └── health_models.dart       ← All data structures
│   ├── services/
│   │   ├── ble_service.dart         ← BLE connection + data parsing
│   │   ├── health_analysis_service.dart ← Algorithms (HRV, AFib, etc.)
│   │   ├── emergency_service.dart   ← SOS, SMS, phone calls
│   │   └── storage_service.dart     ← SharedPreferences persistence
│   └── screens/
│       ├── dashboard_screen.dart    ← Health score + vitals overview
│       ├── heart_screen.dart        ← HR, HRV, AFib, zones
│       ├── bp_screen.dart           ← Blood pressure + metrics
│       ├── activity_screen.dart     ← Steps, calories, fall detection
│       ├── sleep_screen.dart        ← Sleep stages analysis
│       └── settings_screen.dart     ← Profile, contacts, language
├── pubspec.yaml
└── android/
    └── app/src/main/AndroidManifest.xml
```

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  flutter_blue_plus: ^1.32.12
  fl_chart: ^0.68.0
  shared_preferences: ^2.2.3
  url_launcher: ^6.3.0
  permission_handler: ^11.3.1
  intl: ^0.19.0
```

### Running the App

```bash
cd app
flutter pub get
flutter run                    # Debug on connected device
flutter build apk --release    # Build release APK
```

### Key App Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
```

---

## 8. Features & Capabilities

### Health Score Algorithm

The app calculates a 0–100 overall health score:

| Metric | Weight | Normal Range | Calculation |
|--------|--------|-------------|-------------|
| Heart Rate | 25% | 60–100 BPM | Gaussian curve centered at 72 BPM |
| SpO₂ | 30% | 95–100% | Linear: 100%→100pts, 90%→50pts |
| Blood Pressure | 25% | 120/80 mmHg | Penalty per mmHg above normal |
| HRV (RMSSD) | 20% | 30–80ms | Logarithmic scale |

### Heart Rate Zones

| Zone | BPM Range | Color | Benefit |
|------|-----------|-------|---------|
| Rest | < 60 | Blue | Low activity |
| Fat Burn | 60–100 | Green | Ideal for cardio base |
| Cardio | 100–140 | Yellow | Cardiovascular fitness |
| Peak | 140–170 | Red | High intensity training |
| Maximum | > 170 | Purple | Extreme effort |

### Blood Pressure Classification (AHA/ACC)

| Category | Systolic | Diastolic | Action |
|----------|---------|-----------|--------|
| Normal | < 120 | < 80 | Maintain lifestyle |
| Elevated | 120–129 | < 80 | Monitor closely |
| High Stage 1 | 130–139 | 80–89 | Lifestyle changes |
| High Stage 2 | ≥ 140 | ≥ 90 | Doctor consultation |
| Hypertensive Crisis | > 180 | > 120 | Emergency care |

### Emergency System

**Auto-trigger conditions:**
- SpO₂ < 90% for > 10 seconds
- HR < 40 BPM or > 170 BPM
- Fall detected (g-force delta > 2.5g)
- Button 2 (EMERGENCY GPIO 34) held for 3 seconds

**Alert actions:**
1. Watch vibrates in SOS pattern (3 short, 3 long, 3 short)
2. Red LED flashes rapidly
3. BLE packet flags `fall: 1` or critical readings
4. App sends SMS to all emergency contacts with location
5. App displays call prompt for emergency contacts

---

## 9. Troubleshooting

### Hardware Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| No I2C devices found | Wrong pins / no power | Check GPIO 21/22, verify 3.3V |
| MAX30102 address 0x57 not found | Loose connection | Re-solder SDA/SCL, check VCC=3.3V |
| Heart rate always 0 | No finger on sensor, or too dark | Press finger firmly, block ambient light |
| ESP32 won't upload | Boot mode issue | Hold BOOT while clicking Upload |
| Watch freezes | Power issue | Add 100nF cap across 3V3/GND near ESP32 |
| Battery drains fast | Deep sleep not enabled | Enable `esp_light_sleep_start()` when BLE idle |
| BLE disconnects often | Interference | Keep phone within 3 metres |

### App Issues

| Problem | Fix |
|---------|-----|
| Can't scan for watch | Enable Bluetooth + Location permission |
| Watch found but won't connect | Force-close app, restart watch |
| "No data" on all screens | Check BLE UUID matches firmware exactly |
| Steps always 0 | MPU6050 not calibrated — shake watch gently |
| SMS not sending | Check SEND_SMS permission is granted |

### Multimeter Diagnostic Points

```
Test Point          Expected    If Wrong
─────────────────────────────────────────
Battery terminals   3.5–4.2V    < 3.0V = replace battery
TP4056 OUT+         4.8–5.2V    0V = TP4056 fault
ESP32 3V3 pin       3.2–3.4V    0V = no power / 5V = overvoltage!
MAX30102 VCC        3.2–3.4V    0V = wiring error
LED cathode         0V (lit)    > 0V = resistor missing
Between VCC & GND   Very high Ω 0Ω = SHORT CIRCUIT — do not power!
```

---

## 10. Google Play Publishing

### Step 1: Generate Signing Key

```bash
keytool -genkey -v -keystore digital_saver_key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias digital_saver
```

⚠️ **Store this file securely — losing it means you can never update your app.**

### Step 2: Configure android/app/build.gradle

```gradle
android {
    signingConfigs {
        release {
            keyAlias 'digital_saver'
            keyPassword 'YOUR_KEY_PASSWORD'
            storeFile file('digital_saver_key.jks')
            storePassword 'YOUR_STORE_PASSWORD'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Step 3: Build & Upload

```bash
flutter build apk --release
# APK → build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Play Console Setup

1. Create account at play.google.com/console ($25 one-time fee)
2. Create app: "Digital Saver", Health & Fitness category
3. Upload APK, add 2+ screenshots (1080×1920)
4. Add privacy policy URL (required — see template below)
5. Submit for review (1–3 days)

### Privacy Policy Template

Host this HTML at `https://cambric-software.github.io/Digital-saver/privacy_policy.html`:

```html
<!DOCTYPE html><html><body>
<h1>Privacy Policy — Digital Saver</h1>
<p>Digital Saver collects health data (heart rate, SpO₂, blood pressure) 
from your paired smartwatch via Bluetooth. All data is processed and stored 
locally on your device only. We do not transmit personal health data to 
external servers. Emergency contact data is used solely to send SOS alerts 
at your explicit request. This app is not a certified medical device.</p>
<p>Contact: [your email]</p>
</body></html>
```

---

## 11. Release Notes

### v2.0.0 — Current (June 2025)

**Flutter App — Complete Rewrite:**
- 6 full screens with professional Material 3 UI
- Real BLE connectivity to ESP32 (matching firmware UUIDs exactly)
- Health score ring with animation
- HRV analysis: RMSSD, SDNN, pNN50, stress index
- AFib irregular heartbeat detection
- Blood pressure classification (AHA/ACC guidelines)
- Vascular age + MAP + pulse pressure metrics
- Animated step progress ring
- Sleep stage distribution (donut chart)
- 10-language support (Arabic primary)
- Emergency SOS with SMS + phone call
- Demo mode for testing without hardware
- Profile persistence with BMI calculation
- Emergency contact management with one-tap alert

**Firmware v2.0.0:**
- MAX30102 PPG optimized settings
- MPU6050 fall detection algorithm
- HRV calculation (RMSSD + SDNN)
- Blood pressure estimation from PPG waveform
- BLE JSON data streaming at 1Hz
- Sleep mode detection
- Emergency button with vibration SOS

### v1.0.0 — Initial

- Basic BLE communication
- Simple heart rate display
- Single-screen design

---

## ⚠️ Medical Disclaimer

> **Digital Saver is a wellness monitoring tool, NOT a certified medical device.** Blood pressure readings are estimated from PPG waveform analysis and may not be accurate. Heart rate and SpO₂ readings can be affected by motion, cold hands, dark skin pigmentation, and nail polish. Always consult a licensed healthcare professional for medical decisions. Emergency features supplement but do not replace emergency services. Call emergency services (123 in Egypt) for life-threatening situations.

---

*Document Version: 2.0.0 · Prepared by Digital Saver Team · Egyptian Government Health Initiative*
