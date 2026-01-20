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
-- Name: v_production_dashboard; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.v_production_dashboard AS
 SELECT p.bucket_time,
    p.company_id,
    p.machine_id,
    m.device_id,
    m.plant_id,
    pl.plant_name,
    p.program_no,
    p.total_cycles,
    p.avg_std_cycle_time,
    p.avg_actual_cycle_time_sec,
    p.last_cycle_time
   FROM ((gold.hourly_production_stats p
     LEFT JOIN master.machine_info m ON (((p.machine_id = m.machine_id) AND (p.company_id = m.company_id))))
     LEFT JOIN master.plants pl ON (((m.plant_id = pl.plant_id) AND (m.company_id = pl.company_id))));


--
-- PostgreSQL database dump complete
--


