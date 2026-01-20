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
-- Name: machine_alarms; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_alarms (
    "time" timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_id text NOT NULL,
    alarm_no text,
    alarm_desc text,
    created_at timestamp with time zone DEFAULT now(),
    shift_id text
);


--
-- Name: machine_alarms_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_alarms_time_idx ON silver.machine_alarms USING btree ("time" DESC);


--
-- Name: machine_alarms fk_ma_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_alarms
    ADD CONSTRAINT fk_ma_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


