# Continuous Aggregate Refresh Policies

This document maintains the configuration for all Continuous Aggregates in the system, including their logical window and refresh frequency.

| Continuous Aggregate Name | Start Offset | End Offset | Schedule Interval | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `gold.cagg_prod_program_d` | 7 days | 1 hour | 5 minutes | Daily production totals and target tracking. |
| `gold.cagg_prod_machine_time_d` | 30 days | 1 hour | 10 minutes | Historical machine utilization and health trends. |

---

### Policy Definitions
- **Start Offset**: The start of the window that will be materialized (relative to now).
- **End Offset**: The end of the window that will be materialized (helps avoid materializing unstable recent data).
- **Schedule Interval**: How often the background worker runs to refresh the cagg.
