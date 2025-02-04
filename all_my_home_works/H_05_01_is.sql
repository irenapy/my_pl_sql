CREATE OR REPLACE TRIGGER hire_date_update
    BEFORE UPDATE ON irina_ii6.employees
    FOR EACH ROW
BEGIN
   
    IF :OLD.job_id != :NEW.job_id THEN
        :NEW.hire_date := TRUNC(SYSDATE);
    END IF;
END hire_date_update;
/



-----виклик

UPDATE irina_ii6.employees
SET job_id = 'IPI_MAN'
WHERE employee_id = 104;



