CREATE OR REPLACE FUNCTION master.get_shift_id(p_plant_id text, p_time timestamp with time zone)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
AS $function$

DECLARE

    v_shift_id TEXT;

    v_local_time TIME;

    v_duration NUMERIC;

BEGIN

    -- 1. Force conversion to IST to ensure 'time' extraction aligns with Shift definitions

    v_local_time := (p_time AT TIME ZONE 'Asia/Kolkata')::TIME;



    -- 2. Find matching shift with corrected cross-midnight logic

    SELECT shift_id INTO v_shift_id

    FROM master.shifts

    WHERE plant_id = p_plant_id

      AND (

          CASE 

              -- Calculate end_time and check if it wrapped past midnight

              WHEN (start_time + (COALESCE(duration_hrs, 8) || ' hours')::INTERVAL)::TIME >= start_time THEN

                  -- NORMAL SHIFT: end_time is same day (e.g., 06:00 - 14:00)

                  -- Match: start_time <= v_local_time < end_time

                  v_local_time >= start_time 

                  AND v_local_time < (start_time + (COALESCE(duration_hrs, 8) || ' hours')::INTERVAL)::TIME

              ELSE

                  -- CROSS-MIDNIGHT SHIFT: end_time wrapped to next day (e.g., 22:00 - 06:00)

                  -- Match: v_local_time >= start_time (same day) OR v_local_time < end_time (next day)

                  v_local_time >= start_time 

                  OR v_local_time < (start_time + (COALESCE(duration_hrs, 8) || ' hours')::INTERVAL)::TIME

          END

      )

    ORDER BY shift_id  -- Deterministic ordering matches legacy ORDER BY ShiftID

    LIMIT 1;



    -- 3. Never return NULL to prevent aggregate drift

    RETURN COALESCE(v_shift_id, 'UNKNOWN');

END;

$function$
;
