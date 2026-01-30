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
-- Name: v_downtime_dashboard; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.v_downtime_dashboard AS
 SELECT d.bucket_time,
    d.company_id,
    d.machine_id,
    m.plant_id,
    pl.plant_name,
    d.down_code,
    dc.description AS down_description,
    d.downtime_count,
    d.total_downtime_sec
   FROM (((gold.hourly_downtime_stats d
     LEFT JOIN master.machine_info m ON (((d.machine_id = m.machine_id) AND (d.company_id = m.company_id))))
     LEFT JOIN master.plants pl ON (((m.plant_id = pl.plant_id) AND (m.company_id = pl.company_id))))
     LEFT JOIN master.downtime_codes dc ON (((d.down_code = dc.down_code) AND (d.company_id = dc.company_id))));


--
-- PostgreSQL database dump complete
--


