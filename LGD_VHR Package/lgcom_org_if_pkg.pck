CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_org_if_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework
    /* Module       : LGCOM
    /* Program Name : lgcom_org_if_pkg.pls
    /* Reference by :
    /* Description  : ORG 정보 I/F
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-24   Sungkeunsong     1.0      initialize
    /******************************************************************************/

    PROCEDURE main(p_errcode           OUT VARCHAR2
                  ,p_errbuf            OUT VARCHAR2
                  ,p_organization_code IN VARCHAR2);

    PROCEDURE insert_org_info_proc(p_errcode           OUT VARCHAR2
                                  ,p_errbuf            OUT VARCHAR2
                                  ,p_organization_code IN VARCHAR2);

    PROCEDURE update_org_info_proc(p_errcode           OUT VARCHAR2
                                  ,p_errbuf            OUT VARCHAR2
                                  ,p_organization_code IN VARCHAR2);

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGCOM';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE := 'LGSYSC00020';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

END lgcom_org_if_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_org_if_pkg AS

    /******************************************************************************/
    /*                  Copyright (c) 2017 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework 
    /* Module       : TDR
    /* Program Name : lgcom_org_if_pkg.pls
    /* Reference by :
    /* Description  : ORG 정보 I/F
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-24   Sungkeunsong     1.0      initialize
    /******************************************************************************/

    PROCEDURE main(p_errcode           OUT VARCHAR2
                  ,p_errbuf            OUT VARCHAR2
                  ,p_organization_code IN VARCHAR2) IS

        --조직정보 수신테이블에 있는 조직코드 중 lgcom_organization_m 에 존재하지 않는 조직코드 추출  --새로운 조직 insert
        CURSOR new_org_info IS

            SELECT io.organization_code
            FROM   tb_ifr_ehr_department_i io
            WHERE  io.organization_code NOT IN
                   (SELECT om.organization_code
                    FROM   lgcom_organization_m om)
            GROUP  BY io.organization_code;

        -- 오늘 수신받은 조직정보에 있는 조직코드 중 lgcom_organization_m 에 존재하는 조직코드 추출 --바뀐 정보 update
        CURSOR update_org_info IS
            SELECT io.organization_code
            FROM   tb_ifr_ehr_department_i io
            WHERE  TO_CHAR(io.eai_interface_date, 'YYYYMMDD') =
                   TO_CHAR(SYSDATE, 'YYYYMMDD')
            AND    io.organization_code IN
                   (SELECT om.organization_code
                     FROM   lgcom_organization_m om)
            --AND    io.data_interface_type_code = 'U'
            GROUP  BY io.organization_code;

    BEGIN
        FOR cur_record IN new_org_info
        LOOP
            -- lgcom_organization_m 없는 조직 insert
            insert_org_info_proc(p_errcode
                                ,p_errbuf
                                ,cur_record.organization_code);

        END LOOP;

        FOR cur_u_record IN update_org_info
        LOOP
            -- lgcom_organization_m 있는 조직의 새로운 정보 update
            update_org_info_proc(p_errcode
                                ,p_errbuf
                                ,cur_u_record.organization_code);

        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(main)';
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

    END;

    PROCEDURE insert_org_info_proc(p_errcode           OUT VARCHAR2
                                  ,p_errbuf            OUT VARCHAR2
                                  ,p_organization_code IN VARCHAR2) IS

        --조직 수신테이블에서 해당 조직코드의 최신 정보 추출

        CURSOR org_info IS
            SELECT business_group_id
                  ,subsidiary_name
                  ,organization_id
                  ,organization_code
                  ,SUBSTR(organization_name, INSTR(organization_name, '.') + 1) AS organization_name
                  ,start_date
                  ,end_date
                  ,change_start_date
                  ,change_end_date
                  ,organization_manager
                  ,organization_level_code
                  ,organization_level_name
                  ,division_code
                  ,division_name
                  ,en_organization_name
                  ,parent_organization_code
                  ,sort_code
                  ,nationality
                  ,organization_type
                  ,organization_location_id
                  ,organization_location
                  ,org_co_code
                  ,org_co_kr_name
                  ,org_co_en_name
                  ,org_h05_code
                  ,org_h05_kr_name
                  ,org_h05_en_name
                  ,org_h1_code
                  ,org_h1_kr_name
                  ,org_h1_en_name
                  ,org_h2_code
                  ,org_h2_kr_name
                  ,org_h2_en_name
                  ,org_h3_code
                  ,org_h3_kr_name
                  ,org_h3_en_name
                  ,org_h4_code
                  ,org_h4_kr_name
                  ,org_h4_en_name
                  ,org_h5_code
                  ,org_h5_kr_name
                  ,org_h5_en_name
                  ,organization_flag
                  ,last_organization_flag
                  ,org_asg_detail
                  ,last_update_date
                  ,org_group_code
                  ,org_group_name
                  ,create_emp_no
                  ,update_emp_no
                  ,au_code
                  ,au_name
                  ,expense_code
                  ,expense_code_name
                  ,org_master_history_id
                  ,pre_organization_code
                  ,pre_organization_name
            FROM   (SELECT *
                    FROM   tb_ifr_ehr_department_i io
                    WHERE  io.organization_code = p_organization_code
                    ORDER  BY io.eai_interface_date DESC)
            WHERE  ROWNUM = 1;

    BEGIN
        FOR cur_record IN org_info
        LOOP

            BEGIN
                INSERT INTO lgcom_organization_m
                    (business_group_id
                    ,corporation_name
                    ,organization_id
                    ,organization_code
                    ,organization_name
                    ,start_date
                    ,end_date
                    ,organization_manager_emp_no
                    ,organization_level_code
                    ,organization_level_name
                    ,division_code
                    ,division_name
                    ,organization_eng_name
                    ,parent_organization_code
                    ,nationality_name
                    ,organization_location_id
                    ,organization_location_name
                    ,department_organization_code
                    ,department_organization_name
                    ,center_organization_code
                    ,center_organization_name
                    ,hierarchy1_org_code
                    ,hierarchy1_org_name
                    ,hierarchy1_english_org_name
                    ,hierarchy2_org_code
                    ,hierarchy2_org_name
                    ,hierarchy2_english_org_name
                    ,hierarchy3_org_code
                    ,hierarchy3_org_name
                    ,hierarchy3_english_org_name
                    ,hierarchy4_org_code
                    ,hierarchy4_org_name
                    ,hierarchy4_english_org_name
                    ,hierarchy5_organization_code
                    ,hierarchy5_organization_name
                    ,hierarchy5_english_org_name
                    ,organization_flag
                    ,last_organization_flag
                    ,organization_group_code
                    ,organization_group_name
                    ,org_master_history_id
                    ,pre_organization_code
                    ,pre_organization_name
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date)
                VALUES
                    (cur_record.business_group_id
                    ,cur_record.subsidiary_name
                    ,cur_record.organization_id
                    ,cur_record.organization_code
                    ,cur_record.organization_name
                    ,TO_DATE(cur_record.start_date, 'yyyy-mm-dd')
                    ,TO_DATE(cur_record.end_date, 'yyyy-mm-dd')
                    ,cur_record.organization_manager
                    ,cur_record.organization_level_code
                    ,cur_record.organization_level_name
                    ,cur_record.division_code
                    ,cur_record.division_name
                    ,cur_record.en_organization_name
                    ,cur_record.parent_organization_code
                    ,cur_record.nationality
                    ,cur_record.organization_location_id
                    ,cur_record.organization_location
                    ,cur_record.org_co_code
                    ,cur_record.org_co_kr_name
                    ,cur_record.org_h05_code
                    ,cur_record.org_h05_kr_name
                    ,cur_record.org_h1_code
                    ,cur_record.org_h1_kr_name
                    ,cur_record.org_h1_en_name
                    ,cur_record.org_h2_code
                    ,cur_record.org_h2_kr_name
                    ,cur_record.org_h2_en_name
                    ,cur_record.org_h3_code
                    ,cur_record.org_h3_kr_name
                    ,cur_record.org_h3_en_name
                    ,cur_record.org_h4_code
                    ,cur_record.org_h4_kr_name
                    ,cur_record.org_h4_en_name
                    ,cur_record.org_h5_code
                    ,cur_record.org_h5_kr_name
                    ,cur_record.org_h5_en_name
                    ,cur_record.organization_flag
                    ,cur_record.last_organization_flag
                    ,cur_record.org_group_code
                    ,cur_record.org_group_name
                    ,cur_record.org_master_history_id
                    ,cur_record.pre_organization_code
                    ,cur_record.pre_organization_name
                    ,-999
                    ,SYSDATE
                    ,-999
                    ,SYSDATE);

            EXCEPTION
                WHEN OTHERS THEN
                    g_step := 'insert lgcom_organization_m';
                    lgcom_error_log_pkg.set_comment_text(g_step);
            END;

        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(insert_user_info_proc)';
            lgcom_error_log_pkg.set_comment_text(g_step);
    END;

    PROCEDURE update_org_info_proc(p_errcode           OUT VARCHAR2
                                  ,p_errbuf            OUT VARCHAR2
                                  ,p_organization_code IN VARCHAR2) IS

        --조직 수신테이블에서 해당 조직코드의 가장 최근 정보를 추출
        CURSOR org_u_info IS
            SELECT business_group_id
                  ,subsidiary_name
                  ,organization_id
                  ,organization_code
                  ,SUBSTR(organization_name, INSTR(organization_name, '.') + 1) AS organization_name
                  ,start_date
                  ,end_date
                  ,change_start_date
                  ,change_end_date
                  ,organization_manager
                  ,organization_level_code
                  ,organization_level_name
                  ,division_code
                  ,division_name
                  ,en_organization_name
                  ,parent_organization_code
                  ,sort_code
                  ,nationality
                  ,organization_type
                  ,organization_location_id
                  ,organization_location
                  ,org_co_code
                  ,org_co_kr_name
                  ,org_co_en_name
                  ,org_h05_code
                  ,org_h05_kr_name
                  ,org_h05_en_name
                  ,org_h1_code
                  ,org_h1_kr_name
                  ,org_h1_en_name
                  ,org_h2_code
                  ,org_h2_kr_name
                  ,org_h2_en_name
                  ,org_h3_code
                  ,org_h3_kr_name
                  ,org_h3_en_name
                  ,org_h4_code
                  ,org_h4_kr_name
                  ,org_h4_en_name
                  ,org_h5_code
                  ,org_h5_kr_name
                  ,org_h5_en_name
                  ,organization_flag
                  ,last_organization_flag
                  ,org_asg_detail
                  ,last_update_date
                  ,org_group_code
                  ,org_group_name
                  ,create_emp_no
                  ,update_emp_no
                  ,au_code
                  ,au_name
                  ,expense_code
                  ,expense_code_name
                  ,org_master_history_id
                  ,pre_organization_code
                  ,pre_organization_name
            FROM   (SELECT *
                    FROM   tb_ifr_ehr_department_i io
                    WHERE  io.organization_code = p_organization_code
                    ORDER  BY io.eai_interface_date DESC)
            WHERE  ROWNUM = 1;

    BEGIN

        FOR cur_u_record IN org_u_info
        LOOP
            --lgcom_organization_m 테이블에 해당 조직코드의 정보를 최신 정보로 update
            BEGIN

                UPDATE lgcom_organization_m
                SET    business_group_id            = cur_u_record.business_group_id
                      ,corporation_name             = cur_u_record.subsidiary_name
                      ,organization_id              = cur_u_record.organization_id
                      ,organization_code            = cur_u_record.organization_code
                      ,organization_name            = cur_u_record.organization_name
                      ,start_date                   = TO_DATE(cur_u_record.start_date
                                                             ,'yyyy-mm-dd')
                      ,end_date                     = TO_DATE(cur_u_record.end_date
                                                             ,'yyyy-mm-dd')
                      ,organization_manager_emp_no  = cur_u_record.organization_manager
                      ,organization_level_code      = cur_u_record.organization_level_code
                      ,organization_level_name      = cur_u_record.organization_level_name
                      ,division_code                = cur_u_record.division_code
                      ,division_name                = cur_u_record.division_name
                      ,organization_eng_name        = cur_u_record.en_organization_name
                      ,parent_organization_code     = cur_u_record.parent_organization_code
                      ,nationality_name             = cur_u_record.nationality
                      ,organization_location_id     = cur_u_record.organization_location_id
                      ,organization_location_name   = cur_u_record.organization_location
                      ,department_organization_code = cur_u_record.org_co_code
                      ,department_organization_name = cur_u_record.org_co_kr_name
                      ,center_organization_code     = cur_u_record.org_h05_code
                      ,center_organization_name     = cur_u_record.org_h05_kr_name
                      ,hierarchy1_org_code          = cur_u_record.org_h1_code
                      ,hierarchy1_org_name          = cur_u_record.org_h1_kr_name
                      ,hierarchy1_english_org_name  = cur_u_record.org_h1_en_name
                      ,hierarchy2_org_code          = cur_u_record.org_h2_code
                      ,hierarchy2_org_name          = cur_u_record.org_h2_kr_name
                      ,hierarchy2_english_org_name  = cur_u_record.org_h2_en_name
                      ,hierarchy3_org_code          = cur_u_record.org_h3_code
                      ,hierarchy3_org_name          = cur_u_record.org_h3_kr_name
                      ,hierarchy3_english_org_name  = cur_u_record.org_h3_en_name
                      ,hierarchy4_org_code          = cur_u_record.org_h4_code
                      ,hierarchy4_org_name          = cur_u_record.org_h4_kr_name
                      ,hierarchy4_english_org_name  = cur_u_record.org_h4_en_name
                      ,hierarchy5_organization_code = cur_u_record.org_h5_code
                      ,hierarchy5_organization_name = cur_u_record.org_h5_kr_name
                      ,hierarchy5_english_org_name  = cur_u_record.org_h5_en_name
                      ,organization_flag            = cur_u_record.organization_flag
                      ,last_organization_flag       = cur_u_record.last_organization_flag
                      ,organization_group_code      = cur_u_record.org_group_code
                      ,organization_group_name      = cur_u_record.org_group_name
                      ,org_master_history_id        = cur_u_record.org_master_history_id
                      ,pre_organization_code        = cur_u_record.pre_organization_code
                      ,pre_organization_name        = cur_u_record.pre_organization_name
                      ,last_updated_by              = -999
                      ,last_update_date             = SYSDATE
                WHERE  lgcom_organization_m.organization_code =
                       p_organization_code;
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    g_step := 'UPDATE lgcom_organization_m';
                    lgcom_error_log_pkg.set_comment_text(g_step);
            END;

        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(UPDATE_user_info_proc)';
            lgcom_error_log_pkg.set_comment_text(g_step);
    END;

END lgcom_org_if_pkg;
/
