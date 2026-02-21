/*
    OBJECT: sp_upsert_gld_machine_shift_partial_oee
    AUTHOR: Amith B R
    PURPOSE: Consolidates OEE time and parts metrics into a single gold layer report at shift level.
    TARGET TABLE: gold.machine_shift_partial_oee
    DEPENDENCIES: etl.fn_calc_gld_oee_time, etl.fn_calc_gld_oee_parts
*/

CREATE OR REPLACE PROCEDURE etl.sp_upsert_gld_machine_shift_partial_oee(
    p_job_name TEXT DEFAULT 'sp_upsert_gld_machine_shift_partial_oee',
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    -- Standard Control Variables
    v_log_id INT;
    v_rows_affected INT DEFAULT 0;
    v_start_date DATE;
    v_end_date DATE;
    v_exec_type TEXT := 'INCREMENTAL';
BEGIN
    -------------------------------------------------------------------------
    -- 1. ORCHESTRATION START
    -------------------------------------------------------------------------
    -- Determine Date Range
    IF p_start_date IS NOT NULL THEN
        v_start_date := p_start_date;
        v_end_date := COALESCE(p_end_date, v_start_date);
        v_exec_type := 'MANUAL';
    ELSE
        -- Default to yesterday
        v_start_date := (CURRENT_DATE - INTERVAL '1 day')::DATE;
        v_end_date := v_start_date;
    END IF;

    -- Log Start
    v_log_id := etl.fn_log_job_start(p_job_name, v_exec_type);

    -------------------------------------------------------------------------
    -- 2. CORE LOGIC (The "Meat")
    -------------------------------------------------------------------------
    -- 2.1 Upsert Time Metrics
    INSERT INTO gold.machine_shift_partial_oee (
        company_id, plant_id, machine_id, logical_date, shift_id, shift_name,
        shift_start, shift_end, total_shift_duration_sec, total_down_sec, 
        total_utilised_sec, total_load_unload_sec, total_exceeded_load_unload_sec,
        last_updated_by, last_updated_ts
    )
    SELECT 
        src.company_id, src.plant_id, src.machine_id, src.logical_date, src.shift_id, src.shift_name,
        src.shift_start, src.shift_end, src.total_shift_duration_sec, src.total_down_sec,
        src.total_utilised_sec, src.total_load_unload_sec, src.total_exceeded_load_unload_sec,
        p_job_name, NOW()
    FROM etl.fn_calc_gld_oee_time(v_start_date, v_end_date) src
    ON CONFLICT (company_id, plant_id, machine_id, logical_date, shift_id)
    DO UPDATE SET 
        shift_name = EXCLUDED.shift_name,
        shift_start = EXCLUDED.shift_start,
        shift_end = EXCLUDED.shift_end,
        total_shift_duration_sec = EXCLUDED.total_shift_duration_sec,
        total_down_sec = EXCLUDED.total_down_sec,
        total_utilised_sec = EXCLUDED.total_utilised_sec,
        total_load_unload_sec = EXCLUDED.total_load_unload_sec,
        total_exceeded_load_unload_sec = EXCLUDED.total_exceeded_load_unload_sec,
        last_updated_by = EXCLUDED.last_updated_by,
        last_updated_ts = EXCLUDED.last_updated_ts;

    -- 2.2 Update Parts Metrics
    WITH parts_data AS (
        SELECT * FROM etl.fn_calc_gld_oee_parts(v_start_date, v_end_date)
    )
    UPDATE gold.machine_shift_partial_oee g
    SET 
        total_parts = p.total_parts,
        total_theoretical_time_sec = p.total_theoretical_time_sec,
        total_rejects = p.total_rejects,
        last_updated_by = p_job_name,
        last_updated_ts = NOW()
    FROM parts_data p
    WHERE g.company_id = p.company_id 
      AND g.plant_id = p.plant_id
      AND g.machine_id = p.machine_id 
      AND g.logical_date = p.logical_date 
      AND g.shift_id = p.shift_id;

    -- 2.3 Final Efficiency Calculations
    UPDATE gold.machine_shift_partial_oee
    SET 
        availability_effy = CASE WHEN total_shift_duration_sec > 0 THEN total_utilised_sec / total_shift_duration_sec ELSE 0 END,
        production_effy = CASE WHEN total_utilised_sec > 0 THEN total_theoretical_time_sec / total_utilised_sec ELSE 0 END,
        quality_effy = CASE WHEN total_parts > 0 THEN (total_parts::numeric - COALESCE(total_rejects, 0)::numeric) / total_parts::numeric ELSE 1.0 END,
        overall_effective_effy = 
            (CASE WHEN total_shift_duration_sec > 0 THEN total_utilised_sec / total_shift_duration_sec ELSE 0 END) * 
            (CASE WHEN total_utilised_sec > 0 THEN total_theoretical_time_sec / total_utilised_sec ELSE 0 END) *
            (CASE WHEN total_parts > 0 THEN (total_parts::numeric - COALESCE(total_rejects, 0)::numeric) / total_parts::numeric ELSE 1.0 END)
    WHERE logical_date BETWEEN v_start_date AND v_end_date;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -------------------------------------------------------------------------
    -- 3. ORCHESTRATION END & COMMIT
    -------------------------------------------------------------------------
    -- Log Success
    CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', v_rows_affected, 'Range: ' || v_start_date || ' to ' || v_end_date);

EXCEPTION WHEN OTHERS THEN
    -- Fail Gracefully
    CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
    RAISE;
END;
$$;
