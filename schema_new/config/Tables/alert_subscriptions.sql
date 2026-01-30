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
-- Name: alert_subscriptions; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config.alert_subscriptions (
    subscription_id integer NOT NULL,
    rule_id integer,
    user_id text,
    method text,
    target_address text,
    created_at timestamp with time zone DEFAULT now(),
    company_id text,
    CONSTRAINT alert_subscriptions_method_check CHECK ((method = ANY (ARRAY['Email'::text, 'SMS'::text, 'Push'::text])))
);


--
-- Name: alert_subscriptions_subscription_id_seq; Type: SEQUENCE; Schema: config; Owner: -
--

CREATE SEQUENCE config.alert_subscriptions_subscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_subscriptions_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: config; Owner: -
--

ALTER SEQUENCE config.alert_subscriptions_subscription_id_seq OWNED BY config.alert_subscriptions.subscription_id;


--
-- Name: alert_subscriptions subscription_id; Type: DEFAULT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_subscriptions ALTER COLUMN subscription_id SET DEFAULT nextval('config.alert_subscriptions_subscription_id_seq'::regclass);


--
-- Name: alert_subscriptions alert_subscriptions_pkey; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_subscriptions
    ADD CONSTRAINT alert_subscriptions_pkey PRIMARY KEY (subscription_id);


--
-- Name: alert_subscriptions alert_subscriptions_company_id_fkey; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_subscriptions
    ADD CONSTRAINT alert_subscriptions_company_id_fkey FOREIGN KEY (company_id) REFERENCES master.companies(company_id);


--
-- Name: alert_subscriptions alert_subscriptions_rule_id_fkey; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_subscriptions
    ADD CONSTRAINT alert_subscriptions_rule_id_fkey FOREIGN KEY (rule_id) REFERENCES config.alert_rules(rule_id);


--
-- Name: alert_subscriptions fk_alert_user; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config.alert_subscriptions
    ADD CONSTRAINT fk_alert_user FOREIGN KEY (user_id, company_id) REFERENCES master.users(user_id, company_id);


--
-- PostgreSQL database dump complete
--


