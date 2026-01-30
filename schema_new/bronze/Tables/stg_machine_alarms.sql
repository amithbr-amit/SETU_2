--
-- Name: stg_machine_alarms; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_alarms (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    alarm_no text,
    alarm_desc text
);

--
-- Name: stg_machine_alarms stg_machine_alarms_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_alarms
    ADD CONSTRAINT stg_machine_alarms_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_alarms_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_alarms_watermark ON bronze.stg_machine_alarms USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_alarms', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_alarms', INTERVAL '30 days');
