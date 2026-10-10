CREATE OR REPLACE PACKAGE VHR_MGR.lgvhr_common_pkg
IS

FUNCTION sys_user_id RETURN VARCHAR2;

FUNCTION start_of_time RETURN DATE;

FUNCTION end_of_time RETURN DATE;

FUNCTION decode_lookup (p_lookup_type IN VARCHAR2
                       ,p_lookup_code IN VARCHAR2
                       ,p_type        IN VARCHAR2 DEFAULT 'N'
                       ,p_lang        IN VARCHAR2 DEFAULT 'en'
                       )
RETURN VARCHAR2;


FUNCTION decode_lookup_name (p_lookup_type IN VARCHAR2
                            ,p_name        IN VARCHAR2
                            ,p_type        IN VARCHAR2 DEFAULT 'C'
                            ,p_lang        IN VARCHAR2 DEFAULT 'en'
                            )
RETURN VARCHAR2;


FUNCTION decode_message (p_message_id IN VARCHAR2
                        ,p_lang       IN VARCHAR2 DEFAULT 'en'
                        ,p_type       IN VARCHAR2 DEFAULT 'C'
                        )
RETURN VARCHAR2;


FUNCTION get_subsidiary_code_func
RETURN VARCHAR2;


FUNCTION get_subsidiary_code_func (p_organization_id IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_subsidiary_id_func (p_subsidiary_code IN VARCHAR2)
RETURN NUMBER;


FUNCTION get_subsidiary_name_func (p_organization_id IN NUMBER)
RETURN VARCHAR2;


FUNCTION get_subsidiary_name_func (p_subsidiary_code IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION get_shift_type_code_func (p_subsidiary_code IN VARCHAR2
                                  ,p_employee_no     IN VARCHAR2
                                  ,p_basis_date      IN DATE
                                  )
RETURN VARCHAR2;


FUNCTION get_shift_info_func (p_subsidiary_code IN VARCHAR2
                             ,p_basis_date      IN DATE
                             ,p_shift_type_code IN VARCHAR2
                             ,p_type            IN VARCHAR2 DEFAULT 'DN'
                             )
RETURN VARCHAR2;


FUNCTION get_org_resp_flag_func (p_subsidiary_code IN VARCHAR2
                                ,p_employee_no     IN VARCHAR2
                                ,p_basis_date      IN DATE     DEFAULT NULL
                                )
RETURN VARCHAR2;


FUNCTION get_application_user_id_func (p_subsidiary_code IN VARCHAR2
                                      ,p_employee_no     IN VARCHAR2
                                      )
RETURN NUMBER;


FUNCTION get_employee_no_func (p_subsidiary_code     IN VARCHAR2
                              ,p_application_user_id IN NUMBER
                              )
RETURN VARCHAR2;


FUNCTION get_mail_addr_func (p_subsidiary_code IN VARCHAR2
                            ,p_employee_no     IN VARCHAR2
                            )
RETURN VARCHAR2;


FUNCTION get_mail_system_code_func (p_subsidiary_code IN VARCHAR2
                                   ,p_module_code     IN VARCHAR2
                                   )
RETURN VARCHAR2;


FUNCTION get_mail_title_func (p_subsidiary_code IN VARCHAR2
                             ,p_module_code     IN VARCHAR2
                             )
RETURN VARCHAR2;


FUNCTION get_mail_sender_func (p_subsidiary_code IN VARCHAR2
                              ,p_module_code     IN VARCHAR2 DEFAULT NULL
                              )
RETURN VARCHAR2;


FUNCTION get_language_code_func (p_subsidiary_code IN VARCHAR2)
RETURN VARCHAR2;


FUNCTION get_organization_name_func (p_subsidiary_code IN VARCHAR2
                                    ,p_organization_id IN VARCHAR2
                                    ,p_type            IN VARCHAR2 DEFAULT NULL
                                    )
RETURN VARCHAR2;


FUNCTION get_parent_org_id_func (p_subsidiary_code  IN VARCHAR2
                                ,p_organization_id  IN NUMBER
                                ,p_parent_type_code IN VARCHAR2 DEFAULT NULL
                                ,p_no_matched_flag  IN VARCHAR2 DEFAULT 'Y'
                                )
RETURN NUMBER;


FUNCTION get_emp_master_rec (p_subsidiary_code  IN VARCHAR2
                            ,p_employee_no      IN VARCHAR2
                            )
RETURN emp_master%ROWTYPE;


FUNCTION get_org_master_rec (p_subsidiary_code  IN VARCHAR2
                            ,p_organization_id  IN VARCHAR2
                            )
RETURN org_master%ROWTYPE;


FUNCTION get_emp_assig_rec (p_subsidiary_code IN VARCHAR2
                           ,p_employee_no     IN VARCHAR2
                           ,p_assignment_date IN DATE     DEFAULT NULL
                           )
RETURN emp_assig%ROWTYPE;


END lgvhr_common_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvhr_common_pkg
IS

FUNCTION sys_user_id 
RETURN VARCHAR2
IS
BEGIN
    RETURN lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SYS_USER', 'A1');
END sys_user_id;


FUNCTION start_of_time
RETURN DATE
IS
BEGIN
    RETURN TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'START_OF_TIME', 'A1'), 'YYYYMMDD');
END start_of_time;


FUNCTION end_of_time
RETURN DATE
IS
BEGIN
    RETURN TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'END_OF_TIME', 'A1'), 'YYYYMMDD');
END end_of_time;


/*************************************************************************************************/
/* Program Name : decode_lookup                                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Lookup Type, Code를 받아 값을 Return한다.                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_lookup_type                     in    varchar2  Lookup Type                  */
/*                p_lookup_code                     in    varchar2  Lookup Code                  */
/*                p_type                            in    varchar2  Return 유형(N/D/A...)        */
/*                p_lang                            in    varchar2  Language                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION decode_lookup (p_lookup_type IN VARCHAR2
                       ,p_lookup_code IN VARCHAR2
                       ,p_type        IN VARCHAR2 DEFAULT 'N'
                       ,p_lang        IN VARCHAR2 DEFAULT 'en'
                       )
RETURN VARCHAR2
IS
    cc_rec    lgcom_common_code_c%ROWTYPE;
    ccm_rec   lgcom_common_code_multi_lang_c%ROWTYPE;

BEGIN

    SELECT *
    INTO   cc_rec
    FROM   lgcom_common_code_c
    WHERE  code_type_code = p_lookup_type
    AND    common_code    = p_lookup_code
    ;

    BEGIN    
        SELECT *
        INTO   ccm_rec
        FROM   (SELECT *
                FROM   lgcom_common_code_multi_lang_c
                WHERE  code_type_code = p_lookup_type
                AND    common_code    = p_lookup_code
                AND    language_code  = p_lang
                UNION ALL
                SELECT *
                FROM   lgcom_common_code_multi_lang_c  -- 영어만 셋업이 된 경우 영어로 보여줌
                WHERE  code_type_code = p_lookup_type
                AND    common_code    = p_lookup_code
                AND    language_code  = 'en'
               )
        WHERE  ROWNUM = 1
        ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  -- Multi Language 셋업 안된 경우
        ccm_rec.common_code_name := cc_rec.common_code_desc;  -- Code 의 Desc 값 셋팅
    END;
    
    IF NVL(p_type, 'N') = 'N' THEN
        RETURN REPLACE(ccm_rec.common_code_name, p_lookup_code || '-', '');

    ELSIF p_type = 'D' THEN
        RETURN cc_rec.common_code_desc;

    ELSIF p_type = 'A1' THEN
        RETURN cc_rec.code_data1_value;

    ELSIF p_type = 'A2' THEN
        RETURN cc_rec.code_data2_value;

    ELSIF p_type = 'A3' THEN
        RETURN cc_rec.code_data3_value;

    ELSIF p_type = 'A4' THEN
        RETURN cc_rec.code_data4_value;

    ELSIF p_type = 'A5' THEN
        RETURN cc_rec.code_data5_value;
    END IF;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END decode_lookup;


/*************************************************************************************************/
/* Program Name : decode_lookup_name                                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Lookup Type, Code를 받아 값을 Return한다.                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_lookup_type                     in    varchar2  Lookup Type                  */
/*                p_name                            in    varchar2  Name                         */
/*                p_type                            in    varchar2  Return 유형(N/D/A...)        */
/*                p_lang                            in    varchar2  Language                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION decode_lookup_name (p_lookup_type IN VARCHAR2
                            ,p_name        IN VARCHAR2
                            ,p_type        IN VARCHAR2 DEFAULT 'C'
                            ,p_lang        IN VARCHAR2 DEFAULT 'en'
                            )
RETURN VARCHAR2
IS
    cc_rec    lgcom_common_code_c%ROWTYPE;
    ccm_rec   lgcom_common_code_multi_lang_c%ROWTYPE;

BEGIN

    BEGIN    
        SELECT *
        INTO   ccm_rec
        FROM   (SELECT *
                FROM   lgcom_common_code_multi_lang_c
                WHERE  code_type_code   = p_lookup_type
                AND    common_code_name = p_name
                AND    language_code    = p_lang
                UNION ALL
                SELECT *
                FROM   lgcom_common_code_multi_lang_c  -- 영어만 셋업이 된 경우 영어로 보여줌
                WHERE  code_type_code   = p_lookup_type
                AND    common_code_name = p_name
                AND    language_code    = 'en'
               )
        WHERE  ROWNUM = 1
        ;

        SELECT *
        INTO   cc_rec
        FROM   lgcom_common_code_c
        WHERE  code_type_code = p_lookup_type
        AND    common_code    = ccm_rec.common_code
        ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN  -- Multi Language 셋업 안된 경우
        SELECT *
        INTO   cc_rec
        FROM   lgcom_common_code_c
        WHERE  code_type_code   = p_lookup_type
        AND    common_code_desc = p_name
        ;
    END;
    
    IF NVL(p_type, 'C') = 'C' THEN
        RETURN cc_rec.common_code;

    ELSIF p_type = 'D' THEN
        RETURN cc_rec.common_code_desc;

    ELSIF p_type = 'A1' THEN
        RETURN cc_rec.code_data1_value;

    ELSIF p_type = 'A2' THEN
        RETURN cc_rec.code_data2_value;

    ELSIF p_type = 'A3' THEN
        RETURN cc_rec.code_data3_value;

    ELSIF p_type = 'A4' THEN
        RETURN cc_rec.code_data4_value;

    ELSIF p_type = 'A5' THEN
        RETURN cc_rec.code_data5_value;
    END IF;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END decode_lookup_name;




/*************************************************************************************************/
/* Program Name : decode_message                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 메시지ID를 값을 Return한다.                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_message_id                      in    varchar2  메시지ID                     */
/*                p_type                            in    varchar2  Return 유형(C/D/T...)        */
/*                p_lang                            in    varchar2  Language                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION decode_message (p_message_id IN VARCHAR2
                        ,p_lang       IN VARCHAR2 DEFAULT 'en'
                        ,p_type       IN VARCHAR2 DEFAULT 'C'
                        )
RETURN VARCHAR2
IS

    csm_rec            lgcom_system_message_m%ROWTYPE;

BEGIN

    SELECT *
    INTO   csm_rec
    FROM   lgcom_system_message_m
    WHERE  system_message_id = p_message_id
    AND    language_code     = NVL(p_lang, 'en')
    ;

    IF NVL(p_type, 'C') = 'C' THEN
        RETURN csm_rec.message_detail_content;

    ELSIF p_type = 'D' THEN
        RETURN csm_rec.message_desc;

    ELSIF p_type = 'T' THEN
        RETURN csm_rec.message_type_code;
    END IF;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END decode_message;


/*************************************************************************************************/
/* Program Name : get_subsidiary_code_func                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 디폴트 법인코드(약어)를 Return한다.                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_subsidiary_code_func
RETURN VARCHAR2
IS
BEGIN
    RETURN lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SUBSIDIARY_CODE', 'A1');

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_subsidiary_code_func;


/*************************************************************************************************/
/* Program Name : get_subsidiary_code_func                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직ID 에 해당하는 법인코드(약어)를 Return한다.                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_organization_id                 in    NUMBER    조직ID(법인ID)               */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_subsidiary_code_func (p_organization_id IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    RETURN lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SUBSIDIARY_CODE', 'A1');

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_subsidiary_code_func;


/*************************************************************************************************/
/* Program Name : get_subsidiary_id_func                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직ID 에 해당하는 법인코드(약어)를 Return한다.                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    VARCHAR2  법인코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_subsidiary_id_func (p_subsidiary_code IN VARCHAR2)
RETURN NUMBER
IS
    v_ou_id                     NUMBER;
BEGIN

    SELECT organization_id
    INTO   v_ou_id
    FROM   lgcom_company_v 
    WHERE  short_code = p_subsidiary_code
    ;
    
    RETURN v_ou_id;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_subsidiary_id_func;


/*************************************************************************************************/
/* Program Name : get_subsidiary_name_func                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직ID 에 해당하는 법인명을 Return한다.                                        */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_organization_id                 in    NUMBER    조직ID(법인ID)               */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_subsidiary_name_func (p_organization_id IN NUMBER)
RETURN VARCHAR2
IS
    v_subsidiary_name    lgcom_company_v.name%TYPE;
BEGIN

    SELECT name 
    INTO   v_subsidiary_name
    FROM   lgcom_company_v 
    WHERE  short_code = get_subsidiary_code_func(p_organization_id)
    ;
    
    RETURN v_subsidiary_name;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_subsidiary_name_func;


/*************************************************************************************************/
/* Program Name : get_subsidiary_name_func                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 법인코드에 해당하는 법인명을 Return한다.                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    VARCHAR2  법인코드                     */
/*                p_type                            in    VARCHAR2  Short/Full                   */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_subsidiary_name_func (p_subsidiary_code IN VARCHAR2)
RETURN VARCHAR2
IS
    v_subsidiary_name    lgcom_company_v.name%TYPE;
BEGIN

    SELECT name 
    INTO   v_subsidiary_name
    FROM   lgcom_company_v 
    WHERE  short_code = p_subsidiary_code
    ;
    
    RETURN v_subsidiary_name;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_subsidiary_name_func;


/*************************************************************************************************/
/* Program Name : get_shift_type_code_func                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 특정일자에 해당하는 교대유형코드를 Return한다.                      */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_basis_date                      in    date      기준일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_shift_type_code_func (p_subsidiary_code IN VARCHAR2
                                  ,p_employee_no     IN VARCHAR2
                                  ,p_basis_date      IN DATE
                                  )
RETURN VARCHAR2
IS
    v_shift_type_code        emp_assig.attribute10%TYPE;

    v_date                   DATE;
    v_min_date               DATE;
    v_max_date               DATE;

BEGIN

    BEGIN
        SELECT attribute10 AS shift_type_code
        INTO   v_shift_type_code
        FROM   emp_assig
        WHERE  subsidiary_code  = p_subsidiary_code
        AND    employee_number  = p_employee_no
        AND    TO_CHAR(p_basis_date, 'YYYYMMDD') BETWEEN TO_CHAR(assignment_start_date, 'YYYYMMDD') AND attribute1
        ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        SELECT MIN(TRUNC(assignment_start_date)), MAX(TRUNC(assignment_start_date))
        INTO   v_min_date, v_max_date
        FROM   emp_assig
        WHERE  subsidiary_code = p_subsidiary_code
        AND    employee_number = p_employee_no
        ;
        
        IF (v_min_date IS NULL AND v_max_date IS NULL) THEN
            v_shift_type_code := '1A';  -- 발령정보가 없으면 단부제로 셋팅
        ELSE 
            IF (p_basis_date > v_max_date ) THEN
                v_date := v_max_date;
            ELSIF (p_basis_date < v_min_date) THEN
                v_date := v_min_date;
            END IF;
            
            SELECT attribute10 AS shift_type_code
            INTO   v_shift_type_code
            FROM   emp_assig
            WHERE  subsidiary_code  = p_subsidiary_code
            AND    employee_number  = p_employee_no
            AND    TO_CHAR(v_date, 'YYYYMMDD') BETWEEN TO_CHAR(assignment_start_date, 'YYYYMMDD') AND attribute1
            ;
        END IF;
    END;

    RETURN v_shift_type_code;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;   -- 에러인경우 1A 로?

END get_shift_type_code_func;


/*************************************************************************************************/
/* Program Name : get_shift_info_func                                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 일자/교대유형에 해당하는 교대조 정보를 Return한다.                             */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_basis_date                      in    date      기준일자                     */
/*                p_shift_type_code                 in    varchar2  교대유형코드                 */
/*                p_type                            in    varchar2  Return 유형                  */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_shift_info_func (p_subsidiary_code IN VARCHAR2
                             ,p_basis_date      IN DATE
                             ,p_shift_type_code IN VARCHAR2
                             ,p_type            IN VARCHAR2 DEFAULT 'DN'
                             )
RETURN VARCHAR2
IS
    ab_rec    tb_att_base_bas_n%ROWTYPE;
BEGIN

    SELECT * 
    INTO   ab_rec
    FROM   tb_att_base_bas_n ab
    WHERE  ab.subsidiary_code          = p_subsidiary_code
    AND    ab.time_and_attendance_date = p_basis_date
    AND    ab.shift_type_code          = p_shift_type_code
    ;
    
    IF (NVL(p_type, 'DN') = 'DN') THEN
        RETURN ab_rec.night_shift_flag;

    ELSIF (p_type = 'DayNight') THEN
        RETURN CASE WHEN ab_rec.night_shift_flag = 'Y' THEN 'Night' ELSE 'Day' END;

    ELSIF (p_type = 'AT') THEN
        RETURN ab_rec.attendance_time;

    ELSIF (p_type = 'LT') THEN
        RETURN ab_rec.leaving_office_time;
    END IF;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;   -- 에러인경우 'N' (Day) 으로?

END get_shift_info_func;



/*************************************************************************************************/
/* Program Name : get_org_resp_flag_func                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호가 특정일자에 조직책임자인지 여부를 Return한다.                        */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_basis_date                      in    date      일자(생략시 현재일자)        */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_org_resp_flag_func (p_subsidiary_code IN VARCHAR2
                                ,p_employee_no     IN VARCHAR2
                                ,p_basis_date      IN DATE     DEFAULT NULL
                                )
RETURN VARCHAR2
IS
    v_position_code  emp_assig.position%TYPE;
BEGIN

    SELECT position
    INTO   v_position_code
    FROM   emp_assig
    WHERE  subsidiary_code  = p_subsidiary_code
    AND    employee_number  = p_employee_no
    AND    TO_CHAR(p_basis_date, 'YYYYMMDD') BETWEEN TO_CHAR(assignment_start_date, 'YYYYMMDD') AND attribute1
    ;

/*
-- 조직 테이블에서도 체크할것인지 확인할것 : 단, 현재기준(2017/10/25) 조직테이블은 히스토리가 없음
SELECT om.org_manager_number
FROM   org_master om
WHERE  om.org_manager_number = p_employee_no
;
*/

    IF (v_position_code IS NOT NULL) THEN
    
        -- 조책대상아닌 직책이면
        IF (v_position_code IN ( '대상코드추가' )) THEN  -- -- 조직과 연계가 안되면, 조책비대상코드를 셋업으로 관리하도록 변경할것
            RETURN 'N';
        END IF;   

        RETURN 'Y';
    END IF;

    RETURN 'N';

EXCEPTION
WHEN OTHERS THEN
    RETURN 'N';

END get_org_resp_flag_func;


/*************************************************************************************************/
/* Program Name : get_application_user_id                                                        */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호에 해당하는 application_user_id를 Return한다.                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_application_user_id_func (p_subsidiary_code IN VARCHAR2
                                      ,p_employee_no     IN VARCHAR2
                                      )
RETURN NUMBER
IS
    v_application_user_id        lgcom_user_m.application_user_id%TYPE;
BEGIN

    SELECT application_user_id
    INTO   v_application_user_id
    FROM   lgcom_user_m
    WHERE  user_name = p_employee_no
    ;
    
    RETURN v_application_user_id;

EXCEPTION
WHEN OTHERS THEN
    RETURN -1;

END get_application_user_id_func;


/*************************************************************************************************/
/* Program Name : get_employee_no_func                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : application_user_id에 해당하는 사원번호를 Return한다.                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_application_user_id             in    number    유저ID                       */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_employee_no_func (p_subsidiary_code     IN VARCHAR2
                              ,p_application_user_id IN NUMBER
                              )
RETURN VARCHAR2
IS
    v_user_name        lgcom_user_m.user_name%TYPE;
BEGIN

    SELECT user_name
    INTO   v_user_name
    FROM   lgcom_user_m
    WHERE  application_user_id = p_application_user_id
    ;
    
    RETURN v_user_name;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_employee_no_func;


/*************************************************************************************************/
/* Program Name : get_mail_addr                                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호에 해당하는 메일주소를 Return한다.                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_mail_addr_func (p_subsidiary_code IN VARCHAR2
                            ,p_employee_no     IN VARCHAR2
                            )
RETURN VARCHAR2
IS
    v_mail_addr        lgcom_user_m.mail_addr%TYPE;
BEGIN

    SELECT mail_addr
    INTO   v_mail_addr
    FROM   lgcom_user_m t
    WHERE  user_name = p_employee_no
    ;
    
    RETURN v_mail_addr;

EXCEPTION
WHEN OTHERS THEN
    RETURN -1;

END get_mail_addr_func;


/*************************************************************************************************/
/* Program Name : get_mail_system_code_func                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 모듈코드에 해당하는 시스템코드를 Return한다.                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_module_code                     in    varchar2  모듈코드(LGVATT/LGVPAY/...)  */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_mail_system_code_func (p_subsidiary_code IN VARCHAR2
                                   ,p_module_code     IN VARCHAR2
                                   )
RETURN VARCHAR2
IS
    v_system_code             VARCHAR2(300);
BEGIN

    SELECT parent_common_code
    INTO   v_system_code
    FROM   lgcom_common_code_c
    WHERE  code_type_code = 'LGCOM_MODULE_CODE'
    AND    common_code    = p_module_code
    AND    use_flag       = 'Y'
    ;
    
    RETURN v_system_code;

EXCEPTION
WHEN OTHERS THEN
    RETURN '';

END get_mail_system_code_func;


/*************************************************************************************************/
/* Program Name : get_mail_title_func                                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 모듈코드에 해당하는 메일타이틀을 Return한다.                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_module_code                     in    varchar2  모듈코드(LGVATT/LGVPAY/...)  */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_mail_title_func (p_subsidiary_code IN VARCHAR2
                             ,p_module_code     IN VARCHAR2
                             )
RETURN VARCHAR2
IS
    v_mail_title             VARCHAR2(300);
BEGIN

    SELECT '[' || code_data1_value || '-' || code_data2_value || ']'
    INTO   v_mail_title
    FROM   lgcom_common_code_c
    WHERE  code_type_code = 'LGCOM_MODULE_CODE'
    AND    common_code    = p_module_code
    AND    use_flag       = 'Y'
    ;
    
    RETURN v_mail_title;

EXCEPTION
WHEN OTHERS THEN
    RETURN '';

END get_mail_title_func;


/*************************************************************************************************/
/* Program Name : get_mail_sender_func                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 메일발송 메일아이디를 Return한다.                                              */
/*                모듈에 따라 달리할 필요가 있을 경우에는, 모듈코드별 로직을 처리한다.           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_module_code                     in    varchar2  모듈코드(LGVATT/LGVPAY/...)  */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_mail_sender_func (p_subsidiary_code IN VARCHAR2
                              ,p_module_code     IN VARCHAR2 DEFAULT NULL
                              )
RETURN VARCHAR2
IS
    v_sender_email_addr           VARCHAR2(100);
BEGIN

    IF (p_module_code IS NULL) THEN
        v_sender_email_addr := lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SENDER_EMAIL_ADDR', 'A1');
    ELSE
        NULL;  -- 모듈에 해당하는 로직 추가할것
    END IF;
    
    RETURN v_sender_email_addr;

EXCEPTION
WHEN OTHERS THEN
    RETURN '';

END get_mail_sender_func;


/*************************************************************************************************/
/* Program Name : get_language_code_func                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 언어가 없을경우에 디폴트 언어코드를 Return한다.                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_language_code_func (p_subsidiary_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN lgvhr_common_pkg.decode_lookup ('LGVHR_COMMON_CODE', 'LANGUAGE_CODE', 'A1');  -- 디폴트언어
END get_language_code_func;


/*************************************************************************************************/
/* Program Name : get_organization_name_func                                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직명을 Return한다.                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_organization_id                 in    varchar2  조직ID                       */
/*                p_type                            in    varchar2  유형                         */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_organization_name_func (p_subsidiary_code IN VARCHAR2
                                    ,p_organization_id IN VARCHAR2
                                    ,p_type            IN VARCHAR2 DEFAULT NULL
                                    )
RETURN VARCHAR2
IS
    om_rec    org_master%ROWTYPE;
BEGIN

    SELECT *
    INTO   om_rec
    FROM   org_master om
    WHERE  om.organization_id = p_organization_id
    ;
    
    -- 필요시 p_type 에 따른 로직 추가
    
    RETURN om_rec.org_name_local;
    
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_organization_name_func;


/*************************************************************************************************/
/* Program Name : get_parent_org_id_func                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 모듈코드에 해당하는 메일타이틀을 Return한다.                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_organization_id                 in    number    조직ID                       */
/*                p_parent_org_type                 in    varchar2  상위유형코드                 */
/*                p_no_matched_flag                 in    varchar2  상위유형없을때여부           */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_parent_org_id_func (p_subsidiary_code  IN VARCHAR2
                                ,p_organization_id  IN NUMBER
                                ,p_parent_type_code IN VARCHAR2 DEFAULT NULL
                                ,p_no_matched_flag  IN VARCHAR2 DEFAULT 'Y'
                                )
RETURN NUMBER
IS
    v_parent_org_id             org_master.parent_org_id%TYPE;
BEGIN

    -- 상위유형이 없으면, 무조건 첫번째 상위유형
    IF (p_parent_type_code IS NULL) THEN
        SELECT parent_org_id 
        INTO   v_parent_org_id 
        FROM   org_master 
        WHERE  subsidiary_code = p_subsidiary_code 
        AND    organization_id = p_organization_id
        ;

        RETURN v_parent_org_id ;
    END IF;

    FOR org IN (
                SELECT om.organization_id         AS organization_id
                      ,om.org_name_local          AS organization_name
                      ,om.org_name_eng            AS organization_name_eng
                      ,om.org_start_date          AS organization_start_date
                      ,om.org_end_date            AS organization_end_date
                      ,cm.organization_level_code AS organization_type_code
                      ,om.org_type                AS organization_type_name
                      ,om.org_manager_number      AS organization_manager_no

                FROM   org_master           om
                      ,lgcom_organization_m cm

                START WITH om.subsidiary_code = p_subsidiary_code
                AND        om.organization_id = p_organization_id
                AND        om.organization_id = cm.organization_id

                CONNECT BY NOCYCLE  -- 무한루프 방지
                           PRIOR om.subsidiary_code = om.subsidiary_code
                AND        PRIOR om.parent_org_id   = om.organization_id
                AND        TRUNC(SYSDATE) BETWEEN om.org_start_date AND NVL(om.org_end_date, lgvhr_common_pkg.end_of_time)
                AND        om.organization_id   = cm.organization_id
               )
    LOOP
        IF (org.organization_type_code = p_parent_type_code) THEN

            -- 상위유형에 해당하는 조직ID
            RETURN org.organization_id;

        -- 상위유형이 없을때
        ELSIF (org.organization_type_code < p_parent_type_code) THEN

            -- 다음 상위유형 허용이면
            IF (NVL(p_no_matched_flag, 'Y') = 'Y') THEN
                -- 다음 상위유형에 해당하는 조직ID
                RETURN org.organization_id;
            ELSE
                RETURN NULL;
            END IF;
        END IF;
    END LOOP;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_parent_org_id_func;


/*************************************************************************************************/
/* Program Name : get_emp_master_rec                                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호에 해당하는 사원정보를 return 한다                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_emp_master_rec (p_subsidiary_code  IN VARCHAR2
                            ,p_employee_no      IN VARCHAR2
                            )
RETURN emp_master%ROWTYPE
IS
    em_rec                   emp_master%ROWTYPE;
BEGIN

    SELECT *
    INTO   em_rec
    FROM   emp_master
    WHERE  subsidiary_code = p_subsidiary_code
    AND    employee_number = p_employee_no
    ;

    RETURN em_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_emp_master_rec;


/*************************************************************************************************/
/* Program Name : get_org_master_rec                                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직ID에 해당하는 조직정보를 return 한다                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_organization_id                 in    varchar2  조직ID                       */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_org_master_rec (p_subsidiary_code  IN VARCHAR2
                            ,p_organization_id  IN VARCHAR2
                            )
RETURN org_master%ROWTYPE
IS
    om_rec                   org_master%ROWTYPE;
BEGIN

    SELECT *
    INTO   om_rec
    FROM   org_master
    WHERE  subsidiary_code = p_subsidiary_code
    AND    organization_id = p_organization_id
    ;

    RETURN om_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_org_master_rec;


/*************************************************************************************************/
/* Program Name : get_emp_assig_rec                                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호/발령일자에 해당하는 발령정보를 return 한다                            */
/*                발령일자가 없으면, 현재 유효한 발령정보를 return 한다.                         */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_assignment_date                 in    date      발령일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_emp_assig_rec (p_subsidiary_code IN VARCHAR2
                           ,p_employee_no     IN VARCHAR2
                           ,p_assignment_date IN DATE     DEFAULT NULL
                           )
RETURN emp_assig%ROWTYPE
IS
    ea_rec                   emp_assig%ROWTYPE;
BEGIN

    SELECT *
    INTO   ea_rec
    FROM   emp_assig
    WHERE  subsidiary_code = p_subsidiary_code
    AND    employee_number = p_employee_no
    AND    NVL(p_assignment_date, TRUNC(SYSDATE)) BETWEEN assignment_start_date AND TO_DATE(attribute1, 'YYYYMMDD')
    ;

    RETURN ea_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_emp_assig_rec;


END lgvhr_common_pkg;
/
