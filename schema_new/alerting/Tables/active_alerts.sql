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
-- Name: active_alerts; Type: TABLE; Schema: alerting; Owner: -
--

CREATE TABLE alerting.active_alerts (
    company_id text NOT NULL,
    machine_id text NOT NULL,
    rule_id integer NOT NULL,
    start_time timestamp with time zone NOT NULL,
    last_checked_at timestamp with time zone NOT NULL
);


--
-- Name: active_alerts active_alerts_pkey; Type: CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.active_alerts
    ADD CONSTRAINT active_alerts_pkey PRIMARY KEY (company_id, machine_id, rule_id);


--
-- Name: active_alerts active_alerts_rule_id_fkey; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.active_alerts
    ADD CONSTRAINT active_alerts_rule_id_fkey FOREIGN KEY (rule_id) REFERENCES config.alert_rules(rule_id);


--
-- Name: active_alerts fk_aa_company; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.active_alerts
    ADD CONSTRAINT fk_aa_company FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- Name: active_alerts fk_active_machine; Type: FK CONSTRAINT; Schema: alerting; Owner: -
--

ALTER TABLE ONLY alerting.active_alerts
    ADD CONSTRAINT fk_active_machine FOREIGN KEY (machine_id, company_id) REFERENCES master.machine_info(machine_id, company_id);


--
-- PostgreSQL database dump complete
--


