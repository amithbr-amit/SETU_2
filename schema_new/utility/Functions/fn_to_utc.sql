/*
    OBJECT: fn_to_utc
    AUTHOR: Amith B R
    PURPOSE: Converts a string literal or timestamp to a timestamptz in UTC.
             Treats input as UTC regardless of session timezone.
    USAGE: SELECT utility.fn_to_utc('2026-01-01 00:00:00');
*/

CREATE OR REPLACE FUNCTION utility.fn_to_utc(p_date date)
RETURNS timestamp with time zone
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT (p_date::timestamp AT TIME ZONE 'UTC');
$$;
