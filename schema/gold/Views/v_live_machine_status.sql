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
-- Name: v_live_machine_status; Type: VIEW; Schema: gold; Owner: -
--

CREATE VIEW gold.v_live_machine_status AS
 SELECT DISTINCT ON (s.machine_id, s.company_id) s.machine_id,
    s.company_id,
    s."time" AS last_updated,
    s.status,
    s.program_no,
    s.operator_id,
    m.plant_id,
    m.device_id
   FROM (silver.machine_status s
     LEFT JOIN master.machine_info m ON (((s.machine_id = m.machine_id) AND (s.company_id = m.company_id))))
  ORDER BY s.machine_id, s.company_id, s."time" DESC;


--
-- PostgreSQL database dump complete
--


