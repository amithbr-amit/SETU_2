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
-- Name: production_targets; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.production_targets (
    target_id integer NOT NULL,
    machine_id text NOT NULL,
    company_id text NOT NULL,
    program_no text,
    shift_id text,
    target_parts_per_hour double precision,
    std_cycle_time_sec double precision,
    effective_start_date date,
    effective_end_date date,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: production_targets_target_id_seq; Type: SEQUENCE; Schema: master; Owner: -
--

CREATE SEQUENCE master.production_targets_target_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: production_targets_target_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: -
--

ALTER SEQUENCE master.production_targets_target_id_seq OWNED BY master.production_targets.target_id;


--
-- Name: production_targets target_id; Type: DEFAULT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.production_targets ALTER COLUMN target_id SET DEFAULT nextval('master.production_targets_target_id_seq'::regclass);


--
-- Name: production_targets production_targets_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.production_targets
    ADD CONSTRAINT production_targets_pkey PRIMARY KEY (target_id);


--
-- Name: idx_prod_targets_machine; Type: INDEX; Schema: master; Owner: -
--

CREATE INDEX idx_prod_targets_machine ON master.production_targets USING btree (machine_id, company_id);


--
-- Name: production_targets production_targets_machine_id_company_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.production_targets
    ADD CONSTRAINT production_targets_machine_id_company_id_fkey FOREIGN KEY (machine_id, company_id) REFERENCES master.machine_info(machine_id, company_id);


--
-- PostgreSQL database dump complete
--


