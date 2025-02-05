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
        p_department_id  IN NUMBER
    ) IS
        v_count_id_job NUMBER;
        v_count_id_dep NUMBER;
        v_min_salary NUMBER;
        v_max_salary NUMBER;
        v_new_employee_id NUMBER;
    BEGIN
        
        log_util.log_start('add_employee');
    
        IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
        END IF;

        IF TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ви можете додавати нового співробітника лише в робочий час');
        END IF;

        SELECT COUNT(*) INTO v_count_id_job FROM jobs WHERE job_id = p_job_id;
        IF v_count_id_job = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий код посади');
        END IF;

      
        
        SELECT COUNT(*) INTO v_count_id_dep FROM departments WHERE department_id = p_department_id;
        IF v_count_id_dep = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неіснуючий ідентифікатор відділу');
        END IF;

        
       
        SELECT min_salary, max_salary INTO v_min_salary, v_max_salary FROM jobs WHERE job_id = p_job_id;
        IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
            RAISE_APPLICATION_ERROR(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');
        END IF;

        
        SELECT NVL(MAX(employee_id), 0) + 1 INTO v_new_employee_id FROM employees;

        
        BEGIN
            INSERT INTO employees (
                employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id
            ) VALUES (
                v_new_employee_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id
            );

            
            COMMIT;

            
            DBMS_OUTPUT.PUT_LINE('Співробітник ' || p_first_name || ' ' || p_last_name || ' успішно доданий');
        EXCEPTION
            WHEN OTHERS THEN
               
                log_util.log_error('Помилка при додаванні співробітника', SQLERRM);
                RAISE;
        END;

     
        log_util.log_finish('add_employee');
    END add_employee;


