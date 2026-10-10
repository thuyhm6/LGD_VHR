CREATE OR REPLACE PACKAGE VHR_MGR.lgvhr_transaction_pkg
IS

PROCEDURE send_mail (p_ret_code        OUT NUMBER
                    ,p_ret_msg         OUT VARCHAR2
                    ,p_user_id         IN  VARCHAR2
                    ,p_subsidiary_code IN  VARCHAR2
                    ,p_mail_code       IN  VARCHAR2
                    ,p_receipt_info    IN  VARCHAR2
                    ,p_language_code   IN  VARCHAR2 DEFAULT NULL
                    ,p_mail_mapp       IN  VARCHAR2 DEFAULT NULL
                    ,p_sender_info     IN  VARCHAR2 DEFAULT NULL
                    ,p_cc_info         IN  VARCHAR2 DEFAULT NULL
                    ,p_subject_content IN  VARCHAR2 DEFAULT NULL
                    );
                    
PROCEDURE send_mail_clob (p_ret_code        OUT NUMBER
                         ,p_ret_msg         OUT VARCHAR2
                         ,p_user_id         IN  VARCHAR2
                         ,p_subsidiary_code IN  VARCHAR2
                         ,p_mail_code       IN  VARCHAR2
                         ,p_receipt_info    IN  VARCHAR2
                         ,p_language_code   IN  VARCHAR2 DEFAULT NULL
                         ,p_mail_mapp       IN  CLOB     DEFAULT NULL
                         ,p_sender_info     IN  VARCHAR2 DEFAULT NULL
                         ,p_cc_info         IN  VARCHAR2 DEFAULT NULL
                         ,p_subject_content IN  VARCHAR2 DEFAULT NULL
                         );
                    
END lgvhr_transaction_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvhr_transaction_pkg IS

/*************************************************************************************************/
/* Program Name : send_mail                                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태실적 결재요청을 처리후 결과를 Return 한다                                  */
/*                음수(< 0) : 오류                                                               */
/*                양수(> 0) : 메일발송 seq_id                                                    */
/*                                                                                               */
/*                p_mail_code = 셋업된메일코드                                                   */
/*                    코드값 : LGVHR_MAIL_TEMPLATE_LIST 에 셋업된 값                             */
/*                                                                                               */
/*                p_receipt_info = 수신자정보                                                    */
/*                                                                                               */
/*                p_mail_mapp = 메일내용의 가변값 매핑데이타                                     */
/*                    생략시 최소값으로 내부 처리                                                */
/*                    camel 표기 최소 : { "subject": { "none":"" }, "data1": { "none":"" } }     */
/*                                                                                               */
/*                    내용직접작성(DIRECT) 일때는, 메일내용                                      */
/*                                                                                               */
/*                p_sender_info  = 발신자정보                                                    */
/*                p_cc_info      = 참조자정보                                                    */
/*                    @ 없을때 : 사번                                                            */
/*                    @ 있을때 : 이메일주소                                                      */
/*                                                                                               */
/*                p_language_code = 언어                                                         */
/*                                                                                               */
/*                사용법 예)                                                                     */
/*                  send_mail (                                                                  */
/*                    p_mail_code     => 'DAY_ATT_NOT_APPR_1ST'                                  */
/*                   ,p_mail_mapp     => '{"subject":{"title":""},"data1":{"text":""}}'          */
/*                   ,p_sender_info   => NULL                                                    */
/*                   ,p_receipt_info  => 'VH??????'                                              */
/*                   ,p_cc_info       => 'email1@lgdisplay.com'                                  */
/*                   ,p_language_code => 'ko'                                                    */
/*                   );                                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_mail_code                       in    varchar2  메일코드                     */
/*                p_receipt_info                    in    varchar2  수신자 데이타                */
/*                p_mail_mapp                       in    varchar2  메일데이타                   */ 
/*                p_sender_info                     in    varchar2  발신자 데이타                */
/*                p_cc_info                         in    varchar2  참조자 데이타                */
/*                p_language_code                   in    varchar2  언어코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE send_mail (p_ret_code        OUT NUMBER
                    ,p_ret_msg         OUT VARCHAR2
                    ,p_user_id         IN  VARCHAR2
                    ,p_subsidiary_code IN  VARCHAR2
                    ,p_mail_code       IN  VARCHAR2
                    ,p_receipt_info    IN  VARCHAR2
                    ,p_language_code   IN  VARCHAR2 DEFAULT NULL
                    ,p_mail_mapp       IN  VARCHAR2 DEFAULT NULL
                    ,p_sender_info     IN  VARCHAR2 DEFAULT NULL
                    ,p_cc_info         IN  VARCHAR2 DEFAULT NULL
                    ,p_subject_content IN  VARCHAR2 DEFAULT NULL
                    )
IS
BEGIN

    send_mail_clob (p_ret_code
                   ,p_ret_msg
                   ,p_user_id
                   ,p_subsidiary_code
                   ,p_mail_code
                   ,p_receipt_info
                   ,p_language_code
                   ,CAST(p_mail_mapp AS CLOB)
                   ,p_sender_info
                   ,p_cc_info
                   ,p_subject_content
                   );

END send_mail;


PROCEDURE send_mail_clob (p_ret_code        OUT NUMBER
                         ,p_ret_msg         OUT VARCHAR2
                         ,p_user_id         IN  VARCHAR2
                         ,p_subsidiary_code IN  VARCHAR2
                         ,p_mail_code       IN  VARCHAR2
                         ,p_receipt_info    IN  VARCHAR2
                         ,p_language_code   IN  VARCHAR2 DEFAULT NULL
                         ,p_mail_mapp       IN  CLOB
                         ,p_sender_info     IN  VARCHAR2 DEFAULT NULL
                         ,p_cc_info         IN  VARCHAR2 DEFAULT NULL
                         ,p_subject_content IN  VARCHAR2 DEFAULT NULL
                         )
IS
    v_mail_id                     NUMBER;
    v_mail_seq_id                 NUMBER;    
    v_system_code                 VARCHAR2(100);
    v_module_code                 VARCHAR2(100);

    v_subject_content             lgcom_mail_info.subject_content%TYPE;
    v_mail_clob_data              lgcom_mail_info.mail_clob_data%TYPE;
    v_mail_clob_content           lgcom_mail_info.mail_clob_content%TYPE;
    v_mail_prefix                 VARCHAR2(300);
    
    v_mail_type_code              VARCHAR2(100);
    v_language_code               VARCHAR2(10);
    
    v_sender_email_addr           VARCHAR2(100);
    v_sender_emp_no               VARCHAR2(30);
    v_sender_emp_name             VARCHAR2(300);
    
    v_receipt_email_addr          VARCHAR2(2000);
    v_receipt_emp_no              VARCHAR2(30);
    v_receipt_emp_name            VARCHAR2(300);
    
    v_cc_email_addr               VARCHAR2(2000);
    v_cc_emp_no                   VARCHAR2(30);
    v_cc_emp_name                 VARCHAR2(300);
    

    v_map_pos1                    NUMBER;
    v_map_pos2                    NUMBER;
    v_map_str1                    VARCHAR2(1000);
    v_map_str2                    lgcom_mail_info.mail_clob_data%TYPE;
    v_direct_code                 lgcom_common_code_c.code_data2_value%TYPE;
BEGIN

    v_language_code   := NVL(p_language_code, lgvhr_common_pkg.get_language_code_func(p_subsidiary_code));
    
    BEGIN
        -- 임의의 제목(p_subject_content) 이 있으면 우선순위 : DIRECT 일때 제목을 가변적으로 하고자 할때 필요함
        SELECT cm.mail_id, cm.system_code, cm.module_code, NVL(p_subject_content, mc.subject_text),   'T' AS mail_type_code, NVL(cc.code_data2_value, 'MAPPING')
        INTO   v_mail_id,  v_system_code,  v_module_code,  v_subject_content,                         v_mail_type_code,      v_direct_code
        FROM   lgcom_mail_m         cm
              ,lgcom_common_code_c  cc
              ,lgcom_mail_content_n mc
        WHERE  cc.code_type_code              = 'LGVHR_MAIL_TEMPLATE_LIST'
        AND    cc.common_code                 = p_mail_code
        AND    TO_NUMBER(cc.code_data1_value) = cm.mail_id
        AND    cm.mail_id                     = mc.mail_id
        AND    mc.language_code               = v_language_code
        ;
        
        -- 메일 타이틀 Prefix
        v_mail_prefix := NULL;

        SELECT '[' || code_data1_value || '-' || code_data2_value || '] '
        INTO   v_mail_prefix
        FROM   lgcom_common_code_c
        WHERE  code_type_code = 'LGCOM_MODULE_CODE'
        AND    common_code    = v_module_code
        AND    use_flag       = 'Y'
        ;
        
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_ret_code := -1;
        p_ret_msg  := 'Mail Template does not exist.';
        RETURN ;
    END;
    
    -- 송신자 정보
    v_sender_email_addr := NULL;
    v_sender_emp_no     := NULL;
    v_sender_emp_name   := NULL;
    
    IF (p_sender_info IS NULL) THEN
        v_sender_email_addr := lgvhr_common_pkg.get_mail_sender_func (p_subsidiary_code);
    ELSE
        IF (INSTR(p_sender_info, '@') > 0) THEN
            v_sender_email_addr := TRIM(p_sender_info);
        ELSE
            SELECT mail_addr,           user_name,       full_name_local
            INTO   v_sender_email_addr, v_sender_emp_no, v_sender_emp_name
            FROM   lgcom_user_m_v
            WHERE  user_name = p_sender_info
            AND    ROWNUM    = 1
            ;
        END IF;
    END IF;

    -- 수신자 정보
    v_receipt_email_addr := NULL;
    v_receipt_emp_no     := NULL;
    v_receipt_emp_name   := NULL;
    
    IF (p_receipt_info IS NOT NULL) THEN
        IF (INSTR(p_receipt_info, '@') > 0) THEN
            v_receipt_email_addr := TRIM(p_receipt_info);
        ELSE
            SELECT mail_addr,            user_name,        full_name_local
            INTO   v_receipt_email_addr, v_receipt_emp_no, v_receipt_emp_name
            FROM   lgcom_user_m_v
            WHERE  user_name = p_receipt_info
            AND    ROWNUM    = 1
            ;
        END IF;
    END IF;

    -- 참조자 정보
    v_cc_email_addr := NULL;
    v_cc_emp_no     := NULL;
    v_cc_emp_name   := NULL;
    
    IF (p_cc_info IS NOT NULL) THEN
        IF (INSTR(p_cc_info, '@') > 0) THEN
            v_cc_email_addr := TRIM(p_cc_info);
            v_cc_emp_no     := NULL;
            v_cc_emp_name   := NULL;
        ELSE
            SELECT mail_addr,       user_name,   full_name_local
            INTO   v_cc_email_addr, v_cc_emp_no, v_cc_emp_name
            FROM   lgcom_user_m_v
            WHERE  user_name = p_cc_info
            AND    ROWNUM    = 1
            ;
        END IF;
    END IF;
    

    IF (v_sender_email_addr IS NULL) THEN
        p_ret_code := -1;
        p_ret_msg  := 'Sender e-mail does not exist.';
        RETURN ;
    END IF;

    IF (v_receipt_email_addr IS NULL) THEN
        p_ret_code := -1;
        p_ret_msg  := 'Recipient e-mail does not exist.';
        RETURN ;
    END IF;

    -- 메일내용 직접 작성이면
    IF (v_direct_code = 'DIRECT') THEN
        v_mail_id           := NULL;
        v_mail_clob_data    := NULL;
        v_mail_clob_content := p_mail_mapp;
        v_subject_content   := REPLACE(v_subject_content, '[prefix]', v_mail_prefix);
    ELSE
        -- 메일내용 매핑정보 : 없을경우 필수값 처리 : subject 는 웹에서 호출시에, 앞일수도, 뒤일수도 있음
        --{"subject":{"attDate":"09-11-2017"},"data1":{"empNo":"VH??????","empName":"HongGilDong"}}  -- subject 가 앞에
        --{"data1":{"empNo":"VH??????","empName":"HongGilDong"},"subject":{"attDate":"09-11-2017"}}  -- subject 가 뒤에
        v_mail_clob_data    := NVL(TRIM(p_mail_mapp), '{"subject":{"none":""},"data1":{"none":""}}');
        v_map_pos1          := INSTR(v_mail_clob_data, '"subject"');
        v_map_pos2          := INSTR(v_mail_clob_data, '{', v_map_pos1+LENGTH('"subject"'));
        v_map_str1          := SUBSTR(v_mail_clob_data, 1,  v_map_pos2);
        v_map_str2          := SUBSTR(v_mail_clob_data, v_map_pos2+1);
        v_mail_clob_data    := v_map_str1 || '"prefix":"' || v_mail_prefix || '",' || v_map_str2;
        v_mail_clob_content := NULL;
    END IF;


    -- Mail Sequence
    SELECT lgcom_mail_info_seq.NEXTVAL 
    INTO   v_mail_seq_id 
    FROM   dual
    ;
    
    INSERT INTO lgcom_mail_info
      ( seq_id                            ,system_code                       ,module_code                       ,mail_id 
       ,sender_email_addr                 ,receipt_email_addr                ,cc_email_addr                     ,type_code
       ,language_code                     ,subject_content                   ,mail_clob_data                    ,mail_clob_content 
       ,file_name                         ,status_code                       ,error_reason_desc                 
       ,created_by                        ,creation_date                     ,last_updated_by                   ,last_update_date       
      )
    VALUES
      ( v_mail_seq_id                     ,v_system_code                     ,v_module_code                     ,v_mail_id
       ,v_sender_email_addr               ,v_receipt_email_addr              ,v_cc_email_addr                   ,v_mail_type_code                  
       ,v_language_code                   ,v_subject_content                 ,v_mail_clob_data                  ,v_mail_clob_content
       ,NULL                              ,'N'                               ,NULL
       ,p_user_id                         ,SYSDATE                           ,p_user_id                         ,SYSDATE
     );

    p_ret_code := v_mail_seq_id;
    p_ret_msg  := ' ';

EXCEPTION
WHEN OTHERS THEN
    p_ret_code := -1;
    p_ret_msg  := SQLCODE || ': ' || 'Undefined error occurred.';

END send_mail_clob;


END lgvhr_transaction_pkg;
/
