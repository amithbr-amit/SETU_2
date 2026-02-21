/*
    OBJECT: fn_upsert_calendar
    AUTHOR: Amith B R
    PURPOSE: Populates or updates the master.calendar table for a given year. 
             All timestamps are stored in UTC.
    USAGE: SELECT utility.fn_upsert_calendar(2026);
*/

CREATE OR REPLACE FUNCTION utility.fn_upsert_calendar(p_year integer)
RETURNS void
LANGUAGE plpgsql
SET timezone = 'UTC'
AS $$
BEGIN
    INSERT INTO master.calendar (
        date_key,
        full_date,
        year,
        iso_year,
        month,
        iso_week,
        week_start_date,
        week_end_date,
        day_of_week,
        is_weekend
    )
    SELECT 
        to_char(d, 'YYYYMMDD')::integer AS date_key,
        d AS full_date,
        extract(year from d)::integer AS year,
        extract(isoyear from d)::integer AS iso_year,
        extract(month from d)::integer AS month,
        extract(week from d)::integer AS iso_week,
        date_trunc('week', d) AS week_start_date,
        (date_trunc('week', d) + interval '6 days') AS week_end_date,
        extract(isodow from d)::integer AS day_of_week,
        extract(isodow from d) IN (6, 7) AS is_weekend
    FROM generate_series(
        (p_year || '-01-01 00:00:00+00')::timestamptz,
        (p_year || '-12-31 00:00:00+00')::timestamptz,
        interval '1 day'
    ) d
    ON CONFLICT (date_key) DO UPDATE SET
        full_date = EXCLUDED.full_date,
        year = EXCLUDED.year,
        iso_year = EXCLUDED.iso_year,
        month = EXCLUDED.month,
        iso_week = EXCLUDED.iso_week,
        week_start_date = EXCLUDED.week_start_date,
        week_end_date = EXCLUDED.week_end_date,
        day_of_week = EXCLUDED.day_of_week,
        is_weekend = EXCLUDED.is_weekend;
END;
$$;
