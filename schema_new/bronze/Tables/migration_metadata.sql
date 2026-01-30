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
-- Name: migration_metadata; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.migration_metadata (
    id integer NOT NULL,
    table_name text NOT NULL,
    rows_migrated integer NOT NULL,
    min_timestamp timestamp with time zone,
    max_timestamp timestamp with time zone,
    company_ids text[],
    max_rows_limit integer,
    run_id uuid NOT NULL,
    migrated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE migration_metadata; Type: COMMENT; Schema: bronze; Owner: -
--

COMMENT ON TABLE bronze.migration_metadata IS 'Tracks what data was migrated per run for limit-aware validation';


--
-- Name: COLUMN migration_metadata.max_rows_limit; Type: COMMENT; Schema: bronze; Owner: -
--

COMMENT ON COLUMN bronze.migration_metadata.max_rows_limit IS 'If set, indicates a partial migration with --max-rows limit';


--
-- Name: COLUMN migration_metadata.run_id; Type: COMMENT; Schema: bronze; Owner: -
--

COMMENT ON COLUMN bronze.migration_metadata.run_id IS 'UUID grouping all tables migrated in a single run';


--
-- Name: migration_metadata_id_seq; Type: SEQUENCE; Schema: bronze; Owner: -
--

CREATE SEQUENCE bronze.migration_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migration_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: bronze; Owner: -
--

ALTER SEQUENCE bronze.migration_metadata_id_seq OWNED BY bronze.migration_metadata.id;


--
-- Name: migration_metadata id; Type: DEFAULT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.migration_metadata ALTER COLUMN id SET DEFAULT nextval('bronze.migration_metadata_id_seq'::regclass);


--
-- Name: migration_metadata migration_metadata_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.migration_metadata
    ADD CONSTRAINT migration_metadata_pkey PRIMARY KEY (id);


--
-- Name: idx_migration_metadata_latest; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_migration_metadata_latest ON bronze.migration_metadata USING btree (table_name, migrated_at DESC);


--
-- Name: idx_migration_metadata_run; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_migration_metadata_run ON bronze.migration_metadata USING btree (run_id);


--
-- Name: idx_migration_metadata_table; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_migration_metadata_table ON bronze.migration_metadata USING btree (table_name);


--
-- PostgreSQL database dump complete
--


