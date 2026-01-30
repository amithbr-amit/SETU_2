- **Version**: 1.7.0
- **Created**: January 6, 2026
- **Updated**: January 9, 2026
- **Author**: Rahul Shettigar
- **Last Updated By**: Rahul Shettigar
- **Description**: Records significant architectural decisions for the SETU project.
- **Status**: Live

# Architectural Decision Records (ADR)

This document records the significant architectural decisions made during the SETU project (MSSQL to TimescaleDB migration).

---

## 1. Database Technology: TimescaleDB

*   **Context**: The legacy MSSQL system struggled with high-volume telemetry ingestion and analytical query performance as data grew.
*   **Decision**: Migrate to **TimescaleDB** (PostgreSQL extension).
*   **Rationale**:
    *   **Hypertables**: Automatic partitioning by time handles high-ingest rates without manual sharding.
    *   **Continuous Aggregates**: Real-time rollups (e.g., hourly production) eliminate expensive `GROUP BY` queries on raw data.
    *   **SQL Compatibility**: Unlike NoSQL solutions (InfluxDB, MongoDB), TimescaleDB offers full SQL support (JOINs, CTEs), simplifying the migration of complex business logic.
    *   **Compression**: Columnar compression reduces storage costs by ~90% for historical data.

## 2. Architecture Pattern: Medallion Architecture

*   **Context**: We needed a clear separation between raw ingestion, cleaned facts, and business-ready aggregates.
*   **Decision**: Adopt a 3-layer approach:
    *   **Bronze**: Raw JSON ingestion (High write throughput).
    *   **Silver**: Cleaned, structured Hypertables (Star Schema facts).
    *   **Gold**: Aggregated metrics and reporting views (Read-optimized).
*   **Rationale**: Decouples ingestion speed from analytical load. Allows reprocessing of raw data if business logic changes.

## 3. Schema Management & Directory Structure

*   **Context**: Managing a large database schema in a single file or haphazard structure leads to merge conflicts and "drift."
*   **Decision**:
    *   **Flyway**: Use strict versioned migrations (`V00X__Name.sql`) for all DDL changes.
    *   **Export Structure**: When exporting the schema for reference/codebase, split strictly by object type:
        *   `schema/<schema_name>/Tables/`
        *   `schema/<schema_name>/Views/`
        *   `schema/<schema_name>/Materialized Views/`
        *   `schema/<schema_name>/Continuous Aggregates/`
        *   `schema/<schema_name>/Functions/`
        *   `schema/<schema_name>/Stored Procedures/`
*   **Rationale**: Granular files allow for cleaner Git diffs and easier navigation of the codebase.

## 4. Hypertable Primary Keys (Composite Keys)

*   **Context**: TimescaleDB requires that the partitioning column (usually `time`) be part of the Primary Key / Unique Constraints.
*   **Decision**: All Hypertables use composite Primary Keys.
    *   *Example*: `silver.machine_cycles` PK is `(machine_id, cycle_start)`.
    *   *Example*: `alerting.history` PK is `(alert_id, time)`.
*   **Rationale**: Enforces uniqueness constraints within partitions while satisfying TimescaleDB's partitioning requirements.

## 5. Multi-Tenancy (Composite Foreign Keys)

*   **Context**: The system supports multiple companies (tenants). A `machine_id` might not be globally unique across tenants, or we want to enforce strict tenant isolation.
*   **Decision**: `master.machine_info` uses a composite Primary Key `(machine_id, company_id)`.
*   **Consequence**: All child tables (`machine_assets`, `production_targets`, etc.) must use Composite Foreign Keys referencing both columns.
*   **Rationale**: Ensures that data is strictly bound to its tenant hierarchy and prevents accidental data leakage or orphaned records across tenants.

## 6. Alerting Engine Design

*   **Context**: Alerting logic in the legacy system was tightly coupled with reporting queries.
*   **Decision**: Decouple alerting into a separate `alerting` schema and engine.
    *   **Config**: `config.alert_rules` defines the logic.
    *   **State**: `alerting.active_alerts` tracks current state to prevent "alert storms" (deduplication).
    *   **History**: `alerting.history` provides an immutable audit log.
*   **Rationale**: Allows the alerting engine to run independently (e.g., as a background worker) without impacting user-facing dashboard performance.

---

## 7. Keyset Pagination for Migration

*   **Context**: Migrating millions of rows from MSSQL requires a pagination strategy that handles:
    1. Crash recovery (resume without re-processing)
    2. Phantom reads (new rows inserted during migration)
    3. Deterministic ordering (no duplicates, no gaps)
*   **Decision**: Use **Keyset Pagination** with composite cursor `(timestamp, IDD)`.
*   **Implementation**:
    ```sql
    SELECT TOP 5000 * FROM dbo.MachineWiseCycleDetails_MVP
    WHERE UpdatedTS > @last_ts OR (UpdatedTS = @last_ts AND IDD > @last_id)
    ORDER BY UpdatedTS, IDD
    ```
*   **Alternatives Rejected**:
    *   **OFFSET/FETCH**: Inconsistent results under concurrent writes; O(n) performance for deep pages.
    *   **SNAPSHOT Isolation**: Requires DBA configuration; adds transaction overhead.
*   **Rationale**: Keyset provides deterministic, resumable iteration without locking. At-Least-Once delivery is acceptable because Bronze→Silver has idempotent processing.

## 8. Migration Metadata System (V014)

*   **Context**: When running partial migrations (e.g., `--max-rows 10000` for testing), validation would flag "orphan batches" because MSSQL had more data than was migrated.
*   **Decision**: Create `bronze.migration_metadata` to track what was actually migrated.
*   **Schema**:
    | Column | Purpose |
    |--------|---------|
    | `run_id` | Groups tables from same migration run |
    | `min_timestamp`, `max_timestamp` | Exact range migrated |
    | `rows_migrated` | Audit count |
    | `company_ids[]` | Which tenants were involved |
*   **Consequence**: Validation queries filter MSSQL to `WHERE timestamp BETWEEN min AND max`, ensuring "apples-to-apples" comparison.
*   **Rationale**: Eliminates false-positive validation errors; enables limit-aware testing without full data loads.

## 9. NULL Handling in Gold Layer (COALESCE Strategy)

*   **Context**: Legacy MSSQL stored procedures had inconsistent NULL handling. For example:
    ```sql
    -- Legacy: 5 > NULL = UNKNOWN → falls to ELSE branch
    CASE WHEN actual > down_threshold THEN actual ELSE std END
    ```
*   **Decision**: Apply `COALESCE(column, 0)` in all Gold layer aggregates.
*   **Semantic Change**: 
    | Scenario | Legacy MSSQL | New TimescaleDB |
    |----------|--------------|-----------------|
    | `down_threshold = NULL` | Uses `actual` (UNKNOWN → ELSE) | Uses `std` (5 > 0 = TRUE) |
*   **Justification**: 
    1. Production data audit confirmed `down_threshold` is never NULL in practice.
    2. Explicit COALESCE prevents silent NULL propagation in rollups.
    3. Behavior is now deterministic and documented.
*   **Migration**: `V019__Logic_Drift_Remediation.sql` documents this change.

## 10. Write-Time Shift Resolution

*   **Context**: Legacy MSSQL resolved shifts at **read time** via `s_GetShiftTime` stored procedure. This caused:
    1. Inconsistent results if shift definitions changed retroactively.
    2. Performance overhead on every dashboard query.
*   **Decision**: Resolve `shift_id` at **write time** during Bronze→Silver processing.
*   **Implementation**: `bronze.proc_ingest_payload` calls `master.get_shift_id(plant_id, timestamp)` and persists result.
*   **Shift Logic**:
    ```sql
    -- Handles cross-midnight shifts (e.g., 22:00-06:00)
    CASE 
        WHEN end_time >= start_time THEN -- Normal day shift
            local_time >= start_time AND local_time < end_time
        ELSE -- Cross-midnight
            local_time >= start_time OR local_time < end_time
    END
    ```
*   **Timezone**: All shift calculations use `Asia/Kolkata` (IST). India does not observe DST, eliminating timezone drift.
*   **Rationale**: Pre-computed `shift_id` enables O(1) shift-based aggregations via partition pruning on Silver/Gold tables.


---

## 11. Schema Normalization (MVP2)

*   **Context**: The legacy schema used mixed GUIDs/Strings for IDs and had tight coupling between Machines and Plants, making re-assignment difficult.
*   **Decision**: 
    1.  **Integer IDs**: Adopt `SERIAL` (Integer) Primary Keys for all Master tables (`companies`, `plants`, `machines`).
    2.  **Decoupling**: Remove `plant_id` from `machine_info`. Use `plant_machine_mapping` table for N:M flexibility (though likely 1:1 in practice).
    3.  **Device Separation**: Split `device_id` into a separate `device_info` table to manage hardware inventory independently of machine assignment.
    4.  **Global Downtime Codes**: Remove `company_id` from `downtime_codes` to enforce a standard global catalog.
*   **Rationale**: 
    *   **Performance**: joining on INT is faster than Text/GUID.
    *   **Flexibility**: Machines can be moved between plants without changing their core record.
    *   **Inventory**: Hardware lifecycle (Devices) is distinct from Asset lifecycle (Machines).

