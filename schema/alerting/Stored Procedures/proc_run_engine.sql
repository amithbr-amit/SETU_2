CREATE OR REPLACE PROCEDURE alerting.proc_run_engine()
 LANGUAGE plpgsql
AS $procedure$

BEGIN

    CALL alerting.proc_check_machine_downtime();

    CALL alerting.proc_check_device_heartbeat(15); -- Default 15 min heartbeat

    -- Add calls for other checks (Temperature, Spindle Load, etc.)

END;

$procedure$
;
