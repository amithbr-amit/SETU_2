/*
    OBJECT: fn_log_job_start
    AUTHOR: Amith B R
    PURPOSE: Initializes an execution entry in the job log for orchestration.
    TARGET TABLE: etl.control_job_log
    DEPENDENCIES: None
*/

CREATE OR REPLACE FUNCTION etl.fn_log_job_start(
    p_job_name TEXT, 
    p_type TEXT
) 
RETURNS INT 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
DECLARE 
    v_log_id INT;
BEGIN
    INSERT INTO etl.control_job_log (job_name, status, execution_type)
    VALUES (p_job_name, 'RUNNING', p_type)
    RETURNING log_id INTO v_log_id;
    
    RETURN v_log_id;
END;
$$;
