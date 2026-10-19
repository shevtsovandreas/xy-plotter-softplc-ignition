# System Architecture

## Overview

The XY Plotter automation system uses a distributed control architecture based on **Raspberry Pi 5, CODESYS SoftPLC, Ignition Perspective, PostgreSQL, and an ESP32 motion controller**.

The project modernizes the original Siemens S7-1200 and KTP700 Basic HMI implementation by moving PLC execution, visualization, and data management to a single Linux-based edge platform.
<img width="1920" height="1080" alt="2" src="https://github.com/user-attachments/assets/f2c61e68-c522-49c4-b8f8-cd58573ff3d0" />
Time-critical motion control remains on a dedicated ESP32 controller.

## Architecture Components

| Component | Technology | Responsibility |
|---|---|---|
| Edge computing | Raspberry Pi 5 | Hosts the automation software stack |
| PLC control | CODESYS Control for Raspberry Pi 64 SL | Sequencing, machine commands, interlocks, and trajectory execution coordination |
| HMI / SCADA | Ignition Perspective 8.3.10 | Operator interface, drawing management, visualization, and diagnostics |
| Database | PostgreSQL 17 | Drawing storage, configuration, alarms, and execution history |
| Motion controller | ESP32 + W5500 | Real-time motion interpolation and STEP/DIR pulse generation |
| Operator interface | Web browser | Access to the Perspective application |
<img width="1920" height="1080" alt="1" src="https://github.com/user-attachments/assets/898cdcee-c728-4b0d-9131-5c7fa5ded161" />

## Control Layers

### 1. Visualization and Application Layer — Ignition

Ignition provides the interface between the operator and the automation system.

Its responsibilities include:

- Automatic and manual control screens
- Drawing library and G-code management
- G-code parsing and SVG preview generation
- Transfer of structured drawing data to the PLC
- Machine status visualization and diagnostics
- Alarm management and execution history

Ignition is not responsible for generating motor pulses or executing time-critical motion.

### 2. Machine Control Layer — CODESYS

CODESYS runs on the Raspberry Pi 5 as a SoftPLC.

It handles:

- Operating modes and machine commands
- Machine sequencing and interlocks
- Manual movement and homing requests
- Drawing point and contour management
- Communication with the ESP32 motion controller
- Processing of motion feedback and controller status

The PLC receives drawing data from Ignition and coordinates its execution through the ESP32.

### 3. Motion Control Layer — ESP32

The ESP32 operates as a dedicated motion controller connected through an Ethernet W5500 interface.

It handles:

- Reception and buffering of trajectory points
- 256-point circular motion buffer
- Bresenham-based motion interpolation
- Deterministic STEP/DIR pulse generation
- Motor direction and pen control
- Limit switch monitoring and motion feedback

Motion timing is handled locally on the ESP32 using a 10 µs timer interrupt, independently of the Linux operating system and web application.

### 4. Data Storage Layer — PostgreSQL

PostgreSQL provides persistent storage for the automation application.

It stores:

- Drawing metadata, G-code, and SVG data
- Drawing dimensions and point/contour information
- Communication signal definitions and logs
- Error catalog and error history
- Drawing execution history

Database initialization and reference catalog management are implemented through Ignition startup scripts and Named Queries.

## Communication Architecture
<img width="1920" height="1080" alt="3" src="https://github.com/user-attachments/assets/ab554baf-c962-4584-8fac-8d952d1d45f8" />
| Source | Destination | Protocol | Data |
|---|---|---|---|
| Browser | Ignition Gateway | HTTP/HTTPS | Operator interface |
| Ignition | PostgreSQL | JDBC | Drawings, configuration, and history |
| Ignition | CODESYS | OPC UA | Commands, trajectory data, and machine status |
| CODESYS | ESP32 | TCP/IP | Motion commands and trajectory points |
| ESP32 | CODESYS | TCP/IP | Position feedback, buffer status, and error codes |

### Drawing Execution Workflow

1. The operator selects a drawing from the Ignition Perspective library.
2. Ignition retrieves the drawing data from PostgreSQL.
3. Ignition parses the G-code into structured points and contours.
4. The drawing data is transferred to CODESYS through OPC UA.
5. CODESYS coordinates the execution and sends motion commands to the ESP32 through TCP/IP.
6. The ESP32 buffers trajectory points and generates the motor control pulses.
7. Motion feedback is returned to CODESYS and made available to Ignition.
8. Ignition displays the drawing progress and records execution information in PostgreSQL.

## Design Principles

### Separation of Responsibilities
<img width="1920" height="1080" alt="4" src="https://github.com/user-attachments/assets/8f013cb4-2f23-4d64-92d1-d110f757be41" />
Each component performs a clearly defined function:

- **Ignition** — visualization and application logic
- **CODESYS** — machine control and sequencing
- **ESP32** — deterministic motion execution
- **PostgreSQL** — persistent data storage

### Edge-Based Integration

The Raspberry Pi 5 consolidates the PLC runtime, SCADA Gateway, and database into a single edge platform, reducing the number of dedicated computing devices required by the original architecture.

### Independent Motion Execution

The ESP32 performs time-critical motion operations independently of the Raspberry Pi operating system.
This prevents normal Linux scheduling delays, database operations, or HMI activity from directly affecting STEP/DIR pulse timing.

### Modular Communication

The system uses standard interfaces:

- OPC UA for PLC integration
- TCP/IP for motion controller communication
- JDBC for database access
- HTTP/HTTPS for browser-based visualization
