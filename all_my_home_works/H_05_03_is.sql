CREATE OR REPLACE VIEW irina_ii6.department_report AS
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM irina_ii6.employees
GROUP BY DEPARTMENT_ID;

DECLARE
    v_recipient VARCHAR2(100);
    v_subject   VARCHAR2(100) := 'Звіт про кількість працівників';
    v_message   VARCHAR(4000);
BEGIN
 
    SELECT EMAIL || '@gmail.com' INTO v_recipient
    FROM irina_ii6.employees
    WHERE EMPLOYEE_ID = 207;

    
    v_message := 'Ід департаменту | Кількість працівників';
    FOR rec IN (SELECT DEPARTMENT_ID, EMPLOYEE_COUNT FROM irina_ii6.department_report) LOOP
        v_message := v_message || rec.DEPARTMENT_ID || ' | ' || rec.EMPLOYEE_COUNT || '|';
    END LOOP;

  
    sys.sendmail(
        p_recipient => v_recipient,
        p_subject   => v_subject,
        p_message   => v_message
    );
END;