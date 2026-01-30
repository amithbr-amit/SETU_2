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
-- Name: machine_info; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.machine_info (
    machine_id varchar(50) NOT NULL,
    company_id integer NOT NULL,
    device_iot_id integer NOT NULL,
    iot_id SERIAL NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_info machine_info_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_pkey PRIMARY KEY (iot_id);


--
-- Name: machine_info uq_machine_company; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT uq_machine_company UNIQUE (machine_id, company_id);


--
-- Name: machine_info machine_info_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- Name: machine_info machine_info_device_iot_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_info
    ADD CONSTRAINT machine_info_device_iot_id_fkey FOREIGN KEY (device_iot_id) REFERENCES master.device_info(device_iot_id);


--
-- PostgreSQL database dump complete
--


