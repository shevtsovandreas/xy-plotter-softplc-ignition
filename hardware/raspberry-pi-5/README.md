# Raspberry Pi 5 — Edge Control Platform

## Overview

The Raspberry Pi 5 serves as the central edge computing platform for the XY Plotter automation system, replacing the original Siemens S7-1200 PLC and KTP700 Basic HMI.

The platform combines three main software components on a single Linux-based device:

- **CODESYS SoftPLC** — machine control, operating modes, sequencing, interlocks, and communication with the ESP32 motion controller.
- **Ignition Gateway** — web-based HMI, drawing management, process visualization, and diagnostics.
- **PostgreSQL** — storage of drawings, G-code, SVG data, alarm and signal catalogs, and execution history.

The ESP32 remains a separate motion controller responsible for real-time step generation and motor control.

## Hardware Specifications

| Component | Specification |
|---|---|
| Board | Raspberry Pi 5 Model B Rev 1.0 |
| CPU architecture | ARM64 (aarch64) |
| RAM | 8 GB |
| Storage | 64 GB microSD card |
| Swap | 2 GB zram |
| Network interfaces | Gigabit Ethernet, Wi-Fi |

## Operating System

| Parameter | Value |
|---|---|
| Distribution | Debian GNU/Linux 13.6 (Trixie) |
| Kernel | Linux 6.18.34+rpt-rpi-2712 |
| Architecture | aarch64 |
| Hostname | `RaspberyPi5` |

## Installed Software

| Software | Version | Purpose |
|---|---|---|
| CODESYS Control | 4.21.0.0 | SoftPLC runtime |
| CODESYS Runtime SDK | 3.5.22.20 | Runtime foundation |
| Ignition Gateway | 8.3.10 | HMI, visualization, and application logic |
| PostgreSQL | 17.11 | Relational database |
| Nginx | Installed | HTTP web server / proxy component |

## System Architecture

The Raspberry Pi hosts the PLC runtime, Ignition Gateway, and PostgreSQL database.

| Communication | Protocol | Purpose |
|---|---|---|
| Ignition ↔ CODESYS | OPC UA | Commands, machine status, and trajectory data |
| Ignition ↔ PostgreSQL | JDBC | Drawing storage, configuration, and history |
| CODESYS ↔ ESP32 | TCP/IP | Motion commands and controller feedback |
| Browser ↔ Ignition | HTTP | Access to Perspective HMI |

CODESYS manages the control sequence and machine interlocks, while the ESP32 executes time-critical motion operations using a circular point buffer and deterministic STEP/DIR pulse generation.

## Network Configuration

The current development installation uses Wi-Fi for network connectivity.

| Interface | Status | Description |
|---|---|---|
| `wlan0` | Active | Primary network connection |
| `eth0` | Down | Ethernet interface |
| `lo` | Active | Local loopback |

The device can be accessed over SSH using its local hostname:

```bash
ssh admin@raspberypi5.local
```

IP addresses depend on the local network configuration and are not required to reproduce the project.

For more predictable network communication, wired Ethernet is recommended when deploying the system in an industrial environment.

## Network Services and Ports

The following TCP ports were observed on the Raspberry Pi:

| Port | Service | Description |
|---|---|---|
| 22 | SSH | Remote terminal access |
| 80 | Nginx | HTTP server |
| 4840 | CODESYS OPC UA | PLC data exchange with Ignition |
| 5432 | PostgreSQL | Local database connection |
| 8060 | Ignition Gateway | Additional Gateway listener |
| 8088 | Ignition Gateway | HTTP Gateway access |
| 11740 | CODESYS Control | Runtime communication |

PostgreSQL is configured to listen on loopback addresses only (`127.0.0.1` and `::1`), allowing local applications to access the database without exposing it directly to the network.

CODESYS OPC UA is available through the Raspberry Pi network interface.

## System Services

The following services were confirmed running:

| Service | Status |
|---|---|
| `codesyscontrol.service` | Active |
| `Ignition-Gateway.service` | Active |
| `postgresql@17-main.service` | Active |

Ignition Gateway and PostgreSQL are configured as enabled system services.

CODESYS Control runs through a generated systemd service associated with its runtime startup configuration.

### Service Management

Check the service status:

```bash
sudo systemctl status codesyscontrol
sudo systemctl status Ignition-Gateway
sudo systemctl status postgresql@17-main
```

View the listening TCP ports:

```bash
sudo ss -lntp
```

Check PostgreSQL clusters:

```bash
pg_lsclusters
```

## Installation Paths

| Component | Path |
|---|---|
| CODESYS runtime | `/opt/codesys/` |
| CODESYS configuration | `/etc/codesyscontrol/CODESYSControl.cfg` |
| CODESYS runtime data | `/var/opt/codesys/` |
| Ignition Gateway | `/opt/ignition/` |
| PostgreSQL data | `/var/lib/postgresql/17/main/` |
| PostgreSQL logs | `/var/log/postgresql/postgresql-17-main.log` |

## Database

The PostgreSQL database used by the project is named `xyplotter`.
It stores drawing definitions, G-code and SVG data, reference catalogs, and execution history.
Database backup and restoration files are provided separately in the repository.

**Note:** This project is an engineering and educational demonstrator. The Raspberry Pi and software-based PLC architecture are not presented as a certified safety control system.
