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
-- Name: machine_cycle_stats_hourly; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.machine_cycle_stats_hourly AS
 SELECT bucket,
    company_id,
    machine_id,
    shift_id,
    total_cycles,
    avg_cycle_time,
    avg_load_unload,
    effective_load_unload_total,
    total_load_unload_exceeded,
    last_updated
   FROM _timescaledb_internal._materialized_hypertable_34;


--
-- PostgreSQL database dump complete
--


