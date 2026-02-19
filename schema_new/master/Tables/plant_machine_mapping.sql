--
-- Name: plant_machine_mapping; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.plant_machine_mapping (
    mapping_id SERIAL NOT NULL,
    company_iot_id integer NOT NULL, -- Refers to master.companies(iot_id)
    plant_iot_id integer NOT NULL, -- Refers to master.plants(iot_id)
    machine_iot_id integer NOT NULL, -- Refers to master.machine_info(iot_id)
    created_at timestamp with time zone DEFAULT now()
);

-- Primary Key
ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_pkey PRIMARY KEY (mapping_id);

-- Unique constraint to prevent duplicate mappings
ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT uq_plant_machine UNIQUE (plant_iot_id, machine_iot_id);

-- Foreign Keys
ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_plant_iot_id_fkey FOREIGN KEY (plant_iot_id) REFERENCES master.plants(iot_id);

ALTER TABLE ONLY master.plant_machine_mapping
    ADD CONSTRAINT plant_machine_mapping_machine_iot_id_fkey FOREIGN KEY (machine_iot_id) REFERENCES master.machine_info(iot_id);

-- Indices for performance
CREATE INDEX plant_machine_mapping_lookup_idx ON master.plant_machine_mapping (company_iot_id, plant_iot_id);
