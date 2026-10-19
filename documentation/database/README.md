# PostgreSQL — Database Architecture

## Overview

The XY Plotter automation system uses **PostgreSQL 17** as its relational database, hosted locally on the Raspberry Pi 5.

The database, named `xyplotter`, provides persistent storage for drawing management, execution history, communication diagnostics, and error tracking.

Ignition Gateway communicates with PostgreSQL through JDBC using SQL Named Queries and project scripts.

## Database Structure

The database contains six main tables, organized into three functional groups.

### Drawing Management

| Table | Description |
|---|---|
| `drawing` | Stores drawing metadata, G-code, SVG previews, dimensions, and point/contour counts |
| `drawing_history` | Records drawing execution history, results, and completed points |

### Communication Diagnostics

| Table | Description |
|---|---|
| `comm_signal` | Defines PLC/ESP32 communication signals, registers, bit positions, and descriptions |
| `comm_log` | Records communication signal changes and diagnostic events |

### Error Management

| Table | Description |
|---|---|
| `error_catalog` | Stores predefined error codes, descriptions, sources, and priorities |
| `error_history` | Records error events, timestamps, and states |

## Drawing Management

The `drawing` table acts as the central drawing library.

Each drawing contains its original G-code and generated SVG preview, together with metadata used by the Ignition application.

The typical workflow is:

1. An operator uploads a G-code file through Ignition Perspective.
2. Ignition processes the file and generates the SVG preview.
3. Drawing information is saved in PostgreSQL.
4. The operator selects and activates a drawing.
5. Ignition retrieves the G-code and prepares the trajectory for CODESYS.
6. Execution results are recorded in `drawing_history`.

This approach allows drawings to be stored and reused without manually transferring files to the PLC.

## Communication Signal Catalog

The `comm_signal` table defines the communication signals displayed in the Ignition I/O Monitor.

Signal definitions include register information, bit positions, and descriptive metadata.

The `comm_log` table stores signal state changes for diagnostic purposes.

This allows the application to provide both live signal monitoring and historical communication logs.

## Error Catalog and History

The error management system separates error definitions from error occurrences.

- `error_catalog` contains predefined PLC and ESP32 error codes, descriptions, and priorities.
- `error_history` stores recorded error events and their associated timestamps and states.

Ignition uses these tables to display active errors and historical alarm information.

## Automatic Database Initialization

The database is initialized automatically by the Ignition application during Gateway project startup.

The startup logic:

1. Creates required tables if they do not already exist.
2. Creates database indexes.
3. Initializes the communication signal catalog.
4. Initializes the predefined PLC and ESP32 error catalog.

Initialization is implemented using Ignition project scripts and SQL Named Queries.

The database connection must be configured and accessible before initialization can complete successfully.

Existing drawing data and execution history are not restored by the initialization scripts.

## Data Access

Ignition is the main application responsible for reading and writing database records.

| Operation | Component |
|---|---|
| Drawing upload and storage | Ignition Perspective / Named Queries |
| Drawing retrieval | Ignition project scripts |
| Execution history | Ignition / Named Queries |
| Communication logging | Ignition project scripts |
| Error catalog initialization | Ignition startup scripts |
| Error history | Ignition / Named Queries |

CODESYS and ESP32 do not communicate directly with PostgreSQL. Their operating data is exchanged through the PLC and Ignition integration layers.

## Backup and Restoration

The repository includes two database exports:

- `xyplotter_full.backup` — complete database backup with stored data.
- `xyplotter_schema.sql` — database structure without data.
