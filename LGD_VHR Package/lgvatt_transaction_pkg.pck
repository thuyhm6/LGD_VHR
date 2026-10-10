CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_transaction_pkg
IS

PROCEDURE apply_att_result_approval (p_ret_code                 OUT NUMBER
                                    ,p_ret_msg                  OUT VARCHAR2
                                    ,p_user_id                  IN  VARCHAR2
                                    ,p_subsidiary_code          IN  VARCHAR2
                                    ,p_employee_no              IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_result_plan_type         IN  VARCHAR2
                                    ,p_approval_type            IN  VARCHAR2 DEFAULT 'REJECT'
                                    );


PROCEDURE apply_att_update_req_approval (p_ret_code                     OUT NUMBER
                                        ,p_ret_msg                      OUT VARCHAR2
                                        ,p_user_id                      IN  VARCHAR2
                                        ,p_subsidiary_code              IN  VARCHAR2
                                        ,p_approval_request_id          IN  NUMBER
                                        ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                        );
                                        

PROCEDURE apply_att_lt_ta_plan_approval (p_ret_code                     OUT NUMBER
                                        ,p_ret_msg                      OUT VARCHAR2
                                        ,p_user_id                      IN  VARCHAR2
                                        ,p_subsidiary_code              IN  VARCHAR2
                                        ,p_planning_id                  IN  NUMBER
                                        ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                        );
--2021/07/03  HMS Start                                        
PROCEDURE apply_att_swap_wh_approval (p_ret_code                     OUT NUMBER
                                     ,p_ret_msg                      OUT VARCHAR2
                                     ,p_user_id                      IN  VARCHAR2
                                     ,p_subsidiary_code              IN  VARCHAR2
                                     ,p_approval_request_id          IN  NUMBER
                                     ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                     );
                                     
PROCEDURE apply_att_swap_wh_master (p_ret_code                     OUT NUMBER
                                   ,p_ret_msg                      OUT VARCHAR2
                                   ,p_user_id                      IN  VARCHAR2
                                   ,p_subsidiary_code              IN  VARCHAR2
                                   ,p_weekly_holiday               IN  DATE
                                   ,p_working_day                  IN  DATE
                                   ,p_employee_no                  IN  VARCHAR2
                                   ,p_swap_type                    IN  VARCHAR2
                                    );
--2021/07/03  HMS End
                                        
PROCEDURE apply_att_residual_ann_lv (p_ret_code                   OUT NUMBER
                                    ,p_ret_msg                    OUT VARCHAR2
                                    ,p_user_id                    IN  VARCHAR2
                                    ,p_subsidiary_code            IN  VARCHAR2
                                    ,p_employee_no                IN  VARCHAR2
                                    ,p_time_and_attendance_yyyymm IN  VARCHAR2
                                    ,p_curr_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                    ,p_next_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                    );


PROCEDURE apply_att_use_res_ann_lv (p_ret_code                   OUT NUMBER
                                   ,p_ret_msg                    OUT VARCHAR2
                                   ,p_user_id                    IN  VARCHAR2
                                   ,p_subsidiary_code            IN  VARCHAR2
                                   ,p_employee_no                IN  VARCHAR2
                                   ,p_time_and_attendance_yyyymm IN  VARCHAR2
                                   ,p_curr_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                   ,p_next_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                   );


PROCEDURE apply_att_result_ot_calc (p_ret_code                    OUT VARCHAR2
                                   ,p_ret_msg                     OUT VARCHAR2
                                   ,p_user_id                     IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code             IN  VARCHAR2 DEFAULT NULL
                                   ,p_base_time_attend_apply_flag IN  VARCHAR2 DEFAULT 'Y'
                                   ,p_employee_no                 IN  VARCHAR2 DEFAULT NULL
                                   );
                                   
                                   
PROCEDURE send_att_modified_alert (p_ret_code                   OUT NUMBER
                                  ,p_ret_msg                    OUT VARCHAR2
                                  ,p_user_id                    IN  VARCHAR2
                                  ,p_subsidiary_code            IN  VARCHAR2
                                  ,p_employee_no                IN  VARCHAR2
                                  ,p_time_and_attendance_date   IN  DATE
                                  ,p_result_plan_type           IN  VARCHAR2
                                  ,p_lang_code                  IN  VARCHAR2 DEFAULT 'en'
                                  );
                                   
                                   
FUNCTION apply_att_code_record (p_ac_rec    IN tb_att_code_c%ROWTYPE
                               ,p_work_type IN VARCHAR2 DEFAULT NULL
                               )
RETURN VARCHAR2;


FUNCTION apply_att_calendar_record (p_ac_rec    IN tb_att_calendar_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2;


FUNCTION apply_att_close_record (p_ac_rec    IN tb_att_close_n%ROWTYPE
                                ,p_work_type IN VARCHAR2 DEFAULT NULL
                                )
RETURN VARCHAR2;


FUNCTION apply_att_base_bas_record (p_ab_rec    IN tb_att_base_bas_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2;


FUNCTION apply_att_plan_record (p_ap_rec    IN tb_att_plan_n%ROWTYPE
                               ,p_work_type IN VARCHAR2 DEFAULT NULL
                               )
RETURN VARCHAR2;


FUNCTION apply_att_result_record (p_ar_rec    IN tb_att_result_n%ROWTYPE
                                 ,p_work_type IN VARCHAR2 DEFAULT NULL
                                 )
RETURN VARCHAR2;


FUNCTION apply_att_result_hist_record (p_ar_rec    IN tb_att_result_n%ROWTYPE
                                      ,p_work_type IN VARCHAR2 DEFAULT NULL
                                      )
RETURN VARCHAR2;


FUNCTION apply_att_update_req_record (p_aur_rec   IN tb_att_update_req_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2;


FUNCTION apply_att_lt_ta_plan_record (p_altp_rec    IN tb_att_lt_time_attend_plan_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2;


FUNCTION apply_att_annual_leave_record (p_aal_rec    IN tb_att_annual_leave_n%ROWTYPE
                                       ,p_work_type IN VARCHAR2 DEFAULT NULL
                                       )
RETURN VARCHAR2;


FUNCTION apply_att_idcard_acs_record (p_iat_rec   IN tb_att_idcard_acs_time_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2;


FUNCTION apply_att_contract_record (p_ac_rec    IN tb_att_contract_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2;


FUNCTION apply_att_holiday_info_record (p_hi_rec    IN tb_att_holiday_info_n%ROWTYPE
                                       ,p_work_type IN VARCHAR2 DEFAULT NULL
                                       )
RETURN VARCHAR2;


PROCEDURE valid_att_annual_leave_proc (p_ret_code                      OUT NUMBER
                                      ,p_ret_msg                       OUT VARCHAR2
                                      ,p_user_id                       IN  VARCHAR2
                                      ,p_att_type                      IN  VARCHAR2
                                      ,p_subsidiary_code               IN  VARCHAR2
                                      ,p_employee_no                   IN  VARCHAR2 DEFAULT NULL     -- 사원번호
                                      ,p_lang_code                     IN  VARCHAR2 DEFAULT 'en'
                                      ,p_time_and_attendance_date      IN  DATE     DEFAULT NULL     -- Plan 기준일자
                                      ,p_request_no                    IN  VARCHAR2 DEFAULT NULL     -- 수정요청서 번호
                                      ,p_emp_cat                       IN  VARCHAR2 DEFAULT NULL     -- 발령범주
                                      ,p_new_result_attendance_code    IN  VARCHAR2 DEFAULT NULL     -- 신규실적근태코드(화면에서 입력된 값)
                                      ,p_new_plan_attendance_code      IN  VARCHAR2 DEFAULT NULL     -- 신규계획 근태코드(화면에서 입력된 값)
                                      );

END lgvatt_transaction_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_transaction_pkg
IS

/*************************************************************************************************/
/* Program Name : apply_att_result_approval                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태실적 결재요청을 처리후 결과를 Return 한다                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_result_plan_type                in    varchar2  실적계획유형(RESULT/PLAN)    */
/*                p_approval_type                   in    varchar2  결재유형(REJECT/APPROVAL)    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/23  박귀희B     근태코드 = NW 일때, 상세코드 = NW_NRM 처리                            */
/* 2021/07/17  HMT_20210717          Swap weekly holiday (Add p_employee_no)                   */
/*************************************************************************************************/
PROCEDURE apply_att_result_approval (p_ret_code                 OUT NUMBER
                                    ,p_ret_msg                  OUT VARCHAR2
                                    ,p_user_id                  IN  VARCHAR2
                                    ,p_subsidiary_code          IN  VARCHAR2
                                    ,p_employee_no              IN  VARCHAR2
                                    ,p_time_and_attendance_date IN  DATE
                                    ,p_result_plan_type         IN  VARCHAR2
                                    ,p_approval_type            IN  VARCHAR2 DEFAULT 'REJECT'
                                    )
IS
    v_time_and_attendance_date    tb_att_plan_n.time_and_attendance_date%TYPE;
    v_ot_calc_status              VARCHAR2(100);

    ab_rec                        tb_att_base_bas_n%ROWTYPE;
    ap_rec                        tb_att_plan_n%ROWTYPE;
    ar_rec                        tb_att_result_n%ROWTYPE;
    
    v_apply_result_flag           VARCHAR2(30);
BEGIN

    v_time_and_attendance_date := p_time_and_attendance_date;

    -- 승인
    IF (NVL(p_approval_type, 'REJECT') = 'APPROVAL') THEN
    
        NULL;  -- 현재는 BizWeb 에서 처리

    -- 반려
    ELSE
    
        -- 계획
        IF (p_result_plan_type = 'PLAN') THEN

            -- 반려대상 근태계획 정보
            ap_rec := lgvatt_common_pkg.get_att_plan_rec(p_subsidiary_code, p_employee_no, v_time_and_attendance_date);

            -- 근태일자 및 부제유형코드에 해당하는 근태기본 정보
            ab_rec := lgvatt_common_pkg.get_att_base_bas_rec(p_subsidiary_code, v_time_and_attendance_date, ap_rec.shift_type_code);
        
            ap_rec.time_and_attendance_code       := ab_rec.time_and_attendance_code;
            ap_rec.time_attend_detail_code        := CASE WHEN ab_rec.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END;  -- 근태상세코드 : 2018.01.23 박귀희 : 근태코드 = NW 일때, 상세코드 = NW_NRM
            ap_rec.night_shift_flag               := ab_rec.night_shift_flag;
            ap_rec.evening_meal_flag              := 'N';
            ap_rec.overtime_sum_hours             := ab_rec.overtime_hours;
            ap_rec.base_time_attend_apply_flag    := 'Y';  -- 기본근태여부
            ap_rec.last_update_user_id            := p_user_id;
            ap_rec.last_update_date               := SYSDATE;

            -- 근태기본 정보로 근태계획 원복
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_plan_record(ap_rec, 'UPDATE');

        -- 실적
        ELSIF (p_result_plan_type = 'RESULT') THEN
    
            -- 반려대상 근태실적 정보
            ar_rec := lgvatt_common_pkg.get_att_result_rec(p_subsidiary_code, p_employee_no, v_time_and_attendance_date);

            -- 현재 일근태 실적 백업            
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_hist_record (ar_rec, 'REJECT');

            -- 근태일자 및 부제유형코드에 해당하는 근태기본 정보
            ab_rec := lgvatt_common_pkg.get_att_base_bas_rec(p_subsidiary_code, v_time_and_attendance_date, ar_rec.shift_type_code);
            
            ar_rec.time_and_attendance_code       := ab_rec.time_and_attendance_code;
            ar_rec.time_attend_detail_code        := CASE WHEN ab_rec.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END;  -- 근태상세코드 : 2018.01.23 박귀희 : 근태코드 = NW 일때, 상세코드 = NW_NRM
            ar_rec.work_hours                     := lgvatt_common_pkg.get_work_hours(p_subsidiary_code, p_employee_no, v_time_and_attendance_date);
            ar_rec.work_start_time                := ab_rec.attendance_time;
            ar_rec.night_shift_flag               := ab_rec.night_shift_flag;
            ar_rec.evening_meal_flag              := 'N';
            ar_rec.overtime_sum_hours             := ab_rec.overtime_hours;
            ar_rec.weekday_overtime_hours         := 0;
            ar_rec.holiday_overtime_hours         := 0;
            ar_rec.public_holiday_overtime_hours  := 0;
            ar_rec.weekday_night_overtime_hours   := 0;
            ar_rec.weekday_ot_af_night_work_hours := 0;
            ar_rec.holiday_night_overtime_hours   := 0;
            ar_rec.public_holiday_night_ot_hours  := 0;
            ar_rec.normal_night_overtime_hours    := 0;
            ar_rec.tardy_hours                    := 0;
            ar_rec.early_leave_hours              := 0;
            ar_rec.going_out_hours                := 0;
            ar_rec.special_bonus_hours            := 0;
            ar_rec.helpcall_support_hours         := 0;
            ar_rec.base_time_attend_apply_flag    := 'Y';  -- 기본근태여부
            ar_rec.last_update_user_id            := p_user_id;
            ar_rec.last_update_date               := SYSDATE;

            IF (NVL(ab_rec.overtime_hours, 0) != 0) THEN
                lgvatt_ot_calculation_pkg.calculate_ot (p_subsidiary_code    => p_subsidiary_code
                                                       ,p_employee_no        => ar_rec.employee_no --HMT_20210717
                                                       ,p_date               => v_time_and_attendance_date
                                                       ,p_att_code           => ar_rec.time_and_attendance_code
                                                       ,p_shift_code         => ar_rec.shift_type_code
                                                       ,p_night_flag         => ab_rec.night_shift_flag
                                                       ,p_dinner_check       => 'N'
                                                       ,p_working_start_time => ab_rec.attendance_time
                                                       ,p_ot                 => ab_rec.overtime_hours
                                                       ,p_ot150              => ar_rec.weekday_overtime_hours
                                                       ,p_ot200              => ar_rec.holiday_overtime_hours
                                                       ,p_ot300              => ar_rec.public_holiday_overtime_hours
                                                       ,p_nt200              => ar_rec.weekday_night_overtime_hours
                                                       ,p_nt210              => ar_rec.weekday_ot_af_night_work_hours
                                                       ,p_nt270              => ar_rec.holiday_night_overtime_hours
                                                       ,p_nt390              => ar_rec.public_holiday_night_ot_hours
                                                       ,p_nt30               => ar_rec.normal_night_overtime_hours
                                                       ,p_status             => v_ot_calc_status
                                                       );
            END IF;

            -- 근태기본 정보로 근태실적 원복
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_record(ar_rec, 'UPDATE');
        
        ELSE
            
            p_ret_code := 1;
            p_ret_msg  := 'Error : p_result_plan_type = ' || p_result_plan_type;

        END IF;

    END IF;

    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_result_approval;


/*************************************************************************************************/
/* Program Name : apply_att_update_req_approval                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 수정요청서 결재요청을 처리후 결과를 Return 한다                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_approval_request_id             in    number    승인요청ID                   */
/*                p_approval_type                   in    varchar2  결재유형(REJECT/APPROVAL)    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/25  박귀희B     수정요청서 승인이면, 실적의 요청상태도 반영                           */
/*                         결재자의 결재화면에서, 해당건은 Requested 의 승인된 건으로 리스트 됨  */
/*************************************************************************************************/
PROCEDURE apply_att_update_req_approval (p_ret_code                     OUT NUMBER
                                        ,p_ret_msg                      OUT VARCHAR2
                                        ,p_user_id                      IN  VARCHAR2
                                        ,p_subsidiary_code              IN  VARCHAR2
                                        ,p_approval_request_id          IN  NUMBER
                                        ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                        )
IS
BEGIN

    FOR aur IN (SELECT *
                FROM   tb_att_update_req_n
                WHERE  approval_request_id    = p_approval_request_id
                AND    subsidiary_code        = p_subsidiary_code
                AND    data_old_new_type_code = DECODE(NVL(p_approval_type, 'APPROVAL'), 'REJECT', 'OLD', 'NEW')  -- NEW/OLD
                ORDER BY request_seq_no
               )
    LOOP
        -- 반려
        IF (NVL(p_approval_type, 'APPROVAL') = 'REJECT') THEN
        
            NULL;  -- 현재는 BizWeb 에서 처리

        -- 승인
        ELSE
        
            BEGIN
                -- 수정요청서의 근태로 근태실적 반영
                UPDATE tb_att_result_n
                SET    shift_type_code                = aur.shift_type_code
                      ,time_and_attendance_code       = aur.time_and_attendance_code
                      ,work_hours                     = aur.work_hours
                      ,work_start_time                = aur.work_start_time
                      ,night_shift_flag               = aur.night_shift_flag
                      ,evening_meal_flag              = aur.evening_meal_flag
                      ,overtime_sum_hours             = aur.overtime_sum_hours
                      ,weekday_overtime_hours         = aur.weekday_overtime_hours
                      ,holiday_overtime_hours         = aur.holiday_overtime_hours
                      ,public_holiday_overtime_hours  = aur.public_holiday_overtime_hours
                      ,weekday_night_overtime_hours   = aur.weekday_night_overtime_hours
                      ,weekday_ot_af_night_work_hours = aur.weekday_ot_af_night_work_hours
                      ,holiday_night_overtime_hours   = aur.holiday_night_overtime_hours
                      ,public_holiday_night_ot_hours  = aur.public_holiday_night_ot_hours
                      ,normal_night_overtime_hours    = aur.normal_night_overtime_hours
                      ,tardy_hours                    = aur.tardy_hours
                      ,early_leave_hours              = aur.early_leave_hours
                      ,going_out_hours                = aur.going_out_hours
                      ,special_bonus_hours            = aur.special_bonus_hours
                      ,helpcall_support_hours         = aur.helpcall_support_hours
                      ,time_attend_detail_code        = aur.time_attend_detail_code
                      ,time_attend_input_reason_desc  = aur.time_attend_input_reason_desc
                      ,base_time_attend_apply_flag    = 'N'  -- 기본근태여부
                      ,approval_request_id            = aur.approval_request_id    -- 2018.01.25 박귀희 : 수정요청서 승인이면, 실적의 요청상태도 반영
                      ,request_code                   = aur.request_code           -- 2018.01.25 박귀희 : 수정요청서 승인이면, 실적의 요청상태도 반영
                      ,progress_status_code           = aur.progress_status_code   -- 2018.01.25 박귀희 : 수정요청서 승인이면, 실적의 요청상태도 반영
                      ,last_update_user_id            = p_user_id
                      ,last_update_date               = SYSDATE
                WHERE  subsidiary_code          = aur.subsidiary_code
                AND    time_and_attendance_date = aur.time_and_attendance_date
                AND    employee_no              = aur.employee_no
                ;
            EXCEPTION
            WHEN OTHERS THEN
                -- 에러처리 필요시 추가
                NULL;
            END;

        END IF;

    END LOOP;

    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_update_req_approval;


/*************************************************************************************************/
/* Program Name : apply_att_lt_ta_plan_approval                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 장기근태계획 결재요청을 처리후 결과를 Return 한다                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_planning_id                     in    number    계획ID                       */
/*                p_approval_type                   in    varchar2  결재유형(REJECT/APPROVAL)    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/23  박귀희B     근태코드 = NW 일때, 상세코드 = NW_NRM 처리                            */
/*************************************************************************************************/
PROCEDURE apply_att_lt_ta_plan_approval (p_ret_code                     OUT NUMBER
                                        ,p_ret_msg                      OUT VARCHAR2
                                        ,p_user_id                      IN  VARCHAR2
                                        ,p_subsidiary_code              IN  VARCHAR2
                                        ,p_planning_id                  IN  NUMBER
                                        ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                        )
IS
    v_plan_start_date                   DATE;
BEGIN

    FOR alt IN (SELECT *
                FROM   tb_att_lt_time_attend_plan_n
                WHERE  planning_id            = p_planning_id
                AND    subsidiary_code        = p_subsidiary_code
               )
    LOOP
        -- 반려
        IF (NVL(p_approval_type, 'APPROVAL') = 'REJECT') THEN
        
            NULL;  -- 현재는 BizWeb 에서 처리

        -- 승인
        ELSE
        
            -- 계획이므로 오늘(포함)이후만 가능
            v_plan_start_date := GREATEST(TRUNC(SYSDATE), alt.plan_start_date);
        
            FOR dd IN 0..(alt.plan_end_date - v_plan_start_date)
            LOOP
                BEGIN
                    -- 저녁/OT 는 초기화
                    UPDATE tb_att_plan_n
                    SET    time_and_attendance_code    = alt.time_and_attendance_code
                          ,time_attend_detail_code     = CASE WHEN alt.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END  -- 근태상세코드 : 2018.01.23 박귀희 : 근태코드 = NW 일때, 상세코드 = NW_NRM
                          ,evening_meal_flag           = 'N'
                          ,overtime_sum_hours          = 0
                          ,planning_id                 = alt.planning_id
                          ,base_time_attend_apply_flag = 'N'  -- 기본근태여부
                          ,last_update_user_id         = p_user_id
                          ,last_update_date            = SYSDATE
                    WHERE  subsidiary_code          = p_subsidiary_code
                    AND    time_and_attendance_date = v_plan_start_date+dd
                    AND    employee_no              = alt.employee_no
                    AND    time_and_attendance_code IN ( SELECT /*+ push_subq */
                                                                time_and_attendance_code
                                                         FROM   tb_att_code_c
                                                         WHERE  update_enable_flag = 'Y'  -- 휴일/휴직근태등의 사용자가 수정불가한 근태?는 제외하고, 수정가능한 것만
                                                       )
                    ;
                EXCEPTION
                WHEN OTHERS THEN
                    -- 에러처리 필요시 추가
                    NULL;
                END;
            END LOOP;
            
        END IF;

    END LOOP;

    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_lt_ta_plan_approval;


/*************************************************************************************************/
/* Program Name : apply_att_update_req_approval                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 수정요청서 결재요청을 처리후 결과를 Return 한다                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_approval_request_id             in    number    승인요청ID                   */
/*                p_approval_type                   in    varchar2  결재유형(REJECT/APPROVAL)    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/07/03  HMS_20210703     Approval for swap weekly holiday                                           */
/* 2022/02/28  HMT_20220228    No swap if  time_and_attendance_code IN ('NN', 'PH', 'US')   */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_swap_wh_approval (p_ret_code                     OUT NUMBER
                                     ,p_ret_msg                      OUT VARCHAR2
                                     ,p_user_id                      IN  VARCHAR2
                                     ,p_subsidiary_code              IN  VARCHAR2
                                     ,p_approval_request_id          IN  NUMBER
                                     ,p_approval_type                IN  VARCHAR2 DEFAULT 'APPROVAL'
                                     )
IS
    wh_rec                   tb_att_result_n%ROWTYPE;                          
    nw_rec                   tb_att_result_n%ROWTYPE;
    pre_wh_rec               tb_att_result_n%ROWTYPE;                          
    pre_nw_rec               tb_att_result_n%ROWTYPE;
    v_ot150                  NUMBER;
    v_ot200                  NUMBER;
    v_ot300                  NUMBER;
    v_nt200                  NUMBER;
    v_nt210                  NUMBER;
    v_nt270                  NUMBER;
    v_nt390                  NUMBER;
    v_nt30                   NUMBER;
    v_status                 VARCHAR2(100);
    v_shift_type_wh_swap     VARCHAR2(10); --HMT_20220228
    v_shift_type_nw_swap     VARCHAR2(10); --HMT_20220228
    v_shift_type_wh_result   VARCHAR2(10); --HMT_20220228
    v_shift_type_nw_result   VARCHAR2(10); --HMT_20220228
   --Get tb_att_swap_holiday_request_n infor
    CURSOR rq_result IS
    SELECT n.request_seq_no, n.employee_no, n.weekly_holiday, n.working_day, n.weekly_holiday_shift_type_code, n.working_day_shift_type_code
      FROM tb_att_swap_holiday_request_n n
     WHERE n.approval_request_id    = p_approval_request_id
       AND n.subsidiary_code        = p_subsidiary_code
       AND n.confirm_flag <> 'Y';
         
BEGIN

   FOR rq IN rq_result LOOP
     
    wh_rec     := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, rq.employee_no, rq.weekly_holiday);
    nw_rec     := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, rq.employee_no, rq.working_day);
    pre_wh_rec := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, rq.employee_no, rq.weekly_holiday - 1);
    pre_nw_rec := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, rq.employee_no, rq.working_day - 1);
         
        -- 반려
        IF (NVL(p_approval_type, 'APPROVAL') = 'REJECT') THEN
        
            NULL;  -- 현재는 BizWeb 에서 처리

        -- 승인
        ELSE
        --HMT_20220228 Start
        --1A, 21AB, 22AB have the same working schedule so it will be consider as 1 shift code type = Standard Type - Std.
            SELECT DECODE(SUBSTR(rq.weekly_holiday_shift_type_code,1,1),'3',rq.weekly_holiday_shift_type_code,'Std') INTO v_shift_type_wh_swap from dual;
            SELECT DECODE(SUBSTR(wh_rec.shift_type_code,1,1),'3',wh_rec.shift_type_code,'Std')                       INTO v_shift_type_wh_result from dual;
            SELECT DECODE(SUBSTR(rq.working_day_shift_type_code,1,1),'3',rq.working_day_shift_type_code,'Std')       INTO v_shift_type_nw_swap from dual;
            SELECT DECODE(SUBSTR(nw_rec.shift_type_code,1,1),'3',nw_rec.shift_type_code,'Std')                       INTO v_shift_type_nw_result from dual;
          
            IF wh_rec.time_and_attendance_code <> 'WH' OR nw_rec.time_and_attendance_code IN ('NN', 'PH', 'US')
                --If the shift code in swap detail is different from the shift type in current attendance result -> Not allowned to swap
                OR v_shift_type_wh_swap <> v_shift_type_wh_result 
                OR v_shift_type_nw_swap <> v_shift_type_nw_result THEN
                 
                UPDATE tb_att_swap_holiday_request_n sr  
                    SET sr.progress_status_code = '70', 
                        sr.last_update_user_id = p_user_id,
                        sr.last_update_date = sysdate
                WHERE sr.request_seq_no = rq.request_seq_no;
                  
            ELSE
        --HMT_20220228 End
                BEGIN
                --Swap NW and WH
                UPDATE tb_att_result_n
                   SET shift_type_code                = wh_rec.shift_type_code
                      ,time_and_attendance_code       = wh_rec.time_and_attendance_code
                      ,work_hours                     = wh_rec.work_hours
                      ,work_start_time                = wh_rec.work_start_time
                      ,night_shift_flag               = wh_rec.night_shift_flag
                      ,evening_meal_flag              = null
                      ,overtime_sum_hours             = 0
                      ,weekday_overtime_hours         = 0
                      ,holiday_overtime_hours         = 0
                      ,public_holiday_overtime_hours  = 0
                      ,weekday_night_overtime_hours   = 0
                      ,weekday_ot_af_night_work_hours = 0
                      ,holiday_night_overtime_hours   = 0
                      ,public_holiday_night_ot_hours  = 0
                      ,normal_night_overtime_hours    = wh_rec.normal_night_overtime_hours
                      ,tardy_hours                    = null
                      ,early_leave_hours              = null
                      ,going_out_hours                = null
                      ,special_bonus_hours            = null
                      ,helpcall_support_hours         = null
                      ,time_attend_detail_code        = wh_rec.time_attend_detail_code
                      ,time_attend_input_reason_desc  = null
                      ,base_time_attend_apply_flag    = 'N'
                      ,approval_request_id            = null    
                      ,request_code                   = null   
                      ,progress_status_code           = null   
                      ,last_update_user_id            = p_user_id
                      ,last_update_date               = SYSDATE
                WHERE  subsidiary_code          = nw_rec.subsidiary_code
                  AND  time_and_attendance_date = nw_rec.time_and_attendance_date
                  AND  employee_no              = nw_rec.employee_no;
                
                --If the previous date of NW have OT -> re-calculate the OT of previous date
                IF pre_nw_rec.overtime_sum_hours > 0 THEN
                    lgvatt_ot_calculation_pkg.calculate_ot(p_subsidiary_code    => pre_nw_rec.subsidiary_code
                                                      ,p_employee_no        => pre_nw_rec.employee_no
                                                      ,p_date               => pre_nw_rec.time_and_attendance_date
                                                      ,p_att_code           => pre_nw_rec.time_and_attendance_code
                                                      ,p_shift_code         => pre_nw_rec.shift_type_code
                                                      ,p_night_flag         => pre_nw_rec.night_shift_flag
                                                      ,p_dinner_check       => nvl(pre_nw_rec.evening_meal_flag, 'N')
                                                      ,p_working_start_time => pre_nw_rec.work_start_time
                                                      ,p_ot                 => pre_nw_rec.overtime_sum_hours
                                                      ,p_ot150              => v_ot150
                                                      ,p_ot200              => v_ot200
                                                      ,p_ot300              => v_ot300
                                                      ,p_nt200              => v_nt200
                                                      ,p_nt210              => v_nt210
                                                      ,p_nt270              => v_nt270
                                                      ,p_nt390              => v_nt390
                                                      ,p_nt30               => v_nt30
                                                      ,p_status             => v_status
                                                      );
                                                      
                    UPDATE tb_att_result_n r1 
                       SET r1.weekday_overtime_hours         = v_ot150,
                           r1.holiday_overtime_hours         = v_ot200,
                           r1.public_holiday_overtime_hours  = v_ot300,
                           r1.weekday_night_overtime_hours   = v_nt200,
                           r1.weekday_ot_af_night_work_hours = v_nt210,
                           r1.holiday_night_overtime_hours   = v_nt270,
                           r1.public_holiday_night_ot_hours  = v_nt390
                    WHERE  subsidiary_code          = pre_nw_rec.subsidiary_code
                      AND  time_and_attendance_date = pre_nw_rec.time_and_attendance_date
                      AND  employee_no              = pre_nw_rec.employee_no;                                      
                END IF;
                
                --Swap WH and NW
                UPDATE tb_att_result_n
                   SET shift_type_code                = nw_rec.shift_type_code
                      ,time_and_attendance_code       = nw_rec.time_and_attendance_code
                      ,work_hours                     = nw_rec.work_hours
                      ,work_start_time                = nw_rec.work_start_time
                      ,night_shift_flag               = nw_rec.night_shift_flag
                      ,evening_meal_flag              = null
                      ,overtime_sum_hours             = 0
                      ,weekday_overtime_hours         = 0
                      ,holiday_overtime_hours         = 0
                      ,public_holiday_overtime_hours  = 0
                      ,weekday_night_overtime_hours   = 0
                      ,weekday_ot_af_night_work_hours = 0
                      ,holiday_night_overtime_hours   = 0
                      ,public_holiday_night_ot_hours  = 0
                      ,normal_night_overtime_hours    = nw_rec.normal_night_overtime_hours
                      ,tardy_hours                    = null
                      ,early_leave_hours              = null
                      ,going_out_hours                = null
                      ,special_bonus_hours            = null
                      ,helpcall_support_hours         = null
                      ,time_attend_detail_code        = nw_rec.time_attend_detail_code
                      ,time_attend_input_reason_desc  = null
                      ,base_time_attend_apply_flag    = 'N'
                      ,approval_request_id            = null    
                      ,request_code                   = null   
                      ,progress_status_code           = null   
                      ,last_update_user_id            = p_user_id
                      ,last_update_date               = SYSDATE
                WHERE  subsidiary_code          = wh_rec.subsidiary_code
                  AND  time_and_attendance_date = wh_rec.time_and_attendance_date
                  AND  employee_no              = wh_rec.employee_no;
                
                ----If the previous date of WH have OT -> re-calculate the OT of previous date
                IF pre_wh_rec.overtime_sum_hours > 0 THEN
                    lgvatt_ot_calculation_pkg.calculate_ot(p_subsidiary_code    => pre_wh_rec.subsidiary_code
                                                      ,p_employee_no        => pre_wh_rec.employee_no
                                                      ,p_date               => pre_wh_rec.time_and_attendance_date
                                                      ,p_att_code           => pre_wh_rec.time_and_attendance_code
                                                      ,p_shift_code         => pre_wh_rec.shift_type_code
                                                      ,p_night_flag         => pre_wh_rec.night_shift_flag
                                                      ,p_dinner_check       => nvl(pre_wh_rec.evening_meal_flag, 'N')
                                                      ,p_working_start_time => pre_wh_rec.work_start_time
                                                      ,p_ot                 => pre_wh_rec.overtime_sum_hours
                                                      ,p_ot150              => v_ot150
                                                      ,p_ot200              => v_ot200
                                                      ,p_ot300              => v_ot300
                                                      ,p_nt200              => v_nt200
                                                      ,p_nt210              => v_nt210
                                                      ,p_nt270              => v_nt270
                                                      ,p_nt390              => v_nt390
                                                      ,p_nt30               => v_nt30
                                                      ,p_status             => v_status
                                                      );
                                                      
                    UPDATE tb_att_result_n r1 
                       SET r1.weekday_overtime_hours         = v_ot150,
                           r1.holiday_overtime_hours         = v_ot200,
                           r1.public_holiday_overtime_hours  = v_ot300,
                           r1.weekday_night_overtime_hours   = v_nt200,
                           r1.weekday_ot_af_night_work_hours = v_nt210,
                           r1.holiday_night_overtime_hours   = v_nt270,
                           r1.public_holiday_night_ot_hours  = v_nt390
                    WHERE  subsidiary_code          = pre_wh_rec.subsidiary_code
                      AND  time_and_attendance_date = pre_wh_rec.time_and_attendance_date
                      AND  employee_no              = pre_wh_rec.employee_no;                                      
                END IF;
                
            EXCEPTION
            WHEN OTHERS THEN
                -- 에러처리 필요시 추가
                NULL;
            END;
            END IF;
        END IF;
    
    END LOOP;
    
    COMMIT;

    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_swap_wh_approval;

/*************************************************************************************************/
/* Program Name : apply_att_swap_wh_master                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 수정요청서 결재요청을 처리후 결과를 Return 한다                                */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_weekly_holiday                  in    date                                  */
/*                p_working_day                     in    date                                  */
/*                p_employee_no                     in    varchar2                              */
/*                p_swap_type                       in    varchar2                              */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/07/03  HMS_20210703     Master for swap weekly holiday                                           */
/* 2022/02/28  HMT_20220228    No swap if  time_and_attendance_code IN ('NN', 'PH', 'US')   */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_swap_wh_master(p_ret_code                      OUT NUMBER
                                   ,p_ret_msg                      OUT VARCHAR2
                                   ,p_user_id                      IN  VARCHAR2
                                   ,p_subsidiary_code              IN  VARCHAR2
                                   ,p_weekly_holiday               IN  DATE
                                   ,p_working_day                  IN  DATE
                                   ,p_employee_no                  IN  VARCHAR2
                                   ,p_swap_type                    IN  VARCHAR2
                                    )
IS
    wh_rec                   tb_att_result_n%ROWTYPE;                          
    nw_rec                   tb_att_result_n%ROWTYPE;
    pre_wh_rec               tb_att_result_n%ROWTYPE;                          
    pre_nw_rec               tb_att_result_n%ROWTYPE;
    v_weekly_holiday         DATE:=p_weekly_holiday;
    v_working_day            DATE:=p_working_day;
    v_ot150                  NUMBER;
    v_ot200                  NUMBER;
    v_ot300                  NUMBER;
    v_nt200                  NUMBER;
    v_nt210                  NUMBER;
    v_nt270                  NUMBER;
    v_nt390                  NUMBER;
    v_nt30                   NUMBER;
    v_status                 VARCHAR2(100);
    v_request_seq_no         NUMBER; --HMT_20220228
    v_shift_type_wh_swap     VARCHAR2(10); --HMT_20220228
    v_shift_type_nw_swap     VARCHAR2(10); --HMT_20220228
    v_shift_type_wh_result   VARCHAR2(10); --HMT_20220228
    v_shift_type_nw_result   VARCHAR2(10); --HMT_20220228
         
BEGIN

    IF p_swap_type = 'R' THEN --DELETE SWAP
        v_weekly_holiday := p_working_day;
        v_working_day    := p_weekly_holiday;
    END IF;
    wh_rec     := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, p_employee_no, v_weekly_holiday);
    nw_rec     := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, p_employee_no, v_working_day);
    pre_wh_rec := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, p_employee_no, v_weekly_holiday - 1);
    pre_nw_rec := lgvatt_common_pkg.get_att_result_rec (p_subsidiary_code, p_employee_no, v_working_day - 1);
    --HMT_20220228 Start
    SELECT n.request_seq_no, n.weekly_holiday_shift_type_code, n.working_day_shift_type_code
    INTO    v_request_seq_no, v_shift_type_wh_swap, v_shift_type_nw_swap
      FROM tb_att_swap_holiday_request_n n
    WHERE n.weekly_holiday    = p_weekly_holiday
        AND n.working_day       = p_working_day
        AND n.employee_no      = p_employee_no
        AND n.request_seq_no = (select max(ss.request_seq_no)
                                    from tb_att_swap_holiday_request_n ss
                                   where ss.employee_no = p_employee_no
                                     AND ss.weekly_holiday = p_weekly_holiday
                                     AND ss.working_day       = p_working_day);
          
    --1A, 21AB, 22AB have the same working schedule so it will be consider as 1 shift code type = Standard Type - Std.                           
    SELECT DECODE(SUBSTR(v_shift_type_wh_swap,1,1),'3',v_shift_type_wh_swap,'Std')      INTO v_shift_type_wh_swap from dual;
    SELECT DECODE(SUBSTR(wh_rec.shift_type_code,1,1),'3',wh_rec.shift_type_code,'Std')  INTO v_shift_type_wh_result from dual;
    SELECT DECODE(SUBSTR(v_shift_type_nw_swap,1,1),'3',v_shift_type_nw_swap,'Std')      INTO v_shift_type_nw_swap from dual;
    SELECT DECODE(SUBSTR(nw_rec.shift_type_code,1,1),'3',nw_rec.shift_type_code,'Std')  INTO v_shift_type_nw_result from dual;
     
    IF wh_rec.time_and_attendance_code <> 'WH' OR nw_rec.time_and_attendance_code IN ('NN', 'PH', 'US')
    --If the shift code in swap detail is different from the shift type in current attendance result -> Not allowned to swap
        OR v_shift_type_wh_swap <> v_shift_type_wh_result 
        OR v_shift_type_nw_swap <> v_shift_type_nw_result THEN
                 
        UPDATE tb_att_swap_holiday_request_n sr 
           SET sr.progress_status_code = '70', 
               sr.last_update_user_id = p_user_id,
               sr.last_update_date = sysdate
        WHERE sr.request_seq_no = v_request_seq_no; 
                  
    ELSE
    
        BEGIN
    --HMT_20220228 End
            --Swap NW and WH
            UPDATE tb_att_result_n
               SET shift_type_code                = wh_rec.shift_type_code
                  ,time_and_attendance_code       = wh_rec.time_and_attendance_code
                  ,work_hours                     = wh_rec.work_hours
                  ,work_start_time                = wh_rec.work_start_time
                  ,night_shift_flag               = wh_rec.night_shift_flag
                  ,evening_meal_flag              = null
                  ,overtime_sum_hours             = 0
                  ,weekday_overtime_hours         = 0
                  ,holiday_overtime_hours         = 0
                  ,public_holiday_overtime_hours  = 0
                  ,weekday_night_overtime_hours   = 0
                  ,weekday_ot_af_night_work_hours = 0
                  ,holiday_night_overtime_hours   = 0
                  ,public_holiday_night_ot_hours  = 0
                  ,normal_night_overtime_hours    = wh_rec.normal_night_overtime_hours
                  ,tardy_hours                    = null
                  ,early_leave_hours              = null
                  ,going_out_hours                = null
                  ,special_bonus_hours            = null
                  ,helpcall_support_hours         = null
                  ,time_attend_detail_code        = wh_rec.time_attend_detail_code
                  ,time_attend_input_reason_desc  = null
                  ,base_time_attend_apply_flag    = 'N'
                  ,approval_request_id            = null    
                  ,request_code                   = null   
                  ,progress_status_code           = null   
                  ,last_update_user_id            = p_user_id
                  ,last_update_date               = SYSDATE
            WHERE  subsidiary_code          = nw_rec.subsidiary_code
              AND  time_and_attendance_date = nw_rec.time_and_attendance_date
              AND  employee_no              = nw_rec.employee_no;
            
            --If the previous date of NW have OT -> re-calculate the OT of previous date
            IF pre_nw_rec.overtime_sum_hours > 0 THEN
                lgvatt_ot_calculation_pkg.calculate_ot(p_subsidiary_code    => pre_nw_rec.subsidiary_code
                                                      ,p_employee_no        => pre_nw_rec.employee_no
                                                      ,p_date               => pre_nw_rec.time_and_attendance_date
                                                      ,p_att_code           => pre_nw_rec.time_and_attendance_code
                                                      ,p_shift_code         => pre_nw_rec.shift_type_code
                                                      ,p_night_flag         => pre_nw_rec.night_shift_flag
                                                      ,p_dinner_check       => nvl(pre_nw_rec.evening_meal_flag, 'N')
                                                      ,p_working_start_time => pre_nw_rec.work_start_time
                                                      ,p_ot                 => pre_nw_rec.overtime_sum_hours
                                                      ,p_ot150              => v_ot150
                                                      ,p_ot200              => v_ot200
                                                      ,p_ot300              => v_ot300
                                                      ,p_nt200              => v_nt200
                                                      ,p_nt210              => v_nt210
                                                      ,p_nt270              => v_nt270
                                                      ,p_nt390              => v_nt390
                                                      ,p_nt30               => v_nt30
                                                      ,p_status             => v_status
                                                      );
                                                      
                UPDATE tb_att_result_n r1 
                   SET r1.weekday_overtime_hours         = v_ot150,
                       r1.holiday_overtime_hours         = v_ot200,
                       r1.public_holiday_overtime_hours  = v_ot300,
                       r1.weekday_night_overtime_hours   = v_nt200,
                       r1.weekday_ot_af_night_work_hours = v_nt210,
                       r1.holiday_night_overtime_hours   = v_nt270,
                       r1.public_holiday_night_ot_hours  = v_nt390
                  WHERE  subsidiary_code          = pre_nw_rec.subsidiary_code
                    AND  time_and_attendance_date = pre_nw_rec.time_and_attendance_date
                    AND  employee_no              = pre_nw_rec.employee_no;                                      
            END IF;
            --Swap WH and NW
            UPDATE tb_att_result_n
               SET shift_type_code                = nw_rec.shift_type_code
                  ,time_and_attendance_code       = nw_rec.time_and_attendance_code
                  ,work_hours                     = nw_rec.work_hours
                  ,work_start_time                = nw_rec.work_start_time
                  ,night_shift_flag               = nw_rec.night_shift_flag
                  ,evening_meal_flag              = null
                  ,overtime_sum_hours             = 0
                  ,weekday_overtime_hours         = 0
                  ,holiday_overtime_hours         = 0
                  ,public_holiday_overtime_hours  = 0
                  ,weekday_night_overtime_hours   = 0
                  ,weekday_ot_af_night_work_hours = 0
                  ,holiday_night_overtime_hours   = 0
                  ,public_holiday_night_ot_hours  = 0
                  ,normal_night_overtime_hours    = nw_rec.normal_night_overtime_hours
                  ,tardy_hours                    = null
                  ,early_leave_hours              = null
                  ,going_out_hours                = null
                  ,special_bonus_hours            = null
                  ,helpcall_support_hours         = null
                  ,time_attend_detail_code        = nw_rec.time_attend_detail_code
                  ,time_attend_input_reason_desc  = null
                  ,base_time_attend_apply_flag    = 'N'
                  ,approval_request_id            = null    
                  ,request_code                   = null   
                  ,progress_status_code           = null   
                  ,last_update_user_id            = p_user_id
                  ,last_update_date               = SYSDATE
            WHERE  subsidiary_code          = wh_rec.subsidiary_code
            AND    time_and_attendance_date = wh_rec.time_and_attendance_date
            AND    employee_no              = wh_rec.employee_no;
            
            --If the previous date of WH have OT -> re-calculate the OT of previous date
            IF pre_wh_rec.overtime_sum_hours > 0 THEN
                lgvatt_ot_calculation_pkg.calculate_ot(p_subsidiary_code    => pre_wh_rec.subsidiary_code
                                                      ,p_employee_no        => pre_wh_rec.employee_no
                                                      ,p_date               => pre_wh_rec.time_and_attendance_date
                                                      ,p_att_code           => pre_wh_rec.time_and_attendance_code
                                                      ,p_shift_code         => pre_wh_rec.shift_type_code
                                                      ,p_night_flag         => pre_wh_rec.night_shift_flag
                                                      ,p_dinner_check       => nvl(pre_wh_rec.evening_meal_flag, 'N')
                                                      ,p_working_start_time => pre_wh_rec.work_start_time
                                                      ,p_ot                 => pre_wh_rec.overtime_sum_hours
                                                      ,p_ot150              => v_ot150
                                                      ,p_ot200              => v_ot200
                                                      ,p_ot300              => v_ot300
                                                      ,p_nt200              => v_nt200
                                                      ,p_nt210              => v_nt210
                                                      ,p_nt270              => v_nt270
                                                      ,p_nt390              => v_nt390
                                                      ,p_nt30               => v_nt30
                                                      ,p_status             => v_status
                                                      );
                                                      
                UPDATE tb_att_result_n r1 
                   SET r1.weekday_overtime_hours         = v_ot150,
                       r1.holiday_overtime_hours         = v_ot200,
                       r1.public_holiday_overtime_hours  = v_ot300,
                       r1.weekday_night_overtime_hours   = v_nt200,
                       r1.weekday_ot_af_night_work_hours = v_nt210,
                       r1.holiday_night_overtime_hours   = v_nt270,
                       r1.public_holiday_night_ot_hours  = v_nt390
                WHERE  subsidiary_code          = pre_wh_rec.subsidiary_code
                  AND  time_and_attendance_date = pre_wh_rec.time_and_attendance_date
                  AND  employee_no              = pre_wh_rec.employee_no;                                      
            END IF;
                
            EXCEPTION
            WHEN OTHERS THEN
                -- 에러처리 필요시 추가
                NULL;
            END; 
        END IF;  
    
    COMMIT;

    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_swap_wh_master;


/*************************************************************************************************/
/* Program Name : apply_att_residual_ann_lv                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태년도에 해당하는 잔여연차휴가를 리비전후 결과를 Return 한다      */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  근태년월(YYYY)               */
/*                p_curr_year_apply_flag            in    varchar2  당년도 전체적용여부          */
/*                p_next_year_apply_flag            in    varchar2  다음년도적용여부             */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_residual_ann_lv (p_ret_code                   OUT NUMBER
                                    ,p_ret_msg                    OUT VARCHAR2
                                    ,p_user_id                    IN  VARCHAR2
                                    ,p_subsidiary_code            IN  VARCHAR2
                                    ,p_employee_no                IN  VARCHAR2
                                    ,p_time_and_attendance_yyyymm IN  VARCHAR2
                                    ,p_curr_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                    ,p_next_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                    )
IS
    v_prev_res_annual_lv_days          NUMBER;  -- 전월잔여연차휴가일수 
    v_curr_res_annual_lv_days          NUMBER;  -- 당월잔여연차휴가일수 

    prev_aal_rec                       tb_att_annual_leave_n%ROWTYPE;
BEGIN

    p_ret_code := 0;
    p_ret_msg  := '';

    -- 201712 오픈이므로, 201712 연차정보는 사용/보정/보상된 최종데이타를 Update 하였으므로,
    -- 시스템에서 임의로 보정 처리되면 절대 안됨
    IF (p_time_and_attendance_yyyymm <= '201712') THEN  RETURN;  END IF;
    
    v_prev_res_annual_lv_days := -9999;

    FOR anl IN (SELECT *
                FROM   (SELECT * 
                        FROM   tb_att_annual_leave_n 
                        WHERE  subsidiary_code               = p_subsidiary_code 
                        AND    employee_no                   = p_employee_no 
                        AND    time_and_attendance_yyyymm LIKE SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '%'  -- 당년도만
                        AND    time_and_attendance_yyyymm   >= CASE WHEN NVL(p_curr_year_apply_flag, 'N') = 'Y'
                                                                    THEN SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '01'  -- 01월 이후
                                                                    ELSE p_time_and_attendance_yyyymm  -- 당월 이후
                                                               END
                        UNION ALL
                        SELECT * 
                        FROM   tb_att_annual_leave_n 
                        WHERE  subsidiary_code               = p_subsidiary_code 
                        AND    employee_no                   = p_employee_no 
                        AND    time_and_attendance_yyyymm    > SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '99'  -- 다음년도도 계속 처리
                        AND    NVL(p_next_year_apply_flag, 'N') = 'Y'
                       )
                ORDER BY time_and_attendance_yyyymm
               )
    LOOP
        IF (v_prev_res_annual_lv_days = -9999) THEN

            -- 전월 연차정보
            prev_aal_rec := lgvatt_common_pkg.get_att_annual_leave_rec (p_subsidiary_code, p_employee_no, TO_CHAR(ADD_MONTHS(TO_DATE(p_time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM'));
            
            -- 전월 잔여연차일수
            v_prev_res_annual_lv_days := NVL(prev_aal_rec.residual_annual_leave_days, 0);
        END IF;
        
        v_curr_res_annual_lv_days := NVL(v_prev_res_annual_lv_days,         0)  -- 전월잔여연차휴가일수 
                                   + NVL(anl.occur_basic_annual_leave_days, 0)  -- 당월발생기초연차휴가일수 
                                   + NVL(anl.occur_monthly_ann_lv_days,     0)  -- 당월발생월별연차휴가일수 
                                   + NVL(anl.annual_calibration_days,       0)  -- 당월연차보정일수
                                   - NVL(anl.use_annual_leave_days,         0)  -- 당월사용연차휴가일수 : 연차정보 테이블의 사용연차
                                   - NVL(anl.annual_compensation_days,      0)  -- 연차보상일수
                                   ;
                                       
        -- 잔여휴가 보정
        UPDATE tb_att_annual_leave_n
        SET    residual_annual_leave_days = v_curr_res_annual_lv_days  -- 잔여휴가
              ,last_update_user_id        = p_user_id
              ,last_update_date           = SYSDATE
        WHERE  subsidiary_code            = p_subsidiary_code 
        AND    employee_no                = p_employee_no 
        AND    time_and_attendance_yyyymm = anl.time_and_attendance_yyyymm
        ;
            
        v_prev_res_annual_lv_days := v_curr_res_annual_lv_days;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_residual_ann_lv;


/*************************************************************************************************/
/* Program Name : apply_att_use_res_ann_lv                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 사원번호의 근태년도에 해당하는 사용/잔여연차휴가를 리비전후 결과를 Return 한다 */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  근태년월(YYYY)               */
/*                p_curr_year_apply_flag            in    varchar2  당년도 전체적용여부          */
/*                p_next_year_apply_flag            in    varchar2  다음년도적용여부             */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/* 2018/03/02  손수양C     LGD 베트남 급여근태 고도화                                            */        
/*                         반일휴가 추가로 사용년차 계산에 HL 추가                               */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_use_res_ann_lv (p_ret_code                   OUT NUMBER
                                   ,p_ret_msg                    OUT VARCHAR2
                                   ,p_user_id                    IN  VARCHAR2
                                   ,p_subsidiary_code            IN  VARCHAR2
                                   ,p_employee_no                IN  VARCHAR2
                                   ,p_time_and_attendance_yyyymm IN  VARCHAR2
                                   ,p_curr_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                   ,p_next_year_apply_flag       IN  VARCHAR2 DEFAULT 'N'
                                   )
IS
    v_prev_res_annual_lv_days          tb_att_annual_leave_n.residual_annual_leave_days%TYPE;  -- 전월잔여연차휴가일수 
    v_use_annual_leave_days            tb_att_annual_leave_n.use_annual_leave_days%TYPE;       -- 당월사용연차휴가일수
    v_curr_res_annual_lv_days          tb_att_annual_leave_n.residual_annual_leave_days%TYPE;  -- 당월잔여연차휴가일수 

    prev_aal_rec                       tb_att_annual_leave_n%ROWTYPE;
BEGIN

    p_ret_code := 0;
    p_ret_msg  := '';

    -- 201712 오픈이므로, 201712 연차정보는 사용/보정/보상된 최종데이타를 Update 하였으므로,
    -- 시스템에서 임의로 보정 처리되면 절대 안됨
    IF (p_time_and_attendance_yyyymm <= '201712') THEN  RETURN;  END IF;

    v_prev_res_annual_lv_days := -9999;

    FOR anl IN (SELECT *
                FROM   (SELECT * 
                        FROM   tb_att_annual_leave_n 
                        WHERE  subsidiary_code               = p_subsidiary_code 
                        AND    employee_no                   = p_employee_no 
                        AND    time_and_attendance_yyyymm LIKE SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '%'  -- 당년도만
                        AND    time_and_attendance_yyyymm   >= CASE WHEN NVL(p_curr_year_apply_flag, 'N') = 'Y'
                                                                    THEN SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '01'  -- 01월 이후
                                                                    ELSE p_time_and_attendance_yyyymm  -- 당월 이후
                                                               END
                        UNION ALL
                        SELECT * 
                        FROM   tb_att_annual_leave_n 
                        WHERE  subsidiary_code               = p_subsidiary_code 
                        AND    employee_no                   = p_employee_no 
                        AND    time_and_attendance_yyyymm    > SUBSTR(p_time_and_attendance_yyyymm, 1, 4) || '99'  -- 다음년도도 계속 처리
                        AND    NVL(p_next_year_apply_flag, 'N') = 'Y'
                       )
                ORDER BY time_and_attendance_yyyymm
               )
    LOOP
        IF (v_prev_res_annual_lv_days = -9999) THEN

            -- 전월 연차정보
            prev_aal_rec := lgvatt_common_pkg.get_att_annual_leave_rec (p_subsidiary_code, p_employee_no, TO_CHAR(ADD_MONTHS(TO_DATE(p_time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM'));
            
            -- 전월 잔여연차일수
            v_prev_res_annual_lv_days := NVL(prev_aal_rec.residual_annual_leave_days, 0);
        END IF;
        
        /* 2018/03/02 : 반일휴가 추가로 사용년차 계산에 HL 추가 */
        SELECT NVL(SUM(ac.paid_days), 0)
        INTO   v_use_annual_leave_days
        FROM   tb_att_result_n ar,
               tb_att_code_c   ac
        WHERE  ar.subsidiary_code            = p_subsidiary_code
        AND    ar.time_and_attendance_yyyymm = anl.time_and_attendance_yyyymm
        AND    ar.employee_no                = p_employee_no
        AND    ar.time_and_attendance_code   IN ( 'AL' ,'HL', 'HL_FN', 'HL_SN' )
        AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
        AND    ar.subsidiary_code            = ac.subsidiary_code
        ;
            
        v_curr_res_annual_lv_days := NVL(v_prev_res_annual_lv_days,         0)  -- 전월잔여연차휴가일수 
                                   + NVL(anl.occur_basic_annual_leave_days, 0)  -- 당월발생기초연차휴가일수 
                                   + NVL(anl.occur_monthly_ann_lv_days,     0)  -- 당월발생월별연차휴가일수 
                                   + NVL(anl.annual_calibration_days,       0)  -- 당월연차보정일수
                                   - NVL(v_use_annual_leave_days,           0)  -- 당월사용연차휴가일수 : 일근태실적 테이블의 연차 합계
                                   - NVL(anl.annual_compensation_days,      0)  -- 연차보상일수
                                   ;

        -- 잔여휴가 보정
        UPDATE tb_att_annual_leave_n
        SET    use_annual_leave_days      = v_use_annual_leave_days     -- 사용휴가
              ,residual_annual_leave_days = v_curr_res_annual_lv_days   -- 잔여휴가
              ,last_update_user_id        = p_user_id
              ,last_update_date           = SYSDATE
        WHERE  subsidiary_code            = p_subsidiary_code 
        AND    employee_no                = p_employee_no 
        AND    time_and_attendance_yyyymm = anl.time_and_attendance_yyyymm
        ;
            
        v_prev_res_annual_lv_days := v_curr_res_annual_lv_days;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END apply_att_use_res_ann_lv;


/*************************************************************************************************/
/* Program Name : apply_att_result_ot_calc                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태실적 생성/변경 후에, OT 상세를 계산하여 반영한다.                          */
/*                단, base_time_attend_apply_flag = 'T' 인 데이타를 대상으로 처리한다.           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  사용자ID                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_base_time_attend_apply_flag     in    varchar2  기본근태적용여부             */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/01/30  박귀희B     Initial Release                                                       */
/* 2021/07/17  HMT_20210717          Swap weekly holiday (Add p_employee_no)                   */
/*************************************************************************************************/
PROCEDURE apply_att_result_ot_calc (p_ret_code                    OUT VARCHAR2
                                   ,p_ret_msg                     OUT VARCHAR2
                                   ,p_user_id                     IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code             IN  VARCHAR2 DEFAULT NULL
                                   ,p_base_time_attend_apply_flag IN  VARCHAR2 DEFAULT 'Y'
                                   ,p_employee_no                 IN  VARCHAR2 DEFAULT NULL
                                   )
IS
    v_subsidiary_code               VARCHAR2(30) := NVL(p_subsidiary_code, 'LGDVN');
    v_user_id                       VARCHAR2(30) := NVL(p_user_id, lgvhr_common_pkg.sys_user_id);

    ar_rec                          tb_att_result_n%ROWTYPE;
    v_ot_calc_status                VARCHAR2(100);
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- 2018.01.30 박귀희 : OT 계산을 위하여 변경 구분된 컬럼에 대하여 OT 계산
    -- 동일한 근태사항끼리 그룹핑 : 속도빠르게
    FOR res IN (SELECT /*+ index(ar TB_ATT_RESULT_N_N3) */
                       shift_type_code               AS shift_type_code
                      ,work_start_time               AS work_start_time
                      ,time_and_attendance_code      AS time_and_attendance_code
                      ,NVL(night_shift_flag,  'N')   AS night_shift_flag
                      ,NVL(evening_meal_flag, 'N')   AS evening_meal_flag
                      ,NVL(overtime_sum_hours, 0)    AS overtime_sum_hours
                      ,MIN(time_and_attendance_date) AS time_and_attendance_date
                FROM   tb_att_result_n ar
                WHERE  subsidiary_code             = v_subsidiary_code
                AND    base_time_attend_apply_flag = 'T'
                AND    employee_no                 = NVL(p_employee_no, employee_no)
                GROUP BY  shift_type_code, work_start_time, time_and_attendance_code, NVL(night_shift_flag, 'N'), NVL(evening_meal_flag, 'N'), NVL(overtime_sum_hours, 0)
               )
    LOOP
        lgvatt_ot_calculation_pkg.calculate_ot (p_subsidiary_code    => v_subsidiary_code
                                               ,p_employee_no        => p_employee_no --HMT_20210717
                                               ,p_date               => res.time_and_attendance_date
                                               ,p_att_code           => res.time_and_attendance_code
                                               ,p_shift_code         => res.shift_type_code
                                               ,p_night_flag         => res.night_shift_flag
                                               ,p_dinner_check       => res.evening_meal_flag
                                               ,p_working_start_time => res.work_start_time
                                               ,p_ot                 => res.overtime_sum_hours
                                               ,p_ot150              => ar_rec.weekday_overtime_hours
                                               ,p_ot200              => ar_rec.holiday_overtime_hours
                                               ,p_ot300              => ar_rec.public_holiday_overtime_hours
                                               ,p_nt200              => ar_rec.weekday_night_overtime_hours
                                               ,p_nt210              => ar_rec.weekday_ot_af_night_work_hours
                                               ,p_nt270              => ar_rec.holiday_night_overtime_hours
                                               ,p_nt390              => ar_rec.public_holiday_night_ot_hours
                                               ,p_nt30               => ar_rec.normal_night_overtime_hours
                                               ,p_status             => v_ot_calc_status
                                               );

        -- OT 상세 계산을 위해서 호출되므로, last 컬럼은 변경하지 않음
        UPDATE /*+ index(ar TB_ATT_RESULT_N_N3) */
               tb_att_result_n ar
        SET    base_time_attend_apply_flag    = NVL(p_base_time_attend_apply_flag, 'Y')
              ,weekday_overtime_hours         = ar_rec.weekday_overtime_hours         
              ,holiday_overtime_hours         = ar_rec.holiday_overtime_hours         
              ,public_holiday_overtime_hours  = ar_rec.public_holiday_overtime_hours  
              ,weekday_night_overtime_hours   = ar_rec.weekday_night_overtime_hours   
              ,weekday_ot_af_night_work_hours = ar_rec.weekday_ot_af_night_work_hours 
              ,holiday_night_overtime_hours   = ar_rec.holiday_night_overtime_hours   
              ,public_holiday_night_ot_hours  = ar_rec.public_holiday_night_ot_hours  
              ,normal_night_overtime_hours    = ar_rec.normal_night_overtime_hours    
        WHERE  subsidiary_code             = v_subsidiary_code
        AND    base_time_attend_apply_flag = 'T'
        AND    employee_no                 = NVL(p_employee_no, employee_no)
        AND    shift_type_code             = res.shift_type_code         
        AND    time_and_attendance_code    = res.time_and_attendance_code
        AND    NVL(night_shift_flag,  'N') = res.night_shift_flag
        AND    NVL(evening_meal_flag, 'N') = res.evening_meal_flag
        AND    NVL(overtime_sum_hours, 0)  = res.overtime_sum_hours
        ;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN

    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
END apply_att_result_ot_calc;


/*************************************************************************************************/
/* Program Name : send_att_modified_alert                                                        */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 결재자가 계획/실적 근태 수정시에 대상자에게 수정 안내메일을 발송한다.          */
/*                현재는 실적만 수정가능하지만, 계획에 대한 기능 추가시에 계획도 가능하다.       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  결재자USER_ID                */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  대상자사원번호               */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_result_plan_type                in    varchar2  실적계획유형(RESULT/PLAN)    */
/*                p_approval_type                   in    varchar2  결재유형(REJECT/APPROVAL)    */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE send_att_modified_alert (p_ret_code                   OUT NUMBER
                                  ,p_ret_msg                    OUT VARCHAR2
                                  ,p_user_id                    IN  VARCHAR2
                                  ,p_subsidiary_code            IN  VARCHAR2
                                  ,p_employee_no                IN  VARCHAR2
                                  ,p_time_and_attendance_date   IN  DATE
                                  ,p_result_plan_type           IN  VARCHAR2
                                  ,p_lang_code                  IN  VARCHAR2 DEFAULT 'en'
                                  )
IS
    v_approver_name               emp_master.full_name_local%TYPE;
    
    v_mail_addr                   lgcom_user_m.mail_addr%TYPE;
    v_mail_code                   lgcom_common_code_c.common_code%TYPE;
    v_mail_mapp                   lgcom_mail_info.mail_clob_data%TYPE;

BEGIN
    
    -- 대상자 메일주소
    v_mail_addr := lgvhr_common_pkg.get_mail_addr_func (p_subsidiary_code, p_employee_no);
    
    -- 결재자 성명 : 길동 홍
    SELECT middlename_local || DECODE(middlename_local, NULL, NULL, ' ') || lastname_local || DECODE(lastname_local,   NULL, NULL, ' ') || firstname_local
    INTO   v_approver_name
    FROM   emp_master
    WHERE  employee_number = lgvhr_common_pkg.get_employee_no_func(p_subsidiary_code, p_user_id)
    ;

    v_mail_code := CASE WHEN p_result_plan_type = 'PLAN' 
                        THEN 'DAY_ATT_PLAN_MODIFIED_APPR' 
                        ELSE 'DAY_ATT_RESULT_MODIFIED_APPR'
                   END;

    v_mail_mapp := '{"subject":{"none":""},"data1":{"attendaceDate":"'
                || TO_CHAR(p_time_and_attendance_date, 'DD/MM/YYYY')
                || '","aDayOfWeek":"'
                || TO_CHAR(p_time_and_attendance_date, 'Dy')    -- 요일 : Mon / Tue 형식
                || '","approverName":"'
                || v_approver_name
                || '"}}';


    -- 템플릿에서는 <br/> 태그가 안되므로, 템플릿을 읽어서 변환후 DIRECT 로 처리함
    SELECT REPLACE(REPLACE(REPLACE(mc.mail_detail_content, 
               '[attendaceDate]', TO_CHAR(p_time_and_attendance_date, 'DD/MM/YYYY')),
               '[aDayOfWeek]', TO_CHAR(p_time_and_attendance_date, 'Dy')),
               '[approverName]', v_approver_name)
    INTO   v_mail_mapp
    FROM   lgcom_mail_m         cm
          ,lgcom_common_code_c  cc
          ,lgcom_mail_content_n mc
    WHERE  cc.code_type_code              = 'LGVHR_MAIL_TEMPLATE_LIST'
    AND    cc.common_code                 = v_mail_code
    AND    TO_NUMBER(cc.code_data1_value) = cm.mail_id
    AND    cm.mail_id                     = mc.mail_id
    AND    mc.language_code               = NVL(p_lang_code, 'en')
    ;

    lgvhr_transaction_pkg.send_mail(p_ret_code        => p_ret_code
                                   ,p_ret_msg         => p_ret_msg
                                   ,p_user_id         => p_user_id
                                   ,p_subsidiary_code => p_subsidiary_code
                                   ,p_mail_code       => v_mail_code
                                   ,p_receipt_info    => v_mail_addr
                                   ,p_language_code   => p_lang_code
                                   ,p_mail_mapp       => v_mail_mapp
                                   ,p_sender_info     => NULL
                                   ,p_cc_info         => NULL
                                   ,p_subject_content => NULL
                                   );
                             
    -- 메일발송시 정상이면 발송번호, 에러이면 -1 리턴함
    IF (p_ret_code = -1) THEN
        p_ret_code := 1;
    ELSE
        p_ret_code := 0;  -- 정상
        p_ret_msg  := '';
    END IF;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);

END send_att_modified_alert;



/*************************************************************************************************/
/* Program Name : apply_att_code_record                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태코드를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ac_rec                          in    varchar2  근태코드 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_code_record (p_ac_rec    IN tb_att_code_c%ROWTYPE
                               ,p_work_type IN VARCHAR2 DEFAULT NULL
                               )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_code_c
        WHERE  subsidiary_code          = p_ac_rec.subsidiary_code
        AND    time_and_attendance_code = p_ac_rec.time_and_attendance_code
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_code_c VALUES p_ac_rec;

    ELSE
        -- 수정
        UPDATE tb_att_code_c
        SET    time_and_attendance_name       = p_ac_rec.time_and_attendance_name      
              ,time_and_attendance_type_code  = p_ac_rec.time_and_attendance_type_code 
              ,paid_days                      = p_ac_rec.paid_days                     
              ,unpaid_days                    = p_ac_rec.unpaid_days                   
              ,attendance_days                = p_ac_rec.attendance_days               
              ,payment_rate                   = p_ac_rec.payment_rate                  
              ,ofc_wrk_tech_wrk_type_code     = p_ac_rec.ofc_wrk_tech_wrk_type_code    
              ,overtime_flag                  = p_ac_rec.overtime_flag                 
              ,gender_code                    = p_ac_rec.gender_code                   
              ,use_flag                       = p_ac_rec.use_flag                      
              ,apply_content                  = p_ac_rec.apply_content                 
              ,apply_plan_desc                = p_ac_rec.apply_plan_desc               
              ,time_and_attendance_short_name = p_ac_rec.time_and_attendance_short_name
              ,update_enable_flag             = p_ac_rec.update_enable_flag            
              ,daily_time_attend_plan_tg_flag = p_ac_rec.daily_time_attend_plan_tg_flag
              ,daily_time_attend_rslt_tg_flag = p_ac_rec.daily_time_attend_rslt_tg_flag
              ,lt_time_attend_plan_tg_flag    = p_ac_rec.lt_time_attend_plan_tg_flag   
              ,last_update_user_id            = p_ac_rec.last_update_user_id           
              ,last_update_date               = p_ac_rec.last_update_date              
        WHERE  subsidiary_code          = p_ac_rec.subsidiary_code
        AND    time_and_attendance_code = p_ac_rec.time_and_attendance_code
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_code_record;


/*************************************************************************************************/
/* Program Name : apply_att_calendar_record                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 카렌다를 적용 후, 결과를 Return 한다                                           */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ac_rec                          in    varchar2  카렌다 레코드                */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_calendar_record (p_ac_rec    IN tb_att_calendar_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_calendar_n
        WHERE  subsidiary_code          = p_ac_rec.subsidiary_code
        AND    time_and_attendance_date = p_ac_rec.time_and_attendance_date
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_calendar_n VALUES p_ac_rec;

    ELSE
        -- 수정
        UPDATE tb_att_calendar_n
        SET    time_and_attendance_yyyymm = p_ac_rec.time_and_attendance_yyyymm
              ,time_and_attendance_code   = p_ac_rec.time_and_attendance_code
              ,a_day_of_the_week_code     = p_ac_rec.a_day_of_the_week_code
              ,holiday_code               = p_ac_rec.holiday_code
              ,holiday_flag               = p_ac_rec.holiday_flag
              ,confirm_flag               = p_ac_rec.confirm_flag
              ,last_update_user_id        = p_ac_rec.last_update_user_id
              ,last_update_date           = p_ac_rec.last_update_date
        WHERE  subsidiary_code          = p_ac_rec.subsidiary_code
        AND    time_and_attendance_date = p_ac_rec.time_and_attendance_date
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_calendar_record;


/*************************************************************************************************/
/* Program Name : apply_att_close_record                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태마감을 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ac_rec                          in    varchar2  근태마감 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_close_record (p_ac_rec    IN tb_att_close_n%ROWTYPE
                                ,p_work_type IN VARCHAR2 DEFAULT NULL
                                )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_close_n
        WHERE  subsidiary_code            = p_ac_rec.subsidiary_code
        AND    time_and_attendance_yyyymm = p_ac_rec.time_and_attendance_yyyymm
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_close_n VALUES p_ac_rec;

    ELSE
        -- 수정
        UPDATE tb_att_close_n
        SET    period_from_date        = p_ac_rec.period_from_date          
              ,period_to_date          = p_ac_rec.period_to_date         
              ,period_close_date       = p_ac_rec.period_close_date         
              ,perfect_attendance_days = p_ac_rec.perfect_attendance_days   
              ,confirm_flag            = p_ac_rec.confirm_flag              
              ,last_update_user_id     = p_ac_rec.last_update_user_id       
              ,last_update_date        = p_ac_rec.last_update_date          
        WHERE  subsidiary_code            = p_ac_rec.subsidiary_code
        AND    time_and_attendance_yyyymm = p_ac_rec.time_and_attendance_yyyymm
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_close_record;


/*************************************************************************************************/
/* Program Name : apply_att_base_bas_record                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태기본을 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ab_rec                          in    varchar2  근태기본 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_base_bas_record (p_ab_rec    IN tb_att_base_bas_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_base_bas_n
        WHERE  subsidiary_code          = p_ab_rec.subsidiary_code
        AND    time_and_attendance_date = p_ab_rec.time_and_attendance_date
        AND    shift_type_code          = p_ab_rec.shift_type_code
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_base_bas_n VALUES p_ab_rec;

    ELSE
        -- 수정
        UPDATE tb_att_base_bas_n
        SET    time_and_attendance_yyyymm   = p_ab_rec.time_and_attendance_yyyymm   
              ,a_day_of_the_week_code       = p_ab_rec.a_day_of_the_week_code       
              ,time_and_attendance_code     = p_ab_rec.time_and_attendance_code     
              ,attendance_time              = p_ab_rec.attendance_time              
              ,leaving_office_time          = p_ab_rec.leaving_office_time          
              ,night_shift_flag             = p_ab_rec.night_shift_flag             
              ,overtime_hours               = p_ab_rec.overtime_hours               
              ,time_attend_input_close_time = p_ab_rec.time_attend_input_close_time 
              ,time_attend_apprv_close_time = p_ab_rec.time_attend_apprv_close_time 
              ,work_hours                   = p_ab_rec.work_hours                   
              ,evening_meal_flag            = p_ab_rec.evening_meal_flag            
              ,last_update_user_id          = p_ab_rec.last_update_user_id          
              ,last_update_date             = p_ab_rec.last_update_date             
        WHERE  subsidiary_code          = p_ab_rec.subsidiary_code
        AND    time_and_attendance_date = p_ab_rec.time_and_attendance_date
        AND    shift_type_code          = p_ab_rec.shift_type_code
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_base_bas_record;


/*************************************************************************************************/
/* Program Name : apply_att_plan_record                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 계획근태를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ap_rec                          in    varchar2  계획근태 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_plan_record (p_ap_rec    IN tb_att_plan_n%ROWTYPE
                               ,p_work_type IN VARCHAR2 DEFAULT NULL
                               )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_plan_n
        WHERE  subsidiary_code          = p_ap_rec.subsidiary_code
        AND    time_and_attendance_date = p_ap_rec.time_and_attendance_date
        AND    employee_no              = p_ap_rec.employee_no
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_plan_n VALUES p_ap_rec;

    ELSE
        -- 수정
        UPDATE tb_att_plan_n
        SET    shift_type_code               = p_ap_rec.shift_type_code
              ,time_and_attendance_yyyymm    = p_ap_rec.time_and_attendance_yyyymm
              ,a_day_of_the_week_code        = p_ap_rec.a_day_of_the_week_code
              ,time_and_attendance_code      = p_ap_rec.time_and_attendance_code
              ,night_shift_flag              = p_ap_rec.night_shift_flag
              ,evening_meal_flag             = p_ap_rec.evening_meal_flag
              ,overtime_sum_hours            = p_ap_rec.overtime_sum_hours
              ,planning_id                   = p_ap_rec.planning_id
              ,progress_status_code          = p_ap_rec.progress_status_code
              ,approval_request_id           = p_ap_rec.approval_request_id
              ,request_code                  = p_ap_rec.request_code
              ,time_attend_detail_code       = p_ap_rec.time_attend_detail_code
              ,time_attend_input_reason_desc = p_ap_rec.time_attend_input_reason_desc
              ,base_time_attend_apply_flag   = p_ap_rec.base_time_attend_apply_flag
              ,last_update_user_id           = p_ap_rec.last_update_user_id
              ,last_update_date              = p_ap_rec.last_update_date
        WHERE  subsidiary_code          = p_ap_rec.subsidiary_code
        AND    time_and_attendance_date = p_ap_rec.time_and_attendance_date
        AND    employee_no              = p_ap_rec.employee_no
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_plan_record;


/*************************************************************************************************/
/* Program Name : apply_att_result_record                                                        */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 실적근태를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ar_rec                          in    varchar2  실적근태 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_result_record (p_ar_rec    IN tb_att_result_n%ROWTYPE
                                 ,p_work_type IN VARCHAR2 DEFAULT NULL
                                 )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_result_n
        WHERE  subsidiary_code          = p_ar_rec.subsidiary_code
        AND    time_and_attendance_date = p_ar_rec.time_and_attendance_date
        AND    employee_no              = p_ar_rec.employee_no
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_result_n VALUES p_ar_rec;

    ELSE
        -- 수정
        UPDATE tb_att_result_n
        SET    shift_type_code                = p_ar_rec.shift_type_code
              ,time_and_attendance_yyyymm     = p_ar_rec.time_and_attendance_yyyymm
              ,a_day_of_the_week_code         = p_ar_rec.a_day_of_the_week_code
              ,time_and_attendance_code       = p_ar_rec.time_and_attendance_code
              ,work_hours                     = p_ar_rec.work_hours
              ,work_start_time                = p_ar_rec.work_start_time
              ,night_shift_flag               = p_ar_rec.night_shift_flag
              ,evening_meal_flag              = p_ar_rec.evening_meal_flag
              ,overtime_sum_hours             = p_ar_rec.overtime_sum_hours
              ,weekday_overtime_hours         = p_ar_rec.weekday_overtime_hours
              ,holiday_overtime_hours         = p_ar_rec.holiday_overtime_hours
              ,public_holiday_overtime_hours  = p_ar_rec.public_holiday_overtime_hours
              ,weekday_night_overtime_hours   = p_ar_rec.weekday_night_overtime_hours
              ,weekday_ot_af_night_work_hours = p_ar_rec.weekday_ot_af_night_work_hours
              ,holiday_night_overtime_hours   = p_ar_rec.holiday_night_overtime_hours
              ,public_holiday_night_ot_hours  = p_ar_rec.public_holiday_night_ot_hours
              ,normal_night_overtime_hours    = p_ar_rec.normal_night_overtime_hours
              ,tardy_hours                    = p_ar_rec.tardy_hours
              ,early_leave_hours              = p_ar_rec.early_leave_hours
              ,going_out_hours                = p_ar_rec.going_out_hours
              ,special_bonus_hours            = p_ar_rec.special_bonus_hours
              ,helpcall_support_hours         = p_ar_rec.helpcall_support_hours
              ,approval_request_id            = p_ar_rec.approval_request_id
              ,request_code                   = p_ar_rec.request_code
              ,progress_status_code           = p_ar_rec.progress_status_code
              ,time_attend_detail_code        = p_ar_rec.time_attend_detail_code
              ,time_attend_input_reason_desc  = p_ar_rec.time_attend_input_reason_desc
              ,base_time_attend_apply_flag    = p_ar_rec.base_time_attend_apply_flag
              ,last_update_user_id            = p_ar_rec.last_update_user_id
              ,last_update_date               = p_ar_rec.last_update_date
        WHERE  subsidiary_code          = p_ar_rec.subsidiary_code
        AND    time_and_attendance_date = p_ar_rec.time_and_attendance_date
        AND    employee_no              = p_ar_rec.employee_no
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_result_record;


/*************************************************************************************************/
/* Program Name : apply_att_result_hist_record                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 실적근태의 히스토리를 적용 후, 결과를 Return 한다                              */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = REJECT : 일근태 반려시 처리                                      */
/*                            = NOT_APPROVED : 일근태 미승인시 처리                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ar_rec                          in    varchar2  실적근태 레코드              */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_result_hist_record (p_ar_rec    IN tb_att_result_n%ROWTYPE
                                      ,p_work_type IN VARCHAR2 DEFAULT NULL
                                      )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
    arh_rec                    tb_att_result_h%ROWTYPE;

BEGIN

    -- 실적 데이타    
    arh_rec.subsidiary_code                := p_ar_rec.subsidiary_code               ;    -- 해외법인코드
    arh_rec.time_and_attendance_date       := p_ar_rec.time_and_attendance_date      ;    -- 근태일자
    arh_rec.shift_type_code                := p_ar_rec.shift_type_code               ;    -- 교대유형코드
    arh_rec.employee_no                    := p_ar_rec.employee_no                   ;    -- 사원번호
    arh_rec.time_and_attendance_yyyymm     := p_ar_rec.time_and_attendance_yyyymm    ;    -- 근태년월
    arh_rec.a_day_of_the_week_code         := p_ar_rec.a_day_of_the_week_code        ;    -- 요일코드
    arh_rec.time_and_attendance_code       := p_ar_rec.time_and_attendance_code      ;    -- 근태코드
    arh_rec.work_hours                     := p_ar_rec.work_hours                    ;    -- 근무시간수
    arh_rec.work_start_time                := p_ar_rec.work_start_time               ;    -- 근무시작시간
    arh_rec.night_shift_flag               := p_ar_rec.night_shift_flag              ;    -- 야근여부
    arh_rec.evening_meal_flag              := p_ar_rec.evening_meal_flag             ;    -- 저녁식사여부
    arh_rec.overtime_sum_hours             := p_ar_rec.overtime_sum_hours            ;    -- 연장근무합계시간수
    arh_rec.weekday_overtime_hours         := p_ar_rec.weekday_overtime_hours        ;    -- 평일연장근무시간수
    arh_rec.holiday_overtime_hours         := p_ar_rec.holiday_overtime_hours        ;    -- 휴일연장근무시간수
    arh_rec.public_holiday_overtime_hours  := p_ar_rec.public_holiday_overtime_hours ;    -- 공공휴일연장근무시간수
    arh_rec.weekday_night_overtime_hours   := p_ar_rec.weekday_night_overtime_hours  ;    -- 평일야간연장근무시간수
    arh_rec.weekday_ot_af_night_work_hours := p_ar_rec.weekday_ot_af_night_work_hours;    -- 평일연장근무후야간근무시간수
    arh_rec.holiday_night_overtime_hours   := p_ar_rec.holiday_night_overtime_hours  ;    -- 휴일야간연장근무시간수
    arh_rec.public_holiday_night_ot_hours  := p_ar_rec.public_holiday_night_ot_hours ;    -- 공공휴일야간연장근무시간수
    arh_rec.normal_night_overtime_hours    := p_ar_rec.normal_night_overtime_hours   ;    -- 정상야간연장근무시간수
    arh_rec.tardy_hours                    := p_ar_rec.tardy_hours                   ;    -- 지각시간수
    arh_rec.early_leave_hours              := p_ar_rec.early_leave_hours             ;    -- 조퇴시간수
    arh_rec.going_out_hours                := p_ar_rec.going_out_hours               ;    -- 외출시간수
    arh_rec.special_bonus_hours            := p_ar_rec.special_bonus_hours           ;    -- 특별보너스시간수
    arh_rec.helpcall_support_hours         := p_ar_rec.helpcall_support_hours        ;    -- 헬프콜지원시간수
    arh_rec.approval_request_id            := p_ar_rec.approval_request_id           ;    -- 승인요청아이디
    arh_rec.request_code                   := p_ar_rec.request_code                  ;    -- 요청코드
    arh_rec.progress_status_code           := p_ar_rec.progress_status_code          ;    -- 진행상태코드
    arh_rec.time_attend_detail_code        := p_ar_rec.time_attend_detail_code       ;    -- 근태상세코드
    arh_rec.time_attend_input_reason_desc  := p_ar_rec.time_attend_input_reason_desc ;    -- 근태입력사유설명
    arh_rec.last_update_flag               := p_ar_rec.base_time_attend_apply_flag   ;    -- 최종수정여부
    arh_rec.creation_user_id               := p_ar_rec.creation_user_id              ;    -- 생성사용자아이디
    arh_rec.creation_date                  := p_ar_rec.creation_date                 ;    -- 생성일자
    arh_rec.last_update_user_id            := p_ar_rec.last_update_user_id           ;    -- 최종수정사용자아이디
    arh_rec.last_update_date               := p_ar_rec.last_update_date              ;    -- 최종수정일자

    SELECT SQ_TB_ATT_RESULT_ID.NEXTVAL INTO arh_rec.history_serial_no FROM dual;  -- 이력일련순서번호
    arh_rec.creation_date    := SYSDATE;  -- history 테이블에 별도의 컬럼이 없는 관계로, 백업된 SYSDATE 를 creation_date 에 적용한다.
    
    arh_rec.history_serial_no := arh_rec.history_serial_no + 1000000000;  -- 트리거의 백업과 구분하기 위함 : 추후 트리거 백업하지 않을시에, 주석처리하고 빼주는 DML 처리할것
    
    -- history 테이블에 별도의 컬럼이 없는 관계로, 백업된 SYSDATE 를 creation_user_id 로 구분한다.
    IF (p_work_type = 'REJECT') THEN  -- 일근태 반려시 처리
        arh_rec.creation_user_id := '-1111';

    ELSIF (p_work_type = 'NOT_APPROVED') THEN  -- 일근태 미승인시 처리
        arh_rec.creation_user_id := '-2222';

    ELSE
        arh_rec.creation_user_id := '-9999';
    END IF;

    -- 이력 생성
    INSERT INTO tb_att_result_h VALUES arh_rec;

    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_result_hist_record;


/*************************************************************************************************/
/* Program Name : apply_att_update_req_record                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 근태수정요청서를 적용 후, 결과를 Return 한다                                   */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_aur_rec                         in    varchar2  근태수정요청서 레코드        */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_update_req_record (p_aur_rec   IN tb_att_update_req_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_update_req_n
        WHERE  request_no     = p_aur_rec.request_no
        AND    request_seq_no = p_aur_rec.request_seq_no
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_update_req_n VALUES p_aur_rec;

    ELSE
        -- 수정
        UPDATE tb_att_update_req_n
        SET    request_date                   = p_aur_rec.request_date                  
              ,subsidiary_code                = p_aur_rec.subsidiary_code               
              ,time_and_attendance_date       = p_aur_rec.time_and_attendance_date      
              ,employee_no                    = p_aur_rec.employee_no                   
              ,shift_type_code                = p_aur_rec.shift_type_code               
              ,time_and_attendance_code       = p_aur_rec.time_and_attendance_code      
              ,work_hours                     = p_aur_rec.work_hours                    
              ,work_start_time                = p_aur_rec.work_start_time               
              ,night_shift_flag               = p_aur_rec.night_shift_flag              
              ,evening_meal_flag              = p_aur_rec.evening_meal_flag             
              ,overtime_sum_hours             = p_aur_rec.overtime_sum_hours            
              ,weekday_overtime_hours         = p_aur_rec.weekday_overtime_hours        
              ,holiday_overtime_hours         = p_aur_rec.holiday_overtime_hours        
              ,public_holiday_overtime_hours  = p_aur_rec.public_holiday_overtime_hours 
              ,weekday_night_overtime_hours   = p_aur_rec.weekday_night_overtime_hours  
              ,weekday_ot_af_night_work_hours = p_aur_rec.weekday_ot_af_night_work_hours
              ,holiday_night_overtime_hours   = p_aur_rec.holiday_night_overtime_hours  
              ,public_holiday_night_ot_hours  = p_aur_rec.public_holiday_night_ot_hours 
              ,normal_night_overtime_hours    = p_aur_rec.normal_night_overtime_hours   
              ,tardy_hours                    = p_aur_rec.tardy_hours                   
              ,early_leave_hours              = p_aur_rec.early_leave_hours             
              ,going_out_hours                = p_aur_rec.going_out_hours               
              ,special_bonus_hours            = p_aur_rec.special_bonus_hours           
              ,helpcall_support_hours         = p_aur_rec.helpcall_support_hours        
              ,data_old_new_type_code         = p_aur_rec.data_old_new_type_code        
              ,update_request_reason_desc     = p_aur_rec.update_request_reason_desc    
              ,approval_request_id            = p_aur_rec.approval_request_id           
              ,request_code                   = p_aur_rec.request_code                  
              ,progress_status_code           = p_aur_rec.progress_status_code          
              ,time_attend_detail_code        = p_aur_rec.time_attend_detail_code       
              ,time_attend_input_reason_desc  = p_aur_rec.time_attend_input_reason_desc 
              ,time_attend_update_reason_desc = p_aur_rec.time_attend_update_reason_desc
              ,last_update_user_id            = p_aur_rec.last_update_user_id           
              ,last_update_date               = p_aur_rec.last_update_date              
        WHERE  request_no     = p_aur_rec.request_no
        AND    request_seq_no = p_aur_rec.request_seq_no
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_update_req_record;

/*************************************************************************************************/
/* Program Name : apply_att_lt_ta_plan_record                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 장기근태계획을 적용 후, 결과를 Return 한다                                     */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_altp_rec                        in    varchar2  장기근태계획 레코드          */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_lt_ta_plan_record (p_altp_rec    IN tb_att_lt_time_attend_plan_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_lt_time_attend_plan_n
        WHERE  planning_id     = p_altp_rec.planning_id
        AND    subsidiary_code = p_altp_rec.subsidiary_code
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_lt_time_attend_plan_n VALUES p_altp_rec;

    ELSE
        -- 수정
        UPDATE tb_att_lt_time_attend_plan_n
        SET    employee_no                   = p_altp_rec.employee_no                  
              ,time_and_attendance_code      = p_altp_rec.time_and_attendance_code     
              ,plan_start_date               = p_altp_rec.plan_start_date              
              ,plan_end_date                 = p_altp_rec.plan_end_date                
              ,request_reason_content        = p_altp_rec.request_reason_content       
              ,progress_status_code          = p_altp_rec.progress_status_code         
              ,approval_request_id           = p_altp_rec.approval_request_id          
              ,request_no                    = p_altp_rec.request_no                   
              ,request_code                  = p_altp_rec.request_code                 
              ,time_attend_detail_code       = p_altp_rec.time_attend_detail_code      
              ,time_attend_input_reason_desc = p_altp_rec.time_attend_input_reason_desc
              ,last_update_user_id           = p_altp_rec.last_update_user_id          
              ,last_update_date              = p_altp_rec.last_update_date             
        WHERE  planning_id     = p_altp_rec.planning_id
        AND    subsidiary_code = p_altp_rec.subsidiary_code
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_lt_ta_plan_record;


/*************************************************************************************************/
/* Program Name : apply_att_annual_leave_record                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 연차휴가를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_aal_rec                         in    varchar2  연차휴가 레코드              */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_annual_leave_record (p_aal_rec    IN tb_att_annual_leave_n%ROWTYPE
                                       ,p_work_type IN VARCHAR2 DEFAULT NULL
                                       )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_annual_leave_n
        WHERE  subsidiary_code            = p_aal_rec.subsidiary_code
        AND    employee_no                = p_aal_rec.employee_no
        AND    time_and_attendance_yyyymm = p_aal_rec.time_and_attendance_yyyymm
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_annual_leave_n VALUES p_aal_rec;

    ELSE
        -- 수정
        UPDATE tb_att_annual_leave_n
        SET    hire_date                     = p_aal_rec.hire_date                    
              ,occur_basic_annual_leave_days = p_aal_rec.occur_basic_annual_leave_days
              ,occur_monthly_ann_lv_days     = p_aal_rec.occur_monthly_ann_lv_days    
              ,annual_calibration_days       = p_aal_rec.annual_calibration_days
              ,use_annual_leave_days         = p_aal_rec.use_annual_leave_days        
              ,residual_annual_leave_days    = p_aal_rec.residual_annual_leave_days   
              ,annual_compensation_days      = p_aal_rec.annual_compensation_days
              ,apply_date                    = p_aal_rec.apply_date                   
              ,last_update_user_id           = p_aal_rec.last_update_user_id          
              ,last_update_date              = p_aal_rec.last_update_date             
        WHERE  subsidiary_code            = p_aal_rec.subsidiary_code
        AND    employee_no                = p_aal_rec.employee_no
        AND    time_and_attendance_yyyymm = p_aal_rec.time_and_attendance_yyyymm
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_annual_leave_record;


/*************************************************************************************************/
/* Program Name : apply_att_idcard_acs_record                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : IDCARD 출입시간을 적용 후, 결과를 Return 한다                                  */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_iat_rec                         in    varchar2  ID카드출입 레코드            */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_idcard_acs_record (p_iat_rec   IN tb_att_idcard_acs_time_n%ROWTYPE
                                     ,p_work_type IN VARCHAR2 DEFAULT NULL
                                     )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_idcard_acs_time_n
        WHERE  subsidiary_code          = p_iat_rec.subsidiary_code
        AND    employee_no              = p_iat_rec.employee_no
        AND    time_and_attendance_date = p_iat_rec.time_and_attendance_date
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_idcard_acs_time_n VALUES p_iat_rec;

    ELSE
        -- 수정
        UPDATE tb_att_idcard_acs_time_n
        SET    check_in_date       = p_iat_rec.check_in_date                    
              ,check_out_date      = p_iat_rec.check_out_date
              ,last_update_user_id = p_iat_rec.last_update_user_id          
              ,last_update_date    = p_iat_rec.last_update_date             
        WHERE  subsidiary_code          = p_iat_rec.subsidiary_code
        AND    employee_no              = p_iat_rec.employee_no
        AND    time_and_attendance_date = p_iat_rec.time_and_attendance_date
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_idcard_acs_record;


/*************************************************************************************************/
/* Program Name : apply_att_contract_record                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : PIC 정보를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_iat_rec                         in    varchar2  ID카드출입 레코드            */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_contract_record (p_ac_rec    IN tb_att_contract_n%ROWTYPE
                                   ,p_work_type IN VARCHAR2 DEFAULT NULL
                                   )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_contract_n
        WHERE  subsidiary_code             = p_ac_rec.subsidiary_code
        AND    time_attend_contact_user_id = p_ac_rec.time_attend_contact_user_id
        AND    organization_id             = p_ac_rec.organization_id
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_contract_n VALUES p_ac_rec;

    ELSE
        -- 수정
        UPDATE tb_att_contract_n
        SET    effective_start_date = p_ac_rec.effective_start_date                    
              ,effective_end_date   = p_ac_rec.effective_end_date
              ,last_update_user_id  = p_ac_rec.last_update_user_id          
              ,last_update_date     = p_ac_rec.last_update_date             
        WHERE  subsidiary_code             = p_ac_rec.subsidiary_code
        AND    time_attend_contact_user_id = p_ac_rec.time_attend_contact_user_id
        AND    organization_id             = p_ac_rec.organization_id
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_contract_record;


/*************************************************************************************************/
/* Program Name : apply_att_holiday_info_record                                                  */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 휴일정보를 적용 후, 결과를 Return 한다                                         */
/*                레코드타입의 데이타를 기준으로 반영하므로, 모든 값이 셋팅되어 있어야 한다.     */
/*                                                                                               */
/*                p_work_type = NULL : 데이타 존재여부 체크 후 INSERT/UPDATE 처리                */
/*                            = CREATE : 데이타 존재여부 체크 없이 INSERT 처리                   */
/*                            = UPDATE : 데이타 존재여부 체크 없이 UPDATE 처리                   */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_iat_rec                         in    varchar2  ID카드출입 레코드            */
/*                p_work_type                       in    varchar2  작업유형                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
FUNCTION apply_att_holiday_info_record (p_hi_rec    IN tb_att_holiday_info_n%ROWTYPE
                                       ,p_work_type IN VARCHAR2 DEFAULT NULL
                                       )
RETURN VARCHAR2
IS
    v_data_count               NUMBER;
BEGIN

    IF (p_work_type IS NULL) THEN

        SELECT COUNT(*)
        INTO   v_data_count
        FROM   tb_att_holiday_info_n
        WHERE  subsidiary_code = p_hi_rec.subsidiary_code
        AND    holiday_date    = p_hi_rec.holiday_date
        ;
        
    -- 생성
    ELSIF (p_work_type = 'CREATE') THEN
        v_data_count := 0;
        
    -- 수정
    ELSIF (p_work_type = 'UPDATE') THEN
        v_data_count := 1;

    ELSE
        RETURN 'N';
    END IF;

    -- 없으면        
    IF (v_data_count = 0) THEN

        -- 생성
        INSERT INTO tb_att_holiday_info_n VALUES p_hi_rec;

    ELSE
        -- 수정
        UPDATE tb_att_holiday_info_n
        SET    time_and_attendance_yyyy = p_hi_rec.time_and_attendance_yyyy                    
              ,holiday_code             = p_hi_rec.holiday_code
              ,holiday_name             = p_hi_rec.holiday_name
              ,time_and_attendance_code = p_hi_rec.time_and_attendance_code
              ,last_update_user_id      = p_hi_rec.last_update_user_id          
              ,last_update_date         = p_hi_rec.last_update_date             
        WHERE  subsidiary_code = p_hi_rec.subsidiary_code
        AND    holiday_date    = p_hi_rec.holiday_date
        ;
    END IF;
    
    RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    RETURN 'N';

END apply_att_holiday_info_record;


/*************************************************************************************************/
/* Program Name : valid_att_annual_leave_proc                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 수정요청서 결재요청을 처리후 결과를 Return 한다                                */
/*                                                                                               */
/*                p_att_type = INPUT      : 근태입력                                             */
/*                             APPROVAL   : 근태결재                                             */
/*                             REJECT     : 근태반려                                             */
/*                             UPD_REQ    : 수정요청서 요청                                      */
/*                             UPD_APPR   : 수정요청서 결재                                      */
/*                             LT_TA_REQ  : 장기근태계획 요청                                    */
/*                             LT_TA_APPR : 장기근태계획 결재                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_ret_code                        in    number    처리결과코드                 */
/*                p_ret_msg                         in    varchar2  처리결과메시지               */
/*                p_user_id                         in    varchar2  근태코드                     */
/*                p_att_type                        in    varchar2  근태유형                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*                p_time_and_attendance_date        in    date      근태일자                     */
/*                p_request_no                      in    varchar2  수정요청서번호/PLANNING_ID   */
/*                p_emp_cat                         in    Varchar2  발령범주(LGD_OW/LGD_LW)      */
/*                p_new_result_attendance_code      in    varchar2  신규실적근태코드             */
/*                p_new_plan_attendance_code        in    varchar2  신규계획 근태코드            */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/* 2018/03/02  손수양C     반일휴가추가로 AL 에 HL 체크 추가함                                   */
/*                                                                                               */
/*************************************************************************************************/
 PROCEDURE valid_att_annual_leave_proc (p_ret_code                      OUT NUMBER
                                      ,p_ret_msg                       OUT VARCHAR2
                                      ,p_user_id                       IN  VARCHAR2
                                      ,p_att_type                      IN  VARCHAR2
                                      ,p_subsidiary_code               IN  VARCHAR2
                                      ,p_employee_no                   IN  VARCHAR2 DEFAULT NULL     -- 사원번호
                                      ,p_lang_code                     IN  VARCHAR2 DEFAULT 'en'
                                      ,p_time_and_attendance_date      IN  DATE     DEFAULT NULL     -- Plan 기준일자
                                      ,p_request_no                    IN  VARCHAR2 DEFAULT NULL     -- 수정요청서 번호
                                      ,p_emp_cat                       IN  VARCHAR2 DEFAULT NULL     -- 발령범주
                                      ,p_new_result_attendance_code    IN  VARCHAR2 DEFAULT NULL     -- 신규실적근태코드(화면에서 입력된 값)
                                      ,p_new_plan_attendance_code      IN  VARCHAR2 DEFAULT NULL     -- 신규계획 근태코드(화면에서 입력된 값)
                                      )
IS
    v_time_and_attendance_date         tb_att_plan_n.time_and_attendance_date%TYPE;
    v_time_and_attendance_yyyymm       tb_att_plan_n.time_and_attendance_yyyymm%TYPE;

    v_result_time_attendance_date      tb_att_plan_n.time_and_attendance_date%TYPE;
    v_result_yyyymm                    tb_att_plan_n.time_and_attendance_yyyymm%TYPE;
    v_leave_yyyymm                     tb_att_plan_n.time_and_attendance_yyyymm%TYPE;


    v_plan_use_annual_leave_days       tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    v_result_use_annual_leave_days     tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    v_lt_pln_use_annual_leave_days     tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    v_upd_use_annual_leave_days        tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    
    v_enable_use_annual_leave_days     tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    
    v_future_creaion_months            NUMBER                                                  := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'FUTURE_CREATION_MONTHS', 'A1');
    
    v_plan_upd_cnt                     NUMBER                                                  := 0;

    --ac_rec                             tb_att_code_c%ROWTYPE;
    prev_aal_rec                       tb_att_annual_leave_n%ROWTYPE;
    curr_aal_rec                       tb_att_annual_leave_n%ROWTYPE;
    ap_rec                             tb_att_plan_n%ROWTYPE;
    v_desc                             varchar2(1000) := '';
    

    -- 장기근태 계획 Validation    
    FUNCTION valid_lt_ta_annual_leave_func (c_att_type                     IN  VARCHAR2
                                           ,c_subsidiary_code              IN  VARCHAR2
                                           ,c_employee_no                  IN  VARCHAR2
                                           --,c_time_and_attendance_date     IN  DATE
                                           ,c_planning_id                  IN  VARCHAR2
                                           )
    RETURN NUMBER
    IS
        v_lt_pln_use_annual_leave_days       tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    BEGIN
        -- 기준일자 이후로 진행중인 장기근태계획정보 : 승인된건은 계획근태에 바로 반영됨
        --2018/03/02 :  반일연차 추가로 반일 연차와 연차를 분리해서 추출해서 가져온다.
        
        SELECT NVL(SUM(a.paid_days), 0)
        INTO   v_lt_pln_use_annual_leave_days
        
        FROM ( 
                SELECT NVL(cc.paid_days,0) paid_days
                FROM   tb_att_lt_time_attend_plan_n al
                      ,tb_att_base_bas_n            bb
                      ,tb_att_plan_n                ap
                      ,tb_att_code_c                cc
                WHERE  al.subsidiary_code                = c_subsidiary_code
                AND    al.employee_no                    = c_employee_no
                --AND    al.plan_end_date                 >= c_time_and_attendance_date 
                AND    al.plan_end_date                 >= TRUNC(SYSDATE)    -- 계획은 과거는 의미 없으므로, 오늘(SYSDATE) 날짜(포함) 이후만 해당
                AND    al.time_and_attendance_code      IN ( 'AL' )  
                AND    (al.progress_status_code         IN ( '10', '20', '30' )  -- 10:PRE REQUEST,20:REQUESTED,30:INPROGRESS,40:APPROVED
                        OR
                        al.planning_id                   = c_planning_id
                       )
                AND    al.subsidiary_code                = bb.subsidiary_code
                --AND    bb.time_and_attendance_date BETWEEN GREATEST(al.plan_start_date, c_time_and_attendance_date) AND al.plan_end_date  -- 장기근태계획기간
                AND    bb.time_and_attendance_date BETWEEN GREATEST(al.plan_start_date, TRUNC(SYSDATE)) AND al.plan_end_date  -- 장기근태계획기간
                AND    bb.shift_type_code                = lgvhr_common_pkg.get_shift_type_code_func(al.subsidiary_code, al.employee_no, bb.time_and_attendance_date)
                AND    bb.time_and_attendance_code       = 'NW'  -- 기본근태가 출근(Normal Working) 인 날만
                AND    al.subsidiary_code                = ap.subsidiary_code
                AND    al.employee_no                    = ap.employee_no
                AND    bb.time_and_attendance_date       = ap.time_and_attendance_date        
                AND    ap.time_and_attendance_code      <> 'AL'  -- 중복이 허용되므로 이미 연차는 제외
                AND    cc.subsidiary_code                = c_subsidiary_code
                AND    cc.time_and_attendance_code       = al.time_and_attendance_code
                -- 2018/03/02 : 반일휴가 추가 
                UNION ALL
                SELECT NVL(cc.paid_days,0) paid_days
                FROM   tb_att_lt_time_attend_plan_n al
                      ,tb_att_base_bas_n            bb
                      ,tb_att_plan_n                ap
                      ,tb_att_code_c                cc
                WHERE  al.subsidiary_code                = c_subsidiary_code
                AND    al.employee_no                    = c_employee_no
                --AND    al.plan_end_date                 >= c_time_and_attendance_date 
                AND    al.plan_end_date                 >= TRUNC(SYSDATE)    -- 계획은 과거는 의미 없으므로, 오늘(SYSDATE) 날짜(포함) 이후만 해당
                AND    al.time_and_attendance_code      IN ( 'HL', 'HL_FN', 'HL_SN' ) 
                AND    (al.progress_status_code         IN ( '10', '20', '30' )  -- 10:PRE REQUEST,20:REQUESTED,30:INPROGRESS,40:APPROVED
                        OR
                        al.planning_id                   = c_planning_id
                       )
                AND    al.subsidiary_code                = bb.subsidiary_code
                --AND    bb.time_and_attendance_date BETWEEN GREATEST(al.plan_start_date, c_time_and_attendance_date) AND al.plan_end_date  -- 장기근태계획기간
                AND    bb.time_and_attendance_date BETWEEN GREATEST(al.plan_start_date, TRUNC(SYSDATE)) AND al.plan_end_date  -- 장기근태계획기간
                AND    bb.shift_type_code                = lgvhr_common_pkg.get_shift_type_code_func(al.subsidiary_code, al.employee_no, bb.time_and_attendance_date)
                AND    bb.time_and_attendance_code       = 'NW'  -- 기본근태가 출근(Normal Working) 인 날만
                AND    al.subsidiary_code                = ap.subsidiary_code
                AND    al.employee_no                    = ap.employee_no
                AND    bb.time_and_attendance_date       = ap.time_and_attendance_date
                AND    ap.time_and_attendance_code NOT IN ( 'HL', 'HL_FN', 'HL_SN' )  -- 중복이 허용되므로 이미 연차는 제외
                AND    cc.subsidiary_code                = c_subsidiary_code
                AND    cc.time_and_attendance_code       = al.time_and_attendance_code
                ) a
        
        ;

dbms_output.put_line ('장기근태계획 연차일수 = ' || v_lt_pln_use_annual_leave_days);
        RETURN v_lt_pln_use_annual_leave_days;  -- 장기근태계획 연차일수

    EXCEPTION
    WHEN OTHERS THEN
        RETURN 999;
    END valid_lt_ta_annual_leave_func;
    

    -- 수정요청서 Validation    
    FUNCTION valid_upd_annual_leave_func (c_att_type                     IN  VARCHAR2
                                         ,c_subsidiary_code              IN  VARCHAR2
                                         ,c_employee_no                  IN  VARCHAR2
                                         --,c_time_and_attendance_date     IN  DATE
                                         ,c_request_no                   IN  VARCHAR2
                                         )
    RETURN NUMBER
    IS
        v_upd_new_annual_leave_days       tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
        v_upd_old_annual_leave_days       tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    BEGIN
        -- 진행중인 수정요청서정보 : 월근태마감전까지의 수정요청서만 유효
        -- 2018/03/02  : 반일휴가 추가하면서 ac_rec 에서 가져오지 않고 tb_att_code_c 테이블을 엮음
        --               ac_rec는 AL 코드만 가져와서 넣기 때문에 처리가 불가능함  
        SELECT NVL(SUM(CASE WHEN data_old_new_type_code = 'OLD' THEN cc.paid_days ELSE 0 END), 0)
              ,NVL(SUM(CASE WHEN data_old_new_type_code = 'NEW' THEN cc.paid_days ELSE 0 END), 0)
        INTO   v_upd_old_annual_leave_days
              ,v_upd_new_annual_leave_days
        FROM   tb_att_update_req_n au
             , tb_att_code_c       cc
        WHERE  au.subsidiary_code            = c_subsidiary_code
        AND    au.employee_no                = c_employee_no
/*
        AND    (au.progress_status_code     IN ( '10', '20', '30' )  -- 10:PRE REQUEST,20:REQUESTED,30:INPROGRESS,40:APPROVED
                OR
                au.request_no                = c_request_no
               )
*/
        AND    au.progress_status_code      IN ( '10', '20', '30' )  -- 10:PRE REQUEST,20:REQUESTED,30:INPROGRESS,40:APPROVED

        AND    au.time_and_attendance_code   IN ( 'AL','HL', 'HL_FN', 'HL_SN' )
        AND    SYSDATE                       < lgvatt_common_pkg.get_att_close_time (au.subsidiary_code
                                                                                    ,'UPD_REQ'
                                                                                    ,au.time_and_attendance_date
                                                                                    ,lgvhr_common_pkg.get_shift_type_code_func(au.subsidiary_code, au.employee_no, au.time_and_attendance_date)
                                                                                    ,NULL
                                                                                    )
        AND    cc.subsidiary_code                = c_subsidiary_code
        AND    cc.time_and_attendance_code       = au.time_and_attendance_code                                                                                   
        ;

dbms_output.put_line ('수정요청 사용연차일수 = ' || (v_upd_new_annual_leave_days - v_upd_old_annual_leave_days));
        RETURN v_upd_new_annual_leave_days   -- 수정후 연차일수
             - v_upd_old_annual_leave_days;  -- 수정전 연차일수

    EXCEPTION
    WHEN OTHERS THEN
        RETURN 999;
    END valid_upd_annual_leave_func;
    

    -- 일근태 Validation    
    FUNCTION valid_input_annual_leave_func (c_att_type                     IN  VARCHAR2
                                           ,c_subsidiary_code              IN  VARCHAR2
                                           ,c_employee_no                  IN  VARCHAR2
                                           --,c_time_and_attendance_date     IN  DATE
                                           )
    RETURN NUMBER
    IS
        v_plan_use_annual_leave_days       tb_att_annual_leave_n.use_annual_leave_days%TYPE        := 0;
    BEGIN
        -- 기준일자 이후의 연차계획
        -- 2018/03/02 : 반일 휴가 추가 
        SELECT NVL(SUM(cc.paid_days), 0)
        INTO   v_plan_use_annual_leave_days
        FROM   tb_att_plan_n       ap
              ,tb_att_code_c       cc
        WHERE  ap.subsidiary_code           = c_subsidiary_code
        AND    ap.employee_no               = c_employee_no
        --AND    ap.time_and_attendance_date >= c_time_and_attendance_date
        AND    ap.time_and_attendance_date >= TRUNC(SYSDATE)  -- 계획은 과거는 의미 없으므로, 오늘(SYSDATE) 날짜(포함) 이후만 해당
        AND    ap.time_and_attendance_code  IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )
        AND    cc.subsidiary_code                = c_subsidiary_code
        AND    cc.time_and_attendance_code       = ap.time_and_attendance_code  
        ;

dbms_output.put_line ('계획 사용연차일수 = ' || v_plan_use_annual_leave_days);
        RETURN v_plan_use_annual_leave_days;  -- 계획 연차일수
    EXCEPTION
    WHEN OTHERS THEN
        RETURN 999;
    END valid_input_annual_leave_func;

BEGIN

    p_ret_code := 0;
    p_ret_msg  := ' ';
    v_enable_use_annual_leave_days := 0;

    --ac_rec := lgvatt_common_pkg.get_att_code_rec (p_subsidiary_code, 'AL');  -- 연차 코드정보

    v_time_and_attendance_date   := TRUNC(NVL(p_time_and_attendance_date, SYSDATE));  -- 기준일자 : 오늘
    v_time_and_attendance_yyyymm := TO_CHAR(v_time_and_attendance_date, 'YYYYMM');  -- 기준근태년월 : 당월

    -- 실적기준일자
    SELECT MIN(time_and_attendance_date)  -- 실적기준으로 평일은 1일이지만, 에러방지를 위하여 Min 처리
    INTO   v_result_time_attendance_date
    FROM   TABLE(CAST(lgvatt_common_pkg.get_input_date(p_subsidiary_code, v_time_and_attendance_date, 'RESULT') AS lgvatt_input_date_tbl))
    WHERE  holiday_flag = 'N'
    ;

    -- 대상자만큼
    FOR per IN (SELECT employee_no                                                          AS employee_no
                      ,MAX(DECODE(data_old_new_type_code, 'OLD', time_and_attendance_code)) AS old_time_attendance_code
                      ,MIN(DECODE(data_old_new_type_code, 'NEW', time_and_attendance_code)) AS new_time_attendance_code
                      ,MIN(time_and_attendance_date)                                        AS min_time_attendance_date
                      ,MAX(time_and_attendance_date)                                        AS max_time_attendance_date
                FROM   tb_att_update_req_n
                WHERE  request_no                = p_request_no     
                AND    p_att_type               IN ( 'UPD_REQ', 'UPD_APPR' )          -- 수정요청서: 하나의 요청서에 여러명(Line Worker:여러명, Office Worker:1명)
                GROUP BY employee_no
                HAVING MAX(DECODE(data_old_new_type_code, 'OLD', time_and_attendance_code)) = 'AL'
                    OR MIN(DECODE(data_old_new_type_code, 'NEW', time_and_attendance_code)) = 'AL'
                    OR MAX(DECODE(data_old_new_type_code, 'OLD', time_and_attendance_code)) = 'HL' --2018/03/02 : 반일휴가 추가 
                    OR MIN(DECODE(data_old_new_type_code, 'NEW', time_and_attendance_code)) = 'HL' --2018/03/02 : 반일휴가 추가
                    OR MAX(DECODE(data_old_new_type_code, 'OLD', time_and_attendance_code)) = 'HL_FN' --2018/08/21 : 반일휴가 추가 (야간 : First-part)
                    OR MIN(DECODE(data_old_new_type_code, 'NEW', time_and_attendance_code)) = 'HL_FN' --2018/08/21 : 반일휴가 추가 (야간 : First-part)
                    OR MAX(DECODE(data_old_new_type_code, 'OLD', time_and_attendance_code)) = 'HL_SN' --2018/08/21 : 반일휴가 추가 (야간 : Second-part)
                    OR MIN(DECODE(data_old_new_type_code, 'NEW', time_and_attendance_code)) = 'HL_SN' --2018/08/21 : 반일휴가 추가 (야간 : Second-part)
                UNION ALL
                SELECT employee_no                                                          AS employee_no
                      ,time_and_attendance_code                                             AS old_time_attendance_code
                      ,time_and_attendance_code                                             AS new_time_attendance_code
                      ,plan_start_date                                                      AS min_time_attendance_date
                      ,plan_end_date                                                        AS max_time_attendance_date
                FROM   tb_att_lt_time_attend_plan_n
                WHERE  p_att_type               IN ( 'LT_TA_REQ', 'LT_TA_APPR' )      -- 장기근태계획 : 한사람 : 한번에 1개의 근태계획이므로
                AND    planning_id               = p_request_no
                AND    time_and_attendance_code  IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )                          -- 연차만 --2018/03/02 : 반일휴가 추가 
                UNION ALL
                SELECT p_employee_no                                                        AS employee_no
                      ,'AL'                                                                 AS old_time_attendance_code
                      ,'AL'                                                                 AS new_time_attendance_code
                      ,v_result_time_attendance_date                                        AS min_time_attendance_date
                      ,v_time_and_attendance_date                                           AS max_time_attendance_date
                FROM   dual
                WHERE  p_att_type               IN ( 'INPUT', 'APPROVAL', 'REJECT','MODIFY' )  -- 일근태 : 한사람 : 연차여부는 화면에서 체크. (Office Worker 는 한번만 가능하지만, Line Worker는 여러번 수정 가능)
                                
               )
    LOOP
        -- 입력/승인일때 new 근태코드가 연차가 아니면, 잔여연차가 늘어나는 것이므로, 연차체크는 하지 않음
        IF (p_att_type IN ( 'INPUT', 'APPROVAL' )) THEN
        
            SELECT COUNT(*)
            INTO   v_plan_upd_cnt
            FROM   tb_att_plan_n
            WHERE  time_and_attendance_date >= TRUNC(SYSDATE)  -- 계획은 오늘 이후만 의미 있음
            AND    employee_no               = p_employee_no
            AND    last_update_date         >= SYSDATE-(1/24/60/2)  -- 현재 파라미터는 기준일자가 NULL 로 넘어오므로, 시스템반영시간을 감안하여 30초전에 수정된 계획이 있는지 체크
            ;

            -- 입력된 실적값이 휴가가 아니고, 계획이 변경되지 않았거나 입력된 계획값이 휴가가 아니면, 연차체크는 하지 않음 : APPROVAL 일때는 cnt = 0 이므로 체크하지 않음
            -- 2018/03/02 : 반일휴가 추가 
            IF (NVL(p_new_result_attendance_code, 'NW') NOT IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' ) AND (v_plan_upd_cnt = 0 OR (v_plan_upd_cnt > 0 AND NVL(p_new_plan_attendance_code, 'NW') NOT IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )))) THEN
                GOTO APPLY_ANNUAL_LEAVE;
            END IF;
            
            -- APPROVAL 일때는 입력일때 처리되었음로, 체크하지 않음
            IF (p_att_type = 'APPROVAL') THEN
                GOTO APPLY_ANNUAL_LEAVE;
            END IF;
        END IF;
        
        -- 반려이거나 New 근태코드가 연차가 아니면, 잔여연차가 늘어나는 것이므로, 연차체크는 하지 않음
        -- 2018/03/02 : 반일휴가 추가 
        IF (p_att_type IN ( 'REJECT' ) OR per.new_time_attendance_code NOT IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )) THEN
            GOTO APPLY_ANNUAL_LEAVE;
        END IF;

        
        -- 계획 사용연차일수 : 일근태 입력/결재
        v_plan_use_annual_leave_days := valid_input_annual_leave_func (p_att_type, p_subsidiary_code, per.employee_no);  --, v_time_and_attendance_date);  -- PLAN 은 오늘(SYSDATE) 이후(포함)만 의미 있음 FDFD
        
        -- 수정요청 사용연차일수 : 수정요청서 선택/요청/결재
        v_upd_use_annual_leave_days := valid_upd_annual_leave_func (p_att_type, p_subsidiary_code, per.employee_no, p_request_no);--, v_time_and_attendance_date, p_request_no);
        
        -- 장기근태계획 연차일수 : 장기근태계획 요청/결재
        v_lt_pln_use_annual_leave_days := valid_lt_ta_annual_leave_func (p_att_type, p_subsidiary_code, per.employee_no, p_request_no);  --, v_time_and_attendance_date, p_request_no);

        v_result_yyyymm := TO_CHAR(per.min_time_attendance_date, 'YYYYMM');  -- 입력/수정 해당월이후 실적정보 : 예를 들어, 12.4 에 11월의 수정요청을 하는 경우에, 11월/12월 모두 연차실적 있을수 있음
        v_leave_yyyymm  := TO_CHAR(ADD_MONTHS(per.min_time_attendance_date, -1), 'YYYYMM');  -- 전월 연차정보
        
        -- 실적 사용연차일수
        -- 2018/03/02 : HL 추가로 CODE 테이블 조인 
        SELECT NVL(SUM(cc.paid_days), 0)
        INTO   v_result_use_annual_leave_days
        FROM   tb_att_result_n   ar
              ,tb_att_code_c     cc
        WHERE  ar.subsidiary_code                  = p_subsidiary_code
        AND    ar.employee_no                      = p_employee_no
        AND    ar.time_and_attendance_yyyymm BETWEEN v_result_yyyymm AND SUBSTR(v_result_yyyymm, 1, 4) || '12'
        AND    ar.time_and_attendance_code         IN ( 'AL' ,'HL', 'HL_FN', 'HL_SN' )
        AND    cc.subsidiary_code               = p_subsidiary_code
        AND    cc.time_and_attendance_code      = ar.time_and_attendance_code  
        ;

        prev_aal_rec := lgvatt_common_pkg.get_att_annual_leave_rec (p_subsidiary_code, per.employee_no, v_leave_yyyymm);  -- 전월 연차정보
        IF (prev_aal_rec.residual_annual_leave_days IS NULL) THEN  prev_aal_rec.residual_annual_leave_days := 0;  END IF;
        
        curr_aal_rec := lgvatt_common_pkg.get_att_annual_leave_rec (p_subsidiary_code, per.employee_no, v_result_yyyymm);  -- 당월 연차정보
        
dbms_output.put_line ('잔여 연차일수 = ' || prev_aal_rec.residual_annual_leave_days || ', 휴가년월 = ' || v_leave_yyyymm);

        -- 사용가능 연차일수
        v_enable_use_annual_leave_days := prev_aal_rec.residual_annual_leave_days  -- 전월 잔여연차일수
                                        - v_result_use_annual_leave_days           -- 실적 연차일수
                                        - v_plan_use_annual_leave_days             -- 계획 연차일수
                                        - v_upd_use_annual_leave_days              -- 수정요청서 연차일수
                                        - v_lt_pln_use_annual_leave_days           -- 장기근태계획 연차일수

                                        + NVL(curr_aal_rec.occur_basic_annual_leave_days, 0)  -- 당월 발생 기초일수
                                        + NVL(curr_aal_rec.occur_monthly_ann_lv_days    , 0)  -- 당월 발생 연차일수
                                        + NVL(curr_aal_rec.annual_calibration_days      , 0)  -- 당월 연차 보정일수
                                        - NVL(curr_aal_rec.annual_compensation_days     , 0)  -- 당월 연차 보상일수
                                        ;
/*dbms_output.put_line ('사용가능 연차일수 = ' || v_enable_use_annual_leave_days || '=' || prev_aal_rec.residual_annual_leave_days
                                                                               || '-' || v_result_use_annual_leave_days 
                                                                               || '-' || v_plan_use_annual_leave_days 
                                                                               || '-' || v_upd_use_annual_leave_days 
                                                                               || '-' || v_lt_pln_use_annual_leave_days 
                                                                               || '+' || NVL(curr_aal_rec.occur_basic_annual_leave_days, 0)
                                                                               || '+' || NVL(curr_aal_rec.occur_monthly_ann_lv_days, 0) 
                                                                               || '+' || NVL(curr_aal_rec.annual_calibration_days, 0) 
                                                                               || '-' || NVL(curr_aal_rec.annual_compensation_days, 0));*/
                                                                               

       /*v_desc :=  '사용가능 =>'||v_enable_use_annual_leave_days||'<BR>'||
                 '전월 잔여연차일수=>'||  to_char(nvl(prev_aal_rec.residual_annual_leave_days,0))||'<BR>'||
                  '실적 연차일수=>'||  to_char(v_result_use_annual_leave_days)||'<BR>'||                                                                                 
                  '계획 연차일수=>'||  to_char(v_plan_use_annual_leave_days)||'<BR>'||
                  '수정요청서 연차일수=>'||  to_char(v_upd_use_annual_leave_days)||'<BR>'||
                  '장기근태계획 연차일수=>'||  to_char(v_lt_pln_use_annual_leave_days)||'<BR>'||
                  '당월 발생 기초일수=>'||  to_char(NVL(curr_aal_rec.occur_basic_annual_leave_days, 0))||'<BR>'||
                  '당월 발생 연차일수=>'||  to_char(NVL(curr_aal_rec.occur_monthly_ann_lv_days    , 0))||'<BR>'||
                  '당월 연차 보정일수=>'||  to_char(NVL(curr_aal_rec.annual_calibration_days    , 0))||'<BR>'||
                  '당월 연차 보상일수=>'||  to_char(NVL(curr_aal_rec.annual_compensation_days    , 0))||'<BR>';*/

              
                  
        <<APPLY_ANNUAL_LEAVE>>        
        -- 사용가능한 잔여연차
        IF (p_ret_code = 0 AND v_enable_use_annual_leave_days >= 0) THEN
            
            IF    (p_att_type IN ( 'INPUT', 'REJECT' )) THEN  -- 근태입력  
            
                lgvatt_transaction_pkg.apply_att_use_res_ann_lv (p_ret_code, p_ret_msg, p_user_id, p_subsidiary_code, per.employee_no, TO_CHAR(v_result_time_attendance_date, 'YYYYMM'), 'N', 'Y');
            
            ELSIF (p_att_type = 'APPROVAL'  ) THEN  -- 근태결재 : 근태입력시에 연차정보 반영됨
                NULL;

            ELSIF (p_att_type = 'UPD_APPR'  ) THEN  -- 수정요청서 결재
                 

                lgvatt_transaction_pkg.apply_att_use_res_ann_lv (p_ret_code, p_ret_msg, p_user_id, p_subsidiary_code, per.employee_no, TO_CHAR(v_result_time_attendance_date, 'YYYYMM'), 'N', 'Y');
                
            ELSIF (p_att_type = 'LT_TA_APPR' ) THEN  -- 장기근태계획 결재

                -- 장기근태계획 계획근태에 반영 : 계획이므로 연차정보는 반영없음
                lgvatt_transaction_pkg.apply_att_lt_ta_plan_approval (p_ret_code, p_ret_msg, p_user_id, p_subsidiary_code, p_request_no, 'APPROVAL');
            ELSIF (p_att_type = 'MODIFY'  ) THEN  -- 근태 결재자가 수정하는 경우 
                lgvatt_transaction_pkg.apply_att_use_res_ann_lv (p_ret_code, p_ret_msg, p_user_id, p_subsidiary_code, per.employee_no, TO_CHAR(v_result_time_attendance_date, 'YYYYMM'), 'N', 'Y');
            END IF;

        ELSE
            p_ret_code := -1;

            IF    (p_att_type = 'INPUT'     ) THEN  -- 근태입력           
                p_ret_msg := 'note.att.enableResidualAnnualLeaveInput';  -- 사용가능한 잔여연차가 부족합니다. 입력하신 근태사항을 확인하시기 바랍니다.

            ELSIF (p_att_type = 'APPROVAL'  ) THEN  -- 근태결재           
                p_ret_msg := 'note.att.enableResidualAnnualLeaveApproval';  -- 사용가능한 잔여연차가 부족합니다. 결재하실 근태사항을 확인하시기 바랍니다.

            ELSIF (p_att_type = 'UPD_REQ'   ) THEN  -- 수정요청서 요청    
                p_ret_msg := 'note.att.enableResidualAnnualLeaveUpdReq';  -- 사용가능한 잔여연차가 부족합니다. 수정하신 근태사항을 확인하시기 바랍니다.

            ELSIF (p_att_type = 'UPD_APPR'  ) THEN  -- 수정요청서 결재    
                p_ret_msg := 'note.att.enableResidualAnnualLeaveUpdAppr';  -- 사용가능한 잔여연차가 부족합니다. 결재하실 근태사항을 확인하시기 바랍니다.

            ELSIF (p_att_type = 'LT_TA_REQ' ) THEN  -- 장기근태계획 요청  
                p_ret_msg := 'note.att.enableResidualAnnualLeaveLtTaReq';  -- 사용가능한 잔여연차가 부족합니다. 입력하신 장기근태계획을 확인하시기 바랍니다.

            ELSIF (p_att_type = 'LT_TA_APPR') THEN  -- 장기근태계획 결재
                p_ret_msg := 'note.att.enableResidualAnnualLeaveLtTaAppr';  -- 사용가능한 잔여연차가 부족합니다. 결재하실 장기근태계획을 확인하시기 바랍니다.
            ELSIF    (p_att_type = 'MODIFY'     ) THEN  -- 결재자가 근태 수정           
                p_ret_msg := 'note.att.enableResidualAnnualLeaveInput';  -- 사용가능한 잔여연차가 부족합니다. 입력하신 근태사항을 확인하시기 바랍니다.
            ELSE
                p_ret_msg := 'note.att.enableResidualAnnualLeaveElse';  -- 사용가능한 잔여연차가 부족합니다. 근태사항을 확인하시기 바랍니다.
            
            END IF;
        END IF;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := -1;
    p_ret_msg  := 'error.PageError';  -- 예상치 못한 서버 오류가 발생하였습니다.시스템 담당자에게 문의하시기 바랍니다.

END valid_att_annual_leave_proc;


END lgvatt_transaction_pkg;
/
