CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_region_pkg IS

    TYPE region_rec IS RECORD(
         request_region_code_use_flag VARCHAR2(1)
        ,user_name                    VARCHAR2(100)
        ,application_user_id          NUMBER
        ,request_region_code          VARCHAR2(100)
        ,request_region_name          VARCHAR2(100)
        ,default_org_id               NUMBER
        ,default_org_code             VARCHAR2(20)
        ,default_org_name             VARCHAR2(300)
        ,server_time_difference_seqs  NUMBER
        ,user_org_id                  NUMBER
        ,user_org_code                VARCHAR2(20)
        ,user_org_name                VARCHAR2(300)
        ,user_org_use_flag            VARCHAR2(1)
        ,ou_use_flag                  VARCHAR2(1));

    TYPE region_table IS TABLE OF region_rec;
    FUNCTION get_regin_info(p_sso_id VARCHAR2) RETURN region_table
        PIPELINED;

END lgcom_region_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgcom_region_pkg IS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : LGD Web Common Framework Project
    /* Module       : LGCOM
    /* Program Name : lgcom_region_pkg
    /* Reference by :
    /* Description  : get_regin_info
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-08-22   Kimhansik      1.0      initialize
    /******************************************************************************/
    FUNCTION get_regin_info(p_sso_id VARCHAR2) RETURN region_table
        PIPELINED IS

        v_rec region_rec;

        v_error_exception EXCEPTION;

        CURSOR region_info IS
            SELECT lcc.common_code AS request_region_code
                  ,lcc.common_code_desc AS request_region_name
                  ,NVL(r.user_name
                      ,(SELECT s.user_name -- tuner
                       FROM   lgcom_sso_login_v s
                       WHERE  SUBSTR(s.email_id, 1, INSTR(s.email_id, '@') - 1) =
                              p_sso_id
                       AND    ROWNUM = 1)) AS user_name
                  ,lcc.code_data2_value  default_org_id
                  ,d.short_code AS default_org_code
                  ,d.name       AS default_org_name
                  ,to_number(lcc.code_data4_value)   server_time_difference_seqs
                  ,lcc.sort_order_no
            FROM   lgcom_common_code_c lcc,
                   (SELECT lum.user_name,
                           DECODE(subsidiary.Short_code
                                 ,'LGDCA'
                                 ,'ZHC'
                                 ,subsidiary.region_code) region_code
                    FROM   lgcom_user_m_v lum
                          ,(SELECT to_number(sub.common_code)      subsidiary_id,
                                   sub.common_code_desc Short_code,
                                   sub.code_data1_value region_code
                            FROM   lgcom_common_code_c sub
                            WHERE  sub.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                            AND    sub.use_flag = 'Y') subsidiary
                    WHERE  lum.subsidiary_id = subsidiary.subsidiary_id(+)
                    AND    SUBSTR(lum.mail_addr, 1, INSTR(lum.mail_addr, '@') - 1) = p_sso_id) r
                  ,(SELECT ou.code_data1_value short_code
                          ,ou.common_code_desc name
                          ,ou.common_code      organization_id
                    FROM   lgcom_common_code_c ou
                    WHERE  1 = 1
                    AND    ou.code_type_code = 'LGCOM_OU_INFO'
                    AND    ou.use_flag = 'Y'
                    ) d
            WHERE  lcc.common_code      = r.region_code(+)
            AND    lcc.code_data2_value = d.organization_id
            AND    lcc.code_type_code   = 'LGCOM_TIMEZONE_DEFAULT_COMPANY'
            AND    lcc.use_flag         = 'Y'
            ORDER  BY lcc.sort_order_no;

    BEGIN

        FOR cur_record IN region_info
        LOOP

            BEGIN
                SELECT lu.application_user_id
                      ,lu.default_org_id
                      ,ho.short_code
                      ,ho.name
                      ,NVL(lu.default_org_id_use_flag, 'N')
                      ,(SELECT /*+ leading(lur) */
                        DECODE(COUNT(1), 0, 'N', 'Y') AS ou_use_flag -- tuner
                       FROM   lgcom_user_role_n    lur
                             ,lgcom_role_m         lr
                             ,lgcom_role_biz_org_n lrb
                       WHERE  lur.role_code = lr.role_code
                       AND    lur.role_code = lrb.role_code
                       AND    NVL(lr.apply_start_date, SYSDATE) <= SYSDATE
                       AND    NVL(lr.apply_end_date, SYSDATE) >= SYSDATE
                       AND    NVL(lur.apply_start_date, SYSDATE) <= SYSDATE
                       AND    NVL(lur.apply_end_date, SYSDATE) >= SYSDATE
                       AND    lrb.organization_type_code = 'C'
                       AND    lur.application_user_id = lu.application_user_id)
                INTO   v_rec.application_user_id
                      ,v_rec.user_org_id
                      ,v_rec.user_org_code
                      ,v_rec.user_org_name
                      ,v_rec.user_org_use_flag
                      ,v_rec.ou_use_flag
                FROM   lgcom_user_m        lu
                      ,(SELECT lcc.common_code       organization_id,
                               lcc.code_data1_value  short_code,
                               lcc.common_code_desc  name
                        FROM   lgcom_common_code_c lcc
                        WHERE  lcc.code_type_code = 'LGCOM_OU_INFO'
                        AND    lcc.use_flag = 'Y' ) ho                        
                      --,hr_operating_units ho
                WHERE  lu.user_name = cur_record.user_name
                AND    lu.default_org_id = ho.organization_id(+);
            EXCEPTION
                WHEN OTHERS THEN
                    v_rec.ou_use_flag := 'N';
            END;

            v_rec.request_region_code_use_flag := 'N';
            v_rec.user_name                    := cur_record.user_name;
            v_rec.request_region_code          := cur_record.request_region_code;
            v_rec.request_region_name          := cur_record.request_region_name;

            v_rec.default_org_id              := cur_record.default_org_id;
            v_rec.default_org_code            := cur_record.default_org_code;
            v_rec.default_org_name            := cur_record.default_org_name;
            v_rec.server_time_difference_seqs := cur_record.server_time_difference_seqs;

            PIPE ROW(v_rec);

        END LOOP;
    END get_regin_info;

END lgcom_region_pkg;
/
