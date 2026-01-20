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
-- Name: machine_assets; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.machine_assets (
    asset_id text NOT NULL,
    machine_id text NOT NULL,
    company_id text NOT NULL,
    supplier_name text,
    model_number text,
    manufacturing_year integer,
    commissioned_date date,
    warranty_expire_date date,
    license_type text DEFAULT 'Standard'::text,
    is_activated boolean DEFAULT false,
    customer_address text,
    support_contact text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_assets machine_assets_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_pkey PRIMARY KEY (asset_id);


--
-- Name: machine_assets machine_assets_machine_id_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_machine_id_company_id_fkey FOREIGN KEY (machine_id, company_id) REFERENCES master.machine_info(machine_id, company_id);


--
-- PostgreSQL database dump complete
--


