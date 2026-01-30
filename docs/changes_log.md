# Changes Log

## Phase 1: Master Schema Normalization

I have successfully normalized the `master` schema in the `d:\SETU_2\schema_new` directory. This aligns the schema with the latest architectural decisions (Integer IDs, Decoupling, Device Management).

### Changes Implemented

#### 1. Unified Integer IDs
All Master tables now use `SERIAL` (Auto-incrementing Integer) Primary Keys instead of Text/GUIDs for better performance and standard indexing.

#### 2. Machine-Plant Decoupling
- **Removed** `plant_id` column from `master.machine_info`.
- **Created** `master.plant_machine_mapping` table to handle N:M relationships (though functionally strict assignment).

#### 3. Device Management
- **Created** `master.device_info` table (`device_iot_id` PK).
- **Modified** `master.machine_info` to reference `device_iot_id` instead of embedding device details.

#### 4. Schema Cleanup
- **Common Standards**: Renamed columns in `machine_assets` (`license_type` -> `subscription_tier` ENUM).
- **Dropped** `master.machine_health_settings` as part of the cleanup.
- **Global Codes**: Removed `company_id` from `master.downtime_codes` to promote a global standard catalogue.

### Documentation Updates
- **DataDictionary.md**: Updated ERD and Schema Definitions to reflect the new `master` structure.
- **ADR**: Added "Schema Normalization (MVP2)" record to `ArchitecturalDecisionRecords.md`.

### File Manifest (`schema_new/master/Tables`)
- `companies.sql` (Normalized)
- `device_info.sql` (New)
- `downtime_codes.sql` (Normalized)
- `machine_assets.sql` (Normalized)
- `machine_info.sql` (Normalized)
- `plant_machine_mapping.sql` (New)
- `plants.sql` (Normalized)
- `production_targets.sql` (Pending downstream update)
- `shifts.sql` (Pending downstream update)
- `users.sql` (Pending downstream update)

## Phase 2: The Bronze Foundation (Ingestion Tier)

I have successfully generated the new Bronze Layer schema in `d:\SETU_2\schema_new\bronze`. This layer is now optimized for high-performance ingestion and strict typing.

### Changes Implemented

#### 1. New Bronze Tables
Created 8 new tables prefixed with `stg_` matching the Silver layer facts:
- `stg_machine_cycles`
- `stg_machine_status`
- `stg_machine_energy`
- `stg_machine_alarms`
- `stg_machine_downtime`
- `stg_machine_focas`
- `stg_machine_tool_usage`
- `stg_machine_pm_status`

*Note: `customer_feedback` was excluded.*
*Note: Legacy tables (`raw_telemetry`, etc.) were RETAINED.*

#### 2. Standardization Rules
- **System Columns**: `id` (Identity), `ingested_at` (Partition Key), `kafka_offset`, `device_iot_id`, `machine_iot_id`.
- **Hypertable**: 1-day chunks partitioned by `ingested_at`.
- **Indexing**: Watermark index `(id, ingested_at DESC)`.
- **Retention**: 30-day retention policy.
