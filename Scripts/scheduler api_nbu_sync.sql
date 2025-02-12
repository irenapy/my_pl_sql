BEGIN
    sys.dbms_scheduler.create_job (
        job_name        => 'SYNC_NBU_EXCHANGE',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN util.api_nbu_sync; END;',
        start_date      => SYSDATE,
        repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0; BYSECOND=0',
        end_date        => TO_DATE(NULL),
        job_class       => 'DEFAULT_JOB_CLASS',
        enabled         => TRUE,
        auto_drop       => FALSE,
        comments        => 'Оновлення курс валют'
    );
END;
/