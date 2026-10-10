CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_common_pkg
IS
/*
 * Global Type 으로 생성
 * 각 유저에 권한 부여 : VHR_APP / VHR_VEW
     - GRANT EXECUTE ON lgvatt_common_pkg TO VHR_APP;
     - GRANT EXECUTE ON lgvatt_common_pkg TO VHR_VEW;

 * 각 유저에서 Synonym 생성
     - CREATE OR REPLACE SYNONYM lgvatt_common_pkg FOR VHR_MGR.lgvatt_common_pkg;

CREATE OR REPLACE TYPE lgvatt_appr_line_rec AS OBJECT 
  ( approver_seq_no                    NUMBER         -- 결재자일련순서번호    
   ,approver_employee_no               VARCHAR2(30)   -- 승인자직원번호    
   ,approver_name                      VARCHAR2(240)  -- 승인자명        
   ,approver_position_name             VARCHAR2(100)  -- 결재자직책명    
   ,approver_organization_name         VARCHAR2(240)  -- 결재자조직명    
   ,approver_type_name                 VARCHAR2(100)  -- 결재자구분명    
   ,delegate_flag                      VARCHAR2(1)    -- 위임여부        
   ,mandator_employee_no               VARCHAR2(30)   -- 위임자사원번호  
   ,mandator_name                      VARCHAR2(240)  -- 위임자명        
   ,mandator_position_name             VARCHAR2(100)  -- 위임자직책명    
   ,mandator_organization_name         VARCHAR2(240)  -- 위임자조직명    
  );

CREATE OR REPLACE TYPE lgvatt_appr_line_tbl IS TABLE OF lgvatt_appr_line_rec;


CREATE OR REPLACE TYPE lgvatt_input_date_rec AS OBJECT 
  ( date_seq_no                        NUMBER         -- 날짜일련순서번호  
   ,time_and_attendance_yyyymmdd       VARCHAR2(8)    -- 근태일자(YYYYMMDD)
   ,a_day_of_the_week_code             VARCHAR2(3)    -- 요일코드
   ,holiday_flag                       VARCHAR2(1)    -- 휴일여부
   ,time_and_attendance_yyyymm         VARCHAR2(8)    -- 근태년월
   ,time_and_attendance_date           DATE
   ,inquery_enable_flag                VARCHAR2(1)    -- 조회가능여부
   ,input_enable_flag                  VARCHAR2(1)    -- 입력가능여부
   ,approval_enable_flag               VARCHAR2(1)    -- 결재가능여부
  );

CREATE OR REPLACE TYPE lgvatt_input_date_tbl IS TABLE OF lgvatt_input_date_rec;


CREATE OR REPLACE TYPE lgvatt_result_monthly_rec AS OBJECT 
  ( employee_no                        VARCHAR2(30)   -- 사원번호
   ,time_and_attendance_yyyymm         VARCHAR2(6)    -- 근태년월
   ,working_time_hours                 NUMBER         -- Normal Time
   ,night_hours                        NUMBER         -- Night Time
   ,overtime_hours                     NUMBER         -- Over Time
   ,night_overtime_hours               NUMBER         -- Over Time at Night
   ,paid_vacation_days                 NUMBER         -- Paid Leave
   ,absence_days                       NUMBER         -- Absence
   ,tardy_hours                        NUMBER         -- Lateness
   ,going_out_hours                    NUMBER         -- Going-out
   ,early_leave_hours                  NUMBER         -- Leaving-early
   ,unpaid_vacation_days               NUMBER         -- Unpaid Leave
   ,absence_leave_days                 NUMBER         -- Suspension
  );

CREATE OR REPLACE TYPE lgvatt_result_monthly_tbl IS TABLE OF lgvatt_result_monthly_rec;
*/
g_def_user_id             VARCHAR2(30) := '-1';

FUNCTION get_appr_line (p_subsidiary_code IN VARCHAR2
                       ,p_employee_no     IN VARCHAR2
                       ,p_att_type        IN VARCHAR2
                       ,p_attr1           IN VARCHAR2 DEFAULT NULL
                       ,p_attr2           IN VARCHAR2 DEFAULT NULL
                       ,p_attr3           IN VARCHAR2 DEFAULT NULL
                       ,p_attr4           IN VARCHAR2 DEFAULT NULL
                       ,p_attr5           IN VARCHAR2 DEFAULT NULL
                       )
RETURN lgvatt_appr_line_tbl;



FUNCTION get_input_date (p_subsidiary_code              IN VARCHAR2
                        ,p_time_and_attendance_date     IN DATE
                        ,p_plan_result_type             IN VARCHAR2
                        ,p_today                        IN DATE     DEFAULT NULL
                        ,p_attr1                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr2                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr3                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr4                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr5                        IN VARCHAR2 DEFAULT NULL
                        ,p_recursive_flag               IN VARCHAR2 DEFAULT 'N'
                        )
RETURN lgvatt_input_date_tbl;





FUNCTION get_input_date_lw (p_subsidiary_code              IN VARCHAR2
                           ,p_time_and_attendance_date     IN DATE
                           ,p_shift_type_code              IN VARCHAR2
                           ,p_plan_result_type             IN VARCHAR2
                           ,p_today                        IN DATE     DEFAULT NULL
                           ,p_attr1                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr2                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr3                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr4                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr5                        IN VARCHAR2 DEFAULT NULL
                           ,p_recursive_flag               IN VARCHAR2 DEFAULT 'N'
                           )
RETURN lgvatt_input_date_tbl;


PROCEDURE get_weekday_info (p_subsidiary_code              IN  VARCHAR2,
                            p_time_and_attendance_date     IN  DATE,
                            p_week_code                    OUT VARCHAR2,
                            p_time_and_attendance_code     OUT VARCHAR2,
                            p_holiday_code                 OUT VARCHAR2
                           );

FUNCTION get_attendance_time_by_att (p_subsidiary_code          IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_shift_type_code          IN  VARCHAR2
                                    )
RETURN VARCHAR2;


FUNCTION get_attendance_time_by_shift (p_subsidiary_code              IN  VARCHAR2
                                      ,p_shift_type_code              IN  VARCHAR2
                                      ,p_night_shift_flag             IN  VARCHAR2
                                      )
RETURN VARCHAR2;


FUNCTION get_att_result_monthly (p_subsidiary_code             IN VARCHAR2
                                ,p_employee_no                 IN VARCHAR2
                                ,p_from_time_attendance_yyyymm IN VARCHAR2
                                ,p_to_time_attendance_yyyymm   IN VARCHAR2 DEFAULT NULL
                                ,p_group_type                  IN VARCHAR2 DEFAULT 'GROUP'
                                ,p_attr1                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr2                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr3                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr4                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr5                       IN VARCHAR2 DEFAULT NULL
                                )
RETURN lgvatt_result_monthly_tbl;



FUNCTION get_att_code_rec (p_subsidiary_code          IN VARCHAR2
                          ,p_time_and_attendance_code IN VARCHAR2
                          )
RETURN tb_att_code_c%ROWTYPE;


FUNCTION get_att_calendar_rec (p_subsidiary_code          IN VARCHAR2
                              ,p_time_and_attendance_date IN DATE
                              )
RETURN tb_att_calendar_n%ROWTYPE;


FUNCTION get_att_close_rec (p_subsidiary_code            IN VARCHAR2
                           ,p_time_and_attendance_yyyymm IN VARCHAR2
                           )
RETURN tb_att_close_n%ROWTYPE;



FUNCTION get_att_base_bas_rec (p_subsidiary_code          IN VARCHAR2
                              ,p_time_and_attendance_date IN DATE
                              ,p_shift_type_code          IN VARCHAR2
                              )
RETURN tb_att_base_bas_n%ROWTYPE;


FUNCTION get_att_plan_rec (p_subsidiary_code          IN VARCHAR2
                          ,p_employee_no              IN  VARCHAR2
                          ,p_time_and_attendance_date IN  DATE
                          )
RETURN tb_att_plan_n%ROWTYPE;


FUNCTION get_att_result_rec (p_subsidiary_code          IN VARCHAR2
                            ,p_employee_no              IN  VARCHAR2
                            ,p_time_and_attendance_date IN  DATE
                            )
RETURN tb_att_result_n%ROWTYPE;


FUNCTION get_att_update_req_rec (p_request_no     IN VARCHAR2
                                ,p_request_seq_no IN NUMBER
                                )
RETURN tb_att_update_req_n%ROWTYPE;


FUNCTION get_att_lt_ta_plan_rec (p_planning_id     IN NUMBER
                                ,p_subsidiary_code IN VARCHAR2
                                )
RETURN tb_att_lt_time_attend_plan_n%ROWTYPE;


FUNCTION get_att_annual_leave_rec (p_subsidiary_code            IN VARCHAR2
                                  ,p_employee_no                IN VARCHAR2
                                  ,p_time_and_attendance_yyyymm IN VARCHAR2
                                  )
RETURN tb_att_annual_leave_n%ROWTYPE;


FUNCTION get_att_idcard_acs_time_rec (p_subsidiary_code          IN VARCHAR2
                                     ,p_employee_no              IN VARCHAR2
                                     ,p_time_and_attendance_date IN DATE
                                     )
RETURN tb_att_idcard_acs_time_n%ROWTYPE;


FUNCTION get_att_contract_rec (p_subsidiary_code             IN VARCHAR2
                              ,p_time_attend_contact_user_id IN VARCHAR2
                              ,p_organization_id             IN NUMBER    
                              )
RETURN tb_att_contract_n%ROWTYPE;


FUNCTION get_att_holiday_info_rec (p_subsidiary_code IN VARCHAR2
                                  ,p_holiday_date    IN DATE
                                  )
RETURN tb_att_holiday_info_n%ROWTYPE;

--< Start HMT_20220301 : Get date type
FUNCTION get_att_date_type (p_subsidiary_code           IN  VARCHAR2
                               ,p_employee_no                         IN VARCHAR2
                               ,p_atendance_date                    IN  DATE
                               ,p_type                                    IN  VARCHAR2
                               )
RETURN VARCHAR2; 
--< End

--Start HMT_20221212 Add get_work_type_values function
FUNCTION get_work_values_type(p_subsidiary_code    IN  VARCHAR2,
                                              p_start_date           IN  DATE,
                                              p_end_date             IN  DATE,
                                              p_in_value               IN VARCHAR2,
                                              p_emp_type             IN VARCHAR2,
                                              p_get_type              IN VARCHAR2
                                             )
RETURN NUMBER;
--End

FUNCTION get_work_hours (p_subsidiary_code          IN  VARCHAR2
                        ,p_employee_no              IN  VARCHAR2
                        ,p_time_and_attendance_date IN  DATE
                        )
RETURN VARCHAR2;


FUNCTION get_work_hours (p_subsidiary_code              IN  VARCHAR2
                        ,p_time_and_attendance_code     IN  VARCHAR2
                        ,p_tardy_hours                  IN  NUMBER
                        ,p_going_out_hours              IN  NUMBER
                        ,p_early_leave_hours            IN  NUMBER
                        )
RETURN NUMBER;

FUNCTION get_work_hours_by_att (p_subsidiary_code          IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_shift_type_code          IN  VARCHAR2
                                    )
RETURN NUMBER;

FUNCTION get_work_hours_by_plan (p_subsidiary_code          IN  VARCHAR2
                        ,p_employee_no              IN  VARCHAR2
                        ,p_time_and_attendance_date IN  DATE
                        )
RETURN VARCHAR2;

FUNCTION get_work_days (p_subsidiary_code               IN  VARCHAR2
                        ,p_from_date                    IN  DATE
                        ,p_to_date                      IN  DATE
                        )
RETURN NUMBER;

--< Start HMT_20210703 : Get working day when swap
FUNCTION get_work_days_by_swap (p_subsidiary_code           IN  VARCHAR2
                               ,p_weekly_holiday            IN  DATE
                               ,p_working_day               IN  DATE
                               ,p_employee_no               IN  VARCHAR2
                               ,p_type                      IN  VARCHAR2
                               )
RETURN VARCHAR2; 
--< End

FUNCTION get_working_date (p_subsidiary_code IN VARCHAR2
                          ,p_from_date       IN DATE
                          ,p_days            IN NUMBER
                          ,p_shift_type       IN VARCHAR2 DEFAULT '1A'
                        )
RETURN DATE;


FUNCTION get_att_code_info (p_subsidiary_code          IN  VARCHAR2
                           ,p_time_and_attendance_code IN  VARCHAR2
                           ,p_type                     IN  VARCHAR2 DEFAULT 'NAME'
                           )
RETURN VARCHAR2;


FUNCTION get_holiday_flag(p_subsidiary_code IN VARCHAR2
                         ,p_shift_code      IN VARCHAR2 DEFAULT '1A'
                         ,p_date            IN DATE)
RETURN VARCHAR2;


FUNCTION get_deduc_item_weekly_report(p_subsidiary_code IN  VARCHAR2
                                     ,p_att_date        IN  DATE
                                     ,p_empolyee_no     IN  VARCHAR2 
                                      )
RETURN varchar2;  


FUNCTION get_approval_status (p_request_master_id IN  VARCHAR2
                             ,p_request_code      IN  NUMBER
                             ,p_employee_no       IN  VARCHAR2 default NULL
                             )
RETURN VARCHAR2;
                                              

FUNCTION get_curr_att_yyyymm (p_subsidiary_code IN  VARCHAR2
                             ,p_att_type        IN  VARCHAR2 DEFAULT 'FINAL'
                             )
RETURN VARCHAR2;


FUNCTION get_att_close_time (p_subsidiary_code          IN  VARCHAR2
                            ,p_att_type                 IN  VARCHAR2
                            ,p_time_and_attendance_date IN  DATE
                            ,p_shift_type_code          IN  VARCHAR2 DEFAULT '1A'
                            ,p_screen_type              IN  VARCHAR2 DEFAULT 'DEFAULT'
                            ,p_today                    IN  DATE     DEFAULT SYSDATE
                            )
RETURN DATE;


FUNCTION get_idcard_inout_time (p_subsidiary_code          IN  VARCHAR2
                               ,p_employee_no              IN  VARCHAR2
                               ,p_time_and_attendance_date IN  DATE
                               ,p_inout_type               IN  VARCHAR2
                               )
RETURN DATE;

--< Start HMT_20210315 : Get In Out time of shift type
FUNCTION get_shift_inout_time (p_subsidiary_code           IN  VARCHAR2
                               ,p_shift_type               IN  VARCHAR2
                               ,p_employee_no              IN  VARCHAR2
                               ,p_time_and_attendance_date IN  DATE
                               ,p_inout_type               IN  VARCHAR2
                               )
RETURN DATE; 
--< End

FUNCTION get_unit_requestor ( p_subsidiary_code          IN  VARCHAR2
                             ,p_organization_id          IN  VARCHAR2
                             )
RETURN VARCHAR2;                             


FUNCTION get_att_contract_info (p_subsidiary_code IN  VARCHAR2
                               ,p_organization_id IN  VARCHAR2
                               ,p_type            IN  VARCHAR2 DEFAULT 'EMP_NO'
                               ,p_seq             IN  NUMBER   DEFAULT 1
                               )
RETURN VARCHAR2;


FUNCTION get_last_assignment_type_2nd (p_subsidiary_code     IN  VARCHAR2
                                      ,p_employee_no         IN  VARCHAR2
                                      ,p_assignment_date     IN  DATE
                                      ,p_assignment_type_1st IN  VARCHAR2
                                      ,p_type                IN  VARCHAR2
                                      )
RETURN VARCHAR2;


FUNCTION get_att_result_code_use_days (p_subsidiary_code             IN  VARCHAR2
                                      ,p_employee_no                 IN  VARCHAR2
                                      ,p_from_time_attendance_date   IN  DATE
                                      ,p_to_time_attendance_date     IN  DATE     DEFAULT NULL
                                      ,p_time_and_attendance_code    IN  VARCHAR2
                                      ,p_time_attend_detail_code     IN  VARCHAR2 DEFAULT NULL
                                      )
RETURN NUMBER;


FUNCTION get_att_result_code_use_days (p_subsidiary_code             IN  VARCHAR2
                                      ,p_employee_no                 IN  VARCHAR2
                                      ,p_from_time_attendance_yyyymm IN  VARCHAR2
                                      ,p_to_time_attendance_yyyymm   IN  VARCHAR2 DEFAULT NULL
                                      ,p_time_and_attendance_code    IN  VARCHAR2
                                      ,p_time_attend_detail_code     IN  VARCHAR2 DEFAULT NULL
                                      )
RETURN NUMBER;


END lgvatt_common_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_common_pkg
IS


/*************************************************************************************************/
/* Program Name : get_appr_line                                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태유형에 따라서 결재선을 조회하여 return 한다                                */
/*                파라미터를 특정하지 않고, 유형(p_att_type)에 따라 필요시에 로직추가하도록 한다.*/
/*                사용법                                                                         */
/*                  SELECT *                                                                     */
/*                  FROM   TABLE(CAST(lgvatt_common_pkg.get_appr_line('LGDVN', 'VH000781', 'TA_CODE', 'DB') AS lgvatt_appr_line_tbl)) */
/*                  ORDER BY approver_seq_no                                                     */
/*                                                                                               */
/*                p_att_type = TA_CODE  : 근태코드에 따른 결재선                                 */
/*                p_attr1    = 근태코드 : 사용자가 선택한 근태코드                               */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_att_type                        in    varchar2  근태유형                     */
/*                p_attr1                           in    varchar2  파라미터1                    */
/*                p_attr2                           in    varchar2  파라미터2                    */
/*                p_attr3                           in    varchar2  파라미터3                    */
/*                p_attr4                           in    varchar2  파라미터4                    */
/*                p_attr5                           in    varchar2  파라미터5                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_appr_line (p_subsidiary_code IN VARCHAR2
                       ,p_employee_no     IN VARCHAR2
                       ,p_att_type        IN VARCHAR2
                       ,p_attr1           IN VARCHAR2 DEFAULT NULL
                       ,p_attr2           IN VARCHAR2 DEFAULT NULL
                       ,p_attr3           IN VARCHAR2 DEFAULT NULL
                       ,p_attr4           IN VARCHAR2 DEFAULT NULL
                       ,p_attr5           IN VARCHAR2 DEFAULT NULL
                       )
RETURN lgvatt_appr_line_tbl
IS
    v_approver_position_code            VARCHAR2(30);
    v_return                            lgvatt_appr_line_tbl;
    v_approver_seq_no                   NUMBER := 0;
    
    em_rec                              emp_master%ROWTYPE;
BEGIN

    v_return := lgvatt_appr_line_tbl();

    -- 근태코드에 따른 결재선 조회
    IF (p_att_type = 'TA_CODE') THEN
    
        -- 대상자정보
        SELECT * INTO em_rec FROM emp_master WHERE employee_number  = p_employee_no;
        
        -- 결재단계코드에 해당하는 직책코드
        v_approver_position_code := lgvhr_common_pkg.decode_lookup_name('LGVHR_POSITION_CODE', lgvhr_common_pkg.decode_lookup('LGVHR_ATT_APPROVAL_POSITION', 'LT'));  --v_approval_step_name)); -- 재량권 웹서비스 예정이므로 임시처리만

        v_approver_seq_no := 0;
        -- 상위자 조회
        FOR apr IN (SELECT em.seq                                                                      AS approver_seq
                          ,sv.employee_number                                                       AS approver_employee_no
                          ,sv.full_name_local                                                       AS approver_name
                          ,lgvhr_common_pkg.decode_lookup('IF_VIETNAM_GRADE_TITLE', sv.grade_title) AS approver_title_name
                          ,sv.organization_id                                                       AS approver_organization_code
                          ,sv.org_name_local                                                        AS approver_organization_name
                          ,sv.position                                                              AS approver_position_code
                          ,lgvhr_common_pkg.decode_lookup('IF_POSITION', sv.position)               AS approver_position_name  /* 직책명 */
                          ,lgvhr_common_pkg.get_application_user_id_func(sv.subsidiary_code, sv.employee_number) AS approver_user_id
                          ,(SELECT org_type FROM org_master WHERE organization_id = em.organization_id)          AS approver_organization_type
                    FROM   (
                            SELECT ROWNUM          AS seq
                                  ,employee_number AS employee_number
                                  ,supervisor      AS supervisor
                                  ,organization_id AS organization_id
                            FROM   emp_master
                            START WITH subsidiary_code  = p_subsidiary_code
                            AND        employee_number  = p_employee_no
                            CONNECT BY subsidiary_code  = p_subsidiary_code
                            AND        PRIOR supervisor = employee_number
                           ) em,
                           emp_master sv
                    WHERE  em.employee_number = sv.employee_number
                    AND    NVL(sv.date_retire, TRUNC(SYSDATE+1)) > TRUNC(SYSDATE)
                    AND    sv.position  IS NOT NULL
                    AND    sv.position  >= '300'  -- Leader of Team
                    ORDER BY em.seq
                   )
        LOOP
            -- Org Type
               -- 300    Team    350    Section    400    Task
               -- 500    Part    600    Shift      650    Unit
            
            -- Position
               -- 300    Leader of Team         370    Leader of Section
               -- 500    Leader of Part         520    Leader of Part (Probation)
               -- 650    Supervisor of Unit     660    Supervisor of Unit (Probation)
        
            IF (apr.approver_organization_type = '500' AND em_rec.position IN ( '500', '520' )  -- Part / Leader of Part, Leader of Part (Probation)
                OR
                apr.approver_organization_type = '650' AND em_rec.position IN ( '650', '660' )  -- Unit / Supervisor of Unit, Supervisor of Unit (Probation)
               )
            THEN  
                GOTO skip;
            END IF;
            
            v_approver_seq_no := v_approver_seq_no + 1;

            v_return.EXTEND;
            v_return(v_approver_seq_no) := lgvatt_appr_line_rec (approver_seq_no            => v_approver_seq_no              -- 승인자순서
                                                                ,approver_user_id           => apr.approver_user_id           -- 승인자아이디
                                                                ,approver_employee_no       => apr.approver_employee_no       -- 승인자사번
                                                                ,approver_name              => apr.approver_name              -- 승인자성명
                                                                ,approver_title_name        => apr.approver_title_name        -- 승인자직급
                                                                ,approver_position_name     => apr.approver_position_name     -- 승인자직책
                                                                ,approver_organization_code => apr.approver_organization_code -- 승인자조직코드
                                                                ,approver_organization_name => apr.approver_organization_name -- 승인자조직
                                                                ,approver_type_name         => '1'                            -- 승인자유형 : 추후 재량권 가능할때 유형 추가할 것
                                                                ,delegate_flag              => 'N'                            -- 위임여부 : 추후 위임정보 I/F 가능할때 추가할것
                                                                ,mandator_employee_no       => ''                             -- 위임자사번
                                                                ,mandator_name              => ''                             -- 위임자성명
                                                                ,mandator_title_name        => ''                             -- 위임자직급
                                                                ,mandator_position_name     => ''                             -- 위임자직책
                                                                ,mandator_organization_code => ''                             -- 위임자조직코드
                                                                ,mandator_organization_name => ''                             -- 위임자조직
                                                                );

            IF (apr.approver_position_code <= v_approver_position_code OR v_approver_seq_no >= 2) THEN
                EXIT;
            END IF;
            
            <<skip>>

            IF (apr.approver_organization_type <= '300') THEN  EXIT;  END IF;  -- Team
            IF (apr.approver_organization_type  = '350') THEN  EXIT;  END IF;  -- Section
            
            -- Leader of Part : S/L 또는 T/L 이 Final
            IF (em_rec.position = '500' AND apr.approver_position_code IN ( '370', '300' )) THEN  EXIT;  END IF;

        END LOOP;
    END IF;

    RETURN v_return;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_appr_line;



/*************************************************************************************************/
/* Program Name : get_input_days                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 계획/실적에 따라서 근태일자에 해당하는 입력가능한 일자를 조회하여 return 한다  */
/*                파라미터를 특정하지 않고, 필요시에 로직추가하도록 한다.                        */
/*                사용법                                                                         */
/*                  SELECT *                                                                     */
/*                  FROM   TABLE(CAST(lgvatt_common_pkg.get_input_date('LGDVN', TO_DATE('20171006', 'YYYYMMDD'), 'PLAN') AS lgvatt_input_date_tbl)) */
/*                  ORDER BY date_seq_no                                                         */
/*                                                                                               */
/*                p_plan_result_type = PLAN(계획), RESULT(실적)                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_plan_result_type                in    varchar2  계획/실적유형(PLAN/RESULT)   */
/*                p_today                           in    date      오늘일자                     */
/*                p_attr1                           in    varchar2  파라미터1                    */
/*                p_attr2                           in    varchar2  파라미터2                    */
/*                p_attr3                           in    varchar2  파라미터3                    */
/*                p_attr4                           in    varchar2  파라미터4                    */
/*                p_attr5                           in    varchar2  파라미터5                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_input_date (p_subsidiary_code              IN VARCHAR2
                        ,p_time_and_attendance_date     IN DATE
                        ,p_plan_result_type             IN VARCHAR2
                        ,p_today                        IN DATE     DEFAULT NULL
                        ,p_attr1                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr2                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr3                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr4                        IN VARCHAR2 DEFAULT NULL
                        ,p_attr5                        IN VARCHAR2 DEFAULT NULL
                        ,p_recursive_flag               IN VARCHAR2 DEFAULT 'N'
                        )
RETURN lgvatt_input_date_tbl
IS
    v_today_holiday_flag                tb_att_calendar_n.holiday_flag%TYPE;

    v_inquery_enable_flag               VARCHAR2(1);
    v_input_enable_flag                 VARCHAR2(1);
    v_approval_enable_flag              VARCHAR2(1);
    
    v_approval_close_limit_flag         VARCHAR2(10);

    v_return                            lgvatt_input_date_tbl;
    v_date_seq_no                       NUMBER := 0;

    v_day_count                         NUMBER := 0;
    v_inc_dec_val                       NUMBER := 0;
    v_start_seq_no                      NUMBER := 0;

    v_today                             DATE;

    v_valid_count                       NUMBER;
    v_valid_flag                        VARCHAR2(1);
    v_valid_tbl                         lgvatt_input_date_tbl;
BEGIN

    -- 결재마감시간 제한 여부
    v_approval_close_limit_flag := NVL(lgvhr_common_pkg.decode_lookup ('LGVHR_ATT_COMMON_CODE', 'CLOSE_TIME_LIMIT_APPROVAL_FLAG', 'A1'), 'Y');

    -- 테스트 또는 향후 계획 입력 확장을 위하여, 오늘을 변경가능
    v_today := TRUNC(NVL(p_today, SYSDATE));

    v_valid_flag := 'N';
    IF (NVL(p_recursive_flag, 'N') = 'N' AND p_time_and_attendance_date != v_today) THEN
        v_valid_tbl := get_input_date(p_subsidiary_code, v_today, p_plan_result_type, v_today, NULL, NULL, NULL, NULL, NULL, 'Y');
        v_valid_flag := 'Y';
    END IF;


    -- 휴일여부
    SELECT NVL(holiday_flag, 'N')
    INTO   v_today_holiday_flag
    FROM   tb_att_calendar_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = v_today      -- 오늘
    ;


    -- 전체 건수 미리 체크
    SELECT COUNT(*)
    INTO   v_day_count
    FROM   (
            SELECT *
            FROM   tb_att_calendar_n
            START WITH subsidiary_code                    = p_subsidiary_code
            AND        time_and_attendance_date           = p_time_and_attendance_date-1
            AND        p_plan_result_type                 = 'RESULT'
            CONNECT BY subsidiary_code                    = p_subsidiary_code
            AND        PRIOR (time_and_attendance_date-1) = time_and_attendance_date
            AND        PRIOR holiday_flag                 = 'Y'
            UNION ALL
            SELECT *
            FROM   tb_att_calendar_n
            START WITH subsidiary_code                    = p_subsidiary_code
            AND        time_and_attendance_date           = p_time_and_attendance_date
            AND        p_plan_result_type                 = 'PLAN'
            CONNECT BY subsidiary_code                    = p_subsidiary_code
            AND        holiday_flag                       = 'Y'
            AND        PRIOR (time_and_attendance_date+1) = time_and_attendance_date
           )
    ;


    v_inquery_enable_flag  := 'Y';
    v_input_enable_flag    := 'Y';
    v_approval_enable_flag := 'Y';

    v_start_seq_no := CASE WHEN p_plan_result_type = 'RESULT' THEN (v_day_count+1) ELSE 0 END;
    v_inc_dec_val  := CASE WHEN p_plan_result_type = 'RESULT' THEN -1 ELSE 1 END;

    v_date_seq_no  := v_start_seq_no;
    v_return := lgvatt_input_date_tbl();

    -- 날짜 갯수만큼 미리 생성
    FOR i IN 1..v_day_count
    LOOP
        v_return.EXTEND;
    END LOOP;


    FOR att IN (
                SELECT *
                FROM   (
                        SELECT *
                        FROM   tb_att_calendar_n
                        START WITH subsidiary_code                    = p_subsidiary_code
                        AND        time_and_attendance_date           = p_time_and_attendance_date-1
                        AND        p_plan_result_type                 = 'RESULT'
                        CONNECT BY subsidiary_code                    = p_subsidiary_code
                        AND        PRIOR (time_and_attendance_date-1) = time_and_attendance_date
                        AND        PRIOR holiday_flag                 = 'Y'
                        ORDER BY time_and_attendance_date DESC
                       )
                UNION ALL
                SELECT *
                FROM   (
                        SELECT *
                        FROM   tb_att_calendar_n
                        START WITH subsidiary_code                    = p_subsidiary_code
                        AND        time_and_attendance_date           = p_time_and_attendance_date
                        AND        p_plan_result_type                 = 'PLAN'
                        CONNECT BY subsidiary_code                    = p_subsidiary_code
                        AND        holiday_flag                       = 'Y'
                        AND        PRIOR (time_and_attendance_date+1) = time_and_attendance_date
                        ORDER BY time_and_attendance_date ASC
                       )
               )
    LOOP
        /******************************************************************
         * 요청자
           - 화요일 : 월요일 실적, 화요일 계획 입력가능, 그외는 조회만 가능
           - 수요일 : 화요일 실적, 수요일 계획 입력가능, 그외는 조회만 가능
           - 목요일 : 수요일 실적, 목요일 계획 입력가능, 그외는 조회만 가능
           - 금요일 : 목요일 실적, 금토일 계획 입력가능, 그외는 조회만 가능
           - 토요일 : 모든 날짜 조회만 가능(놀토일때)
           - 일요일 : 모든 날짜 조회만 가능
           - 월요일 : 금토일 실적, 월요일 계획 입력가능, 그외는 조회만 가능

         * 결재자
           - 화요일 : 월요일 실적, 화요일 계획 결재가능, 그외는 조회만 가능
           - 수요일 : 화요일 실적, 수요일 계획 결재가능, 그외는 조회만 가능
           - 목요일 : 수요일 실적, 목요일 계획 결재가능, 그외는 조회만 가능
           - 금요일 : 목요일 실적, 금토일 계획 결재가능, 그외는 조회만 가능
           - 토요일 : 모든 날짜 조회만 가능(놀토일때)
           - 일요일 : 모든 날짜 조회만 가능
           - 월요일 : 금토일 실적, 월요일 계획 결재가능, 그외는 조회만 가능
         *****************************************************************/

        -- 실적이면
        -- 요청자 : 오늘이 휴일이거나 첫번째가 오늘-1이 아니면, 전체 불가
        -- 승인자 : 오늘이 휴일이거나 첫번째가 오늘(포함) 이후이면, 전체 불가 : 이전의 결재안한 건들은 배치프로그램에서 미리 처리가 됨
        IF (p_plan_result_type = 'RESULT') THEN

            v_inquery_enable_flag := 'Y';    -- 조회여부

            -- 휴일이면
            IF (v_today_holiday_flag = 'Y') THEN
                v_input_enable_flag    := 'N';    -- 입력여부
                v_approval_enable_flag := 'N';    -- 결재여부
            END IF;

            -- 첫번째일때
            IF (v_date_seq_no = v_start_seq_no) THEN
                IF (att.time_and_attendance_date <> (v_today-1)) THEN
                    v_input_enable_flag := 'N';    -- 입력여부
                END IF;

                IF (att.time_and_attendance_date >= v_today) THEN
                    v_approval_enable_flag := 'N';    -- 결재여부
                END IF;
            END IF;
            
        -- 계획이면
        -- 요청자 : 오늘이 휴일이거나 첫번째가 오늘이 아니면, 전체 불가
        -- 승인자 : 오늘이 휴일이거나 첫번째가 오늘(제외) 이전이면, 전체 불가
        ELSE

            v_inquery_enable_flag := 'Y';    -- 조회여부

            -- 휴일이면
            IF (v_today_holiday_flag = 'Y') THEN
                v_input_enable_flag    := 'N';    -- 입력여부
                v_approval_enable_flag := 'N';    -- 결재여부
            END IF;

            -- 첫번째일때
            IF (v_date_seq_no = v_start_seq_no) THEN
                IF (att.time_and_attendance_date <> v_today) THEN
                    v_input_enable_flag := 'N';    -- 입력여부
                END IF;

                IF (att.time_and_attendance_date < v_today) THEN
                    v_approval_enable_flag := 'N';    -- 결재여부
                END IF;
            END IF;

        END IF;

        -- 미래일자일때, 결재가능여부 한번 더 체크
        IF (v_approval_enable_flag = 'Y' AND v_valid_flag = 'Y') THEN
            v_valid_count := 0;
            v_valid_flag  := 'N';

            FOR dd IN v_valid_tbl.FIRST..v_valid_tbl.LAST
            LOOP
                v_valid_count := v_valid_count + 1;
                IF (att.time_and_attendance_date = v_valid_tbl(dd).time_and_attendance_date) THEN
                    v_valid_flag := 'Y';
                END IF;
            END LOOP;

            IF (v_valid_count > 0 AND v_valid_flag = 'N') THEN
                v_approval_enable_flag := 'N';
            END IF;
        END IF;

        -- 결재마감제한 없으면
        IF (p_plan_result_type = 'RESULT' AND att.time_and_attendance_date < v_today AND v_approval_close_limit_flag = 'N') THEN
            v_approval_enable_flag := 'Y';
        END IF;            


        v_date_seq_no := v_date_seq_no + v_inc_dec_val;
        v_return(v_date_seq_no) := lgvatt_input_date_rec (date_seq_no                  => v_date_seq_no                                      -- 날짜일련순서번호
                                                         ,time_and_attendance_yyyymmdd => TO_CHAR(att.time_and_attendance_date, 'YYYYMMDD')  -- 근태일자(YYYYMMDD)
                                                         ,a_day_of_the_week_code       => att.a_day_of_the_week_code                         -- 요일코드
                                                         ,holiday_flag                 => NVL(att.holiday_flag, 'N')                         -- 휴일여부
                                                         ,time_and_attendance_yyyymm   => att.time_and_attendance_yyyymm                     -- 근태년월
                                                         ,time_and_attendance_date     => att.time_and_attendance_date                       -- 근태일자(Date)
                                                         ,inquery_enable_flag          => v_inquery_enable_flag                              -- 조회가능여부
                                                         ,input_enable_flag            => v_input_enable_flag                                -- 입력가능여부
                                                         ,approval_enable_flag         => v_approval_enable_flag                             -- 결재가능여부
                                                         );
    END LOOP;

    RETURN v_return;

EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line(SQLERRM);
    RETURN NULL;

END get_input_date;

/*************************************************************************************************/
/* Program Name : get_input_days                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 계획/실적에 따라서 근태일자에 해당하는 입력가능한 일자를 조회하여 return 한다  */
/*                파라미터를 특정하지 않고, 필요시에 로직추가하도록 한다.                        */
/*                사용법                                                                         */
/*                  SELECT *                                                                     */
/*                  FROM   TABLE(CAST(lgvatt_common_pkg.get_input_date('LGDVN', TO_DATE('20171006', 'YYYYMMDD'), 'PLAN') AS lgvatt_input_date_tbl)) */
/*                  ORDER BY date_seq_no                                                         */
/*                                                                                               */
/*                p_plan_result_type = PLAN(계획), RESULT(실적)                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_shift_type_code                 in    varchar2  부제코드                     */
/*                p_plan_result_type                in    varchar2  계획/실적유형(PLAN/RESULT)   */
/*                p_today                           in    date      오늘일자                     */
/*                p_attr1                           in    varchar2  파라미터1                    */
/*                p_attr2                           in    varchar2  파라미터2                    */
/*                p_attr3                           in    varchar2  파라미터3                    */
/*                p_attr4                           in    varchar2  파라미터4                    */
/*                p_attr5                           in    varchar2  파라미터5                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/11/08  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_input_date_lw (p_subsidiary_code              IN VARCHAR2
                           ,p_time_and_attendance_date     IN DATE
                           ,p_shift_type_code              IN VARCHAR2
                           ,p_plan_result_type             IN VARCHAR2
                           ,p_today                        IN DATE     DEFAULT NULL
                           ,p_attr1                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr2                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr3                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr4                        IN VARCHAR2 DEFAULT NULL
                           ,p_attr5                        IN VARCHAR2 DEFAULT NULL
                           ,p_recursive_flag               IN VARCHAR2 DEFAULT 'N'
                           )
RETURN lgvatt_input_date_tbl
IS
    v_today_holiday_flag                tb_att_calendar_n.holiday_flag%TYPE;

    v_inquery_enable_flag               VARCHAR2(1);
    v_input_enable_flag                 VARCHAR2(1);
    v_approval_enable_flag              VARCHAR2(1);
    
    v_approval_close_limit_flag         VARCHAR2(10);

    v_return                            lgvatt_input_date_tbl;
    v_date_seq_no                       NUMBER := 0;

    v_day_count                         NUMBER := 0;
    v_inc_dec_val                       NUMBER := 0;
    v_start_seq_no                      NUMBER := 0;

    v_today                             DATE;

    v_valid_count                       NUMBER;
    v_valid_flag                        VARCHAR2(1);
    v_valid_tbl                         lgvatt_input_date_tbl;
BEGIN

    -- 결재마감시간 제한 여부
    v_approval_close_limit_flag := NVL(lgvhr_common_pkg.decode_lookup ('LGVHR_ATT_COMMON_CODE', 'CLOSE_TIME_LIMIT_APPROVAL_FLAG', 'A1'), 'Y');

    -- 테스트 또는 향후 계획 입력 확장을 위하여, 오늘을 변경가능
    v_today := TRUNC(NVL(p_today, SYSDATE));

    v_valid_flag := 'N';
    IF (NVL(p_recursive_flag, 'N') = 'N' AND p_time_and_attendance_date != v_today) THEN
        v_valid_tbl := get_input_date(p_subsidiary_code, v_today, p_plan_result_type, v_today, NULL, NULL, NULL, NULL, NULL, 'Y');
        v_valid_flag := 'Y';
    END IF;


    -- 휴일여부
    SELECT DECODE(time_and_attendance_code, 'NW', 'N', 'Y')
    INTO   v_today_holiday_flag
    FROM   tb_att_base_bas_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = v_today      -- 오늘
    AND    shift_type_code          = p_shift_type_code
    ;


    -- 전체 건수 미리 체크
    SELECT COUNT(*)
    INTO   v_day_count
    FROM   (
            SELECT *
            FROM   tb_att_base_bas_n
            START WITH subsidiary_code                    = p_subsidiary_code
            AND        time_and_attendance_date           = p_time_and_attendance_date-1
            AND        p_plan_result_type                 = 'RESULT'
            AND        shift_type_code                    = p_shift_type_code
            CONNECT BY subsidiary_code                    = p_subsidiary_code
            AND        PRIOR (time_and_attendance_date-1) = time_and_attendance_date
            AND        PRIOR DECODE(time_and_attendance_code, 'NW', 'N', 'Y') = 'Y'
            AND        shift_type_code                    = p_shift_type_code
            UNION ALL
            SELECT *
            FROM   tb_att_base_bas_n
            START WITH subsidiary_code                    = p_subsidiary_code
            AND        time_and_attendance_date           = p_time_and_attendance_date
            AND        p_plan_result_type                 = 'PLAN'
            AND        shift_type_code                    = p_shift_type_code
            CONNECT BY subsidiary_code                    = p_subsidiary_code
            AND        PRIOR (time_and_attendance_date+1) = time_and_attendance_date
            AND        DECODE(time_and_attendance_code, 'NW', 'N', 'Y') = 'Y'
            AND        shift_type_code                    = p_shift_type_code
           )
    ;


    v_inquery_enable_flag  := 'Y';
    v_input_enable_flag    := 'Y';
    v_approval_enable_flag := 'Y';

    v_start_seq_no := CASE WHEN p_plan_result_type = 'RESULT' THEN (v_day_count+1) ELSE 0 END;
    v_inc_dec_val  := CASE WHEN p_plan_result_type = 'RESULT' THEN -1 ELSE 1 END;

    v_date_seq_no  := v_start_seq_no;
    v_return := lgvatt_input_date_tbl();

    -- 날짜 갯수만큼 미리 생성
    FOR i IN 1..v_day_count
    LOOP
        v_return.EXTEND;
    END LOOP;


    FOR att IN (
                SELECT *
                FROM   (
                        SELECT t.*, DECODE(time_and_attendance_code, 'NW', 'N', 'Y') AS holiday_flag
                        FROM   tb_att_base_bas_n t
                        START WITH subsidiary_code                    = p_subsidiary_code
                        AND        time_and_attendance_date           = p_time_and_attendance_date-1
                        AND        p_plan_result_type                 = 'RESULT'
                        AND        shift_type_code                    = p_shift_type_code
                        CONNECT BY subsidiary_code                    = p_subsidiary_code
                        AND        PRIOR (time_and_attendance_date-1) = time_and_attendance_date
                        AND        PRIOR DECODE(time_and_attendance_code, 'NW', 'N', 'Y') = 'Y'
                        AND        shift_type_code                    = p_shift_type_code
                        ORDER BY time_and_attendance_date DESC
                       )
                UNION ALL
                SELECT *
                FROM   (
                        SELECT t.*, DECODE(time_and_attendance_code, 'NW', 'N', 'Y') AS holiday_flag
                        FROM   tb_att_base_bas_n t
                        START WITH subsidiary_code                    = p_subsidiary_code
                        AND        time_and_attendance_date           = p_time_and_attendance_date
                        AND        p_plan_result_type                 = 'PLAN'
                        AND        shift_type_code                    = p_shift_type_code
                        CONNECT BY subsidiary_code                    = p_subsidiary_code
                        AND        PRIOR (time_and_attendance_date+1) = time_and_attendance_date
                        AND        DECODE(time_and_attendance_code, 'NW', 'N', 'Y') = 'Y'
                        AND        shift_type_code                    = p_shift_type_code
                        ORDER BY time_and_attendance_date ASC
                       )
               )
    LOOP
        /******************************************************************
         * 요청자
           - 화요일 : 월요일 실적, 화요일 계획 입력가능, 그외는 조회만 가능
           - 수요일 : 화요일 실적, 수요일 계획 입력가능, 그외는 조회만 가능
           - 목요일 : 수요일 실적, 목요일 계획 입력가능, 그외는 조회만 가능
           - 금요일 : 목요일 실적, 금토일 계획 입력가능, 그외는 조회만 가능
           - 토요일 : 모든 날짜 조회만 가능(놀토일때)
           - 일요일 : 모든 날짜 조회만 가능
           - 월요일 : 금토일 실적, 월요일 계획 입력가능, 그외는 조회만 가능

         * 결재자
           - 화요일 : 월요일 실적, 화요일 계획 결재가능, 그외는 조회만 가능
           - 수요일 : 화요일 실적, 수요일 계획 결재가능, 그외는 조회만 가능
           - 목요일 : 수요일 실적, 목요일 계획 결재가능, 그외는 조회만 가능
           - 금요일 : 목요일 실적, 금토일 계획 결재가능, 그외는 조회만 가능
           - 토요일 : 모든 날짜 조회만 가능(놀토일때)
           - 일요일 : 모든 날짜 조회만 가능
           - 월요일 : 금토일 실적, 월요일 계획 결재가능, 그외는 조회만 가능
         *****************************************************************/

        -- 실적이면
        -- 요청자 : 오늘이 휴일이거나 첫번째가 오늘-1이 아니면, 전체 불가
        -- 승인자 : 오늘이 휴일이거나 첫번째가 오늘(포함) 이후이면, 전체 불가 : 이전의 결재안한 건들은 배치프로그램에서 미리 처리가 됨
        IF (p_plan_result_type = 'RESULT') THEN

            v_inquery_enable_flag := 'Y';    -- 조회여부

            -- 휴일이면
            IF (v_today_holiday_flag = 'Y') THEN
                v_input_enable_flag    := 'N';    -- 입력여부
                v_approval_enable_flag := 'N';    -- 결재여부
            END IF;

            -- 첫번째일때
            IF (v_date_seq_no = v_start_seq_no) THEN
                IF (att.time_and_attendance_date <> (v_today-1)) THEN
                    v_input_enable_flag := 'N';    -- 입력여부
                END IF;

                IF (att.time_and_attendance_date >= v_today) THEN
                    v_approval_enable_flag := 'N';    -- 결재여부
                END IF;
            END IF;
            
        -- 계획이면
        -- 요청자 : 오늘이 휴일이거나 첫번째가 오늘이 아니면, 전체 불가
        -- 승인자 : 오늘이 휴일이거나 첫번째가 오늘(제외) 이전이면, 전체 불가
        ELSE

            v_inquery_enable_flag := 'Y';    -- 조회여부

            -- 휴일이면
            IF (v_today_holiday_flag = 'Y') THEN
                v_input_enable_flag    := 'N';    -- 입력여부
                v_approval_enable_flag := 'N';    -- 결재여부
            END IF;

            -- 첫번째일때
            IF (v_date_seq_no = v_start_seq_no) THEN
                IF (att.time_and_attendance_date <> v_today) THEN
                    v_input_enable_flag := 'N';    -- 입력여부
                END IF;

                IF (att.time_and_attendance_date < v_today) THEN
                    v_approval_enable_flag := 'N';    -- 결재여부
                END IF;
            END IF;

        END IF;

        -- 미래일자일때, 결재가능여부 한번 더 체크
        IF (v_approval_enable_flag = 'Y' AND v_valid_flag = 'Y') THEN
            v_valid_count := 0;
            v_valid_flag  := 'N';

            FOR dd IN v_valid_tbl.FIRST..v_valid_tbl.LAST
            LOOP
                v_valid_count := v_valid_count + 1;
                IF (att.time_and_attendance_date = v_valid_tbl(dd).time_and_attendance_date) THEN
                    v_valid_flag := 'Y';
                END IF;
            END LOOP;

            IF (v_valid_count > 0 AND v_valid_flag = 'N') THEN
                v_approval_enable_flag := 'N';
            END IF;
        END IF;

        -- 결재마감제한 없으면
        IF (p_plan_result_type = 'RESULT' AND att.time_and_attendance_date < v_today AND v_approval_close_limit_flag = 'N') THEN
            v_approval_enable_flag := 'Y';
        END IF;            


        v_date_seq_no := v_date_seq_no + v_inc_dec_val;
        v_return(v_date_seq_no) := lgvatt_input_date_rec (date_seq_no                  => v_date_seq_no                                      -- 날짜일련순서번호
                                                         ,time_and_attendance_yyyymmdd => TO_CHAR(att.time_and_attendance_date, 'YYYYMMDD')  -- 근태일자(YYYYMMDD)
                                                         ,a_day_of_the_week_code       => att.a_day_of_the_week_code                         -- 요일코드
                                                         ,holiday_flag                 => NVL(att.holiday_flag, 'N')                         -- 휴일여부
                                                         ,time_and_attendance_yyyymm   => att.time_and_attendance_yyyymm                     -- 근태년월
                                                         ,time_and_attendance_date     => att.time_and_attendance_date                       -- 근태일자(Date)
                                                         ,inquery_enable_flag          => v_inquery_enable_flag                              -- 조회가능여부
                                                         ,input_enable_flag            => v_input_enable_flag                                -- 입력가능여부
                                                         ,approval_enable_flag         => v_approval_enable_flag                             -- 결재가능여부
                                                         );
    END LOOP;

    RETURN v_return;

EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line(SQLERRM);
    RETURN NULL;

END get_input_date_lw;

/*************************************************************************************************/
/* Program Name : get_weekday_info                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 일자의 정보를 Return한다.                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_week_code                       out   varchar2  요일코드(MON,TUE,...)        */
/*                p_time_and_attendance_code        out   varchar2  근태코드                     */
/*                p_holiday_code                    out   varchar2  휴일코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/02  한승용B     Initial Release                                                       */
/*                                                                                               */
/* 2017/10/25  박귀희B     패키지 변경                                                           */
/*                         lgvatt_ot_calculation_pkg -> lgvatt_transaction_pkg                   */
/* 2021/03/15  HMT_20210315         All saturday off                                                                                           */
/*************************************************************************************************/
PROCEDURE get_weekday_info (p_subsidiary_code              IN  VARCHAR2,
                            p_time_and_attendance_date     IN  DATE,
                            p_week_code                    OUT VARCHAR2,
                            p_time_and_attendance_code     OUT VARCHAR2,
                            p_holiday_code                 OUT VARCHAR2
                           )
IS

    CURSOR C1_saturday_holiday
    IS
    SELECT 1 AS flag
    FROM   dual
    WHERE  TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'D')) = 7
    --AND    TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'W')) IN ( 1, 3, 5 ) --HMT_20210315 delete
    ;


    CURSOR C2_select_holiday_table
    IS
    SELECT time_and_attendance_code, holiday_code
    FROM   tb_att_holiday_info_n
    WHERE  subsidiary_code = p_subsidiary_code
    AND    holiday_date    = p_time_and_attendance_date
    ;

    v_week_num NUMBER;

BEGIN

    v_week_num := TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'D'));

    p_time_and_attendance_code     := 'NW';    -- Normal Work
    p_holiday_code                 := '';

    IF v_week_num = 1 THEN
        p_time_and_attendance_code := 'WH';    -- Weekly Holiday (1/3주토요일, 일요일 모두 WH)
        p_week_code    := 'SUN';
    ELSIF v_week_num = 2 THEN
        p_week_code    := 'MON';
    ELSIF v_week_num = 3 THEN
        p_week_code    := 'TUE';
    ELSIF v_week_num = 4 THEN
        p_week_code    := 'WED';
    ELSIF v_week_num = 5 THEN
        p_week_code    := 'THU';
    ELSIF v_week_num = 6 THEN
        p_week_code    := 'FRI';
    ELSIF v_week_num = 7 THEN
        p_week_code    := 'SAT';
    ELSE
        p_time_and_attendance_code := 'ER';
        p_week_code    := 'ERR';
    END IF;

    FOR r1 IN C1_saturday_holiday
    LOOP
        p_time_and_attendance_code := 'WH';    -- Weekly Holiday
        --< Start HMT_20210315 : All saturday off
         IF p_time_and_attendance_date < TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD')
          AND TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'W')) IN ( 2, 4) THEN
              p_time_and_attendance_code := 'NW';
          END IF;
        --< End
    END LOOP;

    FOR r2 IN C2_select_holiday_table
    LOOP
        p_time_and_attendance_code := r2.time_and_attendance_code;
        p_holiday_code             := r2.holiday_code;
    END LOOP;

END get_weekday_info;


/*************************************************************************************************/
/* Program Name : get_attendance_time_by_att                                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 일자 및 교대조에 해당하는 출근시간을 Return한다.                               */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_shift_type_code                 in    varchar2  교대유형코드                 */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_attendance_time_by_att (p_subsidiary_code          IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_shift_type_code          IN  VARCHAR2
                                    )
RETURN VARCHAR2
IS
    v_attendance_time      tb_att_base_bas_n.attendance_time%TYPE;

BEGIN

    SELECT attendance_time
    INTO   v_attendance_time
    FROM   tb_att_base_bas_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    AND    shift_type_code          = p_shift_type_code
    ;

    RETURN v_attendance_time;

END get_attendance_time_by_att;



/*************************************************************************************************/
/* Program Name : get_attendance_time_by_shift                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 주야 및 교대조에 해당하는 출근시간을 Return한다.                               */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_night_shift_flag                in    varchar2  주야구분(Y:야, N:주)         */
/*                                                                  3교대추가시 해당코드 추가    */
/*                p_shift_type_code                 in    varchar2  교대유형코드                 */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_attendance_time_by_shift (p_subsidiary_code              IN  VARCHAR2
                                      ,p_shift_type_code              IN  VARCHAR2
                                      ,p_night_shift_flag             IN  VARCHAR2
                                      )
RETURN VARCHAR2
IS
    v_attendance_time      tb_att_base_bas_n.attendance_time%TYPE;

BEGIN

    SELECT CASE WHEN p_night_shift_flag = 'Y' THEN code_data5_value  -- 야간 출근시간
                WHEN p_night_shift_flag = 'N' THEN code_data4_value  -- 주간 출근시간
                ELSE                               code_data4_value
           END
    INTO   v_attendance_time
    FROM   lgcom_common_code_c
    WHERE  code_type_code              = 'LGVHR_SHIFT_TYPE_CODE'
    AND    common_code                 = p_shift_type_code
    ;

    RETURN v_attendance_time;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_attendance_time_by_shift;



/*************************************************************************************************/
/* Program Name : get_att_result_monthly                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태년월에 해당하는 월별 Summary 를 return 한다                     */
/*                사용법                                                                         */
/*                  SELECT employee_no                                                           */
/*                        ,time_and_attendance_yyyymm                                            */
/*                        ,working_time_hours                                                    */
/*                        ,night_hours                                                           */
/*                        ,overtime_hours                                                        */
/*                        ,night_overtime_hours                                                  */
/*                        ,paid_vacation_days                                                    */
/*                        ,absence_days                                                          */
/*                        ,tardy_hours                                                           */
/*                        ,going_out_hours                                                       */
/*                        ,early_leave_hours                                                     */
/*                        ,unpaid_vacation_days                                                  */
/*                        ,absence_leave_days                                                    */
/*                  FROM   TABLE(CAST(lgvatt_common_pkg.get_att_result_monthly('LGDVN', 'VH000781', '201710') AS lgvatt_result_monthly_tbl)) */
/*                                                                                               */
/*                p_group_type = GROUP : 기간별 조회일때, 각 근태년월별 Summary                  */
/*                               SUM   : 기간별 조회일때, 근태년월 전체 합계 Summary             */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_from_time_attendance_yyyymm     in    varchar2  시작근태년월(YYYYMM)         */
/*                p_to_time_attendance_yyyymm       in    varchar2  종료근태년월(YYYYMM)         */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/02/05  박귀희B     근태유형코드 -> 근태코드로 구분 방법 변경                             */
/* 2018/03/02  손수양      베트남 급여근태 고도화
/*                         반일휴가  HL 추가                                                     */
/*************************************************************************************************/
FUNCTION get_att_result_monthly (p_subsidiary_code             IN VARCHAR2
                                ,p_employee_no                 IN VARCHAR2
                                ,p_from_time_attendance_yyyymm IN VARCHAR2
                                ,p_to_time_attendance_yyyymm   IN VARCHAR2 DEFAULT NULL
                                ,p_group_type                  IN VARCHAR2 DEFAULT 'GROUP'
                                ,p_attr1                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr2                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr3                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr4                       IN VARCHAR2 DEFAULT NULL
                                ,p_attr5                       IN VARCHAR2 DEFAULT NULL
                                )
RETURN lgvatt_result_monthly_tbl
IS
    v_monthly_seq_no                    NUMBER;
    v_return                            lgvatt_result_monthly_tbl;


BEGIN

    v_return := lgvatt_result_monthly_tbl();

    v_monthly_seq_no := 0;
    FOR mon IN (
                SELECT cl.perfect_attendance_days
                      ,ar.*
                FROM   (-- 2018.02.05 박귀희 : type_code -> code 변경 (세분화되지 않아 변경함. 코드추가시 변경필요함)
                        SELECT ar.employee_no,
                               DECODE(NVL(p_attr1, 'GROUP'), 'SUM', p_from_time_attendance_yyyymm, ar.time_and_attendance_yyyymm)           AS time_and_attendance_yyyymm,
                               -- Paymenet
                               SUM(CASE WHEN ac.time_and_attendance_code IN ( 'NW', 'DB', 'OB' )  --ac.time_and_attendance_type_code IN ( 'WK', 'BT' )
                                        THEN NVL(ac.attendance_days, 0) * 8
                                        ELSE 0
                                   END)                                                                                                     AS working_time_hours,    -- Normal Time,
                               SUM(NVL(ar.normal_night_overtime_hours, 0))                                                                  AS night_hours,           -- Night Time,
                               SUM((NVL(ar.weekday_overtime_hours, 0)
                                   +NVL(ar.holiday_overtime_hours, 0)
                                   +NVL(ar.public_holiday_overtime_hours, 0)))                                                              AS overtime_hours,        -- Over Time,
                               SUM((NVL(ar.weekday_night_overtime_hours, 0)
                                   +NVL(ar.weekday_ot_af_night_work_hours, 0)
                                   +NVL(ar.holiday_night_overtime_hours, 0)
                                   +NVL(ar.public_holiday_night_ot_hours, 0)))                                                              AS night_overtime_hours,  -- Over Time at Night,
                               /* 2018/03/02 : 반일휴가 추가 */                                   
                               SUM(CASE WHEN ac.time_and_attendance_code IN ( 'AL', 'PF', 'PL', 'PM', 'UF', 'UL', 'UM' ,'HL', 'HL_FN', 'HL_SN')  --ac.time_and_attendance_type_code IN ( 'LV' )
                                        THEN NVL(ac.paid_days, 0)
                                        ELSE 0
                                   END)                                                                                                     AS paid_vacation_days,    -- Paid Leave

                               -- Deduction
                               SUM(CASE WHEN ac.time_and_attendance_code IN ( 'AB' )  --ac.time_and_attendance_type_code IN ( 'AS' )
                                        THEN NVL(ac.unpaid_days, 0)
                                        ELSE 0
                                   END)                                                                                                     AS absence_days,          -- Absence
                               SUM(NVL(ar.tardy_hours, 0))                                                                                  AS tardy_hours,           -- Lateness
                               SUM(NVL(ar.going_out_hours, 0))                                                                              AS going_out_hours,       -- Going-out
                               SUM(NVL(ar.early_leave_hours, 0))                                                                            AS early_leave_hours,     -- Leaving-early
                               /* 2018/03/02 : 반일휴가 추가 */
                               SUM(CASE WHEN ac.time_and_attendance_code IN ( 'AL', 'PF', 'PL', 'PM', 'UF', 'UL', 'UM','HL', 'HL_FN', 'HL_SN' )  --ac.time_and_attendance_type_code IN ( 'LV' )
                                        THEN NVL(ac.unpaid_days, 0)
                                        ELSE 0
                                   END)                                                                                                     AS unpaid_vacation_days,  -- Unpaid Leave
                               SUM(CASE WHEN ac.time_and_attendance_code IN ( 'PS', 'US' )  --ac.time_and_attendance_type_code IN ( 'SP' )
                                        THEN NVL(ac.unpaid_days, 0)
                                        ELSE 0
                                   END)                                                                                                     AS absence_leave_days,    -- Suspension

                               -- Days
                               SUM(ac.paid_days)                                                                                            AS paid_days,             -- Paid Days
                               SUM(ac.unpaid_days)                                                                                          AS unpaid_days,           -- Unpaid Days
                               SUM(ac.attendance_days)                                                                                      AS attendance_days        -- Attendance Days

                        FROM   tb_att_result_n ar,
                               tb_att_code_c   ac
                        WHERE  ar.subsidiary_code            = p_subsidiary_code
                        AND    ar.employee_no                = p_employee_no
                        AND    ar.time_and_attendance_yyyymm BETWEEN p_from_time_attendance_yyyymm AND NVL(p_to_time_attendance_yyyymm, p_from_time_attendance_yyyymm)
                        AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
                        AND    ar.subsidiary_code            = ac.subsidiary_code

                        GROUP BY ar.employee_no, DECODE(NVL(p_attr1, 'GROUP'), 'SUM', p_from_time_attendance_yyyymm, ar.time_and_attendance_yyyymm)
                       ) ar,
                       tb_att_close_n cl
                WHERE  ar.time_and_attendance_yyyymm = cl.time_and_attendance_yyyymm
                AND    cl.subsidiary_code            = p_subsidiary_code
               )
    LOOP
        v_monthly_seq_no := v_monthly_seq_no + 1;

        v_return.EXTEND;
        v_return(v_monthly_seq_no) := lgvatt_result_monthly_rec (employee_no                => mon.employee_no                -- 사원번호
                                                                ,time_and_attendance_yyyymm => mon.time_and_attendance_yyyymm -- 근태년월
                                                                ,working_time_hours         => mon.working_time_hours         -- Normal Time
                                                                ,night_hours                => mon.night_hours                -- Night Time
                                                                ,overtime_hours             => mon.overtime_hours             -- Over Time
                                                                ,night_overtime_hours       => mon.night_overtime_hours       -- Over Time at Night
                                                                ,paid_vacation_days         => mon.paid_vacation_days         -- Paid Leave
                                                                ,absence_days               => mon.absence_days               -- Absence
                                                                ,tardy_hours                => mon.tardy_hours                -- Lateness
                                                                ,going_out_hours            => mon.going_out_hours            -- Going-out
                                                                ,early_leave_hours          => mon.early_leave_hours          -- Leaving-early
                                                                ,unpaid_vacation_days       => mon.unpaid_vacation_days       -- Unpaid Leave
                                                                ,absence_leave_days         => mon.absence_leave_days         -- Suspension

                                                                ,perfect_attendance_days    => mon.perfect_attendance_days    -- Perfect Attendance Days (만근일수)
                                                                ,paid_days                  => mon.paid_days                  -- Paid Days (유급일수 : 휴가등)
                                                                ,unpaid_days                => mon.unpaid_days                -- Unpaid Days (무급일수 : 결근등)
                                                                ,attendance_days            => mon.attendance_days            -- Attendance Days (출근일수 : 출근, 출장등)
                                                                );
    END LOOP;

    RETURN v_return;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_result_monthly;



/*************************************************************************************************/
/* Program Name : get_att_code_rec                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태코드에 해당하는 근태코드 정보를 return 한다                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_code_rec (p_subsidiary_code          IN VARCHAR2
                          ,p_time_and_attendance_code IN VARCHAR2
                          )
RETURN tb_att_code_c%ROWTYPE
IS
    ac_rec                   tb_att_code_c%ROWTYPE;
BEGIN

    SELECT *
    INTO   ac_rec
    FROM   tb_att_code_c
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_code = p_time_and_attendance_code
    ;

    RETURN ac_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_code_rec;


/*************************************************************************************************/
/* Program Name : get_att_calendar_rec                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태일자에 해당하는 카렌다 정보를 return 한다                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_calendar_rec (p_subsidiary_code          IN VARCHAR2
                              ,p_time_and_attendance_date IN DATE
                              )
RETURN tb_att_calendar_n%ROWTYPE
IS
    ac_rec                   tb_att_calendar_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   ac_rec
    FROM   tb_att_calendar_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    ;

    RETURN ac_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_calendar_rec;


/*************************************************************************************************/
/* Program Name : get_att_close_rec                                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태년월에 해당하는 근태마감정보를 return 한다                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  근태년월                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_close_rec (p_subsidiary_code            IN VARCHAR2
                           ,p_time_and_attendance_yyyymm IN VARCHAR2
                           )
RETURN tb_att_close_n%ROWTYPE
IS
    ac_rec                   tb_att_close_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   ac_rec
    FROM   tb_att_close_n
    WHERE  subsidiary_code            = p_subsidiary_code
    AND    time_and_attendance_yyyymm = p_time_and_attendance_yyyymm
    ;

    RETURN ac_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_close_rec;


/*************************************************************************************************/
/* Program Name : get_att_base_bas_rec                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태일자, 부제유형코드에 해당하는 기초근태를 return 한다                       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_shift_type_code                 in    varchar2  교대유형코드                 */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_base_bas_rec (p_subsidiary_code          IN VARCHAR2
                              ,p_time_and_attendance_date IN DATE
                              ,p_shift_type_code          IN VARCHAR2
                              )
RETURN tb_att_base_bas_n%ROWTYPE
IS
    abb_rec                   tb_att_base_bas_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   abb_rec
    FROM   tb_att_base_bas_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    AND    shift_type_code          = p_shift_type_code
    ;

    RETURN abb_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_base_bas_rec;


/*************************************************************************************************/
/* Program Name : get_att_plan_rec                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태일자, 사원번호에 해당하는 계획근태를 return 한다                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_plan_rec (p_subsidiary_code          IN VARCHAR2
                          ,p_employee_no              IN  VARCHAR2
                          ,p_time_and_attendance_date IN  DATE
                          )
RETURN tb_att_plan_n%ROWTYPE
IS
    ap_rec                   tb_att_plan_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   ap_rec
    FROM   tb_att_plan_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    AND    employee_no              = p_employee_no
    ;

    RETURN ap_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_plan_rec;


/*************************************************************************************************/
/* Program Name : get_att_result_rec                                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태일자, 사원번호에 해당하는 실적근태를 return 한다                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_result_rec (p_subsidiary_code          IN VARCHAR2
                            ,p_employee_no              IN  VARCHAR2
                            ,p_time_and_attendance_date IN  DATE
                            )
RETURN tb_att_result_n%ROWTYPE
IS
    ar_rec                   tb_att_result_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   ar_rec
    FROM   tb_att_result_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    AND    employee_no              = p_employee_no
    ;

    RETURN ar_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_result_rec;


/*************************************************************************************************/
/* Program Name : get_att_update_req_rec                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 요청번호에 해당하는 수정요청서 정보를 return 한다                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_request_no                      in    varchar2  요청번호                     */
/*                p_request_seq_no                  in    number    요청일련번호                 */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_update_req_rec (p_request_no     IN VARCHAR2
                                ,p_request_seq_no IN NUMBER
                                )
RETURN tb_att_update_req_n%ROWTYPE
IS
    aur_rec                   tb_att_update_req_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   aur_rec
    FROM   tb_att_update_req_n
    WHERE  request_no     = p_request_no
    AND    request_seq_no = p_request_seq_no
    ;

    RETURN aur_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_update_req_rec;


/*************************************************************************************************/
/* Program Name : get_att_lt_ta_plan_rec                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 계획아이디에 해당하는 장기근태계획 정보를 return 한다                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                planning_id                       in    number    계획아이디                   */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_lt_ta_plan_rec (p_planning_id     IN NUMBER
                                ,p_subsidiary_code IN VARCHAR2
                                )
RETURN tb_att_lt_time_attend_plan_n%ROWTYPE
IS
    altp_rec                   tb_att_lt_time_attend_plan_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   altp_rec
    FROM   tb_att_lt_time_attend_plan_n
    WHERE  planning_id     = p_planning_id
    AND    subsidiary_code = p_subsidiary_code
    ;

    RETURN altp_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_lt_ta_plan_rec;


/*************************************************************************************************/
/* Program Name : get_att_annual_leave_rec                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태년월에 해당하는 연차휴가 정보를 return 한다                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  근태년월                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_annual_leave_rec (p_subsidiary_code            IN VARCHAR2
                                  ,p_employee_no                IN VARCHAR2
                                  ,p_time_and_attendance_yyyymm IN VARCHAR2
                                  )
RETURN tb_att_annual_leave_n%ROWTYPE
IS
    aal_rec                   tb_att_annual_leave_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   aal_rec
    FROM   tb_att_annual_leave_n
    WHERE  subsidiary_code            = p_subsidiary_code
    AND    employee_no                = p_employee_no
    AND    time_and_attendance_yyyymm = p_time_and_attendance_yyyymm
    ;

    RETURN aal_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_annual_leave_rec;


/*************************************************************************************************/
/* Program Name : get_att_idcard_acs_time_rec                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태일자에 해당하는 출입정보를 return 한다                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_idcard_acs_time_rec (p_subsidiary_code          IN VARCHAR2
                                     ,p_employee_no              IN VARCHAR2
                                     ,p_time_and_attendance_date IN DATE
                                     )
RETURN tb_att_idcard_acs_time_n%ROWTYPE
IS
    aict_rec                   tb_att_idcard_acs_time_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   aict_rec
    FROM   tb_att_idcard_acs_time_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    employee_no              = p_employee_no
    AND    time_and_attendance_date = p_time_and_attendance_date
    ;

    RETURN aict_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_idcard_acs_time_rec;


/*************************************************************************************************/
/* Program Name : get_att_contract_rec                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태일자에 해당하는 PIC정보를 return 한다                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_attend_contact_user_id     in    varchar2  PIC사원번호                  */
/*                p_organization_id                 in    number    조직ID                       */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_contract_rec (p_subsidiary_code             IN VARCHAR2
                              ,p_time_attend_contact_user_id IN VARCHAR2
                              ,p_organization_id             IN NUMBER    
                              )
RETURN tb_att_contract_n%ROWTYPE
IS
    tac_rec                   tb_att_contract_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   tac_rec
    FROM   tb_att_contract_n
    WHERE  subsidiary_code             = p_subsidiary_code
    AND    time_attend_contact_user_id = p_time_attend_contact_user_id
    AND    organization_id             = p_organization_id
    ;

    RETURN tac_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_contract_rec;


/*************************************************************************************************/
/* Program Name : get_att_holiday_info_rec                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 휴일일자에 해당하는 휴일정보를 return 한다                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_holiday_date                    in    date      휴일일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/17  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_holiday_info_rec (p_subsidiary_code IN VARCHAR2
                                  ,p_holiday_date    IN DATE
                                  )
RETURN tb_att_holiday_info_n%ROWTYPE
IS
    ahi_rec                   tb_att_holiday_info_n%ROWTYPE;
BEGIN

    SELECT *
    INTO   ahi_rec
    FROM   tb_att_holiday_info_n
    WHERE  subsidiary_code = p_subsidiary_code
    AND    holiday_date    = p_holiday_date
    ;

    RETURN ahi_rec;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_holiday_info_rec;

/*************************************************************************************************/
/* Program Name : get_att_date_type                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Get date type.                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                    */
/*                p_atendance_date                 in   Date       종료일자                     */
/*                p_type                                 in    varchar2  type                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2022/03/01  HMT_20220301  Get date type                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_date_type (p_subsidiary_code           IN  VARCHAR2
                               ,p_employee_no                         IN  VARCHAR2
                               ,p_atendance_date                    IN  DATE
                               ,p_type                                    IN  VARCHAR2
                               )
RETURN VARCHAR2 IS
    v_return_value             VARCHAR2(20) := NULL;
    
BEGIN
   
   IF p_type = 'SHIFT_CODE_SWAP' THEN   
     BEGIN
     select s.working_day_shift_type_code into v_return_value
          from tb_att_swap_holiday_request_n s
         where s.employee_no = p_employee_no
           AND s.weekly_holiday = p_atendance_date
           AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
           AND NOT EXISTS (select 1
                                  from tb_att_swap_holiday_request_n s1
                                 where s1.employee_no = p_employee_no
                                  AND s1.working_day = p_atendance_date
                                  AND s1.weekly_holiday = s.working_day
                                   AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
           AND s.request_seq_no = (select max(ss.request_seq_no)
                                    from tb_att_swap_holiday_request_n ss
                                   where ss.employee_no = p_employee_no
                                     AND ss.weekly_holiday = p_atendance_date
                                     AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
         
         EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_return_value :=NULL;
        END;                            
           IF v_return_value is NULL THEN
             select s.weekly_holiday_shift_type_code into v_return_value
              from tb_att_swap_holiday_request_n s
             where s.employee_no = p_employee_no
               AND s.working_day = p_atendance_date
               AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
               AND NOT EXISTS (select 1
                                      from tb_att_swap_holiday_request_n s1
                                     where s1.employee_no = p_employee_no
                                      AND s1.weekly_holiday = p_atendance_date
                                      AND s1.working_day = s.weekly_holiday
                                       AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
              AND s.request_seq_no = (select max(ss.request_seq_no)
                                    from tb_att_swap_holiday_request_n ss
                                   where ss.employee_no = p_employee_no
                                     AND ss.working_day = p_atendance_date
                                     AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
           END IF;
                                     
     ELSIF  p_type = 'ATTENDANCE_CODE_SWAP' THEN 
       BEGIN  
         select 'NW' into v_return_value
              from tb_att_swap_holiday_request_n s
             where s.employee_no = p_employee_no
               AND s.weekly_holiday = p_atendance_date
               AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
               AND NOT EXISTS (select 1
                                      from tb_att_swap_holiday_request_n s1
                                     where s1.employee_no = p_employee_no
                                      AND s1.working_day = p_atendance_date
                                      AND s1.weekly_holiday = s.working_day
                                       AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
               AND s.request_seq_no = (select max(ss.request_seq_no)
                                        from tb_att_swap_holiday_request_n ss
                                       where ss.employee_no = p_employee_no
                                         AND ss.weekly_holiday = p_atendance_date
                                         AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
           EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_return_value := NULL;
        END;
                                  
           IF v_return_value is NULL THEN
             select 'WH' into v_return_value
              from tb_att_swap_holiday_request_n s
             where s.employee_no = p_employee_no
               AND s.working_day = p_atendance_date
               AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
               AND NOT EXISTS (select 1
                                      from tb_att_swap_holiday_request_n s1
                                     where s1.employee_no = p_employee_no
                                      AND s1.weekly_holiday = p_atendance_date
                                      AND s1.working_day = s.weekly_holiday
                                       AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
              AND s.request_seq_no = (select max(ss.request_seq_no)
                                    from tb_att_swap_holiday_request_n ss
                                   where ss.employee_no = p_employee_no
                                     AND ss.working_day = p_atendance_date
                                     AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
           END IF;         
          
      END IF;

    RETURN v_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_date_type;

FUNCTION get_work_values_type(p_subsidiary_code  IN VARCHAR2,
                                             p_start_date      IN  DATE,
                                             p_end_date        IN  DATE,
                                             p_in_value          IN VARCHAR2,
                                             p_emp_type        IN VARCHAR2,
                                             p_get_type         IN VARCHAR2
                                              )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Program Name : get_work_values_type
/* Description  : Return total employee's overtime value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2022/12/12  HMT_20221212        Add get_work_values_type function  
/*
/******************************************************************************/
RETURN NUMBER
IS
    work_values             NUMBER := 0;

BEGIN
  IF p_emp_type = 'ORG' THEN
  --Get TARDY_HOURS
    IF p_get_type = 'tardy' THEN
       
       SELECT SUM(T.TARDY_HOURS) INTO work_values
        FROM EMP_MASTER E, TB_ATT_RESULT_N T
       WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
          AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
         AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);
    
    --Get EARLY_LEAVE_HOURS
    ELSIF p_get_type = 'early' THEN
      
      SELECT SUM(T.EARLY_LEAVE_HOURS) INTO work_values
        FROM EMP_MASTER E, TB_ATT_RESULT_N T
       WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
          AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
         AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);
     
    --GET GOING_OUT_HOURS  
     ELSIF p_get_type = 'going_out' THEN
      
      SELECT SUM(T.GOING_OUT_HOURS) INTO work_values
        FROM EMP_MASTER E, TB_ATT_RESULT_N T
       WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
          AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
         AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);
       
       --GET TRAINNING HOURS
       ELSIF p_get_type = 'trainning' THEN
      
      SELECT SUM(T.WORK_HOURS) INTO work_values
        FROM EMP_MASTER E, TB_ATT_RESULT_N T
       WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
          AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
          AND T.A_DAY_OF_THE_WEEK_CODE IN ('OR','DR')
         AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);
      
      --GET LEAVE HOURS 
       ELSIF p_get_type = 'leave' THEN
      
      SELECT SUM(T.WORK_HOURS) INTO work_values
        FROM EMP_MASTER E, TB_ATT_RESULT_N T
       WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
          AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
          AND T.A_DAY_OF_THE_WEEK_CODE IN ('HL',  'HL_SN',  'HL_FN',  'AL',  'PM',  'PF',  'DB',  'OB',  'UL',  'UM',  'UF')
         AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);

        END IF;
      
      ELSIF p_emp_type = 'EMP' THEN
        --Get TARDY_HOURS
        IF p_get_type = 'tardy' THEN
           
           SELECT SUM(T.TARDY_HOURS) INTO work_values
            FROM TB_ATT_RESULT_N T
           WHERE T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
              AND T.EMPLOYEE_NO = p_in_value;
        
        --Get EARLY_LEAVE_HOURS
        ELSIF p_get_type = 'early' THEN
          
          SELECT SUM(T.EARLY_LEAVE_HOURS) INTO work_values
            FROM TB_ATT_RESULT_N T
           WHERE T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
              AND T.EMPLOYEE_NO = p_in_value;
         
        --GET GOING_OUT_HOURS  
         ELSIF p_get_type = 'going_out' THEN
          
          SELECT SUM(T.GOING_OUT_HOURS) INTO work_values
            FROM TB_ATT_RESULT_N T
           WHERE T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
              AND T.EMPLOYEE_NO = p_in_value;
           
           --GET TRAINNING HOURS
           ELSIF p_get_type = 'trainning' THEN
          
          SELECT SUM(T.WORK_HOURS) INTO work_values
            FROM TB_ATT_RESULT_N T
           WHERE T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
              AND T.A_DAY_OF_THE_WEEK_CODE IN ('OR','DR')
              AND T.EMPLOYEE_NO = p_in_value;
          
          --GET LEAVE HOURS 
           ELSIF p_get_type = 'leave' THEN
          
          SELECT SUM(T.WORK_HOURS) INTO work_values
            FROM TB_ATT_RESULT_N T
           WHERE T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
              AND T.A_DAY_OF_THE_WEEK_CODE IN ('HL',  'HL_SN',  'HL_FN',  'AL',  'PM',  'PF',  'DB',  'OB',  'UL',  'UM',  'UF')
              AND T.EMPLOYEE_NO = p_in_value;
              
          END IF;
          ELSIF p_emp_type = 'TOTAL' THEN
        --Get TARDY_HOURS
              SELECT COUNT(DISTINCT E.EMPLOYEE_NUMBER) INTO work_values
                FROM EMP_MASTER E, TB_ATT_RESULT_N T
               WHERE E.EMPLOYEE_NUMBER = T.EMPLOYEE_NO
                  AND T.TIME_AND_ATTENDANCE_DATE BETWEEN p_start_date AND p_end_date
                 AND E.ORGANIZATION_ID IN (SELECT OM.ORGANIZATION_ID
                        FROM ORG_MASTER OM
                       START WITH OM.ORGANIZATION_ID = p_in_value
                      CONNECT BY PRIOR OM.ORGANIZATION_ID = OM.PARENT_ORG_ID);
          
      END IF;
      
   return work_values;

EXCEPTION
WHEN OTHERS THEN
    RETURN work_values;

END get_work_values_type;

/*************************************************************************************************/
/* Program Name : get_att_code_info                                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태코드정보를 Return한다.                                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*                p_type                            in    varchar2  유형                         */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_code_info (p_subsidiary_code          IN  VARCHAR2
                           ,p_time_and_attendance_code IN  VARCHAR2
                           ,p_type                     IN  VARCHAR2 DEFAULT 'NAME'
                           )
RETURN VARCHAR2
IS
    ac_rec                 tb_att_code_c%ROWTYPE;

BEGIN

    SELECT *
    INTO   ac_rec
    FROM   tb_att_code_c
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_code = p_time_and_attendance_code
    ;

    IF (NVL(p_type, 'NAME') = 'NAME') THEN
        RETURN ac_rec.time_and_attendance_name;  -- 코드명(전체)

    --ELSIF (p_type = 'SCREEN') THEN
    --    RETURN ac_rec.;    -- 화면명(약어)

    ELSIF (p_type = 'TYPE') THEN
        RETURN ac_rec.time_and_attendance_type_code;  -- 코드유형코드

    ELSIF (p_type = 'PAID') THEN
        RETURN ac_rec.paid_days;  -- 유급일수

    ELSIF (p_type = 'UNPAID') THEN
        RETURN ac_rec.unpaid_days;  -- 무급일수

    ELSIF (p_type = 'ATTENDANCE') THEN
        RETURN ac_rec.attendance_days;  -- 출근일수

    ELSIF (p_type = 'OFC_TECH') THEN
        RETURN ac_rec.ofc_wrk_tech_wrk_type_code;  -- 사무기능직구분코드

    ELSIF (p_type = 'OVERTIME') THEN
        RETURN ac_rec.overtime_flag;  -- 연장근무여부

    ELSIF (p_type = 'GENDER') THEN
        RETURN ac_rec.gender_code;  -- 성별코드

    ELSIF (p_type = 'USE') THEN
        RETURN ac_rec.use_flag;  -- 사용여부

    ELSIF (p_type = 'CONTENT') THEN
        RETURN ac_rec.apply_content;  -- 적용내용

    ELSIF (p_type = 'DESC') THEN
        RETURN ac_rec.apply_plan_desc;  -- 적용방안설명
    END IF;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_code_info;


/*************************************************************************************************/
/* Program Name : get_work_hours                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  실제 근무시간을 Return한다.                                                   */
/*                 - result 의 work_hours 값은, attendance_days * 8 시간이며,                    */
/*                   레포트등에서는 지각/외출/조퇴 값을 제외한 시간을 사용한다.                  */
/*                 - 휴일(WH), 휴가(AL) 등에 출근해서, 지각/외출/조퇴 가 있으면 - 값이 된다.     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/03  박귀희B     [베트남 근태/급여 프로젝트]                                           */
/*                         근무시간은 차감시간은 제외한 기본근태에 대한 시간을 반영토록 함       */
/* 2021/03/24  HMT_20210324   update work_hours = 8 or 9                                         */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_hours (p_subsidiary_code          IN  VARCHAR2
                        ,p_employee_no              IN  VARCHAR2
                        ,p_time_and_attendance_date IN  DATE
                        )
RETURN VARCHAR2
IS
    ar_rec              tb_att_result_n%ROWTYPE;
    ac_rec              tb_att_code_c%ROWTYPE;
    
    v_shift_code        tb_att_result_n.shift_type_code%TYPE;
    v_work_hours        tb_att_result_n.work_hours%TYPE;
BEGIN

    -- 실제출근해서 일한 시간(출근, 출장등)
    v_work_hours := 0;
    
    ar_rec := get_att_result_rec(p_subsidiary_code, p_employee_no, p_time_and_attendance_date);
/*
    SELECT *
    INTO   ar_rec
    FROM   tb_att_result_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    employee_no              = p_employee_no
    AND    time_and_attendance_date = p_time_and_attendance_date
    ;
*/


       
    SELECT *
    INTO   ac_rec
    FROM   tb_att_code_c
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_code = ar_rec.time_and_attendance_code
    ;

    -- 출근에 해당하는 근태코드일때만
    IF (NVL(ac_rec.attendance_days, 0) = 1) THEN
      --< Start 2023.03.09 : 2S10G Shift condition add 
      IF ar_rec.shift_type_code LIKE '102%' THEN 
        v_work_hours := (NVL(ac_rec.attendance_days, 0) * 8)  -- 출근/출장등 출근 일수
                      /* 차감항목은 제외
                      - NVL(ar_rec.tardy_hours, 0)            -- 지각시간
                      - NVL(ar_rec.early_leave_hours, 0)      -- 조퇴시간
                      - NVL(ar_rec.going_out_hours, 0)        -- 외출시간
                      */
                      ;
      ELSIF ar_rec.shift_type_code LIKE '3%' THEN 
        v_work_hours := (NVL(ac_rec.attendance_days, 0) * 9.5)  -- 출근/출장등 출근 일수
                      /* 차감항목은 제외
                      - NVL(ar_rec.tardy_hours, 0)            -- 지각시간
                      - NVL(ar_rec.early_leave_hours, 0)      -- 조퇴시간
                      - NVL(ar_rec.going_out_hours, 0)        -- 외출시간
                      */
                      ;
      ELSE
        --2021/03/24 HMT_20210324 : update work_hours
        IF TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'D')) = 6
        OR p_time_and_attendance_date < TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD') THEN
          v_work_hours := (NVL(ac_rec.attendance_days, 0) * 8);  -- 출근/출장등 출근 일수
                      /* 차감항목은 제외
                      - NVL(ar_rec.tardy_hours, 0)            -- 지각시간
                      - NVL(ar_rec.early_leave_hours, 0)      -- 조퇴시간
                      - NVL(ar_rec.going_out_hours, 0)        -- 외출시간
                      */
          ELSE
            v_work_hours := (NVL(ac_rec.attendance_days, 0) * 9); --HMT_20210324 9
          END IF;
          --> End
      END IF;
    ELSIF (NVL(ac_rec.attendance_days, 0) = 0.5) THEN
      --< Start 2023.03.09 : 2S10G Shift condition add 
          IF ar_rec.shift_type_code LIKE '102%' THEN
            v_work_hours := 4;
      --2021/03/24 HMT_20210324 : update work_hours
        --v_work_hours := 4;
          ELSIF ar_rec.shift_type_code LIKE '3%' THEN 
             v_work_hours := 4;
          ELSE
            IF TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'D')) = 6
            OR p_time_and_attendance_date < TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD') THEN
              v_work_hours := 4; 
              ELSE
                v_work_hours := 4.5;
              END IF;
          END IF;
        --> End
    END IF;

    RETURN v_work_hours;

EXCEPTION
WHEN OTHERS THEN
    RETURN SQLERRM;

END get_work_hours;


/*************************************************************************************************/
/* Program Name : get_work_hours                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  실제 근무시간을 Return한다.                                                   */
/*                 - result 의 work_hours 값은, attendance_days * 8 시간이며,                    */
/*                   레포트등에서는 지각/외출/조퇴 값을 제외한 시간을 사용한다.                  */
/*                 - 휴일(WH), 휴가(AL) 등에 출근해서, 지각/외출/조퇴 가 있으면 - 값이 된다.     */
/*                 - 기본근태등에서 기본 근무시간을 조회시에는, 지각/외출/조퇴를 0 으로 호출한다.*/
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*                p_tardy_hours                     in    number    지각시간                     */
/*                p_going_out_hours                 in    number    외출시간                     */
/*                p_early_leave_hours               in    number    조퇴시간                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/03  박귀희B     [베트남 근태/급여 프로젝트]                                           */
/*                         근무시간은 차감시간은 제외한 기본근태에 대한 시간을 반영토록 함       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_hours (p_subsidiary_code              IN  VARCHAR2
                        ,p_time_and_attendance_code     IN  VARCHAR2
                        ,p_tardy_hours                  IN  NUMBER
                        ,p_going_out_hours              IN  NUMBER
                        ,p_early_leave_hours            IN  NUMBER
                        )
RETURN NUMBER
IS
    ac_rec              tb_att_code_c%ROWTYPE;

    v_work_hours        tb_att_result_n.work_hours%TYPE;
BEGIN

    -- 실제출근해서 일한 시간(출근, 출장등)
    v_work_hours := 0;

    SELECT *
    INTO   ac_rec
    FROM   tb_att_code_c
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_code = p_time_and_attendance_code
    ;

    -- 출근에 해당하는 근태코드일때만
    IF (NVL(ac_rec.attendance_days, 0) > 0) THEN
        v_work_hours := (NVL(ac_rec.attendance_days, 0) * 8)  -- 출근/출장등 출근 일수
                      /* 차감항목은 제외
                      - NVL(p_tardy_hours, 0)                 -- 지각시간
                      - NVL(p_going_out_hours, 0)             -- 외출시간
                      - NVL(p_early_leave_hours, 0)           -- 조퇴시간
                      */
                      ;
    END IF;

    RETURN v_work_hours;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_work_hours;

/*************************************************************************************************/
/* Program Name : get_work_hours_by_att                                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Get the work hours: 8 or 9.5 base on the Shift Type Code.                               */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_shift_type_code                 in    varchar2  교대유형코드                 */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/12/06  TaiDD     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_hours_by_att (p_subsidiary_code          IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_shift_type_code          IN  VARCHAR2
                                    )
RETURN NUMBER
IS
    v_work_hours      tb_att_base_bas_n.work_hours%TYPE;

BEGIN

    SELECT work_hours
    INTO   v_work_hours
    FROM   tb_att_base_bas_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = p_time_and_attendance_date
    AND    shift_type_code          = p_shift_type_code
    ;

    RETURN v_work_hours;
    
EXCEPTION
WHEN OTHERS THEN
     RETURN NULL;

END get_work_hours_by_att;

/*************************************************************************************************/
/* Program Name : get_work_hours_by_plan                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  Get the work hours based on the info from the table tb_att_plan_n  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2019/10/31  TaiDD    Initial Release                                                       */
/* 2021/03/24  HMT_20210324   update work_hours = 8 or 9                                         */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_hours_by_plan (p_subsidiary_code          IN  VARCHAR2
                        ,p_employee_no              IN  VARCHAR2
                        ,p_time_and_attendance_date IN  DATE
                        )
RETURN VARCHAR2
IS
    ap_rec              tb_att_plan_n%ROWTYPE;
    ac_rec              tb_att_code_c%ROWTYPE;
    
    v_shift_code        tb_att_plan_n.shift_type_code%TYPE;
    v_work_hours       NUMBER;
BEGIN

    v_work_hours := 0;
    
    ap_rec := get_att_plan_rec(p_subsidiary_code, p_employee_no, p_time_and_attendance_date);
       
    SELECT *
    INTO   ac_rec
    FROM   tb_att_code_c
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_code = ap_rec.time_and_attendance_code
    ;

    -- 출근에 해당하는 근태코드일때만
    IF (NVL(ac_rec.attendance_days, 0) = 1) THEN
      --< Start 2023.03.09 : 2S10G Shift condition add
      IF ap_rec.shift_type_code LIKE '102%' THEN 
        v_work_hours := (NVL(ac_rec.attendance_days, 0) * 8);  -- 출근/출장등 출근 일수
        
      ELSIF ap_rec.shift_type_code LIKE '3%' THEN 
        v_work_hours := (NVL(ac_rec.attendance_days, 0) * 9.5)  -- 출근/출장등 출근 일수
                      ;
      ELSE
        IF TO_NUMBER(TO_CHAR(p_time_and_attendance_date, 'D')) = 6 THEN
           v_work_hours := (NVL(ac_rec.attendance_days, 0) * 8);  -- 출근/출장등 출근 일수    
        ELSE
          v_work_hours := (NVL(ac_rec.attendance_days, 0) * 9); --HMT_20210324 9
          END IF;                   
      END IF;
    ELSIF (NVL(ac_rec.attendance_days, 0) = 0.5) THEN
        v_work_hours := 4;
    END IF;

    RETURN v_work_hours;

EXCEPTION
WHEN OTHERS THEN
    RETURN SQLERRM;

END get_work_hours_by_plan;

/*************************************************************************************************/
/* Program Name : get_work_days                                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  특정 기간 근무일수 계산                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_from_date                       in   Date       시작일자                     */
/*                p_to_date                         in   Date       종료일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  김연균B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_days(p_subsidiary_code IN VARCHAR2
                      ,p_from_date       IN DATE
                      ,p_to_date         IN DATE) RETURN NUMBER IS
    v_work_days NUMBER;

BEGIN

    -- Working days
    v_work_days := 0;

     BEGIN
       SELECT COUNT(*)
       INTO   v_work_days
       FROM   tb_att_calendar_n tac
       WHERE  1 = 1
       AND    tac.subsidiary_code = p_subsidiary_code
       AND    tac.time_and_attendance_date BETWEEN  p_from_date
                                              AND   p_to_date
       AND    tac.holiday_flag = 'N' ; -- 휴일 제외
     END ;

    -- 휴일을 제외한 Working Days 계산

    RETURN v_work_days;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;

END get_work_days;

/*************************************************************************************************/
/* Program Name : get_work_days_by_swap                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Get working day when swap.                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_from_date                       in   Date       시작일자                     */
/*                p_to_date                         in   Date       종료일자                     */
/*                p_employee_no                     in    varchar2  사원번호                    */
/*                p_type                            in    varchar2  type                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/07/03  HMT_20210703  Get working days when swap                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_work_days_by_swap (p_subsidiary_code           IN  VARCHAR2
                               ,p_weekly_holiday            IN  DATE
                               ,p_working_day               IN  DATE
                               ,p_employee_no               IN  VARCHAR2
                               ,p_type                      IN  VARCHAR2
                               )
RETURN VARCHAR2 IS
    v_work_days             NUMBER;
    v_work_date             VARCHAR2(20);
    v_weekly_holiday_from   DATE;
    v_weekly_holiday_to     DATE;
    
BEGIN
    
    SELECT MAX(t.time_and_attendance_date) INTO v_weekly_holiday_from 
     FROM   tb_att_result_n t
      WHERE t.subsidiary_code = p_subsidiary_code
        AND t.time_and_attendance_date < p_weekly_holiday
        AND t.employee_no = p_employee_no
        AND t.time_and_attendance_code IN (select c.time_and_attendance_code from tb_att_code_c c where c.attendance_days = 0);
        
    SELECT MIN(t.time_and_attendance_date) INTO v_weekly_holiday_to
     FROM   tb_att_result_n t
      WHERE t.subsidiary_code = p_subsidiary_code
        AND t.time_and_attendance_date > p_weekly_holiday
        AND t.employee_no = p_employee_no
        AND t.time_and_attendance_code IN (select c.time_and_attendance_code from tb_att_code_c c where c.attendance_days = 0);
      
    IF p_weekly_holiday > p_working_day AND  p_working_day > v_weekly_holiday_from 
      THEN v_weekly_holiday_from := p_working_day;      END IF;
      
    IF p_weekly_holiday < p_working_day AND p_working_day < v_weekly_holiday_to 
      THEN v_weekly_holiday_to := p_working_day;      END IF;
      
   SELECT v_weekly_holiday_to - v_weekly_holiday_from INTO v_work_days FROM dual;
   
   IF p_type = 'START_DATE' THEN     v_work_date:= TO_CHAR(v_weekly_holiday_from, 'YYYYMMDD');
    ELSIF p_type = 'END_DATE' THEN  v_work_date:= TO_CHAR(v_weekly_holiday_to, 'YYYYMMDD');
     ELSIF p_type = 'WORKING_TIME' THEN v_work_date:= TO_CHAR(v_work_days);         
          
      END IF;

    RETURN v_work_date;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_work_days_by_swap;

/*************************************************************************************************/
/* Program Name : get_working_date                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  실제 근무일자 계산                                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_from_date                       in   Date       시작일자                     */
/*                p_days                            in   Number     일자수(기간)                 */
/*                p_shift_type                      in   Date       근무유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  김연균B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_working_date(p_subsidiary_code IN VARCHAR2
                         ,p_from_date       IN DATE
                         ,p_days            IN NUMBER
                         ,p_shift_type      IN VARCHAR2 DEFAULT '1A'
                         )
RETURN DATE
IS
    l_from_date  DATE;
    l_to_date    DATE;
    l_cnt        NUMBER := 1;
    l_holiday_fg VARCHAR2(1);
    l_end_date   DATE;

BEGIN

    l_from_date := TRUNC(p_from_date);
    l_to_date   := TRUNC(p_from_date);

    IF NVL(p_days, 0) = 0 THEN
        RETURN l_to_date;
    END IF;

    LOOP
        IF l_cnt = p_days THEN
            EXIT;
        END IF;

        SELECT tab.time_and_attendance_date
              ,tac.holiday_flag
        INTO   l_to_date
              ,l_holiday_fg
        FROM   tb_att_base_bas_n tab
              ,tb_att_calendar_n tac
        WHERE  1 = 1
        AND    tab.subsidiary_code = p_subsidiary_code
        AND    tab.subsidiary_code = tac.subsidiary_code
        AND    tab.shift_type_code = NVL(p_shift_type, '1A')
        AND    tab.time_and_attendance_date = tac.time_and_attendance_date
        AND    tab.time_and_attendance_date = l_to_date + DECODE(SIGN(p_days), 1, 1, -1);

        IF l_holiday_fg = 'N' THEN
            IF SIGN(p_days) = 1 THEN
                l_cnt := l_cnt + 1;
            ELSE
                l_cnt := l_cnt - 1;
            END IF;
        END IF;

    END LOOP;

    RETURN l_to_date;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;

END get_working_date;


/************************************************************************************************/
/* Program Name : get_holiday_flag                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  휴일 여부 확인 한다.                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_date                            in   Date       조회일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  김연균B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_holiday_flag(p_subsidiary_code IN VARCHAR2
                         ,p_shift_code      IN VARCHAR2 DEFAULT '1A'
                         ,p_date            IN DATE) RETURN VARCHAR2 IS

    l_holiday_flag VARCHAR2(1) := 'N';

BEGIN


  BEGIN
    SELECT DECODE(t.time_and_attendance_code, 'NW', 'N', 'Y') AS holiday_flag
    INTO   l_holiday_flag
    FROM   TB_ATT_BASE_BAS_N t
    WHERE  t.subsidiary_code          = p_subsidiary_code
    AND    t.time_and_attendance_date = TRUNC(p_date)
    AND    t.shift_type_code          = p_shift_code;
EXCEPTION
    WHEN no_data_found THEN
        l_holiday_flag := 'N';
    WHEN OTHERS THEN
        l_holiday_flag := 'N';
  END ;


RETURN l_holiday_flag;

EXCEPTION
     WHEN OTHERS THEN
        RETURN NULL;

END get_holiday_flag;

/*************************************************************************************************/
/* Program Name : get_deduc_item_weekly_report                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  실제 근무시간을 Return한다.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_att_date                 in    DATE      근태날짜                            */
/*                p_empolyee_no              in    varchar2  사번                                */
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/31  H.W JANG     Initial Release                                                      */
/*************************************************************************************************/
FUNCTION get_deduc_item_weekly_report(p_subsidiary_code IN  VARCHAR2
                                     ,p_att_date        IN DATE
                                     ,p_empolyee_no     IN VARCHAR2
                                      )
RETURN VARCHAR2
IS
    v_lt_code           NUMBER;
    v_el_code           NUMBER;
    v_go_code           NUMBER;

    v_tot_item          VARCHAR2(30);
BEGIN

    -- 지각,조퇴 외출 조회
    SELECT a.tardy_hours
          ,a.early_leave_hours
          ,a.going_out_hours
    INTO   v_lt_code
          ,v_el_code
          ,v_go_code
    FROM   TB_ATT_RESULT_N A
    WHERE  A.TIME_AND_ATTENDANCE_DATE = p_att_date
    AND    A.EMPLOYEE_NO              = p_empolyee_no
    AND    A.Subsidiary_Code          = p_subsidiary_code;

    -- 코드 입력 여부에 따라 조합 시작
    v_tot_item := NULL;

    IF v_lt_code IS NOT NULL AND v_lt_code != 0 THEN
       v_tot_item := 'LT '||to_char(v_lt_code,'FM00.0');
    END IF;

    IF nvl(v_tot_item,' ') != ' ' THEN
      IF v_el_code IS NOT NULL AND v_el_code != 0 THEN
         v_tot_item := v_tot_item || ', '||'EL '||to_char(v_el_code,'FM00.0');
      END IF;
    ELSIF nvl(v_tot_item,' ') = ' ' AND v_el_code IS NOT NULL AND v_el_code != 0 THEN
       v_tot_item := 'EL '||to_char(v_el_code,'FM00.0');
    END IF;

    IF nvl(v_tot_item,' ') != ' ' THEN
      IF v_go_code IS NOT NULL AND v_go_code != 0  THEN
       v_tot_item := v_tot_item ||', '||'GO '||to_char(v_go_code,'FM00.0');
      END IF;
    ELSIF nvl(v_tot_item,' ') = ' ' AND v_go_code IS NOT NULL AND v_go_code != 0 THEN
       v_tot_item := 'GO '||to_char(v_go_code,'FM00.0');
    END IF;

    RETURN v_tot_item;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_deduc_item_weekly_report;

/*************************************************************************************************/
/* Program Name : get_work_hours                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  :  Daily Attendance 승인 Status                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_request_master_id               in    number     Request Master ID           */
/*                p_system_code                     in    varchar2   시스템 코드                 */
/*                p_module_code                     in    varchar2   모듈코드                    */
/*                p_request_code                    in    number     결재요청코드                */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  김연균B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_approval_status (p_request_master_id IN VARCHAR2
                             ,p_request_code      IN NUMBER
                             ,p_employee_no       IN VARCHAR2 DEFAULT NULL
                             )
RETURN VARCHAR2
IS
    v_get_approval_status_code VARCHAR2(20);
    v_approval_status          VARCHAR2(20);
    v_wait_for_approval        VARCHAR2(20);
    v_approver_wait_cnt        NUMBER ;
BEGIN

     -- 승인 요청서 Table에서 1차, 2차 상태를 가져온다
    BEGIN
        SELECT MAX(DECODE(las.approval_seqs, 1, las.approval_status_code)) ||
               MAX(DECODE(las.approval_seqs, 2, las.approval_status_code))
        INTO   v_get_approval_status_code
        FROM   lgcom_approval_request_n lar
              ,lgcom_approval_status_n  las
        WHERE  1 = 1
        AND    lar.request_master_id = las.request_master_id
        AND    lar.request_master_id = p_request_master_id
        AND    lar.request_code = p_request_code
        AND    las.approval_seqs     > 0 -- 본인 제외
        GROUP  BY lar.request_master_id
        ;
    END;

    -- 사용자 정의 Status를 변환
    ----------------------------
    --  NY    Not Yet
    --  1A    1st Approved
    --  FA    Final Approved
    --  FR    Final reject
    --  FC    Final Cancel
    --  1R    1st Reject
    --  1C    1st Cancel
    ----------------------------
    --  WA  Wait for Approval
    ----------------------------

    BEGIN
        SELECT lcc.parent_common_code,nvl(lcc.code_data1_value,'NONE')
        INTO   v_approval_status,v_wait_for_approval
        FROM   lgcom_common_code_c lcc
        WHERE  lcc.code_type_code = 'LGVHR_ATT_GET_APPROVAL_STATUS'
        AND    lcc.common_code    = v_get_approval_status_code
        AND    NVL(lcc.apply_start_date, TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
        AND    NVL(lcc.apply_end_date,   TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
        ;
    END;


    -- 1차, 2차 Waiting 대상 여부 확인
    -- 조회 대상자( 1st, Final)차례에 Wait for Approval이 있는지 확인
    IF v_wait_for_approval = 'WA' AND p_employee_no IS NOT NULL THEN
        BEGIN
          SELECT COUNT(*)
          INTO   v_approver_wait_cnt
          FROM   lgcom_approval_request_n lar
                ,lgcom_approval_status_n  las
          WHERE  1 = 1
          AND    las.user_no = p_employee_no
          AND    lar.request_code = p_request_code
          AND    lar.request_master_id = las.request_master_id
          AND    lar.request_master_id = p_request_master_id
          AND    las.approval_status_code = '2'-- Wait for Approval
          AND    las.approval_seqs > 0; -- 본인 제외

        END ;

         IF v_approver_wait_cnt > 0 THEN
             v_approval_status := 'WA'; -- Wait for approval

         END IF ;


    END IF ;


    RETURN v_approval_status;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_approval_status;



/*************************************************************************************************/
/* Program Name : get_curr_att_yyyymm                                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 현재 유효한 근태년월을 Return한다.                                             */
/*                유형(p_att_type)에 따라 필요시에 로직추가하도록 한다.                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_att_type                        in    varchar2  근태유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_curr_att_yyyymm (p_subsidiary_code IN  VARCHAR2
                             ,p_att_type        IN  VARCHAR2 DEFAULT 'FINAL'
                             )
RETURN VARCHAR2
IS
    ac_rec    tb_att_close_n%ROWTYPE;
BEGIN

    ac_rec.time_and_attendance_yyyymm := NULL;

    -- SYSDATE 에 해당하는 입력가능한 근태년월
    IF (NVL(p_att_type, 'FINAL') = 'FINAL') THEN

        SELECT *
        INTO   ac_rec
        FROM   (SELECT *
                FROM   tb_att_close_n
                WHERE  subsidiary_code = p_subsidiary_code
                AND    time_and_attendance_yyyymm >= lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'OPEN_YYYYMM', 'A1')
                AND    time_and_attendance_yyyymm >= TO_CHAR(ADD_MONTHS(SYSDATE, lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'EFFECTIVE_CLOSE_MONTHS', 'A1')), 'YYYYMM')  -- 마감일자 관리가 안돠어, 과거년월이 계속 나오는걸 방지
                AND    TRUNC(SYSDATE) BETWEEN period_from_date AND period_to_date
                AND    period_close_date          >= SYSDATE
               )
        WHERE  ROWNUM = 1
        ;

    END IF;

    -- 현재 확정되지 않은 첫번째 근태년월
    IF (NVL(p_att_type, 'FINAL') = 'FIRST') THEN

        SELECT *
        INTO   ac_rec
        FROM   (
                SELECT *
                FROM   tb_att_close_n t
                WHERE  subsidiary_code = p_subsidiary_code
                AND    time_and_attendance_yyyymm >= lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'OPEN_YYYYMM', 'A1')
                AND    time_and_attendance_yyyymm >= TO_CHAR(ADD_MONTHS(SYSDATE, lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'EFFECTIVE_CLOSE_MONTHS', 'A1')), 'YYYYMM')  -- 마감일자 관리가 안돠어, 과거년월이 계속 나오는걸 방지
                AND    NVL(confirm_flag, 'N')     <> 'Y'
                ORDER BY time_and_attendance_yyyymm
               )
        WHERE ROWNUM = 1
        ;
    END IF;

    RETURN ac_rec.time_and_attendance_yyyymm;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_curr_att_yyyymm;


/*************************************************************************************************/
/* Program Name : get_att_close_time                                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태입력/결재/수정요청서요청/결재에 대한 마감시간을 Return한다.                */
/*                                                                                               */
/*                p_att_type = INPUT : 근태입력                                                  */
/*                             APPROVAL : 근태결재                                               */
/*                             UPD_SEL : 수정요청서 날짜 선택                                    */
/*                                       가능날짜이면 수정일자, 불가날짜이면 다른날짜 : TRUNC    */
/*                             UPD_REQ : 수정요청서 요청                                         */
/*                             UPD_ARP : 수정요청서 결재                                         */
/*                p_screen_type = DEFAULT : 기본                                                 */
/*                                LW_ORG_DATE : Line Worker 근태입력                             */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_att_type                        in    varchar2  근태유형                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_shift_type_code                 in    varchar2  교대유형코드(1A/21A/21B...)  */
/*                p_screen_type                     in    varchar2  화면유형                     */
/*                p_today                           in    date      오늘일자                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_close_time (p_subsidiary_code          IN  VARCHAR2
                            ,p_att_type                 IN  VARCHAR2
                            ,p_time_and_attendance_date IN  DATE
                            ,p_shift_type_code          IN  VARCHAR2 DEFAULT '1A'
                            ,p_screen_type              IN  VARCHAR2 DEFAULT 'DEFAULT'
                            ,p_today                    IN  DATE     DEFAULT SYSDATE
                            )
RETURN DATE
IS
    ab_rec                          tb_att_base_bas_n%ROWTYPE;
    ac_rec                          tb_att_close_n%ROWTYPE;
    al_rec                          tb_att_calendar_n%ROWTYPE;
    
    v_time_and_attendance_date      DATE;

    v_close_time_limit_flag         VARCHAR2(10);
    v_close_time_limit_time         VARCHAR2(10);
    
    v_close_time                    VARCHAR2(10);
    v_plus_day                      NUMBER;

    v_close_date                    DATE;
    
    v_shift_type_code               VARCHAR2(10)                := NVL(p_shift_type_code, '1A');

    v_plan_tbl                      lgvatt_input_date_tbl;
    v_result_tbl                    lgvatt_input_date_tbl;
    v_valid_flag                    BOOLEAN;
BEGIN

    v_time_and_attendance_date := TRUNC(p_time_and_attendance_date);

    -- 수정요청일자에 해당하는 근태년월
    ac_rec := lgvatt_common_pkg.get_att_close_rec (p_subsidiary_code, TO_CHAR(v_time_and_attendance_date, 'YYYYMM'));  

    -- 마감시간 제한 여부
    v_close_time_limit_flag := NVL(lgvhr_common_pkg.decode_lookup ('LGVHR_ATT_COMMON_CODE', 'CLOSE_TIME_LIMIT_' || p_att_type || '_FLAG', 'A1'), 'Y');

    -- 수정요청서 날짜선택/요청/결재
    IF (p_att_type IN ( 'UPD_SEL', 'UPD_REQ', 'UPD_APR' )) THEN

        -- 수정요청서는 과거실적에 대해서 신청하는 것이므로, 오늘날짜부터는 신청 불가함(어제실적은 오늘 입력함, 금토일까지는 체크하지 않음)
        IF (v_time_and_attendance_date >= TRUNC(NVL(p_today, SYSDATE))) THEN
            RETURN TO_DATE(TO_CHAR(lgvhr_common_pkg.start_of_time, 'YYYYMMDD') || ' 00:00:01', 'YYYYMMDD HH24:MI:SS');
        END IF;

        -- 날짜선택 : 리턴값이 수정요청일자와 같을때만 수정가능
        IF (p_att_type = 'UPD_SEL') THEN
        
            -- 캘린더 없는 날짜 선택이면
            al_rec := lgvatt_common_pkg.get_att_calendar_rec (p_subsidiary_code, v_time_and_attendance_date);
            IF (al_rec.time_and_attendance_date IS NULL) THEN
                RETURN lgvhr_common_pkg.start_of_time;    -- 수정요청일자와 다른날짜
            END IF;

            -- 마감시간 제한 없으면
            IF (v_close_time_limit_flag = 'N') THEN
                RETURN v_time_and_attendance_date;  -- 수정요청일자
            END IF;  
            
            -- 마감시간이 지났으면
            IF (NVL(p_today, SYSDATE) > ac_rec.period_close_date) THEN
                RETURN lgvhr_common_pkg.start_of_time;    -- 수정요청일자와 다른날짜
            ELSE
                RETURN v_time_and_attendance_date;  -- 수정요청일자
            END IF;

        -- 요청/결재 : 추후 기준이 달라지면 분리할것
        ELSE
            -- 마감시간 제한 없으면
            IF (v_close_time_limit_flag = 'N') THEN
                RETURN lgvhr_common_pkg.end_of_time;
            END IF;
            
            RETURN ac_rec.period_close_date;  -- 월별 마감시간
        END IF;

    -- 수정요청서 외
    ELSE
        SELECT *
        INTO   ab_rec
        FROM   tb_att_base_bas_n ab
        WHERE  ab.subsidiary_code          = p_subsidiary_code
        AND    ab.time_and_attendance_date = TRUNC(NVL(p_today, v_time_and_attendance_date))
        AND    ab.shift_type_code          = v_shift_type_code
        ;

        IF (p_att_type = 'INPUT') THEN
            v_close_time := ab_rec.time_attend_input_close_time;

        ELSIF (p_att_type = 'APPROVAL') THEN
            v_close_time := ab_rec.time_attend_apprv_close_time;

        ELSE
            v_close_time := '000000';  -- 파라미터 틀리면, 시간제한
        END IF;

        -- 마감시간 제한 없으면
        IF (v_close_time_limit_flag = 'N') THEN
        
            -- 부제별 마감시간의 2번째 값 : INPUT_CLOSE_TIME_1N / APPRV_CLOSE_TIME_1N
            v_close_time_limit_time := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_CLOSE_TIME', (CASE WHEN p_att_type = 'APPROVAL' THEN 'APPRV' ELSE 'INPUT' END) || '_CLOSE_TIME_' || SUBSTR(v_shift_type_code, 1, 1) || ab_rec.night_shift_flag , 'A2');
       
            -- 값이 없으면, 마감시간 제한 없음. 단, 입력시에는 어제까지만 가능하며, 그외는 해당월 마감시간까지만.
            IF (v_close_time_limit_time IS NULL) THEN
                
                IF (p_att_type = 'INPUT' AND v_time_and_attendance_date > TRUNC(SYSDATE)) THEN  -- v_time_and_attendance_date : 계획기준일자
                    RETURN TO_DATE(TO_CHAR(lgvhr_common_pkg.start_of_time, 'YYYYMMDD') || ' 00:00:01', 'YYYYMMDD HH24:MI:SS');  -- 시간제한함
                ELSE
                    RETURN  LEAST(ac_rec.period_close_date, TO_DATE(TO_CHAR(lgvhr_common_pkg.end_of_time, 'YYYYMMDD') || ' 23:59:59', 'YYYYMMDD HH24:MI:SS'));
                END IF;

            ELSE
                -- 값이 있으면, 해당 마감시간으로 적용 : 'A1' 의 값은 기초근태 생성시에 적용되는 공통 마감시감이며, 'A2' 는 필요시에 별도로 지정하여 사용함
                v_close_time := v_close_time_limit_time;
            END IF;
        END IF;
        

        v_plus_day := TO_NUMBER(SUBSTR(v_close_time, 1, 2));  -- 마감시간의 첫2자리는 확장 일수

        -- Line Worker 부서원 일자별
        IF (NVL(p_screen_type, 'DEFAULT') = 'LW_ORG_DATE') THEN
            v_plan_tbl   := lgvatt_common_pkg.get_input_date_lw(p_subsidiary_code, TRUNC(p_today), p_shift_type_code, 'PLAN');
            v_result_tbl := lgvatt_common_pkg.get_input_date_lw(p_subsidiary_code, TRUNC(p_today), p_shift_type_code, 'RESULT');

            v_valid_flag := FALSE;
            FOR dd IN v_plan_tbl.FIRST..v_plan_tbl.LAST
            LOOP
                IF (v_time_and_attendance_date = v_plan_tbl(dd).time_and_attendance_date) THEN
                    v_valid_flag := TRUE;
                END IF;
            END LOOP;

            IF (NOT v_valid_flag AND v_result_tbl.COUNT > 1) THEN
                FOR dd IN v_result_tbl.FIRST..v_result_tbl.LAST
                LOOP
                    IF (v_time_and_attendance_date = v_result_tbl(dd).time_and_attendance_date) THEN
                        v_valid_flag := TRUE;
                    END IF;
                END LOOP;
            END IF;     
            
            IF (v_valid_flag) THEN
                v_close_date := TO_DATE(TO_CHAR(TRUNC(p_today) + v_plus_day, 'YYYYMMDD')          -- 오늘일자 + 마감시간 확장
                             || ' '
                             || SUBSTR(v_close_time, 3, 4) || '00', 'YYYYMMDD HH24MISS');  -- 마감시간
            ELSE
                IF (v_time_and_attendance_date <= TRUNC(p_today)) THEN
                    v_close_date := TO_DATE(TO_CHAR(v_time_and_attendance_date + v_plus_day, 'YYYYMMDD')  -- 근태일자 + 마감시간 확장
                                 || ' '
                                 || SUBSTR(v_close_time, 3, 4) || '00', 'YYYYMMDD HH24MISS');             -- 마감시간
                ELSE
                    v_close_date := TO_DATE(TO_CHAR(lgvhr_common_pkg.start_of_time, 'YYYYMMDD') || ' 00:00:01', 'YYYYMMDD HH24:MI:SS');  -- 입력불가한 미래일자를 선택시에는 안되도록 시간제한
                END IF;
            END IF;
        ELSE
            v_close_date := TO_DATE(TO_CHAR(v_time_and_attendance_date + v_plus_day, 'YYYYMMDD')  -- 근태일자 + 마감시간 확장
                         || ' '
                         || SUBSTR(v_close_time, 3, 4) || '00', 'YYYYMMDD HH24MISS');             -- 마감시간
        END IF;

    END IF;

    RETURN v_close_date;

EXCEPTION
WHEN OTHERS THEN

    IF ('Y' = lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'CLOSE_TIME_ERROR_INPUT_FLAG', 'A1')) THEN  -- -- 마감시간오류시 입력가능 여부
        RETURN TO_DATE(TO_CHAR(lgvhr_common_pkg.end_of_time, 'YYYYMMDD') || ' 23:59:59', 'YYYYMMDD HH24:MI:SS');  -- 오류일때 입력가능이면, 시간풀어줌
    ELSE
        RETURN TO_DATE(TO_CHAR(lgvhr_common_pkg.start_of_time, 'YYYYMMDD') || ' 00:00:01', 'YYYYMMDD HH24:MI:SS');  -- 오류일때 입력불가이면, 시간제한함
    END IF;

END get_att_close_time;


/*************************************************************************************************/
/* Program Name : get_idcard_inout_time                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태일자에 해당하는 입출시간을 Return한다.                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_inout_type                      in    varchar2  입출유형(IN/OUT)             */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_idcard_inout_time (p_subsidiary_code          IN  VARCHAR2
                               ,p_employee_no              IN  VARCHAR2
                               ,p_time_and_attendance_date IN  DATE
                               ,p_inout_type               IN  VARCHAR2
                               )
RETURN DATE
IS
    v_check_inout_date         DATE;
BEGIN

    SELECT DECODE(p_inout_type, 'IN', check_in_date, 'OUT', check_out_date, NULL)
    INTO   v_check_inout_date
    FROM   tb_att_idcard_acs_time_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    employee_no              = p_employee_no
    AND    time_and_attendance_date = p_time_and_attendance_date
    ;

    RETURN v_check_inout_date;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_idcard_inout_time;

/*************************************************************************************************/
/* Program Name : get_shift_inout_time                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Get In Out time of shift type.                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_shift_type                      in    varchar2  Shif type  
/*                p_employee_no                     in    varchar2  사원번호                    */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_inout_type                      in    varchar2  입출유형(IN/OUT)             */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/03/15  HMT_20210315  Get In Out time of shift type                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_shift_inout_time (p_subsidiary_code           IN  VARCHAR2
                               ,p_shift_type               IN  VARCHAR2
                               ,p_employee_no              IN  VARCHAR2
                               ,p_time_and_attendance_date IN  DATE
                               ,p_inout_type               IN  VARCHAR2
                               )
RETURN DATE
IS
    v_check_inout_date         DATE;
    v_out_time_param           NUMBER:= 10/24;
BEGIN
    
    IF p_inout_type = 'IN' THEN
      SELECT TO_DATE(TO_CHAR(t.time_and_attendance_date, 'YYYYMMDD')||t.work_start_time, 'YYYYMMDDHH24:MI')
      INTO   v_check_inout_date
        FROM tb_att_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.time_and_attendance_date = p_time_and_attendance_date
         AND t.shift_type_code = p_shift_type
         AND t.employee_no = p_employee_no;
    END IF;
    
    IF p_inout_type = 'OUT' THEN
      IF p_time_and_attendance_date < TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD') THEN
        v_out_time_param := 9/24;
      END IF;
      IF p_shift_type = '1A' THEN
        SELECT DECODE (T.A_DAY_OF_THE_WEEK_CODE,'FRI',TO_DATE(TO_CHAR(t.time_and_attendance_date, 'YYYYMMDD')||t.work_start_time, 'YYYYMMDDHH24:MI') + 9/24,
                                          TO_DATE(TO_CHAR(t.time_and_attendance_date, 'YYYYMMDD')||t.work_start_time, 'YYYYMMDDHH24:MI') + v_out_time_param)
      INTO   v_check_inout_date
        FROM tb_att_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.time_and_attendance_date = p_time_and_attendance_date
         AND t.shift_type_code = p_shift_type
         AND t.employee_no = p_employee_no;
        ELSE 
          SELECT TO_DATE(TO_CHAR(t.time_and_attendance_date, 'YYYYMMDD')||t.work_start_time, 'YYYYMMDDHH24:MI') + 12/24
            INTO   v_check_inout_date
              FROM tb_att_result_n t
             WHERE t.subsidiary_code = p_subsidiary_code
               AND t.time_and_attendance_date = p_time_and_attendance_date
               AND t.shift_type_code = p_shift_type
               AND t.employee_no = p_employee_no;
          END IF;
    END IF;

    RETURN v_check_inout_date;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_shift_inout_time;


/*************************************************************************************************/
/* Program Name : get_idcard_inout_time                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 기능직 Unit 부서의 대표사번을  가져온다                                        */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_organization_id                 in    NUMBER   조직아이디                    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_unit_requestor (p_subsidiary_code          IN  VARCHAR2
                            ,p_organization_id          IN  VARCHAR2
                            )
RETURN VARCHAR2
IS  
     /* 기존로직
     SELECT em.employee_number
    INTO   v_employee_number
    FROM   emp_master em
    WHERE  subsidiary_code    = p_subsidiary_code
    AND    em.organization_id = p_organization_id
    AND    em.status          = 'Active Assignment'
    AND    em.position       IS NULL
    AND    ROWNUM             = 1
    ;
    */
    
    v_employee_number VARCHAR2(20);
    v_manager_emp_no  VARCHAR2(30);
    
    v_chk_sup_no      NUMBER :=0; 
    v_chk_same_sup    NUMBER :=0;

BEGIN

      SELECT om.org_manager_number
      INTO   v_manager_emp_no
      FROM   org_master om
      WHERE  om.organization_id = p_organization_id;
        
   IF nvl(v_manager_emp_no, 'X') != 'X' THEN

      SELECT nvl(count(em.employee_number),0)
      INTO   v_chk_same_sup
      FROM   emp_master em
      WHERE  subsidiary_code    = p_subsidiary_code
      AND    em.organization_id = p_organization_id
      AND    em.status          = 'Active Assignment'
      AND    em.supervisor      = v_manager_emp_no
      AND    em.position       IS NULL
      ;
   
      IF v_chk_same_sup > 0 THEN
        
          SELECT em.employee_number
          INTO   v_employee_number
          FROM   emp_master em
          WHERE  subsidiary_code    = p_subsidiary_code
          AND    em.organization_id = p_organization_id
          AND    em.status          = 'Active Assignment'
          AND    em.supervisor      = v_manager_emp_no
          AND    em.position       IS NULL
          AND    ROWNUM             = 1;
        
      END IF;

   ELSE 
      SELECT nvl(COUNT(DISTINCT em.supervisor),0)
      INTO   v_chk_sup_no
      FROM   emp_master em
      WHERE  subsidiary_code    = p_subsidiary_code
      AND    em.organization_id = p_organization_id
      AND    em.status          = 'Active Assignment'
      AND    em.assignment_category  = 'LGD_LW'
      AND    em.position       IS NULL;

      IF v_chk_sup_no = 1 THEN 
        SELECT em.employee_number
        INTO   v_employee_number
        FROM   emp_master em
        WHERE  subsidiary_code    = p_subsidiary_code
        AND    em.organization_id = p_organization_id
        AND    em.status          = 'Active Assignment'
        AND    em.assignment_category  = 'LGD_LW'
        AND    em.position       IS NULL
        AND    ROWNUM             = 1;
      
      END IF;  
      

   END IF;

   IF nvl(v_employee_number, 'X') = 'X' THEN
      SELECT em.employee_number
      INTO   v_employee_number
      FROM   emp_master em
      WHERE  subsidiary_code    = p_subsidiary_code
      AND    em.organization_id = p_organization_id
      AND    em.status          = 'Active Assignment'
      AND    ROWNUM             = 1
      ; 
   END IF;    


   RETURN v_employee_number;
  
  
EXCEPTION
    WHEN OTHERS THEN
        
        RETURN NULL;

END get_unit_requestor;


/*************************************************************************************************/
/* Program Name : get_att_contract_info                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 조직에 해당하는 PIC 정보를 Return한다.                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_organization_id                 in    varchar2  조직ID                       */
/*                p_type                            in    varchar2  유형                         */
/*                p_seq                             in    varchar2  PIC순서                      */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_contract_info (p_subsidiary_code IN  VARCHAR2
                               ,p_organization_id IN  VARCHAR2
                               ,p_type            IN  VARCHAR2 DEFAULT 'EMP_NO'
                               ,p_seq             IN  NUMBER   DEFAULT 1
                               )
RETURN VARCHAR2
IS
    ac_rec  tb_att_contract_n%ROWTYPE;
    em_rec  emp_master%ROWTYPE;
BEGIN

    BEGIN
        SELECT *
        INTO   ac_rec
        FROM   tb_att_contract_n ac
        WHERE  ac.subsidiary_code = p_subsidiary_code
        AND    ac.organization_id = p_organization_id
        ;
    EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        -- 여러명일때는 해당하는 번째의 담당자 : 1(디폴트) 첫번째, 99 : 마지막, p_seq 보다 적으면 마지막
        FOR pic IN (SELECT *
                    FROM   tb_att_contract_n ac
                    WHERE  ac.subsidiary_code = p_subsidiary_code
                    AND    ac.organization_id = p_organization_id
                   )
        LOOP
            ac_rec := pic;

            IF (SQL%ROWCOUNT >= NVL(p_seq, 1)) THEN
                EXIT;  
            END IF;
        END LOOP;
    WHEN OTHERS THEN
       RETURN NULL;
    END;

    -- 부서 근태담당자(PIC) 사번
    IF (NVL(p_type, 'EMP_NO') = 'EMP_NO') THEN
        RETURN ac_rec.time_attend_contact_user_id;
    END IF;

    -- 부서 근태담당자(PIC) 사번
    IF (p_type = 'EMP_NO_NAME') THEN
        em_rec := lgvhr_common_pkg.get_emp_master_rec (p_subsidiary_code, ac_rec.time_attend_contact_user_id);
        
        RETURN em_rec.full_name_local || ' (' || ac_rec.time_attend_contact_user_id || ')';
    END IF;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;

END get_att_contract_info;


/*************************************************************************************************/
/* Program Name : get_last_assignment_type_2nd                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 발령일자 및 발령유형에 해당하는 지난 최종 발령의 2차발령 정보를 Return한다.    */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_assignment_date                 in    date      발령일자                     */
/*                p_assignment_type_1st             in    varchar2  1차발령유형                  */
/*                p_type                            in    varchar2  유형                         */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/02/07  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_last_assignment_type_2nd (p_subsidiary_code     IN  VARCHAR2
                                      ,p_employee_no         IN  VARCHAR2
                                      ,p_assignment_date     IN  DATE
                                      ,p_assignment_type_1st IN  VARCHAR2
                                      ,p_type                IN  VARCHAR2
                                      )
RETURN VARCHAR2
IS
BEGIN
    FOR asg IN (SELECT *
                FROM   emp_assig
                WHERE  subsidiary_code       = p_subsidiary_code
                AND    employee_number       = p_employee_no
                AND    assignment_start_date < p_assignment_date
                ORDER BY assignment_start_date DESC
               )
    LOOP
        IF (asg.assignment_type_1st <> p_assignment_type_1st) THEN
            RETURN NULL;
        END IF;
            
        IF (asg.assignment_type_2nd IS NOT NULL) THEN
            IF (p_type = 'TYPE') THEN
                RETURN asg.assignment_type_2nd;

            ELSIF (p_type = 'REASON') THEN
                RETURN asg.attribute13;

            ELSE
                RETURN NULL;
            END IF;
        END IF;
    END LOOP;

    RETURN NULL;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;
END get_last_assignment_type_2nd;


/*************************************************************************************************/
/* Program Name : get_att_result_code_use_days                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태실적에서 사용된 코드에 대한 일수를 Return한다.                             */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_from_time_attendance_date       in    date      시작근태일자                 */
/*                p_to_time_attendance_date         in    date      종료근태일자                 */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*                p_time_attend_detail_code         in    varchar2  근태상세코드                 */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/02/13  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_result_code_use_days (p_subsidiary_code             IN  VARCHAR2
                                      ,p_employee_no                 IN  VARCHAR2
                                      ,p_from_time_attendance_date   IN  DATE
                                      ,p_to_time_attendance_date     IN  DATE     DEFAULT NULL
                                      ,p_time_and_attendance_code    IN  VARCHAR2
                                      ,p_time_attend_detail_code     IN  VARCHAR2 DEFAULT NULL
                                      )
RETURN NUMBER
IS
    v_attendance_days                 NUMBER;
    v_paid_days                       NUMBER;
    v_unpaid_days                     NUMBER;
    v_use_cnt                         NUMBER;
BEGIN

    SELECT NVL(SUM(ac.attendance_days), 0) AS attendance_days, 
           NVL(SUM(ac.paid_days), 0)       AS paid_days, 
           NVL(SUM(ac.unpaid_days), 0)     AS unpaid_days,
           COUNT(*)                        AS use_cnt
    INTO   v_attendance_days, v_paid_days, v_unpaid_days, v_use_cnt
    FROM   tb_att_result_n ar,
           tb_att_code_c   ac
    WHERE  ar.subsidiary_code            = p_subsidiary_code
    AND    ar.employee_no                = p_employee_no
    AND    ar.time_and_attendance_date   BETWEEN p_from_time_attendance_date AND NVL(p_to_time_attendance_date, p_from_time_attendance_date)
    AND    ar.time_and_attendance_code   = p_time_and_attendance_code
    AND    NVL(ar.time_attend_detail_code, 'NULL') = NVL(p_time_attend_detail_code, NVL(ar.time_attend_detail_code, 'NULL'))
    AND    ar.subsidiary_code            = ac.subsidiary_code
    AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
    ;
    
    -- 사용된 일수. 단, WH 와 같이 모두 0일때는 갯수
    RETURN GREATEST((v_attendance_days + v_paid_days + v_unpaid_days), v_use_cnt);

EXCEPTION
WHEN OTHERS THEN
    RETURN 0;

END get_att_result_code_use_days;


/*************************************************************************************************/
/* Program Name : get_att_result_code_use_days                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태실적에서 사용된 코드에 대한 일수를 Return한다.                             */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_from_time_attendance_yyyymm     in    varchar2  시작근태년월(YYYYMM)         */
/*                p_to_time_attendance_yyyymm       in    varchar2  종료근태년월(YYYYMM)         */
/*                p_time_and_attendance_code        in    varchar2  근태코드                     */
/*                p_time_attend_detail_code         in    varchar2  근태상세코드                 */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/02/13  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION get_att_result_code_use_days (p_subsidiary_code             IN  VARCHAR2
                                      ,p_employee_no                 IN  VARCHAR2
                                      ,p_from_time_attendance_yyyymm IN  VARCHAR2
                                      ,p_to_time_attendance_yyyymm   IN  VARCHAR2 DEFAULT NULL
                                      ,p_time_and_attendance_code    IN  VARCHAR2
                                      ,p_time_attend_detail_code     IN  VARCHAR2 DEFAULT NULL
                                      )
RETURN NUMBER
IS
BEGIN

    RETURN
        get_att_result_code_use_days (p_subsidiary_code           => p_subsidiary_code
                                     ,p_employee_no               => p_employee_no
                                     ,p_from_time_attendance_date => TO_DATE(p_from_time_attendance_yyyymm, 'YYYYMM')  -- 1일
                                     ,p_to_time_attendance_date   => LAST_DAY(TO_DATE(NVL(p_to_time_attendance_yyyymm, p_from_time_attendance_yyyymm), 'YYYYMM'))  -- 말일
                                     ,p_time_and_attendance_code  => p_time_and_attendance_code
                                     ,p_time_attend_detail_code   => p_time_attend_detail_code
                                     );
EXCEPTION
WHEN OTHERS THEN
    RETURN 0;

END get_att_result_code_use_days;


END lgvatt_common_pkg;
/
