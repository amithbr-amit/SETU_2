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
-- Name: machine_status; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_status (
    "time" timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_id text NOT NULL,
    program_no text,
    status text,
    operator_id text,
    target integer,
    created_at timestamp with time zone DEFAULT now(),
    shift_id text
);


--
-- Name: machine_status_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_status_time_idx ON silver.machine_status USING btree ("time" DESC);


--
-- Name: machine_status fk_ms_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_status
    ADD CONSTRAINT fk_ms_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


