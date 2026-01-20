CREATE OR REPLACE PROCEDURE bronze.proc_ingest_payload(IN p_payload jsonb, IN p_skip_bronze boolean DEFAULT false)
 LANGUAGE plpgsql
 SET "TimeZone" TO 'Asia/Kolkata'
AS $procedure$

DECLARE

    v_device_id TEXT;

    v_iot_id TEXT;

    v_machine_id TEXT;

    v_company_id TEXT;

    v_plant_id TEXT;

    v_timestamp TIMESTAMPTZ := NOW();

    v_shift_id TEXT;

BEGIN

    -- 1. Optimized Lookup (Anti-N+1 Pattern)

    SELECT 

        m.machine_id, m.company_id, m.plant_id

    INTO 

        v_machine_id, v_company_id, v_plant_id

    FROM (

        SELECT 

            p_payload ->> 'DeviceID' as device_id,

            p_payload ->> 'IOTID' as iot_id

    ) i

    LEFT JOIN master.machine_info m 

        ON m.device_id = i.device_id 

        AND m.iot_id = i.iot_id;



    -- 2. DLQ Logic (Observability)

    IF v_machine_id IS NULL THEN

        INSERT INTO bronze.dead_letter_queue (payload, error_reason)

        VALUES (p_payload, 'Unknown Machine: DeviceID=' || COALESCE(p_payload ->> 'DeviceID', 'NULL') || ', IOTID=' || COALESCE(p_payload ->> 'IOTID', 'NULL'));

        RETURN;

    END IF;



    -- 3. Resolve Shift ID

    IF (p_payload ? 'MachineRunningStatus' AND jsonb_array_length(p_payload -> 'MachineRunningStatus') > 0) THEN

        v_timestamp := (p_payload -> 'MachineRunningStatus' -> 0 ->> 'UpdatedTS')::TIMESTAMPTZ;

    ELSIF (p_payload ? 'MachineWiseFocasDetails' AND jsonb_array_length(p_payload -> 'MachineWiseFocasDetails') > 0) THEN

         v_timestamp := COALESCE(

            (p_payload -> 'MachineWiseFocasDetails' -> 0 ->> 'UpdatedTS')::TIMESTAMPTZ,

            (p_payload -> 'MachineWiseFocasDetails' -> 0 ->> 'Date')::TIMESTAMPTZ

         );

    END IF;

    

    v_shift_id := master.get_shift_id(v_plant_id, v_timestamp);



    -- =========================================================================

    -- 4. Silver Enrichment - ALL Table Handlers

    -- =========================================================================



    -- Machine Running Status

    IF (p_payload ? 'MachineRunningStatus') THEN

        INSERT INTO silver.machine_status (time, company_id, machine_id, program_no, status, operator_id, target, shift_id)

        SELECT 

            (elem ->> 'UpdatedTS')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'RunningProgramNo',

            elem ->> 'Status',

            elem ->> 'OperatorID',

            (elem ->> 'Target')::INTEGER,

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineRunningStatus') AS elem;

    END IF;



    -- Machine Focas (CNC)

    IF (p_payload ? 'MachineWiseFocasDetails') THEN

        INSERT INTO silver.machine_focas (time, company_id, machine_id, shift_id, pot, ot, ct, part_count, rej_count)

        SELECT 

            COALESCE((elem ->> 'UpdatedTS')::TIMESTAMPTZ, (elem ->> 'Date')::TIMESTAMPTZ, NOW()),

            v_company_id,

            v_machine_id,

            COALESCE(elem ->> 'ShiftID', v_shift_id),

            (elem ->> 'POT')::DOUBLE PRECISION,

            (elem ->> 'OT')::DOUBLE PRECISION,

            (elem ->> 'CT')::DOUBLE PRECISION,

            (elem ->> 'PartCount')::DOUBLE PRECISION,

            (elem ->> 'RejCount')::DOUBLE PRECISION

        FROM jsonb_array_elements(p_payload -> 'MachineWiseFocasDetails') AS elem;

    END IF;



    -- Machine Cycles

    -- UPDATED: Added down_threshold for legacy Load/Unload formula parity (Fix #3)

    IF (p_payload ? 'MachineWiseCycleDetails') THEN

        INSERT INTO silver.machine_cycles (cycle_start, cycle_end, company_id, machine_id, program_no, std_load_unload, std_cycle_time, actual_load_unload, down_threshold, shift_id)

        SELECT 

            (elem ->> 'CycleStart')::TIMESTAMPTZ,

            (elem ->> 'CycleEnd')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'ProgramNo',

            (elem ->> 'StdLoadUnload')::INTEGER,

            (elem ->> 'StdCycleTime')::INTEGER,

            (elem ->> 'ActualLoadUnload')::INTEGER,

            COALESCE((elem ->> 'DownThreshold')::INTEGER, 0),  -- ADDED: For legacy formula

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWiseCycleDetails') AS elem;

    END IF;



    -- Machine Downtime

    IF (p_payload ? 'MachineWiseDownDetails') THEN

        INSERT INTO silver.machine_downtime (down_start, down_end, company_id, machine_id, down_code, down_id, down_threshold, shift_id)

        SELECT 

            (elem ->> 'DownStart')::TIMESTAMPTZ,

            (elem ->> 'DownEnd')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'DownCode', 

            (elem ->> 'DownID')::INTEGER,

            (elem ->> 'DownThreshold')::INTEGER,

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWiseDownDetails') AS elem;

    END IF;



    -- Machine Alarms

    IF (p_payload ? 'MachineWiseAlarmDetails') THEN

        INSERT INTO silver.machine_alarms (time, company_id, machine_id, alarm_no, alarm_desc, shift_id)

        SELECT 

            (elem ->> 'AlarmTS')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'AlarmNo',

            elem ->> 'AlarmDesc',

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWiseAlarmDetails') AS elem;

    END IF;



    -- Machine Energy

    IF (p_payload ? 'MachineWiseEnergyDetails') THEN

        INSERT INTO silver.machine_energy (time, company_id, machine_id, category, servo_energy, spindle_energy, total_energy, shift_id)

        SELECT 

            (elem ->> 'UpdatedTS')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'Category',

            (elem ->> 'ServoEnergy')::DOUBLE PRECISION,

            (elem ->> 'SpindleEnergy')::DOUBLE PRECISION,

            (elem ->> 'TotalEnergy')::DOUBLE PRECISION,

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWiseEnergyDetails') AS elem;

    END IF;



    -- =========================================================================

    -- NEW: Machine Tool Usage (was missing!)

    -- =========================================================================

    IF (p_payload ? 'MachineWiseToolDetails') THEN

        INSERT INTO silver.machine_tool_usage (time, company_id, machine_id, tool_no, target_count, actual_count, shift_id)

        SELECT 

            (elem ->> 'UpdatedTS')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            elem ->> 'ToolNo',

            (elem ->> 'Target')::INTEGER,

            (elem ->> 'Actual')::INTEGER,

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWiseToolDetails') AS elem;

    END IF;



    -- =========================================================================

    -- NEW: Machine PM Status (was missing!)

    -- =========================================================================

    IF (p_payload ? 'MachineWisePMDetails') THEN

        INSERT INTO silver.machine_pm_status (time, company_id, machine_id, pm_corrected_count, shift_id)

        SELECT 

            (elem ->> 'UpdatedTS')::TIMESTAMPTZ,

            v_company_id,

            v_machine_id,

            (elem ->> 'PMCorrectedCount')::INTEGER,

            v_shift_id

        FROM jsonb_array_elements(p_payload -> 'MachineWisePMDetails') AS elem;

    END IF;



    -- Log Raw (Processed) - Only if NOT skipping

    IF NOT p_skip_bronze THEN

        INSERT INTO bronze.raw_telemetry (device_id, iot_id, company_id, payload, processed, processing_status)

        VALUES (

            COALESCE(v_device_id, p_payload ->> 'DeviceID'), 

            COALESCE(v_iot_id, p_payload ->> 'IOTID'), 

            v_company_id, 

            p_payload, 

            TRUE,

            'processed'

        );

    END IF;



END;

$procedure$
;
