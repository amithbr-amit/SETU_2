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
-- Name: machine_health_settings; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.machine_health_settings (
    setting_id integer NOT NULL,
    machine_id text NOT NULL,
    company_id text NOT NULL,
    parameter_name text NOT NULL,
    min_value double precision,
    max_value double precision,
    target_value double precision,
    unit text,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: machine_health_settings_setting_id_seq; Type: SEQUENCE; Schema: master; Owner: -
--

CREATE SEQUENCE master.machine_health_settings_setting_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: machine_health_settings_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: -
--

ALTER SEQUENCE master.machine_health_settings_setting_id_seq OWNED BY master.machine_health_settings.setting_id;


--
-- Name: machine_health_settings setting_id; Type: DEFAULT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_health_settings ALTER COLUMN setting_id SET DEFAULT nextval('master.machine_health_settings_setting_id_seq'::regclass);


--
-- Name: machine_health_settings machine_health_settings_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_health_settings
    ADD CONSTRAINT machine_health_settings_pkey PRIMARY KEY (setting_id);


--
-- Name: machine_health_settings uq_machine_health_company; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_health_settings
    ADD CONSTRAINT uq_machine_health_company UNIQUE (machine_id, parameter_name, company_id);


--
-- Name: machine_health_settings machine_health_settings_machine_id_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.machine_health_settings
    ADD CONSTRAINT machine_health_settings_machine_id_company_id_fkey FOREIGN KEY (machine_id, company_id) REFERENCES master.machine_info(machine_id, company_id);


--
-- PostgreSQL database dump complete
--


