CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_excel_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2017 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_excel_pkg.pls
    /* Reference by :
    /* Description  : Excel Upload
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /*  2017-08-23  Kimhansik    Initial
    /******************************************************************************/

    PROCEDURE lgsysc00140(p_errcode    OUT VARCHAR2
                         ,p_errbuf     OUT VARCHAR2
                         ,p_session_id IN NUMBER);

    FUNCTION is_number(v_str_number IN VARCHAR2) RETURN NUMBER;

    FUNCTION is_date(v_str_date IN VARCHAR2
                    ,v_format   IN VARCHAR2 DEFAULT 'YYYYMMDD') RETURN VARCHAR2;

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGCOM';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE := 'LGSYSC00236';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

END lgcom_excel_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_excel_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2017 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_excel_pkg.pls
    /* Reference by :
    /* Description  : Excel Upload
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /*  2017-08-23  Kimhansik    Initial
    /******************************************************************************/

    PROCEDURE lgsysc00140(p_errcode    OUT VARCHAR2
                         ,p_errbuf     OUT VARCHAR2
                         ,p_session_id IN NUMBER) IS

        v_exception EXCEPTION;

        CURSOR c1 IS
            SELECT attribute3 AS program_id
                  ,attribute4 AS program_name
                  ,attribute1 AS system_code
                  ,attribute2 AS module_code
                  ,UPPER(attribute5) AS program_type_code
                  ,attribute6 AS business_effect_code
                  ,attribute7 AS difficulty_code
                  ,TO_DATE(REPLACE(attribute8, '-', ''), 'yyyymmdd') AS transfer_date
                  ,attribute9 AS use_flag
                  ,attribute11 AS etc_attach_file_id
                  ,'N' AS excel_download_authority_flag
                  ,xii.created_by AS created_by
                  ,SYSDATE AS creation_date
                  ,xii.created_by AS last_updated_by
                  ,SYSDATE AS last_update_date
            FROM   lgcom_import_n xii--xxlge_import_info
            WHERE  xii.session_id = p_session_id
            AND    xii.attribute199 IS NULL
            AND    xii.seq_no > 1;

    BEGIN
        BEGIN
            --1. attribute1        AS system_code
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || 'Error - system_code(lookup)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_SYSTEM_CODE'
                    AND    lcc.common_code = xii.attribute1)
            AND    xii.seq_no > 1;

            --2. attribute2        AS module_code
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- module_code(lookup)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_MODULE_CODE'
                    AND    lcc.common_code = xii.attribute2
                    AND    lcc.parent_common_code = xii.attribute1)
            AND    xii.seq_no > 1;

            --3. attribute3        AS program_id
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- program_id(naming rule)'
            WHERE  xii.session_id = p_session_id
            AND    xii.attribute3 NOT LIKE xii.attribute2 || '%'
            AND    xii.seq_no > 1;

            --4. attribute4        AS program_name
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- program name(not null)'
            WHERE  xii.session_id = p_session_id
            AND    xii.attribute4 IS NULL
            AND    xii.seq_no > 1;

            --5. attribute5        AS program_type_code
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- program_type(lookup)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_PROGRAM_TYPE_CODE'
                    AND    lcc.common_code = UPPER(xii.attribute5))
            AND    xii.seq_no > 1;

            --6. attribute6        AS business_effect_code
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- business_effect(lookup)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_BUSINESS_EFFECT_CODE'
                    AND    lcc.common_code = xii.attribute6)
            AND    xii.seq_no > 1;

            --7. attribute7        AS difficulty_code
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- difficulty_code(lookup)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_DIFFICULTY_CODE'
                    AND    lcc.common_code = xii.attribute7)
            AND    xii.seq_no > 1;

            --8. attribute8     AS transfer_date
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 ||
                                  '- transfer_date(date format)'
            WHERE  xii.session_id = p_session_id
            AND    is_date(xii.attribute8, 'YYYYMMDD') = 'N'
            AND    xii.seq_no > 1;

            --9. attribute9     AS use_flag
            UPDATE lgcom_import_n xii--xxlge_import_info
            SET    attribute199 = 'Y'
                  ,attribute200 = attribute200 || '- use_flag(Y,N)'
            WHERE  xii.session_id = p_session_id
            AND    NOT EXISTS
             (SELECT 'x'
                    FROM   lgcom_code_type_code_c lc
                          ,lgcom_common_code_c    lcc
                    WHERE  lc.code_type_code = lcc.code_type_code
                    AND    lc.use_flag = 'Y'
                    AND    lcc.use_flag = 'Y'
                    AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                    AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                    AND    lc.code_type_code = 'LGCOM_YN_FLAG'
                    AND    lcc.common_code = xii.attribute9)
            AND    xii.seq_no > 1;
            /*
                       --10. attribute11    AS excel_download_authority_flag
                       UPDATE xxlge_import_info xii
                       SET    attribute199 = 'Y'
                             ,attribute200 = attribute200 || '- excel_flag(Y,N)'
                       WHERE  xii.session_id = p_session_id
                       AND    NOT EXISTS
                        (SELECT 'x'
                               FROM   lgcom_code_type_code_c lc
                                     ,lgcom_common_code_c    lcc
                               WHERE  lc.code_type_code = lcc.code_type_code
                               AND    lc.use_flag = 'Y'
                               AND    lcc.use_flag = 'Y'
                               AND    NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE + 1
                               AND    NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                               AND    lc.code_type_code = 'LGCOM_YN_FLAG'
                               AND    lcc.common_code = xii.attribute11)
                       AND    xii.seq_no > 1;
            */

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                -- update error(attribute200이 150자리밖에 안됨)
                NULL;
        END;

        FOR cr1 IN c1
        LOOP

            BEGIN
                INSERT INTO lgcom_program_m
                    (program_id
                    ,program_name
                    ,system_code
                    ,module_code
                    ,program_type_code
                    ,business_effect_code
                    ,difficulty_code
                    ,transfer_date
                    ,use_flag
                    ,etc_attach_file_id
                    ,excel_download_authority_flag
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date)
                VALUES
                    (cr1.program_id
                    ,cr1.program_name
                    ,cr1.system_code
                    ,cr1.module_code
                    ,cr1.program_type_code
                    ,cr1.business_effect_code
                    ,cr1.difficulty_code
                    ,cr1.transfer_date
                    ,cr1.use_flag
                    ,cr1.etc_attach_file_id
                    ,cr1.excel_download_authority_flag
                    ,cr1.created_by
                    ,cr1.creation_date
                    ,cr1.last_updated_by
                    ,cr1.last_update_date);
            EXCEPTION
                WHEN dup_val_on_index THEN
                    BEGIN
                        UPDATE lgcom_program_m lpm
                        SET    program_name         = cr1.program_name
                              ,system_code          = cr1.system_code
                              ,module_code          = cr1.module_code
                              ,program_type_code    = cr1.program_type_code
                              ,business_effect_code = cr1.business_effect_code
                              ,difficulty_code      = cr1.difficulty_code
                              ,transfer_date        = cr1.transfer_date
                              ,use_flag             = cr1.use_flag
                              ,etc_attach_file_id   = cr1.etc_attach_file_id
                              ,last_updated_by      = cr1.last_updated_by
                              ,last_update_date     = cr1.last_update_date
                        WHERE  lpm.program_id = cr1.program_id;
                    EXCEPTION
                        WHEN OTHERS THEN
                            p_errbuf := cr1.program_id;
                            RAISE v_exception;
                    END;
                WHEN OTHERS THEN
                    p_errbuf := cr1.program_id;
                    RAISE v_exception;
            END;

        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            p_errcode := 'E';
            p_errbuf  := p_errbuf || '-' || SUBSTR(SQLERRM, 1, 1000);
            ROLLBACK;
    END;

    FUNCTION is_number(v_str_number IN VARCHAR2) RETURN NUMBER IS
        v_num NUMBER;
    BEGIN
        v_num := to_number(v_str_number);
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END is_number;

    FUNCTION is_date(v_str_date IN VARCHAR2
                    ,v_format   IN VARCHAR2 DEFAULT 'YYYYMMDD') RETURN VARCHAR2 IS
        v_date DATE;
    BEGIN
        v_date := TO_DATE(REPLACE(v_str_date, '-', ''), v_format);
        RETURN 'Y';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'N';
    END is_date;

END lgcom_excel_pkg;
/
