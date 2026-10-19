# PostgreSQL Database

## Overview

PostgreSQL 17 is used as the database backend for the XY Plotter automation system.
The database stores drawing definitions, G-code, SVG previews, communication signal definitions, error catalogs, and execution history.
Database initialization and reference data management are implemented through **Ignition Gateway startup scripts and Named Queries**.

## Database Files

| File | Description |
|---|---|
| `xyplotter_full.backup` | Complete PostgreSQL backup, including database structure and stored data |
| `xyplotter_schema.sql` | SQL export of the database structure without data |

## Database Structure

The database is named `xyplotter` and contains six main tables.

| Table | Purpose |
|---|---|
| `drawing` | Drawing metadata, G-code, SVG previews, dimensions, and point/contour counts |
| `drawing_history` | Drawing execution history, results, and completed points |
| `comm_signal` | Communication signal definitions, registers, bit numbers, and descriptions |
| `comm_log` | Communication signal state-change history |
| `error_catalog` | Error codes, descriptions, sources, and priorities |
| `error_history` | Error events, timestamps, and states |

## Automatic Database Initialization

The Ignition project includes an automatic database initialization procedure executed during Gateway project startup.
The `onStartup` script performs the following operations:

1. Creates communication signal and log tables, if they do not already exist.
2. Creates the required database indexes.
3. Initializes the communication signal definitions using `startUp.comm.setupSignals()`.
4. Creates the application tables, including drawings and execution history.
5. Initializes the error catalog with predefined ESP32 and PLC error codes.

The initialization uses Ignition Named Queries located under `System/`.

**The database structure and reference catalogs are managed by the Ignition application.** Manual execution of the SQL schema is not required when starting with an empty, correctly configured database.

Automatic initialization does not restore previously stored drawings or historical records.

## Restoring the Database

To restore the complete database from the provided backup:

```bash
sudo -u postgres createdb xyplotter
```

```bash
sudo -u postgres pg_restore \
  --no-owner \
  --no-privileges \
  -d xyplotter \
  xyplotter_full.backup
```

These commands assume that the database does not already exist.

After restoration, configure the PostgreSQL connection in Ignition Gateway and ensure the database user has the required permissions.
