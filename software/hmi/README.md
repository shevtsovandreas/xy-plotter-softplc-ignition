# Ignition Perspective — HMI & SCADA

## Overview

The XY Plotter HMI is developed using **Ignition 8.3.10** and the Perspective module, running on a Raspberry Pi 5.

Ignition provides the main operator interface, drawing management, machine monitoring, diagnostics, and historical data visualization.

The application communicates with CODESYS SoftPLC through OPC UA and PostgreSQL through JDBC.

## Project Files

| File | Description |
|---|---|
| `XY_Plotter_Gateway_Ignition-backup-20261018-1830.gwbk` | Full Ignition Gateway backup — standard 2D version |
| `XY_Plotter_SCADA_2026-10-18_1830.zip` | Ignition project export — standard 2D version |
| `XY_Plotter_SCADA_2026-11-21_1857.zip` | Ignition project export — extended version with 2D and 3D visualization |
| `tags.json` | Ignition Tag Provider export |

### Gateway Backup

The `.gwbk` file is a complete Gateway-level backup intended for restoring an Ignition installation.

It may include Gateway configuration, projects, database connections, OPC UA connections, security settings, and other Gateway resources.

Restoring a Gateway backup replaces the configuration of the target Gateway. It should therefore be used on a dedicated or test installation.

**Note:** The provided Gateway backup contains the standard 2D version of the application. To use the Digital Twin,
import the extended project version after restoring the Gateway and configure the additional Digital Twin components.

### Project Export

Two versions of the **XY_Plotter_SCADA** Ignition project
are provided:

- **Standard Version (2D)** — original Perspective application with SVG-based drawing visualization.
- **Digital Twin Version (2D + 3D)** — extended Perspective application with interactive Three.js visualization and an Ignition WebDev API.

Both versions include:

- Perspective views and reusable components
- Python project scripts
- SQL Named Queries
- Gateway startup and shutdown scripts
- Tag Change event scripts
- Perspective styles and page configuration

Both project versions should be imported using the project name `XY_Plotter_SCADA`.

The Digital Twin version additionally requires the Ignition WebDev module, Nginx configuration, and the Digital Twin application files.

For installation and configuration instructions, see the
[Digital Twin software documentation](../digital-twin/README.md).

This export is suitable for importing the application into an existing Ignition Gateway without replacing its entire configuration.

### Tag Export

The `tags.json` file contains the exported Ignition tags used for PLC communication, machine monitoring, and application state management.

It includes OPC UA tags linked to CODESYS variables, as well as Memory and Expression tags.

The OPC UA connection named `CodesysOpcUa` must be configured on the target Gateway.

## Perspective Application

The HMI includes six main screens:

| Screen | Function |
|---|---|
| **Auto** | Automatic drawing execution, trajectory visualization, and machine status |
| **Library** | Drawing upload, preview, activation, and deletion |
| **Manual** | Jog controls, positioning, homing, and pen control |
| **I/O Monitor** | Communication signals, PLC/ESP32 data, and diagnostic logs |
| **Alarms** | Error monitoring and alarm history |
| **History** | Drawing execution records and historical results |

## Application Logic

The Ignition project includes several Python script libraries.

| Script Library | Responsibility |
|---|---|
| `gcodeTransfer.gcodeSend` | G-code processing and transfer of drawing data to CODESYS |
| `gcodeTransfer.bufferControl` | PLC drawing buffer control |
| `svgGeneration.gcodeParse` | G-code parsing |
| `svgGeneration.gcodePreview` | Drawing preview generation |
| `svgGeneration.gcodeMainView` | Drawing visualization in the main interface |
| `startUp.comm` | Communication signal initialization |
| `tableLogs.addLog` | Logging functionality |
| `popUp.openPopUp` | Popup handling |

### G-code Processing

Drawing files are managed through the Ignition application and stored in PostgreSQL.

The application parses G-code and transfers structured drawing information to CODESYS through OPC UA.

CODESYS then manages the execution sequence and sends motion commands to the ESP32 controller.

### Database Initialization

The project includes Gateway startup scripts and SQL Named Queries for database initialization.

These scripts create the required tables and indexes and initialize the communication signal and error catalogs.

The database must be configured and accessible before the application initialization can complete successfully.

## Communication

| Connection | Protocol | Description |
|---|---|---|
| Ignition ↔ CODESYS | OPC UA | Machine commands, status, and drawing data |
| Ignition ↔ PostgreSQL | JDBC | Drawing storage, catalogs, and history |
| Browser ↔ Ignition | HTTP/HTTPS | Perspective operator interface |

## Import and Restoration

### Option 1 — Full Gateway Restoration

Use the provided `.gwbk` file through the Ignition Gateway backup/restore interface.

This method restores Gateway-level resources and configuration.

**Warning:** Restoring a Gateway backup can overwrite existing Gateway settings. Use a dedicated installation.

### Option 2 — Project Import

1. Install Ignition 8.3.10 with the required modules.
2. Import the `XY_Plotter_SCADA` project ZIP through the Gateway interface.
3. Import `tags.json` into the appropriate Tag Provider.
4. Configure the CODESYS OPC UA connection.
5. Configure the PostgreSQL database connection.
6. Verify Named Queries, tag quality, and Gateway startup scripts.
7. Open the Perspective application and verify communication.

Gateway-level connections and credentials may require separate configuration when using the project export.

### Option 3 — Digital Twin Installation

1. Restore the Gateway backup or configure a new Ignition Gateway.
2. Import the Digital Twin project version as `XY_Plotter_SCADA`, replacing the standard version if already installed.
3. Install and enable the Ignition WebDev module.
4. Deploy the Digital Twin application files.
5. Install and configure Nginx.
6. Open the Perspective application through Nginx.
7. Verify 2D and 3D visualization and live machine feedback.

For detailed deployment instructions, see the [Digital Twin software documentation](../digital-twin/README.md).
