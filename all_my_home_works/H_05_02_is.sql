CREATE OR REPLACE VIEW rep_project_dep_v AS
SELECT
    p.project_name,
    d.department_name,
    COUNT(e.employee_id) AS emp_count,
    COUNT(DISTINCT e.manager_id) AS u_manager_count,
    SUM(e.salary) AS sum_salary
FROM
    (SELECT
        ext_fl.project_id,
        ext_fl.project_name,
        ext_fl.department_id
FROM EXTERNAL ( (project_id NUMBER, 
                project_name VARCHAR2(100), 
                department_id NUMBER)
TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER -- вказуємо назву директорї в БД
ACCESS PARAMETERS ( records delimited BY newline
                                        nologfile
                                        nobadfile 
                                        fields terminated BY ',' 
                                        missing field VALUES are NULL )
LOCATION('PROJECTS.csv') -- вказуємо назву файлу
 REJECT LIMIT UNLIMITED /*немає обмежень для вдкидання рядкв*/ ) ext_fl) p
JOIN
    departments d ON p.department_id = d.department_id
JOIN
    employees e ON d.department_id = e.department_id
GROUP BY
    p.project_name, d.department_name;

DECLARE
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER';
    file_name VARCHAR2(200):= 'TOTAL_PROJ_INDEX_is.csv';
    file_content VARCHAR2(4000); 
BEGIN
   
    FOR rrr IN (SELECT * FROM rep_project_dep_v) LOOP
        file_content := file_content || 
                        rrr.project_name || ',' || 
                        rrr.department_name || ',' || 
                        rrr.emp_count || ',' || 
                        rrr.u_manager_count || ',' || 
                        rrr.sum_salary || CHR(10);
    END LOOP;
   
    file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W');

    UTL_FILE.PUT_LINE(file_handle, 'PROJECT_NAME, DEPARTMENT_NAME, EMP_COUNT, UNIQUE_MANAGERS, SUM_SALARY');
    UTL_FILE.PUT_LINE(file_handle, file_content);

    UTL_FILE.FCLOSE(file_handle);
    EXCEPTION
    WHEN OTHERS THEN
        
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    
        RAISE;
END;
/


