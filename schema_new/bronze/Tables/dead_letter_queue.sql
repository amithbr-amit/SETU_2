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
-- Name: dead_letter_queue; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.dead_letter_queue (
    "time" timestamp with time zone DEFAULT now() NOT NULL,
    payload jsonb,
    error_reason text,
    company_id text
);


--
-- Name: dead_letter_queue_time_idx; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX dead_letter_queue_time_idx ON bronze.dead_letter_queue USING btree ("time" DESC);


--
-- Name: dead_letter_queue dead_letter_queue_company_id_fkey; Type: FK CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.dead_letter_queue
    ADD CONSTRAINT dead_letter_queue_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


