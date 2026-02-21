- **Version**: 2.0.0
- **Created**: January 30, 2026
- **Updated**: January 30, 2026
- **Author**: Amith B R
- **Description**: Records significant architectural decisions for the SETU project (MVP2).
- **Status**: Live

# Architectural Decision Records (ADR) - MVP2

---

## 1. Schema Normalization (MVP2)

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


---

## 2. Bronze Layer Architecture (MVP2)

*   **Context**: The previous `raw_telemetry` (single JSONB table) design suffered from poor debuggability and difficulty in managing retention for specific data types.
*   **Decision**: Adopt a "Staging Table" approach with strict schemas for the Bronze Layer.
    1.  **Strict Schemas**: Replace generic JSONB with specific tables (`stg_machine_cycles`, etc.) that mirror Silver facts.
    2.  **Partitioning**: Partition Hypertables by `ingested_at` (Arrival Time), NOT event time.
    3.  **Chunking**: Use **1-day chunks**.
    4.  **Retention**: **30 days**.
*   **Standards**:
    *   **Prefix**: `bronze.raw_`.
    *   **System Columns**: `id` (Identity), `ingested_at`, `kafka_offset`, `machine_iot_id`, `device_id`.

*   **Rationale (The Warehouse Analogy)**:
    *   **Bronze is a warehouse receiving boxes**. Every day, trucks drop off boxes. Some contain today's items, some contain last week's.
    *   **Ingestion Partitioning Rule**: *"Sort boxes by arrival date, not manufacture date."*
        *   When boxes arrive, label them by the day they entered. You don't control when trucks arrive, and old items can arrive today.
        *   We care about when we *received* the data for cleanup purposes.
    *   **Chunk Management Rule**: *"Use small daily storage bins."*
        *   Store boxes in daily bins. When it's time to clean up, you throw away one bin at a time.
        *   This makes `DROP_CHUNK` fast and keeps the warehouse running smoothly while new trucks arrive.
    *   **The "Watermark Anchor"**:
        *   We force an `id BIGINT IDENTITY` column on every Bronze table.
        *   This acts as the absolute tie-breaker. If 1,000 machines report events at the exact same millisecond, the `id` allows the ETL process to know exactly where to restart (`WHERE id > last_processed_id`) without losing or duplicating data.

---

## 3. Silver Layer Architecture

*   **Context**: The Silver Layer holds cleaned, enriched, and structured data. Data volume varies significantly between different types of machine events.
*   **Decision**:
    1.  **Hypertable Classification**:
        *   **High Frequency (7-day chunks)**: High-volume operational data.
            *   `machine_cycles`
            *   `machine_downtime`
        *   **Low Frequency (1-month chunks)**: Lower volume, status, or summary data.
            *   `machine_alarms`
            *   `machine_energy`
            *   `machine_focas`
            *   `machine_focas_program_production`
            *   `machine_tool_usage`
            *   `machine_am_status`
            *   `machine_pm_status`
    2.  **Standard Tables (No Hypertable)**:
        *   `machine_status`: Stores the *current* or latest state. Not a time-series history log.
    3.  **Compression**:
        *   Enable **TimescaleDB Native Compression** to reduce storage costs.
        *   **Policy**:
            *   **High Frequency**: Compress chunks older than **30 days** (allows for late-arriving data/corrections to stay uncompressed for a buffer period).
            *   **Low Frequency**: Compress chunks older than **3 months** (data is often accessed for monthly reporting).
*   **Rationale**:
    
    #### 1. Why 7 Days is WRONG for Low Velocity tables (`machine_focas`, `machine_energy`)
    If you use a 7-day chunk size for tables that only get 3-6 rows per machine per day, you will create **"Micro-Chunks."**
    
    *   **The Math:**
        *   Assume 100 machines.
        *   `machine_focas`: 300 rows/day → 2,100 rows/week.
        *   2,100 rows is tiny (approx 100KB - 200KB).
    *   **The Problem:**
        *   TimescaleDB (and PostgreSQL) has overhead for every single chunk (metadata, file handles, vacuum processes).
        *   Creating a separate physical file for just 200KB of data is inefficient. It wastes disk inodes and slows down the query planner (it has to scan through hundreds of tiny files instead of a few large ones).
    
    #### 2. The Recommended Strategy: Coarse Chunking
    
    **For `machine_focas` and `machine_energy`:**
    Use a **1 Month** interval.
    
    This gathers enough data (~30 shifts per machine) into a single file to make Indexes effective and Compression efficient.
    
    > **Note**: **Space Partitioning** is **Strictly Forbidden** for this volume.
    
    ```sql
    -- Create Hypertable for Focas (Low Velocity)
    SELECT create_hypertable('silver.machine_focas', 'logical_date', 
        chunk_time_interval => INTERVAL '1 month');
    
    -- Create Hypertable for Energy (Low Velocity)
    SELECT create_hypertable('silver.machine_energy', 'logical_date', 
        chunk_time_interval => INTERVAL '1 month');
    ```
    
    *(Note: If you have fewer than 50 machines, you could even increase this to `INTERVAL '3 months'` or `INTERVAL '1 year'`.)*
    
    #### 3. Compression is CRITICAL here
    Since these tables are sparse (few rows per day), they are prime candidates for massive compression savings (often 96%+ reduction).
    
    However, because the data is sparse, you must **Segment By** the Machine ID to force the database to group that machine's monthly history together physically.
    
    **Configuration for `machine_focas`:**
    ```sql
    ALTER TABLE silver.machine_focas SET (
        timescaledb.compress,
        timescaledb.compress_segmentby = 'machine_iot_id', 
        timescaledb.compress_orderby = 'logical_date DESC'
    );
    
    -- Compress data older than 3 months (to allow for late shift data)
    SELECT add_compression_policy('silver.machine_focas', INTERVAL '3 months');
    ```
    
    **Configuration for `machine_energy`:**
    ```sql
    ALTER TABLE silver.machine_energy SET (
        timescaledb.compress,
        timescaledb.compress_segmentby = 'machine_iot_id, category', 
        timescaledb.compress_orderby = 'logical_date DESC'
    );
    
    -- Compress data older than 3 months
    SELECT add_compression_policy('silver.machine_energy', INTERVAL '3 months');
    ```
    
    #### Summary Comparison
    
    | Table | Frequency | Recommended Chunk Size | Why? |
    | :--- | :--- | :--- | :--- |
    | `machine_cycles` | High (Secs to Hours) | **7 Days** | Needs to manage high insert volume and keep recent data hot. |
    | `machine_focas` | Low (3 per day) | **1 Month** | Avoids "micro-chunks"; groups enough data to compress well. |
    | `machine_energy`| Low (6 per day) | **1 Month** | Avoids "micro-chunks"; groups enough data to compress well. |

---

## 4. Data Types Standards

*   **Context**: PostgreSQL handles `TEXT` and `VARCHAR(N)` almost identically in terms of storage and performance. However, `VARCHAR(N)` enforces a length limit that often requires expensive `ALTER TABLE` operations later if requirements change.
*   **Decision**: 
    1.  **Prefer TEXT**: Use `TEXT` for all string/character columns by default.
    2.  **Avoid VARCHAR(N)**: Do not use `VARCHAR` or `VARCHAR(N)` unless there is a specific, immutable business requirement for a length constraint (e.g., legacy system compatibility).
*   **Rationale**: 
    *   **Flexibility**: `TEXT` allows for future growth without schema migrations.
    *   **Performance**: There is no performance penalty for using `TEXT` over `VARCHAR` in PostgreSQL.
    *   **Simplicity**: Reduces cognitive load during schema design; no need to guess "max lengths".

---

## 5. Procedure Transaction Handling (RCA)

*   **Context**: Several procedures were failing with `SQL Error [2D000]: cannot commit while a subtransaction is active` during manual execution or Flyway migrations.
*   **Decision**: 
    1.  **Remove Explicit COMMIT**: Procedures that utilize `EXCEPTION` blocks must NOT contain explicit `COMMIT` or `ROLLBACK` statements.
    2.  **Rely on Auto-Commit**: Trust the database engine's default behavior to commit the transaction upon successful completion of the `CALL` statement.
*   **Rationale**: 
    *   **Subtransaction Conflict**: In PostgreSQL PL/pgSQL, an `EXCEPTION` block internally creates a subtransaction (savepoint). PostgreSQL restricts transaction control commands (`COMMIT/ROLLBACK`) while a subtransaction is active.
    *   **Robustness**: Standardizing this pattern ensures procedures are compatible with error handling protocols and orchestration tools (like Flyway) without causing transaction state errors.
    *   **Clean Orchestration**: ETL procedures should log their start/end status and let the high-level orchestration handle the final transaction state where appropriate.

---

## 6. Function Language Selection (SQL vs. PL/pgSQL)

*   **Context**: PostgreSQL provides multiple languages for writing functions. Choosing the right one affects both maintainability and system performance.
*   **Decision**:
    1.  **Prefer LANGUAGE SQL for "Simple" Logic**: Use `LANGUAGE sql` for functions that consist of a single `SELECT` statement, basic expressions, or simple wrappers.
    2.  **Use LANGUAGE PL/pgSQL for "Complex" Logic**: Reserve `LANGUAGE plpgsql` for functions requiring procedural control (IF/ELSE, LOOP, variables) or explicit error handling (`EXCEPTION` blocks).
*   **Rationale - Performance Improvements**:
    *   **Function Inlining**: The PostgreSQL query optimizer can **inline** `LANGUAGE sql` functions. This means the engine "expands" the function code into the parent query, allowing it to optimize index usage, joins, and filters as if the logic were written inline. `LANGUAGE plpgsql` functions act as a "black box" to the optimizer, often preventing these optimizations.
    *   **Reduced Overhead**: SQL functions avoid the overhead of initializing the PL/pgSQL interpreter state, which is significant for lightweight utility functions called frequently in large datasets.
*   **Usage Standards**:
    *   **Utility Functions**: Like `fn_week_start` or `fn_to_utc` must be `LANGUAGE sql` and `IMMUTABLE` to maximize performance.
    *   **ETL Calculations**: May use `PL/pgSQL` if they involve complex multi-step processing or if they are top-level procedures (`etl.sp_...`).
