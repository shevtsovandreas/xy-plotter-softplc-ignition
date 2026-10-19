# CODESYS SoftPLC — XY Plotter Control

## Overview

The XY Plotter control application is developed using **CODESYS V3.5 SP22 Patch 2** and runs on a Raspberry Pi 5 using **CODESYS Control for Raspberry Pi 64 SL**.

CODESYS replaces the original Siemens S7-1200 PLC and manages the main machine control logic.

The PLC coordinates automatic and manual operation, processes drawing trajectories received from Ignition, and communicates with the ESP32 motion controller over TCP/IP.

Time-critical motion generation remains on the ESP32.

## Project Files

| File | Description |
|---|---|
| `xy_plotter.export` | CODESYS XML export containing the PLC application, program organization units, data types, and exported configuration objects |

## Development Environment

| Component | Version |
|---|---|
| CODESYS Development System | V3.5 SP22 Patch 2 (64-bit) |
| CODESYS Control Runtime | 4.21.0.0 |
| Runtime SDK | 3.5.22.20 |
| Target device | CODESYS Control for Raspberry Pi 64 SL |
| Runtime platform | Raspberry Pi 5, ARM64 |
| Programming language | IEC 61131-3 Structured Text (ST) |

## PLC Application Structure

The exported application includes the following main components:

| Component | Responsibility |
|---|---|
| `Main_OB1` | Main PLC program |
| `FB100_Logic_Call` | Main control logic and coordination |
| `FB200_TCP_ESP` | TCP communication with the ESP32 |
| `FB300_ESP_Cmd` | ESP32 command handling |
| `SND_ESP_Buffer` | Outgoing command and trajectory data |
| `RCV_ESP_Buffer` | Incoming ESP32 status and feedback |
| `DB` | Machine commands and operating parameters |
| `Drawing` | Drawing data and execution parameters |
| `TCP` | Communication-related data |
| `PLC_Point` | Drawing point data type |
| `PLC_Contour` | Drawing contour data type |

Additional structures define ESP32 commands, coordinates, responses, and status information.

## Control Architecture

The PLC acts as the coordination layer between Ignition and the ESP32 motion controller.

**Ignition → CODESYS (OPC UA)**

- Operating mode and machine commands
- Manual movement and positioning requests
- Drawing points and contours
- Drawing execution parameters

**CODESYS → ESP32 (TCP/IP)**

- Control word (STW)
- Target coordinates
- Point and contour numbers
- Movement speed
- Point flags

**ESP32 → CODESYS (TCP/IP)**

- Status word (ZSW)
- Actual X/Y coordinates
- Current drawing point
- Buffer occupancy
- Error codes and execution feedback

CODESYS manages sequencing, command handling, and machine interlocks, while the ESP32 performs real-time motion interpolation and STEP/DIR pulse generation.

## Importing the PLC Application

1. Install CODESYS Development System V3.5 SP22 Patch 2 or a compatible version.
2. Create a new CODESYS project or open an appropriate target project.
3. Use **Project → Import** to import `xy_plotter.export`.
4. Verify the target device and required libraries.
5. Configure the connection to CODESYS Control on the Raspberry Pi.
6. Configure the communication parameters for the ESP32.
7. Build the application and resolve any missing dependencies.
8. Log in to the Runtime using the appropriate device credentials.
9. Download and test the PLC application.

The XML export is intended for importing application objects. Device-specific configuration and runtime settings may require additional setup.

## Runtime Configuration

The application runs on the Raspberry Pi 5 under the `codesyscontrol` service.

Check the Runtime status:

```bash
sudo systemctl status codesyscontrol
```

The CODESYS installation uses the following paths:

| Path | Description |
|---|---|
| `/opt/codesys/` | Runtime installation |
| `/etc/codesyscontrol/CODESYSControl.cfg` | Runtime configuration |
| `/var/opt/codesys/` | Runtime data |

## Authentication

Runtime access requires valid CODESYS device credentials.
Usernames and passwords are not included in this repository. Authentication and access permissions must be configured individually on the target system.
