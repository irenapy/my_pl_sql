CREATE OR REPLACE PACKAGE UTIL IS
    FUNCTION get_dep_name(i_employee_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2;
    PROCEDURE del_jobs(p_job_id IN JOBS.JOB_ID%TYPE, po_result OUT VARCHAR2);
END UTIL;
/

-----------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY UTIL IS

   
    FUNCTION get_dep_name (
    i_employee_id IN NUMBER
) RETURN VARCHAR2 IS
    v_departmet_id departments.department_id%TYPE;
BEGIN

    SELECT dp.department_id
    INTO v_departmet_id
    FROM employees em
    JOIN departments dp
    ON em.department_id = dp.department_id
    WHERE em.employee_id = i_employee_id;

    RETURN  v_departmet_id; 

END get_dep_name;


   
    FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
  v_job_title jobs.job_title%TYPE;
 BEGIN
  SELECT j.job_title
  INTO v_job_title
  FROM employees em
  JOIN jobs j
  ON em.job_id = j.job_id
  WHERE em.employee_id = p_employee_id;
  RETURN v_job_title;
 END get_job_title;


    
    PROCEDURE del_jobs(p_job_id IN JOBS.JOB_ID%TYPE, po_result OUT VARCHAR2) IS
        v_job_count NUMBER;
    BEGIN
        
        SELECT COUNT(*)
        INTO v_job_count
        FROM jobs
        WHERE job_id = p_job_id;

        IF v_job_count > 0 THEN
            
            DELETE FROM jobs
            WHERE job_id = p_job_id;

            po_result := 'Посада ' || p_job_id || ' успішно видалена';
        ELSE
            
            po_result := 'Посада ' || p_job_id || ' не існує';
        END IF;
    END del_jobs;

END UTIL;
/



---------------------------------------------------
DROP FUNCTION get_job_title;
DROP FUNCTION get_dep_name;
DROP PROCEDURE del_jobs;

----------------------------------------------------------------------
SELECT 
    em.employee_id,
    em.first_name || ' ' || em.last_name AS full_name,
    UTIL.get_job_title(em.employee_id) AS job_title,
    UTIL.get_dep_name(em.employee_id) AS department_name
FROM employees em;
--------------------------------------------------


---------------------------------------------
DECLARE
    v_job_title VARCHAR2(100);
BEGIN
    v_job_title := UTIL.get_job_title(101); 
    DBMS_OUTPUT.PUT_LINE('Назва посади: ' || v_job_title);
END;
/


------------------------------------------

DECLARE
    v_department_name VARCHAR2(100);
BEGIN
   
    v_department_name := UTIL.get_dep_name(101);
    DBMS_OUTPUT.PUT_LINE('Назва департаменту: ' || v_department_name);
END;
/

-------------------------------------------------------
DECLARE
    v_result VARCHAR2(100);
BEGIN
    UTIL.del_jobs('IT_PROG', v_result);
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/


