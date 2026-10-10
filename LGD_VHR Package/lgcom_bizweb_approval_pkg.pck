CREATE OR REPLACE PACKAGE VHR_MGR.lgcom_bizweb_approval_pkg IS

    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : lgcom_bizweb_Approval_pkg.pls                               */
    /* Description  : 승인마스터 및 승인상세를 입력/삭제하는 패키지               */
    /*                다른 PGM 에서 호출되어 사용되며, 다른 PGM 에서 COmmit 처리  */
    /*                하여 본 프로그램에서는 Commit, Rollback 없음.               */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-30   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

    /***  Input Argument List and Desc
    
    1. pi_ou_id : Operating Unit[SAMPLE : 본사 = 89]
    2. pi_request_no : 업무에서 필요한 경우 문서번호를 별도 만들때 활용하는 칼럼[과거 SAMPLE : PON-1789903]
    3. pi_request_master_id : 업무에서 생성한 문서 혹은 승인번호[PK]
    4. pi_request_code : 업무별 승인 형태 코드[PK]
          [LOOLUP CODE SAMPLE : SELECT x.common_code FROM lgcom_common_code_c x WHERE  x.code_type_code = 'LGCOM_APPROVAL_REQUEST_CODE']
    5. pi_system_code : LGCOM 에 탑재된 시스템들에 대해서 부여된 시스템 코드[SAMPLE : 구매영역 = 'LGPRO']
    6. pi_module_code : LGCOM 에 탑재된 시스템내에 존재하는 모듈에 부여된 모듈 코드[SAMPLE : PON = 'LGPONM']
    7. pi_request_title : 요청 제목
    8. pi_comment_content : 요청업무 추가 내용
    9. pi_apply_status_code :
    10. pi_requestor_user_id : 요청서 작업자
    11.pi_purchase_type_code :
    12.pi_approval_on_off_flag :
    13.pi_submission_type_code : 승인문서 종류(Code Master 값 그대로) and 승인메일 제목으로 활용되므로 반드시 입력 필요
          [LOOLUP CODE SAMPLE : SELECT x.code_data2_value FROM lgcom_common_code_c x WHERE  x.code_type_code = 'LGCOM_APPROVAL_REQUEST_CODE']
    14.pi_source_document_code : 승인문서 종류(대문자 처리)
          [LOOLUP CODE SAMPLE : SELECT x.code_data2_value FROM lgcom_common_code_c x WHERE  x.code_type_code = 'LGCOM_APPROVAL_REQUEST_CODE']
    15.pi_doc_category_code : NULL
    16.pi_submit_objective_content : 각 업무별로 품의서를 올리는 목적에 대한 내용을 입력하는 칼럼으로 품의화면에 Read Only 로 조회
    17.pi_status_code : 최초 요청 시에는 10 : PRE REQUEST, 실제 승인 요청되면 20 : REQUESTED 인데 Insert 하는 경우는 10 임.
    ***/

    /*TYPE lgcom_getlist_in_params_rec IS RECORD (p_pgm_seq              VARCHAR2(30)
    ,p_org_id               NUMBER
    ,p_requestor_user_id    NUMBER
    ,p_requestor_emp_no     VARCHAR2(30)
    ,p_additional_type_code VARCHAR2(30)
    ,p_additional_code      VARCHAR2(30)
    ,p_rule1_type           VARCHAR2(30)
    ,p_rule1_code           VARCHAR2(30)
    ,p_rule2_type           VARCHAR2(30)
    ,p_rule2_code           VARCHAR2(30)
    ,p_range_code           VARCHAR2(30)
    ,p_uom_code             VARCHAR2(30)
    ,p_range_value          NUMBER);*/

    TYPE lgcom_getlist_out_params_rec IS RECORD(
         p_approval_seq           NUMBER
        ,p_approver_user_id       NUMBER
        ,p_approver_emp_no        VARCHAR2(30)
        ,p_approver_name          VARCHAR2(100)
        ,p_approver_position_code VARCHAR2(30)
        ,p_approver_position_name VARCHAR2(100)
        ,p_approver_dept_code     VARCHAR2(30)
        ,p_approver_dept_name     VARCHAR2(100)
        ,p_approval_type_meaning  VARCHAR2(30)
        ,p_delegate_flag          VARCHAR2(1)
        ,p_mandator_user_id       NUMBER
        ,p_mandator_emp_no        VARCHAR2(30)
        ,p_mandator_name          VARCHAR2(100)
        ,p_mandator_position_code VARCHAR2(30)
        ,p_mandator_position_name VARCHAR2(100)
        ,p_mandator_dept_code     VARCHAR2(30)
        ,p_mandator_dept_name     VARCHAR2(100));

    /*TYPE lgcom_raw_appr_line_rec IS RECORD(p_approval_step_id      NUMBER
                                           ,p_auth_mtrx_master_id   NUMBER
                                           ,p_auth_mtrx_detail_id   NUMBER
                                           ,p_approval_seqs         NUMBER
                                           ,p_approver_type_code    VARCHAR2(30)
                                           ,p_approver_lcl          VARCHAR2(40)
                                           ,p_approver_ucl          VARCHAR2(40)
                                           ,p_approval_type_code    VARCHAR2(30)
                                           ,p_attribute1            VARCHAR2(240));
    
    TYPE lgcom_requestor_hierarchy_rec IS RECORD (p_seq                  NUMBER
                                                  ,p_person_id            NUMBER
                                                  ,p_emp_no               VARCHAR2(30)
                                                  ,p_emp_name             VARCHAR2(100)
                                                  ,p_supervisor_id        NUMBER
                                                  ,p_dept_id              NUMBER
                                                  ,p_position_code        VARCHAR2(60));*/

    TYPE lgcom_getlist_out_params_tbl IS TABLE OF lgcom_getlist_out_params_rec INDEX BY BINARY_INTEGER;
    --TYPE lgcom_raw_appr_line_tbl       IS TABLE OF xxautt_raw_appr_line_rec       INDEX BY BINARY_INTEGER;
    --TYPE lgcom_requestor_hierarchy_tbl IS TABLE OF xxautt_requestor_hierarchy_rec INDEX BY BINARY_INTEGER;

    PROCEDURE main_proc(pi_command           IN VARCHAR2
                       ,pi_request_master_id IN NUMBER
                       ,pi_request_code      IN VARCHAR2
                       ,pi_user_id           IN NUMBER --요청,취소,요청취소,삭제일경우 요청자 id , 승인/반려일경우 승인자 id.
                       ,pi_comment           IN VARCHAR2
                       ,pi_portal_flag       IN VARCHAR2 DEFAULT 'N' --Y/N 통합결재 ToDo발송여부
                       ,pi_mail_flag         IN VARCHAR2 DEFAULT 'N' --Y/N 메일발송여부
                        --Out Parms
                       ,po_return_code OUT VARCHAR2
                       ,po_return_msg  OUT VARCHAR2);

    PROCEDURE request_create_proc(pi_request_master_id         IN NUMBER
                                 ,pi_request_code              IN VARCHAR2
                                 ,pi_organization_id           IN NUMBER
                                 ,pi_request_no                IN VARCHAR2
                                 ,pi_system_code               IN VARCHAR2 --DEFAULT 'LGEIH'
                                 ,pi_module_code               IN VARCHAR2
                                 ,pi_request_creation_code     IN VARCHAR2 DEFAULT 'CREATE'
                                 ,pi_status_code               IN VARCHAR2 DEFAULT '10'
                                 ,pi_process_status_code       IN VARCHAR2 DEFAULT NULL
                                 ,pi_apply_status_code         IN VARCHAR2 DEFAULT 'N'
                                 ,pi_request_title             IN VARCHAR2
                                 ,pi_comment_content           IN VARCHAR2
                                 ,pi_department_code           IN VARCHAR2
                                 ,pi_requestor_id              IN NUMBER --fnd_user.user id
                                 ,pi_request_date              IN DATE DEFAULT SYSDATE
                                 ,pi_attach_file_id            IN NUMBER
                                 ,pi_purchase_type_code        IN VARCHAR2
                                 ,pi_approval_on_off_flag      IN VARCHAR2
                                 ,pi_submission_type_code      IN VARCHAR2
                                 ,pi_source_document_code      IN VARCHAR2
                                 ,pi_concurrent_request_id     IN NUMBER
                                 ,pi_group_seq_no              IN NUMBER
                                 ,pi_doc_category_code         IN VARCHAR2
                                 ,pi_submit_objective_content  IN VARCHAR2 --pi_submission_objective_content
                                 ,pi_submission_content        IN CLOB
                                 ,pi_approver_screen_url_addr  IN VARCHAR2
                                 ,pi_approval_url_addr         IN VARCHAR2
                                 ,pi_requestor_screen_url_addr IN VARCHAR2
                                 ,pi_request_url_addr          IN VARCHAR2
                                  --Out Parms
                                 ,po_return_code OUT VARCHAR2
                                 ,po_return_msg  OUT VARCHAR2);

    PROCEDURE request_update_proc(pi_request_master_id         IN NUMBER
                                 ,pi_request_code              IN VARCHAR2
                                 ,pi_organization_id           IN NUMBER
                                 ,pi_request_no                IN VARCHAR2
                                 ,pi_system_code               IN VARCHAR2 --DEFAULT 'LGEIH'
                                 ,pi_module_code               IN VARCHAR2
                                 ,pi_request_creation_code     IN VARCHAR2 DEFAULT 'CREATE'
                                 ,pi_status_code               IN VARCHAR2 DEFAULT '10'
                                 ,pi_process_status_code       IN VARCHAR2 DEFAULT NULL
                                 ,pi_apply_status_code         IN VARCHAR2 DEFAULT 'N'
                                 ,pi_request_title             IN VARCHAR2
                                 ,pi_comment_content           IN VARCHAR2
                                 ,pi_department_code           IN VARCHAR2
                                 ,pi_requestor_id              IN NUMBER --fnd_user.user id
                                 ,pi_request_date              IN DATE DEFAULT SYSDATE
                                 ,pi_attach_file_id            IN NUMBER
                                 ,pi_purchase_type_code        IN VARCHAR2
                                 ,pi_approval_on_off_flag      IN VARCHAR2
                                 ,pi_submission_type_code      IN VARCHAR2
                                 ,pi_source_document_code      IN VARCHAR2
                                 ,pi_concurrent_request_id     IN NUMBER
                                 ,pi_group_seq_no              IN NUMBER
                                 ,pi_doc_category_code         IN VARCHAR2
                                 ,pi_submit_objective_content  IN VARCHAR2 --pi_submission_objective_content
                                 ,pi_submission_content        IN CLOB
                                 ,pi_approver_screen_url_addr  IN VARCHAR2
                                 ,pi_approval_url_addr         IN VARCHAR2
                                 ,pi_requestor_screen_url_addr IN VARCHAR2
                                 ,pi_request_url_addr          IN VARCHAR2
                                  --Out Parms
                                 ,po_return_code OUT VARCHAR2
                                 ,po_return_msg  OUT VARCHAR2);

    PROCEDURE approval_line_del_proc(pi_request_master_id IN NUMBER
                                    ,pi_request_code      IN VARCHAR2
                                    ,
                                     --Out Parms
                                     po_return_code OUT VARCHAR2
                                    ,po_return_msg  OUT VARCHAR2);

    PROCEDURE approval_line_create_proc(pi_request_master_id IN NUMBER
                                       ,pi_request_code      IN VARCHAR2
                                        --,pi_approval_seqs          IN NUMBER   DEFAULT NULL
                                       ,pi_organization_id IN NUMBER
                                        --,pi_process_seq_no         IN NUMBER   DEFAULT NULL
                                        --,pi_progress_code          IN VARCHAR2 DEFAULT NULL
                                       ,pi_user_no IN VARCHAR2
                                        --,pi_sign_user_no           IN VARCHAR2 DEFAULT NULL
                                        --,pi_approval_status_code   IN VARCHAR2 DEFAULT NULL
                                        --,pi_approval_date          IN DATE
                                       ,pi_approval_action_code IN VARCHAR2
                                        --,pi_approval_method_code   IN VARCHAR2
                                       ,pi_approval_duty_code     IN VARCHAR2
                                       ,pi_approval_comment       IN VARCHAR2 DEFAULT NULL
                                       ,pi_inspection_comment     IN VARCHAR2 DEFAULT NULL
                                       ,pi_share_flag             IN VARCHAR2 DEFAULT NULL
                                       ,pi_return_flag            IN VARCHAR2 DEFAULT NULL
                                       ,pi_mandator_employee_no   IN VARCHAR2
                                       ,pi_approval_line_id       IN VARCHAR2
                                       ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N' --재량권에서 가져온데이타이면 'Y'아니면 'N'
                                       ,pi_creator_user_id        IN NUMBER
                                        --Out Parms
                                       ,po_return_code OUT VARCHAR2
                                       ,po_return_msg  OUT VARCHAR2);

    PROCEDURE forward_request_proc(pi_request_master_id IN NUMBER
                                  ,pi_ou_id             IN NUMBER
                                  ,pi_request_code      IN VARCHAR2
                                   --,pi_approval_seqs          IN NUMBER
                                  ,pi_for_emp_no             IN VARCHAR2 --전달받는사람 사번
                                  ,pi_emp_no                 IN VARCHAR2 --전달자사번
                                  ,pi_inspection_comment     IN VARCHAR2 --검토요청 코멘트
                                  ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N'
                                  ,pi_portal_flag            IN VARCHAR2
                                  ,pi_mail_flag              IN VARCHAR2
                                   --Out Parms
                                  ,po_return_code OUT VARCHAR2
                                  ,po_return_msg  OUT VARCHAR2);

    PROCEDURE preview_request_proc(pi_request_master_id IN NUMBER
                                  ,pi_ou_id             IN NUMBER
                                  ,pi_request_code      IN VARCHAR2
                                   --,pi_approval_seqs          IN NUMBER   --preview생성 차수 30000이상
                                  ,pi_for_emp_no             IN VARCHAR2 --전달받는사람 사번
                                  ,pi_emp_no                 IN VARCHAR2 --전달자사번
                                  ,pi_inspection_comment     IN VARCHAR2 --검토요청 코멘트
                                  ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N' --재량권사용여부
                                  ,pi_share_flag             IN VARCHAR2 DEFAULT 'Y' --검토내용 공개여부
                                  ,pi_portal_flag            IN VARCHAR2
                                  ,pi_mail_flag              IN VARCHAR2
                                   --Out Parms
                                  ,po_return_code OUT VARCHAR2
                                  ,po_return_msg  OUT VARCHAR2);

    PROCEDURE preview_update_proc(pi_request_master_id IN NUMBER
                                 ,pi_ou_id             IN NUMBER
                                 ,pi_request_code      IN VARCHAR2
                                 ,pi_approval_seqs     IN NUMBER --preview 차수 30000이상
                                 ,pi_comment           IN VARCHAR2 --검토내용 코멘트
                                 ,pi_attach_file_id    IN NUMBER
                                  --Out Parms
                                 ,po_return_code OUT VARCHAR2
                                 ,po_return_msg  OUT VARCHAR2);

    PROCEDURE make_acpt_proc(pi_request_master_id IN NUMBER
                            ,pi_request_code      IN VARCHAR2
                            ,pi_approval_seqs     IN NUMBER
                            ,pi_request_status    IN VARCHAR2
                            ,pi_portal_flag       IN VARCHAR2
                            ,pi_mail_flag         IN VARCHAR2
                            ,pi_user_id           IN VARCHAR2
                            ,po_return_code       OUT VARCHAR2
                            ,po_return_msg        OUT VARCHAR2);

    PROCEDURE insert_acpt_proc(p_approval_system_code         IN VARCHAR2
                              ,p_approval_business_code       IN VARCHAR2
                              ,p_approval_business_prcs_no    IN VARCHAR2
                              ,p_approval_step_no             IN VARCHAR2
                              ,p_approval_title               IN VARCHAR2
                              ,p_requestor_name               IN VARCHAR2
                              ,p_requestor_employee_no        IN VARCHAR2
                              ,p_first_request_yyyymmdd       IN VARCHAR2
                              ,p_approval_step_name           IN VARCHAR2
                              ,p_approval_step_code           IN VARCHAR2
                              ,p_approver_name                IN VARCHAR2
                              ,p_approver_employee_no         IN VARCHAR2
                              ,p_delegate_name                IN VARCHAR2
                              ,p_delegate_employee_no         IN VARCHAR2
                              ,p_approval_line_change_flag    IN VARCHAR2
                              ,p_requestor_screen_url_addr    IN VARCHAR2
                              ,p_requestor_screen_param_value IN VARCHAR2
                              ,p_approver_screen_url_addr     IN VARCHAR2
                              ,p_approver_screen_param_value  IN VARCHAR2
                              ,p_register_ymdhms              IN VARCHAR2
                              ,p_interface_work_flag          IN VARCHAR2
                              ,p_eai_seq_id                   IN NUMBER
                              ,p_data_interface_type_code     IN CHAR
                              ,p_data_interface_date          IN DATE
                              ,p_eai_transfer_flag            IN CHAR
                               --,p_error_flag                     OUT VARCHAR2
                              ,po_return_code OUT VARCHAR2
                              ,po_return_msg  OUT VARCHAR2);

    PROCEDURE bit_mail_proc(pi_request_master_id         IN NUMBER
                           ,pi_module_code               IN VARCHAR2
                           ,pi_request_no                IN VARCHAR2
                           ,pi_mail_title                IN VARCHAR2
                           ,pi_register_ymdhms           IN VARCHAR2
                           ,pi_requestor_employee_no     IN VARCHAR2
                           ,pi_approver_employee_no      IN VARCHAR2
                           ,pi_status                    IN VARCHAR2
                           ,pi_requestor_screen_url_addr IN VARCHAR2
                           ,pi_requestor_screen_param    IN VARCHAR2
                           ,pi_approver_screen_url_addr  IN VARCHAR2
                           ,pi_approver_screen_param     IN VARCHAR2
                           ,pi_user_id                   IN NUMBER
                           ,pi_request_comment           IN VARCHAR2
                           ,pi_mail_templete_id          IN NUMBER
                           ,po_return_code               OUT VARCHAR2
                           ,po_return_msg                OUT VARCHAR2);

    FUNCTION call_arm_info_old(p_arm_no               IN VARCHAR2
                              , -- '2410'
                               p_org_id               IN NUMBER
                              , -- 89
                               p_emp_no               IN VARCHAR2
                              , -- 사번
                               p_additional_type_code IN VARCHAR2
                              , -- NULL
                               p_additional_code      IN VARCHAR2
                              , -- NULL
                               p_rule1_type           IN VARCHAR2
                              , -- NULL
                               p_rule1_code           IN VARCHAR2
                              , -- NULL
                               p_rule2_type           IN VARCHAR2
                              , -- NULL
                               p_rule2_code           IN VARCHAR2
                              , -- NULL   
                               p_range_code           IN VARCHAR2
                              , -- 'AMOUNT'
                               p_uom_code             IN VARCHAR
                              , -- 'KRW'
                               p_range_value          IN NUMBER -- 10000
                               ) RETURN lgcom_arm_out_tab
        PIPELINED;

    FUNCTION call_arm_info(p_arm_no               IN VARCHAR2
                          , -- '2410'
                           p_org_id               IN NUMBER
                          , -- 89
                           p_emp_no               IN VARCHAR2
                          , -- 사번
                           p_additional_type_code IN VARCHAR2
                          , -- NULL
                           p_additional_code      IN VARCHAR2
                          , -- NULL
                           p_rule1_type           IN VARCHAR2
                          , -- NULL
                           p_rule1_code           IN VARCHAR2
                          , -- NULL
                           p_rule2_type           IN VARCHAR2
                          , -- NULL
                           p_rule2_code           IN VARCHAR2
                          , -- NULL   
                           p_range_code           IN VARCHAR2
                          , -- 'AMOUNT'
                           p_uom_code             IN VARCHAR
                          , -- 'KRW'
                           p_range_value          IN NUMBER -- 10000
                           ) RETURN lgcom_approval_status_tbl
        PIPELINED;

    FUNCTION get_approval_info(p_user_id              IN NUMBER
                              ,p_position_code        IN VARCHAR2
                              ,p_portal_mandator_flag IN VARCHAR2 DEFAULT 'Y' --통합결재 위임여부
                               ) RETURN lgcom_approval_status_tbl;

    FUNCTION get_portal_mandator_info(p_approver_user_id IN NUMBER
                                      -- ,p_approval_action_code     IN VARCHAR2
                                      ) RETURN lgcom_approval_status_tbl;

    FUNCTION get_org_id_func(p_user_id NUMBER) RETURN NUMBER;

END lgcom_bizweb_approval_pkg;
/
create or replace package body vhr_mgr.lgcom_bizweb_approval_pkg is

    g_created_by        NUMBER;
    g_creation_date     DATE;
    g_last_updated_by   NUMBER;
    g_last_update_date  DATE;
    g_last_update_login NUMBER;

    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : lgcom_bizweb_Approval_pkg.pls                               */
    /* Description  : 승인마스터 및 승인상세를 입력/삭제하는 패키지               */
    /*                다른 PGM 에서 호출되어 사용되며, 다른 PGM 에서 COmmit 처리  */
    /*                하여 본 프로그램에서는 Commit, Rollback 없음.               */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-30   Kimhansik         1.0       Initial Release                   */
    /* 2017-10-23   Kimhansik         1.1       call_arm_info Function추가        */
    /******************************************************************************/

    PROCEDURE main_proc(pi_command           IN VARCHAR2
                       ,pi_request_master_id IN NUMBER
                       ,pi_request_code      IN VARCHAR2
                       ,pi_user_id           IN NUMBER  --요청,취소,요청취소,삭제일경우 요청자 id , 승인/반려일경우 승인자 id.
                       ,pi_comment           IN VARCHAR2
                       ,pi_portal_flag        IN VARCHAR2 DEFAULT 'N'--Y/N 통합결재 ToDo발송여부
                       ,pi_mail_flag          IN VARCHAR2 DEFAULT 'N'--Y/N 메일발송여부
                        --Out Parms
                       ,po_return_code       OUT VARCHAR2
                       ,po_return_msg        OUT VARCHAR2
                       ) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : lgcom_bizweb_Approval_pkg.pls                               */
    /* Description  : 승인마스터 및 승인상세를 입력/삭제하는 패키지               */
    /*                다른 PGM 에서 호출되어 사용되며, 다른 PGM 에서 COmmit 처리  */
    /*                하여 본 프로그램에서는 Commit, Rollback 없음.               */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-30   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        --p_command
        -->>요청자
        --REQUEST : 결재요청('REQUEST')
        --CANCEL : Cancel('CANCEL') -->CANCEL로 상태바꾸고 요청서 링크는 삭제함.
        --DELETE : 삭제
        --REQUESTCANCEL : 상신취소,Rewrite('REQUESTCANCEL')
        --REFERENCE,FORWARD,PREVIEW : 참조,전달,검토자지정
        -->>승인자
        --APPROVAL : 승인
        --REJECT : 반려
        --INSPECTION : 검토요청. 차후에 필요하면 추가....

        -- p_approval_type : 결재권자의 승인타입 lgcom_approval_status_n.approval_action_code
        --LGCOM_APPROVAL_ACTION_CODE(lgcom_common_code_c)
        -- APPROVAL,AGREEMENT,PARAGREE_ALL,PARAGREE_OR

        --Request Status(요청서 상태) lgcom_approval_request_n
        --LGCOM_APPROVAL_REQ_STATUS_CODE
        --10    PRE REQUEST
        --20    REQUESTED
        --30    INPROGRESS
        --40    APPROVED
        --50    REJECT
        --60    CANCEL
        --70    REQ.CANCEL

        --Approval Status(승인라인상태)(lgcom_common_code_c)
        --LGCOM_APPROVAL_STATUS_CODE
        --1   In Progress
        --2   Wait for Approval
        --3   Approved
        --4   Reject
        --5   Cancel
        
        --승인차수(lgcom_approval_status_n)
        --approval_seqs
        --0        Requestor
        --1~       Approver
        --10001 ~  Reference
        --20001 ~  Forward
        --30001 ~  Preview

        o_req_status_code      VARCHAR2(30);

        v_user_id              NUMBER;
        v_user_no              VARCHAR2(30);
        v_language_code        VARCHAR2(30);
        v_module_code          VARCHAR2(30);
        v_min_process_seq_no   NUMBER;
        v_max_process_seq_no   NUMBER;
        v_process_seq_no       NUMBER;

        v_next_flag            VARCHAR2(10);
        v_approval_status_code VARCHAR2(30);
        v_process_status_code  VARCHAR2(30);

        g_local_date  DATE;
        --g_return_code VARCHAR2(30);

        --v_approver_user_id        NUMBER;
        --v_approver_emp_no         VARCHAR2(100);
        --v_approver_emp_name       VARCHAR2(100);
        --v_approver_position_code  VARCHAR2(100);
        --v_approver_position_name  VARCHAR2(100);
        --v_approver_dept_code      VARCHAR2(100);
        --v_approver_dept_name      VARCHAR2(100);
        v_org_id                  NUMBER;
        --v_requestor_user_no       VARCHAR2(100);

        v_count                   NUMBER;
        v_mail_flag               VARCHAR2(10);
        v_update_seq              VARCHAR2(1);

        err_check EXCEPTION;

        cursor c_request is
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no,a.user_no,a.mandator_employee_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag = 'Y'
        AND    a.progress_code = '0002'
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.process_seq_no    = v_process_seq_no
        AND    a.approval_status_code = '1';

        cursor c_request_cancel is
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no,a.user_no,a.mandator_employee_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag = 'Y'
        AND    a.progress_code = '0002'
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.process_seq_no    = v_process_seq_no
        AND    a.approval_status_code = '2';

        cursor c_approval is
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag       = 'Y'
        AND    a.progress_code  = '0002'
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.approval_status_code = '2'
        AND    a.user_no           = v_user_no
        AND    a.approval_seqs in (SELECT min(las.approval_seqs)
                                    FROM   lgcom_approval_status_n las
                                          ,lgcom_common_code_c     c
                                    WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                                    AND    c.use_flag = 'Y'
                                    AND    las.progress_code = '0002'
                                    AND    las.approval_action_code = c.common_code
                                    AND    las.request_master_id = pi_request_master_id
                                    AND    las.request_code      = pi_request_code
                                    AND    las.approval_status_code = '2'
                                    AND    las.user_no           = v_user_no);

        cursor c_reference is--REFERENCE
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag = 'Y'
        AND    a.progress_code is null
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.approval_seqs     >= 10000--REFERENCE
        AND    a.approval_seqs     <  20000--REFERENCE
        AND    a.approval_status_code = '1';

        cursor c_forward is--FORWARD
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag = 'Y'
        AND    a.progress_code is null
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.approval_seqs     >= 20000--FORWARD
        AND    a.approval_seqs     <  30000--FORWARD
        AND    a.approval_status_code = '1';

        cursor c_preview is--PREVIEW
        SELECT a.approval_action_code,a.approval_seqs,a.process_seq_no
        FROM   lgcom_approval_status_n a
              ,lgcom_common_code_c     c
        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
        AND    c.use_flag = 'Y'
        AND    a.progress_code is null
        AND    a.approval_action_code = c.common_code
        AND    a.request_master_id = pi_request_master_id
        AND    a.request_code      = pi_request_code
        AND    a.approval_seqs     >= 30000--PREVIEW
        AND    a.approval_status_code = '1';

    BEGIN

        po_return_code := 'OK';

        begin
            SELECT r.organization_id
                  ,r.module_code
            INTO   v_org_id
                  ,v_module_code
            FROM   lgcom_approval_request_n r
            WHERE  r.request_master_id = pi_request_master_id
            AND    r.request_code      = pi_request_code;

        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := 'Module Select Error ';
              return;
        end;

        g_local_date := sysdate;--xxlge_mtz_pkg.ou_local_date(v_org_id);

        begin
            SELECT u.application_user_id
                  ,u.language_code
                  ,u.user_name
            INTO   v_user_id
                  ,v_language_code
                  ,v_user_no
            FROM   lgcom_user_m_v u
            WHERE  u.application_user_id = pi_user_id
            and    trunc(sysdate) between u.apply_start_date and u.apply_end_date;

        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := 'Parameter User No Select Error';
              return;
        end;

        begin
            --결재최저차수
            SELECT MIN(las.process_seq_no)
            INTO   v_min_process_seq_no
            FROM   lgcom_approval_status_n las
                  ,lgcom_common_code_c     c
            WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
            AND    c.use_flag = 'Y'
            AND    c.code_data3_value = 'APPROVAL'
            AND    las.approval_action_code = c.common_code
            AND    las.request_master_id    = pi_request_master_id
            AND    las.request_code         = pi_request_code
            AND    las.approval_seqs        = 1;
        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := '결재할 차수 Select Error '||SQLCODE||' '||SQLERRM;
              return;
        end;

        begin
            --결재최고차수
            SELECT MAX(las.process_seq_no)
            INTO   v_max_process_seq_no
            FROM   lgcom_approval_status_n las
                  ,lgcom_common_code_c     c
            WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
            AND    c.use_flag = 'Y'
            AND    las.progress_code = '0002'
            AND    las.approval_action_code = c.common_code
            AND    las.request_master_id    = pi_request_master_id
            AND    las.request_code         = pi_request_code;
        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := '결재최고 차수 Select Error '||SQLCODE||' '||SQLERRM;
              return;
        end;


        -- 결재요청(최초결재자 한번만 하면됨)
        --REFERENCE는 최초 승인요청시 자동으로 통합결재 요청됨.
        IF pi_command = 'REQUEST' THEN

            begin
                --결재할 차수
                SELECT MIN(las.process_seq_no)
                INTO   v_process_seq_no
                FROM   lgcom_approval_status_n las
                      ,lgcom_common_code_c     c
                WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                AND    c.use_flag = 'Y'
                AND    las.progress_code = '0002'
                AND    las.approval_action_code = c.common_code
                AND    las.request_master_id    = pi_request_master_id
                AND    las.request_code         = pi_request_code
                AND    las.approval_status_code = '1';
            exception
              when others then
                  po_return_code := 'NG';
                  po_return_msg  := '결재할 차수 Select Error '||SQLCODE||' '||SQLERRM;
                  return;
            end;

            v_update_seq := 0;

            for v_rec in c_request loop

                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code = '2'
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;

                --o_req_status_code := '20'; --10    PRE REQUEST,20 REQUESTED,30    INPROGRESS
               --update 오류로 seq이용하여  최초 한번만 update 함 (병렬 승인 오류 수정(kmw))
                IF v_update_seq = 0 THEN
                    UPDATE lgcom_approval_request_n
                    SET    status_code         = decode(status_code,'10','20'
                                                                   ,'20','30'
                                                                   ,'70','20'
                                                                   ,status_code)--o_req_status_code
                          ,process_status_code = v_rec.process_seq_no
                          ,request_date        = g_local_date
                          ,last_update_date    = g_local_date
                          ,last_updated_by     = v_user_id
                    WHERE  request_master_id = pi_request_master_id
                    AND    request_code      = pi_request_code;
                END IF;
                --통합결제 승인자에게 승인요청
                make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                               pi_request_code       => pi_request_code,
                               pi_approval_seqs      => v_rec.approval_seqs,
                               pi_request_status     => pi_command, --승인요청
                               pi_portal_flag        => pi_portal_flag,
                               pi_mail_flag          => pi_mail_flag,
                               pi_user_id            => v_user_id,
                               po_return_code        => po_return_code,
                               po_return_msg         => po_return_msg);

                if po_return_code = 'OK' then
                    NULL;
                else
                    rollback;
                    return;
                end if;
                 v_update_seq := v_update_seq + 1;

            end loop;


        ELSIF pi_command = 'CANCEL' THEN

            --
            --요청취소
            --1단계 작성중상태에서만 취소 가능
            --g_step := '5.Line status Select';
            SELECT approval_status_code
            INTO   v_approval_status_code
            FROM   lgcom_approval_status_n a
            WHERE  a.request_master_id = pi_request_master_id
            AND    a.request_code      = pi_request_code
            AND    a.approval_seqs = 1;

            --'1' In Progress(작성중)
            IF v_approval_status_code = '1' THEN

                o_req_status_code := '60'; -- CANCEL

                UPDATE lgcom_approval_request_n
                SET    status_code      = o_req_status_code
                      ,last_update_date = g_local_date
                      ,last_updated_by  = v_user_id
                WHERE  request_master_id = pi_request_master_id
                AND    request_code      = pi_request_code;

            ELSE
                --You cannot modify the confirmed data.
                --g_step     := 'You cannot Request Cancel';
                po_return_msg := 'error.notChangeConfirmData';
                RAISE err_check;
            END IF;

        ELSIF pi_command = 'DELETE' THEN
            --
            --요청삭제
            --1단계 작성중상태에서만 삭제 가능
            --g_step := '5.Line status Select';
            v_next_flag := 'N';

            begin
                SELECT 'Y'
                INTO   v_next_flag
                FROM   lgcom_approval_request_n t
                WHERE  1 = 1
                AND    t.request_master_id = pi_request_master_id
                AND    t.request_code      = pi_request_code
                AND    t.status_code       in ( '10','60','70') --삭제상태는 PRE REQUEST,CANCEL,REQ.CANCEL 만 가능함.(Detail 이 없는 상태임.)
                AND    ROWNUM = 1;
            exception
              when others then
                v_next_flag := 'N';
                po_return_code := 'NG';
                po_return_msg := 'You can not delete because of inprogress of approval.';
                return;
            end;

            -- 삭제대상이 PRE REQUEST 인 상태가 존재하면 수행
            IF v_next_flag = 'Y' THEN
                delete
                from   lgcom_approval_request_n lar
                where  lar.request_master_id = pi_request_master_id
                and    lar.request_code      = pi_request_code;

                delete
                from   lgcom_approval_status_n las
                where  las.request_master_id = pi_request_master_id
                and    las.request_code      = pi_request_code;
            end if;

        ELSIF pi_command = 'REQUESTCANCEL' THEN

            begin
                --결재할 차수
                SELECT MIN(las.process_seq_no)
                INTO   v_process_seq_no
                FROM   lgcom_approval_status_n las
                      ,lgcom_common_code_c     c
                WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                AND    c.use_flag = 'Y'
                AND    las.progress_code = '0002'
                AND    las.approval_action_code = c.common_code
                AND    las.request_master_id    = pi_request_master_id
                AND    las.request_code         = pi_request_code
                AND    las.approval_status_code = '2';
            exception
              when others then
                  po_return_code := 'NG';
                  po_return_msg  := '결재할 차수 Select Error '||SQLCODE||' '||SQLERRM;
                  return;
            end;
            --요청취소
            for v_rec in c_request_cancel loop

                --통합결제
                if pi_portal_flag = 'Y' then
                    make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                   pi_request_code       => pi_request_code,
                                   pi_approval_seqs      => v_rec.approval_seqs,
                                   pi_request_status     => pi_command, --요청취소
                                   pi_portal_flag        => pi_portal_flag,
                                   pi_mail_flag          => pi_mail_flag,
                                   pi_user_id            => v_user_id,
                                   po_return_code        => po_return_code,
                                   po_return_msg         => po_return_msg);

                    if po_return_code = 'OK' then
                        NULL;
                    else
                        rollback;
                        return;
                    end if;
                end if;

                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code =  '1' --In Progress
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;

                o_req_status_code := '70'; -- REQ.CANCEL--PRE REQUEST
                UPDATE lgcom_approval_request_n
                SET    status_code         = o_req_status_code
                      ,process_status_code = NULL
                      ,last_update_date    = g_local_date
                      ,last_updated_by     = v_user_id
                WHERE  request_master_id = pi_request_master_id
                AND    request_code      = pi_request_code;


            end loop;

        ELSIF pi_command = 'REFERENCE' THEN

            --REFERENCE(참조)
            for v_rec in c_reference loop

                --통합결제
                if pi_portal_flag = 'Y' then
                    make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                   pi_request_code       => pi_request_code,
                                   pi_approval_seqs      => v_rec.approval_seqs,
                                   pi_request_status     => pi_command,
                                   pi_portal_flag        => pi_portal_flag,
                                   pi_mail_flag          => pi_mail_flag,
                                   pi_user_id            => v_user_id,
                                   po_return_code        => po_return_code,
                                   po_return_msg         => po_return_msg);

                    if po_return_code = 'OK' then
                        NULL;
                    else
                        rollback;
                        return;
                    end if;
                end if;

                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code =  '2'--조회하면 '3'으로 변경.
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;


            end loop;

        ELSIF pi_command = 'FORWARD' THEN

            --FORWARD(전달)
            for v_rec in c_forward loop

                --통합결제
                if pi_portal_flag = 'Y' then
                    make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                   pi_request_code       => pi_request_code,
                                   pi_approval_seqs      => v_rec.approval_seqs,
                                   pi_request_status     => pi_command,
                                   pi_portal_flag        => pi_portal_flag,
                                   pi_mail_flag          => pi_mail_flag,
                                   pi_user_id            => v_user_id,
                                   po_return_code        => po_return_code,
                                   po_return_msg         => po_return_msg);

                    if po_return_code = 'OK' then
                        NULL;
                    else
                        rollback;
                        return;
                    end if;
                end if;

                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code =  '2'--조회하면 '3'으로 변경.
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;

            end loop;

        ELSIF pi_command = 'PREVIEW' THEN

            --PREVIEW(검토자지정)
            for v_rec in c_preview loop

                --통합결제
                if pi_portal_flag = 'Y' then
                    make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                   pi_request_code       => pi_request_code,
                                   pi_approval_seqs      => v_rec.approval_seqs,
                                   pi_request_status     => pi_command,
                                   pi_portal_flag        => pi_portal_flag,
                                   pi_mail_flag          => pi_mail_flag,
                                   pi_user_id            => v_user_id,
                                   po_return_code        => po_return_code,
                                   po_return_msg         => po_return_msg);

                    if po_return_code = 'OK' then
                        NULL;
                    else
                        rollback;
                        return;
                    end if;
                end if;

                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code =  '2'--검토완료하면 '3'으로 변경.
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;


            end loop;

            --승인시
        ELSIF pi_command = 'APPROVAL' THEN

            begin
                --결재할 차수
                SELECT MIN(las.process_seq_no)
                INTO   v_process_seq_no
                FROM   lgcom_approval_status_n las
                      ,lgcom_common_code_c     c
                WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                AND    c.use_flag = 'Y'
                AND    las.progress_code = '0002'
                AND    las.approval_action_code = c.common_code
                AND    las.request_master_id    = pi_request_master_id
                AND    las.request_code         = pi_request_code
                AND    las.user_no              = v_user_no
                AND    las.approval_status_code = '2';

            exception
              when others then
                  po_return_code := 'NG';
                  po_return_msg  := '결재할 차수 Select Error '||SQLCODE||' '||SQLERRM;
                  return;
            end;

            --승인
            for v_rec in c_approval loop

                --통합결제 승인처리
                make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                               pi_request_code       => pi_request_code,
                               pi_approval_seqs      => v_rec.approval_seqs,
                               pi_request_status     => 'APPROVAL', --승인
                               pi_portal_flag        => pi_portal_flag,
                               pi_mail_flag          => 'N',--pi_mail_flag,
                               pi_user_id            => v_user_id,
                               po_return_code        => po_return_code,
                               po_return_msg         => po_return_msg);

                if po_return_code = 'OK' then
                    NULL;
                else
                    rollback;
                    return;
                end if;

                --승인처리
                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code = '3' --Approved -- 'APPROVAL'
                      ,a.approval_comment     = pi_comment
                      ,a.approval_date        = g_local_date
                      ,a.sign_user_no         = v_user_no
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.approval_seqs     = v_rec.approval_seqs;

                v_next_flag := 'Y';

                if v_rec.approval_action_code = 'PARAGREE_ALL' then
                    -- 병렬합의_ALL 승인일경우 미승인된 다른건이 있는지 확인.
                    begin

                        SELECT 'N'
                        INTO   v_next_flag
                        FROM   lgcom_approval_status_n a
                              ,lgcom_common_code_c     c
                        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                        AND    c.use_flag = 'Y'
                        AND    a.approval_action_code = c.common_code
                        AND    a.request_master_id = pi_request_master_id
                        AND    a.request_code      = pi_request_code
                        AND    a.process_seq_no    = v_rec.process_seq_no
                        AND    a.approval_status_code = '2'--Wait for Approval
                        AND    rownum = 1;
                    exception
                      when others then
                        v_next_flag := 'Y';
                    end;

                elsif v_rec.approval_action_code = 'PARAGREE_OR' then

                    v_process_status_code := '00';
                    begin
                        select lar.process_status_code
                        into   v_process_status_code--현재 결재진행차수
                        from   lgcom_approval_request_n lar
                        where  lar.request_master_id = pi_request_master_id
                        and    lar.request_code      = pi_request_code;

                    exception
                      when others then
                        null;
                    end;

                    if v_process_status_code = to_char(v_rec.process_seq_no) then
                        --지금 승인한 차수와 Header의 차수가 같으면 다음 진행
                        v_next_flag := 'Y';
                    else
                        --지금 승인한 차수와 Header의 차수가 다르면 종료
                        v_next_flag := 'N';
                    end if;

                end if;

                if v_next_flag = 'Y' then

                    IF v_max_process_seq_no = v_rec.process_seq_no  THEN
                        --최종승인자이면 완료처리

                        o_req_status_code := '40'; --APPROVED
                        UPDATE lgcom_approval_request_n
                        SET    status_code         = o_req_status_code
                              --,process_status_code = v_process_seq_no
                              ,request_date        = g_local_date
                              ,last_update_date    = g_local_date
                              ,last_updated_by     = v_user_id
                        WHERE  request_master_id = pi_request_master_id
                        AND    request_code      = pi_request_code;

                        if pi_mail_flag = 'Y' then
                            --최종승인완료시 작성자에게 메일링.
                            make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                           pi_request_code       => pi_request_code,
                                           pi_approval_seqs      => v_rec.approval_seqs,
                                           pi_request_status     => 'APPROVED', --최종승인
                                           pi_portal_flag        => 'N',
                                           pi_mail_flag          => pi_mail_flag,
                                           pi_user_id            => v_user_id,
                                           po_return_code        => po_return_code,
                                           po_return_msg         => po_return_msg);

                            if po_return_code = 'OK' then
                                NULL;
                            else
                                rollback;
                                return;
                            end if;
                        end if;

                        --참조발송을 통합결재 완료후로 변경(2017-02-15 kimhansik)
                        for v_ref in c_reference loop
                            --REFERENCE는 통합결재 위임 적용않함.

                            UPDATE lgcom_approval_status_n a
                            SET    a.approval_status_code = '2'
                                  ,a.last_update_date     = g_local_date
                                  ,a.last_updated_by      = v_user_id
                            WHERE  a.request_master_id = pi_request_master_id
                            AND    a.request_code      = pi_request_code
                            AND    a.approval_seqs     = v_ref.approval_seqs;

                            --통합결제 승인자에게 승인요청
                            make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                           pi_request_code       => pi_request_code,
                                           pi_approval_seqs      => v_ref.approval_seqs,
                                           pi_request_status     => 'REFERENCE', --참조자
                                           pi_portal_flag        => pi_portal_flag,
                                           pi_mail_flag          => pi_mail_flag,
                                           pi_user_id            => v_user_id,
                                           po_return_code        => po_return_code,
                                           po_return_msg         => po_return_msg);

                            if po_return_code = 'OK' then
                                NULL;
                            else
                                rollback;
                                return;
                            end if;

                        end loop;

                    ELSE
                        --다음단계결재자 승인대기상태로 변경
                        --다음차수
                        SELECT MIN(a.process_seq_no)
                        INTO   v_process_seq_no
                        FROM   lgcom_approval_status_n a
                              ,lgcom_common_code_c     c
                        WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                        AND    c.use_flag = 'Y'
                        AND    a.progress_code = '0002'
                        AND    a.approval_action_code = c.common_code
                        AND    a.request_master_id    = pi_request_master_id
                        AND    a.request_code         = pi_request_code
                        AND    a.approval_status_code = '1'
                        AND    a.process_seq_no       > v_rec.process_seq_no;

                        o_req_status_code := '30'; --INPROGRESS
                        UPDATE lgcom_approval_request_n
                        SET    status_code         = o_req_status_code
                              ,process_status_code = v_process_seq_no
                              ,last_update_date    = g_local_date
                              ,last_updated_by     = v_user_id
                        WHERE  request_master_id = pi_request_master_id
                        AND    request_code      = pi_request_code;

                        --v_process_seq_n는 다음차수승인요청에서 사용함.
                        for v_next in c_request loop

                            UPDATE lgcom_approval_status_n a
                            SET    a.approval_status_code = '2'
                                  ,a.last_update_date     = g_local_date
                                  ,a.last_updated_by      = v_user_id
                            WHERE  a.request_master_id = pi_request_master_id
                            AND    a.request_code      = pi_request_code
                            AND    a.approval_seqs     = v_next.approval_seqs;

                            --통합결제 다음차수 승인자에게 승인요청
                            make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                           pi_request_code       => pi_request_code,
                                           pi_approval_seqs      => v_next.approval_seqs,
                                           pi_request_status     => 'REQUEST', --승인요청
                                           pi_portal_flag        => pi_portal_flag,
                                           pi_mail_flag          => pi_mail_flag,
                                           pi_user_id            => v_user_id,
                                           po_return_code        => po_return_code,
                                           po_return_msg         => po_return_msg);

                            if po_return_code = 'OK' then
                                NULL;
                            else
                                rollback;
                                return;
                            end if;

                        end loop;
                    end if;

                end if;

            end loop;

        ELSIF pi_command = 'REJECT' THEN

            begin
                --결재할 차수
                SELECT MIN(las.process_seq_no)
                INTO   v_process_seq_no
                FROM   lgcom_approval_status_n las
                      ,lgcom_common_code_c     c
                WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                AND    c.use_flag = 'Y'
                AND    las.progress_code = '0002'
                AND    las.approval_action_code = c.common_code
                AND    las.request_master_id    = pi_request_master_id
                AND    las.request_code         = pi_request_code
                AND    las.approval_status_code = '2';
            exception
              when others then
                  po_return_code := 'NG';
                  po_return_msg  := '결재할 차수 Select Error '||SQLCODE||' '||SQLERRM;
                  return;
            end;

            --반려
            v_count := 0;
            for v_rec in c_approval loop

                v_count := v_count + 1;

                if v_count = 1 then
                    v_mail_flag := pi_mail_flag;
                else
                    v_mail_flag := 'N';

                end if;

                if pi_command = 'PARAGREE_OR' then
                    null;
                else
                    --통합결제 반려처리
                    if pi_portal_flag = 'Y' then
                        make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                       pi_request_code       => pi_request_code,
                                       pi_approval_seqs      => v_rec.approval_seqs,
                                       pi_request_status     => 'REJECT', --반려
                                       pi_portal_flag        => pi_portal_flag,
                                       pi_mail_flag          => v_mail_flag,
                                       pi_user_id            => v_user_id,
                                       po_return_code        => po_return_code,
                                       po_return_msg         => po_return_msg);

                        if po_return_code = 'OK' then
                            NULL;
                        else
                            rollback;
                            return;
                        end if;
                    end if;
                end if;

                --반려처리
                UPDATE lgcom_approval_status_n a
                SET    a.approval_status_code = '4' --Reject -- 'REJECT'
                      ,a.approval_comment     = decode(a.user_no,v_user_no,pi_comment,'Auto Reject')
                      ,a.approval_date        = g_local_date
                      ,a.sign_user_no         = v_user_no
                      ,a.last_update_date     = g_local_date
                      ,a.last_updated_by      = v_user_id
                WHERE  a.request_master_id = pi_request_master_id
                AND    a.request_code      = pi_request_code
                AND    a.progress_code     = '0002'
                AND    a.approval_seqs     = v_rec.approval_seqs;

                v_next_flag := 'Y';

                if pi_command = 'PARAGREE_OR' then
                        --추가 승인대기자가 존재하는지여부
                        v_next_flag := 'N';
                        begin
                            SELECT 'Y'
                            INTO   v_next_flag
                            FROM   lgcom_approval_status_n a
                                  ,lgcom_common_code_c     c
                            WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                            AND    c.use_flag = 'Y'
                            AND    a.approval_action_code = c.common_code
                            AND    a.request_master_id = pi_request_master_id
                            AND    a.request_code      = pi_request_code
                            AND    a.progress_code     = '0002'
                            --AND    a.process_seq_no    = v_rec.process_seq_no
                            AND    a.approval_status_code = '2'--Wait for Approval
                            AND    rownum = 1;

                        exception
                          when others then
                            v_next_flag := 'N';
                        end;

                        if v_next_flag = 'N' then--추가 결재자가 없을경우

                            --현재 차수의 전체가 반려했는지확인
                            v_next_flag := 'N';
                            begin
                                SELECT 'Y'
                                INTO   v_next_flag
                                FROM   lgcom_approval_status_n a
                                      ,lgcom_common_code_c     c
                                WHERE  c.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                                AND    c.use_flag = 'Y'
                                AND    a.approval_action_code = c.common_code
                                AND    a.request_master_id = pi_request_master_id
                                AND    a.request_code      = pi_request_code
                                AND    a.process_seq_no    = v_rec.process_seq_no
                                AND    a.approval_status_code <> '4'--반려가 아닌 데이타
                                AND    rownum = 1;

                            exception
                              when others then
                                v_next_flag := 'N';
                            end;

                            if v_next_flag = 'N' then

                                --통합결제 반려처리
                                if pi_portal_flag = 'Y' then
                                    make_acpt_proc(pi_request_master_id  => pi_request_master_id,
                                                   pi_request_code       => pi_request_code,
                                                   pi_approval_seqs      => v_rec.approval_seqs,
                                                   pi_request_status     => 'REJECT', --반려
                                                   pi_portal_flag        => pi_portal_flag,
                                                   pi_mail_flag          => v_mail_flag,
                                                   pi_user_id            => v_user_id,
                                                   po_return_code        => po_return_code,
                                                   po_return_msg         => po_return_msg);

                                    if po_return_code = 'OK' then
                                        NULL;
                                    else
                                        rollback;
                                        return;
                                    end if;
                                end if;

                                o_req_status_code := '50'; --REJECT

                                UPDATE lgcom_approval_request_n
                                SET    status_code         = o_req_status_code
                                      --,process_status_code = v_rec.process_seq_no
                                      ,request_date        = g_local_date
                                      ,last_update_date    = g_local_date
                                      ,last_updated_by     = v_user_id
                                WHERE  request_master_id = pi_request_master_id
                                AND    request_code      = pi_request_code;
                            end if;

                        end if;
                else

                    o_req_status_code := '50'; --REJECT

                    UPDATE lgcom_approval_request_n
                    SET    status_code         = o_req_status_code
                          --,process_status_code = v_rec.process_seq_no
                          ,request_date        = g_local_date
                          ,last_update_date    = g_local_date
                          ,last_updated_by     = v_user_id
                    WHERE  request_master_id = pi_request_master_id
                    AND    request_code      = pi_request_code;
                end if;


            end loop;

        ELSE
            --g_step     := 'Command Error p_approval_comment :' || p_approval_comment;
            po_return_code := 'NG';
            po_return_msg := 'error.xssException';
            RAISE err_check;

        END IF;


    EXCEPTION
        WHEN err_check THEN
            po_return_code := 'NG';
            po_return_msg    := NVL(po_return_msg, 'error.applicationError');
            --o_return_msg  := g_step;
            ROLLBACK;
        WHEN OTHERS THEN
            po_return_code := 'NG';
            po_return_msg    := SQLCODE||' '||SQLERRM;
            --o_return_msg  := g_step || ':' || SQLERRM;
            ROLLBACK;
    END main_proc;

    PROCEDURE request_create_proc( pi_request_master_id             IN NUMBER
                                  ,pi_request_code                  IN VARCHAR2
                                  ,pi_organization_id               IN NUMBER
                                  ,pi_request_no                    IN VARCHAR2
                                  ,pi_system_code                   IN VARCHAR2   --DEFAULT 'LGCOM'
                                  ,pi_module_code                   IN VARCHAR2
                                  ,pi_request_creation_code         IN VARCHAR2   DEFAULT 'CREATE'
                                  ,pi_status_code                   IN VARCHAR2   DEFAULT '10'
                                  ,pi_process_status_code           IN VARCHAR2   DEFAULT NULL
                                  ,pi_apply_status_code             IN VARCHAR2   DEFAULT 'N'
                                  ,pi_request_title                 IN VARCHAR2
                                  ,pi_comment_content               IN VARCHAR2
                                  ,pi_department_code               IN VARCHAR2
                                  ,pi_requestor_id                  IN NUMBER      --fnd_user.user id
                                  ,pi_request_date                  IN DATE        DEFAULT sysdate
                                  ,pi_attach_file_id                IN NUMBER
                                  ,pi_purchase_type_code            IN VARCHAR2
                                  ,pi_approval_on_off_flag          IN VARCHAR2
                                  ,pi_submission_type_code          IN VARCHAR2
                                  ,pi_source_document_code          IN VARCHAR2
                                  ,pi_concurrent_request_id         IN NUMBER
                                  ,pi_group_seq_no                  IN NUMBER
                                  ,pi_doc_category_code             IN VARCHAR2
                                  ,pi_submit_objective_content      IN VARCHAR2--pi_submission_objective_content
                                  ,pi_submission_content            IN CLOB
                                  ,pi_approver_screen_url_addr      IN VARCHAR2
                                  ,pi_approval_url_addr             IN VARCHAR2
                                  ,pi_requestor_screen_url_addr     IN VARCHAR2
                                  ,pi_request_url_addr              IN VARCHAR2
                                  --Out Parms
                                 ,po_return_code    OUT VARCHAR2
                                 ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : request_create_proc.pls                                     */
    /* Description  : 공통 결재마스터 테이블 Insert                               */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_req_rec lgcom_approval_request_n%ROWTYPE;
        v_del_count            NUMBER;

        v_user_id              NUMBER;
        v_user_no              VARCHAR2(30);
        v_language_code        VARCHAR2(30);
        v_request_no           VARCHAR2(30);
        
        v_db_src               VARCHAR2(100);

    BEGIN

        begin
            SELECT u.application_user_id
                  ,u.language_code
                  ,u.user_name
            INTO   v_user_id
                  ,v_language_code
                  ,v_user_no
            FROM   lgcom_user_m u
            WHERE  u.application_user_id = pi_requestor_id;

        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := 'Parameter User No Select Error';
              return;
        end;

        if pi_request_master_id is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_request_master_id column is mandatory.';
            rollback;
            return;
        end if;

        if pi_request_code is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_request_code column is mandatory.';
            rollback;
            return;
        end if;

        if pi_organization_id is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_organization_id column is mandatory.';
            rollback;
            return;
        end if;

        if pi_request_no is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_request_no column is mandatory.';
            rollback;
            return;
        end if;

        if pi_module_code is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_module_code column is mandatory.';
            rollback;
            return;
        end if;

        --mo_global.set_policy_context('S', pi_organization_id);
        v_del_count := 0;

        if pi_request_no is null then

            begin
                SELECT (SELECT SUBSTR(lum.corporation_name, 4)
                            FROM   lgcom_user_m_v lum
                           WHERE   lum.application_user_id = pi_requestor_id
                           and     trunc(sysdate) between lum.apply_start_date and lum.apply_end_date)
                   || '-E-' || to_char(trunc(sysdate), 'yyyymmdd') || '-'
                   || CASE WHEN LENGTH(TO_CHAR(pi_request_master_id)) >= 4 THEN     /* request_id 4자리 이상 */
                                SUBSTR(TO_CHAR(pi_request_master_id), -4)
                           ELSE                                        /* request_id 4자리 미만 */
                                LPAD(TO_CHAR(pi_request_master_id), 4, '0')
                           END
                        as new_req_no
                into v_request_no
                FROM DUAL;
            exception
              when others then null;
            end;
        end if;

        v_approval_req_rec.request_master_id := pi_request_master_id;
        v_approval_req_rec.request_code      := pi_request_code; --승인문서형태로 EP 통합결재와 동일 코드값(예시 : '10007')
        v_approval_req_rec.organization_id   := pi_organization_id;
        v_approval_req_rec.request_no        := nvl(pi_request_no, v_request_no);
        v_approval_req_rec.system_code           := pi_system_code; -- 'LGCOM'        
        v_approval_req_rec.module_code           := pi_module_code; -- 'LGXXX' 시스템에 속한 모듈코드(LGCOM 에 모듈코드, 예시 : LGPONM)
        v_approval_req_rec.request_creation_code := pi_request_creation_code;--CREATE
        v_approval_req_rec.status_code           := pi_status_code;
        v_approval_req_rec.process_status_code   := pi_process_status_code;--최초저장시 NULL
        v_approval_req_rec.apply_status_code     := pi_apply_status_code;
        v_approval_req_rec.request_title         := pi_request_title;
        v_approval_req_rec.comment_content       := pi_comment_content;
        v_approval_req_rec.department_code       := pi_department_code;
        v_approval_req_rec.requestor_id          := pi_requestor_id;
        v_approval_req_rec.request_date          := pi_request_date;
        v_approval_req_rec.attach_file_id        := pi_attach_file_id;
        v_approval_req_rec.purchase_type_code           := pi_purchase_type_code;
        v_approval_req_rec.approval_on_off_flag         := pi_approval_on_off_flag;
        v_approval_req_rec.submission_type_code         := NVL(pi_submission_type_code, v_approval_req_rec.module_code);
        v_approval_req_rec.source_document_code         := pi_source_document_code;
        v_approval_req_rec.concurrent_request_id        := pi_concurrent_request_id;
        v_approval_req_rec.group_seq_no                 := pi_group_seq_no;
        v_approval_req_rec.doc_category_code            := pi_doc_category_code;
        v_approval_req_rec.submission_objective_content := pi_submit_objective_content;
        v_approval_req_rec.submission_content           := pi_submission_content;
        v_approval_req_rec.approver_screen_url_addr     := pi_approver_screen_url_addr;
        v_approval_req_rec.approval_url_addr            := pi_approval_url_addr;
        v_approval_req_rec.requestor_screen_url_addr    := pi_requestor_screen_url_addr;
        v_approval_req_rec.request_url_addr             := pi_request_url_addr;

        g_last_updated_by   := pi_requestor_id;
        g_created_by        := pi_requestor_id;
        g_creation_date     := sysdate;
        g_last_update_date  := sysdate;

        SELECT COUNT(1)
        INTO   v_del_count
        FROM   lgcom_approval_request_n t
        WHERE  t.request_master_id = v_approval_req_rec.request_master_id
        AND    t.request_code      = v_approval_req_rec.request_code
        AND    ROWNUM = 1;

        IF v_del_count > 0 THEN

            DELETE FROM lgcom_approval_request_n t
            WHERE  t.request_master_id = v_approval_req_rec.request_master_id
            AND    t.request_code      = v_approval_req_rec.request_code;

        END IF;

        if v_approval_req_rec.source_document_code is null and
           v_approval_req_rec.submission_type_code is null then
            begin
                SELECT nvl(pi_source_document_code, upper(x.code_data2_value))
                      ,nvl(pi_submission_type_code, x.code_data2_value)
                INTO   v_approval_req_rec.source_document_code
                      ,v_approval_req_rec.submission_type_code
                FROM   lgcom_common_code_c x
                WHERE  1=1
                AND    x.code_type_code      = 'LGCOM_APPROVAL_REQUEST_CODE'
                AND    x.common_code        = pi_request_code
                AND    x.parent_common_code = pi_module_code
                ;
            exception
              when others then
                null;
            end;
        end if;


        BEGIN

            if v_approval_req_rec.requestor_screen_url_addr is null and
               v_approval_req_rec.approver_screen_url_addr  is null then

                SELECT lccml.common_code_name ||'?'
                          || 'jobKeyId='       || v_approval_req_rec.request_master_id || '&'
                          || 'jobRequestCode=' || v_approval_req_rec.request_code
                       ,lccml.common_code_name ||'?'
                          || 'jobKeyId='       || v_approval_req_rec.request_master_id || '&'
                          || 'jobRequestCode=' || v_approval_req_rec.request_code
                INTO    v_approval_req_rec.requestor_screen_url_addr
                       ,v_approval_req_rec.approver_screen_url_addr
                FROM   lgcom_common_code_c lcc
                      ,lgcom_common_code_multi_lang_c lccml
                WHERE  lcc.code_type_code   = lccml.code_type_code
                AND    lcc.common_code      = lccml.common_code
                AND    lcc.code_type_code   = 'LGCOM_APPROVAL_URL'
                AND    lcc.code_data1_value = (SELECT NAME FROM v$database)
                AND    lccml.language_code  = v_language_code  ;

            end if;

            if v_approval_req_rec.approval_url_addr is null and
               v_approval_req_rec.request_url_addr  is null then
                --요청서별 View Source 를 가져옴.
                SELECT x.code_data3_value
                      ,x.code_data3_value
                INTO   v_approval_req_rec.approval_url_addr
                      ,v_approval_req_rec.request_url_addr
                FROM   lgcom_common_code_c x
                WHERE  1 = 1
                AND    x.code_type_code = 'LGCOM_APPROVAL_REQUEST_CODE'
                AND    x.common_code    = pi_request_code;
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                po_return_code    := 'NG';
                po_return_msg := 'Request Id : ' || TO_CHAR(v_approval_req_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
                ROLLBACK;
                RETURN;

        END;

        BEGIN
            select lum.department_code
            into   v_approval_req_rec.department_code
            from   lgcom_user_m_v lum
            where  lum.application_user_id = v_approval_req_rec.requestor_id
            and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date;

        EXCEPTION

            WHEN OTHERS THEN

                po_return_code    := 'NG';
                po_return_msg := 'Department Select Error. Request Id : ' || TO_CHAR(v_approval_req_rec.requestor_id);
                ROLLBACK;
                RETURN;

        END;

        begin
            INSERT INTO lgcom_approval_request_n
                (request_master_id
                ,request_code
                ,organization_id
                ,request_no
                ,system_code
                ,module_code
                ,request_creation_code
                ,status_code
                ,process_status_code
                ,apply_status_code
                ,request_title
                ,comment_content
                ,department_code
                ,requestor_id
                ,request_date
                ,attach_file_id
                ,purchase_type_code
                ,approval_on_off_flag
                ,submission_type_code
                ,source_document_code
                ,concurrent_request_id
                ,group_seq_no
                ,doc_category_code
                ,submission_objective_content
                ,submission_content
                ,approver_screen_url_addr
                ,approval_url_addr
                ,requestor_screen_url_addr
                ,request_url_addr
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by)
            VALUES
                (  v_approval_req_rec.request_master_id
                  ,v_approval_req_rec.request_code
                  ,v_approval_req_rec.organization_id
                  ,v_approval_req_rec.request_no
                  ,v_approval_req_rec.system_code
                  ,v_approval_req_rec.module_code
                  ,'CREATE'--v_approval_req_rec.request_creation_code
                  ,'10'--v_approval_req_rec.status_code
                  ,NULL--v_approval_req_rec.process_status_code
                  ,'N'--v_approval_req_rec.apply_status_code
                  ,v_approval_req_rec.request_title
                  ,v_approval_req_rec.comment_content
                  ,v_approval_req_rec.department_code
                  ,v_approval_req_rec.requestor_id
                  ,v_approval_req_rec.request_date
                  ,v_approval_req_rec.attach_file_id
                  ,v_approval_req_rec.purchase_type_code
                  ,v_approval_req_rec.approval_on_off_flag
                  ,v_approval_req_rec.submission_type_code
                  ,v_approval_req_rec.source_document_code
                  ,v_approval_req_rec.concurrent_request_id
                  ,v_approval_req_rec.group_seq_no
                  ,v_approval_req_rec.doc_category_code
                  ,v_approval_req_rec.submission_objective_content
                  ,v_approval_req_rec.submission_content
                  ,v_approval_req_rec.approver_screen_url_addr
                  ,v_approval_req_rec.approval_url_addr
                  ,v_approval_req_rec.requestor_screen_url_addr
                  ,v_approval_req_rec.request_url_addr
                  ,sysdate--v_approval_req_rec.creation_date
                  ,pi_requestor_id--v_approval_req_rec.created_by
                  ,sysdate--v_approval_req_rec.last_update_date
                  ,pi_requestor_id--v_approval_req_rec.last_updated_by
                  );
        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Insert Error : '||SQLCODE|| ' '||SQLERRM;
            rollback;
            return;
        end;

        --COMMIT;
        po_return_code    := 'OK';
        po_return_msg     := 'Request(' || TO_CHAR(v_approval_req_rec.request_master_id) || ') Creation is done, successfully!';

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'Request(' || TO_CHAR(v_approval_req_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
            
    END request_create_proc;

    PROCEDURE request_update_proc( pi_request_master_id             IN NUMBER
                                  ,pi_request_code                  IN VARCHAR2
                                  ,pi_organization_id               IN NUMBER
                                  ,pi_request_no                    IN VARCHAR2
                                  ,pi_system_code                   IN VARCHAR2   --DEFAULT 'LGCOM'
                                  ,pi_module_code                   IN VARCHAR2
                                  ,pi_request_creation_code         IN VARCHAR2   DEFAULT 'CREATE'
                                  ,pi_status_code                   IN VARCHAR2   DEFAULT '10'
                                  ,pi_process_status_code           IN VARCHAR2   DEFAULT NULL
                                  ,pi_apply_status_code             IN VARCHAR2   DEFAULT 'N'
                                  ,pi_request_title                 IN VARCHAR2
                                  ,pi_comment_content               IN VARCHAR2
                                  ,pi_department_code               IN VARCHAR2
                                  ,pi_requestor_id                  IN NUMBER      --fnd_user.user id
                                  ,pi_request_date                  IN DATE        DEFAULT sysdate
                                  ,pi_attach_file_id                IN NUMBER
                                  ,pi_purchase_type_code            IN VARCHAR2
                                  ,pi_approval_on_off_flag          IN VARCHAR2
                                  ,pi_submission_type_code          IN VARCHAR2
                                  ,pi_source_document_code          IN VARCHAR2
                                  ,pi_concurrent_request_id         IN NUMBER
                                  ,pi_group_seq_no                  IN NUMBER
                                  ,pi_doc_category_code             IN VARCHAR2
                                  ,pi_submit_objective_content      IN VARCHAR2--pi_submission_objective_content
                                  ,pi_submission_content            IN CLOB
                                  ,pi_approver_screen_url_addr      IN VARCHAR2
                                  ,pi_approval_url_addr             IN VARCHAR2
                                  ,pi_requestor_screen_url_addr     IN VARCHAR2
                                  ,pi_request_url_addr              IN VARCHAR2
                                  --Out Parms
                                 ,po_return_code    OUT VARCHAR2
                                 ,po_return_msg     OUT VARCHAR2) IS

    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                            */
    /* Module       : LGCOM                                                       */
    /* Program Name : request_update_proc.pls                                     */
    /* Description  : 공통 결재마스터 테이블 Insert                               */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/
        v_approval_req_rec lgcom_approval_request_n%ROWTYPE;
        v_update_cnt       NUMBER;

        v_language_code        VARCHAR2(30);
        --v_db_src               VARCHAR2(100);

    BEGIN

        begin
            SELECT u.language_code
            INTO   v_language_code
            FROM   lgcom_user_m u
            WHERE  u.application_user_id = pi_requestor_id;

        exception
          when others then
              po_return_code := 'NG';
              po_return_msg  := 'Parameter User No Select Error';
              return;
        end;
        
        --mo_global.set_policy_context('S', pi_organization_id);

        v_update_cnt := 0;

        v_approval_req_rec.request_master_id            := pi_request_master_id;
        v_approval_req_rec.request_code                 := pi_request_code; --승인문서형태로 EP 통합결재와 동일 코드값(예시 : '10007')
        v_approval_req_rec.organization_id              := pi_organization_id;
        v_approval_req_rec.request_no                   := pi_request_no;
        v_approval_req_rec.system_code                  := pi_system_code; -- 'LGEIH'
        v_approval_req_rec.module_code                  := pi_module_code; -- 'LGFINE'
        v_approval_req_rec.request_creation_code        := pi_request_creation_code;--CREATE
        v_approval_req_rec.status_code                  := pi_status_code;
        v_approval_req_rec.process_status_code          := pi_process_status_code;--최초저장시 NULL
        v_approval_req_rec.apply_status_code            := pi_apply_status_code;
        v_approval_req_rec.request_title                := pi_request_title;
        v_approval_req_rec.comment_content              := pi_comment_content;
        v_approval_req_rec.department_code              := pi_department_code;
        v_approval_req_rec.requestor_id                 := pi_requestor_id;
        v_approval_req_rec.request_date                 := pi_request_date;
        v_approval_req_rec.attach_file_id               := pi_attach_file_id;
        v_approval_req_rec.purchase_type_code           := pi_purchase_type_code;
        v_approval_req_rec.approval_on_off_flag         := pi_approval_on_off_flag;
        v_approval_req_rec.submission_type_code         := NVL(pi_submission_type_code, v_approval_req_rec.module_code);
        v_approval_req_rec.source_document_code         := pi_source_document_code;
        v_approval_req_rec.concurrent_request_id        := pi_concurrent_request_id;
        v_approval_req_rec.group_seq_no                 := pi_group_seq_no;
        v_approval_req_rec.doc_category_code            := pi_doc_category_code;
        v_approval_req_rec.submission_objective_content := pi_submit_objective_content;
        v_approval_req_rec.submission_content           := pi_submission_content;
        v_approval_req_rec.approver_screen_url_addr     := pi_approver_screen_url_addr;
        v_approval_req_rec.approval_url_addr            := pi_approval_url_addr;
        v_approval_req_rec.requestor_screen_url_addr    := pi_requestor_screen_url_addr;
        v_approval_req_rec.request_url_addr             := pi_request_url_addr;

        /*get_who_proc(p_organization_id   => v_approval_req_rec.organization_id
                           ,p_created_by        => g_created_by
                           ,p_creation_date     => g_creation_date
                           ,p_last_updated_by   => g_last_updated_by
                           ,p_last_update_date  => g_last_update_date
                           ,p_last_update_login => g_last_update_login);*/

        g_last_updated_by   := pi_requestor_id;
        g_last_update_date  := sysdate;  

        if v_approval_req_rec.source_document_code is null and
           v_approval_req_rec.submission_type_code is null then
            begin
                SELECT nvl(pi_source_document_code, upper(x.code_data2_value))
                      ,nvl(pi_submission_type_code, x.code_data2_value)
                INTO   v_approval_req_rec.source_document_code
                      ,v_approval_req_rec.submission_type_code
                FROM   lgcom_common_code_c x
                WHERE  1=1
                AND    x.code_type_code      = 'LGCOM_APPROVAL_REQUEST_CODE'
                AND    x.common_code        = pi_request_code
                AND    x.parent_common_code = pi_module_code
                ;
            exception
              when others then
                null;
            end;
        end if;


        BEGIN

            if v_approval_req_rec.requestor_screen_url_addr is null and
               v_approval_req_rec.approver_screen_url_addr  is null then

                SELECT lccml.common_code_name ||'?'
                          || 'jobKeyId='       || v_approval_req_rec.request_master_id || '&'
                          || 'jobRequestCode=' || v_approval_req_rec.request_code
                       ,lccml.common_code_name ||'?'
                          || 'jobKeyId='       || v_approval_req_rec.request_master_id || '&'
                          || 'jobRequestCode=' || v_approval_req_rec.request_code
                INTO    v_approval_req_rec.requestor_screen_url_addr
                       ,v_approval_req_rec.approver_screen_url_addr
                FROM   lgcom_common_code_c lcc
                      ,lgcom_common_code_multi_lang_c lccml
                WHERE  lcc.code_type_code   = lccml.code_type_code
                AND    lcc.common_code      = lccml.common_code
                AND    lcc.code_type_code   = 'LGCOM_APPROVAL_URL'
                AND    lcc.code_data1_value = (SELECT NAME FROM v$database)
                AND    lccml.language_code  = v_language_code  ;

            end if;

            --승인요청 화면의 URL
            /*SELECT x.code_data1_value
            INTO   v_approval_req_rec.requestor_screen_url_addr
            FROM   lgcom_common_code_c x
            WHERE  1 = 1
            AND    x.code_type_code = 'LGCOM_MODULE_CODE'
            AND    x.parent_common_code = pi_system_code
            AND    x.common_code = pi_module_code;*/
            if v_approval_req_rec.approval_url_addr is null and
               v_approval_req_rec.request_url_addr  is null then
                --요청서별 View Source 를 가져옴.
                SELECT x.code_data3_value
                      ,x.code_data3_value
                INTO   v_approval_req_rec.approval_url_addr
                      ,v_approval_req_rec.request_url_addr
                FROM   lgcom_common_code_c x
                WHERE  1 = 1
                AND    x.code_type_code = 'LGCOM_APPROVAL_REQUEST_CODE'
                AND    x.common_code    = pi_request_code;
            end if;

        EXCEPTION

            WHEN OTHERS THEN

                ROLLBACK;
                po_return_code    := 'NG';
                po_return_msg := 'Request Id : ' || TO_CHAR(v_approval_req_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
                RETURN;

        END;

        BEGIN
            select lum.department_code
            into   v_approval_req_rec.department_code
            from   lgcom_user_m_v lum
            where  lum.application_user_id = v_approval_req_rec.requestor_id
            and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date;

        EXCEPTION

            WHEN OTHERS THEN

                ROLLBACK;
                po_return_code    := 'NG';
                po_return_msg := 'Department Select Error. Request Id : ' || TO_CHAR(v_approval_req_rec.request_master_id);
                RETURN;

        END;


        SELECT  COUNT(1)
        INTO    v_update_cnt
        FROM    lgcom_approval_request_n
        WHERE   1=1
        AND     request_master_id        = v_approval_req_rec.request_master_id
        AND     request_code             = v_approval_req_rec.request_code
        AND     rownum                   = 1
        ;

        IF v_update_cnt > 0 THEN

            UPDATE lgcom_approval_request_n req
            SET    req.organization_id              = v_approval_req_rec.organization_id
                  --,req.request_no                   = v_approval_req_rec.request_no;
                  ,req.system_code                  = v_approval_req_rec.system_code
                  ,req.module_code                  = v_approval_req_rec.module_code
                  ,req.request_creation_code        = v_approval_req_rec.request_creation_code
                  ,req.status_code                  = v_approval_req_rec.status_code
                  ,req.process_status_code          = v_approval_req_rec.process_status_code
                  ,req.apply_status_code            = v_approval_req_rec.apply_status_code
                  ,req.request_title                = v_approval_req_rec.request_title
                  ,req.comment_content              = v_approval_req_rec.comment_content
                  ,req.department_code              = v_approval_req_rec.department_code
                  ,req.requestor_id                 = v_approval_req_rec.requestor_id
                  ,req.request_date                 = v_approval_req_rec.request_date
                  ,req.attach_file_id               = v_approval_req_rec.attach_file_id
                  ,req.purchase_type_code           = v_approval_req_rec.purchase_type_code
                  ,req.approval_on_off_flag         = v_approval_req_rec.approval_on_off_flag
                  ,req.submission_type_code         = v_approval_req_rec.submission_type_code
                  ,req.source_document_code         = v_approval_req_rec.source_document_code
                  ,req.concurrent_request_id        = v_approval_req_rec.concurrent_request_id
                  ,req.group_seq_no                 = v_approval_req_rec.group_seq_no
                  ,req.doc_category_code            = v_approval_req_rec.doc_category_code
                  ,req.submission_objective_content = v_approval_req_rec.submission_objective_content
                  ,req.submission_content           = v_approval_req_rec.submission_content
                  ,req.approver_screen_url_addr     = v_approval_req_rec.approver_screen_url_addr
                  ,req.approval_url_addr            = v_approval_req_rec.approval_url_addr
                  ,req.requestor_screen_url_addr    = v_approval_req_rec.requestor_screen_url_addr
                  ,req.request_url_addr             = v_approval_req_rec.request_url_addr
                  ,req.last_updated_by              = g_last_updated_by
                  ,req.last_update_date             = g_last_update_date
            WHERE  1=1
            AND    req.request_master_id = v_approval_req_rec.request_master_id
            AND    req.request_code      = v_approval_req_rec.request_code;

            po_return_code    := 'OK';
            po_return_msg     := 'Approval Request(' || TO_CHAR(v_approval_req_rec.request_master_id) || ') Update is done, successfully!';

        ELSE

            po_return_code    := 'NG';
            po_return_msg     := 'Approval Request(' || TO_CHAR(v_approval_req_rec.request_master_id) || ') does not exist.';
            RETURN;

        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'Approval Request(' || TO_CHAR(v_approval_req_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
            
    END request_update_proc;

    PROCEDURE approval_line_del_proc(pi_request_master_id IN NUMBER
                                    ,pi_request_code      IN VARCHAR2
                                     --Out Parms
                                    ,po_return_code    OUT VARCHAR2
                                    ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : approval_line_del_proc.pls                                  */
    /* Description  : 공통 결재마스터 테이블 Insert                               */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_line_rec lgcom_approval_status_n%ROWTYPE;
        v_del_count         NUMBER;

    BEGIN

        v_del_count := 0;

        v_approval_line_rec.request_master_id := pi_request_master_id;
        v_approval_line_rec.request_code      := pi_request_code; --승인문서형태로 EP 통합결재와 동일 코드값(예시 : '10007')

        SELECT COUNT(1)
        INTO   v_del_count
        FROM   lgcom_approval_status_n t
        WHERE  t.request_master_id = v_approval_line_rec.request_master_id
        AND    t.request_code      = v_approval_line_rec.request_code
        --AND    t.approval_action_code IN ('REQUEST', 'APPROVAL', 'AGREEMENT')
        --AND    t.approval_seqs < 10000
        AND    ROWNUM = 1;

        IF v_del_count > 0 THEN

            DELETE FROM lgcom_approval_status_n t
            WHERE  t.request_master_id = v_approval_line_rec.request_master_id
            AND    t.request_code = v_approval_line_rec.request_code;
            --AND    t.approval_action_code IN ('REQUEST', 'APPROVAL', 'AGREEMENT')
            --AND    t.approval_seqs < 10000;

            po_return_code    := 'OK';
            po_return_msg     := 'Approval Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ') Deletion is done, successfully!';

        ELSE

            po_return_code    := 'OK';
            po_return_msg     := 'No Approval Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ') Data to Delete!';

        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'Approval Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
            
    END approval_line_del_proc;

    PROCEDURE approval_line_create_proc( pi_request_master_id      IN NUMBER
                                        ,pi_request_code           IN VARCHAR2
                                        ,pi_organization_id        IN NUMBER
                                        ,pi_user_no                IN VARCHAR2
                                        ,pi_approval_action_code   IN VARCHAR2
                                        ,pi_approval_duty_code     IN VARCHAR2
                                        ,pi_approval_comment       IN VARCHAR2 DEFAULT NULL
                                        ,pi_inspection_comment     IN VARCHAR2 DEFAULT NULL
                                        ,pi_share_flag             IN VARCHAR2 DEFAULT NULL
                                        ,pi_return_flag            IN VARCHAR2 DEFAULT NULL
                                        ,pi_mandator_employee_no   IN VARCHAR2
                                        ,pi_approval_line_id       IN VARCHAR2
                                        ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N'--재량권에서 가져온데이타이면 'Y'아니면 'N'
                                        ,pi_creator_user_id       IN NUMBER
                                        --Out Parms
                                       ,po_return_code    OUT VARCHAR2
                                       ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGPONM                                                      */
    /* Program Name : approval_line_create_proc.pls                               */
    /* Description  : 결재상세 입력                                               */
    /* p_command      : Button             : Actor                                */
    /* REQUEST        : Request Approval   : REQUESTOR                            */
    /* REQUESTCANCEL  : Req. Cancel        : REQUESTOR                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date      In Charge         Version   Description                        */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_line_rec lgcom_approval_status_n%ROWTYPE;
        v_approval_seqs        NUMBER;
        v_process_seq_no       NUMBER;
        v_requestor_user_no    VARCHAR2(20);
        v_approval_action_code VARCHAR2(20);
        v_approval_duty_code   VARCHAR2(100);

    BEGIN
        --pi_settlement_delete_flag : Y 이면 재량권에서 가져온결재권자,N 이면 직등록한결재권자
        --pi_progress_code : REQUEST : 0001
        --                   APPROVAL,AGREEMENT,PARAGREE_ALL,PARAGREE_OR : 0002
        --                   REFERENCE,FORWARD,PREVIEW : NULL

        g_last_updated_by   := pi_creator_user_id;
        g_created_by        := pi_creator_user_id;
        g_creation_date     := sysdate;
        g_last_update_date  := sysdate;

        v_approval_seqs        := 0;

        begin
            select lum.user_name
            into   v_requestor_user_no
            from   lgcom_user_m_v lum
            where  lum.application_user_id = pi_creator_user_id;
        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Get Requestor user Name Select Error.';
            rollback;
            return;
        end;

        if pi_request_master_id is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_request_master_id column is mandatory.';
            rollback;
            return;
        end if;

        if pi_request_code is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_request_code column is mandatory.';
            rollback;
            return;
        end if;

        if pi_organization_id is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_organization_id column is mandatory.';
            rollback;
            return;
        end if;

        if pi_approval_action_code is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_approval_action_code column is mandatory.';
            rollback;
            return;
        end if;

        if pi_user_no is null then
            po_return_code    := 'NG';
            po_return_msg     := 'pi_user_no column is mandatory.';
            rollback;
            return;
        end if;

        --결재자나 참조자가 퇴직자이면 에러처리.
        begin
          select lum.title_name
          into   v_approval_duty_code
          from   lgcom_user_m_v lum
          where  lum.user_name = pi_user_no
          and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
          and    rownum = 1;
        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Error!. This person is a retired person('||pi_user_no||')';
            rollback;
            return;
        end;

        if pi_approval_duty_code is null then
          null;
        else
          v_approval_duty_code := pi_approval_duty_code;
        end if;

        --mo_global.set_policy_context('S', pi_organization_id);

        if pi_approval_action_code in ('APPROVAL','AGREEMENT','PARAGREE_ALL','PARAGREE_OR') then

            begin
              select nvl(max(las.approval_seqs),0)
              into   v_approval_seqs
              from   lgcom_approval_status_n las
              where  las.request_master_id = pi_request_master_id
              and    las.request_code      = pi_request_code
              and    las.approval_seqs > 0
              and    las.approval_seqs < 10000;
            exception
              when others then
                v_approval_seqs := 0;
            end;

            if v_approval_seqs > 0 then
                begin--이전차수의 승인상태
                  select las.approval_action_code,las.process_seq_no
                  into   v_approval_action_code,v_process_seq_no
                  from   lgcom_approval_status_n las
                  where  las.request_master_id = pi_request_master_id
                  and    las.request_code      = pi_request_code
                  and    las.approval_seqs     = v_approval_seqs;
                exception
                  when others then
                    v_approval_action_code := 'APPROVAL';
                    v_process_seq_no       := 10;
                end;
            else
                v_approval_action_code := 'APPROVAL';
                v_process_seq_no       := 10;
            end if;

            if v_approval_action_code in ('PARAGREE_ALL','PARAGREE_OR') then
                if v_approval_action_code = pi_approval_action_code then
                    v_process_seq_no := v_process_seq_no;
                else
                    v_process_seq_no := v_process_seq_no + 10;
                end if;
            else
                v_process_seq_no := v_process_seq_no + 10;
            end if;

        else--('REFERENCE','INSPECTION')

            begin
              select nvl(max(las.approval_seqs),10000)
              into   v_approval_seqs
              from   lgcom_approval_status_n las
              where  las.request_master_id = pi_request_master_id
              and    las.request_code      = pi_request_code
              and    las.approval_seqs > 10000
              and    las.approval_seqs < 20000;
            exception
              when others then
                v_approval_seqs := 10000;
            end;

            v_process_seq_no := 0;

        end if;

        v_approval_seqs := v_approval_seqs + 1;

        v_approval_line_rec.request_master_id := pi_request_master_id;
        v_approval_line_rec.request_code      := pi_request_code;
        v_approval_line_rec.approval_seqs     := v_approval_seqs;--pi_approval_seqs;
        v_approval_line_rec.organization_id   := pi_organization_id;
        v_approval_line_rec.process_seq_no    := v_process_seq_no;--pi_process_seq_no;
        v_approval_line_rec.user_no           := pi_user_no;
        v_approval_line_rec.sign_user_no      := NULL;--pi_sign_user_no;

        v_approval_line_rec.approval_status_code   := '1'; --pi_approval_status_code;
        v_approval_line_rec.approval_date          := NULL;--pi_approval_date;
        v_approval_line_rec.approval_action_code   := pi_approval_action_code;
        if pi_approval_action_code in ('APPROVAL','AGREEMENT','PARAGREE_ALL','PARAGREE_OR') then
            v_approval_line_rec.progress_code        := '0002';--pi_progress_code;
            v_approval_line_rec.approval_method_code := '0001';--pi_approval_method_code;
        else
            v_approval_line_rec.progress_code        := NULL;--pi_progress_code;
            v_approval_line_rec.approval_method_code := NULL;--pi_approval_method_code;
        end if;
        v_approval_line_rec.approval_duty_code     := v_approval_duty_code;
        v_approval_line_rec.approval_comment       := pi_approval_comment;
        v_approval_line_rec.inspection_comment     := pi_inspection_comment;
        v_approval_line_rec.share_flag             := pi_share_flag;
        v_approval_line_rec.return_flag            := pi_return_flag;
        v_approval_line_rec.mandator_employee_no   := pi_mandator_employee_no;
        v_approval_line_rec.approval_line_id       := pi_approval_line_id;
        v_approval_line_rec.settlement_delete_flag := pi_settlement_delete_flag;

        if v_approval_seqs = 1 then
           --최초 결재자 insert시점에 요청자 정보 Insert.
            begin
                INSERT INTO lgcom_approval_status_n
                    (request_master_id
                    ,request_code
                    ,approval_seqs
                    ,organization_id
                    ,process_seq_no
                     --5 fields
                    ,progress_code
                    ,user_no
                    ,sign_user_no
                    ,approval_status_code
                    ,approval_date
                     --10 fields
                    ,approval_action_code
                    ,approval_method_code
                    ,approval_duty_code
                    ,approval_comment
                    ,inspection_comment
                     --15 fields
                    ,share_flag
                    ,return_flag
                    ,mandator_employee_no
                    ,approval_line_id
                    ,settlement_delete_flag
                     --20 fields
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by)
                VALUES
                    (pi_request_master_id--v_approval_line_rec.request_master_id
                    ,pi_request_code--v_approval_line_rec.request_code
                    ,0--approval_seqs
                    ,pi_organization_id--v_approval_line_rec.organization_id
                    ,10--process_seq_no
                     --5 fields
                    ,'0001'
                    ,v_requestor_user_no--v_approval_line_rec.user_no
                    ,NULL--v_approval_line_rec.sign_user_no
                    ,'1'--v_approval_line_rec.approval_status_code
                    ,NULL--v_approval_line_rec.approval_date
                     --10 fields
                    ,'REQUEST'--v_approval_line_rec.approval_action_code
                    ,'0001'--v_approval_line_rec.approval_method_code
                    ,NULL--v_approval_line_rec.approval_duty_code
                    ,NULL--v_approval_line_rec.approval_comment
                    ,NULL--v_approval_line_rec.inspection_comment
                     --15 fields
                    ,NULL--v_approval_line_rec.share_flag
                    ,NULL--v_approval_line_rec.return_flag
                    ,NULL--v_approval_line_rec.mandator_employee_no
                    ,NULL--v_approval_line_rec.approval_line_id
                    ,'N'--v_approval_line_rec.settlement_delete_flag
                     --20 fields
                    ,g_creation_date
                    ,g_created_by
                    ,g_last_update_date
                    ,g_last_updated_by);

            exception
              when others then
                po_return_code    := 'NG';
                po_return_msg     := 'Requestor Insert Error : '||SQLCODE|| ' '||SQLERRM;
                rollback;
                return;
            end;
        end if;--if v_approval_seqs is null then

        begin
            INSERT INTO lgcom_approval_status_n
                (request_master_id
                ,request_code
                ,approval_seqs
                ,organization_id
                ,process_seq_no
                 --5 fields
                ,progress_code
                ,user_no
                ,sign_user_no
                ,approval_status_code
                ,approval_date
                 --10 fields
                ,approval_action_code
                ,approval_method_code
                ,approval_duty_code
                ,approval_comment
                ,inspection_comment
                 --15 fields
                ,share_flag
                ,return_flag
                ,mandator_employee_no
                ,approval_line_id
                ,settlement_delete_flag
                 --20 fields
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by)
            VALUES
                (v_approval_line_rec.request_master_id
                ,v_approval_line_rec.request_code
                ,v_approval_line_rec.approval_seqs
                ,v_approval_line_rec.organization_id
                ,v_approval_line_rec.process_seq_no
                 --5 fields
                ,v_approval_line_rec.progress_code
                ,v_approval_line_rec.user_no
                ,v_approval_line_rec.sign_user_no
                ,v_approval_line_rec.approval_status_code
                ,v_approval_line_rec.approval_date
                 --10 fields
                ,v_approval_line_rec.approval_action_code
                ,v_approval_line_rec.approval_method_code
                ,v_approval_line_rec.approval_duty_code
                ,v_approval_line_rec.approval_comment
                ,v_approval_line_rec.inspection_comment
                 --15 fields
                ,v_approval_line_rec.share_flag
                ,v_approval_line_rec.return_flag
                ,v_approval_line_rec.mandator_employee_no
                ,v_approval_line_rec.approval_line_id
                ,v_approval_line_rec.settlement_delete_flag
                 --20 fields
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by);

        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Insert Error : '||SQLCODE|| ' '||SQLERRM;
            rollback;
            return;
        end;

        --COMMIT;
        po_return_code    := 'OK';
        --po_return_sql_msg := v_program_name || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
        po_return_msg     := 'Approval Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ') Creation is done, successfully!';

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'Approval Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
            
    END approval_line_create_proc;


    PROCEDURE forward_request_proc(pi_request_master_id      IN NUMBER
                                  ,pi_ou_id                  IN NUMBER
                                  ,pi_request_code           IN VARCHAR2
                                  --,pi_approval_seqs          IN NUMBER
                                  ,pi_for_emp_no             IN VARCHAR2 --전달받는사람 사번
                                  ,pi_emp_no                 IN VARCHAR2 --전달자사번
                                  ,pi_inspection_comment     IN VARCHAR2 --검토요청/전달요청 코멘트
                                  ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N'
                                  ,pi_portal_flag            IN VARCHAR2
                                  ,pi_mail_flag              IN VARCHAR2
                                   --Out Parms
                                  ,po_return_code    OUT VARCHAR2
                                  ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : forward_request_proc.pls                                    */
    /* Description  : 공통 결재마스터에 승인자의 전달 정보를 생성 및 통합결재호출 */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_line_rec lgcom_approval_status_n%ROWTYPE;
        v_user_id  NUMBER;
        v_approval_seqs NUMBER;

    BEGIN
        po_return_code    := 'OK';

       select a.application_user_id
       into   v_user_id
       from   lgcom_user_m a
       where  a.user_name = pi_for_emp_no
       and    trunc(sysdate) between a.apply_start_date and a.apply_end_date;

       begin
           select nvl(max(las.approval_seqs + 1),20001)
           into   v_approval_seqs
           from   lgcom_approval_status_n las
           where  las.request_master_id = pi_request_master_id
            and   las.request_code     = pi_request_code
            and   las.approval_seqs    >= 20000
            and   las.approval_seqs    <  30000;
       exception
         when others then
           v_approval_seqs := 20001;
       end;

       --FORWARD는 pi_approval_seqs가 20001이상이어야함.
        v_approval_line_rec.request_master_id      := pi_request_master_id;
        v_approval_line_rec.organization_id        := pi_ou_id;
        v_approval_line_rec.approval_seqs          := v_approval_seqs;--pi_approval_seqs;
        v_approval_line_rec.request_code           := pi_request_code;
        v_approval_line_rec.user_no                := pi_for_emp_no;
        v_approval_line_rec.sign_user_no           := NULL;
        v_approval_line_rec.inspection_comment     := pi_inspection_comment;--전달 요청자 코멘트
        v_approval_line_rec.mandator_employee_no   := pi_emp_no;
        v_approval_line_rec.settlement_delete_flag := nvl(pi_settlement_delete_flag,'N');

        --mo_global.set_policy_context('S', pi_ou_id);
/*
        get_who_proc(p_organization_id   => v_approval_line_rec.organization_id
                           ,p_created_by        => g_created_by
                           ,p_creation_date     => g_creation_date
                           ,p_last_updated_by   => g_last_updated_by
                           ,p_last_update_date  => g_last_update_date
                           ,p_last_update_login => g_last_update_login);*/

       select a.application_user_id
       into   g_created_by
       from   lgcom_user_m_v a
       where  a.user_name = pi_emp_no
       and    trunc(sysdate) between a.apply_start_date and a.apply_end_date;
       
        g_created_by        := g_created_by;
        g_last_updated_by   := g_created_by;
        g_last_update_login := g_created_by;
        g_creation_date     := sysdate;
        g_last_update_date  := sysdate;          

        begin
            INSERT INTO lgcom_approval_status_n
                (request_master_id
                ,organization_id
                ,approval_seqs
                 --5 fields
                ,request_code
                ,process_seq_no
                ,user_no
                ,sign_user_no
                ,approval_status_code
                 --10 fields
                ,inspection_comment
                ,mandator_employee_no
                ,settlement_delete_flag
                ,approval_action_code
                 --12 fields
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by)
            VALUES
                (v_approval_line_rec.request_master_id
                ,v_approval_line_rec.organization_id
                ,v_approval_line_rec.approval_seqs
                 --5 fields
                ,v_approval_line_rec.request_code
                ,0
                ,v_approval_line_rec.user_no
                ,v_approval_line_rec.sign_user_no
                ,'1'
                 --10 fields
                ,v_approval_line_rec.inspection_comment
                ,v_approval_line_rec.mandator_employee_no
                ,v_approval_line_rec.settlement_delete_flag
                ,'FORWARD'
                 --12 fields
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by);
        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Insert Error : '||SQLCODE|| ' '||SQLERRM;
            rollback;
            return;
        end;

         main_proc( pi_command => 'FORWARD'
                   ,pi_request_master_id => pi_request_master_id
                   ,pi_request_code      => pi_request_code
                   ,pi_user_id           => v_user_id--pi_for_emp_no
                   ,pi_comment           => NULL
                   ,pi_portal_flag       => pi_portal_flag--Y/N 통합결재 ToDo발송여부
                   ,pi_mail_flag         => pi_mail_flag  --Y/N 메일발송여부
                   ,po_return_code       => po_return_code
                   ,po_return_msg        => po_return_msg  );

        if po_return_code = 'OK' then
          NULL;
        else
            rollback;
            return;
        end if;
    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'FORWARD Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;

    END forward_request_proc;

    PROCEDURE preview_request_proc(pi_request_master_id      IN NUMBER
                                  ,pi_ou_id                  IN NUMBER
                                  ,pi_request_code           IN VARCHAR2
                                  --,pi_approval_seqs          IN NUMBER   --preview생성 차수 30000이상
                                  ,pi_for_emp_no             IN VARCHAR2 --검토요청받는사람 사번
                                  ,pi_emp_no                 IN VARCHAR2 --검토요청자 사번
                                  ,pi_inspection_comment     IN VARCHAR2 --검토요청 코멘트
                                  ,pi_settlement_delete_flag IN VARCHAR2 DEFAULT 'N'--재량권사용여부
                                  ,pi_share_flag             IN VARCHAR2 DEFAULT 'Y'--검토내용 공개여부
                                  ,pi_portal_flag            IN VARCHAR2
                                  ,pi_mail_flag              IN VARCHAR2
                                   --Out Parms
                                  ,po_return_code    OUT VARCHAR2
                                  ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGPROM                                                      */
    /* Program Name : forward_request_proc.pls                                    */
    /* Description  : 공통 결재마스터에 승인자의 검토요청 정보를 생성 및 통합결재호출 */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_line_rec lgcom_approval_status_n%ROWTYPE;

        v_user_id     NUMBER;
        v_approval_seqs NUMBER;

    BEGIN
        po_return_code    := 'OK';

       BEGIN
           SELECT a.application_user_id
           INTO   v_user_id
           FROM   lgcom_user_m_v a
           WHERE  a.user_name = pi_for_emp_no
           AND    TRUNC(SYSDATE) BETWEEN a.apply_start_date AND a.apply_end_date;
       EXCEPTION
           WHEN OTHERS THEN           
               po_return_code := 'NG';
               po_return_msg  := 'pi_for_emp_no Select Error : ' || pi_emp_no;
               ROLLBACK;
               RETURN;
       END;

       BEGIN
           SELECT NVL(MAX(las.approval_seqs + 1), 30001)
           INTO   v_approval_seqs
           FROM   lgcom_approval_status_n las
           WHERE  las.request_master_id = pi_request_master_id
           AND    las.request_code = pi_request_code
           AND    las.approval_seqs >= 30000
           AND    las.approval_seqs < 40000;
       EXCEPTION
           WHEN OTHERS THEN
               v_approval_seqs := 30001;
       END;

       --PREVIEW는 pi_approval_seqs가 30001이상이어야함.
       --승인자만 승인후 검토요청할수있음
        v_approval_line_rec.request_master_id      := pi_request_master_id;
        v_approval_line_rec.organization_id        := pi_ou_id;
        v_approval_line_rec.approval_seqs          := v_approval_seqs;--pi_approval_seqs;
        v_approval_line_rec.request_code           := pi_request_code;
        v_approval_line_rec.user_no                := pi_for_emp_no;--검토지정된 사람
        v_approval_line_rec.sign_user_no           := NULL;
        v_approval_line_rec.mandator_employee_no   := pi_emp_no;
        v_approval_line_rec.share_flag             := pi_share_flag;
        v_approval_line_rec.settlement_delete_flag := nvl(pi_settlement_delete_flag,'N');
        v_approval_line_rec.inspection_comment     := pi_inspection_comment;

        --mo_global.set_policy_context('S', pi_ou_id);

        /*get_who_proc(p_organization_id   => v_approval_line_rec.organization_id
                           ,p_created_by        => g_created_by
                           ,p_creation_date     => g_creation_date
                           ,p_last_updated_by   => g_last_updated_by
                           ,p_last_update_date  => g_last_update_date
                           ,p_last_update_login => g_last_update_login);*/
       BEGIN
           SELECT a.application_user_id
           INTO   g_created_by
           FROM   lgcom_user_m_v a
           WHERE  a.user_name = pi_emp_no
           AND    TRUNC(SYSDATE) BETWEEN a.apply_start_date AND
                  a.apply_end_date;
       EXCEPTION
           WHEN OTHERS THEN
           
               po_return_code := 'NG';
               po_return_msg  := 'Emp_no Select Error : ' || pi_emp_no;
               ROLLBACK;
               RETURN;
       END;
       
        g_last_updated_by   := g_created_by;
        --g_created_by        := g_created_by;
        g_creation_date     := sysdate;
        g_last_update_date  := sysdate;
        
        --검토요청을 요청한사람 정보 수정
       /* update lgcom_approval_status_n las
        set    las.inspection_comment = pi_inspection_comment
               ,las.last_update_date  = g_creation_date
               ,las.last_updated_by   = g_created_by
        where  las.request_master_id = pi_request_master_id
        and    las.request_code      = pi_request_code
        and    las.user_no           = pi_emp_no
        and    las.progress_code     = '0002'
        and    las.approval_status_code = '2';*/


        begin
            INSERT INTO lgcom_approval_status_n
                (request_master_id
                ,organization_id
                ,approval_seqs
                 --5 fields
                ,request_code
                ,process_seq_no
                ,user_no
                ,sign_user_no
                ,approval_status_code
                 --10 fields
                ,settlement_delete_flag
                ,mandator_employee_no
                ,approval_action_code
                ,inspection_comment
                ,share_flag
                 --12 fields
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by)
            VALUES
                (v_approval_line_rec.request_master_id
                ,v_approval_line_rec.organization_id
                ,v_approval_line_rec.approval_seqs
                 --5 fields
                ,v_approval_line_rec.request_code
                ,0
                ,v_approval_line_rec.user_no
                ,v_approval_line_rec.sign_user_no
                ,'1'
                 --10 fields
                ,v_approval_line_rec.settlement_delete_flag
                ,v_approval_line_rec.mandator_employee_no
                ,'PREVIEW'
                ,v_approval_line_rec.inspection_comment
                ,v_approval_line_rec.share_flag
                 --12 fields
                ,g_creation_date
                ,g_created_by
                ,g_last_update_date
                ,g_last_updated_by);
        exception
          when others then
            po_return_code    := 'NG';
            po_return_msg     := 'Insert Error : '||SQLCODE|| ' '||SQLERRM;
            rollback;
            return;
        end;

         main_proc( pi_command => 'PREVIEW'
                   ,pi_request_master_id => pi_request_master_id
                   ,pi_request_code      => pi_request_code
                   ,pi_user_id           => v_user_id--pi_for_emp_no
                   ,pi_comment           => NULL
                   ,pi_portal_flag       => pi_portal_flag--Y/N 통합결재 ToDo발송여부
                   ,pi_mail_flag         => pi_mail_flag--Y/N 메일발송여부
                   ,po_return_code       => po_return_code
                   ,po_return_msg        => po_return_msg  );

        if po_return_code = 'OK' then
          NULL;
        else
            rollback;
            return;
        end if;
    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'FORWARD Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;

    END preview_request_proc;

    PROCEDURE preview_update_proc( pi_request_master_id       IN NUMBER
                                  ,pi_ou_id                  IN NUMBER
                                  ,pi_request_code           IN VARCHAR2
                                  ,pi_approval_seqs          IN NUMBER   --preview 차수 30000이상
                                  ,pi_comment                IN VARCHAR2 --검토내용 코멘트
                                  ,pi_attach_file_id         IN NUMBER   --첨부화일있을경우
                                   --Out Parms
                                  ,po_return_code    OUT VARCHAR2
                                  ,po_return_msg     OUT VARCHAR2) IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGPROM                                                      */
    /* Program Name : forward_request_proc.pls                                    */
    /* Description  : 검토자의 검토 Comment저장                                   */
    /*                >>> Commit 은 존재하지 않음. 본 프로시저를 호출한 PGM 에서  */
    /*                    Transaction 관리해야 하며, Commit/Rollback 해야 함.     */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*    Date      In Charge         Version   Description                       */
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        v_approval_line_rec lgcom_approval_status_n%ROWTYPE;

    BEGIN
        po_return_code    := 'OK';
       --검토자의 검토내용 저장
        --mo_global.set_policy_context('S', pi_ou_id);

        /*get_who_proc(p_organization_id   => v_approval_line_rec.organization_id
                           ,p_created_by        => g_created_by
                           ,p_creation_date     => g_creation_date
                           ,p_last_updated_by   => g_last_updated_by
                           ,p_last_update_date  => g_last_update_date
                           ,p_last_update_login => g_last_update_login);*/

        --g_last_updated_by   := pi_requestor_id;
        --g_created_by        := pi_requestor_id;
        g_creation_date     := sysdate;
        g_last_update_date  := sysdate; 
        
        UPDATE lgcom_approval_status_n las
        SET    las.approval_comment     = pi_comment
              ,las.approval_status_code = '3' --검토완료
              ,las.approval_date        = SYSDATE
              ,las.approval_line_id     = pi_attach_file_id --첨부화일 ID
              ,las.last_update_date     = g_last_update_date
        --,las.last_updated_by   = g_last_updated_by
        WHERE  las.request_master_id = pi_request_master_id
        AND    las.request_code = pi_request_code
        AND    las.approval_seqs = pi_approval_seqs
        AND    las.approval_status_code = '2'
        AND    las.progress_code IS NULL;


        po_return_msg     := 'FORWARD Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ') Creation is done, successfully!';

    EXCEPTION

        WHEN OTHERS THEN
            ROLLBACK;
            --DBMS_OUTPUT.PUT_LINE('request_create_proc : '||SQLERRM);
            po_return_code    := 'NG';
            po_return_msg := 'FORWARD Line(' || TO_CHAR(v_approval_line_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;

    END preview_update_proc;


    PROCEDURE make_acpt_proc (pi_request_master_id   IN  NUMBER
                             ,pi_request_code        IN  VARCHAR2
                             ,pi_approval_seqs       IN  NUMBER
                             ,pi_request_status      IN  VARCHAR2
                             ,pi_portal_flag         IN  VARCHAR2
                             ,pi_mail_flag           IN  VARCHAR2
                             ,pi_user_id             IN  VARCHAR2
                             ,po_return_code         OUT VARCHAR2
                             ,po_return_msg          OUT VARCHAR2)
    IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : acpt_proc                                                   */
    /* Description  : 통합결제 입력을 위한 DATA                                   */
    /* Reference by :                                                             */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

    v_approval_system_code     VARCHAR2(30);
    v_language_code            VARCHAR2(30);

    v_requestor_screen_url_addr    VARCHAR2(1000);
    v_requestor_screen_param_value VARCHAR2(1000);
    v_approver_screen_url_addr     VARCHAR2(1000);
    v_approver_screen_param_value  VARCHAR2(1000);
    v_portal_requestor_user_name   VARCHAR2(100);
    v_delegate_name                VARCHAR2(100);
    v_delegate_employee_no         VARCHAR2(100);
   
    v_db_src               VARCHAR2(100);

    v_mail_template_id     NUMBER;

   -- 이전 비지니스코드 : 05002
    CURSOR portal_cursor IS
        select  v_approval_system_code   approval_system_code
               ,lar.request_master_id    request_master_id
               ,lar.request_code         approval_business_code-- Legacy 결재업무처리번호
               ,lar.module_code
               ,lar.request_master_id    approval_business_prcs_no
               ,lar.request_no           request_no
               ,(SELECT LPAD(TO_CHAR(NVL(MAX(TO_NUMBER(acpt_step_no)),0)+1),4,'0')  a
                        FROM   tb_acpt_master_i--xxlge_acpt_master_s_i
                        WHERE  acpt_biz_cd =  lar.request_code
                        and    acpt_biz_proc_no = to_char(lar.request_master_id))  approval_step_no-- 결재단계번호
               ,case
                when pi_request_status = 'REQUEST' then
                    '[Request] '||  lar.request_title
                else
                    '['||las.approval_action_code||'] '||  lar.request_title
                end                approval_title  -- 결재제목
              ,lar.request_title  mail_title  -- 메일제목용도
              ,las.approval_seqs
              ,case
               when pi_request_status in ('FORWARD','PREVIEW') then
                  ( SELECT lum.full_name_local
                    FROM   lgcom_user_m_v lum
                    WHERE  lum.user_name = las.mandator_employee_no
                    AND    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                    AND    lum.user_name = las.mandator_employee_no)
               else
                  
                  ( SELECT lum.full_name_local
                    FROM   lgcom_user_m_v lum
                    WHERE  trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                    AND    lum.application_user_id = lar.requestor_id)
               end                                                              requestor_name               -- 요청자명
              ,case
               when pi_request_status in ('FORWARD','PREVIEW') then
                  las.mandator_employee_no
               else
                 
                  ( SELECT lum.user_name
                    FROM   lgcom_user_m_v lum
                    WHERE  trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                    AND    lum.application_user_id = lar.requestor_id)
                    
               end                                                             requestor_employee_no        -- 요청자 사번

              ,TO_CHAR(lar.creation_date, 'YYYYMMDD')                            first_request_yyyymmdd       -- 최초요청일자
              ,decode(pi_request_status,'REQUEST'      ,'[REQUEST]'
                                       ,'REQUESTCANCEL','[CANCEL]'
                                       ,'APPROVAL'     ,'[APPROVED]'
                                       ,'AGREEMENT'    ,'[AGREEMENT]'
                                       ,'REJECT'       ,'[REJECT]'
                                       ,'INSPECTION'   ,'[INSPECTION]'
                                       , '['||pi_request_status||']')         approval_step_name             -- 요청 타입
              ,decode(pi_request_status,'REQUEST'     ,'01'
                                       ,'REQUESTCANCEL','00'
                                       ,'APPROVAL'     ,'02'
                                       ,'AGREEMENT'    ,'02'
                                       ,'REJECT'       ,'03'
                                       ,'INSPECTION'   ,'04'
                                       , '04')           --REFERENCE,FORWARD,PREVIEW,NOTICE,REPORT
                                       approval_step_code           -- 결재단계코드
              , ( SELECT lum.full_name_local
                  FROM   lgcom_user_m_v lum
                  WHERE  trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                  AND    lum.user_name = las.user_no)    approver_name                -- 승인자명
              ,las.user_no                                 approver_employee_no         -- 승인자 사번
              , ( SELECT lum.full_name_local
                  FROM   lgcom_user_m_v lum
                  WHERE  trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                  AND    lum.user_name = las.mandator_employee_no)     delegate_name                -- 위임자명
              ,las.mandator_employee_no                         delegate_employee_no         -- 위임자 사번
              ,'N'                                              approval_line_change_flag    -- 결재라인변경여부
              ,lar.requestor_screen_url_addr                    requestor_screen_url_addr    -- 요청자화면URL주소
              ,lar.request_url_addr                             requestor_screen_param_value -- 요청자화면매개변수문자값
              ,lar.approver_screen_url_addr                     approver_screen_url_addr     -- 승인자화면URL주소
              ,lar.approval_url_addr                            approver_screen_param_value  -- 승인자화면매개변수문자값
              ,TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')                register_ymdhms              -- 등록일시
              ,'N'                                              interface_work_flag          -- 인터페이스작업여부
              ,tb_acpt_master_i_seq.NEXTVAL                  eai_seq_id
              ,'I'                                              data_interface_type_code
              ,SYSDATE                                          data_interface_date
              ,'N'                                              eai_transfer_flag
              ,las.inspection_comment
        from   lgcom_approval_request_n lar,
               lgcom_approval_status_n las
        where  lar.request_master_id = las.request_master_id
        and    lar.request_code      = las.request_code
        and    lar.request_master_id = pi_request_master_id
        and    lar.request_code      = pi_request_code
        and    las.approval_seqs     = pi_approval_seqs;


    BEGIN

        --fnd_profile.get('CM_WEB_AGENT', v_url);

        po_return_code    := 'OK';
        
        
        -- 통합결재 System Code
        BEGIN
           SELECT  common_code
            into   v_approval_system_code
            from   lgcom_common_code_c a       
            where  a.code_type_code = 'LGCOM_APPROVAL_SYSTEM_CODE'
            and    a.code_data1_value = (
                                         SELECT system_code
                                           FROM lgcom_approval_request_n larn
                                          WHERE larn.request_master_id = pi_request_master_id
                                            AND larn.request_code = pi_request_code
                                         );
              EXCEPTION
                WHEN OTHERS THEN
                        po_return_code    := 'NG';
                        po_return_msg := 'Approval System Code Select Error';
                        ROLLBACK;           
        END;
        
        FOR v_rec IN portal_cursor LOOP

            BEGIN
                SELECT nvl(u.language_code,'ko')
                INTO   v_language_code
                FROM   lgcom_user_m u
                WHERE  u.user_name = v_rec.approver_employee_no
                and    trunc(sysdate) between u.apply_start_date and u.apply_end_date;

            EXCEPTION
                WHEN OTHERS THEN
                        po_return_code    := 'NG';
                        po_return_msg := 'Language Code Select Error. Employee Number := '|| v_rec.approver_employee_no;
                        ROLLBACK;
                        RETURN;
            END;

        
            v_portal_requestor_user_name := null;
            BEGIN
                SELECT lum.user_name
                INTO   v_portal_requestor_user_name
                FROM   lgcom_approval_request_n lar
                      ,lgcom_user_m             lum
                WHERE  lar.request_master_id = pi_request_master_id
                AND    lar.request_code = pi_request_code
                AND    lar.requestor_id = lum.application_user_id;
            EXCEPTION
                WHEN OTHERS THEN
                    v_portal_requestor_user_name := NULL;
            END;



            BEGIN
              --2016-12-02   Kimhansik 요청자.승인자 Parm에 erpUserId 추가
                SELECT lccml.common_code_name ,
                       'jobKeyId='|| v_rec.request_master_id || '&'|| 'jobRequestCode=' || v_rec.approval_business_code || '&'|| 'erpUserId='||v_portal_requestor_user_name,
                       lccml.common_code_name ,
                       'jobKeyId='|| v_rec.request_master_id || '&'|| 'jobRequestCode=' || v_rec.approval_business_code || '&'|| 'erpUserId='||v_rec.approver_employee_no
                INTO   v_requestor_screen_url_addr,
                       v_requestor_screen_param_value,
                       v_approver_screen_url_addr,
                       v_approver_screen_param_value
                FROM   lgcom_common_code_c lcc
                      ,lgcom_common_code_multi_lang_c lccml
                WHERE  lcc.code_type_code = lccml.code_type_code
                AND    lcc.common_code = lccml.common_code
                AND    lcc.code_type_code = 'LGCOM_APPROVAL_URL'
                AND    lcc.code_data1_value = (SELECT NAME FROM v$database)
                AND    lccml.language_code = v_language_code--'ko'
                ;

            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    po_return_code    := 'NG';
                    po_return_msg := 'LGCOM_APPROVAL_URL URL Request Master Id : ' || TO_CHAR(v_rec.request_master_id) || ' / SQLCODE : ' || TO_CHAR(SQLCODE) || ' / SQLERRM : ' || SQLERRM;
                    RETURN;

            END;

            v_delegate_name        := v_rec.delegate_name;
            v_delegate_employee_no := v_rec.delegate_employee_no;

            IF v_rec.approval_step_code = '04' THEN
               v_delegate_name        := null;
               v_delegate_employee_no := null;
            END IF;

            if pi_portal_flag = 'Y' then
                BEGIN
                    insert_acpt_proc (p_approval_system_code           =>  v_rec.approval_system_code
                                     ,p_approval_business_code         =>  v_rec.approval_business_code
                                     ,p_approval_business_prcs_no      =>  v_rec.approval_business_prcs_no
                                     ,p_approval_step_no               =>  v_rec.approval_step_no
                                     ,p_approval_title                 =>  v_rec.approval_title
                                     ,p_requestor_name                 =>  v_rec.requestor_name
                                     ,p_requestor_employee_no          =>  v_rec.requestor_employee_no
                                     ,p_first_request_yyyymmdd         =>  v_rec.first_request_yyyymmdd
                                     ,p_approval_step_name             =>  v_rec.approval_step_name
                                     ,p_approval_step_code             =>  v_rec.approval_step_code
                                     ,p_approver_name                  =>  v_rec.approver_name
                                     ,p_approver_employee_no           =>  v_rec.approver_employee_no
                                     ,p_delegate_name                  =>  v_delegate_name --v_rec.delegate_name
                                     ,p_delegate_employee_no           =>  v_delegate_employee_no --v_rec.delegate_employee_no
                                     ,p_approval_line_change_flag      =>  v_rec.approval_line_change_flag
                                     ,p_requestor_screen_url_addr      =>  v_requestor_screen_url_addr
                                     ,p_requestor_screen_param_value   =>  v_requestor_screen_param_value
                                     ,p_approver_screen_url_addr       =>  v_approver_screen_url_addr--v_url || v_approver_screen_url_addr
                                     ,p_approver_screen_param_value    =>  v_approver_screen_param_value--c_request.approver_screen_param_value
                                     ,p_register_ymdhms                =>  v_rec.register_ymdhms
                                     ,p_interface_work_flag            =>  v_rec.interface_work_flag
                                     ,p_eai_seq_id                     =>  v_rec.eai_seq_id
                                     ,p_data_interface_type_code       =>  v_rec.data_interface_type_code
                                     ,p_data_interface_date            =>  v_rec.data_interface_date
                                     ,p_eai_transfer_flag              =>  v_rec.eai_transfer_flag
                                     --,p_error_flag                     => v_return_flag
                                     ,po_return_code                   => po_return_code
                                     ,po_return_msg                    => po_return_msg );

                EXCEPTION WHEN OTHERS THEN
                    --p_error_flag    := 'Y';
                    po_return_code    := 'NG';
                    po_return_msg := '<html>' || '<b>'
                                    || 'Please contact your system administrator. ' || '</b>' || '<br>'
                                    || 'ACPT Transfer Error ('||v_rec.approval_step_name||'). '
                                    || '(SQLCODE:' || SQLCODE || '/SQLERRM:' || SQLERRM || ')' || '<br>'
                                    || '(Reference:' || po_return_code || ')' || '<br>'
                                    || '</html>';
                    RETURN;
                END;
            end if;

            if pi_mail_flag = 'Y' then
              
                BEGIN
                    SELECT TO_NUMBER(a.common_code)
                    INTO   v_mail_template_id
                    FROM   lgcom_common_code_c a
                    WHERE  a.code_type_code = 'LGCOM_APPROVAL_MAIL_TEMPLATE'
                    AND    rownum = 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        
                        po_return_code := 'NG';
                        po_return_msg := '<html>' || '<b>'
                                        || 'mail Templete id is not exists.(Request code : ' ||pi_request_code ||'<br>'
                                        || '</html>';
                    RETURN;
                END;
          
                --'REQUEST','REFERENCE','FORWARD','PREVIEW' 일경우 승인대상자에게 메일링.
                -- 최종승인완료,반려일경우 작성자에게 승인완료메일
                --'APPROVED' : 최종 승인완료상태로 메일발송목적으로 내부적으로만 사용함.
                bit_mail_proc ( pi_request_master_id           =>  pi_request_master_id
                               ,pi_module_code                 =>  v_rec.module_code
                               --,pi_request_code                =>  pi_request_code
                               ,pi_request_no                  =>  v_rec.request_no
                               ,pi_mail_title                  =>  v_rec.mail_title
                               --,pi_requestor_name              =>  v_rec.requestor_name
                               --,pi_approver_name               =>  v_rec.approver_name
                               ,pi_register_ymdhms             =>  v_rec.register_ymdhms
                               ,pi_requestor_employee_no       =>  v_rec.requestor_employee_no
                               ,pi_approver_employee_no        =>  v_rec.approver_employee_no
                               ,pi_status                      =>  pi_request_status
                               ,pi_requestor_screen_url_addr   =>  v_requestor_screen_url_addr
                               ,pi_requestor_screen_param      =>  v_requestor_screen_param_value
                               ,pi_approver_screen_url_addr    =>  v_approver_screen_url_addr
                               ,pi_approver_screen_param       =>  v_approver_screen_param_value
                               ,pi_user_id                     =>  pi_user_id
                               ,pi_request_comment             =>  v_rec.inspection_comment
                               ,pi_mail_templete_id            =>  v_mail_template_id
                               ,po_return_code                 =>  po_return_code
                               ,po_return_msg                  =>  po_return_msg
                               );

            end if;

        END loop;

    exception
      when others then
        po_return_code := 'NG';
        po_return_msg := '<html>' || '<b>'
                        || '(SQLCODE:' || SQLCODE || '/SQLERRM:' || SQLERRM || ')' || '<br>'
                        || '</html>';

    END make_acpt_proc;

    PROCEDURE insert_acpt_proc(p_approval_system_code            IN VARCHAR2
                              ,p_approval_business_code          IN VARCHAR2
                              ,p_approval_business_prcs_no       IN VARCHAR2
                              ,p_approval_step_no                IN VARCHAR2
                              ,p_approval_title                  IN VARCHAR2
                              ,p_requestor_name                  IN VARCHAR2
                              ,p_requestor_employee_no           IN VARCHAR2
                              ,p_first_request_yyyymmdd          IN VARCHAR2
                              ,p_approval_step_name              IN VARCHAR2
                              ,p_approval_step_code              IN VARCHAR2
                              ,p_approver_name                   IN VARCHAR2
                              ,p_approver_employee_no            IN VARCHAR2
                              ,p_delegate_name                   IN VARCHAR2
                              ,p_delegate_employee_no            IN VARCHAR2
                              ,p_approval_line_change_flag       IN VARCHAR2
                              ,p_requestor_screen_url_addr       IN VARCHAR2
                              ,p_requestor_screen_param_value    IN VARCHAR2
                              ,p_approver_screen_url_addr        IN VARCHAR2
                              ,p_approver_screen_param_value     IN VARCHAR2
                              ,p_register_ymdhms                 IN VARCHAR2
                              ,p_interface_work_flag             IN VARCHAR2
                              ,p_eai_seq_id                      IN NUMBER
                              ,p_data_interface_type_code        IN CHAR
                              ,p_data_interface_date             IN DATE
                              ,p_eai_transfer_flag               IN CHAR
                              --,p_error_flag                     OUT VARCHAR2
                              ,po_return_code                     OUT VARCHAR2
                              ,po_return_msg                      OUT VARCHAR2 )
    IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : insert_acpt_proc                                            */
    /* Description  : 통합결제입력                                                */
    /* Reference by :                                                             */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

    v_approver_name                               tb_acpt_master_i.req_nm%type;
    v_approver_employee_no                        tb_acpt_master_i.req_empno%type;
    v_delegate_name                               tb_acpt_master_i.entrust_nm%type;
    v_delegate_employee_no                        tb_acpt_master_i.entrust_empno%type;

    BEGIN

        po_return_code    := 'OK';

        IF p_approval_step_code = '01' THEN   --결재 요청일경우
            IF (p_delegate_employee_no IS NULL
                OR p_delegate_employee_no = ' '
                OR p_delegate_employee_no = p_approver_employee_no ) THEN  --수임자 없을 경우
                v_approver_name        := p_approver_name;
                v_approver_employee_no := p_approver_employee_no;
                v_delegate_name        := ' ';
                v_delegate_employee_no := ' ';
            ELSE      --수임자 있을 경우
                v_approver_name        := p_approver_name;
                v_approver_employee_no := p_approver_employee_no;
                v_delegate_name        := p_delegate_name;
                v_delegate_employee_no := p_delegate_employee_no;
            END IF;
        ELSE
            v_approver_name        := p_approver_name;
            v_approver_employee_no := p_approver_employee_no;
            v_delegate_name        := nvl(p_delegate_name,' ');
            v_delegate_employee_no := nvl(p_delegate_employee_no,' ');
        END IF;

        INSERT INTO tb_acpt_master_i
            (acpt_sys_cd
            ,acpt_biz_cd
            ,acpt_biz_proc_no
            ,acpt_step_no
            ,title
            ,req_nm
            ,req_empno
            ,req_dt
            ,lgcy_step_nm
            ,step_cd
            ,chrgr_nm
            ,chrgr_empno
            ,entrust_nm
            ,entrust_empno
            ,line_chg_yn
            ,req_dtl_url
            ,req_dtl_parm
            ,chrgr_dtl_url
            ,chrgr_dtl_parm
            ,reg_tm
            ,work_yn
            ,eai_seq_id
            ,data_interface_type_code
            ,data_interface_date
            ,eai_transfer_flag)
        VALUES
            (p_approval_system_code
            ,p_approval_business_code
            ,p_approval_business_prcs_no
            ,p_approval_step_no
            ,p_approval_title
            ,p_requestor_name
            ,p_requestor_employee_no
            ,p_first_request_yyyymmdd
            ,p_approval_step_name
            ,p_approval_step_code
            ,v_approver_name
            ,v_approver_employee_no
            ,v_delegate_name
            ,v_delegate_employee_no
            ,p_approval_line_change_flag
            ,p_requestor_screen_url_addr
            ,p_requestor_screen_param_value
            ,p_approver_screen_url_addr
            ,p_approver_screen_param_value
            ,p_register_ymdhms
            ,p_interface_work_flag
            ,p_eai_seq_id
            ,p_data_interface_type_code
            ,p_data_interface_date
            ,p_eai_transfer_flag);


    EXCEPTION WHEN OTHERS THEN
        po_return_code    := 'NG';
        po_return_msg := '<html>' || '<b>'
                        || 'Please contact your system administrator. ' || '</b>' || '<br>'
                        || 'EP Transfer Error. '
                        || '(SQLCODE:' || SQLCODE || '/SQLERRM:' || SQLERRM || ')' || '<br>'
                        || '</html>';
        RETURN;

    END insert_acpt_proc;

    PROCEDURE bit_mail_proc ( pi_request_master_id           IN  NUMBER
                             ,pi_module_code                 IN  VARCHAR2
                             ,pi_request_no                  IN  VARCHAR2
                             ,pi_mail_title                  IN  VARCHAR2
                             ,pi_register_ymdhms             IN  VARCHAR2
                             ,pi_requestor_employee_no       IN  VARCHAR2
                             ,pi_approver_employee_no        IN  VARCHAR2
                             ,pi_status                      IN  VARCHAR2
                             ,pi_requestor_screen_url_addr   IN  VARCHAR2
                             ,pi_requestor_screen_param      IN  VARCHAR2
                             ,pi_approver_screen_url_addr    IN  VARCHAR2
                             ,pi_approver_screen_param       IN  VARCHAR2
                             ,pi_user_id                     IN  NUMBER
                             ,pi_request_comment             IN  VARCHAR2
                             ,pi_mail_templete_id            IN  NUMBER
                             ,po_return_code                 OUT VARCHAR2
                             ,po_return_msg                  OUT VARCHAR2 )
    IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : bit_mail_proc                                               */
    /* Description  : 메일발송                                                    */
    /* Reference by :                                                             */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

    -- Variables for Default Value
    v_seq_id                       lgcom_mail_info.seq_id%type;
    v_module_code                  lgcom_mail_info.module_code%type;
    v_sender_email_addr            lgcom_mail_info.sender_email_addr%type;
    v_receipt_email_addr           lgcom_mail_info.receipt_email_addr%type;
    v_type_code                    lgcom_mail_info.type_code%type;
    v_mail_clob_data               lgcom_mail_info.mail_clob_data%type;
    v_file_name                    lgcom_mail_info.file_name%type;
    --v_content_type_name            lgcom_mail_info.content_type_name%type;
    v_status_code                  lgcom_mail_info.status_code%type;
    v_error_reason_desc            lgcom_mail_info.error_reason_desc%type;
    v_last_update_date             lgcom_mail_info.last_update_date%type;
    v_last_updated_by              lgcom_mail_info.last_updated_by%type;
    v_creation_date                lgcom_mail_info.creation_date%type;
    v_created_by                   lgcom_mail_info.created_by%type;

    -- Variables for URL
    v_mail_logo_url                VARCHAR2(500);
    v_list_symbol_url              VARCHAR2(500);
    v_evs_doc_url                  VARCHAR2(500);
    v_evs_img_url                  VARCHAR2(500);
    v_lgd_logo_url                 VARCHAR2(500);
    v_url                          VARCHAR2(500);
    v_approver_user_id             NUMBER(15);
    v_requestor_user_id            NUMBER(15);

    -- Variables for Approval Information
    v_request_title                tb_acpt_master_i.title%type;

    v_receipt_emp_no           VARCHAR2(30);
    v_sender_emp_no            VARCHAR2(30);
    v_receipt_emp_name         VARCHAR2(452);
    v_sender_emp_name          VARCHAR2(452);

    v_and             VARCHAR2(1) := '&';
    v_language_code   VARCHAR2(10);
    v_corp_code       VARCHAR2(30);
    v_request_status  VARCHAR2(100);
    v_mail_comment_display  VARCHAR2(10);
    
    
    v_mail_title           VARCHAR2(500);
    v_text1                VARCHAR2(500);
    v_text2                VARCHAR2(500);
    v_text3                VARCHAR2(500);
    v_text4                VARCHAR2(500);
    v_request_date         VARCHAR2(20);
    v_request_no           VARCHAR2(100);
    v_param_value          VARCHAR2(1000);
    v_request_comment      VARCHAR2(500);
    v_system_code          VARCHAR2(20);
    --v_mail_id              NUMBER;--Mail_Templete_id


    BEGIN

      --------------------------------------------------------------------------------
      -- Initialize the procedure
      --------------------------------------------------------------------------------
      po_return_code := 'OK';
      -- Set Site URL
      
      /*BEGIN
          
          --System code
          select common_code
          into   v_system_code
          from   lgcom_common_code_c a
          where  a.code_type_code = 'LGCOM_SYSTEM_CODE';

      EXCEPTION WHEN OTHERS THEN
          --p_error_flag    := 'Y';
          po_return_code    := 'NG';
          po_return_msg     := 'system code Not Found. ';
          RETURN;
      END;*/
      
      BEGIN
          --[FIN-EVS] 메일 타이틀 앞부분 가져오기
          select '['||a.code_data1_value||'-'||a.code_data2_value||'] ',a.parent_common_code
          into   v_mail_title,v_system_code
          from   lgcom_common_code_c a
          where  a.code_type_code = 'LGCOM_MODULE_CODE'
          and    a.common_code = pi_module_code
          and    a.use_flag = 'Y';

      EXCEPTION WHEN OTHERS THEN
          --p_error_flag    := 'Y';
          po_return_code    := 'NG';
          po_return_msg     := 'Mail Title Not Found(Module). ';
          RETURN;
      END;


      -- Set Approver and Requestor User ID
         --1. Approver User ID
      BEGIN
          SELECT t.application_user_id,nvl(t.language_code,'ko'),t.corporation_name
          INTO   v_approver_user_id,v_language_code,v_corp_code
          FROM   lgcom_user_m_v t
          WHERE  t.user_name = pi_approver_employee_no
          and    trunc(sysdate) between t.apply_start_date and t.apply_end_date
          and    rownum = 1;
      EXCEPTION WHEN OTHERS THEN
          BEGIN
              SELECT t.application_user_id,nvl(t.language_code,'ko'),t.corporation_name
              INTO   v_approver_user_id,v_language_code,v_corp_code
              FROM   lgcom_user_m_v t
              WHERE  t.user_name = pi_approver_employee_no
              --and    trunc(sysdate) between t.apply_start_date and t.apply_end_date
              and    rownum = 1;
          EXCEPTION WHEN OTHERS THEN
              rollback;
              po_return_code    := 'NG';
              po_return_msg     := 'Approver User ID Not Found. ';
              RETURN;
          END;
      END;
      -- 한국이면 Langauage Code를 ko로 변경함      
      IF nvl(v_corp_code,'X') = 'LGDKR' THEN
         v_language_code := 'ko';
      END IF;
      
         --2. Requestor User ID
      BEGIN
          SELECT t.application_user_id
          INTO   v_requestor_user_id
          FROM   lgcom_user_m_v t
          WHERE  t.user_name = pi_requestor_employee_no;
      EXCEPTION WHEN OTHERS THEN
          --p_error_flag    := 'Y';
          po_return_code    := 'NG';
          po_return_msg := 'Requestor User ID Not Found. ' || pi_requestor_employee_no;
          RETURN;
      END;

      v_request_date  := pi_register_ymdhms;

        --------------------------------------------------------------------------------
        -- Set Dafault Value for xxlge_mail_info Table
        --------------------------------------------------------------------------------

        -- 1. Set Sequence for xxlge_mail_info Table
        BEGIN
            SELECT lgcom_mail_info_seq.NEXTVAL
            INTO   v_seq_id
            FROM   dual;
        EXCEPTION WHEN OTHERS THEN
            po_return_code    := 'NG';
            po_return_msg      := 'Sequence Not Found in xxlge_mail_info Table . ';
            RETURN;
        END;

        -- 2. Set Module Code
        v_module_code := pi_module_code;

        IF pi_status = 'REQUEST' OR
           pi_status = 'REQUESTCANCEL' OR  -- 결재 요청이거나 자기반려인 경우에는 승인자에게 메일 발송
           pi_status = 'FORWARD' OR
           pi_status = 'PREVIEW' OR
           pi_status = 'REFERENCE'  THEN

            -- 3. Set Sendor e-mail Address
            BEGIN
                SELECT a.mail_addr
                      ,a.user_name
                      ,a.full_name_local
                INTO   v_sender_email_addr
                      ,v_sender_emp_no
                      ,v_sender_emp_name
                FROM   lgcom_user_m_v a
                WHERE  a.user_name = pi_requestor_employee_no
                and    rownum = 1;
            EXCEPTION WHEN OTHERS THEN
                po_return_code    := 'NG';
                po_return_msg     := 'e-mail Address Not Found in sender . ';
                RETURN;
            END;

            -- 4. Set Receipt e-mail Address
            BEGIN
                SELECT a.mail_addr
                      ,a.user_name
                      ,a.full_name_local
                INTO   v_receipt_email_addr
                      ,v_receipt_emp_no
                      ,v_receipt_emp_name
                FROM   lgcom_user_m_v a
                WHERE  a.user_name = pi_approver_employee_no
                and    rownum = 1;
            EXCEPTION WHEN OTHERS THEN
                po_return_code    := 'NG';
                po_return_msg := 'e-mail Address Not Found in receipt . ';
                RETURN;
            END;

            -- 결재 승인권자에게 맞는 비용사전품의서 파라메터 셋팅
            /* 메일에서 비용사전품의서 화면 바로 들어가기 URL Setting 변경 */
           
            --v_evs_doc_url := pi_approver_screen_url_addr||'?' || pi_approver_screen_param;
            v_param_value := pi_approver_screen_url_addr||'?' || pi_approver_screen_param;
                             --pi_approver_screen_param;

        ELSIF pi_status = 'APPROVED' OR
              pi_status = 'REJECT'  OR
              pi_status = 'FINAL_REJECT' THEN  -- 결재 승인이거나 결재 반려일 경우에는 요청자에게 메일 발송
              --'APPROVED' 는 승인완료상태로 작성자에게 메일발송을위한 내부 Status로만 사용함.

            -- 3. Set Sender e-mail Address
            BEGIN
                SELECT a.email_addr
                      ,a.employee_no
                      ,a.local_full_name
                INTO   v_sender_email_addr
                      ,v_sender_emp_no
                      ,v_sender_emp_name
                FROM   lgcom_ehr_r_employee a
                WHERE  a.employee_no = pi_approver_employee_no
                and    rownum = 1;
                
            EXCEPTION WHEN OTHERS THEN
                --p_error_flag    := 'Y';
                po_return_code    := 'NG';
                po_return_msg := 'e-mail Address Not Found in sender2 . ';
                RETURN;
            END;

            -- 4. Set Receipt e-mail Address
            BEGIN
                SELECT a.email_addr
                      ,a.employee_no
                      ,a.local_full_name
                INTO   v_receipt_email_addr
                      ,v_receipt_emp_no
                      ,v_receipt_emp_name
                FROM   lgcom_ehr_r_employee a-- xxgifh_global_employee_v
                WHERE  a.employee_no = pi_requestor_employee_no;
            EXCEPTION WHEN OTHERS THEN
                --p_error_flag    := 'Y';
                po_return_code    := 'NG';
                po_return_msg := 'e-mail Address Not Found in receipt2. ';
                RETURN;
            END;

            -- 결재 요청자에게 맞는 비용사전품의서 파라메터 셋팅
            /* 메일에서 비용사전품의서 화면 바로 들어가기 URL Setting 변경 */
            
            v_param_value := pi_requestor_screen_url_addr||'?' || pi_requestor_screen_param;
            --pi_requestor_screen_param;

        END IF;

        IF v_receipt_email_addr IS NULL THEN
                --p_error_flag    := 'Y';
                po_return_code    := 'NG';
                po_return_msg := 'Below person has no email address. Please check.' || '</b>' || '<br>'
                                || '(Employee No: ' || v_receipt_emp_no || ' / Employee Name:'|| v_receipt_emp_name||'<br>';
                RETURN;
        ELSIF v_sender_email_addr IS NULL THEN
                --p_error_flag    := 'Y';
                po_return_code    := 'NG';
                po_return_msg := 'Below person has no email address. Please check.' || '</b>' || '<br>'
                                || '(Employee No: ' || v_sender_emp_no || ' / Employee Name:'|| v_sender_emp_name ||'<br>';
                RETURN;
        END IF;


        -- 5. Set Type Code(T(Text)
        v_type_code := 'T';

        -- 6. Set Subject Text

        -- 7. Set Mail Content
/*        v_mail_long_content :=          '<html>                                                                                                              <head><style>' ||
                               CHR(10)||'Body {font-size:9pt;font-family:Gulim;} P, TR, TD, DIV {font-size:9pt;} P{line-height:100%; margin-top:0; margin-bottom:0;}' ||
                               CHR(10)||'</style>                                                                                                            </head><br>' ||
                               CHR(10)||'<body>' ||
                               CHR(10)||'<table width=500 cellspacing=1 cellpadding=0 border=0>' ||
                               CHR(10)||'<img src="'|| v_mail_logo_url || '">' ||
                               CHR(10)||'</table><br>' ||
                               CHR(10)||'<table width=500 cellspacing=1 cellpadding=0 border=0>' ||
                               CHR(10)||'<tr><td>' ;
*/

        v_mail_comment_display  := 'N';
             
        IF pi_status = 'REQUEST' OR
           pi_status = 'REQUESTCANCEL' OR  -- 결재 요청이거나 자기반려인 경우에는 승인자에게 메일 발송
           pi_status = 'FORWARD' OR
           pi_status = 'PREVIEW' OR
           pi_status = 'REFERENCE'  THEN

            if v_corp_code = 'LGDKR' then

                --'[FIN-BTS] Domestic trip has been requested'
                IF pi_status = 'REQUEST' then
                    v_request_status := '승인을 요청하였습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been requested';
                elsif pi_status = 'REQUESTCANCEL' then
                    v_request_status := '승인요청을 취소하였습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been self rejected';
                elsif pi_status = 'FORWARD' then
                    v_request_status := '전달 하였습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been forwarded';
                elsif pi_status = 'PREVIEW' then
                    v_request_status := '검토를 요청하였습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has requested a review';
                elsif pi_status = 'REFERENCE' then
                    v_request_status := '참조 하였습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been referred';
                end if;                
                

                if pi_status = 'REQUESTCANCEL' then

/*                    v_mail_long_content := v_mail_long_content ||'<br>'||'통합결재 시스템입니다.'|| '<br>' ||
                                         CHR(10)||v_sender_emp_name||'님께서 '||v_request_status|| '<br><br>';
*/                                         
                    v_text1 := '통합결재 시스템입니다.';
                    v_text2 := v_sender_emp_name||'님께서 '||v_request_status;
                    v_text3 := '';
                    v_text4 := '';
                    
                else
/*                    v_mail_long_content := v_mail_long_content ||'<br>'||'통합결재 시스템입니다.'|| '<br>' ||
                                         CHR(10)||v_sender_emp_name||'님께서 '||v_request_status|| '<br>' ||
                                         CHR(10)||'확인하시고 검토부탁드립니다.'|| '<br>' ||
                                         CHR(10)||'Let`s (LGD Global Portal)의 통합결재에서 처리가 가능합니다.'|| '<br><br>'   ;
*/                    
                    v_text1 := '통합결재 시스템입니다.';
                    v_text2 := v_sender_emp_name||'님께서 '||v_request_status;
                    v_text3 := '확인하시고 검토부탁드립니다.';
                    v_text4 := 'LGD Let`s Portal의 통합결재에서 처리가 가능합니다.';
                end if;

            else
                IF pi_status = 'REQUEST' then
                    v_request_status := ' has asked for approval.';
                    v_request_title := v_mail_title||pi_mail_title||' has been requested';
                elsif pi_status = 'REQUESTCANCEL' then
                    v_request_status := ' has canceled your authorization request.';
                    v_request_title := v_mail_title||pi_mail_title||' has been self rejected';
                elsif pi_status = 'FORWARD' then
                    v_request_status := ' has delivered it to you.';
                    v_request_title := v_mail_title||pi_mail_title||' has been forwarded';
                elsif pi_status = 'PREVIEW' then
                    v_request_status := ' has requested a review.';
                    v_request_title := v_mail_title||pi_mail_title||' has requested a review';
                elsif pi_status = 'REFERENCE' then
                    v_request_status := ' referred to you.';
                    v_request_title := v_mail_title||pi_mail_title||' has been referred';
                end if;
                
                
                if pi_status = 'REQUESTCANCEL' then
/*
                    v_mail_long_content := v_mail_long_content ||'<br>'||'This is LGD Global Portal system.'|| '<br>' ||
                                     CHR(10)||v_sender_emp_name||v_request_status|| '<br><br>'   ;
*/                    
                    v_text1 := 'This is LGD Let`s Portal system.';
                    v_text2 := v_sender_emp_name||v_request_status;
                    v_text3 := '';
                    v_text4 := ''; 
                else
/*                    v_mail_long_content := v_mail_long_content ||'<br>'||'This is LGD Global Portal system.'|| '<br>' ||
                                     CHR(10)||v_sender_emp_name||v_request_status|| '<br>' ||
                                     CHR(10)||'Please check and review.'|| '<br>' ||
                                     CHR(10)||'It can be processed by LGD Global Portal system.'|| '<br><br>'   ;
*/                    
                    v_text1 := 'This is LGD Let`s Portal system.';
                    v_text2 := v_sender_emp_name||v_request_status;
                    v_text3 := 'Please check and review.';
                    v_text4 := 'It can be processed by LGD Global Portal system.';
                end if;
            end if;
            
       
/*            v_mail_long_content := v_mail_long_content ||
                                   CHR(10)||'<img src="' || v_list_symbol_url || '">' ||
                                   CHR(10)||'<b>Request date  : </b>' || to_char(to_date(v_request_date,'YYYY-MM-DDHH24:MI:SS'), 'yyyy-mm-dd') || '<br>' ||
                                   CHR(10)||'<img src="' || v_list_symbol_url || '">' ||
                                   CHR(10)||'<b>Request no'||v_and||'nbsp;'||v_and||'nbsp; : </b>' || pi_request_no || '<br>';
*/
        ELSIF pi_status = 'APPROVED' OR
              pi_status = 'REJECT'  OR
              pi_status = 'FINAL_REJECT' THEN

            if v_corp_code = 'LGDKR' then
                IF pi_status = 'APPROVED' then
                    v_request_status := '승인완료 되었습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been approved';
                elsif pi_status = 'REJECT' then
                    v_request_status := '반려 되었습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been rejected';
                elsif pi_status = 'FINAL_REJECT' then
                    v_request_status := '최종반려 되었습니다.';
                    v_request_title := v_mail_title||pi_mail_title||' has been rejected';
                end if;

/*                v_mail_long_content := v_mail_long_content ||'<br>'||'통합결재 시스템입니다.'|| '<br>' ||
                                     CHR(10)||v_receipt_emp_name||'님께서 요청하신건이 '||v_request_status|| '<br>' ||
                                     CHR(10)||'LGD Global Portal시스템에서 확인하시기 바랍니다.'|| '<br><br>'   ;
*/
                v_text1 := '통합결재 시스템입니다.';
                v_text2 := v_receipt_emp_name||'님께서 요청하신건이 '||v_request_status;
                v_text3 := '';
                v_text4 := 'LGD Global Portal시스템에서 확인하시기 바랍니다.';
                
            else
                IF pi_status = 'APPROVED' then
                    v_request_status := ' has been approved.';
                    v_request_title := v_mail_title||pi_mail_title||' has been approved';
                elsif pi_status = 'REJECT' then
                    v_request_status := ' has been rejected.';
                    v_request_title := v_mail_title||pi_mail_title||' has been rejected';
                elsif pi_status = 'FINAL_REJECT' then
                    v_request_status := ' has been rejected.';
                    v_request_title := v_mail_title||pi_mail_title||' has been rejected';
                end if;

/*                v_mail_long_content := v_mail_long_content ||'<br>'||'This is LGD Global Portal system.'|| '<br>' ||
                                     CHR(10)||'Your request from '||v_receipt_emp_name||v_request_status|| '<br>' ||
                                     CHR(10)||'Please check with LGD Global Portal system.'|| '<br><br>'  ;
*/
                v_text1 := 'This is LGD Let`s Portal system.';
                v_text2 := 'Your request from '||v_receipt_emp_name||v_request_status;
                v_text3 := '';
                v_text4 := 'Please check with LGD Let`s Portal system.';
                    
            end if;

            /*v_mail_long_content := v_mail_long_content ||
                                   CHR(10)||'<img src="' || v_list_symbol_url || '">' ||
                                   CHR(10)||'<b>Request date  : </b>' || to_char(to_date(v_request_date,'YYYY-MM-DDHH24:MI:SS'), 'yyyy-mm-dd') || '<br>' ||
                                   CHR(10)||'<img src="' || v_list_symbol_url || '">' ||
                                   CHR(10)||'<b>Request no'||v_and||'nbsp;'||v_and||'nbsp; : </b>' || pi_request_no || '<br>';
*/
        end if;
        
        v_request_date := to_char(to_date(v_request_date,'YYYY-MM-DDHH24:MI:SS'), 'yyyy-mm-dd');
        v_request_no   := pi_request_no;        

        v_request_comment := '';
        
        IF pi_status = 'FORWARD' OR
            pi_status = 'PREVIEW' THEN

            /*v_mail_long_content := v_mail_long_content ||
                                 CHR(10)||'<img src="' || v_list_symbol_url || '">' ||
                                 CHR(10)||'<b>Request Comment : </b>' || pi_request_comment || '<br>' ;
            */ 
            v_mail_comment_display  := 'Y';
            v_request_comment := pi_request_comment;
                                 
        end if;

         /*v_mail_long_content := v_mail_long_content ||
                               CHR(10)||'<br></td>' ||
                               CHR(10)||'</tr>' ||
                               CHR(10)||'</table><br><br>';
*/
        IF pi_status in ('REQUEST','FORWARD','PREVIEW','REFERENCE','APPROVED','REJECT') THEN  -- 결재 요청일 경우
null;
            /*v_mail_long_content := v_mail_long_content ||
                                   CHR(10)||'                                                  <table width=700><tr>' ||
                                   CHR(10)||'                                                  <a href="' || v_evs_doc_url || '">' ||
                                   CHR(10)||'                                                  <img src="' || v_evs_img_url || '" border="0"> </a> '||
                                   CHR(10)||'                                                  </tr></table><br>' ;
*/
        END IF;

        /*v_mail_long_content := v_mail_long_content ||
                               CHR(10)||'                                               <table width=700><tr>' ||
                               CHR(10)||'<img src="' || v_lgd_logo_url || '">'||
                               CHR(10)||'</tr></table>' ||
                               CHR(10)||'</body>' ||
                               CHR(10)||'</html>';
*/
        -- 8. Set Default Value
        v_file_name          := NULL;
        --v_content_type_name  := 'Text/html';
        v_status_code        := 'N';
        v_error_reason_desc  := NULL;
        --v_character_set_name := 'UTF8';
        v_last_update_date   := SYSDATE;
        v_last_updated_by    := pi_user_id;
        v_creation_date      := SYSDATE;
        v_created_by         := pi_user_id;
        --v_last_update_login  := NULL;
        
/*--메일작성양식
{ "subject" : {"name" : "제목 홍길동"} ,
  "data1" :   { "name" : "홍길동",
                "address" : "Seoul Korea",
                "phone" : "010-222-1111" },
  "list1" : [ { "name" : "홍길동1",
                "address" : "Seoul Korea",
                "phone" : "010-222-1111" },
              { "name" : "홍길동2",
                "address" : "Seoul Korea",
                "phone" : "010-222-1111" },
              { "name" : "홍길동3",
                "address" : "Seoul Korea",
                "phone" : "010-222-1111" }
           ] 
}
*/


--## 변수키값은 자바의 카멜표기법을 사용하였고 그리하여야함. ##  -- 
/*{"subject":{"title":"[FIN-EVS] 병렬합의 테스트 has been requested"},
    "data1":{"text1":"통합결재 시스템입니다.",
             "text2":"서춘식님께서 승인을 요청하였습니다.",
             "text3":"확인하시고 검토부탁드립니다.",
             "text4":"Let`s (LGD Global Portal)의 통합결재에서 처리가 가능합니다.",
             "requestDate":"2017-06-29",
             "requestNo":"KR-E-20170629-5379",
             "status":"N",
             "requestComment":"",
             "paramValue":"http://bizweb-dev.lgdisplay.com:9006/lgcom/approval?jobKeyId=35379&jobRequestCode=51002&erpUserId=T962021"}
};*/
        v_mail_clob_data := 
'{'||
    '"subject"'||':' || '{'||'"title":"'         ||v_request_title   ||'"},'||
    '"data1"'  ||':' || '{'||'"text1":"'         ||v_text1           ||'",' ||
                             '"text2":"'         ||v_text2           ||'",' ||
                             '"text3":"'         ||v_text3           ||'",' ||
                             '"text4":"'         ||v_text4           ||'",' ||
                             '"requestDate":"'   ||v_request_date    ||'",' ||
                             '"requestNo":"'     ||v_request_no      ||'",' ||
                             '"status":"'        ||v_mail_comment_display  ||'",' ||
                             '"requestComment":"'||v_request_comment ||'",' ||
                             '"paramValue":"'    ||v_param_value     ||'"}' ||
'}';

-- Templete Table : lgcom_mail_content_n
-- mail_templete_id : 1201

        BEGIN
            INSERT INTO lgcom_mail_info
                      (seq_id                ,system_code            ,module_code            ,sender_email_addr
                      ,receipt_email_addr    ,type_code              ,subject_content
                      ,mail_clob_data        ,file_name              --,content_type_name
                      ,status_code           ,error_reason_desc      ,mail_id                ,language_code
                      ,created_by            ,creation_date          
                      ,last_updated_by       ,last_update_date       )
            VALUES
                      (v_seq_id              ,v_system_code          ,v_module_code          ,v_sender_email_addr
                      ,v_receipt_email_addr  ,v_type_code            ,v_request_title--v_subject_text
                      ,v_mail_clob_data      ,v_file_name            --,v_content_type_name
                      ,v_status_code         ,v_error_reason_desc    ,pi_mail_templete_id    ,v_language_code
                      ,v_created_by          ,v_creation_date       
                      ,v_last_updated_by     ,v_last_update_date     );

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                --p_error_flag    := 'Y';
                po_return_code    := 'NG';
                po_return_msg := 'e-mail Send Error. '||SQLERRM;
               RETURN;

        END;

        po_return_code               := 'OK';
        po_return_msg            := NULL;

    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;

          --p_error_flag    := 'Y';
          po_return_code    := 'NG';
          po_return_msg := 'Send Mail Error (Batch ID : '|| pi_request_master_id ||'). ' || '<br>'
                          || '(SQLCODE:' || SQLCODE || '/SQLERRM:' || SQLERRM || ')';
        RETURN;
    END bit_mail_proc;

    FUNCTION call_arm_info_old(p_arm_no              IN VARCHAR2, -- '2410'
                          p_org_id               IN NUMBER,   -- 89
                          p_emp_no               IN VARCHAR2, -- 사번
                          p_additional_type_code IN VARCHAR2, -- NULL
                          p_additional_code      IN VARCHAR2, -- NULL
                          p_rule1_type           IN VARCHAR2, -- NULL
                          p_rule1_code           IN VARCHAR2, -- NULL
                          p_rule2_type           IN VARCHAR2, -- NULL
                          p_rule2_code           IN VARCHAR2, -- NULL   
                          p_range_code           IN VARCHAR2, -- 'AMOUNT'
                          p_uom_code             IN VARCHAR,  -- 'KRW'
                          p_range_value          IN NUMBER    -- 10000
                          )        RETURN   lgcom_arm_out_tab PIPELINED as
                          
  
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : 웹서비스를 통해 ERP재량권데이타를 호출한다.                 */
    /* Description  :                                                             */
    /* Reference by : 웹공통 Framework에서  ERP ARM 호출                          */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-10-23   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        PRAGMA AUTONOMOUS_TRANSACTION;
          
      req  lgcom_soap_handler.request;
      resp lgcom_soap_handler.response;
      
      --req  lgcom_soap_handler.request;
      --resp lgcom_soap_handler.response;

      oneRow LGCOM_RETRIEVE_AUTH_MTRX_OUT := 
             LGCOM_RETRIEVE_AUTH_MTRX_OUT(NULL,NULL,NULL,NULL,NULL,
                                          NULL,NULL,NULL,NULL,NULL,
                                          NULL,NULL,NULL,NULL,NULL,
                                          NULL,NULL);

      TYPE tCursor IS REF CURSOR;
      vCursor tCursor;
      vStmtStr varchar2(255) := 'select value(p) from table(xmlsequence(extract(:1, :2))) p';

      vDoc xmltype;

    BEGIN

      req := lgcom_soap_handler.new_request
      (
        'ERP/callLGComAuthority/1.0',
        'process',
        'utf-8',
        'InputParameters',
        'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/LGCOM_WS_PKG/GET_APPROVAL_LIST/' ,--'http://lgdsoa.lgdisplay.com/eai/callLGComAuthority',
        'OutputParameters',
        'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/LGCOM_WS_PKG/GET_APPROVAL_LIST/' --'http://lgdsoa.lgdisplay.com/eai/callLGComAuthority'
      );

     
      lgcom_soap_handler.add_parameter_tag_start(req, 'P_IN_TBL');
      lgcom_soap_handler.add_parameter_tag_start(req, 'P_IN_TBL_ITEM');

      lgcom_soap_handler.add_parameter(req, 'P_PGM_SEQ'               ,p_arm_no);
      lgcom_soap_handler.add_parameter(req, 'P_ORG_ID'                ,p_org_id);
      lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_USER_ID'     ,NULL);
      lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_EMP_NO'      ,p_emp_no);
      lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_TYPE_CODE'  ,p_additional_type_code);
      lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_CODE'       ,p_additional_code);
      lgcom_soap_handler.add_parameter(req, 'P_RULE1_TYPE'            ,p_rule1_type);
      lgcom_soap_handler.add_parameter(req, 'P_RULE1_CODE'            ,p_rule1_code);
      lgcom_soap_handler.add_parameter(req, 'P_RULE2_TYPE'            ,p_rule2_type);
      lgcom_soap_handler.add_parameter(req, 'P_RULE2_CODE'            ,p_rule2_code);
      lgcom_soap_handler.add_parameter(req, 'P_RANGE_CODE'            ,nvl(p_range_code,'AMOUNT'));
      lgcom_soap_handler.add_parameter(req, 'P_UOM_CODE'              ,nvl(p_uom_code,'KRW'));
      lgcom_soap_handler.add_parameter(req, 'P_RANGE_VALUE'           ,nvl(p_range_value,0));

      lgcom_soap_handler.add_parameter_tag_end  (req, 'P_IN_TBL_ITEM');
      lgcom_soap_handler.add_parameter_tag_end  (req, 'P_IN_TBL');
      
      /* Validation Mode Setting */
      lgcom_soap_handler.validate_xml(req, FALSE);

      lgcom_soap_handler.invoke(req, resp);

      --rtn_msg := lgcom_soap_handler.get_string_val(resp.doc, 'P_APPROVER_NAME');

          --Open vCursor for vStmtStr using resp.doc, '//'||'selCardInfoERPDBOutput';--selCardInfoERPDBOutputCollection, selCardInfoERPDBOutput
          Open vCursor for vStmtStr using resp.doc, '//'||'P_OUT_TBL_ITEM';

          LOOP
              Fetch vCursor into vDoc;
              exit when vCursor%notfound;

              oneRow.P_APPROVAL_SEQ            := lgcom_soap_handler.get_number_val(vDoc, 'P_APPROVAL_SEQ');
              oneRow.P_APPROVER_USER_ID        := lgcom_soap_handler.get_number_val(vDoc, 'P_APPROVER_USER_ID');
              oneRow.P_APPROVER_EMP_NO         := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_EMP_NO');
              oneRow.P_APPROVER_NAME           := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_NAME');
              oneRow.P_APPROVER_POSITION_CODE  := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_CODE');
              oneRow.P_APPROVER_POSITION_NAME  := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_NAME');
              oneRow.P_APPROVER_DEPT_CODE      := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_CODE');
              oneRow.P_APPROVER_DEPT_NAME      := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_NAME');
              oneRow.P_APPROVAL_TYPE_MEANING   := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVAL_TYPE_MEANING');
              oneRow.P_DELEGATE_FLAG           := lgcom_soap_handler.get_string_val(vDoc, 'P_DELEGATE_FLAG');
              oneRow.P_MANDATOR_USER_ID        := lgcom_soap_handler.get_number_val(vDoc, 'P_MANDATOR_USER_ID');
              oneRow.P_MANDATOR_EMP_NO         := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_EMP_NO');
              oneRow.P_MANDATOR_NAME           := lgcom_soap_handler.get_number_val(vDoc, 'P_MANDATOR_NAME');
              oneRow.P_MANDATOR_POSITION_CODE  := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_CODE');
              oneRow.P_MANDATOR_POSITION_NAME  := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_NAME');
              oneRow.P_MANDATOR_DEPT_CODE      := lgcom_soap_handler.get_number_val(vDoc, 'P_MANDATOR_DEPT_CODE');
              oneRow.P_MANDATOR_DEPT_NAME      := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_DEPT_NAME');
        
              --vDoc
              PIPE ROW(oneRow);

          END LOOP;

          close vCursor;

          RETURN;
          
          -- 사용 예)
          -- SELECT *--p_approval_seq,p_approver_user_id,p_approver_emp_no,p_approver_name...
          -- FROM   TABLE( lgcom_bizweb_approval_pkg.call_arm_info_old('2410',89,'x030807',NULL,NULL,NULL,NULL,NULL,NULL,'AMOUNT','KRW',100000));
          -- x사번과 t사번 연결은 ERP xxlge_lookup_values의 LGCOM_PARTNER_EMP_MAPPING 코드에 등록함
    
    END call_arm_info_old;



--------------------------------------------------------------------
/*
--DEV5 클로닝 작업으로 다운되어 임시로 내부처리 하는 것으로 변경
FUNCTION call_arm_info(p_arm_no              IN VARCHAR2, -- '2410'
                      p_org_id               IN NUMBER,   -- 89
                      p_emp_no               IN VARCHAR2, -- 사번
                      p_additional_type_code IN VARCHAR2, -- NULL
                      p_additional_code      IN VARCHAR2, -- NULL
                      p_rule1_type           IN VARCHAR2, -- NULL
                      p_rule1_code           IN VARCHAR2, -- NULL
                      p_rule2_type           IN VARCHAR2, -- NULL
                      p_rule2_code           IN VARCHAR2, -- NULL   
                      p_range_code           IN VARCHAR2, -- 'AMOUNT'
                      p_uom_code             IN VARCHAR,  -- 'KRW'
                      p_range_value          IN NUMBER    -- 10000
                      )        RETURN   lgcom_approval_status_tbl PIPELINED as
                          
  PRAGMA AUTONOMOUS_TRANSACTION;
          
  oneRow lgcom_approval_status_obj := 
         lgcom_approval_status_obj( NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL,NULL,NULL,
                                    NULL,NULL,NULL);
BEGIN

FOR apr IN (
        SELECT approver_seq_no            AS approval_seqs
              ,approver_user_id           AS employee_id
              ,approver_employee_no	      AS employee_no
              ,approver_name	            AS employee_name
              ,approver_title_name	      AS title_name
              ,approver_organization_code	AS department_code
              ,approver_organization_name	AS department_name
              ,approver_position_name	    AS position_name
              ,NULL                       AS approval_action_code
              ,NULL                       AS mandator_employee_no
              ,NULL                       AS mendator_employee_name
              ,NULL                       AS mendator_title_name
              ,NULL                       AS mendator_department_code
        FROM   TABLE(CAST(lgvatt_common_pkg.get_appr_line('LGDVN', p_emp_no, 'TA_CODE') AS lgvatt_appr_line_tbl)) dt \* 결재자 임시 조회 *\
        ORDER BY approver_seq_no
       )
LOOP
          oneRow.P_APPROVAL_SEQS           := apr.approval_seqs;
          oneRow.p_user_id                 := apr.employee_id;
          oneRow.P_USER_NO                 := apr.employee_no;
          oneRow.p_user_name               := apr.employee_name;
          oneRow.p_user_title_name         := apr.title_name;
          oneRow.p_user_dept_code          := apr.department_code;
          oneRow.p_user_dept_name          := apr.department_name;
          oneRow.p_user_position_name      := apr.position_name;
          oneRow.P_SIGN_USER_NO            := NULL;
          oneRow.p_mand_emp_user_id        := NULL;
          oneRow.P_MANDATOR_EMPLOYEE_NO    := NULL;
          oneRow.P_SETTLEMENT_DELETE_FLAG  := 'Y';

          PIPE ROW(oneRow);
END LOOP;

END call_arm_info;
*/

--------------------------------------------------------------------



    FUNCTION call_arm_info(p_arm_no              IN VARCHAR2, -- '2410'
                          p_org_id               IN NUMBER,   -- 89
                          p_emp_no               IN VARCHAR2, -- 사번
                          p_additional_type_code IN VARCHAR2, -- NULL
                          p_additional_code      IN VARCHAR2, -- NULL
                          p_rule1_type           IN VARCHAR2, -- NULL
                          p_rule1_code           IN VARCHAR2, -- NULL
                          p_rule2_type           IN VARCHAR2, -- NULL
                          p_rule2_code           IN VARCHAR2, -- NULL   
                          p_range_code           IN VARCHAR2, -- 'AMOUNT'
                          p_uom_code             IN VARCHAR,  -- 'KRW'
                          p_range_value          IN NUMBER    -- 10000
                          )        RETURN   lgcom_approval_status_tbl PIPELINED as
                          
  
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : 웹서비스를 통해 ERP재량권데이타를 호출한다.                 */
    /* Description  :                                                             */
    /* Reference by : 웹공통 Framework에서  ERP ARM 호출                          */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-10-23   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/

        PRAGMA AUTONOMOUS_TRANSACTION;
          
      req  lgcom_soap_handler.request;
      resp lgcom_soap_handler.response;
      
      --req  lgcom_soap_handler.request;
      --resp lgcom_soap_handler.response;

      oneRow lgcom_approval_status_obj := 
             lgcom_approval_status_obj( NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL);

      TYPE tCursor IS REF CURSOR;
      vCursor tCursor;
      vStmtStr varchar2(255) := 'select value(p) from table(xmlsequence(extract(:1, :2))) p';

      vDoc xmltype;
            
      V_APPROVAL_SEQS           NUMBER;
      V_APPROVER_USER_ID        NUMBER;
      V_APPROVER_EMP_NO         VARCHAR2(100);
      V_APPROVER_NAME           VARCHAR2(100);
      V_APPROVER_POSITION_CODE  VARCHAR2(100);
      V_APPROVER_POSITION_NAME  VARCHAR2(100);
      V_APPROVER_DEPT_CODE      VARCHAR2(100);
      V_APPROVER_DEPT_NAME      VARCHAR2(100);
      V_APPROVAL_TYPE_MEANING   VARCHAR2(100);
      V_DELEGATE_FLAG           VARCHAR2(100);
      V_MANDATOR_USER_ID        NUMBER;
      V_MANDATOR_EMP_NO         VARCHAR2(100);
      V_MANDATOR_NAME           VARCHAR2(100);
      V_MANDATOR_POSITION_CODE  VARCHAR2(100);
      V_MANDATOR_POSITION_NAME  VARCHAR2(100);
      V_MANDATOR_DEPT_CODE      VARCHAR2(100);
      V_MANDATOR_DEPT_NAME      VARCHAR2(100);
      
      
        v_approval_status_code    VARCHAR2(100);
        v_approval_status_name    VARCHAR2(100);
        v_app_approval_seqs           NUMBER;
        v_ref_approval_seqs           NUMBER;
        v_result_approval_seqs        NUMBER;
        v_app_process_seq_no          NUMBER;
        v_ref_process_seq_no          NUMBER;
        v_result_process_seq_no       NUMBER;

        v_approver_title_name     VARCHAR2(100);
        v_org_id                  NUMBER;
        --v_requestor_user_no       VARCHAR2(100);
        
        v_mandator_title_name     VARCHAR2(100);

        v_progress_code           VARCHAR2(100);
        v_approval_method_code    VARCHAR2(100);
        v_last_approval_type      VARCHAR2(100);
        v_curr_approval_type      VARCHAR2(100);
        v_approval_action_code    VARCHAR2(100);
        v_approval_action_name    VARCHAR2(100);

        v_language_code           VARCHAR2(10);

    BEGIN

      req := lgcom_soap_handler.new_request
      (
        'ERP/callLGComAuthority/1.0',
        'process',
        'utf-8',
        'InputParameters',
        'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/LGCOM_WS_PKG/GET_APPROVAL_LIST/' ,--'http://lgdsoa.lgdisplay.com/eai/callLGComAuthority',
        'OutputParameters',
        'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/LGCOM_WS_PKG/GET_APPROVAL_LIST/' --'http://lgdsoa.lgdisplay.com/eai/callLGComAuthority'
      );

     
      lgcom_soap_handler.add_parameter_tag_start(req, 'P_IN_TBL');
      lgcom_soap_handler.add_parameter_tag_start(req, 'P_IN_TBL_ITEM');

      lgcom_soap_handler.add_parameter(req, 'P_PGM_SEQ'               ,p_arm_no);
      lgcom_soap_handler.add_parameter(req, 'P_ORG_ID'                ,p_org_id);
      lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_USER_ID'     ,NULL);
      lgcom_soap_handler.add_parameter(req, 'P_REQUESTOR_EMP_NO'      ,p_emp_no);
      lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_TYPE_CODE'  ,p_additional_type_code);
      lgcom_soap_handler.add_parameter(req, 'P_ADDITIONAL_CODE'       ,p_additional_code);
      lgcom_soap_handler.add_parameter(req, 'P_RULE1_TYPE'            ,p_rule1_type);
      lgcom_soap_handler.add_parameter(req, 'P_RULE1_CODE'            ,p_rule1_code);
      lgcom_soap_handler.add_parameter(req, 'P_RULE2_TYPE'            ,p_rule2_type);
      lgcom_soap_handler.add_parameter(req, 'P_RULE2_CODE'            ,p_rule2_code);
      lgcom_soap_handler.add_parameter(req, 'P_RANGE_CODE'            ,nvl(p_range_code,'AMOUNT'));
      lgcom_soap_handler.add_parameter(req, 'P_UOM_CODE'              ,nvl(p_uom_code,'KRW'));
      lgcom_soap_handler.add_parameter(req, 'P_RANGE_VALUE'           ,nvl(p_range_value,0));

      lgcom_soap_handler.add_parameter_tag_end  (req, 'P_IN_TBL_ITEM');
      lgcom_soap_handler.add_parameter_tag_end  (req, 'P_IN_TBL');
      
      /* Validation Mode Setting */
      lgcom_soap_handler.validate_xml(req, FALSE);

      lgcom_soap_handler.invoke(req, resp);

      --rtn_msg := lgcom_soap_handler.get_string_val(resp.doc, 'P_APPROVER_NAME');

          --Open vCursor for vStmtStr using resp.doc, '//'||'selCardInfoERPDBOutput';--selCardInfoERPDBOutputCollection, selCardInfoERPDBOutput
          Open vCursor for vStmtStr using resp.doc, '//'||'P_OUT_TBL_ITEM';

          LOOP
              Fetch vCursor into vDoc;
              exit when vCursor%notfound;
              

              V_APPROVAL_SEQS            := lgcom_soap_handler.get_number_val(vDoc, 'P_APPROVAL_SEQ');
              --V_APPROVER_USER_ID        := lgcom_soap_handler.get_number_val(vDoc, 'P_APPROVER_USER_ID');
              V_APPROVER_EMP_NO         := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_EMP_NO');
              V_APPROVER_NAME           := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_NAME');
              V_APPROVER_POSITION_CODE  := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_CODE');
              V_APPROVER_POSITION_NAME  := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_NAME');
              V_APPROVER_DEPT_CODE      := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_CODE');
              V_APPROVER_DEPT_NAME      := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_NAME');
              V_APPROVAL_TYPE_MEANING   := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVAL_TYPE_MEANING');
              V_DELEGATE_FLAG           := lgcom_soap_handler.get_string_val(vDoc, 'P_DELEGATE_FLAG');
              --V_MANDATOR_USER_ID        := lgcom_soap_handler.get_number_val(vDoc, 'P_MANDATOR_USER_ID');
              V_MANDATOR_EMP_NO         := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_EMP_NO');
              V_MANDATOR_NAME           := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_NAME');
              V_MANDATOR_POSITION_CODE  := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_CODE');
              V_MANDATOR_POSITION_NAME  := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_NAME');
              V_MANDATOR_DEPT_CODE      := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_DEPT_CODE');
              V_MANDATOR_DEPT_NAME      := lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_DEPT_NAME');
              
              
              --재량권과 LGCOM 결재 Approval_type Mapping
              --AGREEMENT,APPROVAL,PARAGREE,NOTICE,REPORT
              if upper(V_APPROVAL_TYPE_MEANING) = 'PARAGREE' then
                  v_curr_approval_type := 'PARAGREE_ALL';

                  v_progress_code := '0002';
                  v_approval_method_code := '0001';
              elsif upper(V_APPROVAL_TYPE_MEANING) in ('NOTICE','REPORT') then
                  v_curr_approval_type   := 'REFERENCE';
                  v_progress_code        := NULL;
                  v_approval_method_code := NULL;
              else
                  --AGREEMENT,APPROVAL는 그대로 유지.
                  v_curr_approval_type := upper(V_APPROVAL_TYPE_MEANING);
                  v_progress_code := '0002';
                  v_approval_method_code := '0001';
              end if;

              --결재요청자 v_app_process_seq_no = 10 , v_app_approval_seqs = 1
              if v_last_approval_type is null then
                  if v_curr_approval_type in ('AGREEMENT','APPROVAL','PARAGREE_ALL') then
                      v_app_process_seq_no := 20;
                      v_app_approval_seqs  := 1;
                  elsif v_curr_approval_type = 'REFERENCE' then
                      v_ref_process_seq_no := 0;
                      v_ref_approval_seqs  := 10001;
                  end if;

              else
                  if v_curr_approval_type in ('AGREEMENT','APPROVAL','PARAGREE_ALL') then

                      v_app_approval_seqs  := v_app_approval_seqs + 1;

                      if v_last_approval_type like 'PARAGREE%' and
                         v_last_approval_type = v_curr_approval_type then
                          v_app_process_seq_no := v_app_process_seq_no;
                      else
                          v_app_process_seq_no := v_app_process_seq_no + 10;
                      end if;
                  elsif v_curr_approval_type = 'REFERENCE' then
                      v_ref_process_seq_no := 0;
                      v_ref_approval_seqs  := v_ref_approval_seqs + 1;
                  end if;
              end if;

              v_last_approval_type := v_curr_approval_type;

              if v_curr_approval_type in ('AGREEMENT','APPROVAL','PARAGREE_ALL') then
                  v_result_approval_seqs  := v_app_approval_seqs;--v_app_process_seq_no;
                  v_result_process_seq_no := v_app_process_seq_no;--v_app_approval_seqs;
              elsif v_curr_approval_type = 'REFERENCE' then
                  v_result_approval_seqs  := v_ref_approval_seqs;--v_ref_process_seq_no;
                  v_result_process_seq_no := v_ref_process_seq_no;--v_ref_approval_seqs;
              end if;

              V_APPROVER_USER_ID    := NULL;
              v_approver_title_name := NULL;
              
              begin
                  select lum.application_user_id,nvl(lum.default_org_id,p_org_id),nvl(lum.language_code,'ko'),lum.title_name
                  into   V_APPROVER_USER_ID,v_org_id,v_language_code,v_approver_title_name
                  from   lgcom_user_m_v lum
                  where  lum.user_name = V_APPROVER_EMP_NO;
              exception
                when others then
                  null;
              END;
              
              V_MANDATOR_USER_ID    := NULL;
              v_mandator_title_name := NULL;
              if V_MANDATOR_EMP_NO is not null then
                  BEGIN
                      select lum.application_user_id,lum.title_name
                      into   V_MANDATOR_USER_ID,v_mandator_title_name
                      from   lgcom_user_m_v lum
                      where  lum.user_name = V_MANDATOR_EMP_NO;
                  exception
                    when others then
                      null;
                  end;

              end if;
              

              begin
                SELECT lcc.common_code
                     , lccm.common_code_name
                  into v_approval_action_code
                     , v_approval_action_name
                  FROM LGCOM_CODE_TYPE_CODE_C         lct
                     , LGCOM_COMMON_CODE_C            lcc
                     , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
                 WHERE lct.code_type_code = lcc.code_type_code
                   AND lct.code_type_code = lccm.code_type_code
                   AND lcc.common_code    = lccm.common_code
                   AND lcc.company_id     = lccm.company_id
                   AND lcc.inventory_organization_id = lccm.inventory_organization_id
                   AND lcc.code_type_code = lccm.code_type_code
                   AND lcc.use_flag       = 'Y'
                   AND lcc.common_code    = v_curr_approval_type
                   AND lccm.language_code = v_language_code
                   AND lcc.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                   AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
                   AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE;
              exception
                when others then
                  null;
              end;

              begin
                  SELECT lcc.common_code
                       , lccm.common_code_name
                    into v_approval_status_code
                       , v_approval_status_name
                    FROM LGCOM_CODE_TYPE_CODE_C         lct
                       , LGCOM_COMMON_CODE_C            lcc
                       , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
                   WHERE lct.code_type_code = lcc.code_type_code
                     AND lct.code_type_code = lccm.code_type_code
                     AND lcc.common_code    = lccm.common_code
                     AND lcc.company_id     = lccm.company_id
                     AND lcc.inventory_organization_id = lccm.inventory_organization_id
                     AND lcc.code_type_code = lccm.code_type_code
                     AND lcc.use_flag       = 'Y'
                     AND lccm.language_code = v_language_code
                     AND lcc.common_code = '1'
                     AND lcc.code_type_code = 'LGCOM_APPROVAL_STATUS_CODE'
                     AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
                     AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE;
              exception
                when others then
                  null;
              end;
              
              oneRow.P_REQUEST_MASTER_ID       := null;
              oneRow.P_REQUEST_CODE            := null;
              oneRow.P_APPROVAL_SEQS           := lgcom_soap_handler.get_number_val(vDoc, 'P_APPROVAL_SEQ');
              oneRow.P_ORGANIZATION_ID         := v_org_id;
              oneRow.P_PROCESS_SEQ_NO          := v_result_process_seq_no;
              oneRow.P_PROGRESS_CODE           := v_progress_code;
              oneRow.p_user_id                 := V_APPROVER_USER_ID;
              oneRow.P_USER_NO                 := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_EMP_NO');
              oneRow.p_user_name               := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_NAME');
              oneRow.p_user_title_name         := v_APPROVER_title_name;
              --oneRow.P_APPROVER_POSITION_CODE  := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_CODE');
              oneRow.p_user_dept_code          := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_CODE');
              oneRow.p_user_dept_name          := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_DEPT_NAME');
              oneRow.p_user_position_name      := lgcom_soap_handler.get_string_val(vDoc, 'P_APPROVER_POSITION_NAME');
              oneRow.P_SIGN_USER_NO            := NULL;
              oneRow.P_APPROVAL_STATUS_CODE    :=  v_approval_status_code;
              oneRow.P_APPROVAL_STATUS_NAME    :=  v_approval_status_name;
              oneRow.P_APPROVAL_DATE           :=  NULL;
              oneRow.P_APPROVAL_ACTION_CODE    :=  v_approval_action_code;
              oneRow.P_APPROVAL_ACTION_NAME    :=  v_approval_action_name;
              oneRow.P_APPROVAL_METHOD_CODE    :=  v_approval_method_code;
              oneRow.P_APPROVAL_DUTY_CODE      :=  NULL;
              oneRow.P_APPROVAL_COMMENT        :=  NULL;
              oneRow.P_INSPECTION_COMMENT      :=  NULL;
              oneRow.P_SHARE_FLAG              :=  NULL;
              oneRow.P_RETURN_FLAG             :=  NULL;
              oneRow.p_mand_emp_user_id        :=  V_MANDATOR_USER_ID;
              oneRow.P_MANDATOR_EMPLOYEE_NO    :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_EMP_NO');
              oneRow.p_mand_emp_name           :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_NAME');
              oneRow.p_mand_emp_title_name     :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_NAME');
              oneRow.p_mand_emp_dept_code      :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_DEPT_CODE');
              oneRow.p_mand_emp_dept_name      :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_DEPT_NAME');
              oneRow.p_mand_position_name      :=  lgcom_soap_handler.get_string_val(vDoc, 'P_MANDATOR_POSITION_NAME');
              oneRow.P_APPROVAL_LINE_ID        :=  NULL;
              oneRow.P_SETTLEMENT_DELETE_FLAG  :=  'Y';
              oneRow.P_CREATION_DATE           :=  sysdate;
              oneRow.P_CREATED_BY              :=  V_APPROVER_USER_ID;
              oneRow.P_LAST_UPDATE_DATE        :=  sysdate;
              oneRow.P_LAST_UPDATED_BY         :=  V_APPROVER_USER_ID;
              
              --vDoc
              PIPE ROW(oneRow);

          END LOOP;

          close vCursor;

          RETURN;
          
          -- 사용 예)
          -- SELECT *--p_approval_seq,p_approver_user_id,p_approver_emp_no,p_approver_name...
          -- FROM   TABLE( lgcom_bizweb_approval_pkg.call_arm_info('2410',89,'x030807',NULL,NULL,NULL,NULL,NULL,NULL,'AMOUNT','KRW',100000));
          -- x사번과 t사번 연결은 ERP xxlge_lookup_values의 LGCOM_PARTNER_EMP_MAPPING 코드에 등록함

    END call_arm_info;
    
    FUNCTION get_approval_info(p_user_id         IN NUMBER
                              ,p_position_code   IN VARCHAR2
                              ,p_portal_mandator_flag in VARCHAR2 default 'Y'--통합결재 위임여부
                               )
                          RETURN   lgcom_approval_status_tbl is

    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : 지정된 user 에대한 Parameter Position 이하 승인권자 List 및 위임을 추출한다  */
    /* Description  :                                                             */
    /* Reference by : BIZWEB에서 호출됨                                           */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik         1.0       Initial Release                   */
    /******************************************************************************/


        --v_in_rec  xxautt_retrieve_auth_mtrx_pkg.xxautt_getlist_in_params_rec;
        v_out_tbl lgcom_bizweb_approval_pkg.lgcom_getlist_out_params_tbl;

        --v_return_out_rec lgcom_approval_status_obj;
        v_return_out     lgcom_approval_status_tbl;

        v_approval_status_code    VARCHAR2(30);
        v_approval_status_name    VARCHAR2(30);
        v_approver_user_id        NUMBER;
        v_approver_emp_no         VARCHAR2(100);
        v_approver_emp_name       VARCHAR2(100);
        v_approver_position_code  VARCHAR2(100);
        v_approver_position_name  VARCHAR2(100);
        v_approver_dept_code      VARCHAR2(100);
        v_approver_dept_name      VARCHAR2(100);
        --v_approver_title_code     VARCHAR2(30);
        v_approver_title_name     VARCHAR2(30);
        v_org_id                  NUMBER;
        v_requestor_user_no       VARCHAR2(100);
        v_requestor_user_name     VARCHAR2(100);
        --v_requestor_position_code VARCHAR2(30);
        v_requestor_position_name VARCHAR2(30);
        v_requestor_dept_code     VARCHAR2(100);
        v_requestor_dept_name     VARCHAR2(100);
        v_requestor_title_name    VARCHAR2(30);
        --v_mandator_title_code     VARCHAR2(100);
        v_mandator_title_name     VARCHAR2(100);
        --v_mandator_position_code  VARCHAR2(100);
        --v_mandator_position_name  VARCHAR2(100);
        v_process_seq_no          NUMBER;
        v_approval_action_code    VARCHAR2(30);
        v_approval_action_name    VARCHAR2(30);
        v_progress_code           VARCHAR2(30);
        v_approval_method_code    VARCHAR2(30);
        v_language_code           VARCHAR2(10);

        cursor c_approval_list is
        SELECT
               'APPROVAL' AS approval_action_code
               , (SELECT common_code_name
                    FROM LGCOM_COMMON_CODE_MULTI_LANG_C
                   WHERE code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                     AND common_code    = 'APPROVAL'
                     AND language_code  = 'en') AS approval_action_name
               , ROWNUM AS approval_seqs
               , a.organization_code department_code
               , NVL(a.organization_name,a.organization_name_en) AS department_name
               , (SELECT lum.application_user_id
                  FROM LGCOM_USER_M_V  lum
                  WHERE lum.employee_id = a.person_id
                  and   trunc(sysdate) between lum.apply_start_date and lum.apply_end_date) AS user_id
               , a.employee_no AS employee_no
               , a.local_full_name as employee_name
               , a.job_title_name title_name
               , a.POSITION_CODE
               , a.POSITION_name POSITION
          FROM lgcom_ehr_r_employee a
         WHERE a.retire_flag = 'C'
         and   to_char(sysdate,'YYYY-MM-DD') between nvl(a.hire_yyyymmdd,to_char(sysdate-1,'YYYY-MM-DD')) and nvl(a.resignation_yyyymmdd,to_char(sysdate+1,'YYYY-MM-DD'))
         and  ((p_position_code = '500' and part_leader_flag = 'Y') or
               ((to_number(a.position_code) >= p_position_code ) or (part_leader_flag = 'Y'))
              )
          CONNECT BY PRIOR a.super_employee_no = a.employee_no
                START WITH a.employee_no = v_requestor_user_no;

        i NUMBER;

    begin

        begin
            select lcv.organization_id,lum.user_name,lum.language_code,lum.full_name_local,
                   lum.position_name,lum.department_code,lum.organization_name_eng,
                   lum.title_name
            into   v_org_id,v_requestor_user_no,v_language_code,v_requestor_user_name,
                   v_requestor_position_name,v_requestor_dept_code,v_requestor_dept_name,
                   v_requestor_title_name
            from   lgcom_user_m_v lum,
                   lgcom_company_v lcv
            where  lum.application_user_id = p_user_id
            and    lum.corporation_name = lcv.short_code
            and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
            and    rownum = 1;
        exception
          when others then
            NULL;
        end;
        /*
        begin
            SELECT hou.organization_id,fu.user_name,xgev.full_name_local,
                   xgev.position_code,xgev.position,xgev.department_code,xgev.organization_name,
                   xgev.title_name
            into   v_org_id,v_requestor_user_no,v_requestor_user_name,
                   v_requestor_position_code,v_requestor_position_name,v_requestor_dept_code,v_requestor_dept_name,
                   v_requestor_title_name
            from   xxgifh_global_employee_t xgev
                   ,fnd_user fu
                   ,hr_operating_units hou
            WHERE  xgev.employee_number = fu.user_name
            and    fu.user_id = p_user_id
            and    xgev.corporation_name = hou.short_code
            and    trunc(sysdate) between fu.start_date and nvl(fu.end_date,trunc(sysdate)+1)
            and    trunc(sysdate) between xgev.effective_start_date and xgev.effective_end_date
            AND rownum = 1;

        exception
          when others then
            v_approver_emp_no := NULL;

        end;*/


        v_return_out := lgcom_approval_status_tbl();
        v_progress_code := '0002';
        v_approval_method_code := '0001';

        i := 0;
        v_process_seq_no := 20;
        for v_app in c_approval_list loop
        --결재권자 가져오기
            i := i + 1;

            if P_portal_mandator_flag = 'Y' then
                --Portal 위임

                v_approver_emp_no := NULL;
                begin

                    SELECT lum.application_user_id approver_user_id,lae.chrgr_empno approver_employee_no ,lum.full_name_local emp_name,
                           lum.title_name,lum.position_code,lum.position_name  position,lum.department_code department_code,lum.organization_name_eng organization_name
                    into   v_approver_user_id,v_approver_emp_no,v_approver_emp_name,
                           v_approver_title_name,v_approver_position_code,v_approver_position_name,v_approver_dept_code,v_approver_dept_name
                    FROM   tb_acpt_entrust_i lae,
                           lgcom_user_m_v lum
                    where  lae.acpt_sys_cd = '14'
                    and    lae.chrgr_empno = lum.user_name
                    and    lae.use_yn             = 'Y'
                    and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
                    and    to_char(sysdate,'YYYYMMDD') between lae.entrust_from_dt and lae.entrust_to_dt
                    and    lae.entrust_empno = v_app.employee_no
                    and    lae.lst_upd_tm = (SELECT max(tae.lst_upd_tm)
                                                      FROM  tb_acpt_entrust_i tae,
                                                            lgcom_user_m_v lumv
                                                      where  tae.acpt_sys_cd       = '14'
                                                      and    tae.chrgr_empno       = lumv.user_name
                                                      and    tae.use_yn            = 'Y'
                                                      and    to_char(sysdate,'YYYYMMDD') between tae.entrust_from_dt and tae.entrust_to_dt
                                                      and    trunc(sysdate) between lumv.apply_start_date and lumv.apply_end_date
                                                      and    tae.entrust_empno = v_app.employee_no
                                                      )
                    and   rownum = 1;
            

                exception
                  when others then
                    v_approver_emp_no := NULL;

                end;
            end if;

            v_return_out.extend;

            if v_approver_emp_no is not null then

                v_out_tbl(i).p_mandator_user_id       := v_app.user_id;
                v_out_tbl(i).p_mandator_emp_no        := v_app.employee_no;
                v_out_tbl(i).p_mandator_name          := v_app.employee_name;
                v_out_tbl(i).p_mandator_position_code := v_app.position_code;
                v_out_tbl(i).p_mandator_position_name := v_app.position;
                v_out_tbl(i).p_mandator_dept_code     := v_app.department_code;
                v_out_tbl(i).p_mandator_dept_name     := v_app.department_name;
                v_mandator_title_name    := v_app.title_name;

                v_out_tbl(i).p_approver_user_id       := v_approver_user_id;
                v_out_tbl(i).p_approver_emp_no        := v_approver_emp_no;
                v_out_tbl(i).p_approver_name          := v_approver_emp_name;
                v_out_tbl(i).p_approver_position_code := v_approver_position_code;
                v_out_tbl(i).p_approver_position_name := v_approver_position_name;
                v_out_tbl(i).p_approver_dept_code     := v_approver_dept_code;
                v_out_tbl(i).p_approver_dept_name     := v_approver_dept_name;
                --v_out_tbl(i).p_approver_title_name    := v_approver_title_name;
            else
                --통합결재에서 위임정보가 없으면 본인이 승인권자임.
                v_out_tbl(i).p_approver_user_id       := v_app.user_id;
                v_out_tbl(i).p_approver_emp_no        := v_app.employee_no;
                v_out_tbl(i).p_approver_name          := v_app.employee_name;
                v_out_tbl(i).p_approver_position_code := v_app.position_code;
                v_out_tbl(i).p_approver_position_name := v_app.position;
                v_out_tbl(i).p_approver_dept_code     := v_app.department_code;
                v_out_tbl(i).p_approver_dept_name     := v_app.department_name;
                v_approver_title_name                 := v_app.title_name;
                --v_out_tbl(i).p_approver_title_name    := v_app.title_name;

            end if;

            v_out_tbl(i).p_approval_type_meaning  := 'APPROVAL';

            begin
              SELECT lcc.common_code
                   , lccm.common_code_name
                into v_approval_action_code
                   , v_approval_action_name
                FROM LGCOM_CODE_TYPE_CODE_C         lct
                   , LGCOM_COMMON_CODE_C            lcc
                   , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
               WHERE lct.code_type_code = lcc.code_type_code
                 AND lct.code_type_code = lccm.code_type_code
                 AND lcc.common_code    = lccm.common_code
                 AND lcc.company_id     = lccm.company_id
                 AND lcc.inventory_organization_id = lccm.inventory_organization_id
                 AND lcc.code_type_code = lccm.code_type_code
                 AND lcc.use_flag       = 'Y'
                 AND lcc.common_code    = v_out_tbl(i).p_approval_type_meaning
                 AND lccm.language_code = v_language_code
                 AND lcc.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
                 AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
                 AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE;
            exception
              when others then
                null;
            end;

            begin
                SELECT lcc.common_code
                     , lccm.common_code_name
                  into v_approval_status_code
                     , v_approval_status_name
                  FROM LGCOM_CODE_TYPE_CODE_C         lct
                     , LGCOM_COMMON_CODE_C            lcc
                     , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
                 WHERE lct.code_type_code = lcc.code_type_code
                   AND lct.code_type_code = lccm.code_type_code
                   AND lcc.common_code    = lccm.common_code
                   AND lcc.company_id     = lccm.company_id
                   AND lcc.inventory_organization_id = lccm.inventory_organization_id
                   AND lcc.code_type_code = lccm.code_type_code
                   AND lcc.use_flag       = 'Y'
                   AND lccm.language_code = v_language_code
                   AND lcc.common_code    = '1'
                   AND lcc.code_type_code = 'LGCOM_APPROVAL_STATUS_CODE'
                   AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
                   AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
                   AND rownum = 1;
            exception
              when others then
                null;
            end;

            v_return_out(i) := lgcom_approval_status_obj(
                                   P_REQUEST_MASTER_ID      => NULL
                                  ,P_REQUEST_CODE           => NULL
                                  ,P_APPROVAL_SEQS          => v_app.approval_seqs
                                  ,P_ORGANIZATION_ID        => v_org_id
                                  ,P_PROCESS_SEQ_NO         => v_process_seq_no
                                  ,P_PROGRESS_CODE          => v_progress_code
                                  ,p_user_id                => v_out_tbl(i).p_approver_user_id
                                  ,P_USER_NO                => v_out_tbl(i).p_approver_emp_no
                                  ,p_user_name              => v_out_tbl(i).p_approver_name
                                  ,p_user_title_name        => v_approver_title_name
                                  ,p_user_dept_code         => v_out_tbl(i).p_approver_dept_code
                                  ,p_user_dept_name         => v_out_tbl(i).p_approver_dept_name
                                  --,p_user_position_code     => v_approver_position_code
                                  ,p_user_position_name     => v_approver_position_name
                                  ,P_SIGN_USER_NO           => NULL
                                  ,P_APPROVAL_STATUS_CODE   => v_approval_status_code
                                  ,P_APPROVAL_STATUS_NAME   => v_approval_status_name
                                  ,P_APPROVAL_DATE          => NULL
                                  ,P_APPROVAL_ACTION_CODE   => v_approval_action_code
                                  ,P_APPROVAL_ACTION_NAME   => v_approval_action_name
                                  ,P_APPROVAL_METHOD_CODE   => v_approval_method_code
                                  ,P_APPROVAL_DUTY_CODE     => NULL
                                  ,P_APPROVAL_COMMENT       => NULL
                                  ,P_INSPECTION_COMMENT     => NULL
                                  ,P_SHARE_FLAG             => NULL
                                  ,P_RETURN_FLAG            => NULL
                                  ,p_mand_emp_user_id       => v_out_tbl(i).p_mandator_user_id
                                  ,P_MANDATOR_EMPLOYEE_NO   => v_out_tbl(i).p_mandator_emp_no
                                  ,p_mand_emp_name          => v_out_tbl(i).p_mandator_name
                                  ,p_mand_emp_title_name    => v_mandator_title_name
                                  ,p_mand_emp_dept_code     => v_out_tbl(i).p_mandator_dept_code
                                  ,p_mand_emp_dept_name     => v_out_tbl(i).p_mandator_dept_name
                                  --,p_mand_position_code     => v_out_tbl(i).p_mandator_position_code
                                  ,p_mand_position_name     => v_out_tbl(i).p_mandator_position_name
                                  ,P_APPROVAL_LINE_ID       => NULL
                                  ,P_SETTLEMENT_DELETE_FLAG => 'N'
                                  ,P_CREATION_DATE          => sysdate
                                  ,P_CREATED_BY             => p_user_id
                                  ,P_LAST_UPDATE_DATE       => sysdate
                                  ,P_LAST_UPDATED_BY        => p_user_id
                                  );

            v_process_seq_no := v_process_seq_no + 10;

        end loop;

        RETURN(v_return_out);

        --사용예,BIZWEB에서 호출됨. 승인
        --SELECT *--p_approval_seq,p_approver_user_id,p_approver_emp_no,p_approver_name...
        --FROM   TABLE( lgcom_bizweb_approval_pkg.get_approval_info(p_user_id,'300','Y'));

    end get_approval_info;

    FUNCTION get_portal_mandator_info(p_approver_user_id         IN NUMBER
                                    --  ,p_approval_action_code    IN VARCHAR2 Default NULL
                                      )
                          RETURN   lgcom_approval_status_tbl is

    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : 지정된 user 에대한 통합결재 위임정보가 있는지 확인한다      */
    /* Description  :                                                             */
    /* Reference by : BIZWEB에서 호출됨                                           */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2018-08-31   Kimhansik         1.0   Initial Release                       */
    /******************************************************************************/


        --v_out_tbl xxautt_retrieve_auth_mtrx_pkg.xxautt_getlist_out_params_tbl;
        v_out_tbl lgcom_bizweb_approval_pkg.lgcom_getlist_out_params_tbl;

        v_return_out     lgcom_approval_status_tbl;


        v_approval_status_code    VARCHAR2(100);
        v_approval_status_name    VARCHAR2(100);
        v_approver_user_id        NUMBER;
        v_approver_emp_no         VARCHAR2(100);
        v_approver_emp_name       VARCHAR2(100);
        v_approver_position_code  VARCHAR2(100);
        v_approver_position_name  VARCHAR2(100);
        v_approver_dept_code      VARCHAR2(100);
        v_approver_dept_name      VARCHAR2(100);
        v_approver_title_name     VARCHAR2(100);
        v_org_id                  NUMBER;
        v_requestor_user_no       VARCHAR2(100);
        v_requestor_user_name     VARCHAR2(100);
        v_requestor_title_name    VARCHAR2(100);
        v_requestor_dept_code     VARCHAR2(100);
        v_requestor_dept_name     VARCHAR2(100);
        v_requestor_position_code VARCHAR2(100);
        v_requestor_position_name VARCHAR2(100);

        v_mandator_title_name     VARCHAR2(100);
        v_approval_action_code    VARCHAR2(100);
        v_approval_action_name    VARCHAR2(100);
        v_progress_code           VARCHAR2(100);
        v_approval_method_code    VARCHAR2(100);

        v_language_code           VARCHAR2(10);


    begin

        begin
            select lcv.organization_id,lum.user_name,lum.language_code,lum.full_name_local,lum.title_name,
                   lum.position_name,lum.department_code,lum.organization_name_eng
            into   v_org_id,v_requestor_user_no,v_language_code,v_requestor_user_name,v_requestor_title_name,
                   v_requestor_position_name,v_requestor_dept_code,v_requestor_dept_name
            from   lgcom_user_m_v lum,
                   lgcom_company_v lcv
            where  lum.application_user_id = p_approver_user_id
            and    lum.corporation_name = lcv.short_code
            and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date;
        exception
          when others then
            v_approver_emp_no := NULL;
        end;


        v_approver_emp_no := NULL;

        --Portal 위임있는지 확인.
        begin
            SELECT lum.application_user_id approver_user_id,lae.chrgr_empno approver_employee_no ,lum.full_name_local emp_name,
                   lum.title_name,lum.position_code,lum.position_name  position,lum.department_code department_code,lum.organization_name_eng organization_name
            into   v_approver_user_id,v_approver_emp_no,v_approver_emp_name,
                   v_approver_title_name,v_approver_position_code,v_approver_position_name,v_approver_dept_code,v_approver_dept_name
            FROM   tb_acpt_entrust_i lae,
                   lgcom_user_m_v lum
            where  lae.acpt_sys_cd = '14'
            and    lae.chrgr_empno = lum.user_name
            and    lae.use_yn             = 'Y'
            and    trunc(sysdate) between lum.apply_start_date and lum.apply_end_date
            and    to_char(sysdate,'YYYYMMDD') between lae.entrust_from_dt and lae.entrust_to_dt
            and    lae.entrust_empno = v_requestor_user_no
            and    lae.lst_upd_tm = (SELECT max(tae.lst_upd_tm)
                                              FROM  tb_acpt_entrust_i tae,
                                                    lgcom_user_m_v lumv
                                              where  tae.acpt_sys_cd       = '14'
                                              and    tae.chrgr_empno       = lumv.user_name
                                              and    tae.use_yn            = 'Y'
                                              and    to_char(sysdate,'YYYYMMDD') between tae.entrust_from_dt and tae.entrust_to_dt
                                              and    trunc(sysdate) between lumv.apply_start_date and lumv.apply_end_date
                                              and    tae.entrust_empno = v_requestor_user_no
                                              )
            and   rownum = 1;

        exception
          when others then
            v_approver_emp_no := NULL;

        end;

        v_return_out := lgcom_approval_status_tbl();
        v_return_out.extend;

        if v_approver_emp_no is not null then

            v_out_tbl(1).p_mandator_user_id       := p_approver_user_id;
            v_out_tbl(1).p_mandator_emp_no        := v_requestor_user_no;
            v_out_tbl(1).p_mandator_name          := v_requestor_user_name;
            v_out_tbl(1).p_mandator_position_code := v_requestor_position_code;
            v_out_tbl(1).p_mandator_position_name := v_requestor_position_name;
            v_out_tbl(1).p_mandator_dept_code     := v_requestor_dept_code;
            v_out_tbl(1).p_mandator_dept_name     := v_requestor_dept_name;
            v_mandator_title_name                 := v_requestor_title_name;

            v_out_tbl(1).p_approver_user_id       := v_approver_user_id;
            v_out_tbl(1).p_approver_emp_no        := v_approver_emp_no;
            v_out_tbl(1).p_approver_name          := v_approver_emp_name;
            v_out_tbl(1).p_approver_position_code := v_approver_position_code;
            v_out_tbl(1).p_approver_position_name := v_approver_position_name;
            v_out_tbl(1).p_approver_dept_code     := v_approver_dept_code;
            v_out_tbl(1).p_approver_dept_name     := v_approver_dept_name;
            --v_approver_title_name;
        else
            --통합결재에서 위임정보가 없으면 본인이 승인권자임.
            v_out_tbl(1).p_approver_user_id       := p_approver_user_id;
            v_out_tbl(1).p_approver_emp_no        := v_requestor_user_no;
            v_out_tbl(1).p_approver_name          := v_requestor_user_name;
            v_out_tbl(1).p_approver_position_code := v_requestor_position_code;
            v_out_tbl(1).p_approver_position_name := v_requestor_position_name;
            v_out_tbl(1).p_approver_dept_code     := v_requestor_dept_code;
            v_out_tbl(1).p_approver_dept_name     := v_requestor_dept_name;
            v_approver_title_name                 := v_requestor_title_name;

        end if;

        v_out_tbl(1).p_approval_type_meaning  := NULL;--nvl(p_approval_action_code,'APPROVAL');
        v_progress_code := '0002';
        v_approval_method_code := '0001';

        begin
          SELECT lcc.common_code
               , lccm.common_code_name
            into v_approval_action_code
               , v_approval_action_name
            FROM LGCOM_CODE_TYPE_CODE_C         lct
               , LGCOM_COMMON_CODE_C            lcc
               , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
           WHERE lct.code_type_code = lcc.code_type_code
             AND lct.code_type_code = lccm.code_type_code
             AND lcc.common_code    = lccm.common_code
             AND lcc.company_id     = lccm.company_id
             AND lcc.inventory_organization_id = lccm.inventory_organization_id
             AND lcc.code_type_code = lccm.code_type_code
             AND lcc.use_flag       = 'Y'
             AND lcc.common_code    = v_out_tbl(1).p_approval_type_meaning
             AND lccm.language_code = 'en'
             AND lcc.code_type_code = 'LGCOM_APPROVAL_ACTION_CODE'
             AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
             AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE;
        exception
          when others then
            null;
        end;
        begin
            SELECT lcc.common_code
                 , lccm.common_code_name
              into v_approval_status_code
                 , v_approval_status_name
              FROM LGCOM_CODE_TYPE_CODE_C         lct
                 , LGCOM_COMMON_CODE_C            lcc
                 , LGCOM_COMMON_CODE_MULTI_LANG_C lccm
             WHERE lct.code_type_code = lcc.code_type_code
               AND lct.code_type_code = lccm.code_type_code
               AND lcc.common_code    = lccm.common_code
               AND lcc.company_id     = lccm.company_id
               AND lcc.inventory_organization_id = lccm.inventory_organization_id
               AND lcc.code_type_code = lccm.code_type_code
               AND lcc.use_flag       = 'Y'
               AND lccm.language_code = 'en'
               AND lcc.common_code = '1'
               AND lcc.code_type_code = 'LGCOM_APPROVAL_STATUS_CODE'
               AND NVL(lcc.apply_start_date, SYSDATE) <= SYSDATE
               AND NVL(lcc.apply_end_date, SYSDATE) >= SYSDATE
               AND rownum = 1;
        exception
          when others then
            null;
        end;

        v_return_out(1) := lgcom_approval_status_obj(
                               P_REQUEST_MASTER_ID      => NULL
                              ,P_REQUEST_CODE           => NULL
                              ,P_APPROVAL_SEQS          => NULL
                              ,P_ORGANIZATION_ID        => v_org_id
                              ,P_PROCESS_SEQ_NO         => NULL
                              ,P_PROGRESS_CODE          => v_progress_code--'0002'
                              ,p_user_id                => v_out_tbl(1).p_approver_user_id
                              ,P_USER_NO                => v_out_tbl(1).p_approver_emp_no
                              ,p_user_name              => v_out_tbl(1).p_approver_name
                              ,p_user_title_name        => v_approver_title_name
                              ,p_user_dept_code         => v_out_tbl(1).p_approver_dept_code
                              ,p_user_dept_name         => v_out_tbl(1).p_approver_dept_name
                              --,p_user_position_code     => v_approver_position_code
                              ,p_user_position_name     => v_approver_position_name
                              ,P_SIGN_USER_NO           => NULL
                              ,P_APPROVAL_STATUS_CODE   => v_approval_status_code--'1'
                              ,P_APPROVAL_STATUS_NAME   => v_approval_status_name
                              ,P_APPROVAL_DATE          => NULL
                              ,P_APPROVAL_ACTION_CODE   => v_approval_action_code--'APPROVAL'
                              ,P_APPROVAL_ACTION_NAME   => v_approval_action_name
                              ,P_APPROVAL_METHOD_CODE   => v_approval_method_code
                              ,P_APPROVAL_DUTY_CODE     => NULL
                              ,P_APPROVAL_COMMENT       => NULL
                              ,P_INSPECTION_COMMENT     => NULL
                              ,P_SHARE_FLAG             => NULL
                              ,P_RETURN_FLAG            => NULL
                              ,p_mand_emp_user_id       => v_out_tbl(1).p_mandator_user_id
                              ,P_MANDATOR_EMPLOYEE_NO   => v_out_tbl(1).p_mandator_emp_no
                              ,p_mand_emp_name          => v_out_tbl(1).p_mandator_name
                              ,p_mand_emp_title_name    => v_mandator_title_name
                              ,p_mand_emp_dept_code     => v_out_tbl(1).p_mandator_dept_code
                              ,p_mand_emp_dept_name     => v_out_tbl(1).p_mandator_dept_name
                              --,p_mand_position_code     => v_out_tbl(1).p_mandator_position_code
                              ,p_mand_position_name     => v_out_tbl(1).p_mandator_position_name
                              ,P_APPROVAL_LINE_ID       => NULL
                              ,P_SETTLEMENT_DELETE_FLAG => 'N'
                              ,P_CREATION_DATE          => sysdate
                              ,P_CREATED_BY             => p_approver_user_id
                              ,P_LAST_UPDATE_DATE       => sysdate
                              ,P_LAST_UPDATED_BY        => p_approver_user_id
                              );
            --j := J +1;

        RETURN(v_return_out);

        --사용예,BIZWEB에서 호출됨. 승인
        --SELECT *--p_approval_seq,p_approver_user_id,p_approver_emp_no,p_approver_name...
        --FROM   TABLE( lgcom_bizweb_approval_pkg.get_portal_mandator_info(p_user_id));

    end get_portal_mandator_info;

    FUNCTION get_org_id_func (p_user_id NUMBER)
                              RETURN      NUMBER
    IS
    /******************************************************************************/
    /*                                                                            */
    /* Project      : 웹 공통 framework                                           */
    /* Module       : LGCOM                                                       */
    /* Program Name : get_org_id_func                                             */
    /* Description  : get Org Id                                                  */
    /* Reference by :                                                             */
    /*                                                                            */
    /* Program History                                                            */
    /*----------------------------------------------------------------------------*/
    /*   Date       In Charge       Version  Description
    /*----------------------------------------------------------------------------*/
    /* 2017-08-31   Kimhansik       1.0      Initial Version                      */
    /******************************************************************************/

    v_org_id                NUMBER;

    BEGIN

        v_org_id := NULL;

        IF (p_user_id IS NOT NULL ) THEN

            SELECT hou.organization_id
            INTO   v_org_id
            FROM   lgcom_company_v hou
            WHERE  hou.short_code = (SELECT lum.corporation_name
                                     FROM   lgcom_user_m_v lum
                                     WHERE  lum.application_user_id = p_user_id
                                     );
        END IF;

        RETURN v_org_id;

    EXCEPTION WHEN OTHERS THEN

        RETURN NULL;

    END;


end lgcom_bizweb_approval_pkg;
/
