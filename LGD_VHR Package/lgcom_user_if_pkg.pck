CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_user_if_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_user_if_pkg.pls
    /* Reference by :
    /* Description  : User정보 I/F
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-21   Sungkeun Song     1.0      initialize
    /******************************************************************************/

    PROCEDURE main(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  ,p_user_name           IN VARCHAR2);

    PROCEDURE organization_receieve_proc(p_errcode             OUT VARCHAR2
                                        ,p_errbuf              OUT VARCHAR2
                                        ,p_application_user_id IN NUMBER);

    PROCEDURE regular_emp_receieve_proc(p_errcode             OUT VARCHAR2
                                       ,p_errbuf              OUT VARCHAR2
                                       ,p_application_user_id IN NUMBER);

    PROCEDURE partner_emp_receieve_proc(p_errcode             OUT VARCHAR2
                                       ,p_errbuf              OUT VARCHAR2
                                       ,p_application_user_id IN NUMBER);

    PROCEDURE insert_user_info_proc(p_errcode             OUT VARCHAR2
                                   ,p_errbuf              OUT VARCHAR2
                                   ,p_application_user_id IN NUMBER
                                   ,p_user_name           IN VARCHAR2);

    PROCEDURE update_user_info_proc(p_errcode             OUT VARCHAR2
                                   ,p_errbuf              OUT VARCHAR2
                                   ,p_application_user_id IN NUMBER
                                   ,p_user_name           IN VARCHAR2);

    PROCEDURE create_common_user_role_proc(p_errcode             OUT VARCHAR2
                                          ,p_errbuf              OUT VARCHAR2
                                          ,p_application_user_id IN NUMBER
                                          ,p_user_name           IN VARCHAR2);

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGCOM';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE := 'LGSYSC00020';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

END lgcom_user_if_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_user_if_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_user_if_pkg.pls
    /* Reference by :
    /* Description  : User정보 I/F
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-21   Sungkeun Song     1.0      initialize
    /******************************************************************************/

    PROCEDURE main(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  ,p_user_name           IN VARCHAR2) IS

        -- 오늘 수신받은 인사정보에 있는 사번 중 lgcom_user_m 에 존재하는 사번 추출 --바뀐 정보 update
        CURSOR update_user_info IS
            SELECT ie.employee_no
            FROM   lgcom_ehr_r_employee ie --tb_ifr_ehr_r_employee_i ie
            WHERE  EXISTS (SELECT 1
                    FROM   lgcom_user_m lum
                    WHERE  lum.user_name = ie.employee_no)
            GROUP  BY ie.employee_no;

        -- 인사정보 수신테이블에 있는 사번 중 lgcom_user_m 에 존재하지 않는 사번 추출 --새로운 사람 insert
        CURSOR new_fnd_user_info IS
            SELECT ie.employee_no
            FROM   lgcom_ehr_r_employee ie --tb_ifr_ehr_r_employee_i ie
            WHERE  1 = 1
            AND    NOT EXISTS (SELECT 1
                    FROM   lgcom_user_m lum
                    WHERE  lum.user_name = ie.employee_no)
            GROUP  BY ie.employee_no;

    BEGIN

        --Department Interface IMport
        organization_receieve_proc(p_errcode, p_errbuf, p_application_user_id);

        --Regular Info Interface
        regular_emp_receieve_proc(p_errcode, p_errbuf, p_application_user_id);

        --Partner INterface Import
        partner_emp_receieve_proc(p_errcode, p_errbuf, p_application_user_id);

        FOR cur_u_record IN update_user_info
        LOOP
            -- lgcom_user_m에 있는 사람의 새로운 정보 update
            update_user_info_proc(p_errcode, p_errbuf, p_application_user_id, cur_u_record.employee_no);

        END LOOP;

        FOR cur_record IN new_fnd_user_info
        LOOP
            -- lgcom_user_m에 없는 사람 insert
            insert_user_info_proc(p_errcode, p_errbuf, p_application_user_id, cur_record.employee_no);

        END LOOP;

        -- 전사 Common Role 부여..
        create_common_user_role_proc(p_errcode, p_errbuf, p_application_user_id, p_user_name);

    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(main)';
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
    END;

    PROCEDURE organization_receieve_proc(p_errcode             OUT VARCHAR2
                                        ,p_errbuf              OUT VARCHAR2
                                        ,p_application_user_id IN NUMBER) IS

        v_user_id         NUMBER := -999; -- create_by, last_updated_by 에 이용
        v_subsidiary_id   NUMBER;
        v_subsidiary_name VARCHAR2(100);
        v_exist_flag      VARCHAR2(1);

        CURSOR c_org IS
            SELECT dept.eai_seq_id
                  ,dept.organization_id
                  ,dept.business_group_id
                  ,DECODE(SUBSTR(dept.organization_name, 1, 5), 'LGD K', 'LGDKR', SUBSTR(dept.organization_name, 1, 5)) subsidiary_name
                  ,dept.organization_code
                  ,SUBSTR(dept.organization_name
                         ,INSTR(dept.organization_name, '.') + 1
                         ,lengthb(dept.organization_name)) organization_name
                  ,TO_DATE(dept.start_date, 'YYYY-MM-DD') start_date
                  ,TO_DATE(dept.end_date, 'YYYY-MM-DD') end_date
                  ,dept.organization_manager
                  ,dept.organization_level_code
                  ,dept.organization_level_name
                  ,dept.division_code
                  ,dept.division_name
                  ,dept.en_organization_name
                  ,dept.parent_organization_code
                  ,dept.nationality
                  ,dept.organization_location_id
                  ,dept.organization_location
                  ,dept.org_h1_code
                  ,dept.org_h1_kr_name
                  ,dept.org_h1_en_name
                  ,dept.org_h2_code
                  ,dept.org_h2_kr_name
                  ,dept.org_h2_en_name
                  ,dept.org_h3_code
                  ,dept.org_h3_kr_name
                  ,dept.org_h3_en_name
                  ,dept.org_h4_code
                  ,dept.org_h4_kr_name
                  ,dept.org_h4_en_name
                  ,dept.org_h5_code
                  ,dept.org_h5_kr_name
                  ,dept.org_h5_en_name
                  ,dept.organization_flag
                  ,dept.last_organization_flag
                  ,dept.org_group_code
                  ,dept.org_group_name
                  ,dept.org_master_history_id
                  ,dept.pre_organization_code
                  ,dept.pre_organization_name
            FROM   tb_ifr_ehr_department_i dept
            WHERE  dept.application_transfer_flag = 'N'
            ORDER  BY dept.eai_seq_id;

    BEGIN

        FOR c_rec IN c_org
        LOOP

            v_subsidiary_id   := NULL;
            v_subsidiary_name := NULL;

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            ELSE
                v_user_id := -1;
            END IF;

            -- LGDSG --> LGDSP, LGDVH --> LGDVN 으로 code_data3_value에 매핑함.
            BEGIN
                SELECT to_number(a.common_code) subsidiary_id
                      ,a.common_code_desc
                INTO   v_subsidiary_id
                      ,v_subsidiary_name
                FROM   lgcom_common_code_c a
                WHERE  a.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                AND    a.code_data3_value = c_rec.subsidiary_name;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    p_errcode := SQLCODE;
                    p_errbuf  := 'subsidiary_id NO_DATA_FOUND business_group_id :=' || TO_CHAR(c_rec.business_group_id) || ',' ||
                                 'subsidiary_name := ' || c_rec.subsidiary_name;

                    dbms_output.put_line(p_errbuf);

                    g_step := 'Other Exception Error(Organization_receieve_proc Subsidiary_id Select Error)';
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_parameter('business_group_id', c_rec.business_group_id);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

            END;

            v_exist_flag := 'N';
            BEGIN
                SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                INTO   v_exist_flag
                FROM   lgcom_organization_m lom
                WHERE  lom.organization_code = c_rec.organization_code;
            EXCEPTION
                WHEN OTHERS THEN
                    v_exist_flag := 'N';
            END;

            IF v_subsidiary_id IS NOT NULL THEN
                IF v_exist_flag = 'N' THEN
                    BEGIN
                        INSERT INTO lgcom_organization_m
                            (organization_id
                            ,business_group_id
                            ,subsidiary_id
                            ,corporation_name
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
                            (c_rec.organization_id --organization_id
                            ,c_rec.business_group_id --business_group_id
                            ,v_subsidiary_id
                            ,v_subsidiary_name --corporation_name
                            ,c_rec.organization_code --organization_code
                            ,c_rec.organization_name --organization_name
                            ,c_rec.start_date --start_date
                            ,c_rec.end_date --end_date
                            ,c_rec.organization_manager --organization_manager_emp_no
                            ,c_rec.organization_level_code --organization_level_code
                            ,c_rec.organization_level_name --organization_level_name
                            ,c_rec.division_code --division_code
                            ,c_rec.division_name --division_name
                            ,c_rec.en_organization_name --organization_eng_name
                            ,c_rec.parent_organization_code --parent_organization_code
                            ,c_rec.nationality --nationality_name
                            ,c_rec.organization_location_id --organization_location_id
                            ,c_rec.organization_location --organization_location_name
                            ,c_rec.org_h1_code --hierarchy1_org_code
                            ,c_rec.org_h1_kr_name --hierarchy1_org_name
                            ,c_rec.org_h1_en_name --hierarchy1_english_org_name
                            ,c_rec.org_h2_code --hierarchy2_org_code
                            ,c_rec.org_h2_kr_name --hierarchy2_org_name
                            ,c_rec.org_h2_en_name --hierarchy2_english_org_name
                            ,c_rec.org_h3_code --hierarchy3_org_code
                            ,c_rec.org_h3_kr_name --hierarchy3_org_name
                            ,c_rec.org_h3_en_name --hierarchy3_english_org_name
                            ,c_rec.org_h4_code --hierarchy4_org_code
                            ,c_rec.org_h4_kr_name --hierarchy4_org_name
                            ,c_rec.org_h4_en_name --hierarchy4_english_org_name
                            ,c_rec.org_h5_code --hierarchy5_organization_code
                            ,c_rec.org_h5_kr_name --hierarchy5_organization_name
                            ,c_rec.org_h5_en_name --hierarchy5_english_org_name
                            ,c_rec.organization_flag --organization_flag
                            ,c_rec.last_organization_flag --last_organization_flag
                            ,c_rec.org_group_code --organization_group_code
                            ,c_rec.org_group_name --organization_group_name
                            ,c_rec.org_master_history_id --org_master_history_id
                            ,c_rec.pre_organization_code --pre_organization_code
                            ,c_rec.pre_organization_name --pre_organization_name
                            ,v_user_id --created_by
                            ,SYSDATE --creation_date
                            ,v_user_id --last_updated_by
                            ,SYSDATE --last_update_date
                             );

                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.organization_code || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(Organization_receieve_proc Insert Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('organization_code', c_rec.organization_code);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                    END;

                ELSE
                    BEGIN
                        UPDATE lgcom_organization_m lom
                        SET    business_group_id            = c_rec.business_group_id
                              ,subsidiary_id                = v_subsidiary_id
                              ,corporation_name             = v_subsidiary_name
                              ,organization_code            = c_rec.organization_code
                              ,organization_name            = c_rec.organization_name
                              ,start_date                   = c_rec.start_date
                              ,end_date                     = c_rec.end_date
                              ,organization_manager_emp_no  = c_rec.organization_manager
                              ,organization_level_code      = c_rec.organization_level_code
                              ,organization_level_name      = c_rec.organization_level_name
                              ,division_code                = c_rec.division_code
                              ,division_name                = c_rec.division_name
                              ,organization_eng_name        = c_rec.en_organization_name
                              ,parent_organization_code     = c_rec.parent_organization_code
                              ,nationality_name             = c_rec.nationality
                              ,organization_location_id     = c_rec.organization_location_id
                              ,organization_location_name   = c_rec.organization_location
                              ,hierarchy1_org_code          = c_rec.org_h1_code
                              ,hierarchy1_org_name          = c_rec.org_h1_kr_name
                              ,hierarchy1_english_org_name  = c_rec.org_h1_en_name
                              ,hierarchy2_org_code          = c_rec.org_h2_code
                              ,hierarchy2_org_name          = c_rec.org_h2_kr_name
                              ,hierarchy2_english_org_name  = c_rec.org_h2_en_name
                              ,hierarchy3_org_code          = c_rec.org_h3_code
                              ,hierarchy3_org_name          = c_rec.org_h3_kr_name
                              ,hierarchy3_english_org_name  = c_rec.org_h3_en_name
                              ,hierarchy4_org_code          = c_rec.org_h4_code
                              ,hierarchy4_org_name          = c_rec.org_h4_kr_name
                              ,hierarchy4_english_org_name  = c_rec.org_h4_en_name
                              ,hierarchy5_organization_code = c_rec.org_h5_code
                              ,hierarchy5_organization_name = c_rec.org_h5_kr_name
                              ,hierarchy5_english_org_name  = c_rec.org_h5_en_name
                              ,organization_flag            = c_rec.organization_flag
                              ,last_organization_flag       = c_rec.last_organization_flag
                              ,organization_group_code      = c_rec.org_group_code
                              ,organization_group_name      = c_rec.org_group_name
                              ,org_master_history_id        = c_rec.org_master_history_id
                              ,pre_organization_code        = c_rec.pre_organization_code
                              ,pre_organization_name        = c_rec.pre_organization_name
                              ,last_updated_by              = v_user_id
                              ,last_update_date             = SYSDATE
                        WHERE  lom.organization_id = c_rec.organization_id;
                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.organization_code || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(Organization_receieve_proc Update Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('organization_code', c_rec.organization_code);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                    END;

                END IF;

                BEGIN
                    UPDATE tb_ifr_ehr_department_i ti
                    SET    ti.application_transfer_flag = 'Y'
                          ,ti.application_transfer_date = SYSDATE
                    WHERE  ti.application_transfer_flag = 'N'
                    AND    ti.eai_seq_id = c_rec.eai_seq_id;
                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        p_errcode := SQLCODE;
                        p_errbuf  := c_rec.organization_code || ' ' || SQLERRM;

                        g_step := 'Other Exception Error(Organization_receieve_proc Update Error)';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_parameter('organization_code', c_rec.organization_code);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                END;
            ELSE

                BEGIN
                    UPDATE tb_ifr_ehr_department_i ti
                    SET    ti.application_transfer_flag = 'E'
                          ,ti.application_transfer_date = SYSDATE
                    WHERE  ti.application_transfer_flag = 'N'
                    AND    ti.eai_seq_id = c_rec.eai_seq_id;
                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        p_errcode := SQLCODE;
                        p_errbuf  := c_rec.organization_code || ' ' || SQLERRM;

                        g_step := 'Other Exception Error(Organization_receieve_proc Update Error)';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_parameter('organization_code', c_rec.organization_code);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                END;

            END IF;

        END LOOP;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            g_step    := 'All Other Exception Error(department_receieve_proc)';
            p_errcode := SQLCODE;
            p_errbuf  := SQLERRM;
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
    END organization_receieve_proc;

    PROCEDURE regular_emp_receieve_proc(p_errcode             OUT VARCHAR2
                                       ,p_errbuf              OUT VARCHAR2
                                       ,p_application_user_id IN NUMBER) IS

        v_user_id         NUMBER := -999; -- create_by, last_updated_by 에 이용
        v_subsidiary_id   NUMBER;
        v_subsidiary_name VARCHAR2(100);
        v_exist_flag      VARCHAR2(1);

        CURSOR regular_emp IS
            SELECT emp.eai_seq_id
                  ,emp.data_interface_type_code
                  ,emp.eai_interface_date
                  ,emp.application_transfer_flag
                  ,emp.application_transfer_date
                  ,emp.business_group_id
                  ,DECODE(emp.organization_name, 'LGD Korea Group', 'LGDKR', SUBSTR(emp.organization_name, 1, 5)) subsidiary_name
                  ,emp.person_id
                  ,emp.employee_no
                  ,emp.local_full_name
                  ,emp.en_full_name
                  ,emp.cn_full_name
                  ,emp.birth_yyyymmdd
                  ,emp.solar_lunar_flag
                  ,emp.martial_status_type_name
                  ,emp.wedding_anniversary_date
                  ,emp.email_addr
                  ,emp.retire_flag
                  ,emp.organization_code
                  ,SUBSTR(emp.organization_name, INSTR(emp.organization_name, '.') + 1) organization_name
                  ,SUBSTR(emp.organization_name_en, INSTR(emp.organization_name_en, '.') + 1) organization_name_en
                  ,emp.organization_level_code
                  ,emp.organization_level_name
                  ,emp.job_title_code
                  ,emp.job_title_name
                  ,emp.position_code
                  ,emp.position_name
                  ,emp.location_name
                  ,emp.lg_hire_yyyymmdd
                  ,emp.hire_yyyymmdd
                  ,emp.absense_yyyymmdd
                  ,emp.resignation_yyyymmdd
                  ,emp.reinstatement_yyyymmdd
                  ,emp.office_phone_no
                  ,emp.mobile_no
                  ,emp.fax_no
                  ,emp.grade_type_name
                  ,emp.work_type_name
                  ,emp.status_desc
                  ,emp.last_update_date
                  ,emp.parent_organization_code
                  ,emp.parent_organization_name
                  ,emp.user_id
                  ,emp.job_series_name
                  ,emp.part_leader_flag
                  ,emp.person_location_name
                  ,emp.org_location_name
                  ,emp.super_employee_no
                  ,emp.executive_flag
                  ,emp.recent_org_update_yyyymmdd
                  ,emp.job_title_flag
                  ,emp.real_part_leader_flag
                  ,emp.detail_job1_desc
                  ,emp.fse_flag
                  ,emp.scheduled_resignation_yyyymmdd
                  ,emp.job_start_yyyymmdd
                  ,emp.dangan_flag
                  ,emp.dangan_location_code
                  ,emp.dangan_start_date
                  ,emp.hokou_code
                  ,emp.email_use_flag
                  ,emp.job_title_name_en
                  ,emp.organization_id
                  ,emp.person_location_id
                  ,emp.grade_id
                  ,emp.kor_full_name
                  ,emp.detail_job2_desc
                  ,emp.job_family_name
                  ,emp.job_group_name
                  ,emp.job_name
                  ,emp.job_id
                  ,emp.kor_fse_flag
                  ,emp.work_type_code
                  ,emp.create_date
                  ,emp.grade_seniority
                  ,emp.ko_language_use_flag
                  ,emp.super1_person_id
                  ,emp.super2_person_id
                  ,emp.person_type_name
                  ,emp.ou_id
            FROM   tb_ifr_ehr_r_employee_i emp
            WHERE  emp.application_transfer_flag = 'N'
            ORDER  BY emp.eai_seq_id;

    BEGIN

        --임직원 데이타 본테이블에 적용
        --tb_ifr_ehr_r_employee_i -> lgcom_ehr_r_employee
        FOR c_rec IN regular_emp
        LOOP

            v_subsidiary_id   := NULL;
            v_subsidiary_name := NULL;

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            ELSE
                v_user_id := -1;
            END IF;

            BEGIN
                SELECT to_number(a.common_code) subsidiary_id
                      ,a.common_code_desc
                INTO   v_subsidiary_id
                      ,v_subsidiary_name
                FROM   lgcom_common_code_c a
                WHERE  a.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                AND    a.code_data3_value = c_rec.subsidiary_name;
            EXCEPTION
                WHEN OTHERS THEN
                    v_subsidiary_id   := NULL;
                    v_subsidiary_name := c_rec.subsidiary_name;
            END;

            v_exist_flag := 'N';
            BEGIN
                SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                INTO   v_exist_flag
                FROM   lgcom_ehr_r_employee t
                WHERE  t.person_id = c_rec.person_id;
            EXCEPTION
                WHEN OTHERS THEN
                    v_exist_flag := 'N';
            END;

            IF c_rec.data_interface_type_code <> 'D' THEN
                IF v_subsidiary_id IS NOT NULL THEN
                    IF v_exist_flag = 'N' THEN
                        BEGIN
                            INSERT INTO lgcom_ehr_r_employee
                                (business_group_id
                                ,subsidiary_id
                                ,subsidiary_name
                                ,person_id
                                ,employee_no
                                ,local_full_name
                                ,en_full_name
                                ,cn_full_name
                                ,birth_yyyymmdd
                                ,solar_lunar_flag
                                ,martial_status_type_name
                                ,wedding_anniversary_date
                                ,email_addr
                                ,retire_flag
                                ,organization_id
                                ,organization_code
                                ,organization_name
                                ,organization_name_en
                                ,organization_level_code
                                ,organization_level_name
                                ,job_title_code
                                ,job_title_name
                                ,position_code
                                ,position_name
                                ,location_name
                                ,lg_hire_yyyymmdd
                                ,hire_yyyymmdd
                                ,absense_yyyymmdd
                                ,resignation_yyyymmdd
                                ,reinstatement_yyyymmdd
                                ,office_phone_no
                                ,mobile_no
                                ,fax_no
                                ,grade_type_name
                                ,work_type_name
                                ,status_desc
                                ,parent_organization_code
                                ,parent_organization_name
                                ,user_id
                                ,job_series_name
                                ,part_leader_flag
                                ,person_location_name
                                ,org_location_name
                                ,super_employee_no
                                ,executive_flag
                                ,recent_org_update_yyyymmdd
                                ,job_title_flag
                                ,real_part_leader_flag
                                ,detail_job1_desc
                                ,fse_flag
                                ,scheduled_resignation_yyyymmdd
                                ,job_start_yyyymmdd
                                ,dangan_flag
                                ,dangan_location_code
                                ,dangan_start_date
                                ,hokou_code
                                ,email_use_flag
                                ,job_title_name_en
                                ,person_location_id
                                ,grade_id
                                ,kor_full_name
                                ,detail_job2_desc
                                ,job_family_name
                                ,job_group_name
                                ,job_name
                                ,job_id
                                ,kor_fse_flag
                                ,work_type_code
                                ,create_date
                                ,grade_seniority
                                ,ko_language_use_flag
                                ,super1_person_id
                                ,super2_person_id
                                ,person_type_name
                                ,ou_id
                                ,created_by
                                ,creation_date
                                ,last_updated_by
                                ,last_update_date)
                            VALUES
                                (c_rec.business_group_id
                                ,v_subsidiary_id
                                ,v_subsidiary_name
                                ,c_rec.person_id
                                ,c_rec.employee_no
                                ,c_rec.local_full_name
                                ,c_rec.en_full_name
                                ,c_rec.cn_full_name
                                ,c_rec.birth_yyyymmdd
                                ,c_rec.solar_lunar_flag
                                ,c_rec.martial_status_type_name
                                ,c_rec.wedding_anniversary_date
                                ,c_rec.email_addr
                                ,c_rec.retire_flag
                                ,c_rec.organization_id
                                ,c_rec.organization_code
                                ,c_rec.organization_name
                                ,c_rec.organization_name_en
                                ,c_rec.organization_level_code
                                ,c_rec.organization_level_name
                                ,c_rec.job_title_code
                                ,c_rec.job_title_name
                                ,c_rec.position_code
                                ,c_rec.position_name
                                ,c_rec.location_name
                                ,c_rec.lg_hire_yyyymmdd
                                ,c_rec.hire_yyyymmdd
                                ,c_rec.absense_yyyymmdd
                                ,c_rec.resignation_yyyymmdd
                                ,c_rec.reinstatement_yyyymmdd
                                ,c_rec.office_phone_no
                                ,c_rec.mobile_no
                                ,c_rec.fax_no
                                ,c_rec.grade_type_name
                                ,c_rec.work_type_name
                                ,c_rec.status_desc
                                ,
                                 --c_rec.last_update_date             ,
                                 c_rec.parent_organization_code
                                ,c_rec.parent_organization_name
                                ,c_rec.user_id
                                ,c_rec.job_series_name
                                ,c_rec.part_leader_flag
                                ,c_rec.person_location_name
                                ,c_rec.org_location_name
                                ,c_rec.super_employee_no
                                ,c_rec.executive_flag
                                ,c_rec.recent_org_update_yyyymmdd
                                ,c_rec.job_title_flag
                                ,c_rec.real_part_leader_flag
                                ,c_rec.detail_job1_desc
                                ,c_rec.fse_flag
                                ,c_rec.scheduled_resignation_yyyymmdd
                                ,c_rec.job_start_yyyymmdd
                                ,c_rec.dangan_flag
                                ,c_rec.dangan_location_code
                                ,c_rec.dangan_start_date
                                ,c_rec.hokou_code
                                ,c_rec.email_use_flag
                                ,c_rec.job_title_name_en
                                ,c_rec.person_location_id
                                ,c_rec.grade_id
                                ,c_rec.kor_full_name
                                ,c_rec.detail_job2_desc
                                ,c_rec.job_family_name
                                ,c_rec.job_group_name
                                ,c_rec.job_name
                                ,c_rec.job_id
                                ,c_rec.kor_fse_flag
                                ,c_rec.work_type_code
                                ,c_rec.create_date
                                ,c_rec.grade_seniority
                                ,c_rec.ko_language_use_flag
                                ,c_rec.super1_person_id
                                ,c_rec.super2_person_id
                                ,c_rec.person_type_name
                                ,c_rec.ou_id
                                ,v_user_id
                                ,SYSDATE
                                ,v_user_id
                                ,SYSDATE);
                            COMMIT;
                        EXCEPTION
                            WHEN OTHERS THEN
                                ROLLBACK;
                                p_errcode := SQLCODE;
                                p_errbuf  := c_rec.employee_no || ' ' || SQLERRM;

                                g_step := 'Other Exception Error(regular_emp_receieve_proc Insert Error)';
                                lgcom_error_log_pkg.set_comment_text(g_step);
                                lgcom_error_log_pkg.set_error_code(p_errcode);
                                lgcom_error_log_pkg.set_parameter('employee_no', c_rec.employee_no);
                                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                                lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                        END;
                    ELSE
                        --if c_rec.exist_flag = 'N' then
                        BEGIN
                            UPDATE lgcom_ehr_r_employee ler
                            SET    business_group_id              = c_rec.business_group_id
                                  ,subsidiary_id                  = v_subsidiary_id
                                  ,subsidiary_name                = v_subsidiary_name
                                  ,employee_no                    = c_rec.employee_no
                                  ,local_full_name                = c_rec.local_full_name
                                  ,en_full_name                   = c_rec.en_full_name
                                  ,cn_full_name                   = c_rec.cn_full_name
                                  ,birth_yyyymmdd                 = c_rec.birth_yyyymmdd
                                  ,solar_lunar_flag               = c_rec.solar_lunar_flag
                                  ,martial_status_type_name       = c_rec.martial_status_type_name
                                  ,wedding_anniversary_date       = c_rec.wedding_anniversary_date
                                  ,email_addr                     = c_rec.email_addr
                                  ,retire_flag                    = c_rec.retire_flag
                                  ,organization_id                = c_rec.organization_id
                                  ,organization_code              = c_rec.organization_code
                                  ,organization_name              = c_rec.organization_name
                                  ,organization_name_en           = c_rec.organization_name_en
                                  ,organization_level_code        = c_rec.organization_level_code
                                  ,organization_level_name        = c_rec.organization_level_name
                                  ,job_title_code                 = c_rec.job_title_code
                                  ,job_title_name                 = c_rec.job_title_name
                                  ,position_code                  = c_rec.position_code
                                  ,position_name                  = c_rec.position_name
                                  ,location_name                  = c_rec.location_name
                                  ,lg_hire_yyyymmdd               = c_rec.lg_hire_yyyymmdd
                                  ,hire_yyyymmdd                  = c_rec.hire_yyyymmdd
                                  ,absense_yyyymmdd               = c_rec.absense_yyyymmdd
                                  ,resignation_yyyymmdd           = c_rec.resignation_yyyymmdd
                                  ,reinstatement_yyyymmdd         = c_rec.reinstatement_yyyymmdd
                                  ,office_phone_no                = c_rec.office_phone_no
                                  ,mobile_no                      = c_rec.mobile_no
                                  ,fax_no                         = c_rec.fax_no
                                  ,grade_type_name                = c_rec.grade_type_name
                                  ,work_type_name                 = c_rec.work_type_name
                                  ,status_desc                    = c_rec.status_desc
                                  ,parent_organization_code       = c_rec.parent_organization_code
                                  ,parent_organization_name       = c_rec.parent_organization_name
                                  ,user_id                        = c_rec.user_id
                                  ,job_series_name                = c_rec.job_series_name
                                  ,part_leader_flag               = c_rec.part_leader_flag
                                  ,person_location_name           = c_rec.person_location_name
                                  ,org_location_name              = c_rec.org_location_name
                                  ,super_employee_no              = c_rec.super_employee_no
                                  ,executive_flag                 = c_rec.executive_flag
                                  ,recent_org_update_yyyymmdd     = c_rec.recent_org_update_yyyymmdd
                                  ,job_title_flag                 = c_rec.job_title_flag
                                  ,real_part_leader_flag          = c_rec.real_part_leader_flag
                                  ,detail_job1_desc               = c_rec.detail_job1_desc
                                  ,fse_flag                       = c_rec.fse_flag
                                  ,scheduled_resignation_yyyymmdd = c_rec.scheduled_resignation_yyyymmdd
                                  ,job_start_yyyymmdd             = c_rec.job_start_yyyymmdd
                                  ,dangan_flag                    = c_rec.dangan_flag
                                  ,dangan_location_code           = c_rec.dangan_location_code
                                  ,dangan_start_date              = c_rec.dangan_start_date
                                  ,hokou_code                     = c_rec.hokou_code
                                  ,email_use_flag                 = c_rec.email_use_flag
                                  ,job_title_name_en              = c_rec.job_title_name_en
                                  ,person_location_id             = c_rec.person_location_id
                                  ,grade_id                       = c_rec.grade_id
                                  ,kor_full_name                  = c_rec.kor_full_name
                                  ,detail_job2_desc               = c_rec.detail_job2_desc
                                  ,job_family_name                = c_rec.job_family_name
                                  ,job_group_name                 = c_rec.job_group_name
                                  ,job_name                       = c_rec.job_name
                                  ,job_id                         = c_rec.job_id
                                  ,kor_fse_flag                   = c_rec.kor_fse_flag
                                  ,work_type_code                 = c_rec.work_type_code
                                  ,create_date                    = c_rec.create_date
                                  ,grade_seniority                = c_rec.grade_seniority
                                  ,ko_language_use_flag           = c_rec.ko_language_use_flag
                                  ,super1_person_id               = c_rec.super1_person_id
                                  ,super2_person_id               = c_rec.super2_person_id
                                  ,person_type_name               = c_rec.person_type_name
                                  ,ou_id                          = c_rec.ou_id
                                  ,last_updated_by                = v_user_id
                                  ,last_update_date               = SYSDATE
                            WHERE  ler.person_id = c_rec.person_id;
                            COMMIT;
                        EXCEPTION
                            WHEN OTHERS THEN
                                ROLLBACK;
                                p_errcode := SQLCODE;
                                p_errbuf  := c_rec.employee_no || ' ' || SQLERRM;

                                g_step := 'Other Exception Error(regular_emp_receieve_proc Insert Error)';
                                lgcom_error_log_pkg.set_comment_text(g_step);
                                lgcom_error_log_pkg.set_error_code(p_errcode);
                                lgcom_error_log_pkg.set_parameter('employee_no', c_rec.employee_no);
                                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                                lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                        END;
                    END IF; --if c_rec.exist_flag = 'N' then

                    BEGIN
                        UPDATE tb_ifr_ehr_r_employee_i emp
                        SET    emp.application_transfer_flag = 'Y'
                              ,emp.application_transfer_date = SYSDATE
                        WHERE  emp.application_transfer_flag = 'N'
                        AND    emp.eai_seq_id = c_rec.eai_seq_id;
                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.employee_no || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(regular_emp_receieve_proc Insert Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('employee_no', c_rec.employee_no);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                    END;
                ELSE
                    -- subsidiary_id가 없으면
                    BEGIN
                        UPDATE tb_ifr_ehr_r_employee_i emp
                        SET    emp.application_transfer_flag = 'E'
                              ,emp.application_transfer_date = SYSDATE
                        WHERE  emp.application_transfer_flag = 'N'
                        AND    emp.eai_seq_id = c_rec.eai_seq_id;
                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.employee_no || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(regular_emp_receieve_proc Insert Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('employee_no', c_rec.employee_no);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                    END;
                END IF; --if v_subsidiary_id is not null then
            ELSE
                -- IF c_rec.data_interface_type_code <> 'D' THEN
                -- 삭제
                BEGIN
                    DELETE lgcom_ehr_r_employee emp
                    WHERE  emp.person_id = c_rec.person_id;

                    DELETE lgcom_user_m lum
                    WHERE  lum.employee_id = c_rec.person_id;

                    UPDATE tb_ifr_ehr_r_employee_i emp
                    SET    emp.application_transfer_flag = 'Y'
                          ,emp.application_transfer_date = SYSDATE
                    WHERE  emp.application_transfer_flag = 'N'
                    AND    emp.eai_seq_id = c_rec.eai_seq_id;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        p_errcode := SQLCODE;
                        p_errbuf  := c_rec.employee_no || ' ' || SQLERRM;

                        g_step := 'Other Exception Error(regular_emp_receieve_proc Delete Error)';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_parameter('employee_no', c_rec.employee_no);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                END;
            END IF;

        END LOOP;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_errcode := SQLCODE;
            p_errbuf  := SQLERRM;
            g_step    := 'All Other Exception Error(regular_emp_receieve_proc)';
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            ROLLBACK;

    END regular_emp_receieve_proc;

    PROCEDURE partner_emp_receieve_proc(p_errcode             OUT VARCHAR2
                                       ,p_errbuf              OUT VARCHAR2
                                       ,p_application_user_id IN NUMBER) IS

        v_user_id                 NUMBER := -999; -- create_by, last_updated_by 에 이용
        v_organization_id         NUMBER;
        v_business_group_id       NUMBER;
        v_subsidiary_id           NUMBER;
        v_subsidiary_name         VARCHAR2(100);
        v_organization_eng_name   VARCHAR2(240);
        v_organization_level_code VARCHAR2(15);
        v_organization_level_name VARCHAR2(240);
        v_ou_id                   NUMBER;
        v_exist_flag              VARCHAR2(1);

        v_pnr_emp_cd VARCHAR2(100);

        v_work_start_dt VARCHAR2(10);
        v_work_end_dt   VARCHAR2(10);

        CURSOR partner_emp IS
            SELECT emp.eai_seq_id
                  ,emp.data_interface_type_code
                  ,emp.pnr_emp_cd --사번
                  ,emp.emp_kor_nm --한글성명
                  ,emp.emp_eng_nm --영문성명
                  ,emp.pnr_cd --업체번호
                  ,emp.pnr_cd_nm -- 업체명
                  ,emp.position_cd --직위코드
                  ,emp.position_cd_nm --직위명
                  ,emp.email --e-mail
                  ,emp.work_start_dt work_start_dt --근무시작일자
                  ,emp.work_end_dt work_end_dt --근무종료일자
                  ,CASE
                       WHEN emp.work_gb = 'F' THEN
                        'C' --근무중
                       ELSE
                        'T' --철수
                   END retire_flag
                  ,emp.work_dept_cd --근무부서
                   --,emp.work_dept_cd_nm --근무부서명
                  ,SUBSTR(emp.work_dept_cd_nm, INSTR(emp.work_dept_cd_nm, '.') + 1) work_dept_cd_nm --근무부서명
                  ,SUBSTR(emp.work_dept_cd_nm, 1, 5) subsidiary_name
                  ,emp.phone --사무실전화번호
                  ,emp.mobile --핸드폰전화번호
            FROM   tb_intf_partner_user_r_i emp
            WHERE  emp.application_transfer_flag = 'N'
            ORDER  BY emp.eai_seq_id;

    BEGIN

        --협력사 데이타 본테이블에 적용
        --tb_ifr_ehr_r_employee_i -> lgcom_ehr_r_employee
        FOR c_rec IN partner_emp
        LOOP

            v_organization_id         := NULL;
            v_business_group_id       := NULL;
            v_subsidiary_id           := NULL;
            v_subsidiary_name         := NULL;
            v_organization_eng_name   := NULL;
            v_organization_level_code := NULL;
            v_organization_level_name := NULL;

            v_pnr_emp_cd := c_rec.pnr_emp_cd;

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            ELSE
                v_user_id := -1;
            END IF;

            BEGIN
                SELECT lom.organization_id
                       -- ,lom.business_group_id
                      ,lom.organization_eng_name
                      ,lom.organization_level_code
                      ,lom.organization_level_name
                INTO   v_organization_id
                       --,v_business_group_id
                      ,v_organization_eng_name
                      ,v_organization_level_code
                      ,v_organization_level_name
                FROM   lgcom_organization_m lom
                WHERE  lom.organization_code = c_rec.work_dept_cd;
            EXCEPTION
                WHEN OTHERS THEN
                    v_organization_id := NULL;
                    --v_business_group_id         := NULL;
                    v_organization_eng_name   := NULL;
                    v_organization_level_code := NULL;
                    v_organization_level_name := NULL;
            END;

            BEGIN
                SELECT to_number(a.common_code) subsidiary_id
                      ,a.common_code_desc
                INTO   v_subsidiary_id
                      ,v_subsidiary_name
                FROM   lgcom_common_code_c a
                WHERE  a.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                AND    a.code_data3_value = c_rec.subsidiary_name; --'LGDKR'
            EXCEPTION
                WHEN OTHERS THEN
                    v_subsidiary_id   := 81;
                    v_subsidiary_name := 'LGDKR';
            END;

            BEGIN
                SELECT lcv.organization_id AS ou_id
                      ,lcv.business_group_id
                INTO   v_ou_id
                      ,v_business_group_id
                FROM   lgcom_company_v lcv
                WHERE  lcv.short_code = v_subsidiary_name;
            EXCEPTION
                WHEN OTHERS THEN
                    v_ou_id             := 89; --NOT NULL항목이라 Default값을 사용함.
                    v_business_group_id := 81; --NOT NULL항목이라 Default값을 사용함.
            END;

            BEGIN
                SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                INTO   v_exist_flag
                FROM   lgcom_ehr_r_employee t
                WHERE  t.employee_no = c_rec.pnr_emp_cd;
            EXCEPTION
                WHEN OTHERS THEN
                    v_exist_flag := 'N';
            END;

            IF length(c_rec.work_start_dt) <> 8 OR
               length(c_rec.work_end_dt) <> 8 THEN
                BEGIN
                    g_step := 'partner_emp_receieve_proc(date length error)';
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                    lgcom_error_log_pkg.set_parameter('work_start_dt', c_rec.work_start_dt);
                    lgcom_error_log_pkg.set_parameter('work_end_dt', c_rec.work_end_dt);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                END;
            END IF;

            BEGIN
                SELECT TO_CHAR(TO_DATE(c_rec.work_start_dt, 'YYYYMMDD'), 'YYYY/MM/DD')
                      ,TO_CHAR(TO_DATE(c_rec.work_end_dt, 'YYYYMMDD'), 'YYYY/MM/DD')
                INTO   v_work_start_dt
                      ,v_work_end_dt
                FROM   dual;
            EXCEPTION
                WHEN OTHERS THEN
                    g_step := 'partner_emp_receieve_proc(date change error)';
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                    lgcom_error_log_pkg.set_parameter('work_start_dt', c_rec.work_start_dt);
                    lgcom_error_log_pkg.set_parameter('work_end_dt', c_rec.work_end_dt);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

            END;
            IF c_rec.data_interface_type_code <> 'D' THEN
                IF v_subsidiary_id IS NOT NULL THEN
                    IF v_exist_flag = 'N' THEN

                        BEGIN
                            INSERT INTO lgcom_ehr_r_employee
                                (business_group_id --business_group_id
                                ,subsidiary_id
                                ,subsidiary_name --법인명
                                ,person_id --person_id
                                ,employee_no --사번
                                ,local_full_name --로컬성명
                                ,en_full_name --영문성명
                                ,email_addr --e-mail
                                ,retire_flag --휴퇴구분
                                ,organization_id --조직id
                                ,organization_code --조직코드
                                ,organization_name --조직명
                                ,organization_name_en --영문조직명
                                ,organization_level_code --조직레벨코드
                                ,organization_level_name --조직레벨명
                                ,job_title_code
                                ,job_title_name
                                ,lg_hire_yyyymmdd --그룹입사일
                                ,hire_yyyymmdd --lgd입사일
                                ,resignation_yyyymmdd --퇴직일자
                                ,office_phone_no --사무실전화번호
                                ,mobile_no --핸드폰전화번호
                                ,kor_full_name --한글성명
                                ,person_type_name --person_type명
                                ,ou_id --operating_unit_id
                                ,created_by
                                ,creation_date
                                ,last_updated_by
                                ,last_update_date)
                            VALUES
                                (v_business_group_id --business_group_id
                                ,v_subsidiary_id
                                ,v_subsidiary_name --법인명
                                ,lgcom_ehr_r_employee_seq.nextval -- ,person_id
                                ,c_rec.pnr_emp_cd --사번
                                ,c_rec.emp_kor_nm --한글성명
                                ,c_rec.emp_eng_nm --영문성명
                                ,c_rec.email --e-mail
                                ,c_rec.retire_flag --휴퇴구분
                                ,v_organization_id --조직id
                                ,c_rec.work_dept_cd --근무부서
                                ,c_rec.work_dept_cd_nm --근무부서명
                                ,v_organization_eng_name --영문조직명
                                ,v_organization_level_code --조직레벨코드
                                ,v_organization_level_name --조직레벨명
                                ,c_rec.position_cd --직위코드
                                ,c_rec.position_cd_nm --직위명
                                ,v_work_start_dt --그룹입사일
                                ,v_work_start_dt --근무시작일자
                                ,v_work_end_dt --근무종료일자
                                ,c_rec.phone --사무실전화번호
                                ,c_rec.mobile --핸드폰전화번호
                                ,c_rec.emp_kor_nm --한글성명
                                ,'Partner' --person_type명
                                ,v_ou_id
                                ,v_user_id
                                ,SYSDATE
                                ,v_user_id
                                ,SYSDATE);
                            COMMIT;
                        EXCEPTION
                            WHEN OTHERS THEN
                                ROLLBACK;
                                p_errcode := SQLCODE;
                                p_errbuf  := c_rec.pnr_emp_cd || ' ' || SQLERRM;

                                g_step := 'Other Exception Error(partner_emp_receieve_proc Insert Error)';
                                lgcom_error_log_pkg.set_comment_text(g_step);
                                lgcom_error_log_pkg.set_error_code(p_errcode);
                                lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                                lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                        END;
                    ELSE
                        --if c_rec.exist_flag = 'N' then
                        BEGIN
                            UPDATE lgcom_ehr_r_employee ler
                            SET    business_group_id       = v_business_group_id --business_group_id
                                  ,subsidiary_id           = v_subsidiary_id
                                  ,subsidiary_name         = v_subsidiary_name --법인명
                                  ,local_full_name         = c_rec.emp_kor_nm --한글성명
                                  ,en_full_name            = c_rec.emp_eng_nm --영문성명
                                  ,email_addr              = c_rec.email --e-mail
                                  ,retire_flag             = c_rec.retire_flag --휴퇴구분
                                  ,organization_id         = v_organization_id --조직id
                                  ,organization_code       = c_rec.work_dept_cd --근무부서
                                  ,organization_name       = c_rec.work_dept_cd_nm --근무부서명
                                  ,organization_name_en    = v_organization_eng_name --영문조직명
                                  ,organization_level_code = v_organization_level_code --조직레벨코드
                                  ,organization_level_name = v_organization_level_name --조직레벨명
                                  ,job_title_code          = c_rec.position_cd --직위코드
                                  ,job_title_name          = c_rec.position_cd_nm --직위명
                                  ,lg_hire_yyyymmdd        = c_rec.work_start_dt --근무시작일자
                                  ,hire_yyyymmdd           = c_rec.work_start_dt --근무시작일자
                                  ,resignation_yyyymmdd    = c_rec.work_end_dt --근무종료일자
                                  ,office_phone_no         = c_rec.phone --사무실전화번호
                                  ,mobile_no               = c_rec.mobile --핸드폰전화번호
                                  ,kor_full_name           = c_rec.emp_kor_nm --한글성명
                                  ,person_type_name        = 'Partner' --person_type명
                                  ,ou_id                   = v_ou_id
                                  ,last_updated_by         = v_user_id
                                  ,last_update_date        = SYSDATE
                            WHERE  ler.employee_no = c_rec.pnr_emp_cd;
                            COMMIT;
                        EXCEPTION
                            WHEN OTHERS THEN
                                ROLLBACK;
                                p_errcode := SQLCODE;
                                p_errbuf  := c_rec.pnr_emp_cd || ' ' || SQLERRM;

                                g_step := 'Other Exception Error(partner_emp_receieve_proc Insert Error)';
                                lgcom_error_log_pkg.set_comment_text(g_step);
                                lgcom_error_log_pkg.set_error_code(p_errcode);
                                lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                                lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                        END;
                    END IF;
                    BEGIN
                        UPDATE tb_intf_partner_user_r_i ti
                        SET    ti.application_transfer_flag = 'Y'
                              ,ti.application_transfer_date = SYSDATE
                        WHERE  ti.application_transfer_flag = 'N'
                        AND    ti.eai_seq_id = c_rec.eai_seq_id;
                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.pnr_emp_cd || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(partner_emp_receieve_proc Insert Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                    END;
                ELSE

                    BEGIN
                        UPDATE tb_intf_partner_user_r_i ti
                        SET    ti.application_transfer_flag = 'E'
                              ,ti.application_transfer_date = SYSDATE
                        WHERE  ti.application_transfer_flag = 'N'
                        AND    ti.eai_seq_id = c_rec.eai_seq_id;
                        COMMIT;
                    EXCEPTION
                        WHEN OTHERS THEN
                            ROLLBACK;
                            p_errcode := SQLCODE;
                            p_errbuf  := c_rec.pnr_emp_cd || ' ' || SQLERRM;

                            g_step := 'Other Exception Error(partner_emp_receieve_proc Insert Error)';
                            lgcom_error_log_pkg.set_comment_text(g_step);
                            lgcom_error_log_pkg.set_error_code(p_errcode);
                            lgcom_error_log_pkg.set_parameter('pnr_emp_cd', c_rec.pnr_emp_cd);
                            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                    END;
                END IF;
            ELSE
                --data_interface_type_code = 'D'일 경우
                -- IF c_rec.data_interface_type_code <> 'D' THEN
                -- 삭제
                BEGIN
                    DELETE lgcom_ehr_r_employee emp
                    WHERE  emp.employee_no = c_rec.pnr_emp_cd;

                    DELETE lgcom_user_m lum
                    WHERE  lum.user_name = c_rec.pnr_emp_cd;

                    UPDATE tb_ifr_ehr_r_employee_i emp
                    SET    emp.application_transfer_flag = 'Y'
                          ,emp.application_transfer_date = SYSDATE
                    WHERE  emp.application_transfer_flag = 'N'
                    AND    emp.eai_seq_id = c_rec.eai_seq_id;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        p_errcode := SQLCODE;
                        p_errbuf  := c_rec.pnr_emp_cd || ' ' || SQLERRM;

                        g_step := 'Other Exception Error(regular_emp_receieve_proc Delete Error)';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_parameter('employee_no', c_rec.pnr_emp_cd);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

                END;
            END IF;

        END LOOP;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            g_step    := 'All Other Exception Error(partner_emp_receieve_proc)';
            p_errcode := SQLCODE;
            p_errbuf  := SQLERRM;
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_parameter('pnr_emp_cd', v_pnr_emp_cd);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
    END partner_emp_receieve_proc;

    PROCEDURE insert_user_info_proc(p_errcode             OUT VARCHAR2
                                   ,p_errbuf              OUT VARCHAR2
                                   ,p_application_user_id IN NUMBER
                                   ,p_user_name           IN VARCHAR2) IS

        v_user_id                     NUMBER := -999; -- create_by, last_updated_by 에 이용
        v_request_region_code         VARCHAR2(100);
        v_default_org_id              NUMBER;
        v_server_time_difference_seqs NUMBER;

        v_language_code      lgcom_user_m.language_code%TYPE;
        v_timezone_type_code lgcom_user_m.timezone_code%TYPE;
        v_date_format_code   lgcom_user_m.date_format_code%TYPE;
        v_amount_unit_code   lgcom_user_m.amount_unit_code%TYPE;
        v_system_code        lgcom_user_m.system_code%TYPE;

        CURSOR user_info IS
            SELECT lgcom_user_m_seq.nextval AS application_user_id --시스템 내부에서 사용하는 user id
                  ,employee_no AS user_name -- 사번
                  ,TO_DATE(hire_yyyymmdd, 'YYYY/MM/DD') AS apply_start_date
                  ,TO_DATE(NVL(resignation_yyyymmdd, '2090/12/31'), 'YYYY/MM/DD') AS apply_end_date
                  ,person_id AS employee_id
                  ,email_addr AS mail_addr
                  ,'LGD' AS user_type_code
                  ,en_full_name AS english_full_name
                  ,local_full_name AS local_language_full_name
                  ,SUBSTR(job_title_name, 1, 30) AS grade_title_name
                  ,SUBSTR(organization_code, 1, 40) AS department_code
                  ,SUBSTR(organization_name, 1, 240) AS organization_name
                  ,organization_name_en AS english_organization_name
                  ,subsidiary_name AS corporation_name
                  ,DECODE(person_type_name, 'Employee', 'Y', 'N') AS regular_flag
                   --,'Y' AS regular_flag --TDR 포탈은 정규직 대상으로만 오픈함.
                  ,retire_flag AS resignation_flag
                  ,office_phone_no AS office_phone_no
                  ,mobile_no AS employee_mobile_phone_no
                  ,business_group_id AS business_group_id
                  ,subsidiary_id
                  ,access_password AS access_password
                  ,position_code AS position_code
                  ,position_name AS position_name
                  ,SUBSTR(email_addr, 1, INSTR(email_addr, '@') - 1) sso_id
            FROM   (SELECT ie.employee_no
                          ,ie.hire_yyyymmdd
                          ,ie.resignation_yyyymmdd
                          ,ie.person_id
                          ,ie.email_addr
                          ,ie.en_full_name
                          ,ie.local_full_name
                          ,ie.job_title_name
                          ,ie.organization_code
                          ,ie.organization_name
                          ,ie.organization_name_en
                          ,ie.office_phone_no
                          ,ie.mobile_no
                          ,ie.business_group_id
                          ,ie.subsidiary_id
                          ,ie.subsidiary_name
                          ,om.department_organization_name
                          ,ie.birth_yyyymmdd
                          ,ie.solar_lunar_flag
                          ,ie.martial_status_type_name
                          ,ie.wedding_anniversary_date
                          ,rawtohex(dbms_crypto.hash(to_clob(TO_CHAR(ie.employee_no)), 3)) AS access_password -- 사번 SHA1 Password
                          ,ie.position_code AS position_code
                          ,ie.position_name AS position_name
                          ,ie.person_type_name
                          ,ie.retire_flag
                    FROM   lgcom_ehr_r_employee ie --tb_ifr_ehr_r_employee_i ie
                          ,lgcom_organization_m om
                    WHERE  ie.organization_id = om.organization_id(+)
                    AND    ie.employee_no = NVL(p_user_name, ie.employee_no)
                          --AND    ie.create_date      >= trunc(sysdate)
                    AND    NOT EXISTS (SELECT 1
                            FROM   lgcom_user_m lum
                            WHERE  lum.user_name = ie.employee_no))
            WHERE  1 = 1;
        --ORDER  BY ie.eai_interface_date DESC

    BEGIN

        FOR cur_record IN user_info
        LOOP

            v_system_code := 'LGCOM';

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            END IF;

            BEGIN
                --Default값.
                IF cur_record.subsidiary_id = 81 THEN
                    v_language_code := 'ko';
                ELSE
                    v_language_code := 'en';
                END IF;

                SELECT lcc.common_code AS request_region_code
                       --,r.user_name     AS user_name
                      ,lcc.code_data2_value default_org_id
                       --,d.short_code AS default_org_code
                       --,d.name       AS default_org_name
                      ,(SELECT a.common_code
                        FROM   lgcom_common_code_c a
                        WHERE  a.code_type_code = 'LGCOM_TIMEZONE_TYPE_CODE'
                        AND    a.code_data1_value = lcc.code_data5_value
                        AND    ROWNUM = 1) timezone_code
                      ,to_number(lcc.code_data4_value) server_time_difference_seqs
                INTO   v_request_region_code
                      ,v_default_org_id
                      ,v_timezone_type_code
                      ,v_server_time_difference_seqs
                FROM   lgcom_common_code_c lcc
                      ,(SELECT subsidiary.short_code
                              ,DECODE(subsidiary.short_code, 'LGDCA', 'ZHC', subsidiary.region_code) region_code
                        FROM   (SELECT to_number(sub.common_code) subsidiary_id
                                      ,sub.common_code_desc short_code
                                      ,sub.code_data1_value region_code
                                FROM   lgcom_common_code_c sub
                                WHERE  sub.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                                AND    sub.use_flag = 'Y') subsidiary
                        WHERE  subsidiary_id = cur_record.subsidiary_id) r
                      ,(SELECT ou.code_data1_value short_code
                              ,ou.common_code_desc NAME
                              ,ou.common_code      ou_id
                        FROM   lgcom_common_code_c ou
                        WHERE  1 = 1
                        AND    ou.code_type_code = 'LGCOM_OU_INFO'
                        AND    ou.use_flag = 'Y') d
                WHERE  lcc.common_code = r.region_code
                AND    lcc.code_data2_value = d.ou_id
                AND    lcc.code_type_code = 'LGCOM_TIMEZONE_DEFAULT_COMPANY'
                AND    lcc.use_flag = 'Y'
                ORDER  BY lcc.sort_order_no;

                v_date_format_code := 'YYYY-MM-DD';
                v_amount_unit_code := ',.';
                --v_timezone_type_code := NULL;
            EXCEPTION
                WHEN OTHERS THEN
                    --Default값.
                    v_language_code       := 'ko';
                    v_date_format_code    := 'YYYY-MM-DD';
                    v_amount_unit_code    := ',.';
                    v_request_region_code := NULL;
                    v_timezone_type_code  := NULL;
            END;

            BEGIN
                INSERT INTO lgcom_user_m
                    (application_user_id
                    ,user_name
                    ,apply_start_date
                    ,apply_end_date
                    ,employee_id
                    ,mail_addr
                    ,language_code
                    ,timezone_code
                    ,date_format_code
                    ,amount_unit_code
                    ,system_code
                    ,request_region_code
                    ,request_region_code_use_flag
                    ,default_org_id
                    ,default_org_id_use_flag
                    ,server_time_difference_seqs
                    ,screen_design_theme_id
                    ,menu_use_flag
                    ,user_type_code
                    ,english_full_name
                    ,local_language_full_name
                    ,grade_title_name
                    ,department_code
                    ,organization_name
                    ,english_organization_name
                    ,corporation_name
                    ,regular_flag
                    ,resignation_flag
                    ,office_phone_no
                    ,employee_mobile_phone_no
                    ,access_password
                    ,position_code
                    ,position_name
                    ,subsidiary_id
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date)
                VALUES
                    (cur_record.application_user_id
                    ,cur_record.user_name
                    ,cur_record.apply_start_date
                    ,cur_record.apply_end_date
                    ,cur_record.employee_id
                    ,cur_record.mail_addr
                    ,v_language_code --language_code
                    ,v_timezone_type_code --timezone_code
                    ,v_date_format_code --date_format_code
                    ,v_amount_unit_code --amount_unit_code
                    ,v_system_code -- system_code
                    ,v_request_region_code --request_region_code
                    ,'Y' --request_region_code_use_flag
                    ,v_default_org_id --default_org_id
                    ,'N' --default_org_id_use_flag
                    ,v_server_time_difference_seqs --server_time_difference_seqs --한국 시간은 9
                    ,NULL --screen_design_theme_id
                    ,'N' --menu_use_flag는 Default N으로 넘어간다.
                    ,cur_record.user_type_code
                    ,cur_record.english_full_name
                    ,cur_record.local_language_full_name
                    ,cur_record.grade_title_name
                    ,cur_record.department_code
                    ,cur_record.organization_name
                    ,cur_record.english_organization_name
                    ,cur_record.corporation_name
                    ,cur_record.regular_flag
                    ,cur_record.resignation_flag
                    ,cur_record.office_phone_no
                    ,cur_record.employee_mobile_phone_no
                    ,cur_record.access_password
                    ,cur_record.position_code
                    ,cur_record.position_name
                    ,cur_record.subsidiary_id
                    ,v_user_id --created_by
                    ,SYSDATE --xxlge_mtz_pkg.local_date --creation_date
                    ,v_user_id --last_updated_by
                    ,SYSDATE --xxlge_mtz_pkg.local_date --last_update_date
                     );
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    g_step    := 'insert lgcom_user_m';
                    p_errcode := SQLCODE;
                    p_errbuf  := cur_record.user_name || ' ' || SQLERRM;

                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_parameter('user_name', cur_record.user_name);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);

            END;
        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            g_step    := 'All User Exception Error(insert_user_info_proc)';
            p_errcode := SQLCODE;
            p_errbuf  := SQLERRM;
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            ROLLBACK;
    END;

    PROCEDURE update_user_info_proc(p_errcode             OUT VARCHAR2
                                   ,p_errbuf              OUT VARCHAR2
                                   ,p_application_user_id IN NUMBER
                                   ,p_user_name           IN VARCHAR2) IS

        v_user_id NUMBER := -999;

        v_sort_order_no    NUMBER := NULL;
        v_user_system_code VARCHAR2(100) := NULL;
        v_menu_level_no    NUMBER := 0;

        v_request_region_code         VARCHAR2(100);
        v_default_org_id              NUMBER;
        v_server_time_difference_seqs NUMBER;
        v_language_code               lgcom_user_m.language_code%TYPE;
        v_timezone_type_code          lgcom_user_m.timezone_code%TYPE;
        v_date_format_code            lgcom_user_m.date_format_code%TYPE;
        v_amount_unit_code            lgcom_user_m.amount_unit_code%TYPE;
        v_system_code                 lgcom_user_m.system_code%TYPE;

        --인사 테이블에서 해당 사번의 가장 최근 정보를 추출
        CURSOR user_u_info IS
            SELECT application_user_id
                  ,employee_no AS user_name
                  ,TO_DATE(hire_yyyymmdd, 'YYYY/MM/DD') AS apply_start_date
                  ,TO_DATE(NVL(resignation_yyyymmdd, '2090/12/31'), 'YYYY/MM/DD') AS apply_end_date
                  ,person_id AS employee_id
                  ,email_addr AS mail_addr
                  ,'LGD' AS user_type_code
                  ,en_full_name AS english_full_name
                  ,local_full_name AS local_language_full_name
                  ,SUBSTR(job_title_name, 1, 30) AS grade_title_name
                  ,SUBSTR(organization_code, 1, 40) AS department_code
                  ,SUBSTR(organization_name, 1, 240) AS organization_name
                  ,organization_name_en AS english_organization_name
                  ,subsidiary_name AS corporation_name
                  ,DECODE(person_type_name, 'Employee', 'Y', 'N') AS regular_flag
                   --,'Y' AS regular_flag
                  ,retire_flag AS resignation_flag
                  ,office_phone_no AS office_phone_no
                  ,mobile_no AS employee_mobile_phone_no
                  ,business_group_id AS business_group_id
                  ,lgcom_subsidiary_id
                  ,subsidiary_id
                  ,SUBSTR(department_organization_name, INSTR(department_organization_name, '.') + 1) AS org_co_kr_name --20170622 최상위조직명 추가
                  ,position_code AS position_code
                  ,position_name AS position_name
            FROM   (SELECT um.application_user_id
                          ,ie.employee_no
                          ,ie.hire_yyyymmdd
                          ,ie.resignation_yyyymmdd
                          ,ie.person_id
                          ,ie.email_addr
                          ,ie.en_full_name
                          ,ie.local_full_name
                          ,ie.job_title_name
                          ,ie.organization_code
                          ,ie.organization_name
                          ,ie.organization_name_en
                          ,ie.office_phone_no
                          ,ie.mobile_no
                          ,ie.business_group_id
                          ,um.subsidiary_id                AS lgcom_subsidiary_id
                          ,ie.subsidiary_id
                          ,ie.subsidiary_name
                          ,om.department_organization_name
                          ,ie.position_code                AS position_code
                          ,ie.position_name                AS position_name
                          ,ie.person_type_name
                          ,ie.retire_flag
                    FROM   lgcom_ehr_r_employee ie --tb_ifr_ehr_r_employee_i ie
                          ,lgcom_organization_m om
                          ,lgcom_user_m         um
                    WHERE  ie.organization_id = om.organization_id(+)
                    AND    ie.employee_no = um.user_name
                    AND    ie.employee_no = NVL(p_user_name, ie.employee_no)
                    AND    (um.apply_start_date <> TO_DATE(hire_yyyymmdd, 'YYYY/MM/DD') OR
                          um.apply_end_date <> TO_DATE(NVL(resignation_yyyymmdd, '2090/12/31'), 'YYYY/MM/DD') OR
                          NVL(um.employee_id, -1) <> NVL(ie.person_id, -1) OR
                          NVL(um.mail_addr, 'X') <> NVL(ie.email_addr, 'X') OR
                          NVL(um.english_full_name, 'X') <> NVL(ie.en_full_name, 'X') OR
                          NVL(um.local_language_full_name, 'X') <> NVL(ie.local_full_name, 'X') OR
                          NVL(um.grade_title_name, 'X') <> NVL(SUBSTR(ie.job_title_name, 1, 30), 'X') OR
                          NVL(um.department_code, 'X') <> NVL(SUBSTR(ie.organization_code, 1, 40), 'X') OR
                          NVL(um.organization_name, 'X') <> NVL(SUBSTR(ie.organization_name, 1, 240), 'X') OR
                          NVL(um.english_organization_name, 'X') <> NVL(ie.organization_name_en, 'X') OR
                          NVL(um.resignation_flag, 'X') <> NVL(ie.retire_flag, 'X') OR
                          NVL(um.office_phone_no, 'X') <> NVL(ie.office_phone_no, 'X') OR
                          NVL(um.employee_mobile_phone_no, 'X') <> NVL(ie.mobile_no, 'X') OR
                          NVL(um.position_code, 'X') <> NVL(ie.position_code, 'X') OR
                          NVL(um.position_name, 'X') <> NVL(ie.position_name, 'X') OR
                          NVL(um.subsidiary_id, -9999) <> NVL(ie.subsidiary_id, -9999) OR
                          NVL(um.corporation_name, 'X') <> NVL(ie.subsidiary_name, 'X')))
            WHERE  1 = 1;

        CURSOR user_info_04 IS
            SELECT lfs.application_user_id
            FROM   lgcom_full_system_favor_hier_n lfs
                  ,lgcom_user_m                   lm
            WHERE  lfs.application_user_id = lm.application_user_id
            AND    lm.user_name = NVL(p_user_name, lm.user_name)
            GROUP  BY lfs.application_user_id;

        CURSOR user_info_05 IS
            SELECT DISTINCT t.application_user_id
                           ,t.menu_id
                           ,(SELECT s.menu_level_no
                             FROM   lgcom_menu_m s
                             WHERE  s.menu_id = t.menu_id) AS menu_level_no
                           ,(SELECT ss.high_menu_id
                             FROM   lgcom_menu_m ss
                             WHERE  ss.menu_id = t.menu_id) AS hh_menu_id
                           ,(SELECT hh.menu_level_no
                             FROM   lgcom_menu_m ss
                                   ,lgcom_menu_m hh
                             WHERE  ss.high_menu_id = hh.menu_id
                             AND    ss.menu_id = t.menu_id) AS hh_menu_level_no
            FROM   (SELECT lf.application_user_id
                          ,lm.high_menu_id AS menu_id
                    FROM   lgcom_full_system_favor_hier_n lf
                          ,lgcom_menu_m                   lm
                          ,lgcom_user_m                   lu
                    WHERE  lf.menu_id = lm.menu_id
                    AND    lf.application_user_id = lu.application_user_id
                    AND    lu.user_name = NVL(p_user_name, lu.user_name)
                    AND    lm.high_menu_id IS NOT NULL
                    MINUS
                    SELECT m.application_user_id
                          ,m.menu_id
                    FROM   lgcom_full_system_favor_hier_n m
                          ,lgcom_user_m                   lu
                    WHERE  m.application_user_id = lu.application_user_id
                    AND    lu.user_name = NVL(p_user_name, lu.user_name)) t;

        CURSOR user_info_06 IS
        -- Default system이 없고, Role을 하나라도 갖고있는 User
            SELECT lu.application_user_id
                  ,lu.system_code
                  ,TRUNC(lu.apply_start_date) AS apply_start_date
                  ,TRUNC(lu.apply_end_date) AS apply_end_date
            FROM   lgcom_user_m lu
            WHERE  1 = 1
            AND    lu.user_name = NVL(p_user_name, lu.user_name)
            AND    NVL(lu.apply_start_date, SYSDATE) <= SYSDATE
            AND    NVL(lu.apply_end_date, SYSDATE) >= SYSDATE
            AND    lu.system_code IS NULL
            AND    EXISTS (SELECT 1
                    FROM   lgcom_user_role_n lur
                    WHERE  NVL(lur.apply_start_date, SYSDATE) < SYSDATE + 1
                    AND    NVL(lur.apply_end_date, SYSDATE) > SYSDATE - 1
                    AND    lur.application_user_id = lu.application_user_id)
            UNION
            -- Default system이 LGCOM이면서 LGCOM system이 아닌 Role을 갖고있는
            SELECT lu.application_user_id
                  ,lu.system_code
                  ,TRUNC(lu.apply_start_date) AS apply_start_date
                  ,TRUNC(lu.apply_end_date) AS apply_end_date
            FROM   lgcom_user_m lu
            WHERE  lu.user_name = NVL(p_user_name, lu.user_name)
            AND    NVL(lu.apply_start_date, SYSDATE) <= SYSDATE
            AND    NVL(lu.apply_end_date, SYSDATE) >= SYSDATE
            AND    lu.system_code = v_system_code
            AND    EXISTS (SELECT 1
                    FROM   lgcom_user_role_n lur
                          ,lgcom_role_m      lr
                    WHERE  lur.role_code = lr.role_code
                    AND    NVL(lur.apply_start_date, SYSDATE) < SYSDATE + 1
                    AND    NVL(lur.apply_end_date, SYSDATE) > SYSDATE - 1
                    AND    lr.system_code <> v_system_code
                    AND    lur.application_user_id = lu.application_user_id);

    BEGIN

        FOR cur_u_record IN user_u_info
        LOOP

            v_system_code := 'LGCOM';

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            END IF;

            -- subsidiary_id가 null이었다가 바뀌거나 달라진 경우라면
            IF NVL(cur_u_record.lgcom_subsidiary_id, -9999) <> NVL(cur_u_record.subsidiary_id, -9999) AND
               cur_u_record.subsidiary_id IS NOT NULL THEN
                BEGIN
                    --Default값.
                    IF cur_u_record.subsidiary_id = 81 THEN
                        v_language_code := 'ko';
                    ELSE
                        v_language_code := 'en';
                    END IF;

                    SELECT lcc.common_code AS request_region_code
                           --,r.user_name     AS user_name
                          ,lcc.code_data2_value default_org_id
                           --,d.short_code AS default_org_code
                           --,d.name       AS default_org_name
                          ,(SELECT a.common_code
                            FROM   lgcom_common_code_c a
                            WHERE  a.code_type_code = 'LGCOM_TIMEZONE_TYPE_CODE'
                            AND    a.code_data1_value = lcc.code_data5_value
                            AND    ROWNUM = 1) timezone_code
                          ,to_number(lcc.code_data4_value) server_time_difference_seqs
                    INTO   v_request_region_code
                          ,v_default_org_id
                          ,v_timezone_type_code
                          ,v_server_time_difference_seqs
                    FROM   lgcom_common_code_c lcc
                          ,(SELECT subsidiary.short_code
                                  ,DECODE(subsidiary.short_code, 'LGDCA', 'ZHC', subsidiary.region_code) region_code
                            FROM   (SELECT to_number(sub.common_code) subsidiary_id
                                          ,sub.common_code_desc short_code
                                          ,sub.code_data1_value region_code
                                    FROM   lgcom_common_code_c sub
                                    WHERE  sub.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                                    AND    sub.use_flag = 'Y') subsidiary
                            WHERE  subsidiary_id = cur_u_record.subsidiary_id) r
                          ,(SELECT ou.code_data1_value short_code
                                  ,ou.common_code_desc NAME
                                  ,ou.common_code      ou_id
                            FROM   lgcom_common_code_c ou
                            WHERE  1 = 1
                            AND    ou.code_type_code = 'LGCOM_OU_INFO'
                            AND    ou.use_flag = 'Y') d
                    WHERE  lcc.common_code = r.region_code
                    AND    lcc.code_data2_value = d.ou_id
                    AND    lcc.code_type_code = 'LGCOM_TIMEZONE_DEFAULT_COMPANY'
                    AND    lcc.use_flag = 'Y'
                    ORDER  BY lcc.sort_order_no;

                    v_date_format_code := 'YYYY-MM-DD';
                    v_amount_unit_code := ',.';
                    --v_timezone_type_code := NULL;
                    --v_system_code        := 'LGCOM';
                EXCEPTION
                    WHEN OTHERS THEN
                        --Default값.
                        v_language_code       := 'ko';
                        v_date_format_code    := 'YYYY-MM-DD';
                        v_amount_unit_code    := ',.';
                        v_request_region_code := NULL;
                        v_timezone_type_code  := NULL;
                        --v_system_code         := 'LGCOM';
                END;
            END IF;

            --lgcom_user_m 테이블에 해당 사번의 정보를 최신 정보로 update
            BEGIN

                UPDATE lgcom_user_m lum
                SET    lum.apply_start_date             = cur_u_record.apply_start_date
                      ,lum.apply_end_date               = cur_u_record.apply_end_date
                      ,lum.mail_addr                    = cur_u_record.mail_addr
                      ,lum.language_code                = NVL(v_language_code, lum.language_code)
                      ,lum.date_format_code             = NVL(v_date_format_code, lum.date_format_code)
                      ,lum.amount_unit_code             = NVL(v_amount_unit_code, lum.amount_unit_code)
                      ,lum.request_region_code          = NVL(v_request_region_code, lum.request_region_code)
                      ,lum.request_region_code_use_flag = 'Y'
                      ,lum.timezone_code                = NVL(v_timezone_type_code, lum.timezone_code)
                      ,lum.server_time_difference_seqs  = NVL(v_server_time_difference_seqs
                                                             ,lum.server_time_difference_seqs)
                      ,lum.default_org_id               = NVL(v_default_org_id, lum.default_org_id)
                      ,lum.default_org_id_use_flag      = 'N'
                      ,lum.user_type_code               = cur_u_record.user_type_code
                      ,lum.english_full_name            = cur_u_record.english_full_name
                      ,lum.local_language_full_name     = cur_u_record.local_language_full_name
                      ,lum.grade_title_name             = cur_u_record.grade_title_name
                      ,lum.department_code              = cur_u_record.department_code
                      ,lum.organization_name            = cur_u_record.organization_name
                      ,lum.english_organization_name    = cur_u_record.english_organization_name
                      ,lum.regular_flag                 = cur_u_record.regular_flag
                      ,lum.resignation_flag             = cur_u_record.resignation_flag
                      ,lum.office_phone_no              = cur_u_record.office_phone_no
                      ,lum.employee_mobile_phone_no     = cur_u_record.employee_mobile_phone_no
                      ,lum.position_code                = cur_u_record.position_code
                      ,lum.position_name                = cur_u_record.position_name
                      ,lum.subsidiary_id                = cur_u_record.subsidiary_id
                      ,lum.corporation_name             = cur_u_record.corporation_name
                      ,lum.last_updated_by              = v_user_id
                      ,lum.last_update_date             = SYSDATE
                WHERE  lum.user_name = cur_u_record.user_name;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    g_step    := 'User Exception Error(update_user_info_proc)';
                    p_errcode := SQLCODE;
                    p_errbuf  := SQLERRM;
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_parameter('user_name', cur_u_record.user_name);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            END;

        END LOOP;

        -- BizWeb User가 생성한 My Menu의 내역 중 권한이 없어지거나 메뉴가 변경된 내역 삭제
        IF p_user_name IS NOT NULL THEN
            FOR cur_04_record IN user_info_04
            LOOP
                BEGIN
                    DELETE lgcom_full_system_favor_hier_n lfs
                    WHERE  1 = 1
                    AND    application_user_id = cur_04_record.application_user_id
                    AND    EXISTS (SELECT 'x'
                            FROM   lgcom_menu_m m
                            WHERE  m.menu_id = lfs.menu_id)
                    AND    NOT EXISTS (SELECT 'x'
                            FROM   lgcom_user_menu_info_v lum
                            WHERE  lum.application_user_id = lfs.application_user_id
                            AND    lum.menu_id = lfs.menu_id);
                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        p_errcode := 'E';
                        p_errbuf  := SQLERRM;
                        g_step    := 'update lgcom_user_m (cur_04_record - my menu cleansing)';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                END;
            END LOOP;
        ELSE
            -- parameter로 User_name이 들어오지않는다면 where조건에서 전체대상으로 정리
            BEGIN
                DELETE lgcom_full_system_favor_hier_n lfs
                WHERE  1 = 1
                AND    EXISTS (SELECT 'x'
                        FROM   lgcom_menu_m m
                        WHERE  m.menu_id = lfs.menu_id)
                AND    NOT EXISTS (SELECT 'x'
                        FROM   lgcom_user_menu_info_v lum
                        WHERE  lum.application_user_id = lfs.application_user_id
                        AND    lum.menu_id = lfs.menu_id);
                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    p_errcode := 'E';
                    p_errbuf  := SQLERRM;
                    g_step    := 'update lgcom_user_m (cur_04_record - my menu cleansing)';
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            END;
        END IF;

        -- 상위menu가 없는 하위메뉴만을 갖고있는 User는 해당하는 상위메뉴를 찾아와
        -- User menu테이블에 Insert해준다.
        FOR cur_05_record IN user_info_05
        LOOP

            BEGIN
                v_sort_order_no := NULL;

                SELECT MAX(NVL(lf.sort_order_no, 0)) + 1
                INTO   v_sort_order_no
                FROM   lgcom_full_system_favor_hier_n lf
                      ,lgcom_menu_m                   lm
                WHERE  lf.menu_id = lm.menu_id
                AND    lm.menu_level_no = cur_05_record.menu_level_no
                AND    lf.application_user_id = cur_05_record.application_user_id;
            EXCEPTION
                WHEN OTHERS THEN
                    v_sort_order_no := 1;
            END;

            BEGIN
                INSERT INTO lgcom_full_system_favor_hier_n
                    (application_user_id
                    ,menu_id
                    ,high_menu_id
                    ,sort_order_no
                    ,created_by
                    ,creation_date
                    ,last_updated_by
                    ,last_update_date)
                VALUES
                    (cur_05_record.application_user_id --application_user_id
                    ,cur_05_record.menu_id --menu_id
                    ,NULL --high_menu_id
                    ,v_sort_order_no --sort_order_no
                    ,v_user_id --created_by
                    ,SYSDATE --creation_date
                    ,v_user_id --last_updated_by
                    ,SYSDATE --last_update_date
                     );
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    p_errcode := 'E';
                    p_errbuf  := SQLERRM;
                    g_step    := 'INSERT INTO lgcom_full_system_favor_hier_n';
                    lgcom_error_log_pkg.set_comment_text(g_step);
                    lgcom_error_log_pkg.set_error_code(p_errcode);
                    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                    lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            END;

            -- 추가한 Menu가 2 Level 이라면 추가한 Menu의 상위메뉴를 다시한번 찾아서 Insert해준다..
            IF cur_05_record.menu_level_no = 2 AND
               cur_05_record.hh_menu_id IS NOT NULL THEN
                BEGIN
                    v_sort_order_no := NULL;

                    SELECT MAX(NVL(lf.sort_order_no, 0)) + 1
                    INTO   v_sort_order_no
                    FROM   lgcom_full_system_favor_hier_n lf
                          ,lgcom_menu_m                   lm
                    WHERE  lf.menu_id = lm.menu_id
                    AND    lm.menu_level_no = cur_05_record.hh_menu_level_no
                    AND    lf.application_user_id = cur_05_record.application_user_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_sort_order_no := 1;
                END;

                BEGIN
                    INSERT INTO lgcom_full_system_favor_hier_n
                        (application_user_id
                        ,menu_id
                        ,high_menu_id
                        ,sort_order_no
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date)
                    VALUES
                        (cur_05_record.application_user_id --application_user_id
                        ,cur_05_record.hh_menu_id --menu_id
                        ,NULL --high_menu_id
                        ,v_sort_order_no --sort_order_no
                        ,v_user_id --created_by
                        ,SYSDATE --creation_date
                        ,v_user_id --last_updated_by
                        ,SYSDATE --last_update_date
                         );
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                END;
            END IF;

            COMMIT;

        END LOOP;

        -- 1.Default system 관리
        -- 2.default system이 Null이면서, 부여받은 Role이 존재한다면..
        --   정규,비정규 상관없이 부여받은 Role중 가장많은 Role에 해당하는 system code로 Update
        -- 3.default system이 LGCOM이면서 정규직일경우..
        --    LGCOM을 제외한 또다른 부여받은 Role중에 가장많은 Role에 해당하는 system code Update
        FOR cur_06_record IN user_info_06
        LOOP

            -- 1. Role을 부여받았지만 Default system이 없는 User는
            --    부여받은 Role의 system중 가장 많은 system update
            IF cur_06_record.system_code IS NULL THEN

                v_user_system_code := NULL;
                BEGIN
                    SELECT m.system_code
                    INTO   v_user_system_code
                    FROM   (SELECT lrm.system_code
                                  ,COUNT(1)
                            FROM   lgcom_user_role_n lurn
                                  ,lgcom_role_m      lrm
                            WHERE  lurn.role_code = lrm.role_code
                            AND    NVL(lurn.apply_start_date, SYSDATE) <= SYSDATE
                            AND    NVL(lurn.apply_end_date, SYSDATE) >= SYSDATE
                            AND    lurn.application_user_id = cur_06_record.application_user_id
                            GROUP  BY lrm.system_code
                            ORDER  BY 2 DESC) m
                    WHERE  ROWNUM = 1;

                    UPDATE lgcom_user_m lum
                    SET    lum.system_code      = v_user_system_code
                          ,lum.last_update_date = SYSDATE
                          ,lum.last_updated_by  = v_user_id
                    WHERE  lum.application_user_id = cur_06_record.application_user_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;
            ELSIF cur_06_record.system_code IS NOT NULL THEN

                v_user_system_code := NULL;
                BEGIN
                    SELECT m.system_code
                    INTO   v_user_system_code
                    FROM   (SELECT lrm.system_code
                                  ,COUNT(1)
                            FROM   lgcom_user_role_n lurn
                                  ,lgcom_role_m      lrm
                            WHERE  lurn.role_code = lrm.role_code
                            AND    NVL(lurn.apply_start_date, SYSDATE) <= SYSDATE
                            AND    NVL(lurn.apply_end_date, SYSDATE) >= SYSDATE
                            AND    lrm.system_code <> 'LGCOM'
                            AND    lurn.application_user_id = cur_06_record.application_user_id
                            GROUP  BY lrm.system_code
                            ORDER  BY 2 DESC) m
                    WHERE  ROWNUM = 1;

                    UPDATE lgcom_user_m lum
                    SET    lum.system_code      = v_user_system_code
                          ,lum.last_update_date = SYSDATE
                          ,lum.last_updated_by  = v_user_id
                    WHERE  lum.application_user_id = cur_06_record.application_user_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                END;
            END IF;

            COMMIT;

        END LOOP; --FOR cur_06_record IN user_info_06

        -- Menu display_flag정리하기
        -- 정상적인 하위메뉴를 갖고있는 상위메뉴의 display_flag 또는 use_flag 가 'N'값이면
        -- 해당 메뉴의 모든 하위메뉴의 display_flag = 'N'값으로 Update한다.
        FOR i IN 1 .. 2
        LOOP

            v_menu_level_no := v_menu_level_no + 1;

            -- 첫번째 Loop >> 1레벨 먼저 loop를 돌면서 2레벨의 display_flag정리후
            -- 두번째 Loop >> 2레벨을 돌면서 3레벨의 display_flag정리..
            FOR cur_record IN (SELECT lmm.menu_id
                               FROM   lgcom_menu_m lmm
                               -- 상위메뉴중 display_flag = 'N'인 모든 하위메뉴(use_flag,display_flag = 'Y')
                               WHERE  lmm.high_menu_id IN
                                      (SELECT lm.menu_id
                                       FROM   lgcom_menu_m lm
                                       WHERE  lm.menu_level_no = v_menu_level_no
                                       AND    lm.pop_up_screen_flag = 'N'
                                       AND    (lm.use_flag = 'N' OR lm.display_flag = 'N'))
                               AND    lmm.pop_up_screen_flag = 'N'
                               AND    lmm.use_flag = 'Y'
                               AND    lmm.display_flag = 'Y')
            LOOP
                BEGIN
                    UPDATE lgcom_menu_m m
                    SET    m.display_flag     = 'N'
                          ,m.last_update_date = SYSDATE
                          ,m.last_updated_by  = v_user_id
                    WHERE  m.menu_id = cur_record.menu_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;
            END LOOP;
        END LOOP;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(UPDATE_user_info_proc)';
            dbms_output.put_line('UPDATE_user_info_proc'); --lgcom_error_log_pkg.set_comment_text(g_step);

    END;

    --공통 role 부여, 비즈웹 기존 패키지를 tdr에 맞게 수정하여 사용
     PROCEDURE create_common_user_role_proc(p_errcode             OUT VARCHAR2
                                          ,p_errbuf              OUT VARCHAR2
                                          ,p_application_user_id IN NUMBER
                                          ,p_user_name           IN VARCHAR2) IS
    
        v_common_role_code VARCHAR2(100) := '';
        v_user_id          NUMBER := -999; --fnd_global.user_id;
    
        CURSOR common_role_info IS
            SELECT lcc.common_code AS common_role_code
            FROM   lgcom_code_type_code_c lc
                  ,lgcom_common_code_c    lcc
            WHERE  lc.code_type_code = lcc.code_type_code
            AND    lc.code_type_code = 'LGCOM_COMMON_ROLE_CODE'
            AND    lc.use_flag = 'Y'
            AND    lcc.use_flag = 'Y'
            AND    NVL(lcc.apply_start_date, SYSDATE) < SYSDATE + 1
            AND    NVL(lcc.apply_end_date, SYSDATE) > SYSDATE - 1;

        CURSOR user_info IS
            SELECT lum.application_user_id
                  ,TRUNC(lum.apply_start_date) AS apply_start_date
                  ,TRUNC(lum.apply_end_date) AS apply_end_date
                  ,(SELECT DECODE(COUNT(1), 0, 'N', 'Y')
                    FROM   lgcom_full_system_favor_hier_n t
                    WHERE  t.application_user_id = lum.application_user_id
                    AND    ROWNUM = 1) AS user_menu_flag
            FROM   lgcom_user_m lum
            --,tb_ifr_EHR_R_EMPLOYEE_I ie --xxgifh_global_employee_t xge
            WHERE  1 = 1 --lum.employee_id = ie.person_id --xge.person_id
            AND    NVL(lum.apply_start_date, SYSDATE) < SYSDATE + 1
            AND    NVL(lum.apply_end_date, SYSDATE) >= SYSDATE
                  -- 정규만 대상으로 한다.
            AND    lum.regular_flag = 'Y' --xge.regular_yn = 'Y'
                  -- main에서 call되어질때는 user_name이 필수이나,
                  -- common role추가시 별도로 실행할수있게, NVL처리
            AND    lum.user_name = NVL(p_user_name, lum.user_name)
            AND    NOT EXISTS (SELECT 'Y'
                    FROM   lgcom_user_role_n lur
                    WHERE  lur.application_user_id = lum.application_user_id
                    AND    lur.role_code = v_common_role_code -- cursor1 에서 변수 받음.
                    ); --AND    ROWNUM = 1);

    BEGIN
        FOR common_role_record IN common_role_info
        LOOP

            IF p_application_user_id IS NOT NULL THEN
                v_user_id := p_application_user_id;
            END IF;

            v_common_role_code := common_role_record.common_role_code;

            FOR cur_record IN user_info
            LOOP
                -- 1.Common Role Insert
                -- (정규직 직원(regular_yn = 'Y')이면서 , Common Role이 없는 User대상)
                BEGIN
                    INSERT INTO lgcom_user_role_n
                        (application_user_id
                        ,role_code
                        ,apply_start_date
                        ,apply_end_date
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date
                        ,approver_opinion_desc)
                    VALUES
                        (cur_record.application_user_id --application_user_id
                        ,v_common_role_code --role_code
                        ,cur_record.apply_start_date --apply_start_date
                        ,cur_record.apply_end_date --apply_end_date
                        ,v_user_id --created_by
                        ,SYSDATE --creation_date
                        ,v_user_id --last_updated_by
                        ,SYSDATE --last_update_date
                        ,NULL -- approver_opinion_desc
                         );
                EXCEPTION
                    WHEN OTHERS THEN
                        p_errcode := 'E';
                        p_errbuf  := SQLERRM;
                        g_step    := 'INSERT INTO lgcom_user_role_n';
                        lgcom_error_log_pkg.set_comment_text(g_step);
                        lgcom_error_log_pkg.set_error_code(p_errcode);
                        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
                        ROLLBACK;
                END;

                -- 2. 위조건이면서 User Menu도 갖고있는 User라면
                --    user_Menu Table도 Common role Insert
                IF cur_record.user_menu_flag = 'Y' THEN

                    FOR rec_r IN (SELECT lrm.menu_id
                                        ,lm.menu_level_no
                                        ,lm.sort_order_no
                                  FROM   lgcom_role_menu_n lrm
                                        ,lgcom_menu_m      lm
                                  WHERE  lrm.menu_id = lm.menu_id
                                  AND    lrm.role_code = v_common_role_code
                                  ORDER  BY lm.menu_level_no)
                    LOOP

                        BEGIN
                            INSERT INTO lgcom_full_system_favor_hier_n
                                (application_user_id
                                ,menu_id
                                ,high_menu_id
                                ,sort_order_no
                                ,created_by
                                ,creation_date
                                ,last_updated_by
                                ,last_update_date)
                            VALUES
                                (cur_record.application_user_id --application_user_id
                                ,rec_r.menu_id --menu_id
                                ,NULL --high_menu_id
                                ,rec_r.sort_order_no --sort_order_no
                                ,v_user_id --created_by
                                ,SYSDATE --creation_date
                                ,v_user_id --last_updated_by
                                ,SYSDATE --last_update_date
                                 );
                        EXCEPTION
                            WHEN OTHERS THEN
                                -- 이미 갖고있다면, PK에 의해 DupError로 Skip
                                NULL;
                        END;
                    END LOOP; --rec_r IN (SELECT lrm.menu_id
                END IF; --IF cur_record.user_menu_flag = 'Y' THEN

            END LOOP; --FOR cur_record IN user_info
        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            g_step := 'User Exception Error(create_common_user_role_proc)';
            lgcom_error_log_pkg.set_comment_text(g_step);
            lgcom_error_log_pkg.set_error_code(p_errcode);
            lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
            lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
            ROLLBACK;
    END;
END lgcom_user_if_pkg;
/
