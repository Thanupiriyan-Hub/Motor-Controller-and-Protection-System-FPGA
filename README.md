# Motor Controller and Protection System (FPGA-Based)

This project implements an **FPGA-based stepper motor control and protection system** using Verilog HDL on the **Nexys A7 development board**. The system is designed for **real-time control and monitoring** of a high-torque stepper motor, with safety mechanisms for overvoltage, overcurrent, high temperature, and unusual vibration.

## 🔧 Components Used

- 🌀 **High Torque NEMA 17 Stepper Motor**
- 🔁 **A4988 Stepper Motor Driver**
- 📶 **HC-06 Bluetooth Module**
- 💻 **Nexys A7 FPGA Board**
- 📳 **Vibration Sensor**
- 🌡 **LM75A High-speed Temperature Sensor (I2C)**

---

## ⚙️ Features

- ✅ **Motor Control via Mobile App**
  - Start/Stop motor
  - Change direction (clockwise/counterclockwise)
  - Adjust speed

- 📡 **Real-Time Monitoring**
  - Speed feedback
  - Temperature readings from LM75A
  - Vibration status

- 🔒 **Protection Mechanisms**
  - **Auto shutdown** on:
    - High temperature (above threshold)
    - Unusual vibration detected
  - Fault indicator output

- 📱 **Bluetooth Integration**
  - Wireless control and data feedback via Android mobile app using **HC-06**

---

## 🛠 Architecture Overview

- **FPGA Logic (Verilog HDL)**:
  - PWM generation for A4988
  - I2C controller for LM75A
  - Vibration signal monitoring
  - Temperature/vibration threshold comparison
  - Control logic for auto-off and safety state
  - UART communication with HC-06

- **Mobile App**:
  - User interface for motor control and sensor feedback
  - Bluetooth connection with HC-06

---
