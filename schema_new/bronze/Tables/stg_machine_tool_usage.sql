--
-- Name: stg_machine_tool_usage; Type: TABLE; Schema: bronze; Owner: -
--

CREATE TABLE bronze.stg_machine_tool_usage (
    id BIGINT GENERATED ALWAYS AS IDENTITY NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    kafka_offset bigint,
    device_iot_id integer NOT NULL,
    machine_iot_id integer NOT NULL,
    cnctimestamp timestamp with time zone,
    tool_no text NOT NULL,
    target_count double precision,
    actual_count double precision
);

--
-- Name: stg_machine_tool_usage stg_machine_tool_usage_pkey; Type: CONSTRAINT; Schema: bronze; Owner: -
--

ALTER TABLE ONLY bronze.stg_machine_tool_usage
    ADD CONSTRAINT stg_machine_tool_usage_pkey PRIMARY KEY (id, ingested_at);

--
-- Name: idx_stg_machine_tool_usage_watermark; Type: INDEX; Schema: bronze; Owner: -
--

CREATE INDEX idx_stg_machine_tool_usage_watermark ON bronze.stg_machine_tool_usage USING btree (id, ingested_at DESC);

--
-- Hypertable & Retention
--

SELECT create_hypertable('bronze.stg_machine_tool_usage', 'ingested_at', chunk_time_interval => INTERVAL '1 day');
SELECT add_retention_policy('bronze.stg_machine_tool_usage', INTERVAL '30 days');
