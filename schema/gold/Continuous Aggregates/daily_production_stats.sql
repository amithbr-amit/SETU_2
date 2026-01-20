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
-- Name: daily_production_stats; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.daily_production_stats AS
 SELECT day,
    company_id,
    machine_id,
    total_cycles,
    avg_std_cycle_time,
    total_production_time_sec
   FROM _timescaledb_internal._materialized_hypertable_28;


--
-- PostgreSQL database dump complete
--


