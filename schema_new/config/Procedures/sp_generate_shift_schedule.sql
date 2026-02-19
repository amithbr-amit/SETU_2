/*
    OBJECT: sp_generate_shift_schedule
    AUTHOR: Amith B R
    PURPOSE: Generates shift instances for the next N days based on shift_definitions.
             Uses from_day and to_day for relative date calculations.
             Uses Asia/Kolkata for time calculations.
    USAGE: CALL config.sp_generate_shift_schedule(30);
*/

CREATE OR REPLACE PROCEDURE config.sp_generate_shift_schedule(
    p_days integer DEFAULT 30,
    p_job_name TEXT DEFAULT 'sp_generate_shift_schedule'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date date := current_date;
    v_end_date date := current_date + (p_days - 1);
    v_log_id INT;
    v_rows_affected INT DEFAULT 0;
BEGIN
    -- 1. ORCHESTRATION START
    v_log_id := etl.fn_log_job_start(p_job_name, 'INCREMENTAL');

    -- 2. CORE LOGIC
    INSERT INTO config.shift_schedule (
        company_iot_id,
        shift_name,
        shift_id,
        shift_start_time,
        shift_end_time,
        logical_date
    )
    SELECT 
        sd.company_iot_id,
        sd.shift_name,
        sd.shift_id,
        -- Start time: logical date + offset days + start_time defined (localized to shift timezone)
        (d + (sd.from_day * interval '1 day') + sd.start_time) AT TIME ZONE sd.timezone AS shift_start_time,
        -- End time: logical date + offset days + end_time (localized to shift timezone)
        (d + (sd.to_day * interval '1 day') + sd.end_time) AT TIME ZONE sd.timezone AS shift_end_time,
        d AS logical_date
    FROM generate_series(v_start_date, v_end_date, interval '1 day') AS d
    CROSS JOIN master.shift_definitions sd
    WHERE sd.is_running = true
    ON CONFLICT (company_iot_id, logical_date, shift_id) DO UPDATE SET
        shift_start_time = EXCLUDED.shift_start_time,
        shift_end_time = EXCLUDED.shift_end_time,
        shift_name = EXCLUDED.shift_name;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- 3. ORCHESTRATION END
    CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', v_rows_affected, 'Generated/Updated shifts for ' || p_days || ' days.');

EXCEPTION WHEN OTHERS THEN
    CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
    RAISE;
END;
$$;
