CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_resignation_pkg
IS


PROCEDURE apply_att_annual_lv_corr_retir (p_ret_code                   OUT VARCHAR2
                                         ,p_ret_msg                    OUT VARCHAR2
                                         ,p_user_id                    IN  VARCHAR2
                                         ,p_subsidiary_code            IN  VARCHAR2
                                         ,p_yyyymm                     IN  VARCHAR2
                                         ,p_payroll_calculation_set_id IN  NUMBER
                                         ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                         );



END lgvatt_resignation_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_resignation_pkg
IS

g_temp_var                     VARCHAR2(100);
g_user_id                      VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SYS_USER', 'A1');                                         
g_subsidiary_code              VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SUBSIDIARY_CODE', 'A1');                                  
g_future_creation_months       NUMBER       := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'FUTURE_CREATION_MONTHS', 'A1'));
g_enable_residual_al_days      NUMBER       := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'ENABLE_RESIDUAL_ANNUAL_LEAVE_DAYS', 'A1')); 



/*************************************************************************************************/
/* Program Name : apply_att_annual_lv_corr_retir                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : 퇴직자의 퇴직일 근태 연차생성 보정내역을 반영한다.                             */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : 실행주기 : 사용자가 화면에서 실행                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  사용자ID                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_payroll_calculation_set_id      in    number    급여대상자SetId              */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  박귀희B     Initial Release                                                       */
/* 2019/09/29  TaiDD         The suspense period of maternity leave (Code: US_CHB) which was paid by insurance, still be count as working days when calculate/adjust/correct the annual leave
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_annual_lv_corr_retir (p_ret_code                   OUT VARCHAR2
                                         ,p_ret_msg                    OUT VARCHAR2
                                         ,p_user_id                    IN  VARCHAR2
                                         ,p_subsidiary_code            IN  VARCHAR2
                                         ,p_yyyymm                     IN  VARCHAR2
                                         ,p_payroll_calculation_set_id IN  NUMBER
                                         ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                         )
IS
    v_subsidiary_code                  VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                          VARCHAR2(30) := NVL(p_user_id, g_user_id);

    pre_anl_rec                        tb_att_annual_leave_n%ROWTYPE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    FOR per IN (SELECT employee_no
                       ,full_days
                       ,working_days
                       ,unpaid_days                       
                       ,ROUND((working_days - unpaid_days) / full_days * 12, 0) AS calibration_days          -- 개인별 연간 보정 연차일수                             
                       ,yearly_annual_leave_days                                AS yearly_annual_leave_days  -- 개인별 연간 발생 연차일수
                       /*개인별 년차조정일수에 마이너스 허용 */
                       ,(ROUND((working_days - unpaid_days) / full_days * 12, 0) - yearly_annual_leave_days) AS difference_days  -- 개인별 차이 연차일수
                       ,time_and_attendance_yyyymm
                 FROM   (
                         SELECT ar.employee_no
                               ,ar.full_days
                               ,ar.working_days
                               --,ar.unpaid_days
                               ,(ar.unpaid_days - ar.pregnancy_days) AS unpaid_days --TaiDD 20190929 add the pregnancy_days
                               ,NVL(SUM(aa.occur_monthly_ann_lv_days), 0) AS yearly_annual_leave_days  -- 개인별 연간 발생 연차일수
                               ,MAX(aa.time_and_attendance_yyyymm)        AS time_and_attendance_yyyymm  -- 최종 년월
                         FROM   (
                                 SELECT ar.subsidiary_code
                                       ,ar.employee_no
                                       ,em.attendance_start_date
                                       ,em.attendance_end_date
                                       ,em.full_days                                                             -- 1년 만근일수
                                       ,(em.attendance_end_date - em.attendance_start_date + 1) AS working_days  -- 개인별 만근일수
                                       ,NVL(SUM(ac.unpaid_days), 0)                             AS unpaid_days   -- 개인별 무급일수
                                       ,NVL(SUM(CASE WHEN ar.time_attend_detail_code = 'US_CHB' THEN 1 ELSE 0 END), 0) AS pregnancy_days --TaiDD 20190929 - Count the pregnancy day paid by Insurance
                                 FROM   (
                                         SELECT em.subsidiary_code      AS subsidiary_code
                                               ,em.employee_number      AS employee_number
                                               ,(TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '1231', 'YYYYMMDD') - TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '0101', 'YYYYMMDD') + 1) AS full_days  -- 1년 만근일수
                                               ,GREATEST(em.date_hire_subsidiary, TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '0101', 'YYYYMMDD'))                                     AS attendance_start_date  -- 개인별 기산시작일
                                               ,em.date_retire                                                                                                                        AS attendance_end_date    -- 개인별 기산종료일
                                         FROM   tb_pay_calc_set_target_per_n ps
                                               ,emp_master                   em
                                         WHERE  ps.payroll_calculation_set_id = p_payroll_calculation_set_id  -- 급여대상자SetId
                                         AND    ps.employee_no                = NVL(p_employee_no, ps.employee_no)
                                         AND    ps.employee_no                = em.employee_number
                                         AND    em.subsidiary_code            = p_subsidiary_code
                                         AND    em.date_retire               IS NOT NULL  -- 퇴직자만
                                         AND    em.date_retire               <= last_day(to_date(p_yyyymm,'YYYYMM'))  --미래 퇴직자가 있을수 있어서 월기준으로 당월 말일자까지만..
                                        ) em,
                                        tb_att_result_n ar,
                                        tb_att_code_c   ac
                                 WHERE  em.subsidiary_code                = ar.subsidiary_code
                                 AND    em.employee_number                = ar.employee_no
                                 AND    ar.time_and_attendance_date BETWEEN em.attendance_start_date AND em.attendance_end_date
                                 AND    ar.subsidiary_code                = ac.subsidiary_code
                                 AND    ar.time_and_attendance_code       = ac.time_and_attendance_code
                                 GROUP BY ar.subsidiary_code, ar.employee_no, em.attendance_start_date, em.attendance_end_date, full_days
                                ) ar,
                                tb_att_annual_leave_n aa
                         WHERE  ar.subsidiary_code                  = aa.subsidiary_code
                         AND    ar.employee_no                      = aa.employee_no
                         AND    aa.time_and_attendance_yyyymm BETWEEN TO_CHAR(ar.attendance_start_date, 'YYYYMM') AND TO_CHAR(ar.attendance_end_date, 'YYYYMM')
                         GROUP BY ar.employee_no, ar.full_days, ar.working_days, ar.unpaid_days
                                 , ar.pregnancy_days --TaiDD 20190929
                        )
               )
    LOOP
        -- 전월 연차정보
        pre_anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec(p_subsidiary_code, per.employee_no, TO_CHAR(ADD_MONTHS(TO_DATE(per.time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM'));
        
        -- 보정갯수 반영
        UPDATE tb_att_annual_leave_n
        SET    annual_calibration_days    = per.difference_days
              ,annual_compensation_days   = NVL(pre_anl_rec.residual_annual_leave_days, 0)  -- 보상연차 = 전월잔여
                                          + NVL(occur_basic_annual_leave_days, 0)           --          + 당월발생기초연차(5년단위)
                                          + NVL(occur_monthly_ann_lv_days, 0)               --          + 당월발생연차
                                          - NVL(use_annual_leave_days, 0)                   --          - 당월사용연차
                                          + per.difference_days                             --          + 보정연차
              ,residual_annual_leave_days = 0                                               -- 잔여연차 = 0 (퇴직자이므로, 전체 보상임)
              ,last_update_user_id        = p_user_id
              ,last_update_date           = SYSDATE
        WHERE  subsidiary_code            = v_subsidiary_code
        AND    employee_no                = per.employee_no
        AND    time_and_attendance_yyyymm = per.time_and_attendance_yyyymm
        ;
    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
END apply_att_annual_lv_corr_retir;




                                    
END lgvatt_resignation_pkg;
/
