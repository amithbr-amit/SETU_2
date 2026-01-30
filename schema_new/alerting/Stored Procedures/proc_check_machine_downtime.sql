CREATE OR REPLACE PROCEDURE alerting.proc_check_machine_downtime()
 LANGUAGE plpgsql
AS $procedure$

DECLARE

    r RECORD;

    v_active_exists BOOLEAN;

BEGIN

    -- Iterate over active Downtime Rules

    FOR r IN SELECT * FROM config.alert_rules WHERE metric = 'downtime_duration' AND enabled = TRUE LOOP

        

        -- Find machines exceeding the threshold

        -- Logic: Join live machine status or check most recent downtime record

        -- Simplified: Check open downtime sessions in silver.machine_downtime (assuming down_end is NULL for ongoing? 

        -- Or we look at silver.machine_status 'Stopped' duration).

        

        -- Approach: Check silver.machine_status for 'Stopped' state where duration > threshold.

        -- Note: This requires state duration calculation which is complex on raw events.

        -- Alternative: Use gold.live_status join with downtime start.

        

        -- Placeholder implementation for concept:

        -- INSERT INTO alerting.history ...

        NULL; 

        

    END LOOP;

END;

$procedure$
;
