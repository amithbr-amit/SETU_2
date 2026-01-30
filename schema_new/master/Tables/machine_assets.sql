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
    machine_iot_id integer NOT NULL,
    company_id integer NOT NULL,
    supplier_name varchar(50),
    model_number varchar(50),
    manufacturing_year integer,
    commissioned_date date,
    warranty_expire_date date,
    subscription_tier text DEFAULT 'Freemium'::text CHECK (subscription_tier IN ('Freemium', 'Plus', 'Pro')),
    is_mvp2_enabled boolean DEFAULT false,
    customer_address text,
    support_contact text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


--
-- Name: machine_assets machine_assets_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_pkey PRIMARY KEY (machine_iot_id, company_id);


--
-- Name: machine_assets machine_assets_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);

--
-- Name: machine_assets machine_assets_machine_iot_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -

ALTER TABLE ONLY master.machine_assets
    ADD CONSTRAINT machine_assets_machine_iot_id_fkey FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

--
-- PostgreSQL database dump complete
--


