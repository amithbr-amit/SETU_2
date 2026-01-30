--
-- Name: stg_machine_cycles; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_cycles (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cycle_start timestamp with time zone,
    cycle_end timestamp with time zone,
    program_no text,
    std_load_unload integer,
    std_cycle_time integer,
    actual_load_unload integer,
    actual_cycle_time integer,
    down_threshold integer
);

--
-- Name: stg_machine_cycles stg_machine_cycles_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_cycles
    ADD CONSTRAINT stg_machine_cycles_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_cycles_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_cycles_watermark ON bronze.stg_machine_cycles USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_cycles', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_cycles', INTERVAL '30 days');
