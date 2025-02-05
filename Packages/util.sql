-----специфікація

PROCEDURE add_employee (
        p_first_name     IN VARCHAR2,
        p_last_name      IN VARCHAR2,
        p_email          IN VARCHAR2,
        p_phone_number   IN VARCHAR2,
        p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE),
        p_job_id         IN VARCHAR2,
        p_salary         IN NUMBER,
        p_commission_pct IN NUMBER DEFAULT NULL,
        p_manager_id     IN NUMBER DEFAULT 100,
        p_department_id  IN NUMBER);
        
-------------------------------------------------------------------------------------------       
----body


PROCEDURE fire_an_employee (p_employee_id IN NUMBER) IS 
    v_employee_exists NUMBER;
    v_first_name VARCHAR2(100);
    v_last_name VARCHAR2(100);
    v_job_id VARCHAR2(50);
    v_department_id NUMBER;
    v_hire_date DATE;
BEGIN
    
    log_util.log_start('fire_an_employee');

 IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
        END IF;

        IF TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
        END IF;
       
       
     
    v_employee_exists := 0;
    SELECT COUNT(*) INTO v_employee_exists FROM employees WHERE employee_id = p_employee_id;
    
    IF v_employee_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Переданий співробітник не існує');
    END IF;

 
    BEGIN
        SELECT first_name, last_name, job_id, department_id, hire_date 
        INTO v_first_name, v_last_name, v_job_id, v_department_id, v_hire_date
        FROM employees
        WHERE employee_id = p_employee_id;
    END;

   
    BEGIN
        
        INSERT INTO employees_history (
            employee_id, first_name, last_name, job_id, department_id, hire_date, fire_date
        ) VALUES (
            p_employee_id, v_first_name, v_last_name, v_job_id, v_department_id, v_hire_date, SYSDATE
        );

        DELETE FROM employees WHERE employee_id = p_employee_id;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Співробітник ' || v_first_name || ' ' || v_last_name || ', ' || v_job_id || ', ' || v_department_id || ' успішно звільнений');
    EXCEPTION
        WHEN OTHERS THEN
            
            log_util.log_error('Помилка при видаленні співробітника', SQLERRM);
            RAISE;
    END;

    
    log_util.log_finish('fire_an_employee');
END fire_an_employee;
/

     
        log_util.log_finish('add_employee');
    END add_employee;
/
