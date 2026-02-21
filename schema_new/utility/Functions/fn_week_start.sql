/*
    OBJECT: fn_week_start
    AUTHOR: Amith B R
    PURPOSE: Returns the ISO week start date (Monday) for a given date.
             Result is returned in UTC.
    USAGE: SELECT utility.fn_week_start(now()::date);
*/

CREATE OR REPLACE FUNCTION utility.fn_week_start(p_date date)
RETURNS timestamp with time zone
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT (date_trunc('week', p_date)::timestamp AT TIME ZONE 'UTC');
$$;
