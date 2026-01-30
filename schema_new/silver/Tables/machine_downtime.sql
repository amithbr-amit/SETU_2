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
-- Name: machine_downtime; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_downtime (
    down_start timestamp with time zone NOT NULL,
    down_end timestamp with time zone,
    company_id text NOT NULL,
    machine_id text NOT NULL,
    down_code text,
    down_id integer,
    down_threshold integer,
    created_at timestamp with time zone DEFAULT now(),
    shift_id text
);


--
-- Name: machine_downtime_down_start_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX machine_downtime_down_start_idx ON silver.machine_downtime USING btree (down_start DESC);


--
-- Name: machine_downtime fk_md_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.machine_downtime
    ADD CONSTRAINT fk_md_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


