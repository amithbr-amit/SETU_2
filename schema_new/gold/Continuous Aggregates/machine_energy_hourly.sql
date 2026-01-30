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
-- Name: machine_energy_hourly; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.machine_energy_hourly AS
 SELECT bucket,
    company_id,
    machine_id,
    shift_id,
    category,
    total_energy_consumption,
    last_updated
   FROM _timescaledb_internal._materialized_hypertable_32;


--
-- PostgreSQL database dump complete
--


