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
-- Name: alert_rules; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.alert_rules (
    rule_id integer NOT NULL,
    rule_name text NOT NULL,
    description text,
    metric text NOT NULL,
    condition_operator text NOT NULL,
    threshold_value text NOT NULL,
    duration_sec integer DEFAULT 0,
    severity text,
    enabled boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    value_type text DEFAULT 'String'::text,
    company_id text,
    CONSTRAINT alert_rules_severity_check CHECK ((severity = ANY (ARRAY['Info'::text, 'Warning'::text, 'Critical'::text]))),
    CONSTRAINT alert_rules_value_type_check CHECK ((value_type = ANY (ARRAY['Numeric'::text, 'String'::text, 'Boolean'::text]))),
    CONSTRAINT check_numeric_format CHECK (((value_type <> 'Numeric'::text) OR (threshold_value ~ '^[0-9]+(\.[0-9]+)?$'::text)))
);


--
-- Name: alert_rules_rule_id_seq; Type: SEQUENCE; Schema: config; Owner: -
--

CREATE SEQUENCE config.alert_rules_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rules_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: config; Owner: -
--

ALTER SEQUENCE config.alert_rules_rule_id_seq OWNED BY config.alert_rules.rule_id;


--
-- Name: alert_rules rule_id; Type: DEFAULT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_rules ALTER COLUMN rule_id SET DEFAULT nextval('config.alert_rules_rule_id_seq'::regclass);


--
-- Name: alert_rules alert_rules_pkey; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_rules
    ADD CONSTRAINT alert_rules_pkey PRIMARY KEY (rule_id);


--
-- Name: alert_rules alert_rules_company_id_fkey; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_rules
    ADD CONSTRAINT alert_rules_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- PostgreSQL database dump complete
--


