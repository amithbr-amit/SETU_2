--
-- Name: plants; Type: TABLE; Schema: master; Owner: -
--

CREATE TABLE master.plants (
    iot_id SERIAL NOT NULL,
    company_iot_id integer NOT NULL,
    plant_id text NOT NULL, -- Business unique ID
    plant_code text,
    description text,
    is_primary boolean DEFAULT false,
    effective_from_date timestamp with time zone DEFAULT now(),
    effective_to_date timestamp with time zone DEFAULT '9999-12-31 23:59:59+00',
    updated_by text,
    updated_ts timestamp with time zone DEFAULT now()
);

-- Primary Key
ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (iot_id);

-- Foreign Key
ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_company_iot_id_fkey FOREIGN KEY (company_iot_id) REFERENCES master.companies(iot_id);

-- Unique constraint for business logic
ALTER TABLE ONLY master.plants
    ADD CONSTRAINT plants_company_plant_unique UNIQUE (company_iot_id, plant_id);

-- Indices for performance
CREATE INDEX plants_lookup_idx ON master.plants (company_iot_id, plant_id) WHERE (effective_to_date = '9999-12-31 23:59:59+00');
