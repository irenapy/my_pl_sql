CREATE OR REPLACE  FUNCTION get_sum_price_sales ( p_table IN VARCHAR2) RETURN NUMBER IS
    v_sum       NUMBER;
    v_sql       VARCHAR2(2000);
BEGIN
    
    IF p_table NOT IN ('products', 'products_old') THEN
      to_log('TO_LOG','Неприпустиме значення! Очікується products або products_old');

      RAISE_APPLICATION_ERROR(-20001,'Неприпустиме значення! Очікується products або products_old');
    END IF;

    v_sql := 'SELECT SUM(price_sales) FROM hr.' || p_table;

    EXECUTE IMMEDIATE v_sql INTO v_sum;

    RETURN v_sum;
  END get_sum_price_sales;

/




FUNCTION get_sum_price_sales (p_table IN VARCHAR2
  ) RETURN NUMBER;

