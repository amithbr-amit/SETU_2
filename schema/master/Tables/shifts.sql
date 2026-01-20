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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: shifts; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.shifts (
    shift_id text NOT NULL,
    company_id text NOT NULL,
    plant_id text NOT NULL,
    shift_name text,
    start_time time without time zone,
    duration_hrs numeric,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: shifts shifts_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (shift_id, company_id, plant_id);


--
-- Name: shifts shifts_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.shifts
    ADD CONSTRAINT shifts_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


