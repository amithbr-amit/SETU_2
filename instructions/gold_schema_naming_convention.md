This is the final, production-grade naming convention for your **Gold Layer Semantic Views**. It is designed for maximum performance in **TimescaleDB** and high developer readability in your **Medallion Architecture**.

---

### 1. THE BLUEPRINT: THE "GOLD SEMANTIC" FORMULA
Every view or aggregate in the `gold` schema must follow this strict 5-part anatomy:

> **`[Prefix]_[Domain]_[Specific_Metric]_[Granularity]_[Platform_Suffix]`**

#### A. Prefixes (The Tech)
*   `v_`: Standard PostgreSQL View (Use for real-time data or joining aggregates).
*   `cagg_`: TimescaleDB Continuous Aggregate (Use for all time-series historical trends).

#### B. Domains (The Business Logic)
*   `oee`: Overall Equipment Effectiveness metrics (AE, PE, QE).
*   `prod`: Production totals, targets, cycles, and program data.
*   `maint`: Maintenance, machine health, alarms, and downtime.
*   `util`: Utilities, energy, power consumption, and costs.

#### C. Granularity (The Time-Bucket)
*   `rt`: Real-time / Raw (No aggregation).
*   `sh`: Shift-based (Based on `master.shift_definitions`).
*   `d`: Daily.
*   `w`: Weekly.
*   `m`: Monthly.

#### D. Platform Suffix (The Exception)
*   **[Null]**: Default. Assumed to be **Web/Desktop** (High resolution, full detail).
*   `_mob`: Specific views optimized for **Mobile** (Thin payloads, high aggregation).

---

### 2. THE OFFICIAL REGISTRY (Mapped to UI Widgets)

| Dashboard Widget | Web Name (Default) | Mobile Name (Override) |
| :--- | :--- | :--- |
| **Partial OEE** | `cagg_oee_components_sh` | `v_oee_components_sh_mob` |
| **Target vs Actual** | `cagg_prod_target_actual_sh` | `v_prod_target_actual_sh_mob` |
| **CNC Health Trend** | `v_maint_cnc_health_rt` | `v_maint_cnc_health_rt_mob` |
| **Downtime Losses** | `cagg_maint_downtime_val_d` | `v_maint_downtime_val_d_mob` |
| **Energy Consumption**| `cagg_util_energy_kwh_d` | `v_util_energy_kwh_d_mob` |
| **Top 3 Down Reasons** | `v_maint_top_down_reasons_sh` | `v_maint_top_down_reasons_sh_mob` |
| **Runtime Chart** | `v_prod_runtime_gantt_rt` | *N/A (Web Exclusive)* |

---

### 3. THE RULES OF ENFORCEMENT (Negative Constraints)
1.  **No CamelCase:** Everything must be `lowercase_underscore_separated`.
2.  **No Plural Metric Names:** Use `energy`, not `energies`. Use `down_reason`, not `down_reasons`.
3.  **Maximum 63 Characters:** Postgres will truncate anything longer. Keep descriptors sharp.
4.  **No Schema-Crossing:** Gold views should only join `gold.tables`, `silver.tables`, or `master.tables`. Never join back to `bronze` or `etl`.
5.  **Cagg Consistency:** If a `cagg_` exists for a metric, the `_mob` view **must** query the `cagg_`, not the raw `silver` table.

--- 

