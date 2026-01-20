CREATE OR REPLACE FUNCTION gold.get_energy_summary(_machine_id text, _company_id text, _start_time timestamp with time zone, _end_time timestamp with time zone)
 RETURNS TABLE(bucket timestamp with time zone, category text, total_energy double precision)
 LANGUAGE plpgsql
 STABLE
AS $function$

BEGIN

    RETURN QUERY

    SELECT

        meh.bucket,

        meh.category,

        meh.total_energy_consumption

    FROM gold.machine_energy_hourly meh

    WHERE meh.machine_id = _machine_id

      AND meh.company_id = _company_id

      AND meh.bucket >= _start_time

      AND meh.bucket < _end_time

    ORDER BY meh.bucket ASC;

END;

$function$
;
