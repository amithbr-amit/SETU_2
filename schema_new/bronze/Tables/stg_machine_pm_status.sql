--
-- Name: stg_machine_pm_status; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_pm_status (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    status text,
    pm_corrected_count integer,
    pm_pending_count integer
);

--
-- Name: stg_machine_pm_status stg_machine_pm_status_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_pm_status
    ADD CONSTRAINT stg_machine_pm_status_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_pm_status_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_pm_status_watermark ON bronze.stg_machine_pm_status USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_pm_status', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_pm_status', INTERVAL '30 days');
