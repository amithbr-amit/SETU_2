CREATE OR REPLACE PROCEDURE bronze.proc_process_bronze_batch(IN p_batch_size integer)
 LANGUAGE plpgsql
AS $procedure$

DECLARE

    v_batch_id UUID := gen_random_uuid();

    v_claimed_count INTEGER;

    r RECORD;

BEGIN

    -- =========================================================================

    -- PHASE 1: ATOMIC BATCH CLAIM

    -- =========================================================================

    UPDATE bronze.raw_telemetry

    SET 

        batch_id = v_batch_id,

        processing_status = 'claimed'

    WHERE ctid IN (

        SELECT ctid 

        FROM bronze.raw_telemetry

        WHERE processing_status = 'pending'

        ORDER BY ingest_time

        LIMIT p_batch_size

        FOR UPDATE SKIP LOCKED

    );

    

    GET DIAGNOSTICS v_claimed_count = ROW_COUNT;

    

    IF v_claimed_count = 0 THEN

        RETURN;  -- Nothing to process

    END IF;



    -- =========================================================================

    -- PHASE 2: PROCESS EACH ROW WITH ERROR HANDLING

    -- =========================================================================

    FOR r IN

        SELECT ctid, payload 

        FROM bronze.raw_telemetry

        WHERE batch_id = v_batch_id

    LOOP

        BEGIN

            -- Call ingestion (skip bronze insert since it exists)

            CALL bronze.proc_ingest_payload(r.payload, TRUE);

            

            -- Mark as processed ONLY if successful

            UPDATE bronze.raw_telemetry

            SET 

                processed = TRUE,

                processing_status = 'processed'

            WHERE ctid = r.ctid;

            

        EXCEPTION WHEN OTHERS THEN

            -- On error: move to DLQ, mark as failed

            INSERT INTO bronze.dead_letter_queue (payload, error_reason)

            VALUES (r.payload, SQLERRM);

            

            UPDATE bronze.raw_telemetry

            SET processing_status = 'failed'

            WHERE ctid = r.ctid;

        END;

    END LOOP;

    

END;

$procedure$
;
