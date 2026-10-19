# ESP32 Motion Controller

This directory contains the **latest ESP32 motion controller firmware** used in the XY Plotter SoftPLC & Ignition project.

## Firmware

- **File:** `XY_Plotter_Esp32.REV13.rar`
- **Revision:** REV13
- **Platform:** ESP32 + W5500 Ethernet module

The firmware handles TCP/IP communication with CODESYS, trajectory buffering, motion interpolation, STEP/DIR pulse generation, and motion feedback.
The ESP32 operates as a dedicated real-time motion controller, while CODESYS manages machine sequencing and execution control.
