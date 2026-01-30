- **Version**: 2.0.0
- **Created**: January 29, 2026
- **Updated**: January 29, 2026
- **Author**: Amith B R
- **Last Updated By**: Amith B R
- **Description**: SETU schema changes and ADR.
- **Status**: Live

# Project SETU_2: SQL Evolution and Temporal Upgrade
---

## 1. Executive Summary

### Context:
We have already implemented a Medallion Architecture.
We have a 5-Phase Design Action Plan (Normalization, Bronze-Flat, Control-Plane, ETL-Engine, Lifecycle).

Your design has evolved from a generic JSON-blob ingestion model to a high-performance, stateful **ELT (Extract-Load-Transform) Architecture**. 

**The Flaws in your current execution path:**
*   **Fragmentation:** You have the "What" (Flat tables) and the "How" (Procedures), but you lack the **"Order of Operations."** If you create the Hypertables without the proper composite indices first, your ETL will choke once you hit 1 million rows.
*   **The State-Dependency Risk:** Your business logic (Load/Unload) is fragile. If the state-cache table isn't initialized correctly for existing machines, your first batch will produce `NULL` values.
*   **Scaling Oversight:** You have 10k machines. If you don't implement the **WAL tuning** and **Transaction Batching** simultaneously with the table creation, your Kafka sink will face backpressure immediately this only needs to be documented and how to implement will be decided in next phase.


---

### 2. THE STRATEGY

To move Project SETU_2 to production, we will apply the **"Infrastructure-as-Code (IaC) Migration Pattern."** 

We will organize the action points into four logical phases:
1.  **The Bronze Foundation:** Physical storage and indexing.
2.  **The Control Plane:** Watermarking and state tracking.
3.  **The Transformation Logic:** Atomic procedures.
4.  **The Maintenance Layer:** Compression and Retention.

---

### 3. THE DESIGN ACTION PLAN (SETU_2 MVP2)


#### PHASE 1: ALL SCHEMA CHANGES (Ingestion Tier)
*   **Action 1.1: Schema Normalization:** Changing the table structure by adding or removing columns or renaming columns from master and silver schema.

#### PHASE 2: THE BRONZE FOUNDATION (Ingestion Tier)
*   **Action 2.1: Schema Flattening:** Reject JSONB. Define Bronze tables with strictly typed columns (`TIMESTAMPTZ`, `BIGINT`, `DOUBLE PRECISION`) to match the SQLite source templates.
*   **Action 2.2: Identity Injection:** Every Bronze table must include an `id BIGINT GENERATED ALWAYS AS IDENTITY`. This serves as the absolute tie-breaker for the watermark.
*   **Action 2.3: Hypertable Conversion:** Initialize all Bronze tables as Hypertables. Set `chunk_time_interval` based on 25% of available RAM (e.g., `1 day` for 32GB RAM at your 1k/sec ingest rate).
*   **Action 2.4: Composite Indexing:** Create a composite index on `(id, time DESC)` for every Bronze table. This is the **critical path** for the "Bounded ID-Sweep" ETL logic.

#### PHASE 3: THE CONTROL PLANE (Orchestration)
*   **Action 3.1: ETL Metadata Schema:** Create a protected `_etl` schema. Deploy the `watermarks` table to track `last_processed_id` and `last_processed_ts`.
*   **Action 3.2: State Cache (The Anchor):** Deploy the `silver.latest_cycle_state` table. This acts as a high-speed Key-Value store for the 10,000 machines to calculate `load_unload`.
*   **Action 3.3: Dimension Logic:** Finalize the `fn_get_shift_id` function. Shift logic must be calculated in the Silver layer, not the Bronze layer.

#### PHASE 4: THE TRANSFORMATION ENGINE (ELT Procedures)
*   **Action 4.1: Bounded ID-Sweep Implementation:** Implement the PL/pgSQL procedures using the `(id > v_last_id AND time >= v_last_ts - INTERVAL '1 hour')` logic.
*   **Action 4.2: Atomic State-Stitching:** Ensure the procedure uses the `LAG(..., 1, state_cache_value)` pattern to prevent calculation gaps between batches.
*   **Action 4.3: Sync State Update:** Use a CTE within the procedure to update the `latest_cycle_state` table in the **same transaction** as the Silver insert.
*   **Action 4.4: Job Scheduling:** Register the procedures as **TimescaleDB User Defined Actions (UDA)**. Set the `schedule_interval` to 1 minute to keep latency low without overloading the CPU.

#### PHASE 5: PERFORMANCE & LIFECYCLE (Optimization)
*   **Action 5.1: WAL Optimization:** Set `synchronous_commit = off` for the ETL and Ingestion users. This is mandatory for 10k machines to avoid disk-sync bottlenecks.
*   **Action 5.2: Columnar Compression:** Enable TimescaleDB compression on Bronze and Silver tables. 
    *   *Bronze:* Compress after 7 days (to allow for re-processing).
    *   *Silver:* Compress after 14 days.
*   **Action 5.3: Automated Retention:** Implement a 30-day `drop_chunks` policy on Bronze tables. Bronze is a "transit" layer; do not let it grow indefinitely.

---

### 4. THE EDUCATION

**Clarity of Thought: The "Why" behind the Plan.**

If you cannot explain your data flow, you cannot scale it. Here is the logic for your team:

1.  **Why Flat over JSON?** Because 10k machines generating 1k rows/sec will consume 10x the CPU if forced to parse text. Flat is "Native."
2.  **Why `id` over `time` for Watermarking?** Because at your scale, "time" is a crowd, not a line. `id` is the only way to ensure you don't miss records during a batch split.
3.  **Why a State-Cache table?** Because scanning the 500-million-row `silver.machine_cycles` table to find the "last cycle" for a machine is a suicide mission for performance. You need the answer in O(1) time.

**Next Step:** I recommend you execute **Phase 1 and 2** immediately. Once your tables are live and the first data points hit the state-cache, you can deploy the **Phase 3** transformation procedure. 

## Instructions
* You have a schema folder with all the required schemas and changes to be done for the tables that need to be created.
* You go through the schema folder and understand the changes that need to be done by the user for each schema and table.
* you create the these exact replica in schema_new folder with same folder structure and same .sql extension as the schema folder but with the changes that need to be done by the user for each schema and table. 
* then you can move with phase 2 of flattening the bronze tables and so on.