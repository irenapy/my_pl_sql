CREATE OR REPLACE FUNCTION get_dep_name (
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
/

-------------------
SELECT 
    em.employee_id,
    em.first_name || ' ' || em.last_name AS full_name,
    get_job_title(em.employee_id) AS job_title,
    get_dep_name(em.employee_id) AS department_name
FROM employees em;

--------------------------------------------------
CREATE OR REPLACE FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
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