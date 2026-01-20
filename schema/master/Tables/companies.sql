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
-- Name: companies; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.companies (
    company_id text NOT NULL,
    company_name text NOT NULL,
    effective_from_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (company_id);


--
-- PostgreSQL database dump complete
--


