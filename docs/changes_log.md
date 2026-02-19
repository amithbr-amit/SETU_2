# Changes Log

## Phase 1: Master Schema Normalization [30-Jan-2026]

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

## Phase 2: The Bronze Foundation (Ingestion Tier) [30-Jan-2026]

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

## Phase 3: Silver Layer Refinement [02-Feb-2026]

I have updated the Silver layer schema to align with the Bronze layer identifiers, specifically replacing the legacy text-based IDs with integer-based IoT IDs.

### Changes Implemented

#### 1. ID Standardization
- **Replaced**: `machine_id` (text) with `machine_iot_id` (integer) in all `machine_*` Silver tables.
- **Affected Tables**:
  - `machine_alarms`
  - `machine_cycles`
  - `machine_downtime`
  - `machine_energy`
  - `machine_focas`
  - `machine_pm_status`
  - `machine_status`
  - `machine_tool_usage`
- **Excluded**: `customer_feedback` table remains unchanged.

### 2. Bronze Layer Logical Attributes
- **Added**: `logical_date` and `shift_id` to `stg_machine_focas` only. The `bronze_layer_generator` rules remain unchanged for other tables.

### 3. Data Type Refinements (Bronze & Silver)
- **stg_machine_alarms / machine_alarms**: `alarm_no` changed from `text` to `integer`.
- **stg_machine_cycles / machine_cycles**: `program_no` changed from `text` to `varchar(50)`.
- **stg_machine_downtime / machine_downtime**: Removed `down_code`, added `program_no varchar(50)`.
- **stg_machine_energy / machine_energy**: `category` to `varchar(50)`, energy columns to `numeric(12,3)`.
- **stg_machine_focas / machine_focas**: `part_count`, `rej_count`, `pot`, `ot`, `ct` changed to `integer`. Columns reordered (focas only).
- **stg_machine_status / machine_status**: `program_no`, `status`, `operator_id` changed to `varchar(50)`.
- **stg_machine_tool_usage / machine_tool_usage**: `tool_no` to `varchar(50)`, `target_count`, `actual_count` to `integer`.

### 4. Silver Layer Time & Shift Refinements
- **Renamed**: `time` → `logical_date` in all Silver `machine_*` tables.
- **Converted**: `shift_id` from `text` to `integer`.
- **Added**: `shift_name varchar(50)` column.
- **Updated**: All time-based indexes renamed (e.g., `machine_alarms_time_idx` → `machine_alarms_logical_date_idx`).

### 5. Silver Layer Column Reordering
- **Standardized column order** in all Silver `machine_*` tables:
  1. `logical_date` (partition key)
  2. `company_id` (tenant identifier)
  3. `machine_iot_id` (machine reference)
  4. `shift_id`, `shift_name` (shift context)
  5. Table-specific business columns
  6. `created_at` (audit timestamp at end)

## Phase 4: Multi-Layer Schema Consolidation (IoT Alignment) [03-Feb-2026]

I have completed a major schema wide refactor to align the Master, Silver, Bronze, Config, and Alerting layers with the new surrogate key architecture and refined fact table definitions.

### Changes Implemented

#### 1. Bronze Layer Fact Refinement
- **stg_machine_cycles**: Removed `actual_load_unload` and `actual_cycle_time` columns as they are calculated downstream.
- **Generator Rules**: Updated `bronze_layer_generator` instructions to exclude these columns during auto-generation.

#### 2. Master Company Evolution
- **master.companies**:
  - Added `iot_id` (SERIAL) as the new Primary Key.
  - Changed `company_id` to `VARCHAR(100)` and added a `UNIQUE` constraint.
  - Added location/contact fields: `address`, `state`, `country`, `pin_code`, `email_id`, `phone_no`.
  - Added `effective_to_date` for temporal tracking.
  - Standardized column order for better readability.

#### 3. Global Dependency Migration (Cascading Changes)
- **Renamed**: `company_id` → `company_iot_id` across the entire database schema to align with the new surrogate key reference.
- **Type Upgrade**: Converted `company_iot_id` to `INTEGER` in all referencing tables.
- **Schema Impact (18+ Tables)**:
  - **Master**: `plants`, `machine_info`, `machine_assets`, `shifts`, `users`.
  - **Silver**: `machine_cycles`, `machine_status`, `machine_focas`, `machine_energy`, `machine_downtime`, `machine_alarms`, `customer_feedback`.
  - **Bronze**: `raw_telemetry`, `dead_letter_queue`.
  - **Config**: `alert_rules`, `alert_subscriptions`.
  - **Alerting**: `active_alerts`, `history`.
- **Constraint Refactoring**: Updated all Foreign Keys, Composite Primary Keys, and Unique Constraints (e.g., `uq_machine_company` and `fk_active_machine`) to reference the new column names and types.

#### 4. Machine Connection Details
- **master.machine_info**:
  - Made `device_iot_id` **nullable** to allow machines without pre-assigned devices.
  - Added `ip_address` (VARCHAR(50)) and `port_no` (INTEGER) for direct network connectivity.
  - Standardized column order (PK first, then connection details).

#### 5. Maintenance Status Expansion (AM & PM)
- **New Tables**: Created `stg_machine_am_status` (Bronze) and `machine_am_status` (Silver) to track Autonomous Maintenance metrics.
- **Refined columns**: Used `am_corrected_count` and `am_pending_count` as requested.
- **Standardisation**: 
  - Updated `machine_pm_status` (Silver) to use `company_iot_id` and added a Foreign Key.
  - Removed `shift_id` and `shift_name` from `machine_pm_status` (Silver & Bronze) as they are no longer required for PM tracking.
  - Converted `status` column to `VARCHAR(50)` in both AM and PM tables (Bronze & Silver) for consistency.

#### 6. Detailed Program Production Monitoring
- **New Tables**: Created `stg_machine_focas_program_production` (Bronze) and `machine_focas_program_production` (Silver) as requested.
- **Enhanced Tracking**: Added support for tracking `program_no`, `actual_count`, `target_count`, along with standardized metrics (`std_cycle_time`, `std_load_unload`) as **integers**.
- **Exception Alignment**: Configured these tables to follow the `stg_machine_focas` pattern, retaining `shift_id` and adding `logical_date` in the Bronze layer.
- **Bronze Cleanup**: Explicitly removed `shift_name` from all Bronze tables as it is a master/calculated attribute not required for raw ingestion.

#### 7. Shift Master Refinement
- **Schema Update**: Rebuilt `master.shifts` table with a new `id serial4` primary key and optimized types (`int2` for `shift_id`, `from_day`, `to_day`).
- **Additional Attributes**: Added `is_running`, `from_time`, `to_time`, and `updated_ts` to support dynamic shift management.

#### 8. Silver Layer Referential Integrity Reinforcement
- **Foreign Keys**: Added `machine_iot_id` foreign key constraints to all 10 Silver telemetry tables (`machine_status`, `machine_cycles`, `machine_alarms`, `machine_downtime`, `machine_energy`, `machine_focas`, `machine_focas_program_production`, `machine_am_status`, `machine_pm_status`, `machine_tool_usage`).
- **Standardization**: All constraints follow the naming pattern `fk_<shortname>_machine` and reference `master.machine_info(iot_id)`.

#### 9. Bronze Schema Cleanup
- **Decommissioned Tables**: Deleted legacy tables `dead_letter_queue`, `migration_metadata`, and `raw_telemetry` from the `bronze` schema in `schema_new`. Error handling and raw ingestion are now handled by the standardized `stg_` pipeline.

#### 10. ETL Schema Initialization & Bronze Cleanup
- **ETL Schema**: Created a new `etl` schema in `schema_new/etl/` with a dedicated directory structure for Tables, Procedures, and Views. This will house the unified ingestion and transformation logic.
- **Procedure Cleanup**: Deleted legacy stored procedures `proc_ingest_payload.sql` and `proc_process_bronze_batch.sql` from the `bronze` schema to prevent architectural ambiguity.

#### 14. Schema Synchronization & Standardization
- **Schema Definitions**: Added `schema_definition.sql` to all layers (`bronze`, `config`, `gold`, `master`, `silver`, `etl`, `mtb_catalog`) to ensure consistent initialization and idempotent schema creation.
- **Gold Layer Cleanup**: Removed all legacy `.sql` files (Continuous Aggregates, Functions, Views) from the `gold` layer to reset it for future analytical development.
- **Gold Layer Cleanup**: Removed all legacy `.sql` files (Continuous Aggregates, Functions, Views) from the `gold` layer to reset it for future analytical development.

#### 13. MTB Catalog Implementation

#### 12. Bronze and ETL Schema Refactoring
- **Bronze Prefix Swap**: Renamed all tables in `bronze` from `stg_` to `raw_` (e.g., `bronze.raw_machine_status`). Updated all SQL definitions, indexes, and partition logic to reflect this.
- **ETL Staging Layer**: Initialized 10 `UNLOGGED` staging tables in the `etl` schema using `stg_` prefixes. These are replicated from Bronze but optimized for transformation:
    - Removed `ingested_at` and `kafka_offset`.
    - Renamed `id` to `raw_id` for traceability.
- **Instructional Governance**:
    - Updated `instructions/bronze_layer_generator` for the new `raw_` standard.
    - Created `instructions/etl_schema_generator.md` to govern the ETL staging layer.
- **Environment Management**: Moved hardcoded directory paths from scripts into environment variables (`.env`). Added `.env.example` for project portability.

#### 11. Silver and Alerting Decommissioning
- **Silver Cleanup**: Deleted `customer_feedback.sql` table definition as the feedback loop is being relocated/rethought.
- **Alerting Decommissioning**: Completely removed the `alerting` schema directory (`schema_new/alerting/`). Live alert state and history are now outside the core telemetry scope.


## Phase 5: Procedural Transaction Fix [19-Feb-2026]

Resolved a critical transaction conflict in stored procedures where explicit `COMMIT` statements clashed with `EXCEPTION` blocks.

### Changes Implemented
- **RCA Identified**: PostgreSQL restricts `COMMIT` inside procedures when an `EXCEPTION` block (subtransaction) is active.
- **Fixed Procedures**: 
    - `config.sp_generate_shift_schedule`
    - `etl.sp_upsert_slv_machine_timeline`
- **Updated ADR**: Added "Procedure Transaction Handling (RCA)" to `docs/ArchitecturalDecisionRecords.md`.
