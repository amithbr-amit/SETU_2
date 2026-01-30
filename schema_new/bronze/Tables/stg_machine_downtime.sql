--
-- Name: stg_machine_downtime; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_downtime (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    down_start timestamp with time zone,
    down_end timestamp with time zone,
    down_code text,
    down_id integer,
    down_threshold integer
);

--
-- Name: stg_machine_downtime stg_machine_downtime_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_downtime
    ADD CONSTRAINT stg_machine_downtime_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_downtime_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_downtime_watermark ON bronze.stg_machine_downtime USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_downtime', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_downtime', INTERVAL '30 days');
