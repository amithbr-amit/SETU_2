/*
    OBJECT: sp_upsert_slv_machine_timeline
    AUTHOR: Amith B R
    PURPOSE: Populates the machine timeline in silver layer with states attributed to shifts.
    TARGET TABLE: silver.machine_timeline
    DEPENDENCIES: silver.machine_cycles, config.shift_schedule
*/

CREATE OR REPLACE PROCEDURE etl.sp_upsert_slv_machine_timeline(
    p_job_name TEXT DEFAULT 'sp_upsert_slv_machine_timeline',
    p_start_range TIMESTAMPTZ DEFAULT NULL,
    p_end_range TIMESTAMPTZ DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_log_id INT;
    v_rows_affected INT DEFAULT 0;
    v_start TIMESTAMPTZ;
    v_end TIMESTAMPTZ;
BEGIN
    -- 1. ORCHESTRATION START
    IF p_start_range IS NOT NULL THEN
        v_start := p_start_range;
        v_end := COALESCE(p_end_range, NOW());
    ELSE
        -- Default to processing last 2 days
        v_start := (CURRENT_DATE - INTERVAL '2 days');
        v_end := NOW();
    END IF;

    v_log_id := etl.fn_log_job_start(p_job_name, 'INCREMENTAL');

    -- 2. CORE LOGIC
    INSERT INTO silver.machine_timeline (
        logical_date,
        company_iot_id,
        machine_iot_id,
        source_cycle_start,
        shift_id,
        state_name,
        start_time,
        end_time,
        duration_seconds
    )
    WITH ref_shifts AS (
        SELECT company_iot_id, shift_id, logical_date, period as shift_range
        FROM config.shift_schedule
        WHERE period && tstzrange(v_start, v_end, '[)')
    ),

    base_intervals AS (
        SELECT 
            machine_iot_id,
            company_iot_id,
            cycle_start,
            actual_load_unload,
            std_load_unload,
            down_threshold,
            tstzrange(cycle_start, cycle_end, '[)') as running_range,
            tstzrange(cycle_start - (actual_load_unload * interval '1s'), cycle_start, '[)') as gap_range
        FROM silver.machine_cycles
        WHERE cycle_start >= v_start AND cycle_start < v_end
    ),

    expanded_states AS (
        SELECT 
            b.machine_iot_id,
            b.company_iot_id,
            b.cycle_start as source_cycle_start,
            states.state_name,
            states.event_range
        FROM base_intervals b
        CROSS JOIN LATERAL (
            -- 1. Running
            SELECT 'running' as state_name, b.running_range as event_range
            UNION ALL
            -- 2. Load/Unload
            SELECT 'load_unload', 
                tstzrange(lower(b.gap_range), lower(b.gap_range) + (least(b.actual_load_unload, b.std_load_unload) * interval '1s'), '[)')
            UNION ALL
            -- 3. Excess/Downtime
            SELECT 
                CASE WHEN b.actual_load_unload < b.down_threshold THEN 'exceed_load_unload' ELSE 'downtime' END,
                tstzrange(lower(b.gap_range) + (b.std_load_unload * interval '1s'), upper(b.gap_range), '[)')
            WHERE b.actual_load_unload > b.std_load_unload
        ) AS states
    ),

    final_set AS (
        SELECT 
            e.machine_iot_id,
            e.company_iot_id,
            e.source_cycle_start,
            s.shift_id,
            s.logical_date,
            e.state_name,
            lower(e.event_range * s.shift_range) as s_start,
            upper(e.event_range * s.shift_range) as s_end
        FROM expanded_states e
        INNER JOIN ref_shifts s ON e.company_iot_id = s.company_iot_id AND e.event_range && s.shift_range
    )

    SELECT 
        logical_date,
        company_iot_id,
        machine_iot_id,
        source_cycle_start,
        shift_id,
        state_name,
        s_start,
        s_end,
        EXTRACT(EPOCH FROM (s_end - s_start))::int
    FROM final_set
    WHERE s_start < s_end -- Ensure no zero-length intersections

    ON CONFLICT (company_iot_id, machine_iot_id, logical_date, source_cycle_start, state_name, shift_id) 
    DO UPDATE SET
        start_time = EXCLUDED.start_time,
        end_time = EXCLUDED.end_time,
        duration_seconds = EXCLUDED.duration_seconds;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- 3. ORCHESTRATION END
    CALL etl.sp_log_job_end(v_log_id, 'SUCCESS', v_rows_affected, 'Processed timeline states from ' || v_start || ' to ' || v_end);

EXCEPTION WHEN OTHERS THEN
    CALL etl.sp_log_job_end(v_log_id, 'FAILED', 0, SQLERRM);
    RAISE;
END;
$$;
