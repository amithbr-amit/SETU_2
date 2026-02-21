--
-- Name: machine_shift_partial_oee; Type: TABLE; Schema: gold; Owner: -
--

CREATE TABLE gold.machine_shift_partial_oee (
    company_id text, -- From master.companies.company_id
    plant_id integer, -- From master.plants.plant_id
    machine_id text, -- From master.machine_info.machine_id
    logical_date date NOT NULL,
    shift_id integer NOT NULL,
    shift_name text,
    shift_start timestamp with time zone,
    shift_end timestamp with time zone,
    total_shift_duration_sec numeric(18,2),
    total_down_sec numeric(18,2),
    total_utilised_sec numeric(18,2),
    total_load_unload_sec numeric(18,2),
    total_exceeded_load_unload_sec numeric(18,2),
    total_parts integer,
    total_theoretical_time_sec numeric(18,2),
    total_rejects integer,
    availability_effy numeric(10,4),
    production_effy numeric(10,4),
    quality_effy numeric(10,4),
    overall_effective_effy numeric(10,4),
    last_updated_by text,
    last_updated_ts timestamp with time zone DEFAULT now()
);

-- Primary Key
ALTER TABLE ONLY gold.machine_shift_partial_oee
    ADD CONSTRAINT machine_shift_partial_oee_pkey PRIMARY KEY (company_id, plant_id, machine_id, logical_date, shift_id);

-- Indices
CREATE INDEX idx_gld_oee_date ON gold.machine_shift_partial_oee (logical_date);
CREATE INDEX idx_gld_oee_machine ON gold.machine_shift_partial_oee (machine_id);
