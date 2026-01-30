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
-- Name: downtime_codes; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.downtime_codes (
    down_id SERIAL NOT NULL,
    down_code varchar(50) NOT NULL,
    description text,
    category varchar(50),
    threshold_sec integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: downtime_codes downtime_codes_pkey; Type: CONSTRAINT; Schema: master; Owner: -
--

ALTER TABLE ONLY master.downtime_codes
    ADD CONSTRAINT downtime_codes_pkey PRIMARY KEY (down_id);





--
-- PostgreSQL database dump complete
--


