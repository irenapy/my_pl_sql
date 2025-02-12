---------------------------------------------------------------SPECIFICATION-------------------------------------------------------------------------------
PROCEDURE api_nbu_sync;
------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE change_attribute_employee(
    p_employee_id      IN NUMBER, 
    p_first_name       IN VARCHAR2 DEFAULT NULL,
    p_last_name        IN VARCHAR2 DEFAULT NULL,
    p_email            IN VARCHAR2 DEFAULT NULL,
    p_phone_number     IN VARCHAR2 DEFAULT NULL,
    p_job_id           IN VARCHAR2 DEFAULT NULL,
    p_salary           IN NUMBER DEFAULT NULL,
    p_commission_pct   IN NUMBER DEFAULT NULL,
    p_manager_id       IN NUMBER DEFAULT NULL,
    p_department_id    IN NUMBER DEFAULT NULL
);
-------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE is_business_hours;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE fire_an_employee (p_employee_id IN NUMBER);   
-------------------------------------------------------------------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------BODY------------------------------------------------------------------------------------------
PROCEDURE api_nbu_sync IS
    v_list_currencies VARCHAR2(2000);
    v_currency VARCHAR2(10);
    v_rate NUMBER;
    v_id_number NUMBER;
BEGIN
   
    BEGIN
        SELECT value_text INTO v_list_currencies
        FROM sys_params
        WHERE param_name = 'list_currencies';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Помилка: Данних немає!');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Помилка отримання: ' || SQLERRM);
            RAISE;
    END;
    
    
    FOR r IN (SELECT column_value AS curr FROM TABLE(util.table_from_list(v_list_currencies))) LOOP
        BEGIN
           
            SELECT rate INTO v_rate FROM TABLE(util.get_currency(p_currency => r.curr));
            
            SELECT MAX(id_number) + 1 INTO v_id_number FROM cur_exchange;
            
            
            INSERT INTO cur_exchange (id_number, currency, exchange_rate, exchange_date)
            VALUES (v_id_number, r.curr, v_rate, SYSDATE);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Помилка оброблення ' || r.curr || ': ' || SQLERRM);
        END;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Успішно зваершено!');
END api_nbu_sync;
------------------------------------------------------------------------------------------------------------
PROCEDURE change_attribute_employee(
    p_employee_id      IN NUMBER, 
    p_first_name       IN VARCHAR2 DEFAULT NULL,
    p_last_name        IN VARCHAR2 DEFAULT NULL,
    p_email            IN VARCHAR2 DEFAULT NULL,
    p_phone_number     IN VARCHAR2 DEFAULT NULL,
    p_job_id           IN VARCHAR2 DEFAULT NULL,
    p_salary           IN NUMBER DEFAULT NULL,
    p_commission_pct   IN NUMBER DEFAULT NULL,
    p_manager_id       IN NUMBER DEFAULT NULL,
    p_department_id    IN NUMBER DEFAULT NULL
) IS
    v_employee_ex NUMBER;
BEGIN
    
    log_util.log_start('change_attribute_employee');

     SELECT COUNT(*) INTO v_employee_ex FROM employees WHERE employee_id = p_employee_id;
    
    IF v_employee_ex = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Переданий співробітник не існує');
    END IF;

  
    IF p_first_name IS NULL 
       AND p_last_name IS NULL 
       AND p_email IS NULL 
       AND p_phone_number IS NULL 
       AND p_job_id IS NULL 
       AND p_salary IS NULL 
       AND p_commission_pct IS NULL 
       AND p_manager_id IS NULL 
       AND p_department_id IS NULL THEN
        log_util.log_finish('change_attribute_employee');
        RAISE_APPLICATION_ERROR(-20001, 'Помилка: Значення NULL');
    END IF;
 
    BEGIN
  
        IF p_first_name IS NOT NULL THEN
            UPDATE employees SET first_name = p_first_name WHERE employee_id = p_employee_id;
        END IF;

        IF p_last_name IS NOT NULL THEN
            UPDATE employees SET last_name = p_last_name WHERE employee_id = p_employee_id;
        END IF;

        IF p_email IS NOT NULL THEN
            UPDATE employees SET email = p_email WHERE employee_id = p_employee_id;
        END IF;

        IF p_phone_number IS NOT NULL THEN
            UPDATE employees SET phone_number = p_phone_number WHERE employee_id = p_employee_id;
        END IF;

        IF p_job_id IS NOT NULL THEN
            UPDATE employees SET job_id = p_job_id WHERE employee_id = p_employee_id;
        END IF;

        IF p_salary IS NOT NULL THEN
            UPDATE employees SET salary = p_salary WHERE employee_id = p_employee_id;
        END IF;

        IF p_commission_pct IS NOT NULL THEN
            UPDATE employees SET commission_pct = p_commission_pct WHERE employee_id = p_employee_id;
        END IF;

        IF p_manager_id IS NOT NULL THEN
            UPDATE employees SET manager_id = p_manager_id WHERE employee_id = p_employee_id;
        END IF;

        IF p_department_id IS NOT NULL THEN
            UPDATE employees SET department_id = p_department_id WHERE employee_id = p_employee_id;
        END IF;

        COMMIT;
       
        DBMS_OUTPUT.PUT_LINE('Дані співробітника оновлені.');
    EXCEPTION
        WHEN OTHERS THEN
            log_util.log_error('change_attribute_employee', SQLERRM);
            RAISE;
    END;

    log_util.log_finish('change_attribute_employee');
END change_attribute_employee;
--------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE is_business_hours IS
BEGIN
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
END IF;
    IF TO_CHAR(SYSDATE, 'HH24:MI') < '08:00' OR TO_CHAR(SYSDATE, 'HH24:MI') >= '18:01' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ви можете видаляти співробітника лише в робочий час');
END IF;
END is_business_hours;
--------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE fire_an_employee (p_employee_id IN NUMBER) IS 
    v_employee_is       NUMBER;
    v_first_name        VARCHAR2(100);
    v_last_name         VARCHAR2(100);
    v_job_id            VARCHAR2(50);
    v_department_id     NUMBER;
    v_hire_date         DATE;
BEGIN
log_util.log_start('fire_an_employee');
is_business_hours();
    BEGIN
        SELECT first_name, last_name, job_id, department_id, hire_date 
        INTO v_first_name, v_last_name, v_job_id, v_department_id, v_hire_date
        FROM employees
        WHERE employee_id = p_employee_id;
EXCEPTION
    WHEN no_data_found THEN
    raise_application_error(-20001, 'Переданий співробітник не існує');
END;
    BEGIN
        INSERT INTO employees_history (
        employee_id, first_name, last_name, job_id, department_id, hire_date, fire_date
        ) VALUES (p_employee_id, v_first_name, v_last_name, v_job_id, v_department_id, v_hire_date, SYSDATE
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
-------------------------------------------------------------------------------------------------------------------------------------------------------------
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
is_business_hours();
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
    ) VALUES (v_new_employee_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
COMMIT;
    DBMS_OUTPUT.PUT_LINE('Співробітник ' || p_first_name || ' ' || p_last_name || ' успішно доданий');
        EXCEPTION
            WHEN OTHERS THEN
                log_util.log_error('Помилка при додаванні співробітника', SQLERRM);
                RAISE;
END;
log_util.log_finish('add_employee');
END add_employee;
