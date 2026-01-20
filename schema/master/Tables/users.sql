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
-- Name: users; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.users (
    user_id text NOT NULL,
    user_no text,
    full_name text,
    role text,
    plant_id text,
    created_at timestamp with time zone DEFAULT now(),
    company_id text NOT NULL
);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id, company_id);


--
-- Name: users fk_user_plant; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.users
    ADD CONSTRAINT fk_user_plant FOREIGN KEY (plant_id, company_id) REFERENCES master.plants(plant_id, company_id);


--
-- Name: users users_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.users
    ADD CONSTRAINT users_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


