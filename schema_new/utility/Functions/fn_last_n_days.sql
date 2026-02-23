/*
    OBJECT: fn_last_n_days
    AUTHOR: Amith B R
    PURPOSE: Returns the UTC midnight timestamp for N days prior to the given date.
    USAGE: SELECT utility.fn_last_n_days(now()::date, 30);
*/

CREATE OR REPLACE FUNCTION utility.fn_last_n_days(p_date date, p_days integer)
RETURNS timestamp with time zone
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT ((p_date - (p_days || ' days')::interval)::timestamp AT TIME ZONE 'UTC');
$$;
