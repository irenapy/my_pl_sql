----SET DEFINE OFF;----
--------------------------------------------------


SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS res
FROM dual;
-----------------------------------------------

CREATE TABLE interbank_index_ua_history
    (dt     VARCHAR2(100),
    id_api  VARCHAR2(100),
    value    NUMBER,
    special  VARCHAR2(100) );
    
-------------------------------
CREATE OR REPLACE VIEW interbank_index_ua_v AS
SELECT
    TO_DATE(tt.dt, 'DD-MM-YYYY') AS dt,
    tt.id_api,
    tt.value,
    tt.special
FROM
    (SELECT SYS.GET_NBU('https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS api_response FROM dual),
    JSON_TABLE(
        api_response, '$[*]'
        COLUMNS (
            dt        VARCHAR2(100) PATH '$.dt',
            id_api    VARCHAR2(100) PATH '$.id_api',
            value     NUMBER        PATH '$.value',
            special   VARCHAR2(100) PATH '$.special'
        )
    ) tt;

---------------------------
CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history (dt, id_api, value, special)
    SELECT 
        TRUNC(SYSDATE, 'DD') AS dt, 
        'UONIA_Depo' AS id_api, 
        ROUND(DBMS_RANDOM.VALUE(5, 20), 2) AS value, 
        'Тест' AS special 
    FROM dual;
    
    COMMIT;
END download_ibank_index_ua;
/

-------------------
BEGIN
    sys.dbms_scheduler.create_job(job_name          => 'download_ibank_index_job',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'BEGIN download_ibank_index_ua; END;',
                                start_date          =>  TRUNC(SYSDATE) + 9/24,
                                repeat_interval     => 'FREQ=DAILY; BYHOUR=9; BYMINUTE=0; BYSECOND=0',
                                end_date            => TO_DATE(NULL),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => TRUE,
                                auto_drop           => FALSE,
                                comments            => 'Тестові дані');
END;
/

