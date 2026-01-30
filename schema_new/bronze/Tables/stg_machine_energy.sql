--
-- Name: stg_machine_energy; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_energy (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    category text,
    servo_energy double precision,
    spindle_energy double precision,
    total_energy double precision
);

--
-- Name: stg_machine_energy stg_machine_energy_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_energy
    ADD CONSTRAINT stg_machine_energy_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_energy_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_energy_watermark ON bronze.stg_machine_energy USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_energy', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_energy', INTERVAL '30 days');
