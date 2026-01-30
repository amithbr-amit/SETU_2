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
-- Name: history; Type: TABLE; Schema: alerting; Owner: -
--

CREATE TABLE alerting.history (
    alert_id bigint NOT NULL,
    "time" timestamp with time zone DEFAULT now() NOT NULL,
    company_id text NOT NULL,
    rule_id integer,
    machine_id text NOT NULL,
    message text,
    value_at_alert text,
    status text DEFAULT 'New'::text,
    resolved_at timestamp with time zone
);


--
-- Name: history_alert_id_seq; Type: SEQUENCE; Schema: alerting; Owner: -
--

CREATE SEQUENCE alerting.history_alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_alert_id_seq; Type: SEQUENCE OWNED BY; Schema: alerting; Owner: -
--

ALTER SEQUENCE alerting.history_alert_id_seq OWNED BY alerting.history.alert_id;


--
-- Name: history alert_id; Type: DEFAULT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.history ALTER COLUMN alert_id SET DEFAULT nextval('alerting.history_alert_id_seq'::regclass);


--
-- Name: history history_pkey; Type: CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.history
    ADD CONSTRAINT history_pkey PRIMARY KEY (alert_id, "time");


--
-- Name: history_time_idx; Type: INDEX; Schema: alerting; Owner: -
--

CREATE INDEX history_time_idx ON alerting.history USING btree ("time" DESC);


--
-- Name: history fk_ah_company; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.history
    ADD CONSTRAINT fk_ah_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- Name: history fk_history_machine; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.history
    ADD CONSTRAINT fk_history_machine FOREIGN KEY (machine_id, company_id) REFERENCES master.machine_info(machine_id, company_id);


--
-- Name: history history_rule_id_fkey; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.history
    ADD CONSTRAINT history_rule_id_fkey FOREIGN KEY (rule_id) REFERENCES config.alert_rules(rule_id);


--
-- PostgreSQL database dump complete
--


