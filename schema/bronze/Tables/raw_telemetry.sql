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
-- Name: raw_telemetry; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.raw_telemetry (
    ingest_time timestamp with time zone DEFAULT now() NOT NULL,
    device_id text,
    iot_id text,
    payload jsonb,
    processed boolean DEFAULT false,
    company_id text,
    batch_id uuid,
    processing_status text DEFAULT 'pending'::text
);


--
-- Name: idx_raw_telemetry_batch; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_telemetry_batch ON bronze.raw_telemetry USING btree (batch_id) WHERE (batch_id IS NOT NULL);


--
-- Name: idx_raw_telemetry_pending; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_raw_telemetry_pending ON bronze.raw_telemetry USING btree (ingest_time) WHERE (processing_status = 'pending'::text);


--
-- Name: raw_telemetry_ingest_time_idx; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX raw_telemetry_ingest_time_idx ON bronze.raw_telemetry USING btree (ingest_time DESC);


--
-- Name: raw_telemetry raw_telemetry_company_id_fkey; Type: FK CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.raw_telemetry
    ADD CONSTRAINT raw_telemetry_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


