# CODESYS SoftPLC — Control Logic

## Overview

The XY Plotter uses **CODESYS Control for Raspberry Pi 64 SL** as its main PLC controller.
The application is developed in **CODESYS V3.5 SP22 Patch 2**, using IEC 61131-3 Structured Text (ST).
CODESYS coordinates machine operation, manages drawing execution, processes commands from Ignition, and communicates with the ESP32 motion controller over TCP/IP.

The architecture separates machine control from real-time motion generation:

- **Ignition** — operator interface, G-code processing, and drawing management.
- **CODESYS** — machine sequencing, command processing, and trajectory coordination.
- **ESP32** — point buffering, motion interpolation, and STEP/DIR pulse generation.

## PLC Program Structure

The application contains the following main program components.

| Component | Description |
|---|---|
| `Main_OB1` | Main PLC program execution |
| `FB100_Logic_Call` | Main machine logic and coordination |
| `FB200_TCP_ESP` | TCP communication with the ESP32 controller |
| `FB300_ESP_Cmd` | ESP32 command preparation and handling |
| `DB` | Machine commands, operating modes, and control parameters |
| `Drawing` | Drawing information, points, and contours |
| `SND_ESP_Buffer` | Data transmitted to the ESP32 |
| `RCV_ESP_Buffer` | Data received from the ESP32 |
| `TCP` | TCP communication data |
| `PLC_Point` | Drawing point structure |
| `PLC_Contour` | Drawing contour structure |

## Machine Operating Modes

### Automatic Mode

Automatic mode executes drawing trajectories prepared by Ignition.

The PLC coordinates the following operations:

1. Receives drawing information through OPC UA.
2. Processes the automatic execution commands.
3. Transfers drawing points and contours to the ESP32.
4. Monitors the motion controller buffer and execution feedback.
5. Coordinates progression through the drawing.
6. Reports machine status and execution progress to Ignition.

### Manual Mode

Manual mode allows the operator to control the plotter through Ignition Perspective.

Supported operations include:

- Jogging along the X and Y axes
- Diagonal movement
- Movement to specified target coordinates
- Homing
- Manual pen control
- Movement speed adjustment

Commands are received through PLC variables exposed to Ignition over OPC UA.

## Drawing Data Management

Ignition processes the original G-code and transfers structured trajectory information to CODESYS.

The PLC application uses drawing-related variables and data types to represent:

- Drawing points
- Contour definitions
- Total number of points
- Total number of contours
- Execution parameters

The PLC does not parse the original G-code directly. It receives the processed drawing information from Ignition.

## TCP Communication with ESP32

CODESYS communicates with the ESP32 motion controller using TCP/IP.
The communication logic is implemented through the `FB200_TCP_ESP` and `FB300_ESP_Cmd` components.

### Commands Sent to ESP32

| Field | Description |
|---|---|
| `CommandStw` | Control word |
| `CommandPointNum` | Point number |
| `CommandContourNum` | Contour number |
| `CommandCoord_X` | Target X coordinate |
| `CommandCoord_Y` | Target Y coordinate |
| `CommandSpeed` | Movement speed |
| `CommandPointFlags` | Point execution flags |

### Feedback Received from ESP32

| Field | Description |
|---|---|
| `ResponseZswByte1` | Status word, byte 1 |
| `ResponseZswByte2` | Status word, byte 2 |
| `ResponseCoord_X` | Actual X coordinate |
| `ResponseCoord_Y` | Actual Y coordinate |
| `ResponseCurrPoint` | Current drawing point |
| `ResponsePointsInBuffer` | Number of buffered points |
| `ResponseNumExpected` | Expected point number |
| `ResponseLastContRcv` | Last received contour |
| `ResponseLastContDone` | Last completed contour |
| `ResponseErrorCode` | Controller error code |
| `ResponseDrawingState` | Drawing execution state |

The PLC uses this feedback to coordinate motion execution and monitor communication status.

## Motion Execution

The ESP32 provides a 256-point circular buffer for trajectory execution.
CODESYS manages the transfer of points and monitors the available buffer capacity.
The ESP32 performs Bresenham-based interpolation and generates STEP/DIR signals using a dedicated 10 µs timer interrupt.
This design separates time-critical motion generation from the Linux-based PLC runtime.

## OPC UA Integration

CODESYS exposes application variables through its OPC UA server.
Ignition connects to the server using the `CodesysOpcUa` connection.

The interface includes:

| Variable Group | Purpose |
|---|---|
| `DB` | Machine commands and operating parameters |
| `Drawing` | Drawing data and execution parameters |
| `PLC_Command` | Outgoing command monitoring |
| `ESP32_Response` | Motion controller feedback |
| `FB100_Logic_Call` | PLC heartbeat and communication diagnostics |

The OPC UA interface allows Ignition to control the machine and visualize its status without directly communicating with the ESP32.

## Diagnostics and Error Handling

The PLC application provides diagnostic information for:

- PLC execution and heartbeat
- TCP communication with the ESP32
- Motion controller connection status
- ESP32 error codes
- Drawing execution feedback
- Machine operating states

Ignition uses these signals to display machine status, communication diagnostics, and alarms.
