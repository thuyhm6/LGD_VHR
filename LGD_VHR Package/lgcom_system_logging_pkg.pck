CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_system_logging_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_system_logging_pkg.pls
    /* Reference by :
    /* Description  : system logging info Create
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /*  2017-08-23  Kimhansik     initialize
    /******************************************************************************/

    PROCEDURE main(p_errcode     OUT VARCHAR2
                  ,p_errbuf      OUT VARCHAR2
                  ,p_trx_date    IN VARCHAR2
                  ,p_from_day    IN NUMBER
                  ,p_user_id     IN NUMBER
                  ,p_system_code IN VARCHAR2);

    -- 사용자별 System FAV : user_id = 11223 , system_code = LGCOM  USER_SYSTEM_FAVORITE
    -- 사용자별 All FAV : user_id = 11223 , system_code = ALL  USER_ALL_FAVORITE
    -- 시스템 전체 최다사용 : user_id = 0, system_code = ALL  SYSTEM_ALL_LOGGING
    -- 시스템별 최다 사용 : user_id = 0, system_code = LGCOM  SYSTEM_EACH_LOGGING

    PROCEDURE user_system_favorite_proc(p_errcode            OUT VARCHAR2
                                       ,p_errbuf             OUT VARCHAR2
                                       ,p_previous_yyyymm    IN VARCHAR2
                                       ,p_previous_from_date IN DATE
                                       ,p_previous_to_date   IN DATE
                                       ,p_current_yyyymm     IN VARCHAR2
                                       ,p_current_from_date  IN DATE
                                       ,p_current_to_date    IN DATE
                                       ,p_user_id            IN NUMBER
                                       ,p_system_code        IN VARCHAR2);

    PROCEDURE user_all_favorite_proc(p_errcode            OUT VARCHAR2
                                    ,p_errbuf             OUT VARCHAR2
                                    ,p_previous_yyyymm    IN VARCHAR2
                                    ,p_previous_from_date IN DATE
                                    ,p_previous_to_date   IN DATE
                                    ,p_current_yyyymm     IN VARCHAR2
                                    ,p_current_from_date  IN DATE
                                    ,p_current_to_date    IN DATE
                                    ,p_user_id            IN NUMBER);

    PROCEDURE system_all_logging_proc(p_errcode            OUT VARCHAR2
                                     ,p_errbuf             OUT VARCHAR2
                                     ,p_previous_yyyymm    IN VARCHAR2
                                     ,p_previous_from_date IN DATE
                                     ,p_previous_to_date   IN DATE
                                     ,p_current_yyyymm     IN VARCHAR2
                                     ,p_current_from_date  IN DATE
                                     ,p_current_to_date    IN DATE
                                     ,p_user_id            IN NUMBER);

    PROCEDURE system_each_logging_proc(p_errcode            OUT VARCHAR2
                                      ,p_errbuf             OUT VARCHAR2
                                      ,p_previous_yyyymm    IN VARCHAR2
                                      ,p_previous_from_date IN DATE
                                      ,p_previous_to_date   IN DATE
                                      ,p_current_yyyymm     IN VARCHAR2
                                      ,p_current_from_date  IN DATE
                                      ,p_current_to_date    IN DATE
                                      ,p_system_code        IN VARCHAR2
                                      ,p_user_id            IN NUMBER);

    PROCEDURE create_service_log_s_proc(p_errcode OUT VARCHAR2
                                       ,p_errbuf  OUT VARCHAR2
                                       ,p_yyyymm  IN VARCHAR2
                                       ,p_user_id            IN NUMBER);

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT LGCOM_PROGRAM_M.System_Code%TYPE := 'LGCOM';
    g_program_id  CONSTANT LGCOM_PROGRAM_M.Program_Id%TYPE := 'LGSYSC00021';
    g_step VARCHAR2(2000) := NULL;

END lgcom_system_logging_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_system_logging_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Bizweb Project
    /* Module       : LGCOM
    /* Program Name : lgcom_system_logging_pkg.pls
    /* Reference by :
    /* Description  : system logging info Create
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-24   Kimhansik      1.0      initialize
    /******************************************************************************/
    PROCEDURE main(p_errcode     OUT VARCHAR2
                  ,p_errbuf      OUT VARCHAR2
                  ,p_trx_date    IN VARCHAR2
                  ,p_from_day    IN NUMBER
                  ,p_user_id     IN NUMBER
                  ,p_system_code IN VARCHAR2) IS

        v_transaction_date DATE := NULL;
        v_from_day         NUMBER := NULL;

        v_previous_yyyymm    VARCHAR2(10) := NULL;
        v_previous_from_date DATE := NULL;
        v_previous_to_date   DATE := NULL;

        v_current_yyyymm    VARCHAR2(10) := NULL;
        v_current_from_date DATE := NULL;
        v_current_to_date   DATE := NULL;
    BEGIN
        -- 사용자별 System FAV : user_id = 11223 , system_code = LGCOM  USER_SYSTEM_FAVORITE
        -- 사용자별 All FAV : user_id = 11223 , system_code = ALL  USER_ALL_FAVORITE
        -- 시스템 전체 최다사용 : user_id = 0, system_code = ALL  SYSTEM_ALL_LOGGING
        -- 시스템별 최다 사용 : user_id = 0, system_code = LGCOM  SYSTEM_EACH_LOGGING

        IF p_trx_date IS NULL THEN
            v_transaction_date := SYSDATE;
        ELSE
            v_transaction_date := TO_DATE(p_trx_date, 'yyyymmdd');
        END IF;

        IF p_from_day IS NULL THEN
            v_from_day := 7;
        ELSE
            v_from_day := p_from_day;
        END IF;

        SELECT TO_CHAR(v_transaction_date - v_from_day, 'yyyymm')
              ,TO_CHAR(v_transaction_date, 'yyyymm')
        INTO   v_previous_yyyymm
              ,v_current_yyyymm
        FROM   dual;

        IF v_previous_yyyymm = v_current_yyyymm THEN
            -- previous yyyymm과 current yyyymm이 같다면,
            -- 전달 조건으로 들어가는 월은 'Null'값을 주어 cursor에서 조회되지않게..
            v_previous_yyyymm    := 'Null';
            v_previous_from_date := SYSDATE;
            v_previous_to_date   := SYSDATE;
        ELSE

            v_previous_from_date := v_transaction_date - v_from_day;
            v_previous_to_date   := LAST_DAY(TO_DATE(v_previous_yyyymm
                                                    ,'yyyymm'));

            v_current_from_date := TO_DATE(v_current_yyyymm || '01', 'yyyymmdd');
            v_current_to_date   := v_transaction_date;

        END IF;

        -- USER_SYSTEM_FAVORITE
        user_system_favorite_proc(p_errcode            => p_errcode
                                 ,p_errbuf             => p_errbuf
                                 ,p_previous_yyyymm    => v_previous_yyyymm
                                 ,p_previous_from_date => v_previous_from_date
                                 ,p_previous_to_date   => v_previous_to_date
                                 ,p_current_yyyymm     => v_current_yyyymm
                                 ,p_current_from_date  => v_current_from_date
                                 ,p_current_to_date    => v_current_to_date
                                 ,p_user_id            => p_user_id
                                 ,p_system_code        => p_system_code);

        -- USER_ALL_FAVORITE
        user_all_favorite_proc(p_errcode            => p_errcode
                              ,p_errbuf             => p_errbuf
                              ,p_previous_yyyymm    => v_previous_yyyymm
                              ,p_previous_from_date => v_previous_from_date
                              ,p_previous_to_date   => v_previous_to_date
                              ,p_current_yyyymm     => v_current_yyyymm
                              ,p_current_from_date  => v_current_from_date
                              ,p_current_to_date    => v_current_to_date
                              ,p_user_id            => p_user_id);

        -- SYSTEM_ALL_LOGGING
        system_all_logging_proc(p_errcode            => p_errcode
                               ,p_errbuf             => p_errbuf
                               ,p_previous_yyyymm    => v_previous_yyyymm
                               ,p_previous_from_date => v_previous_from_date
                               ,p_previous_to_date   => v_previous_to_date
                               ,p_current_yyyymm     => v_current_yyyymm
                               ,p_current_from_date  => v_current_from_date
                               ,p_current_to_date    => v_current_to_date
                               ,p_user_id            => p_user_id);

        -- SYSTEM_EACH_LOGGING
        system_each_logging_proc(p_errcode            => p_errcode
                                ,p_errbuf             => p_errbuf
                                ,p_previous_yyyymm    => v_previous_yyyymm
                                ,p_previous_from_date => v_previous_from_date
                                ,p_previous_to_date   => v_previous_to_date
                                ,p_current_yyyymm     => v_current_yyyymm
                                ,p_current_from_date  => v_current_from_date
                                ,p_current_to_date    => v_current_to_date
                                ,p_system_code        => p_system_code
                                ,p_user_id            => p_user_id);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    -- 사용자별 System FAV : USER_SYSTEM_FAVORITE
    PROCEDURE user_system_favorite_proc(p_errcode            OUT VARCHAR2
                                       ,p_errbuf             OUT VARCHAR2
                                       ,p_previous_yyyymm    IN VARCHAR2
                                       ,p_previous_from_date IN DATE
                                       ,p_previous_to_date   IN DATE
                                       ,p_current_yyyymm     IN VARCHAR2
                                       ,p_current_from_date  IN DATE
                                       ,p_current_to_date    IN DATE
                                       ,p_user_id            IN NUMBER
                                       ,p_system_code        IN VARCHAR2) IS

        v_app_user_id   NUMBER := NULL;
        v_system_code   VARCHAR2(30) := NULL;
        v_sort_order_no NUMBER := 0;

        v_user_id NUMBER := p_user_id;--fnd_global.user_id;

        CURSOR cur_01 IS
            SELECT m.application_user_id
            FROM   (SELECT lsa.application_user_id
                    FROM   lgcom_system_access_logging_n lsa
                    WHERE  lsa.execution_yyyymm = p_previous_yyyymm
                    AND    lsa.access_date > p_previous_from_date - 1
                    AND    lsa.access_date < p_previous_to_date + 1
                    AND    lsa.application_user_id =
                           NVL(p_user_id, lsa.application_user_id)
                    UNION ALL
                    SELECT lsa.application_user_id
                    FROM   lgcom_system_access_logging_n lsa
                    WHERE  lsa.execution_yyyymm = p_current_yyyymm
                    AND    lsa.access_date > p_current_from_date - 1
                    AND    lsa.access_date < p_current_to_date + 1
                    AND    lsa.application_user_id =
                           NVL(p_user_id, lsa.application_user_id)) m
            GROUP  BY m.application_user_id;

        CURSOR cur_02 IS
            SELECT m.system_code
            FROM   (SELECT lm.system_code
                    FROM   lgcom_system_access_logging_n lsa
                          ,lgcom_menu_m                  lm
                    WHERE  lsa.menu_id = lm.menu_id
                    AND    lsa.execution_yyyymm = p_previous_yyyymm
                    AND    lsa.access_date > p_previous_from_date - 1
                    AND    lsa.access_date < p_previous_to_date + 1
                    AND    lsa.application_user_id = v_app_user_id
                    AND    lm.system_code = NVL(p_system_code, lm.system_code)
                    UNION ALL
                    SELECT lm.system_code
                    FROM   lgcom_system_access_logging_n lsa
                          ,lgcom_menu_m                  lm
                    WHERE  lsa.menu_id = lm.menu_id
                    AND    lsa.execution_yyyymm = p_current_yyyymm
                    AND    lsa.access_date > p_current_from_date - 1
                    AND    lsa.access_date < p_current_to_date + 1
                    AND    lsa.application_user_id = v_app_user_id
                    AND    lm.system_code = NVL(p_system_code, lm.system_code)) m
            GROUP  BY m.system_code;

        CURSOR cur_03 IS
            SELECT m.*
            FROM   (SELECT sub.menu_id
                          ,COUNT(1) AS access_cnt
                    FROM   (SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.system_code = v_system_code
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_previous_yyyymm
                            AND    lsa.access_date > p_previous_from_date - 1
                            AND    lsa.access_date < p_previous_to_date + 1
                            AND    lsa.application_user_id = v_app_user_id
                            AND    EXISTS
                             (SELECT 'x'
                                    FROM   lgcom_user_menu_autho_v lu
                                    WHERE  lu.application_user_id = v_app_user_id
                                    AND    lu.menu_id = lsa.menu_id)
                            UNION ALL
                            SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.system_code = v_system_code
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_current_yyyymm
                            AND    lsa.access_date > p_current_from_date - 1
                            AND    lsa.access_date < p_current_to_date + 1
                            AND    lsa.application_user_id = v_app_user_id
                            AND    EXISTS
                             (SELECT 'x'
                                    FROM   lgcom_user_menu_autho_v lu
                                    WHERE  lu.application_user_id = v_app_user_id
                                    AND    lu.menu_id = lsa.menu_id)) sub
                    GROUP  BY sub.menu_id
                    ORDER  BY 2 DESC) m
            WHERE  ROWNUM <= 10;

    BEGIN

        FOR cur_01_record IN cur_01
        LOOP

            v_app_user_id := cur_01_record.application_user_id;

            BEGIN
                DELETE lgcom_system_user_favorites_n luf
                WHERE  luf.application_user_id = v_app_user_id
                AND    luf.favorites_creation_class_code =
                       'USER_SYSTEM_FAVORITE';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            -- cur_01의 user의 갖고있는 system Loop
            FOR cur_02_record IN cur_02
            LOOP

                v_system_code   := cur_02_record.system_code;
                v_sort_order_no := 1;

                -- cur_02의 user가 접속한system별 최다접속Menu Loop
                FOR cur_03_record IN cur_03
                LOOP
                    BEGIN
                        INSERT INTO lgcom_system_user_favorites_n
                            (application_user_id
                            ,menu_id
                            ,system_code
                            ,sort_order_no
                            ,favorites_creation_class_code
                            ,created_by
                            ,creation_date
                            ,last_updated_by
                            ,last_update_date)
                        VALUES
                            (v_app_user_id
                            ,cur_03_record.menu_id
                            ,v_system_code
                            ,v_sort_order_no
                            ,'USER_SYSTEM_FAVORITE'
                            ,v_user_id
                            ,SYSDATE
                            ,v_user_id
                            ,SYSDATE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;

                    v_sort_order_no := v_sort_order_no + 1;
                END LOOP;
            END LOOP;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := 'E';
            p_errbuf  := 'user_system_favorite_proc Others Error : ' || SQLERRM;
    END;

    -- 사용자별 All FAV : USER_ALL_FAVORITE
    PROCEDURE user_all_favorite_proc(p_errcode            OUT VARCHAR2
                                    ,p_errbuf             OUT VARCHAR2
                                    ,p_previous_yyyymm    IN VARCHAR2
                                    ,p_previous_from_date IN DATE
                                    ,p_previous_to_date   IN DATE
                                    ,p_current_yyyymm     IN VARCHAR2
                                    ,p_current_from_date  IN DATE
                                    ,p_current_to_date    IN DATE
                                    ,p_user_id            IN NUMBER) IS

        v_app_user_id   NUMBER := NULL;
        v_sort_order_no NUMBER := 0;

        v_user_id NUMBER := p_user_id;--fnd_global.user_id;

        CURSOR cur_01 IS
            SELECT m.application_user_id
            FROM   (SELECT lsa.application_user_id
                    FROM   lgcom_system_access_logging_n lsa
                    WHERE  lsa.execution_yyyymm = p_previous_yyyymm
                    AND    lsa.access_date > p_previous_from_date - 1
                    AND    lsa.access_date < p_previous_to_date + 1
                    AND    lsa.application_user_id =
                           NVL(p_user_id, lsa.application_user_id)
                    UNION ALL
                    SELECT lsa.application_user_id
                    FROM   lgcom_system_access_logging_n lsa
                    WHERE  lsa.execution_yyyymm = p_current_yyyymm
                    AND    lsa.access_date > p_current_from_date - 1
                    AND    lsa.access_date < p_current_to_date + 1
                    AND    lsa.application_user_id =
                           NVL(p_user_id, lsa.application_user_id)) m
            GROUP  BY m.application_user_id;

        CURSOR cur_02 IS
            SELECT m.*
            FROM   (SELECT sub.menu_id
                          ,COUNT(1) AS access_cnt
                    FROM   (SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_previous_yyyymm
                            AND    lsa.access_date > p_previous_from_date - 1
                            AND    lsa.access_date < p_previous_to_date + 1
                            AND    lsa.application_user_id = v_app_user_id
                            AND    EXISTS
                             (SELECT 'x'
                                    FROM   lgcom_user_menu_autho_v lu
                                    WHERE  lu.application_user_id = v_app_user_id
                                    AND    lu.menu_id = lsa.menu_id)
                            UNION ALL
                            SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_current_yyyymm
                            AND    lsa.access_date > p_current_from_date - 1
                            AND    lsa.access_date < p_current_to_date + 1
                            AND    lsa.application_user_id = v_app_user_id
                            AND    EXISTS
                             (SELECT 'x'
                                    FROM   lgcom_user_menu_autho_v lu
                                    WHERE  lu.application_user_id = v_app_user_id
                                    AND    lu.menu_id = lsa.menu_id)) sub
                    GROUP  BY sub.menu_id
                    ORDER  BY 2 DESC) m
            WHERE  ROWNUM <= 10;

    BEGIN
        FOR cur_01_record IN cur_01
        LOOP

            v_app_user_id   := cur_01_record.application_user_id;
            v_sort_order_no := 1;

            BEGIN
                DELETE lgcom_system_user_favorites_n luf
                WHERE  luf.application_user_id = v_app_user_id
                AND    luf.favorites_creation_class_code = 'USER_ALL_FAVORITE';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            FOR cur_02_record IN cur_02
            LOOP
                BEGIN
                    INSERT INTO lgcom_system_user_favorites_n
                        (application_user_id
                        ,menu_id
                        ,system_code
                        ,sort_order_no
                        ,favorites_creation_class_code
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date)
                    VALUES
                        (v_app_user_id
                        ,cur_02_record.menu_id
                        ,'ALL' --system_code
                        ,v_sort_order_no
                        ,'USER_ALL_FAVORITE'
                        ,v_user_id
                        ,SYSDATE
                        ,v_user_id
                        ,SYSDATE);
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;

                v_sort_order_no := v_sort_order_no + 1;
            END LOOP;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := 'E';
            p_errbuf  := 'user_all_favorite_proc Others Error : ' || SQLERRM;
    END;

    -- 시스템 전체 최다사용 : user_id = 0, system_code = ALL   SYSTEM_ALL_LOGGING
    PROCEDURE system_all_logging_proc(p_errcode            OUT VARCHAR2
                                     ,p_errbuf             OUT VARCHAR2
                                     ,p_previous_yyyymm    IN VARCHAR2
                                     ,p_previous_from_date IN DATE
                                     ,p_previous_to_date   IN DATE
                                     ,p_current_yyyymm     IN VARCHAR2
                                     ,p_current_from_date  IN DATE
                                     ,p_current_to_date    IN DATE
                                     ,p_user_id            IN NUMBER) IS

        v_sort_order_no NUMBER := 0;

        v_user_id NUMBER := p_user_id;--fnd_global.user_id;

        CURSOR cur_01 IS
            SELECT m.*
            FROM   (SELECT sub.menu_id
                          ,COUNT(1) AS access_cnt
                    FROM   (SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_previous_yyyymm
                            AND    lsa.access_date > p_previous_from_date - 1
                            AND    lsa.access_date < p_previous_to_date + 1
                            UNION ALL
                            SELECT lsa.menu_id
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_current_yyyymm
                            AND    lsa.access_date > p_current_from_date - 1
                            AND    lsa.access_date < p_current_to_date + 1) sub
                    GROUP  BY sub.menu_id
                    ORDER  BY 2 DESC) m
            WHERE  ROWNUM <= 10;

    BEGIN

        v_sort_order_no := 1;

        BEGIN
            DELETE lgcom_system_user_favorites_n luf
            WHERE  luf.favorites_creation_class_code = 'SYSTEM_ALL_LOGGING';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        FOR cur_01_record IN cur_01
        LOOP
            BEGIN
                INSERT INTO lgcom_system_user_favorites_n
                    (application_user_id
                    ,menu_id
                    ,system_code
                    ,sort_order_no
                    ,favorites_creation_class_code
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date)
                VALUES
                    (0 -- application_user_id
                    ,cur_01_record.menu_id
                    ,'ALL' --system_code
                    ,v_sort_order_no
                    ,'SYSTEM_ALL_LOGGING'
                    ,v_user_id
                    ,SYSDATE
                    ,v_user_id
                    ,SYSDATE);
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            v_sort_order_no := v_sort_order_no + 1;
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := 'E';
            p_errbuf  := 'system_all_logging_proc Others Error : ' || SQLERRM;
    END;

    -- SYSTEM_EACH_LOGGING
    PROCEDURE system_each_logging_proc(p_errcode            OUT VARCHAR2
                                      ,p_errbuf             OUT VARCHAR2
                                      ,p_previous_yyyymm    IN VARCHAR2
                                      ,p_previous_from_date IN DATE
                                      ,p_previous_to_date   IN DATE
                                      ,p_current_yyyymm     IN VARCHAR2
                                      ,p_current_from_date  IN DATE
                                      ,p_current_to_date    IN DATE
                                      ,p_system_code        IN VARCHAR2
                                      ,p_user_id            IN NUMBER) IS

        v_system_code   VARCHAR2(10) := NULL;
        v_sort_order_no NUMBER := 0;

        v_user_id NUMBER := p_user_id;--fnd_global.user_id;

        CURSOR cur_01 IS
            SELECT m.system_code
            FROM   (SELECT lm.system_code
                    FROM   lgcom_system_access_logging_n lsa
                          ,lgcom_menu_m                  lm
                    WHERE  lsa.menu_id = lm.menu_id
                    AND    lsa.execution_yyyymm = p_previous_yyyymm
                    AND    lsa.access_date > p_previous_from_date - 1
                    AND    lsa.access_date < p_previous_to_date + 1
                    AND    lm.system_code = NVL(p_system_code, lm.system_code)
                    UNION ALL
                    SELECT lm.system_code
                    FROM   lgcom_system_access_logging_n lsa
                          ,lgcom_menu_m                  lm
                    WHERE  lsa.menu_id = lm.menu_id
                    AND    lsa.execution_yyyymm = p_current_yyyymm
                    AND    lsa.access_date > p_current_from_date - 1
                    AND    lsa.access_date < p_current_to_date + 1
                    AND    lm.system_code = NVL(p_system_code, lm.system_code)) m
            GROUP  BY m.system_code;

        CURSOR cur_02 IS
            SELECT m.*
            FROM   (SELECT sub.menu_id
                          ,sub.system_code
                          ,COUNT(1) AS access_cnt
                    FROM   (SELECT lsa.menu_id
                                  ,lm.system_code
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.system_code = v_system_code
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_previous_yyyymm
                            AND    lsa.access_date > p_previous_from_date - 1
                            AND    lsa.access_date < p_previous_to_date + 1
                            UNION ALL
                            SELECT lsa.menu_id
                                  ,lm.system_code
                            FROM   lgcom_system_access_logging_n lsa
                                  ,lgcom_menu_m                  lm
                                  ,lgcom_program_m               lp
                            WHERE  lsa.menu_id = lm.menu_id
                            AND    lm.program_id = lp.program_id
                            AND    lm.system_code = v_system_code
                            AND    lm.display_flag = 'Y'
                            AND    lsa.execution_yyyymm = p_current_yyyymm
                            AND    lsa.access_date > p_current_from_date - 1
                            AND    lsa.access_date < p_current_to_date + 1) sub
                    GROUP  BY sub.menu_id
                             ,sub.system_code
                    ORDER  BY 3 DESC) m
            WHERE  ROWNUM <= 10;

    BEGIN
        FOR cur_01_record IN cur_01
        LOOP

            v_system_code   := cur_01_record.system_code;
            v_sort_order_no := 1;

            BEGIN
                DELETE lgcom_system_user_favorites_n luf
                WHERE  luf.system_code = v_system_code
                AND    luf.favorites_creation_class_code =
                       'SYSTEM_EACH_LOGGING';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            FOR cur_02_record IN cur_02
            LOOP
                BEGIN
                    INSERT INTO lgcom_system_user_favorites_n
                        (application_user_id
                        ,menu_id
                        ,system_code
                        ,sort_order_no
                        ,favorites_creation_class_code
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date)
                    VALUES
                        (0 -- application_user_id
                        ,cur_02_record.menu_id
                        ,cur_02_record.system_code
                        ,v_sort_order_no
                        ,'SYSTEM_EACH_LOGGING'
                        ,v_user_id
                        ,SYSDATE
                        ,v_user_id
                        ,SYSDATE);
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;

                v_sort_order_no := v_sort_order_no + 1;
            END LOOP;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := 'E';
            p_errbuf  := 'system_each_logging_proc Others Error : ' || SQLERRM;
    END;

    PROCEDURE create_service_log_s_proc(p_errcode OUT VARCHAR2
                                       ,p_errbuf  OUT VARCHAR2
                                       ,p_yyyymm  IN VARCHAR2
                                       ,p_user_id IN NUMBER) IS

        v_user_id NUMBER := p_user_id;--fnd_global.user_id;
        v_yyyymm  VARCHAR2(100) := NULL;

        CURSOR cur_logging_info IS
            SELECT /*+INDEX(T LGCOM_SYSTEM_SERVICE_LOG_N1)*/
                   t.execution_yyyymm
                  ,t.menu_id
                  ,t.program_id
                  ,t.system_service_desc
                   --,SUBSTR(t.system_service_desc
                   --       ,INSTR(t.system_service_desc, '/', -1) + 1) AS system_service_desc
                  ,AVG(TRUNC(extract(hour FROM(t.actual_end_timestamp -
                                          t.actual_start_timestamp)) * 60 * 60 +
                             extract(minute FROM(t.actual_end_timestamp -
                                          t.actual_start_timestamp)) * 60 +
                             extract(SECOND FROM(t.actual_end_timestamp -
                                          t.actual_start_timestamp))
                            ,2)) AS average_processing_time
            FROM   lgcom_system_service_logging_n t
            WHERE  t.menu_id IS NOT NULL
            AND    t.execution_yyyymm = v_yyyymm
            GROUP  BY t.execution_yyyymm
                     ,t.menu_id
                     ,t.program_id
                     ,system_service_desc;

    BEGIN
        IF p_yyyymm IS NULL THEN
            SELECT TO_CHAR(SYSDATE, 'YYYYMM')
            INTO   v_yyyymm
            FROM   dual;
        ELSE
            v_yyyymm := p_yyyymm;
        END IF;

        BEGIN
            DELETE lgcom_system_service_log_s t
            WHERE  t.execution_yyyymm = v_yyyymm;
            EXCEPTION WHEN OTHERS THEN null;
        END;

        -- 불필요한 service logging info 삭제
        BEGIN
            -- 1.service desc에 program_id가 들어가지않은 service logging정보
            DELETE FROM lgcom_system_service_logging_n lss
            WHERE  lss.execution_yyyymm = v_yyyymm
            AND    NOT EXISTS (SELECT 'x'
                    FROM   lgcom_program_m lpm
                    WHERE  lss.system_service_desc LIKE
                           '%' || lpm.program_id || '%');

            -- 2.Lookup에 등록한  service logging정보
            DELETE FROM lgcom_system_service_logging_n lss
            WHERE  lss.execution_yyyymm = v_yyyymm
            AND    lss.system_service_desc IN
                   (SELECT lcc.common_code_desc
                     FROM   lgcom_code_type_code_c lc
                           ,lgcom_common_code_c    lcc
                     WHERE  lc.code_type_code = 'LGCOM_DEL_SERVICE_LOGGING_DESC'
                     AND    lc.code_type_code = lcc.code_type_code
                     AND    lc.use_flag = 'Y'
                     AND    lcc.use_flag = 'Y'
                     AND    NVL(lcc.apply_start_date, SYSDATE) < SYSDATE + 1
                     AND    NVL(lcc.apply_end_date, SYSDATE) > SYSDATE - 1);
            EXCEPTION WHEN OTHERS THEN null;                     
        END;

        FOR cur_record IN cur_logging_info
        LOOP
           BEGIN
            INSERT INTO lgcom_system_service_log_s
                (execution_yyyymm
                ,menu_id
                ,program_id
                ,system_service_desc
                ,average_processing_time
                ,created_by
                ,creation_date
                ,last_updated_by
                ,last_update_date)
            VALUES
                (cur_record.execution_yyyymm
                ,cur_record.menu_id
                ,cur_record.program_id
                ,cur_record.system_service_desc
                ,cur_record.average_processing_time
                ,v_user_id --created_by
                ,SYSDATE --creation_date
                ,v_user_id --last_updated_by
                ,SYSDATE --last_update_date
                 );
            EXCEPTION WHEN OTHERS THEN null;                 
           END;
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := 'E';
            p_errbuf  := 'create_service_log_s_proc Others Error : ' || SQLERRM;
    END;
END;
/
