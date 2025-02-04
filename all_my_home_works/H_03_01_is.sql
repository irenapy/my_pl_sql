CREATE OR REPLACE PROCEDURE DEL_JOBS (
    P_JOB_ID IN JOBS.JOB_ID%TYPE, 
    PO_RESULT OUT VARCHAR2        
) IS
    v_job_count NUMBER;               
BEGIN
    
    SELECT COUNT(*)
    INTO v_job_count
    FROM jobs
    WHERE job_id = P_JOB_ID;    
    IF v_job_count > 0 THEN        
        DELETE FROM jobs
        WHERE job_id = P_JOB_ID;   
        PO_RESULT := 'Посада ' || P_JOB_ID || ' успішно видалена';
    ELSE       
        PO_RESULT := 'Посада ' || P_JOB_ID || ' не існує';
    END IF;
END DEL_JOBS;
/


-----------------------------------------------------

DECLARE
    v_result VARCHAR2(100); 
BEGIN

    DEL_JOBS('IT_PROG', v_result);
    
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

