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
-- Name: plants; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.plants (
    plant_id text NOT NULL,
    company_id text NOT NULL,
    plant_name text,
    plant_city text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (plant_id, company_id);


--
-- Name: plants plants_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


