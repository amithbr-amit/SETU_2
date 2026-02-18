--
-- Name: machine_timeline; Type: TABLE; Schema: silver; Owner: -
--

CREATE TABLE silver.machine_timeline (
    logical_date date NOT NULL,
    company_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    source_cycle_start timestamp with time zone NOT NULL, -- The immutable anchor from silver.machine_cycles
    shift_id integer NOT NULL,
    state_name text NOT NULL, -- 'running', 'load_unload', 'exceed_load_unload', 'downtime'
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    duration_seconds integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

-- Indices
-- Updated to include company_iot_id as requested
CREATE INDEX machine_timeline_machine_date_idx ON silver.machine_timeline (company_iot_id, machine_iot_id, logical_date);

-- Unique constraint for upserts (including logical_date as requested)
ALTER TABLE silver.machine_timeline
    ADD CONSTRAINT machine_timeline_unique UNIQUE (company_iot_id, machine_iot_id, logical_date, source_cycle_start, state_name, shift_id);

-- Foreign Keys
ALTER TABLE ONLY silver.machine_timeline
    ADD CONSTRAINT fk_mt_company FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

ALTER TABLE ONLY silver.machine_timeline
    ADD CONSTRAINT fk_mt_machine FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

-- Hypertable & Compression Configuration
SELECT create_hypertable(relation => 'silver.machine_timeline'::regclass, time_column_name => 'start_time'::name, chunk_time_interval => INTERVAL '7 days', if_not_exists => TRUE);

ALTER TABLE silver.machine_timeline SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'company_iot_id, machine_iot_id',
    timescaledb.compress_orderby = 'start_time ASC'
);

SELECT add_compression_policy(relation => 'silver.machine_timeline'::regclass, compress_after => INTERVAL '30 days');
