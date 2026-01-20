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
-- Name: customer_feedback; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.customer_feedback (
    "time" timestamp with time zone NOT NULL,
    company_id text NOT NULL,
    machine_id text NOT NULL,
    user_id text,
    batch_no text,
    question_id text,
    question_category text,
    rating_value integer,
    comments text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: customer_feedback_time_idx; Type: INDEX; Schema: silver; Owner: -
--

CREATE INDEX customer_feedback_time_idx ON silver.customer_feedback USING btree ("time" DESC);


--
-- Name: customer_feedback fk_cf_company; Type: FK CONSTRAINT; Schema: silver; Owner: -
--

ALTER TABLE ONLY silver.customer_feedback
    ADD CONSTRAINT fk_cf_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


