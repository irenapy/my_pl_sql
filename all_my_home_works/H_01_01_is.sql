SET SERVEROUTPUT ON;
--------------------------


DECLARE 
    v_year NUMBER := 2015;
    v_check_year NUMBER;
      
BEGIN
    v_check_year := MOD(v_year, 4);
    
    IF v_check_year = 0 THEN
        dbms_output.put_line('Високосний рік'); 
    
    ELSE 
        dbms_output.put_line('Не високосний рік');
    END IF;  
    
END;
/