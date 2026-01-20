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
-- Name: machine_focas; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_focas (
    "time" timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_id text NOT NULL,
    shift_id text,
    part_count double precision,
    rej_count double precision,
    pot double precision,
    ot double precision,
    ct double precision,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_focas_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_focas_time_idx ON silver.machine_focas USING btree ("time" DESC);


--
-- Name: machine_focas fk_mf_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_focas
    ADD CONSTRAINT fk_mf_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


