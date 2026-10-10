CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_dq_batch_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2017 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_dq_batch_pkg.pls
    /* Reference by :
    /* Description  : DQ Batch Call Package
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-09-11   Sungkeun Song     1.0      initialize
    /******************************************************************************/

   -- 실 실행 내역
    PROCEDURE make_dq_proc(p_errcode             OUT VARCHAR2
                          ,p_errbuf              OUT VARCHAR2
                          ,p_application_user_id IN NUMBER
                          ,p_session_id          IN NUMBER
                          ,p_query_id            IN NUMBER
                          ,p_request_id          IN NUMBER);

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGCOM';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE := 'LGCOM50010';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

END lgcom_dq_batch_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_dq_batch_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2017 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_dq_batch_pkg.pls
    /* Reference by :
    /* Description  : DQ Batch Call Package
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-09-11   Sungkeun Song     1.0      initialize
    /******************************************************************************/
    PROCEDURE make_dq_proc(p_errcode             OUT VARCHAR2
                          ,p_errbuf              OUT VARCHAR2
                          ,p_application_user_id IN NUMBER
                          ,p_session_id          IN NUMBER
                          ,p_query_id            IN NUMBER
                          ,p_request_id          IN NUMBER) IS

        native CONSTANT INTEGER := 1;
        cursor_id     INTEGER;
        return_val    INTEGER;
        v_sql_content CLOB;
        v_fetch_rows  NUMBER;

        v_start_date DATE;
        v_program_id VARCHAR2(500);
        v_query_name VARCHAR2(500);
        v_error_exception EXCEPTION;
      


    BEGIN
        -- DQ History Table Update      
        BEGIN
          UPDATE xxlge_query_exec_instr_rslt_n xqe
          SET    xqe.batch_job_start_date  = SYSDATE
                ,xqe.concurrent_request_id = p_request_id
                ,xqe.sql_error_content     = 'P'
                ,xqe.last_updated_by       = p_application_user_id
                ,xqe.last_update_date      = SYSDATE
          WHERE  xqe.application_user_id = p_application_user_id
          AND    xqe.upload_session_id = p_session_id
          AND    xqe.query_id = p_query_id;
           
          COMMIT;
          EXCEPTION WHEN OTHERS THEN
                  p_errcode := sqlcode;
                  p_errbuf  := substr(sqlerrm, 1, 1000);               
                  g_step := 'xxlge_query_exec_instr_rslt_n Error';
                  lgcom_error_log_pkg.set_comment_text(g_step);
                  lgcom_error_log_pkg.set_error_code(p_errcode);
                  lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                  lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
        END;
      
       
        --SELECT utl_encode.text_decode(xqe.sql_content, 'UTF8', 1)
        SELECT xqe.sql_content
        INTO   v_sql_content
        FROM   xxlge_query_exec_instr_rslt_n xqe
        WHERE  xqe.application_user_id = p_application_user_id
        AND    xqe.upload_session_id = p_session_id
        AND    xqe.query_id = p_query_id;

        cursor_id := dbms_sql.open_cursor;
        dbms_sql.parse(cursor_id, v_sql_content, native);

        return_val   := dbms_sql.execute(cursor_id);
        v_fetch_rows := dbms_sql.last_row_count;

        dbms_sql.close_cursor(cursor_id);

        -- DQ History Table Update
        UPDATE xxlge_query_exec_instr_rslt_n xqe
        SET    xqe.batch_job_end_date             = SYSDATE
              ,xqe.sql_execution_result_row_count = v_fetch_rows
              ,xqe.sql_error_content              = 'S'
              ,xqe.last_updated_by                = p_application_user_id
              ,xqe.last_update_date               = SYSDATE
        WHERE  xqe.application_user_id = p_application_user_id
        AND    xqe.upload_session_id = p_session_id
        AND    xqe.query_id = p_query_id;

        IF v_fetch_rows > 0 THEN
              BEGIN
                  SELECT xqe.batch_job_start_date
                        ,xqe.parent_program_id
                        ,xq.query_name
                  INTO   v_start_date
                        ,v_program_id
                        ,v_query_name
                  FROM   xxlge_query_exec_instr_rslt_n xqe
                        ,xxlge_query                   xq
                  WHERE  xqe.query_id = xq.query_id
                  AND    xqe.application_user_id = p_application_user_id
                  AND    xqe.upload_session_id = p_session_id
                  AND    xqe.query_id = p_query_id;

                  INSERT INTO xxlge_dq_use_t
                      (organization_id
                      ,user_id
                      ,form_id
                      ,access_group
                      ,query_name
                      ,start_date
                      ,end_date
                      ,creation_date
                      ,created_by
                      ,last_update_date
                      ,last_updated_by
                      ,last_update_login
                      ,query_id)
                  VALUES
                      (-1
                      ,p_application_user_id --USER_ID
                      ,v_program_id --FORM_ID
                      ,'' --ACCESS_GROUP
                      ,v_query_name --QUERY_NAME
                      ,v_start_date --START_DATE
                      ,SYSDATE --END_DATE
                      ,SYSDATE --CREATION_DATE
                      ,p_application_user_id --CREATED_BY
                      ,SYSDATE --LAST_UPDATE_DATE
                      ,p_application_user_id --LAST_UPDATED_BY
                      ,p_application_user_id --LAST_UPDATE_LOGIN
                      ,p_query_id);
              EXCEPTION
                  WHEN OTHERS THEN
                  g_step := 'xxlge_dq_use_t Error';
                  lgcom_error_log_pkg.set_comment_text(g_step);
                  lgcom_error_log_pkg.set_error_code(p_errcode);
                  lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                  lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
              END;
        END IF;
        
        COMMIT;
        
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
            
                p_errcode := sqlcode;
                p_errbuf  := substr(sqlerrm, 1, 1000);                   
                UPDATE xxlge_query_exec_instr_rslt_n xqe
                SET    xqe.batch_job_start_date  = SYSDATE
                      ,xqe.concurrent_request_id = p_request_id
                      ,xqe.result_content        = 'Error : ' ||
                                                    substr(p_errbuf, 1, 1000)
                      ,xqe.sql_error_content     = 'E'
                      ,xqe.last_updated_by       = p_application_user_id
                      ,xqe.last_update_date      = SYSDATE
                WHERE  xqe.application_user_id = p_application_user_id
                AND    xqe.upload_session_id = p_session_id
                AND    xqe.query_id = p_query_id;

                COMMIT;
        END;
END lgcom_dq_batch_pkg;
/
