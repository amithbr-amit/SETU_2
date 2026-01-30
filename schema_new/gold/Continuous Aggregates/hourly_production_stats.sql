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
-- Name: hourly_production_stats; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.hourly_production_stats AS
 SELECT bucket_time,
    company_id,
    machine_id,
    program_no,
    total_cycles,
    avg_std_cycle_time,
    avg_actual_cycle_time_sec,
    last_cycle_time
   FROM _timescaledb_internal._materialized_hypertable_19;


--
-- PostgreSQL database dump complete
--


