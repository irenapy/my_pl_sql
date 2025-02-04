----Процедура check_work_time
    PROCEDURE check_work_time IS
BEGIN
    
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN
        
        RAISE_APPLICATION_ERROR(-20205, 'Ви можете вносити змiни лише у робочi днi');
    END IF;
END check_work_time;



-----використання процедури check_work_time в util.add_new_jobs 

PROCEDURE add_new_jobs(p_job_id         IN VARCHAR2,
                        p_job_title     IN VARCHAR2,
                        p_min_salary    IN NUMBER,
                        p_max_salary    IN NUMBER DEFAULT NULL,
                        po_err          OUT VARCHAR2) IS
    v_max_salary irina_ii6.jobs.max_salarY%TYPE;
    salary_err   EXCEPTION;
 BEGIN
    check_work_time;
    
    IF p_max_salary IS NULL THEN
        v_max_salary := p_min_salary * gc_percent_of_min_salary;
    ELSE
        v_max_salary := p_max_salary;
    END IF;
    
    BEGIN
        IF (p_min_salary < gc_min_salary OR p_max_salary < gc_min_salary) THEN
            RAISE salary_err;
        ELSE
            INSERT INTO jobs(job_id, job_title, min_salary, max_salary) 
            VALUES (p_job_id, p_job_title, p_min_salary, v_max_salary);
            po_err := 'Посада '||p_job_id||' успшно додана';
            END IF;
        
    EXCEPTION
        WHEN salary_err THEN
            raise_application_error(-20001, 'Передана зарплата менша за 2000');
        WHEN dup_val_on_index THEN
            raise_application_error(-20002, 'Посада '||p_job_id||' вже снує');
        WHEN OTHERS THEN
            raise_application_error(-20003, 'Виникла помилка при додаванн нової посади. '|| SQLERRM);
    END;
    --COMMIT;
 END add_new_jobs;
----------------------------------------------------------
----виклик процедури add_new_jobs

DECLARE
  v_err VARCHAR(100);
BEGIN
    
    util.add_new_jobs(
        p_job_id      => 'IT_QA10',
        p_job_title   => 'QA_Engineer10',
        p_min_salary  => 10000,
        p_max_salary  => 20000,
        po_err        => v_err
    );

    DBMS_OUTPUT.PUT_LINE(v_err);
END;
/
