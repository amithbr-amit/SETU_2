/*
    OBJECT: fn_calc_gld_oee_parts
    AUTHOR: Amith B R
    PURPOSE: Calculates part-based OEE metrics (count, theoretical time) from silver focas data.
    TARGET TABLE: gold.machine_shift_partial_oee
    DEPENDENCIES: silver.machine_focas_program_production
*/

CREATE OR REPLACE FUNCTION etl.fn_calc_gld_oee_parts(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    company_id text,
    plant_id integer,
    machine_id text,
    logical_date date,
    shift_id integer,
    total_parts integer,
    total_theoretical_time_sec numeric(18,2),
    total_rejects integer
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
    parts_agg AS (
        SELECT 
            machine_iot_id,
            company_iot_id,
            logical_date::date as l_date,
            shift_id,
            SUM(actual_count)::integer as parts,
            SUM(actual_count * (std_cycle_time + std_load_unload))::numeric(18,2) as theoretical_time
        FROM silver.machine_focas_program_production
        WHERE logical_date >= (p_start_date::timestamp AT TIME ZONE 'UTC') 
          AND logical_date <= (p_end_date::timestamp AT TIME ZONE 'UTC')
        GROUP BY machine_iot_id, company_iot_id, logical_date, shift_id
    ),
    rejects_agg AS (
        SELECT 
            machine_iot_id,
            company_iot_id,
            logical_date::date as l_date,
            shift_id,
            SUM(rej_count)::integer as rejects
        FROM silver.machine_focas
        WHERE logical_date >= (p_start_date::timestamp AT TIME ZONE 'UTC') 
          AND logical_date <= (p_end_date::timestamp AT TIME ZONE 'UTC')
        GROUP BY machine_iot_id, company_iot_id, logical_date, shift_id
    )
    SELECT 
        mm.company_id,
        mm.plant_id,
        mm.machine_id,
        pa.l_date,
        pa.shift_id,
        pa.parts,
        pa.theoretical_time,
        COALESCE(ra.rejects, 0) as rejects
    FROM parts_agg pa
    JOIN machine_meta mm ON pa.machine_iot_id = mm.machine_iot_id AND pa.company_iot_id = mm.company_iot_id
    LEFT JOIN rejects_agg ra ON pa.machine_iot_id = ra.machine_iot_id 
                            AND pa.company_iot_id = ra.company_iot_id 
                            AND pa.l_date = ra.l_date 
                            AND pa.shift_id = ra.shift_id;
END;
$$;
