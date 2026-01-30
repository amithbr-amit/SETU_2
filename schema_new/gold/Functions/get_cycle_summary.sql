CREATE OR REPLACE FUNCTION gold.get_cycle_summary(_machine_id text, _company_id text, _start_time timestamp with time zone, _end_time timestamp with time zone)
 RETURNS TABLE(bucket timestamp with time zone, total_cycles bigint, avg_cycle_time double precision, avg_load_unload double precision, total_load_unload_exceeded double precision)
 LANGUAGE plpgsql
 STABLE
AS $function$

BEGIN

    RETURN QUERY

    SELECT

        csh.bucket,

        csh.total_cycles,

        csh.avg_cycle_time,

        csh.avg_load_unload,

        csh.total_load_unload_exceeded

    FROM gold.machine_cycle_stats_hourly csh

    WHERE csh.machine_id = _machine_id

      AND csh.company_id = _company_id

      AND csh.bucket >= _start_time

      AND csh.bucket < _end_time

    ORDER BY csh.bucket ASC;

END;

$function$
;
