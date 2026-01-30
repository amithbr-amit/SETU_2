--
-- Name: stg_machine_focas; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_focas (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    part_count double precision,
    rej_count double precision,
    pot double precision,
    ot double precision,
    ct double precision
);

--
-- Name: stg_machine_focas stg_machine_focas_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_focas
    ADD CONSTRAINT stg_machine_focas_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_focas_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_focas_watermark ON bronze.stg_machine_focas USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_focas', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_focas', INTERVAL '30 days');
