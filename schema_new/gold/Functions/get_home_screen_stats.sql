CREATE OR REPLACE FUNCTION gold.get_home_screen_stats(_company_id text)
 RETURNS TABLE(total_machines bigint, running_machines bigint, stopped_machines bigint, idle_machines bigint)
 LANGUAGE plpgsql
 STABLE
AS $function$

DECLARE

    _latest_time TIMESTAMPTZ;

BEGIN

    -- Get the approximate latest time to filter 'live' data (e.g., last 10 minutes)

    -- In a real scenario, we might query the 'current_status' table if it exists.

    -- Here we query the latest status report per machine.

    

    RETURN QUERY

    WITH latest_status AS (

        SELECT DISTINCT ON (machine_id)

            machine_id,

            status,

            time

        FROM silver.machine_status

        WHERE company_id = _company_id

        ORDER BY machine_id, time DESC

    )

    SELECT

        COUNT(*) as total_machines,

        COUNT(*) FILTER (WHERE status = 'Running') as running_machines,

        COUNT(*) FILTER (WHERE status = 'Stopped') as stopped_machines,

        COUNT(*) FILTER (WHERE status = 'Idle') as idle_machines

    FROM latest_status;

END;

$function$
;
