CREATE TABLE irina_ii6.employees_history (
    employee_id   NUMBER NOT NULL, 
    first_name    VARCHAR2(100), 
    last_name     VARCHAR2(100), 
    job_id        VARCHAR2(50), 
    department_id NUMBER, 
    hire_date     DATE, 
    fire_date     DATE DEFAULT sysdate
);