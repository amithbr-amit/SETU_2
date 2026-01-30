--
-- PostgreSQL database dump
--



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: v_oee_dashboard; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.v_oee_dashboard AS
 WITH daily_metrics AS (
         SELECT p.day,
            p.company_id,
            p.machine_id,
            p.total_cycles,
            p.total_production_time_sec,
            COALESCE(d.total_downtime_sec, (0)::numeric) AS total_downtime_sec,
            86400 AS planned_production_time_sec
           FROM (gold.daily_production_stats p
             LEFT JOIN gold.daily_downtime_stats d ON (((p.day = d.day) AND (p.machine_id = d.machine_id) AND (p.company_id = d.company_id))))
        )
 SELECT m.day,
    m.company_id,
    m.machine_id,
    mi.plant_id,
        CASE
            WHEN (m.planned_production_time_sec > 0) THEN (((m.planned_production_time_sec)::numeric - m.total_downtime_sec) / (m.planned_production_time_sec)::numeric)
            ELSE (0)::numeric
        END AS availability_score,
    0.85 AS performance_score_mock,
    0.98 AS quality_score_mock
   FROM (daily_metrics m
     JOIN master.machine_info mi ON (((m.machine_id = mi.machine_id) AND (m.company_id = mi.company_id))));


--
-- PostgreSQL database dump complete
--


