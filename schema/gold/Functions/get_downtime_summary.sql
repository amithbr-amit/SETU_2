CREATE OR REPLACE FUNCTION gold.get_downtime_summary(_machine_id text, _company_id text, _start_time timestamp with time zone, _end_time timestamp with time zone)
 RETURNS TABLE(bucket timestamp with time zone, downtime_seconds double precision, part_count double precision, operating_time double precision)
 LANGUAGE plpgsql
 STABLE
AS $function$

BEGIN

    RETURN QUERY

    SELECT

        mdh.bucket,

        mdh.total_downtime_seconds,

        mdh.total_part_count,

        mdh.total_operating_time

    FROM gold.machine_downtime_hourly mdh

    WHERE mdh.machine_id = _machine_id

      AND mdh.company_id = _company_id

      AND mdh.bucket >= _start_time

      AND mdh.bucket < _end_time

    ORDER BY mdh.bucket ASC;

END;

$function$
;
