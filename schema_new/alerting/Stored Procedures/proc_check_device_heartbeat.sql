CREATE OR REPLACE PROCEDURE alerting.proc_check_device_heartbeat(IN p_threshold_minutes integer DEFAULT 15)
 LANGUAGE plpgsql
AS $procedure$

DECLARE

    r RECORD;

BEGIN

    -- Identify machines with no updates in silver.machine_status for > threshold

    FOR r IN 

        SELECT 

            m.machine_id, 

            MAX(s.time) as last_seen

        FROM master.machine_info m

        LEFT JOIN silver.machine_status s ON m.machine_id = s.machine_id

        GROUP BY m.machine_id

        HAVING MAX(s.time) < NOW() - (p_threshold_minutes || ' minutes')::INTERVAL

           OR MAX(s.time) IS NULL

    LOOP

        -- Insert into Alert History (De-duplication logic would go here in prod)

        INSERT INTO alerting.history (rule_id, machine_id, message, value_at_alert, status)

        VALUES (

            NULL, -- System Rule (Manual ID or looked up)

            r.machine_id, 

            'Device Offline / Heartbeat Missed', 

            COALESCE(r.last_seen::TEXT, 'Never'), 

            'New'

        );

        

        -- Also update Active Alerts table to track ongoing offline state

    END LOOP;

END;

$procedure$
;
