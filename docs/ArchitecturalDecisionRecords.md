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
