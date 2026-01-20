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
-- Name: hourly_downtime_stats; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.hourly_downtime_stats AS
 SELECT bucket_time,
    company_id,
    machine_id,
    down_code,
    downtime_count,
    total_downtime_sec
   FROM _timescaledb_internal._materialized_hypertable_20;


--
-- PostgreSQL database dump complete
--


