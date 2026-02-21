/*
    OBJECT: fn_calc_gld_oee_time
    AUTHOR: Amith B R
    PURPOSE: Aggregates time-based metrics (durations) from machine timeline for OEE calculation.
    TARGET TABLE: gold.machine_shift_partial_oee
    DEPENDENCIES: silver.machine_timeline
*/

CREATE OR REPLACE FUNCTION etl.fn_calc_gld_oee_time(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    company_id text,
    plant_id integer,
    machine_id text,
    logical_date date,
    shift_id integer,
    shift_name text,
    shift_start timestamp with time zone,
    shift_end timestamp with time zone,
    total_shift_duration_sec numeric(18,2),
    total_down_sec numeric(18,2),
    total_utilised_sec numeric(18,2),
    total_load_unload_sec numeric(18,2),
    total_exceeded_load_unload_sec numeric(18,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH machine_meta AS (
        SELECT 
            m.iot_id AS machine_iot_id,
            m.machine_id,
            m.company_iot_id,
            c.company_id,
            COALESCE(pmm.plant_id, c.default_plant_id) AS plant_id
        FROM master.machine_info m
        JOIN master.companies c ON m.company_iot_id = c.iot_id
        LEFT JOIN master.plant_machine_mapping pmm ON m.iot_id = pmm.machine_iot_id
    ),
    timeline_agg AS (
        SELECT 
            machine_iot_id,
            company_iot_id,
            logical_date::date as l_date,
            shift_id,
            MAX(shift_name) as s_name,
            MIN(start_time) as s_start,
            MAX(end_time) as s_end,
            SUM(duration_sec)::numeric(18,2) as total_duration,
            SUM(CASE WHEN state_code = 'DOWN' THEN duration_sec ELSE 0 END)::numeric(18,2) as down_sec,
            SUM(CASE WHEN state_code = 'RUNNING' THEN duration_sec ELSE 0 END)::numeric(18,2) as utilized_sec
        FROM silver.machine_timeline
        WHERE logical_date >= (p_start_date::timestamp AT TIME ZONE 'UTC') 
          AND logical_date <= (p_end_date::timestamp AT TIME ZONE 'UTC')
        GROUP BY machine_iot_id, company_iot_id, logical_date, shift_id
    )
    SELECT 
        mm.company_id,
        mm.plant_id,
        mm.machine_id,
        ta.l_date,
        ta.shift_id,
        ta.s_name,
        ta.s_start,
        ta.s_end,
        ta.total_duration,
        ta.down_sec,
        ta.utilized_sec,
        0::numeric(18,2) as load_unload_sec, -- Placeholder for future logic
        0::numeric(18,2) as exceeded_load_unload_sec -- Placeholder
    FROM timeline_agg ta
    JOIN machine_meta mm ON ta.machine_iot_id = mm.machine_iot_id AND ta.company_iot_id = mm.company_iot_id;
END;
$$;
