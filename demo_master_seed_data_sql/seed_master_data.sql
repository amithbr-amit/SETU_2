DO $$
DECLARE
    v_company_iot_id INTEGER;
    v_plant_iot_id INTEGER;
    v_machine1_iot_id INTEGER;
    v_machine2_iot_id INTEGER;
BEGIN
    -- 1. Insert Company
    -- Using INSERT ... RETURNING to get the generated iot_id
    INSERT INTO master.companies (company_id, company_name, address, state, country, pin_code, email_id, phone_no, effective_from_date)
    VALUES ('DEMO_CORP', 'Demo Manufacturing Corporation', '123 Industrial Estate', 'Karnataka', 'India', '560001', 'info@democorp.com', '+91-9876543210', now())
    ON CONFLICT (company_id) DO UPDATE SET company_name = EXCLUDED.company_name
    RETURNING iot_id INTO v_company_iot_id;

    -- 2. Insert Plant
    INSERT INTO master.plants (company_iot_id, plant_id, plant_code, description, is_primary)
    VALUES (v_company_iot_id, 'BLR-01', 'BLR01', 'Main Bangalore Plant', true)
    ON CONFLICT (company_iot_id, plant_id) DO UPDATE SET plant_code = EXCLUDED.plant_code
    RETURNING iot_id INTO v_plant_iot_id;

    -- 3. Insert Devices
    INSERT INTO master.device_info (device_id, description, is_assigned, created_by)
    VALUES ('DEV001', 'IoT Edge Gateway 001', true, 'seed_script')
    ON CONFLICT (device_id) DO NOTHING;

    INSERT INTO master.device_info (device_id, description, is_assigned, created_by)
    VALUES ('DEV002', 'IoT Edge Gateway 002', true, 'seed_script')
    ON CONFLICT (device_id) DO NOTHING;

    -- 4. Insert Machines
    INSERT INTO master.machine_info (machine_id, company_iot_id, device_id, ip_address, port_no)
    VALUES ('MAC001', v_company_iot_id, 'DEV001', '192.168.1.10', 502)
    ON CONFLICT (machine_id, company_iot_id) DO UPDATE SET device_id = EXCLUDED.device_id
    RETURNING iot_id INTO v_machine1_iot_id;

    INSERT INTO master.machine_info (machine_id, company_iot_id, device_id, ip_address, port_no)
    VALUES ('MAC002', v_company_iot_id, 'DEV002', '192.168.1.11', 502)
    ON CONFLICT (machine_id, company_iot_id) DO UPDATE SET device_id = EXCLUDED.device_id
    RETURNING iot_id INTO v_machine2_iot_id;

    -- 5. Insert Shift Definitions (3 Shifts)
    -- Shift 1: 06:00 to 14:00
    INSERT INTO master.shift_definitions (company_iot_id, shift_name, shift_id, from_day, to_day, start_time, end_time, timezone)
    VALUES (v_company_iot_id, 'Shift 1', 1, 0, 0, '06:00:00', '14:00:00', 'Asia/Kolkata')
    ON CONFLICT (company_iot_id, shift_id) DO UPDATE SET shift_name = EXCLUDED.shift_name;

    -- Shift 2: 14:00 to 22:00
    INSERT INTO master.shift_definitions (company_iot_id, shift_name, shift_id, from_day, to_day, start_time, end_time, timezone)
    VALUES (v_company_iot_id, 'Shift 2', 2, 0, 0, '14:00:00', '22:00:00', 'Asia/Kolkata')
    ON CONFLICT (company_iot_id, shift_id) DO UPDATE SET shift_name = EXCLUDED.shift_name;

    -- Shift 3: 22:00 to 06:00 (Crosses midnight, to_day = 1 if logical date is start)
    -- Note: Depending on how the system handles it, Shift 3 might end at 06:00 on the next day.
    INSERT INTO master.shift_definitions (company_iot_id, shift_name, shift_id, from_day, to_day, start_time, end_time, timezone)
    VALUES (v_company_iot_id, 'Shift 3', 3, 0, 1, '22:00:00', '06:00:00', 'Asia/Kolkata')
    ON CONFLICT (company_iot_id, shift_id) DO UPDATE SET shift_name = EXCLUDED.shift_name;

    -- 6. Insert Plant-Machine Mappings
    INSERT INTO master.plant_machine_mapping (company_iot_id, plant_iot_id, machine_iot_id)
    VALUES (v_company_iot_id, v_plant_iot_id, v_machine1_iot_id)
    ON CONFLICT (plant_iot_id, machine_iot_id) DO NOTHING;

    INSERT INTO master.plant_machine_mapping (company_iot_id, plant_iot_id, machine_iot_id)
    VALUES (v_company_iot_id, v_plant_iot_id, v_machine2_iot_id)
    ON CONFLICT (plant_iot_id, machine_iot_id) DO NOTHING;

    RAISE NOTICE 'Seed data for Company %, Plant % inserted successfully.', 'DEMO_CORP', 'BLR-01';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred during seed data insertion: %', SQLERRM;
        RAISE;
END $$;
COMMIT;
