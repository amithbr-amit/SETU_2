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
-- Name: device_info; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.device_info (
    device_iot_id SERIAL NOT NULL,
    device_id varchar(50) NOT NULL,
    description text,
    is_assigned boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    created_by varchar(50),
    updated_at timestamp with time zone
);


--
-- Name: device_info device_info_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.device_info
    ADD CONSTRAINT device_info_pkey PRIMARY KEY (device_iot_id);


--
-- Name: device_info device_info_device_id_key; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.device_info
    ADD CONSTRAINT device_info_device_id_key UNIQUE (device_id);


--
-- PostgreSQL database dump complete
--
