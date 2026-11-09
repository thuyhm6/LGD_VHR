CREATE OR REPLACE PACKAGE VHR_MGR.LGVPAY_PAID_LEAVE_PKG IS
/******************************************************************************/
/*  Paid Leave (PL_SW : Stop Working / PL_PLP : Prenatal Leave) payment       */
/*                                                                            */
/*  Screens : LGVPAY00031 Paid Leave Registration                             */
/*            LGVPAY00032 Paid Leave Payment Calculation                      */
/*            LGVPAY00033 Paid Leave Payment Rate Setup                       */
/*  Tables  : TB_PAY_PAID_LEAVE_N      registration                           */
/*            TB_PAY_PL_RATE_M         payment rate (effective period)        */
/*            TB_PAY_PL_ITEM_MAP_M     (PL code, tier, component) -> item     */
/*            TB_PAY_PL_CALC_DAILY_N   daily result                           */
/*            TB_PAY_PL_CALC_RESULT_N  monthly result per tier                */
/******************************************************************************/

/* Upload registration (LGCOM_IMPORT_N -> TB_PAY_PAID_LEAVE_N) */
PROCEDURE upload_paid_leave_emp( p_errcode                OUT VARCHAR2
                               , p_errbuf                 OUT VARCHAR2
                               , p_session_id             IN  NUMBER
                               , p_pay_month              IN  VARCHAR2
                               , p_paid_leave_detail_code IN  VARCHAR2
                               , p_application_user_id    IN  NUMBER );

/* Calculate PL days / tier / amount of a month */
PROCEDURE calculate_paid_leave( p_errcode                OUT VARCHAR2
                              , p_errbuf                 OUT VARCHAR2
                              , p_subsidiary_code        IN  VARCHAR2
                              , p_pay_month              IN  VARCHAR2
                              , p_paid_leave_detail_code IN  VARCHAR2   -- NULL : all
                              , p_employee_no            IN  VARCHAR2   -- NULL : all
                              , p_application_user_id    IN  VARCHAR2 );

/* Payroll formula : register in Formula Management with 6 IN parameters
   (P_EMPLOYEE_NO, P_PERIOD_ID, P_PAYROLL_CALCULATION_EXEC_ID, P_PAYROLL_ITEM_ID, P_RUN_TYPE_NAME, P_USER_ID)
   and map the payroll item in LGVPAY00033 */
PROCEDURE calculation_pl_item( p_employee_no                 IN VARCHAR2
                             , p_period_id                   IN NUMBER
                             , p_payroll_calculation_exec_id IN NUMBER
                             , p_payroll_item_id             IN NUMBER
                             , p_run_type_name               IN VARCHAR2
                             , p_user_id                     IN VARCHAR2 );

/* PL days / hours of a month (for other formulas : attendance incentive, transport ...) */
FUNCTION get_pl_days ( p_subsidiary_code        IN VARCHAR2
                     , p_employee_no            IN VARCHAR2
                     , p_pay_month              IN VARCHAR2
                     , p_paid_leave_detail_code IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

FUNCTION get_pl_hours( p_subsidiary_code        IN VARCHAR2
                     , p_employee_no            IN VARCHAR2
                     , p_pay_month              IN VARCHAR2
                     , p_paid_leave_detail_code IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

END LGVPAY_PAID_LEAVE_PKG;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.LGVPAY_PAID_LEAVE_PKG IS

    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_step        lgcom_error_log.error_explanation_text%TYPE := NULL;

    /* "a" look-back window : days before the 1st day of the pay month */
    c_lookback_days CONSTANT NUMBER       := 400;
    /* Global Value name of the regional minimum wage (LGVPAY10001) */
    c_min_wage_var  CONSTANT VARCHAR2(40) := 'REGION_MINIMUM_WAGE';
    /* Planned item id of Adjustment 1/2/3 allowance */
    c_adj1_item_id  CONSTANT NUMBER       := 23;
    c_adj2_item_id  CONSTANT NUMBER       := 24;
    c_adj3_item_id  CONSTANT NUMBER       := 25;

/******************************************************************************/
/* Function Name  : to_num                                                    */
/* Description    : VARCHAR2 -> NUMBER (invalid / NULL => 0)                  */
/******************************************************************************/
FUNCTION to_num( p_value IN VARCHAR2 ) RETURN NUMBER IS
BEGIN
    RETURN NVL(TO_NUMBER(p_value), 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END to_num;

/******************************************************************************/
/* Program Name   : upload_paid_leave_emp                                     */
/* Description    : Upload Paid Leave registration                            */
/*                  Excel : 1 Employee No / 2 Employee Name / 3 Start Date    */
/*                          4 End Date (DD/MM/YYYY) / 5 Note                  */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                p_errcode                OUT     VARCHAR2   error code      */
/*                p_errbuf                 OUT     VARCHAR2   error message   */
/*                p_session_id             IN      NUMBER     upload session  */
/*                p_pay_month              IN      VARCHAR2   YYYYMM          */
/*                p_paid_leave_detail_code IN      VARCHAR2   PL_SW, PL_PLP   */
/*                p_application_user_id    IN      NUMBER     user id         */
/******************************************************************************/
/* Modification Log                                                           */
/* Date         In Charge         Description                                 */
/* ------------ ----------------- ------------------------------------------- */
/* 2026-10-26   HMT               Initial Release                             */
/******************************************************************************/
PROCEDURE upload_paid_leave_emp( p_errcode                OUT VARCHAR2
                               , p_errbuf                 OUT VARCHAR2
                               , p_session_id             IN  NUMBER
                               , p_pay_month              IN  VARCHAR2
                               , p_paid_leave_detail_code IN  VARCHAR2
                               , p_application_user_id    IN  NUMBER )
IS
    v_program_id  lgcom_error_log.program_id%TYPE := 'LGVPAY00031';
    v_user_id     VARCHAR2(40) := lgvhr_common_pkg.sys_user_id;

    v_rec_count   NUMBER := 0;
    v_err_count   NUMBER := 0;
    v_chk_cnt     NUMBER;
    v_start_date  DATE;
    v_end_date    DATE;
    v_error_msg   VARCHAR2(4000);

    v_exception   EXCEPTION;

    CURSOR cur_excel IS
        SELECT li.seq_no
              ,TRIM(li.attribute1) employee_no
              ,TRIM(li.attribute3) start_date
              ,TRIM(li.attribute4) end_date
              ,TRIM(li.attribute5) note
        FROM   lgcom_import_n li
        WHERE  li.session_id = p_session_id
        AND    li.seq_no     > 1
        AND    TRIM(li.attribute1) IS NOT NULL
        ORDER BY li.seq_no
    ;
BEGIN
    IF p_application_user_id IS NOT NULL THEN
        v_user_id := p_application_user_id;
    END IF;

    g_step := 'Get Upload Data Count';
    SELECT COUNT(*)
    INTO   v_rec_count
    FROM   lgcom_import_n li
    WHERE  li.session_id = p_session_id
    ;

    IF v_rec_count < 2 THEN
        p_errbuf := 'No Upload Data Found';
        RAISE v_exception;
    END IF;

    IF p_pay_month IS NULL OR p_paid_leave_detail_code IS NULL THEN
        p_errbuf := 'Check Month / Paid Leave Type';
        RAISE v_exception;
    END IF;

    FOR rec IN cur_excel
    LOOP
        v_error_msg  := NULL;
        v_start_date := NULL;
        v_end_date   := NULL;

        g_step := 'Upload Data Check : Employee No';
        SELECT COUNT(*)
        INTO   v_chk_cnt
        FROM   emp_master em
        WHERE  em.employee_number = rec.employee_no
        ;
        IF v_chk_cnt = 0 THEN
            v_error_msg := 'Check Employee No';
        END IF;

        g_step := 'Upload Data Check : Date';
        IF v_error_msg IS NULL THEN
            BEGIN
                v_start_date := TO_DATE(rec.start_date, 'DD/MM/YYYY');
                v_end_date   := TO_DATE(rec.end_date  , 'DD/MM/YYYY');
            EXCEPTION
                WHEN OTHERS THEN
                    v_error_msg := 'Check Start/End Date (DD/MM/YYYY)';
            END;
        END IF;

        IF v_error_msg IS NULL AND (v_start_date IS NULL OR v_end_date IS NULL OR v_start_date > v_end_date) THEN
            v_error_msg := 'Start Date must be less than or equal to End Date';
        END IF;

        g_step := 'Upload Data Check : Overlap';
        IF v_error_msg IS NULL THEN
            SELECT COUNT(*)
            INTO   v_chk_cnt
            FROM   tb_pay_paid_leave_n tpp
            WHERE  tpp.employee_no            = rec.employee_no
            AND    tpp.paid_leave_detail_code = p_paid_leave_detail_code
            AND    tpp.start_date            <= v_end_date
            AND    tpp.end_date              >= v_start_date
            ;
            IF v_chk_cnt > 0 THEN
                v_error_msg := 'Period overlaps an existing registration';
            END IF;
        END IF;

        g_step := 'Upload Data Check : Check Error Update';
        IF v_error_msg IS NOT NULL THEN
            IF v_err_count = 0 THEN
                ROLLBACK;
            END IF;

            v_err_count := v_err_count + 1;

            UPDATE lgcom_import_n li
            SET    li.attribute199 = 'Y'
                  ,li.attribute200 = CASE WHEN LENGTHB(v_error_msg) > 150
                                          THEN SUBSTRB(v_error_msg, 1, 145)||'.....'
                                          ELSE v_error_msg
                                     END
            WHERE  li.session_id = p_session_id
            AND    li.seq_no     = rec.seq_no
            ;
        END IF;

        IF v_err_count = 0 THEN
            g_step := 'Upload Data Save : Paid Leave';
            INSERT INTO tb_pay_paid_leave_n
                  ( paid_leave_id
                  , payment_yyyymm
                  , paid_leave_detail_code
                  , employee_no
                  , start_date
                  , end_date
                  , note
                  , creation_date
                  , creation_user_id )
            VALUES( sq_pay_paid_leave_id.NEXTVAL
                  , p_pay_month
                  , p_paid_leave_detail_code
                  , rec.employee_no
                  , v_start_date
                  , v_end_date
                  , SUBSTRB(rec.note, 1, 255)
                  , SYSDATE
                  , v_user_id )
            ;
        END IF;
    END LOOP;

    IF v_err_count > 0 THEN
        p_errcode := -2000;
        p_errbuf  := 'Total : ' || (v_rec_count - 1) || ' Error : ' || v_err_count;
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_errcode := NVL(p_errcode, SQLCODE);
        p_errbuf  := SUBSTR(NVL(p_errbuf, SQLERRM), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END upload_paid_leave_emp;

/******************************************************************************/
/* Program Name   : calculate_paid_leave                                      */
/* Description    : Calculate payment of Paid Leave days of a month           */
/*                                                                            */
/*  1) PL day     : TB_ATT_RESULT_N.TIME_AND_ATTENDANCE_CODE = 'PL' and       */
/*                  TIME_ATTEND_DETAIL_CODE has a rate in TB_PAY_PL_RATE_M    */
/*  2) a          : continuous calendar days of (same PL code, WH, PH)        */
/*                  counted backward from each PL day, starting at the first  */
/*                  PL day of the chain (leading WH/PH are not counted).      */
/*                  The chain crosses months.                                 */
/*  3) Tier       : rate row with FROM_DAYS <= a <= TO_DAYS, effective on the */
/*                  PL day, EMP_CATEGORY_CODE = employee category (or ALL)    */
/*  4) Amount     : monthly amount / perfect work hours * PL hours * rate %   */
/*                  Base salary of BASE_AMOUNT_TYPE = MIN_WAGE uses the       */
/*                  regional minimum wage instead of the base salary.         */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                p_errcode                OUT     VARCHAR2   error code      */
/*                p_errbuf                 OUT     VARCHAR2   error message   */
/*                p_subsidiary_code        IN      VARCHAR2   LGDVN           */
/*                p_pay_month              IN      VARCHAR2   YYYYMM          */
/*                p_paid_leave_detail_code IN      VARCHAR2   NULL : all      */
/*                p_employee_no            IN      VARCHAR2   NULL : all      */
/*                p_application_user_id    IN      VARCHAR2   user id         */
/******************************************************************************/
/* Modification Log                                                           */
/* Date         In Charge         Description                                 */
/* ------------ ----------------- ------------------------------------------- */
/* 2026-10-26   HMT               Initial Release                             */
/******************************************************************************/
PROCEDURE calculate_paid_leave( p_errcode                OUT VARCHAR2
                              , p_errbuf                 OUT VARCHAR2
                              , p_subsidiary_code        IN  VARCHAR2
                              , p_pay_month              IN  VARCHAR2
                              , p_paid_leave_detail_code IN  VARCHAR2
                              , p_employee_no            IN  VARCHAR2
                              , p_application_user_id    IN  VARCHAR2 )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAY00032';
    v_user_id         VARCHAR2(40) := NVL(p_application_user_id, lgvhr_common_pkg.sys_user_id);

    v_start_date      DATE;
    v_end_date        DATE;
    v_basis_yyyymmdd  VARCHAR2(8);
    v_basis_date      DATE;

    v_perfect_days    NUMBER;
    v_perfect_hours   NUMBER;
    v_min_wage        NUMBER;
    v_base_salary     NUMBER;
    v_position_allw   NUMBER;
    v_job_allw        NUMBER;
    v_qualif_allw     NUMBER;
    v_adj1_allw       NUMBER;
    v_adj2_allw       NUMBER;
    v_adj3_allw       NUMBER;

    v_exception       EXCEPTION;
BEGIN
    g_step := 'Check Parameter';
    IF p_subsidiary_code IS NULL OR p_pay_month IS NULL THEN
        p_errbuf := 'Check Subsidiary / Month';
        RAISE v_exception;
    END IF;

    v_start_date := TO_DATE(p_pay_month || '01', 'YYYYMMDD');
    v_end_date   := LAST_DAY(v_start_date);

    g_step := 'Delete Previous Result';
    DELETE FROM tb_pay_pl_calc_daily_n d
    WHERE  d.subsidiary_code = p_subsidiary_code
    AND    d.payment_yyyymm  = p_pay_month
    AND    (p_paid_leave_detail_code IS NULL OR d.paid_leave_detail_code = p_paid_leave_detail_code)
    AND    (p_employee_no            IS NULL OR d.employee_no            = p_employee_no)
    ;

    DELETE FROM tb_pay_pl_calc_result_n r
    WHERE  r.subsidiary_code = p_subsidiary_code
    AND    r.payment_yyyymm  = p_pay_month
    AND    (p_paid_leave_detail_code IS NULL OR r.paid_leave_detail_code = p_paid_leave_detail_code)
    AND    (p_employee_no            IS NULL OR r.employee_no            = p_employee_no)
    ;

    g_step := 'Create Daily Result';
    INSERT INTO tb_pay_pl_calc_daily_n
          ( subsidiary_code
          , payment_yyyymm
          , employee_no
          , time_and_attendance_date
          , paid_leave_detail_code
          , emp_category_code
          , shift_type_code
          , chain_start_date
          , continuous_days
          , tier_no
          , pl_rate_id
          , pl_hours
          , base_amount_type
          , base_salary_rate
          , position_allw_rate
          , job_allw_rate
          , qualification_allw_rate
          , adj1_allw_rate
          , adj2_allw_rate
          , adj3_allw_rate
          , creation_date
          , creation_user_id )
    WITH pl_day AS (   /* PL days of the pay month */
        SELECT r.employee_no
             , r.time_and_attendance_date          att_date
             , r.time_attend_detail_code           pl_code
             , MAX(r.shift_type_code)              shift_type_code
             , MAX(lgvpay_info_pkg.get_work_hours( p_subsidiary_code, r.employee_no, r.time_and_attendance_date
                                                 , 'NW', b.shift_type_code, b.work_hours, 'pay_perfect_hours')) pl_hours
        FROM   tb_att_result_n   r
             , tb_att_base_bas_n b
        WHERE  r.subsidiary_code            = p_subsidiary_code
        AND    r.time_and_attendance_yyyymm = p_pay_month
        AND    r.time_and_attendance_code   = 'PL'
        AND    (p_paid_leave_detail_code IS NULL OR r.time_attend_detail_code = p_paid_leave_detail_code)
        AND    (p_employee_no            IS NULL OR r.employee_no             = p_employee_no)
        AND    b.shift_type_code            = r.shift_type_code
        AND    b.time_and_attendance_date   = r.time_and_attendance_date
        AND    EXISTS ( SELECT 1
                        FROM   tb_pay_pl_rate_m m
                        WHERE  m.subsidiary_code        = r.subsidiary_code
                        AND    m.paid_leave_detail_code = r.time_attend_detail_code )
        GROUP BY r.employee_no, r.time_and_attendance_date, r.time_attend_detail_code
    )
    , emp_code AS (
        SELECT DISTINCT employee_no, pl_code
        FROM   pl_day
    )
    , chain_day AS (   /* days which keep the chain : same PL code, WH, PH */
        SELECT ec.employee_no
             , ec.pl_code
             , r.time_and_attendance_date att_date
             , MAX(CASE WHEN r.time_and_attendance_code = 'PL' THEN 1 ELSE 0 END) pl_flag
        FROM   emp_code        ec
             , tb_att_result_n r
        WHERE  r.subsidiary_code          = p_subsidiary_code
        AND    r.employee_no              = ec.employee_no
        AND    r.time_and_attendance_date BETWEEN v_start_date - c_lookback_days AND v_end_date
        AND    (   r.time_and_attendance_code IN ('WH', 'PH')
                OR (r.time_and_attendance_code = 'PL' AND r.time_attend_detail_code = ec.pl_code) )
        GROUP BY ec.employee_no, ec.pl_code, r.time_and_attendance_date
    )
    , chain_grp AS (   /* gaps and islands : same grp = continuous days */
        SELECT c.*
             , c.att_date - ROW_NUMBER() OVER (PARTITION BY c.employee_no, c.pl_code ORDER BY c.att_date) grp
        FROM   chain_day c
    )
    , chain_start AS (
        SELECT g.employee_no
             , g.pl_code
             , g.att_date
             , MIN(CASE WHEN g.pl_flag = 1 THEN g.att_date END) OVER (PARTITION BY g.employee_no, g.pl_code, g.grp) start_date
        FROM   chain_grp g
    )
    , day_tier AS (
        SELECT p.employee_no
             , p.att_date
             , p.pl_code
             , p.shift_type_code
             , p.pl_hours
             , em.assignment_category                emp_category_code
             , cs.start_date                         chain_start_date
             , p.att_date - cs.start_date + 1        continuous_days
        FROM   pl_day      p
             , chain_start cs
             , emp_master  em
        WHERE  cs.employee_no     = p.employee_no
        AND    cs.pl_code         = p.pl_code
        AND    cs.att_date        = p.att_date
        AND    em.employee_number = p.employee_no
    )
    , day_rate AS (   /* rate row : specific category first, then ALL */
        SELECT t.*
             , ( SELECT MAX(x.pl_rate_id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(x.emp_category_code, 'ALL', 2, 1), x.effective_start_date DESC)
                 FROM   tb_pay_pl_rate_m x
                 WHERE  x.subsidiary_code        = p_subsidiary_code
                 AND    x.paid_leave_detail_code = t.pl_code
                 AND    x.emp_category_code     IN (t.emp_category_code, 'ALL')
                 AND    t.continuous_days  BETWEEN x.from_days AND NVL(x.to_days, 99999)
                 AND    t.att_date         BETWEEN x.effective_start_date AND x.effective_end_date ) pl_rate_id
        FROM   day_tier t
    )
    SELECT p_subsidiary_code
         , p_pay_month
         , t.employee_no
         , t.att_date
         , t.pl_code
         , t.emp_category_code
         , t.shift_type_code
         , t.chain_start_date
         , t.continuous_days
         , m.tier_no
         , m.pl_rate_id
         , NVL(t.pl_hours, 0)
         , m.base_amount_type
         , NVL(m.base_salary_rate       , 0)
         , NVL(m.position_allw_rate     , 0)
         , NVL(m.job_allw_rate          , 0)
         , NVL(m.qualification_allw_rate, 0)
         , NVL(m.adj1_allw_rate         , 0)
         , NVL(m.adj2_allw_rate         , 0)
         , NVL(m.adj3_allw_rate         , 0)
         , SYSDATE
         , v_user_id
    FROM   day_rate t
         , tb_pay_pl_rate_m m
    WHERE  m.pl_rate_id(+) = t.pl_rate_id
    ;

    g_step := 'Create Monthly Result';
    FOR emp IN ( SELECT DISTINCT d.employee_no
                 FROM   tb_pay_pl_calc_daily_n d
                 WHERE  d.subsidiary_code = p_subsidiary_code
                 AND    d.payment_yyyymm  = p_pay_month
                 AND    (p_paid_leave_detail_code IS NULL OR d.paid_leave_detail_code = p_paid_leave_detail_code)
                 AND    (p_employee_no            IS NULL OR d.employee_no            = p_employee_no) )
    LOOP
        g_step := 'Basis Date : ' || emp.employee_no;
        SELECT LEAST(v_end_date, NVL(em.date_retire, v_end_date))
        INTO   v_basis_date
        FROM   emp_master em
        WHERE  em.employee_number = emp.employee_no
        ;
        v_basis_yyyymmdd := TO_CHAR(v_basis_date, 'YYYYMMDD');

        g_step := 'Perfect Work Hours : ' || emp.employee_no;
        SELECT NVL(SUM(DECODE(b.time_and_attendance_code, 'NW', 1, 'PH', 1, 0)), 0)
             , NVL(SUM(lgvpay_info_pkg.get_work_hours( p_subsidiary_code, r.employee_no, b.time_and_attendance_date
                                                     , DECODE(r.time_and_attendance_code, 'WH', 'WH', 'PH', 'PH', 'NW')
                                                     , b.shift_type_code, b.work_hours, 'pay_perfect_hours')), 0)
        INTO   v_perfect_days
             , v_perfect_hours
        FROM   tb_att_result_n   r
             , tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date   = b.time_and_attendance_date
        AND    r.shift_type_code            = b.shift_type_code
        AND    r.employee_no                = emp.employee_no
        AND    r.subsidiary_code            = p_subsidiary_code
        AND    r.time_and_attendance_yyyymm = p_pay_month
        ;

        g_step := 'Monthly Amount : ' || emp.employee_no;
        v_min_wage      := to_num(lgvpay_common_pkg.get_calc_var_value(p_subsidiary_code, c_min_wage_var, v_basis_yyyymmdd));
        v_base_salary   := NVL(lgvpay_info_pkg.get_base_pay(emp.employee_no, v_basis_yyyymmdd, p_subsidiary_code, 'A'), 0);
        v_position_allw := NVL(lgvpay_info_pkg.get_position_allowance(emp.employee_no, v_basis_yyyymmdd), 0);
        v_job_allw      := NVL(lgvpay_info_pkg.get_job_allowance(emp.employee_no, v_basis_yyyymmdd), 0);
        v_qualif_allw   := NVL(lgvpay_info_pkg.get_qualification_allowance(emp.employee_no, v_basis_yyyymmdd, p_subsidiary_code), 0);
        v_adj1_allw     := to_num(lgvpay_common_pkg.get_planned_item_value(emp.employee_no, v_basis_date, c_adj1_item_id, 'BASE_AMOUNT'));
        v_adj2_allw     := to_num(lgvpay_common_pkg.get_planned_item_value(emp.employee_no, v_basis_date, c_adj2_item_id, 'BASE_AMOUNT'));
        v_adj3_allw     := to_num(lgvpay_common_pkg.get_planned_item_value(emp.employee_no, v_basis_date, c_adj3_item_id, 'BASE_AMOUNT'));

        g_step := 'Insert Monthly Result : ' || emp.employee_no;
        INSERT INTO tb_pay_pl_calc_result_n
              ( subsidiary_code
              , payment_yyyymm
              , employee_no
              , paid_leave_detail_code
              , tier_no
              , emp_category_code
              , pl_days
              , pl_hours
              , perfect_work_days
              , perfect_work_hours
              , min_wage
              , base_salary_base       , base_salary_full       , base_salary_pay
              , position_allw_base     , position_allw_full     , position_allw_pay
              , job_allw_base          , job_allw_full          , job_allw_pay
              , qualification_allw_base, qualification_allw_full, qualification_allw_pay
              , adj1_allw_base         , adj1_allw_full         , adj1_allw_pay
              , adj2_allw_base         , adj2_allw_full         , adj2_allw_pay
              , adj3_allw_base         , adj3_allw_full         , adj3_allw_pay
              , creation_date
              , creation_user_id )
        SELECT p_subsidiary_code
             , p_pay_month
             , d.employee_no
             , d.paid_leave_detail_code
             , NVL(d.tier_no, 0)
             , MAX(d.emp_category_code)
             , COUNT(*)
             , SUM(d.pl_hours)
             , v_perfect_days
             , v_perfect_hours
             , v_min_wage
             /* Base salary : MIN_WAGE type uses the minimum wage as monthly amount */
             , v_base_salary
             , ROUND(v_base_salary * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(SUM(d.pl_hours * d.base_salary_rate / 100
                         * DECODE(d.base_amount_type, 'MIN_WAGE', v_min_wage, v_base_salary)) / NULLIF(v_perfect_hours, 0))
             , v_position_allw
             , ROUND(v_position_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_position_allw * SUM(d.pl_hours * d.position_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , v_job_allw
             , ROUND(v_job_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_job_allw * SUM(d.pl_hours * d.job_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , v_qualif_allw
             , ROUND(v_qualif_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_qualif_allw * SUM(d.pl_hours * d.qualification_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , v_adj1_allw
             , ROUND(v_adj1_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_adj1_allw * SUM(d.pl_hours * d.adj1_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , v_adj2_allw
             , ROUND(v_adj2_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_adj2_allw * SUM(d.pl_hours * d.adj2_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , v_adj3_allw
             , ROUND(v_adj3_allw * SUM(d.pl_hours) / NULLIF(v_perfect_hours, 0))
             , ROUND(v_adj3_allw * SUM(d.pl_hours * d.adj3_allw_rate / 100) / NULLIF(v_perfect_hours, 0))
             , SYSDATE
             , v_user_id
        FROM   tb_pay_pl_calc_daily_n d
        WHERE  d.subsidiary_code = p_subsidiary_code
        AND    d.payment_yyyymm  = p_pay_month
        AND    d.employee_no     = emp.employee_no
        AND    (p_paid_leave_detail_code IS NULL OR d.paid_leave_detail_code = p_paid_leave_detail_code)
        GROUP BY d.employee_no, d.paid_leave_detail_code, NVL(d.tier_no, 0)
        ;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_errcode := NVL(p_errcode, SQLCODE);
        p_errbuf  := SUBSTR(NVL(p_errbuf, g_step || ' : ' || SQLERRM), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END calculate_paid_leave;

/******************************************************************************/
/* Program Name   : calculation_pl_item                                       */
/* Description    : Payroll formula of Paid Leave items                       */
/*                  (Base salary PL_SW 1, Position allowance PL_SW 1 ...)     */
/*                  value = SUM of mapped (PL code, tier, component) results  */
/*                  of the pay month in TB_PAY_PL_CALC_RESULT_N               */
/*                  -> run LGVPAY00032 Calculate before Payroll Running       */
/******************************************************************************/
/* Modification Log                                                           */
/* Date         In Charge         Description                                 */
/* ------------ ----------------- ------------------------------------------- */
/* 2026-10-26   HMT               Initial Release                             */
/******************************************************************************/
PROCEDURE calculation_pl_item( p_employee_no                 IN VARCHAR2
                             , p_period_id                   IN NUMBER
                             , p_payroll_calculation_exec_id IN NUMBER
                             , p_payroll_item_id             IN NUMBER
                             , p_run_type_name               IN VARCHAR2
                             , p_user_id                     IN VARCHAR2 ) IS

    v_yyyymm          VARCHAR2(6);
    v_end_yyyymmdd    VARCHAR2(8);
    v_subsidiary_code VARCHAR2(100);
    v_count           NUMBER := 0;
    v_return          NUMBER := 0;
    v_input_value_id  NUMBER;
    v_err_buf         VARCHAR2(4000);
BEGIN
    SELECT period.payroll_calc_period_value
         , period.end_yyyymmdd
         , period.subsidiary_code
    INTO   v_yyyymm
         , v_end_yyyymmdd
         , v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
    WHERE  period.payroll_calculation_period_id = p_period_id
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, TO_DATE(v_end_yyyymmdd, 'YYYYMMDD'), p_payroll_item_id) = 'Y' THEN
        RETURN;
    END IF;

    SELECT COUNT(*)
         , NVL(SUM( CASE mp.component_code
                         WHEN 'BASE_SALARY'        THEN r.base_salary_pay        - DECODE(mp.apply_value_type, 'ADJ', r.base_salary_full       , 0)
                         WHEN 'POSITION_ALLW'      THEN r.position_allw_pay      - DECODE(mp.apply_value_type, 'ADJ', r.position_allw_full     , 0)
                         WHEN 'JOB_ALLW'           THEN r.job_allw_pay           - DECODE(mp.apply_value_type, 'ADJ', r.job_allw_full          , 0)
                         WHEN 'QUALIFICATION_ALLW' THEN r.qualification_allw_pay - DECODE(mp.apply_value_type, 'ADJ', r.qualification_allw_full, 0)
                         WHEN 'ADJ1_ALLW'          THEN r.adj1_allw_pay          - DECODE(mp.apply_value_type, 'ADJ', r.adj1_allw_full         , 0)
                         WHEN 'ADJ2_ALLW'          THEN r.adj2_allw_pay          - DECODE(mp.apply_value_type, 'ADJ', r.adj2_allw_full         , 0)
                         WHEN 'ADJ3_ALLW'          THEN r.adj3_allw_pay          - DECODE(mp.apply_value_type, 'ADJ', r.adj3_allw_full         , 0)
                    END ), 0)
    INTO   v_count
         , v_return
    FROM   tb_pay_pl_item_map_m    mp
         , tb_pay_pl_calc_result_n r
    WHERE  mp.subsidiary_code        = v_subsidiary_code
    AND    mp.payroll_item_id        = p_payroll_item_id
    AND    r.subsidiary_code         = mp.subsidiary_code
    AND    r.payment_yyyymm          = v_yyyymm
    AND    r.employee_no             = p_employee_no
    AND    r.paid_leave_detail_code  = mp.paid_leave_detail_code
    AND    r.tier_no                 = mp.tier_no
    ;

    IF v_count = 0 THEN
        RETURN;
    END IF;

    -- pay value input value
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;

    lgvpay_calculation_pkg.create_result( p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                          p_employee_no                 => p_employee_no,
                                          p_payroll_item_id             => p_payroll_item_id,
                                          p_payroll_item_detail_id      => v_input_value_id,
                                          p_rslt_detail_type_code       => 'A',
                                          p_result_value                => ROUND(v_return),
                                          p_user_id                     => p_user_id,
                                          p_period_id                   => p_period_id );

EXCEPTION
    WHEN OTHERS THEN
        v_err_buf := 'calculation_pl_item Error ; ' || SUBSTR(SQLERRM, 1, 1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_buf );
END calculation_pl_item;

/******************************************************************************/
/* Function Name  : get_pl_days / get_pl_hours                                */
/* Description    : PL days / hours of the month (from LGVPAY00032 result)    */
/******************************************************************************/
FUNCTION get_pl_days ( p_subsidiary_code        IN VARCHAR2
                     , p_employee_no            IN VARCHAR2
                     , p_pay_month              IN VARCHAR2
                     , p_paid_leave_detail_code IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER IS
    v_return NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   v_return
    FROM   tb_pay_pl_calc_daily_n d
    WHERE  d.subsidiary_code = p_subsidiary_code
    AND    d.payment_yyyymm  = p_pay_month
    AND    d.employee_no     = p_employee_no
    AND    (p_paid_leave_detail_code IS NULL OR d.paid_leave_detail_code = p_paid_leave_detail_code)
    ;
    RETURN v_return;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_pl_days;

FUNCTION get_pl_hours( p_subsidiary_code        IN VARCHAR2
                     , p_employee_no            IN VARCHAR2
                     , p_pay_month              IN VARCHAR2
                     , p_paid_leave_detail_code IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER IS
    v_return NUMBER;
BEGIN
    SELECT NVL(SUM(d.pl_hours), 0)
    INTO   v_return
    FROM   tb_pay_pl_calc_daily_n d
    WHERE  d.subsidiary_code = p_subsidiary_code
    AND    d.payment_yyyymm  = p_pay_month
    AND    d.employee_no     = p_employee_no
    AND    (p_paid_leave_detail_code IS NULL OR d.paid_leave_detail_code = p_paid_leave_detail_code)
    ;
    RETURN v_return;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_pl_hours;

END LGVPAY_PAID_LEAVE_PKG;
/
