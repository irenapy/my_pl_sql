CREATE OR REPLACE PROCEDURE copy_table(
    p_source_scheme IN VARCHAR2,
    p_target_scheme IN VARCHAR2 DEFAULT USER,
    p_list_table IN VARCHAR2,
    p_copy_data IN BOOLEAN DEFAULT FALSE,
    po_result OUT VARCHAR2
) AS
    v_table_name VARCHAR2(255);
    v_ddl_code VARCHAR2(4000);
    v_sql VARCHAR2(4000);
BEGIN
    FOR r IN (
        SELECT table_name, 
               'CREATE TABLE ' || p_target_scheme || '.' || table_name || ' (' ||
               LISTAGG(column_name || ' ' || data_type || count_symbol, ', ') WITHIN GROUP (ORDER BY column_id) || ')' AS ddl_code
        FROM (
            SELECT table_name, column_name, data_type,
                   CASE
                       WHEN data_type IN ('VARCHAR2', 'CHAR') THEN '(' || data_length || ')'
                       WHEN data_type = 'DATE' THEN NULL
                       WHEN data_type = 'NUMBER' THEN REPLACE('(' || data_precision || ',' || data_scale || ')', '(,)', NULL)
                   END AS count_symbol,
                   column_id
            FROM all_tab_columns
            WHERE owner = p_source_scheme
              AND table_name IN (
    SELECT COLUMN_VALUE 
    FROM TABLE(util.table_from_list(p_list_val => p_list_table)))
)

        GROUP BY table_name
    ) LOOP
        BEGIN
            v_table_name := r.table_name;
            v_ddl_code := r.ddl_code;
            EXECUTE IMMEDIATE v_ddl_code;
            to_log('Таблиця ' || v_table_name || ' створена у ' || p_target_scheme, 'INFO');

            IF p_copy_data THEN
                v_sql := 'INSERT INTO ' || p_target_scheme || '.' || v_table_name || 
                         ' SELECT * FROM ' || p_source_scheme || '.' || v_table_name;
                EXECUTE IMMEDIATE v_sql;
                to_log('Дані скопійовано ' || v_table_name, 'INFO');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                to_log('Помилка при створенні ' || v_table_name || ': ' || SQLERRM, 'ERROR');
                CONTINUE;
        END;
    END LOOP;
    po_result := 'Таблиця скопійована';
EXCEPTION
    WHEN OTHERS THEN
        po_result := 'Error: ' || SQLERRM;
        to_log(po_result, 'ERROR');
END copy_table;
