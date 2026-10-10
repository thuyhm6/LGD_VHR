CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_batch_pkg
IS

PROCEDURE create_att_calendar (p_ret_code                   OUT VARCHAR2
                              ,p_ret_msg                    OUT VARCHAR2
                              ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                              ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                             );
                             
PROCEDURE create_att_close (p_ret_code                   OUT VARCHAR2
                           ,p_ret_msg                    OUT VARCHAR2
                           ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                           ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                           );
                             
PROCEDURE create_att_base (p_ret_code                   OUT VARCHAR2
                          ,p_ret_msg                    OUT VARCHAR2
                          ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                          ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_shift_type_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                          );
                           
PROCEDURE create_att_plan (p_ret_code                   OUT VARCHAR2
                          ,p_ret_msg                    OUT VARCHAR2
                          ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                          ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                          ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                          );
                     
PROCEDURE create_att_result (p_ret_code                   OUT VARCHAR2
                            ,p_ret_msg                    OUT VARCHAR2
                            ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                            ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                            ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                            ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                            ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                            );

PROCEDURE create_att_annual_leave (p_ret_code                   OUT NUMBER
                                  ,p_ret_msg                    OUT VARCHAR2
                                  ,p_user_id                    IN  VARCHAR2 DEFAULT NULL

                                  ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                  ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                                  ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                  );

--HMT_20210406 Start
PROCEDURE create_att_ot_level (p_ret_code                   OUT VARCHAR2
                              ,p_ret_msg                    OUT VARCHAR2
                              ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                              ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                              ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                              );
                              
PROCEDURE update_att_result_without_io (p_ret_code                   OUT VARCHAR2
                                       ,p_ret_msg                    OUT VARCHAR2
                                       ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                                       ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                       ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                                       ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                       ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                                       );
--HMT_20210406 End
                          
PROCEDURE apply_att_annual_lv_correction (p_ret_code                 OUT VARCHAR2
                                         ,p_ret_msg                  OUT VARCHAR2
                                         ,p_user_id                  IN  VARCHAR2
                                         ,p_subsidiary_code          IN  VARCHAR2
                                         ,p_time_and_attendance_yyyy IN  VARCHAR2
                                         ,p_employee_no              IN  VARCHAR2 DEFAULT NULL
                                         );

PROCEDURE apply_att_annual_lv_corr_retir (p_ret_code                   OUT VARCHAR2
                                         ,p_ret_msg                    OUT VARCHAR2
                                         ,p_user_id                    IN  VARCHAR2
                                         ,p_subsidiary_code            IN  VARCHAR2
                                         ,p_payroll_calculation_set_id IN  NUMBER
                                         ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                         );

PROCEDURE apply_att_contract_pl (p_ret_code                   OUT NUMBER
                                ,p_ret_msg                    OUT VARCHAR2
                                ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                                ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                );

PROCEDURE apply_att_fr_asg (p_ret_code         OUT VARCHAR2
                           ,p_ret_msg          OUT VARCHAR2
                           ,p_user_id          IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code  IN  VARCHAR2 DEFAULT NULL
                           ,p_att_type         IN  VARCHAR2 DEFAULT 'ALL'
                           ,p_basic_date       IN  DATE     DEFAULT NULL
                           ,p_employee_no      IN  VARCHAR2 DEFAULT NULL
                           );

PROCEDURE apply_att_result_fr_plan (p_ret_code                 OUT VARCHAR2
                                   ,p_ret_msg                  OUT VARCHAR2
                                   ,p_user_id                  IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code          IN  VARCHAR2 DEFAULT NULL
                                   ,p_assignment_caterogy_type IN  VARCHAR2 DEFAULT NULL
                                   ,p_time_and_attendance_date IN  DATE     DEFAULT NULL
                                   ,p_employee_no              IN  VARCHAR2 DEFAULT NULL
                                   );
           
PROCEDURE apply_not_approved_att_req (p_ret_code             OUT VARCHAR2
                                     ,p_ret_msg              OUT VARCHAR2
                                     ,p_user_id              IN  VARCHAR2 DEFAULT NULL
                                     ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                                     ,p_att_type             IN  VARCHAR2 DEFAULT NULL
                                     ,p_basic_date           IN  DATE     DEFAULT NULL
                                     ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                                     ,p_approver_employee_no IN  VARCHAR2 DEFAULT NULL
                                     );

PROCEDURE send_approver_lw_att_info (p_ret_code             OUT VARCHAR2
                                    ,p_ret_msg              OUT VARCHAR2
                                    ,p_user_id              IN  VARCHAR2 DEFAULT NULL
                                    ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                                    ,p_night_shift_flag     IN  VARCHAR2 DEFAULT NULL
                                    ,p_basic_date           IN  DATE     DEFAULT NULL
                                    ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                                    ,p_approver_employee_no IN  VARCHAR2 DEFAULT NULL
                                    );

PROCEDURE daily_att_count;                       

PROCEDURE get_organization_id(
                              P_unit_org_id          OUT VARCHAR2
                             ,p_part_org_id          OUT VARCHAR2
                             ,p_task_org_id          OUT VARCHAR2
                             ,p_section_org_id       OUT VARCHAR2
                             ,p_team_org_id          OUT VARCHAR2
                             ,p_department_org_id    OUT VARCHAR2
                             ,p_division_org_id      OUT VARCHAR2
                             ,p_organization_id       IN VARCHAR2
                             );

PROCEDURE set_outing_count;

END lgvatt_batch_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_batch_pkg
IS

g_temp_var                     VARCHAR2(100);
g_user_id                      VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SYS_USER', 'A1');                                         
g_subsidiary_code              VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SUBSIDIARY_CODE', 'A1');                                  
g_future_creation_months       NUMBER       := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'FUTURE_CREATION_MONTHS', 'A1'));
g_enable_residual_al_days      NUMBER       := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'ENABLE_RESIDUAL_ANNUAL_LEAVE_DAYS', 'A1')); 


/*************************************************************************************************/
/* Program Name : create_att_calendar                                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ??? ???? ????? ????                                            */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/02  ???B     Initial Release                                                       */
/*                                                                                               */
/* 2017/10/25  ???B     ??? ??                                                           */
/*                         lgvatt_ot_calculation_pkg -> lgvatt_batch_pkg                   */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE create_att_calendar (p_ret_code                   OUT VARCHAR2
                              ,p_ret_msg                    OUT VARCHAR2
                              ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                              ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                             )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);
    
    v_start_date                  DATE;
    v_end_day                     NUMBER;
      
    v_week_code                   tb_att_calendar_n.a_day_of_the_week_code%TYPE;
    v_attendance_code             tb_att_calendar_n.time_and_attendance_code%TYPE;
    v_holiday_code                tb_att_calendar_n.holiday_code%TYPE;
  
    ac_rec                        tb_att_calendar_n%ROWTYPE;

    v_apply_result_flag           VARCHAR2(30);

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0001', 'A1')) THEN  
        IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0001', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
            RETURN;  
        END IF;
        
        -- ????
        SELECT NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_calendar_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;
    

    v_start_date := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');
    v_end_day    := LAST_DAY(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM')) - v_start_date;
    
    DELETE tb_att_calendar_n
    WHERE  subsidiary_code            = v_subsidiary_code
    AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    ;
    
    FOR jj IN 0 .. v_end_day
    LOOP
      
        lgvatt_common_pkg.get_weekday_info(v_subsidiary_code, v_start_date+jj, v_week_code, v_attendance_code, v_holiday_code);
        
        ac_rec.subsidiary_code            := v_subsidiary_code;
        ac_rec.time_and_attendance_date   := v_start_date + jj;
        ac_rec.time_and_attendance_yyyymm := v_time_and_attendance_yyyymm;
        ac_rec.time_and_attendance_code   := v_attendance_code;
        ac_rec.holiday_code               := v_holiday_code;
        ac_rec.holiday_flag               := CASE WHEN v_attendance_code IN ( 'HO', 'WH', 'PH' ) THEN 'Y' ELSE 'N' END;  -- ???? : ??/?/?????
        ac_rec.confirm_flag               := 'N';                                                                        -- ??????, ???? ?????? ????? ?
        ac_rec.a_day_of_the_week_code     := v_week_code;
        ac_rec.creation_user_id           := v_user_id;
        ac_rec.creation_date              := SYSDATE;

        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_calendar_record (ac_rec, 'CREATE');
    END LOOP;
    
    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_calendar;


/*************************************************************************************************/
/* Program Name : create_att_close                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ??? ???? ??????? ????                                        */
/*                ???? ?? ???? ??? ??                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE create_att_close (p_ret_code                   OUT VARCHAR2
                           ,p_ret_msg                    OUT VARCHAR2
                           ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                           ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                           )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);

    v_work_time_attendance_yyyymm VARCHAR2(30);
    
    v_paid_day                    DATE;
    
    ac_rec                        tb_att_close_n%ROWTYPE;

    v_apply_result_flag           VARCHAR2(30);

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';
    
    -- 2018.02.12 ??? : ?????? ???? ??? ??????? ?? ??? ????, ??? ???? 10???? ?? ???? ?(?????? 10???? ??)
    --                     ???????, ?? ???? ??? ???? ?? ???? ???
    FOR cls IN (SELECT * 
                FROM   tb_att_close_n
                WHERE  time_and_attendance_yyyymm < TO_CHAR(SYSDATE, 'YYYYMM')  -- SYSDATE ?? ??? ???? ????
                AND    confirm_flag               = 'N'
               )
    LOOP
        -- ????? : ??? 10?(??) ??? ??? ??
        SELECT MAX(time_and_attendance_date)
        INTO   v_paid_day
        FROM   tb_att_calendar_n
        WHERE  time_and_attendance_yyyymm  = TO_CHAR(ADD_MONTHS(TO_DATE(cls.time_and_attendance_yyyymm, 'YYYYMM'), 1), 'YYYYMM')
        AND    holiday_flag                = 'N'
        AND    time_and_attendance_date   <= TO_DATE(time_and_attendance_yyyymm || '10', 'YYYYMMDD')
        ;
        
        -- ????? ????? ????
        IF (TO_CHAR(SYSDATE) >= v_paid_day) THEN
        
            -- ???? ????
            UPDATE tb_att_close_n
            SET    confirm_flag = 'Y'
            WHERE  time_and_attendance_yyyymm  = cls.time_and_attendance_yyyymm
            ;
            
            COMMIT;
        END IF;
    END LOOP;


    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0002', 'A1')) THEN  
        IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0002', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
            RETURN;  
        END IF;
        
        -- ????
        SELECT NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_close_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;


    DELETE tb_att_close_n
    WHERE  subsidiary_code            = v_subsidiary_code
    AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    ;
    
    ac_rec.subsidiary_code            := v_subsidiary_code;
    ac_rec.time_and_attendance_yyyymm := v_time_and_attendance_yyyymm;
    ac_rec.period_from_date           := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');
    ac_rec.period_to_date             := LAST_DAY(ac_rec.period_from_date);
    ac_rec.period_close_date          := NULL;       -- ????
    ac_rec.perfect_attendance_days    := 0;          -- ????
    ac_rec.confirm_flag               := 'N';        -- ????
    ac_rec.creation_user_id           := v_user_id;
    ac_rec.creation_date              := SYSDATE;
    ac_rec.last_update_user_id        := v_user_id;
    ac_rec.last_update_date           := SYSDATE;

    v_apply_result_flag := lgvatt_transaction_pkg.apply_att_close_record (ac_rec, 'CREATE');
    
    COMMIT;


    -- 2018.02.12 ??? : SYSDATE ?? ??? ~ ???? ????/???? ?? ??
    --                     ???? : ?(?)? ?? ????? ??? ??? ??? ?? ??? ??
    --                     ???? : ???? ????? ????? ??? ??? ????? ?? ??(2?? ?? 17?)
    FOR mm IN 1..MONTHS_BETWEEN(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM'), 'YYYYMM'))
    LOOP
        -- ??? ~ ???
        v_work_time_attendance_yyyymm := TO_CHAR(ADD_MONTHS(SYSDATE, mm), 'YYYYMM');
        
        -- ???? ????
        ac_rec := lgvatt_common_pkg.get_att_close_rec(v_subsidiary_code, v_work_time_attendance_yyyymm);

        -- ???? ????
        SELECT SUM(NVL(cod.paid_days, 0) + NVL(cod.attendance_days, 0))
        INTO   ac_rec.perfect_attendance_days
        FROM   tb_att_calendar_n cal
              ,tb_att_code_c     cod 
        WHERE cal.time_and_attendance_yyyymm = v_work_time_attendance_yyyymm
        AND   cal.time_and_attendance_code   = cod.time_and_attendance_code
        ;

        -- ?????, ??? ??
        IF (v_work_time_attendance_yyyymm = v_time_and_attendance_yyyymm) THEN
            ac_rec.period_close_date := TO_DATE(TO_CHAR(ac_rec.period_to_date + 2, 'YYYYMMDD') || ' 17:00:00', 'YYYYMMDD HH24:MI:SS');  -- ??????? : ??? ???? ??
        ELSE
            -- ???? 2?? ??? ??? ????? ????
            SELECT period_to_date
            INTO   ac_rec.period_close_date
            FROM   (
                    SELECT TO_DATE(TO_CHAR(time_and_attendance_date, 'YYYYMMDD') || ' 17:00:00', 'YYYYMMDD HH24:MI:SS') AS period_to_date,
                           ROWNUM AS day_seq
                    FROM   tb_att_calendar_n
                    WHERE  time_and_attendance_yyyymm = TO_CHAR(ADD_MONTHS(TO_DATE(v_work_time_attendance_yyyymm, 'YYYYMM'), 1), 'YYYYMM')  -- ???
                    AND    holiday_flag               = 'N'
                    ORDER BY time_and_attendance_date
                   )
            WHERE  day_seq = 2
            ;
        END IF;

        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_close_record (ac_rec, 'UPDATE');
    END LOOP;

    COMMIT;
  
EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_close;


/*************************************************************************************************/
/* Program Name : create_att_base                                                                */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ?? ?? ???? ????.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_shift_type_code                 in    varchar2  ??????                 */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/02  ???B     Initial Release                                                       */
/*                                                                                               */
/* 2017/10/25  ???B     ??? ??                                                           */
/*                         lgvatt_ot_calculation_pkg -> lgvatt_batch_pkg                         */
/* 2018/10/18  ???c     ??? 32A,B,C shift ??                                             */
/* 2019/09/27  TaiDD         Change the OT for all Shift to 0 when generate the attendance base         */
/* 2020/08/20  TaiDD         Change the evening_meal_flag to Y for Shift Code 1A when generate the attendance base         */
/* 2021/03/16  HMT_20210316   Change the leaving office time, and change work hours                 */
/* 2026/06/01  HMT_20260601   Add new Shift Type 2A, 2B                 */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE create_att_base (p_ret_code                   OUT VARCHAR2
                          ,p_ret_msg                    OUT VARCHAR2
                          ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                          ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_shift_type_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                          )
IS
    v_subsidiary_code                     VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                             VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm          VARCHAR2(30);
  
    v_night_shift_flag                    tb_att_base_bas_n.night_shift_flag%TYPE;
	v_is_late_shift                       NUMBER := 0;  -- HMT_20260601: Weekly alternating cycle improvisation
      
    v_base_date                           DATE;
    v_base_date_iw                        NUMBER;
    v_date_iw                             NUMBER;
    v_cycle                               NUMBER;
    v_week_num                            NUMBER;
      
    v_start_date                          DATE;
    v_standard_date                       DATE;
    v_actual_date                         DATE;
    v_end_day                             NUMBER;
    v_remain_day                          NUMBER;
    
    v_overtime_hours                      tb_att_base_bas_n.overtime_hours%TYPE;
    v_attendance_time                     tb_att_base_bas_n.attendance_time%TYPE;
    v_leaving_office_time                 tb_att_base_bas_n.leaving_office_time%TYPE;
    v_time_attend_input_close_time        tb_att_base_bas_n.time_attend_input_close_time%TYPE; 
    v_time_attend_apprv_close_time        tb_att_base_bas_n.time_attend_apprv_close_time%TYPE; 
  
    v_week_code                           tb_att_calendar_n.a_day_of_the_week_code%TYPE;
    v_attendance_code                     tb_att_calendar_n.time_and_attendance_code%TYPE;
    i_attendance_code                     tb_att_calendar_n.time_and_attendance_code%TYPE;  --< Start 2023.03.09 : 2S10G Shift condition add 
    v_holiday_code                        tb_att_calendar_n.holiday_code%TYPE;
  
    abb_rec                               tb_att_base_bas_n%ROWTYPE;

    v_apply_result_flag                   VARCHAR2(30);
    
    
    CURSOR c1 (c_shift_type_code IN VARCHAR2)
    IS
    SELECT common_code                                                               AS shift_type_code,
           code_data1_value                                                          AS attendance_cycle,
           TO_DATE(REPLACE(REPLACE(code_data2_value, '-', ''), '/', ''), 'YYYYMMDD') AS attendance_start_date,
           code_data3_value                                                          AS start_working_time,     -- 2017.10.25 ???? ?? ?? : ?? 3?? ??? ??? ???? ???? ??? : lgvatt_ot_calculation_pkg.get_shift_code_info ? ???
           code_data4_value                                                          AS day_shift_start_time,
           code_data5_value                                                          AS night_shift_start_time
    FROM   lgcom_common_code_c
    WHERE  code_type_code              = 'LGVHR_SHIFT_TYPE_CODE'
    AND    TO_NUMBER(code_data1_value) > 0
    AND    common_code                 = NVL(c_shift_type_code, common_code)    
    ;
  
    CURSOR C2 (p_base_date_iw NUMBER
              ,p_date_iw NUMBER
              ,p_cycle NUMBER
              )
    IS
    SELECT DECODE(p_cycle, 0, 0,
                           1, CASE WHEN MOD((p_date_iw - p_base_date_iw), 2) IN ( 0    ) THEN 0 ELSE 1 END,
                           2, CASE WHEN MOD((p_date_iw - p_base_date_iw), 4) IN ( 0, 1 ) THEN 0 ELSE 1 END
                 ) AS night_flag
    FROM dual
    ;
  
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0003', 'A1')) THEN  
        --IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0003', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
           --RETURN;  
        --END IF;
        
        -- ????
        SELECT NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_base_bas_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;

  
    v_start_date := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');
    v_end_day    := LAST_DAY(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM')) - v_start_date;
    
    FOR r1 IN c1(p_shift_type_code) 
    LOOP
        DELETE tb_att_base_bas_n
        WHERE  subsidiary_code = v_subsidiary_code
        AND    shift_type_code = r1.shift_type_code
        AND    time_and_attendance_date BETWEEN v_start_date AND LAST_DAY(v_start_date)
        ;
      
        v_base_date    := r1.attendance_start_date;
        v_base_date_iw := TO_NUMBER(TO_CHAR(TRUNC(v_base_date), 'iw'));
        v_cycle        := TRUNC(TO_NUMBER(r1.attendance_cycle) / 7);

        FOR jj IN 0 .. v_end_day
        LOOP
            
            v_night_shift_flag := 'N';  -- Day
            
            --< Start 2023.03.09 : 2S10G Shift condition add 
            
            IF r1.shift_type_code LIKE '102%' THEN
            
            v_actual_date := TRUNC(v_start_date + jj);
                -- Each shift type code's initializaed date
                BEGIN 
                  SELECT to_date(lgvhr_common_pkg.decode_lookup('LGVHR_SHIFT_TYPE_APPLY_DATE', r1.shift_type_code,'A1'),'YYYYMMDD')
                   INTO  v_standard_date
                  FROM DUAL;
                END ; 
               
               /* 
                 IF r1.shift_type_code = '102A' THEN
                    
                    v_standard_date := TO_DATE('20230201','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102B' THEN
                    
                    v_standard_date := TO_DATE('20230117','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102C' THEN
                    
                    v_standard_date := TO_DATE('20230131','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102D' THEN
                    
                    v_standard_date := TO_DATE('20230116','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102E' THEN
                    
                    v_standard_date := TO_DATE('20230130','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102F' THEN
                    
                    v_standard_date := TO_DATE('20230115','YYYYMMDD');
                    
                 ELSIF r1.shift_type_code = '102G' THEN
                    
                    v_standard_date := TO_DATE('20230104','YYYYMMDD');
                 ELSIF r1.shift_type_code = '102H' THEN
                    
                    v_standard_date := TO_DATE('20230119','YYYYMMDD');
                 ELSIF r1.shift_type_code = '102I' THEN
                    
                    v_standard_date := TO_DATE('20230202','YYYYMMDD');
                 ELSIF r1.shift_type_code = '102J' THEN
                    
                    v_standard_date := TO_DATE('20230118','YYYYMMDD');
                    
                END IF; */
               -- nguyenvansang-19/07/2023 
               v_remain_day := MOD((v_actual_date - v_standard_date),20);
               IF v_remain_day IN (14,19,4,9) THEN
                  v_attendance_code := 'WH';
               ELSE
                 v_attendance_code := 'NW';
               END IF;
               IF v_remain_day < 10 THEN
                 v_night_shift_flag := 'Y';
               END IF;

                
               -- DBMS_OUTPUT.PUT_LINE('Night flag : ' ||v_actual_date||'-'||v_remain_day||'-'||v_night_shift_flag);
                
                v_week_num := TO_NUMBER(TO_CHAR(v_actual_date, 'D'));
                
                IF v_week_num = 1 THEN
                    v_week_code    := 'SUN';
                ELSIF v_week_num = 2 THEN
                    v_week_code    := 'MON';
                ELSIF v_week_num = 3 THEN
                    v_week_code    := 'TUE';
                ELSIF v_week_num = 4 THEN
                    v_week_code    := 'WED';
                ELSIF v_week_num = 5 THEN
                    v_week_code    := 'THU';
                ELSIF v_week_num = 6 THEN
                    v_week_code    := 'FRI';
                ELSIF v_week_num = 7 THEN
                    v_week_code    := 'SAT';
                ELSE
                    v_week_code    := 'ERR';
                END IF;    --> END : 2S10G Shift condition add
            
            --< Start 2023.03.09 : 2S10G Shift condition add    
            lgvatt_common_pkg.get_weekday_info(v_subsidiary_code, v_start_date+jj, v_week_code, i_attendance_code, v_holiday_code); --HMT_202201
            
            IF v_holiday_code like 'HD%' THEN 
              v_attendance_code   := i_attendance_code ;
            END IF ;
            
			--< Start HMT_20260601: Add 2A, 2B
            ELSIF r1.shift_type_code IN ('2A', '2B') THEN
                v_actual_date := TRUNC(v_start_date + jj);
                v_date_iw := TO_NUMBER(TO_CHAR(v_actual_date, 'iw'));
                v_date_iw := v_date_iw + (TO_NUMBER(TO_CHAR(v_actual_date, 'YYYY'))-2017) * 52;
                
                -- Make sure this shift is always Day, no Night flags.
                v_night_shift_flag := 'N'; 
                
                -- (0: Week 1, 1: Week 2)
                v_is_late_shift := 0;
                FOR r2 IN c2(v_base_date_iw, v_date_iw, v_cycle) 
                LOOP
                    v_is_late_shift := r2.night_flag; 
                END LOOP;
                
                -- Xác định Thứ và Mã ngày
                v_week_num := TO_NUMBER(TO_CHAR(v_actual_date, 'D'));
                
                IF v_week_num = 1 THEN v_week_code := 'SUN';
                ELSIF v_week_num = 2 THEN v_week_code := 'MON';
                ELSIF v_week_num = 3 THEN v_week_code := 'TUE';
                ELSIF v_week_num = 4 THEN v_week_code := 'WED';
                ELSIF v_week_num = 5 THEN v_week_code := 'THU';
                ELSIF v_week_num = 6 THEN v_week_code := 'FRI';
                ELSIF v_week_num = 7 THEN v_week_code := 'SAT';
                ELSE v_week_code := 'ERR';
                END IF;

                --: Only Sunday is WH, the rest are NW.
                IF v_week_num = 1 THEN
                    v_attendance_code := 'WH';
                ELSE
                    v_attendance_code := 'NW';
                END IF;
			--> End	
            --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??
            ELSIF r1.shift_type_code NOT LIKE '3%' THEN
            --> End
            
                v_date_iw := TO_NUMBER(TO_CHAR(TRUNC(v_start_date + jj), 'iw'));    -- 1??? ???(MON)?? ?? : ? ~ ?
                
                -- 2018.01.29 ??? : Shift ?? ??? 2017?? ???? ????? ?
                v_date_iw := v_date_iw + (TO_NUMBER(TO_CHAR(TRUNC(v_start_date + jj), 'YYYY'))-2017) * 52;
                
                FOR r2 IN c2(v_base_date_iw, v_date_iw, v_cycle) 
                LOOP
                    IF r2.night_flag = 1 THEN
                        v_night_shift_flag := 'Y';  -- Night
                    END IF;
                
                END LOOP;
                
                lgvatt_common_pkg.get_weekday_info(v_subsidiary_code, v_start_date+jj, v_week_code, v_attendance_code, v_holiday_code); --HMT_202201
            
            --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??    
            ELSE
            
                v_actual_date := TRUNC(v_start_date + jj);
                
                IF r1.shift_type_code = '32A' THEN
                    
                    v_standard_date := TO_DATE('20180901','YYYYMMDD');
                    
                ELSIF r1.shift_type_code = '32B' THEN
                    
                    v_standard_date := TO_DATE('20180824','YYYYMMDD');
                    
                ELSIF r1.shift_type_code = '32C' THEN
                    
                    v_standard_date := TO_DATE('20180828','YYYYMMDD');
                    
                ELSIF r1.shift_type_code = '32G' THEN
                    
                    v_standard_date := TO_DATE('20180904','YYYYMMDD');
                    
                ELSIF r1.shift_type_code = '32H' THEN
                    
                    v_standard_date := TO_DATE('20180829','YYYYMMDD');
                    
                 ELSE
                   
                    v_standard_date := TO_DATE('20180828','YYYYMMDD');
                    
                END IF;
                
                v_remain_day := MOD((v_actual_date - v_standard_date),12);
                
                IF v_remain_day IN (4,5,10,11) THEN
                
                    v_attendance_code := 'WH';
                    
                    IF v_remain_day IN (10,11) THEN
                    
                        v_night_shift_flag := 'Y'; 
                        
                    END IF;
                    
                ELSE
                
                    IF v_remain_day IN (6,7,8,9) THEN
                    
                        v_night_shift_flag := 'Y'; 
                        
                    END IF;
                    
                    v_attendance_code := 'NW';
                    
                END IF;
                
                v_week_num := TO_NUMBER(TO_CHAR(v_actual_date, 'D'));
                
                IF v_week_num = 1 THEN
                    v_week_code    := 'SUN';
                ELSIF v_week_num = 2 THEN
                    v_week_code    := 'MON';
                ELSIF v_week_num = 3 THEN
                    v_week_code    := 'TUE';
                ELSIF v_week_num = 4 THEN
                    v_week_code    := 'WED';
                ELSIF v_week_num = 5 THEN
                    v_week_code    := 'THU';
                ELSIF v_week_num = 6 THEN
                    v_week_code    := 'FRI';
                ELSIF v_week_num = 7 THEN
                    v_week_code    := 'SAT';
                ELSE
                    v_week_code    := 'ERR';
                END IF;
                
            END IF;
            --> End
            --lgvatt_common_pkg.get_weekday_info(v_subsidiary_code, v_start_date+jj, v_week_code, v_attendance_code, v_holiday_code); --HMT_202201
            
            --< Start 2023.03.09 : 2S10G Shift condition add    
            lgvatt_common_pkg.get_weekday_info(v_subsidiary_code, v_start_date+jj, v_week_code, i_attendance_code, v_holiday_code); --HMT_202201
            
            IF v_holiday_code like 'HD%' THEN 
              v_attendance_code   := i_attendance_code ;
            END IF ;
        
            v_attendance_time     := CASE WHEN v_night_shift_flag = 'Y'  -- Night
                                          THEN r1.night_shift_start_time
										  --< Start HMT_20260601: Add 2A, 2B
										  WHEN r1.shift_type_code = '2A' THEN 
                                               CASE WHEN v_is_late_shift = 0 THEN r1.day_shift_start_time ELSE r1.night_shift_start_time END
                                          WHEN r1.shift_type_code = '2B' THEN 
                                               CASE WHEN v_is_late_shift = 0 THEN r1.day_shift_start_time ELSE r1.night_shift_start_time END
											--> End   
                                          --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??    
                                          --ELSE r1.day_shift_start_time
                                          ELSE CASE WHEN r1.shift_type_code LIKE '3%' AND v_remain_day IN (10,11)
                                                    THEN r1.night_shift_start_time
                                                    ELSE r1.day_shift_start_time
                                               END
                                          --> End
                                     END;
                                     
            v_leaving_office_time := CASE WHEN (r1.shift_type_code LIKE '21%' OR r1.shift_type_code LIKE '22%' OR r1.shift_type_code LIKE '102%')
                                          --< Start 2023.03.09 : 2S10G Shift condition add --> END
                                          THEN TO_CHAR(TO_DATE(v_attendance_time, 'HH24:MI')+12/24, 'HH24:MI') 
                                          --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??    
                                          WHEN r1.shift_type_code LIKE '3%' 
                                          THEN TO_CHAR(TO_DATE(v_attendance_time, 'HH24:MI')+12/24, 'HH24:MI') 
                                          --> End
                                          --< Start HMT_20210316 : Change the leaving office time 1A
                                          WHEN r1.shift_type_code = '1A' AND v_attendance_code = 'NW' AND v_week_code <> 'FRI'
                                            AND v_start_date >= TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD')
                                          THEN TO_CHAR(TO_DATE(v_attendance_time, 'HH24:MI')+10/24, 'HH24:MI')
                                          --> End
										  --< Start HMT_20260601: Add 2A, 2B
                                          WHEN r1.shift_type_code IN ('2A', '2B') 
                                          THEN TO_CHAR(TO_DATE(v_attendance_time, 'HH24:MI')+6/24, 'HH24:MI')
										  --> End
                                          ELSE TO_CHAR(TO_DATE(v_attendance_time, 'HH24:MI')+09/24, 'HH24:MI') 
                                     END; 
                                     
            v_overtime_hours      := CASE WHEN v_attendance_code = 'NW'
                                          THEN CASE WHEN (r1.shift_type_code LIKE '2%' Or r1.shift_type_code LIKE '102%' ) 
                                            --< Start 2023.03.09 : 2S10G Shift condition add --> END
                                                    THEN CASE WHEN v_night_shift_flag = 'Y'  -- Night
                                                              --< Start 2019.09.27 Change the OT time for attendance base to 0 
                                                              --THEN 3
                                                              --ELSE 3
                                                              THEN 0
                                                              ELSE 0
                                                              --> End
                                                         END
                                                    --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??   
                                                    WHEN r1.shift_type_code LIKE '3%' 
                                                    THEN CASE WHEN v_night_shift_flag = 'Y'  -- Night
                                                              --< Start 2019.09.27 Change the OT time for attendance base to 0 
                                                              --THEN 1.5
                                                              --ELSE 1.5
                                                              THEN 0
                                                              ELSE 0
                                                              --> End
                                                         END
                                                    --> End
                                                    ELSE 0
                                               END
                                          ELSE 0
                                     END; 
            --< Start 2023.03.09 : 2S10G Shift condition add --> END
            --< Start 2023.03.09 : 2S10G Shift condition add
            IF r1.shift_type_code like '102%' THEN  
               v_time_attend_input_close_time := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_CLOSE_TIME', 'INPUT_CLOSE_TIME_' || SUBSTR(r1.shift_type_code, 3, 1) || v_night_shift_flag, 'A1');
               v_time_attend_apprv_close_time := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_CLOSE_TIME', 'APPRV_CLOSE_TIME_' || SUBSTR(r1.shift_type_code, 3, 1) || v_night_shift_flag, 'A1');        
              
            ELSE                         
               v_time_attend_input_close_time := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_CLOSE_TIME', 'INPUT_CLOSE_TIME_' || SUBSTR(r1.shift_type_code, 1, 1) || v_night_shift_flag, 'A1');
               v_time_attend_apprv_close_time := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_CLOSE_TIME', 'APPRV_CLOSE_TIME_' || SUBSTR(r1.shift_type_code, 1, 1) || v_night_shift_flag, 'A1');
            END IF ;
            abb_rec.subsidiary_code              := v_subsidiary_code;
            abb_rec.time_and_attendance_date     := v_start_date + jj;
            abb_rec.shift_type_code              := r1.shift_type_code;
            abb_rec.time_and_attendance_yyyymm   := v_time_and_attendance_yyyymm;
            abb_rec.a_day_of_the_week_code       := v_week_code;
            abb_rec.time_and_attendance_code     := v_attendance_code;
            abb_rec.attendance_time              := v_attendance_time;
            abb_rec.leaving_office_time          := v_leaving_office_time;
            abb_rec.night_shift_flag             := v_night_shift_flag;
            abb_rec.overtime_hours               := v_overtime_hours;
            abb_rec.time_attend_input_close_time := v_time_attend_input_close_time;
            abb_rec.time_attend_apprv_close_time := v_time_attend_apprv_close_time;
            --< Start 2023.03.09 : 2S10G Shift condition add
            IF r1.shift_type_code like '102%' THEN              
                IF v_attendance_code IN ('WH','PH') THEN 
                    abb_rec.work_hours           := 0;  
                ELSE
                    abb_rec.work_hours           := 8.0;  
                END IF;  
            --> END 2023.03.09 : 2S10G Shift condition add            
            
            --< Start 2018.10.18 ??? : ??? 32A,B,C Shift ?? ?? ??
            ELSIF r1.shift_type_code NOT LIKE '3%' THEN
                -- ????? ?????? 8?? : ?, ATTENDANCE_DAYS ?? ???
                abb_rec.work_hours               := lgvatt_common_pkg.get_work_hours(v_subsidiary_code, v_attendance_code, 0, 0, 0); 
                --< Start HMT_20210316 : Change the work hours
                IF v_week_code in ('MON','TUE','WED','THU') AND abb_rec.work_hours > 0
                  AND v_start_date >= TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD') THEN 
                  abb_rec.work_hours               := abb_rec.work_hours + 1;
                  END IF; 
                --> End
			--< Start HMT_20260601: Add 2A, 2B
		    ELSIF TRIM(r1.shift_type_code) IN ('2A', '2B') THEN
                IF v_attendance_code IN ('WH','PH') THEN 
                    abb_rec.work_hours           := 0;  
                ELSE
                    abb_rec.work_hours           := 5.0;  
                END IF;
			--> End	
            ELSE
                -- ??? 32A,B,C Shift ????
                IF v_attendance_code IN ('WH','PH') THEN --HMT_202201
                    abb_rec.work_hours           := 0;  
                ELSE
                    abb_rec.work_hours           := 9.5;  
                END IF;
            END IF;
            --> End
            --abb_rec.evening_meal_flag            := 'N'; --TaiDD--20200820
            IF r1.shift_type_code = '1A' THEN
               abb_rec.evening_meal_flag            := 'Y';
            ELSE
               abb_rec.evening_meal_flag            := 'N';
            END IF;               
            abb_rec.creation_user_id             := v_user_id;
            abb_rec.creation_date                := SYSDATE;
            
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_base_bas_record (abb_rec, 'CREATE');

        END LOOP;
      
    END LOOP;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_base;



/*************************************************************************************************/
/* Program Name : create_att_plan                                                                */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ?? ?? ???? ????.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_time_and_attendance_date        in    date      ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/23  ???B     ???? = NW ??, ???? = NW_NRM ??                            */
/*************************************************************************************************/
PROCEDURE create_att_plan (p_ret_code                   OUT VARCHAR2
                          ,p_ret_msg                    OUT VARCHAR2
                          ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                          ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                          ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                          ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                          )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);
  
    v_time_attendance_start_date  DATE;
    v_time_attendance_end_date    DATE;

    v_apply_result_flag           VARCHAR2(30);

    ap_rec                        tb_att_plan_n%ROWTYPE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0004', 'A1')) THEN  
        IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0004', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
            RETURN;  
        END IF;
        
        -- ????
        SELECT NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_plan_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;


    v_time_attendance_start_date  := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');  -- ???????
    v_time_attendance_end_date    := LAST_DAY(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'));  -- ???????

    DELETE tb_att_plan_n
    WHERE  subsidiary_code            = v_subsidiary_code
    AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    AND    employee_no                = NVL(p_employee_no, employee_no)
    AND    time_and_attendance_date   = NVL(p_time_and_attendance_date, time_and_attendance_date)
    ;

    FOR emp IN (SELECT *
                FROM   emp_master
                WHERE  subsidiary_code       = v_subsidiary_code
                AND    employee_number       = NVL(p_employee_no, employee_number)
                AND    date_hire_subsidiary <= v_time_attendance_end_date                            -- ????? ??????? ??
                AND    (date_retire         >= v_time_attendance_start_date OR date_retire IS NULL)  -- ????? ??????? ??
                AND    NVL(fse_yn,  'N')    <> 'Y'  -- FSE ??
                AND    NVL(flsa_yn, 'N')    <> 'Y'  -- ???? ??
               )
    LOOP
        FOR abb IN (SELECT * 
                    FROM   tb_att_base_bas_n
                    WHERE  subsidiary_code                = emp.subsidiary_code
                    AND    time_and_attendance_date BETWEEN v_time_attendance_start_date AND v_time_attendance_end_date  -- ??????
                    AND    shift_type_code                = NVL(lgvhr_common_pkg.get_shift_type_code_func(emp.subsidiary_code, emp.employee_number, time_and_attendance_date), '1A')  -- ???? ??????
                    AND    time_and_attendance_date       = NVL(p_time_and_attendance_date, time_and_attendance_date)
                   )
        LOOP
            ap_rec.subsidiary_code               := emp.subsidiary_code;             -- ??????
            ap_rec.time_and_attendance_date      := abb.time_and_attendance_date;    -- ????         
            ap_rec.shift_type_code               := abb.shift_type_code;             -- ??????
            ap_rec.employee_no                   := emp.employee_number;             -- ????
            ap_rec.time_and_attendance_yyyymm    := abb.time_and_attendance_yyyymm;  -- ????           
            ap_rec.a_day_of_the_week_code        := abb.a_day_of_the_week_code;      -- ????       
            ap_rec.time_and_attendance_code      := abb.time_and_attendance_code;    -- ????         
            ap_rec.night_shift_flag              := abb.night_shift_flag;            -- ???? 
            ap_rec.evening_meal_flag             := abb.evening_meal_flag;           -- ??????  
            ap_rec.overtime_sum_hours            := abb.overtime_hours;              -- ?????????
            ap_rec.planning_id                   := NULL;                            -- ???????
            ap_rec.progress_status_code          := NULL;                            -- ??????
            ap_rec.approval_request_id           := NULL;                            -- ???????
            ap_rec.request_code                  := NULL;                            -- ????
            ap_rec.time_attend_detail_code       := CASE WHEN abb.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END;  -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
            ap_rec.time_attend_input_reason_desc := NULL;                            -- ????????
            ap_rec.base_time_attend_apply_flag   := 'Y';                             -- ????????
            ap_rec.creation_user_id              := v_user_id;                       -- ????????
            ap_rec.creation_date                 := SYSDATE;                         -- ????
            ap_rec.last_update_user_id           := v_user_id;                       -- ??????????
            ap_rec.last_update_date              := SYSDATE;                         -- ??????
            
            IF (abb.time_and_attendance_date < emp.date_hire_subsidiary                          -- ??? ??
                OR
                abb.time_and_attendance_date > NVL(emp.date_retire, v_time_attendance_end_date)  -- ??? ??
               )
            THEN
                ap_rec.shift_type_code               := '1A';  -- ??????        
                ap_rec.time_and_attendance_code      := 'NN';  -- ????            
                ap_rec.time_attend_detail_code       := NULL;  -- ??????
                ap_rec.night_shift_flag              := 'N';   -- ????            
                ap_rec.evening_meal_flag             := 'N';   -- ??????        
                ap_rec.overtime_sum_hours            := 0;     -- ????????? 
            END IF; 

            -- ????
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_plan_record (ap_rec, 'CREATE');

        END LOOP;

    END LOOP;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_plan;


/*************************************************************************************************/
/* Program Name : create_att_result                                                                 */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ?? ?? ???? ????.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_time_and_attendance_date        in    date      ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/* 2019/09/27  TaiDD     The code should get the work hour based on the attendance code not from base_bas
                                     For example, the NN attendance code (resign or onboard employees) the Working Time should be 0 */
/* 2021/03/16  HMT_20210316   All saturday off - Update NORMAL_NIGHT_OVERTIME_HOURS in Friday   */
/*************************************************************************************************/
PROCEDURE create_att_result (p_ret_code                   OUT VARCHAR2
                            ,p_ret_msg                    OUT VARCHAR2
                            ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                            ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                            ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                            ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                            ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                            )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);

    v_ot_calc_status              VARCHAR2(100);
    ar_rec                        tb_att_result_n%ROWTYPE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0005', 'A1')) THEN  
        IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0005', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
            RETURN;  
        END IF;
        
        -- ????
        SELECT NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_result_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;


    DELETE tb_att_result_n
    WHERE  subsidiary_code            = v_subsidiary_code
    AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    AND    employee_no                = NVL(p_employee_no, employee_no)
    AND    time_and_attendance_date   = NVL(p_time_and_attendance_date, time_and_attendance_date)
    ;
    
    -- Plan ??? Result ????? Plan ???? ???
    -- Plan ?? ?????/????? ???
    INSERT INTO tb_att_result_n
      ( subsidiary_code,                 time_and_attendance_date,        shift_type_code,                 employee_no, 
        time_and_attendance_yyyymm,      a_day_of_the_week_code,          time_and_attendance_code,        work_hours, 
        work_start_time,                 night_shift_flag,                evening_meal_flag,               overtime_sum_hours, 
        weekday_overtime_hours,          holiday_overtime_hours,          public_holiday_overtime_hours,   weekday_night_overtime_hours, 
        weekday_ot_af_night_work_hours,  holiday_night_overtime_hours,    public_holiday_night_ot_hours,   normal_night_overtime_hours, 
        tardy_hours,                     early_leave_hours,               going_out_hours,                 special_bonus_hours, 
        helpcall_support_hours,          approval_request_id,             request_code,                    progress_status_code, 
        time_attend_detail_code,         time_attend_input_reason_desc,   base_time_attend_apply_flag, 
        creation_user_id,                creation_date,                   last_update_user_id,             last_update_date
      )
    SELECT
        ap.subsidiary_code,              ap.time_and_attendance_date,     ap.shift_type_code,              ap.employee_no, 
        ap.time_and_attendance_yyyymm,   ap.a_day_of_the_week_code,       ap.time_and_attendance_code, /*ab.work_hours*/lgvatt_common_pkg.get_work_hours_by_plan(ap.subsidiary_code, ap.employee_no, ap.time_and_attendance_date), -- 2019.09.27 TaiDD: get the work time base on the attendance code --HMT_20210324 Change the order employee_no and subsidiary_code 
        ab.attendance_time,              ap.night_shift_flag,             ap.evening_meal_flag,            0,  -- ap.overtime_sum_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
        0,                               0,                               0,                               0,
        0,                               0,                               0,                               0,
        0,                               0,                               0,                               0,
        0,                               NULL,                            NULL,                            NULL,
        ap.time_attend_detail_code,      NULL,                            'T',  -- 2018.01.30 ??? : OT ??? ??? ?? ??
        v_user_id,                       SYSDATE,                         v_user_id,                       SYSDATE
    FROM   tb_att_plan_n     ap
          ,tb_att_base_bas_n ab
    WHERE  ap.subsidiary_code            = v_subsidiary_code
    AND    ap.time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    AND    ap.employee_no                = NVL(p_employee_no, ap.employee_no)
    AND    ap.subsidiary_code            = ab.subsidiary_code
    AND    ap.time_and_attendance_date   = ab.time_and_attendance_date
    AND    ap.shift_type_code            = ab.shift_type_code
    AND    ap.time_and_attendance_date   = NVL(p_time_and_attendance_date, ap.time_and_attendance_date)
    ;


    -- 2018.01.30 ??? : OT ??? ??? ?? ??? ??? ??? OT ??
    lgvatt_transaction_pkg.apply_att_result_ot_calc (p_ret_code                    => p_ret_code
                                                    ,p_ret_msg                     => p_ret_msg
                                                    ,p_user_id                     => p_user_id
                                                    ,p_subsidiary_code             => p_subsidiary_code
                                                    ,p_base_time_attend_apply_flag => 'Y'
                                                    ,p_employee_no                 => p_employee_no
                                                    );
    IF (p_ret_code = '0') THEN
      --< Start 2023.03.09 : 2S10G Shift condition add      
         -- ?? ?? ??
          UPDATE TB_ATT_RESULT_N R SET R.NORMAL_NIGHT_OVERTIME_HOURS = 6 
           WHERE R.A_DAY_OF_THE_WEEK_CODE = 'FRI'
             AND R.NORMAL_NIGHT_OVERTIME_HOURS = 7
             AND R.TIME_AND_ATTENDANCE_YYYYMM = v_time_and_attendance_yyyymm
             AND R.SHIFT_TYPE_CODE NOT LIKE '3%';
         
        COMMIT;
     
    ELSE
        ROLLBACK;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_result;


/*************************************************************************************************/
/* Program Name : create_att_annual_leave                                                         */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ???? ?? ???? ? 5? ???? ????? ????                     */
/*                ?? 1?? ??/01 (??)?? ???? ??? ???? 1?? ??? ????   */
/*                ???? ????? ???? ????, ??/???? ?? ?? ??.           */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? (INTERVAL ??? ??)                                         */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/31  ???B     ????? ???? ????? ?? ??                              */
/* 2021/04/24  HMT_20210424  Annual Leave in advance (maximum 12 days/year)
                            Logic: (End of year date (31/12) - FC start date) / 365 * 12
/*************************************************************************************************/
PROCEDURE create_att_annual_leave (p_ret_code                   OUT NUMBER
                                  ,p_ret_msg                    OUT VARCHAR2
                                  ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                                  ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                  ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                                  ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                  )
IS
    v_subsidiary_code                  VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                          VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm       tb_att_annual_leave_n.time_and_attendance_yyyymm%TYPE;
    v_pre_time_attendance_yyyymm       tb_att_annual_leave_n.time_and_attendance_yyyymm%TYPE;
    v_max_time_attendance_yyyymm       tb_att_annual_leave_n.time_and_attendance_yyyymm%TYPE;
    v_occur_basis_first_date           DATE;
    v_occur_basis_last_date            DATE;
    v_fc_start_date                    DATE;         --HMT_20210424   FC contract start date
    v_total_al_year                    NUMBER := 0;  --HMT_20210424   ??????????
    v_al_cal                           NUMBER := 0;  --HMT_20210424   Annual Leave in advance 
    v_total_occur_basic                NUMBER := 0;  --HMT_20210424   ?????????? 

    anl_rec                            tb_att_annual_leave_n%ROWTYPE;                             -- ??????
    pre_anl_rec                        tb_att_annual_leave_n%ROWTYPE;                             -- ??????
    
    v_change_type                      VARCHAR2(30);                                              -- ????
    
    v_apply_result_flag                VARCHAR2(10);

    v_err_log                          VARCHAR2(2000);
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        -- ????? ??? ?? : 2018.02.12 ??? : ?? ?? ???? ?? : 01:03:05 ??
        --IF (TO_CHAR(SYSDATE, 'DD') <> lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0006', 'A1')) THEN  
        --IF (INSTR(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_MONTHLY_BATCH_DAY', 'LGVATTC0006', 'A1'), TO_CHAR(SYSDATE, 'DD')) <= 0) THEN
            --RETURN;  
        --END IF;
        
        -- ??1? 00? ??? ?????, ????? ??
        --v_time_and_attendance_yyyymm := TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'); HMT_20210424 Update current month
        v_time_and_attendance_yyyymm := TO_CHAR(SYSDATE, 'YYYYMM');
    END IF;

    v_pre_time_attendance_yyyymm := TO_CHAR(ADD_MONTHS(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM');  -- ??????
    v_occur_basis_first_date     := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');  -- ???????? : ???/01 ?? ???
    v_occur_basis_last_date      := LAST_DAY(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'));  -- ???????? : ???/?? ???

    v_max_time_attendance_yyyymm := TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM');  -- ?? ??????

    FOR emp IN (SELECT employee_number, 
                       date_hire_subsidiary, 
                       MONTHS_BETWEEN(v_occur_basis_last_date, date_hire_subsidiary) AS hire_months  -- ????? : 5??? ???
                FROM   emp_master
                WHERE  subsidiary_code = v_subsidiary_code
                AND    employee_number = NVL(p_employee_no, employee_number)
                AND    (date_retire IS NULL OR date_retire >= v_occur_basis_last_date)  -- ???/?? ?? ???
               )
    LOOP
      --HMT_20210424 Start Get Employee's FC contract start date, and total al in current year
        SELECT MAX(t.contract_period_start_date) INTO v_fc_start_date
          FROM TB_PAY_EMP_CONTRACT_N t
         WHERE t.contract_type_code = 'FC'
         AND   t.employee_no = emp.employee_number;
         
        SELECT nvl(sum(n.occur_monthly_ann_lv_days), 0), nvl(sum(n.occur_basic_annual_leave_days), 0) INTO v_total_al_year, v_total_occur_basic
          FROM tb_att_annual_leave_n n
         WHERE n.employee_no = emp.employee_number
           AND to_char(to_date(n.time_and_attendance_yyyymm,'YYYYMM') , 'YYYY') = TO_CHAR(SYSDATE, 'YYYY')
           AND n.time_and_attendance_yyyymm <> v_time_and_attendance_yyyymm;
        
        SELECT ROUND(((add_months(trunc(sysdate,'year'),12)-1) - emp.date_hire_subsidiary)/365*12 ,0) INTO v_al_cal
          FROM dual;
          
        IF v_al_cal > 12 THEN v_al_cal := 12; END IF;
      --HMT_20210424 End

        v_err_log := emp.employee_number;
        
        -- ??? ?? ????
        pre_anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec (v_subsidiary_code, emp.employee_number, v_pre_time_attendance_yyyymm);

        IF (SQL%ROWCOUNT = 0) THEN
            -- ??? ????????
            pre_anl_rec.residual_annual_leave_days := 0;
        END IF;
        
        -- ??? ????
        anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec (v_subsidiary_code, emp.employee_number, v_time_and_attendance_yyyymm);

        IF (SQL%ROWCOUNT > 0) THEN
            v_change_type := 'UPDATE';
        ELSE
            v_change_type := 'INSERT';
            
            anl_rec.subsidiary_code                  := v_subsidiary_code;             -- ??????
            anl_rec.employee_no                   := emp.employee_number;           -- ????
            anl_rec.time_and_attendance_yyyymm    := v_time_and_attendance_yyyymm;  -- ????
            anl_rec.hire_date                     := emp.date_hire_subsidiary;      -- ????
            anl_rec.occur_basic_annual_leave_days := 0;                             -- ??????????
            anl_rec.occur_monthly_ann_lv_days     := 0;                             -- ??????????
            anl_rec.annual_calibration_days       := 0;                             -- ??????
            anl_rec.use_annual_leave_days         := 0;                             -- ????????
            anl_rec.annual_compensation_days      := 0;                             -- ??????
            anl_rec.residual_annual_leave_days    := 0;                             -- ????????
            anl_rec.creation_user_id              := v_user_id;                     -- ????????
            anl_rec.creation_date                 := SYSDATE;                       -- ????
        END IF;

        -- ?????????? : ?? 1? ?? ??. ?, ????? ??
        /*IF (emp.date_hire_subsidiary <= v_occur_basis_first_date) THEN
            anl_rec.occur_monthly_ann_lv_days := 1;
        ELSE
            anl_rec.occur_monthly_ann_lv_days := 0;
        END IF;*/ --HMT_20210424 Start Caculate al and update occur_basic_annual_leave_days caculation

        IF (v_total_al_year + anl_rec.occur_monthly_ann_lv_days) < v_al_cal OR to_char(sysdate,'MM/DD') = to_char(emp.date_hire_subsidiary, 'MM/DD') THEN
        IF v_fc_start_date <= sysdate  THEN
            anl_rec.occur_monthly_ann_lv_days := v_al_cal - v_total_al_year;
        ELSE
            anl_rec.occur_monthly_ann_lv_days := 0;
        END IF;
        IF to_char(sysdate,'MM/DD') = '01/01' THEN
          anl_rec.occur_basic_annual_leave_days := TRUNC(MONTHS_BETWEEN(sysdate, emp.date_hire_subsidiary)/60);
        END IF;
        --HMT_20210424 End

        -- ?????????? : 5??? 1? ??(5? 1?, 10? 2?, ...) : ??? ????? ????? ??
        --IF (MOD(TRUNC(emp.hire_months), 60) = 0) THEN
            --anl_rec.occur_basic_annual_leave_days := TRUNC(emp.hire_months / 60);
        IF to_char(sysdate,'MM/DD') = to_char(emp.date_hire_subsidiary, 'MM/DD') THEN
            anl_rec.occur_basic_annual_leave_days := TRUNC(MONTHS_BETWEEN(sysdate, emp.date_hire_subsidiary)/60) - v_total_occur_basic; --HMT_20210424 (- v_total_occur_basic)
        ELSE
            anl_rec.occur_basic_annual_leave_days := 0;
        END IF;
        
        -- ????????
        anl_rec.residual_annual_leave_days    := NVL(pre_anl_rec.residual_annual_leave_days, 0)  -- ????????
                                               + NVL(anl_rec.occur_basic_annual_leave_days,  0)  -- ??????????
                                               + NVL(anl_rec.occur_monthly_ann_lv_days,      0)  -- ??????????
                                               + NVL(anl_rec.annual_calibration_days,        0)  -- ??????
                                               - NVL(anl_rec.use_annual_leave_days,          0)  -- ????????
                                               - NVL(anl_rec.annual_compensation_days,       0)  -- ??????
                                               ;

        anl_rec.hire_date                     := emp.date_hire_subsidiary;      -- ???? : ???? ???? ?? ???
        anl_rec.apply_date                    := TRUNC(SYSDATE);                -- ????
        anl_rec.last_update_user_id           := v_user_id;                     -- ??????????
        anl_rec.last_update_date              := SYSDATE;                       -- ??????

        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_annual_leave_record (anl_rec);
        
        END IF;


        -- ???? ??
        DELETE tb_att_annual_leave_n
        WHERE  employee_no                = emp.employee_number
        AND    time_and_attendance_yyyymm > v_time_and_attendance_yyyymm
        ;
        
        -- ??????? ??
        INSERT INTO tb_att_annual_leave_n
          ( subsidiary_code,               employee_no,               time_and_attendance_yyyymm, hire_date, 
            occur_basic_annual_leave_days, occur_monthly_ann_lv_days, use_annual_leave_days,      residual_annual_leave_days, 
            apply_date,                    annual_calibration_days,   annual_compensation_days, 
            creation_user_id,              creation_date,             last_update_user_id,        last_update_date
          )
        SELECT an.subsidiary_code            AS subsidiary_code, 
               an.employee_no                AS employee_no, 
               mm.time_and_attendance_yyyymm AS time_and_attendance_yyyymm, 
               an.hire_date                  AS hire_date, 
               0                             AS occur_basic_annual_leave_days, 
               0                             AS occur_monthly_ann_lv_days, 
               0                             AS use_annual_leave_days, 
               an.residual_annual_leave_days AS residual_annual_leave_days, 
               an.apply_date                 AS apply_date, 
               0                             AS annual_calibration_days, 
               0                             AS annual_compensation_days, 
               v_user_id                     AS creation_user_id, 
               SYSDATE                       AS creation_date, 
               v_user_id                     AS last_update_user_id, 
               SYSDATE                       AS last_update_date
        FROM   tb_att_annual_leave_n an,
               (SELECT TO_CHAR(ADD_MONTHS(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), LEVEL), 'YYYYMM') AS time_and_attendance_yyyymm
                FROM   dual
                CONNECT BY LEVEL <= MONTHS_BETWEEN(TO_DATE(v_max_time_attendance_yyyymm, 'YYYYMM'), TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'))
               ) mm
        WHERE  an.employee_no                = emp.employee_number
        AND    an.time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
        ;

    END LOOP;
    
    COMMIT;
    
    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);
    
    p_ret_code := 1;
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;

END create_att_annual_leave;

/*************************************************************************************************/
/* Program Name : create_att_ot_level                                                                */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ?? ?? ???? ????.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? ?? ???? ???? ?? (INTERVAL ??? ??)             */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_time_and_attendance_date        in    date      ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/04/06  HMT_20210406     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE create_att_ot_level (p_ret_code                   OUT VARCHAR2
                              ,p_ret_msg                    OUT VARCHAR2
                              ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                              ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                              ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                              ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                              )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);
  
    v_time_attendance_start_date  DATE;
    v_time_attendance_end_date    DATE;

    v_ot_level_exist              NUMBER := 0;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
    
    -- Schedule ????
    ELSE
        
        -- ????
        v_time_and_attendance_yyyymm := TO_CHAR(SYSDATE, 'YYYYMM');

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
    END IF;
    
    SELECT COUNT(1) INTO v_ot_level_exist FROM TB_ATT_OT_LEVEL T WHERE T.TIME_AND_ATTENDANCE_YYYYMM = v_time_and_attendance_yyyymm;
    
    IF v_ot_level_exist = 0 THEN 
      INSERT INTO TB_ATT_OT_LEVEL
        ( ot_level_id, subsidiary_code, time_and_attendance_yyyymm    
         ,shift_type_code ,ot_level ,lower_limit            
         ,upper_limit ,ot_category ,remark            
         ,creation_user_id ,creation_date           
         ,last_update_user_id ,last_update_date       
        ) 
         SELECT TB_ATT_OT_LEVEL_SEQ.NEXTVAL,T.subsidiary_code, v_time_and_attendance_yyyymm   
         ,T.shift_type_code, T.ot_level, T.lower_limit            
         ,T.upper_limit, T.ot_category, T.remark
         ,'1', sysdate
         ,'1', sysdate
         FROM TB_ATT_OT_LEVEL T WHERE T.TIME_AND_ATTENDANCE_YYYYMM = TO_CHAR(ADD_MONTHS(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM')
        ;
    
      END IF;


    v_time_attendance_start_date  := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');  -- ???????
    v_time_attendance_end_date    := LAST_DAY(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'));  -- ???????

    DELETE tb_att_ot_level_info_n
    WHERE  subsidiary_code            = v_subsidiary_code
    AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
    AND    employee_no                = NVL(p_employee_no, employee_no)
    ;
    
    INSERT INTO tb_att_ot_level_info_n
      ( subsidiary_code,                 employee_no,                     time_and_attendance_yyyymm,        level_0,
        level_1,                         level_2,                         level_3,                           level_4,
        apply_flag,          
        creation_user_id,                creation_date,                   last_update_user_id,               last_update_date
      )
    SELECT em.subsidiary_code,           em.employee_number,              v_time_and_attendance_yyyymm,      0,
           0,                            0,                               0,                                 0,
           'T',
           v_user_id,                    sysdate,                         v_user_id,                         sysdate
        FROM   emp_master em
        WHERE  em.subsidiary_code       = v_subsidiary_code
          AND  em.employee_number       = NVL(p_employee_no, em.employee_number)
          AND  em.employee_number  IN ( select distinct tn.employee_no from tb_att_result_n tn 
                                                       where tn.subsidiary_code = v_subsidiary_code
                                                         and tn.time_and_attendance_yyyymm = v_time_and_attendance_yyyymm)
    ;
    
    lgvatt_ot_level_pkg.apply_att_ot_level_calc (p_ret_code                    => p_ret_code
                                                ,p_ret_msg                     => p_ret_msg
                                                ,p_user_id                     => p_user_id
                                                ,p_subsidiary_code             => p_subsidiary_code
                                                ,p_apply_flag                  => 'Y'
                                                ,p_employee_no                 => p_employee_no
                                                );

     IF (p_ret_code = '0') THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END create_att_ot_level;

/*************************************************************************************************/
/* Program Name : update_att_result_without_io                                                                */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Normal work without In/Out data automatically changes to Unpaid leave.                                                   */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : Every at 05:00 on 3rd every month to update for the previous month                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyymm      in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_time_and_attendance_date        in    date      ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/04/26  HMT_20210406     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE update_att_result_without_io (p_ret_code                   OUT VARCHAR2
                                       ,p_ret_msg                    OUT VARCHAR2
                                       ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                                       ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                       ,p_time_and_attendance_yyyymm IN  VARCHAR2 DEFAULT NULL
                                       ,p_employee_no                IN  VARCHAR2 DEFAULT NULL
                                       ,p_time_and_attendance_date   IN  DATE     DEFAULT NULL
                                       )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm  VARCHAR2(30);

    v_unpaid_apply_date        DATE;
    v_period_from_date         DATE;
    v_period_to_date       DATE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? ????
    IF (p_time_and_attendance_yyyymm IS NOT NULL) THEN
        v_time_and_attendance_yyyymm := p_time_and_attendance_yyyymm;
        v_period_from_date           := TO_DATE(p_time_and_attendance_yyyymm || '01', 'YYYYMMDD');
        v_period_to_date             := LAST_DAY(TO_DATE(p_time_and_attendance_yyyymm, 'YYYYMM'));
    
    -- Schedule ????
    ELSE
        
        -- ????
        v_time_and_attendance_yyyymm := TO_CHAR(SYSDATE, 'YYYYMM');        

        -- ?? ????????? ??
        IF (v_time_and_attendance_yyyymm > TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM')) THEN
            RETURN;
        END IF;
        IF TO_CHAR(SYSDATE, 'DD') = '03' THEN
          v_time_and_attendance_yyyymm := TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM');              
        END IF;
        
        SELECT n.unpaid_apply_date, n.period_from_date, nvl(n.unpaid_period_date, n.period_to_date)
          INTO v_unpaid_apply_date, v_period_from_date, v_period_to_date
          FROM TB_ATT_CLOSE_N n
         WHERE n.time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
           AND n.confirm_flag = 'N'
           --AND TO_CHAR(n.unpaid_apply_date, 'YYYY/MM/DD') = TO_CHAR(SYSDATE, 'YYYY/MM/DD')
           AND rownum = 1;
         
        IF TO_CHAR(v_unpaid_apply_date, 'YYYY/MM/DD') <> TO_CHAR(SYSDATE, 'YYYY/MM/DD') OR v_unpaid_apply_date IS NULL THEN
            RETURN;  
        END IF;
        
    END IF;

   update tb_att_result_n n 
   set n.time_and_attendance_code = 'UL'
       ,n.work_hours = 0
       ,n.evening_meal_flag = 'N'
       ,n.overtime_sum_hours = 0
       ,n.weekday_overtime_hours = 0
       ,n.holiday_overtime_hours = 0
       ,n.public_holiday_overtime_hours = 0
       ,n.weekday_night_overtime_hours = 0
       ,n.weekday_ot_af_night_work_hours = 0
       ,n.holiday_night_overtime_hours = 0
       ,n.public_holiday_night_ot_hours = 0
       ,n.normal_night_overtime_hours = 0
       ,n.tardy_hours = 0
       ,n.early_leave_hours = 0
       ,n.going_out_hours = 0
       ,n.special_bonus_hours = 0
       ,n.helpcall_support_hours = 0
       ,n.time_attend_detail_code = 'UL_OTH'
       ,n.base_time_attend_apply_flag = 'N'
       ,n.approval_request_id = ''
       ,n.request_code = ''
       ,n.last_update_user_id = v_user_id
       ,n.last_update_date = sysdate
 where n.time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
   and n.time_and_attendance_date between v_period_from_date and v_period_to_date
   and n.time_and_attendance_code = 'NW'
   and n.progress_status_code <> '40'
   and n.time_attend_detail_code not like '%WFH'
   --and (n.progress_status_code is null OR n.progress_status_code in ('50','60')) Customer don't want
   and EXISTS
       (select 'Y'
          from TB_ATT_IDCARD_ACS_TIME_N t
         where t.employee_no = n.employee_no
           and t.time_and_attendance_date = n.time_and_attendance_date
           and t.check_in_date is null
           and t.check_out_date is null);
    
   

     IF (p_ret_code = '0') THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END update_att_result_without_io;


/*************************************************************************************************/
/* Program Name : apply_att_annual_lv_correction                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ?? ???? ?? ???? ????? ????.                               */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ???? ???? ??                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_time_and_attendance_yyyy        in    varchar2  ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/* 2019/09/29  TaiDD    The suspense period of maternity leave (Code: US_CHB) which was paid 
              by insurance, still be count as working days when calculate/adjust/correct the annual leave
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_annual_lv_correction (p_ret_code                 OUT VARCHAR2
                                         ,p_ret_msg                  OUT VARCHAR2
                                         ,p_user_id                  IN  VARCHAR2
                                         ,p_subsidiary_code          IN  VARCHAR2
                                         ,p_time_and_attendance_yyyy IN  VARCHAR2
                                         ,p_employee_no              IN  VARCHAR2 DEFAULT NULL
                                         )
IS
    v_subsidiary_code                  VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                          VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm       tb_att_annual_leave_n.time_and_attendance_yyyymm%TYPE;
    v_pre_time_attendance_yyyymm       tb_att_annual_leave_n.time_and_attendance_yyyymm%TYPE;

    pre_anl_rec                        tb_att_annual_leave_n%ROWTYPE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    v_time_and_attendance_yyyymm := p_time_and_attendance_yyyy || '12';
    v_pre_time_attendance_yyyymm := p_time_and_attendance_yyyy || '11';

    FOR per IN (SELECT employee_no
                      ,full_days
                      ,working_days
                      ,unpaid_days
                      ,ROUND((working_days - unpaid_days) / full_days * 12, 0) AS calibration_days          -- ??? ?? ?? ????
                      ,yearly_annual_leave_days                                AS yearly_annual_leave_days  -- ??? ?? ?? ????
                      --,GREATEST(0, (ROUND((working_days - unpaid_days) / full_days * 12, 0) - yearly_annual_leave_days)) AS difference_days  -- ??? ?? ????
                      ,GREATEST(0, (ROUND((working_days - unpaid_days + pregnancy_days) / full_days * 12, 0) - yearly_annual_leave_days)) AS difference_days --TaiDD 20190929 add the pregnancy_days
                FROM   (
                        SELECT ar.employee_no
                              ,ar.full_days
                              ,ar.working_days
                              ,ar.unpaid_days
                              ,NVL(SUM(aa.occur_monthly_ann_lv_days), 0) AS yearly_annual_leave_days  -- ??? ?? ?? ????
                              ,ar.pregnancy_days --TaiDD 20190929
                        FROM   (
                                SELECT ar.subsidiary_code
                                      ,ar.employee_no
                                      ,em.full_days                                                             -- 1? ????
                                      ,(em.attendance_end_date - em.attendance_start_date + 1) AS working_days  -- ??? ????
                                      ,NVL(SUM(ac.unpaid_days), 0)                             AS unpaid_days   -- ??? ????
                                      ,NVL(SUM(CASE WHEN ar.time_attend_detail_code = 'US_CHB' THEN 1 ELSE 0 END), 0) AS pregnancy_days --TaiDD 20190929 - Count the pregnancy day paid by Insurance
                                FROM   (
                                        SELECT subsidiary_code      AS subsidiary_code
                                              ,employee_number      AS employee_number
                                              ,(TO_DATE(p_time_and_attendance_yyyy || '1231', 'YYYYMMDD') - TO_DATE(p_time_and_attendance_yyyy || '0101', 'YYYYMMDD') + 1) AS full_days  -- 1? ????
                                              ,GREATEST(date_hire_subsidiary, TO_DATE(p_time_and_attendance_yyyy || '0101', 'YYYYMMDD'))                                   AS attendance_start_date  -- ??? ?????
                                              ,TO_DATE(p_time_and_attendance_yyyy || '1231', 'YYYYMMDD')                                                                   AS attendance_end_date    -- ??? ?????
                                        FROM   emp_master
                                        WHERE  subsidiary_code = p_subsidiary_code
                                        AND    employee_number = NVL(p_employee_no, employee_number)
                                        AND    (date_retire IS NOT NULL OR date_retire >= TO_DATE(p_time_and_attendance_yyyy || '1231', 'YYYYMMDD'))  -- ????
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
                        AND    aa.time_and_attendance_yyyymm BETWEEN p_time_and_attendance_yyyy || '01' AND p_time_and_attendance_yyyy || '12'
                        GROUP BY ar.employee_no, ar.full_days, ar.working_days, ar.unpaid_days
                                       ,ar.pregnancy_days --TaiDD 20190929                
                       )
               )
    LOOP
        -- ?? ????
        pre_anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec(p_subsidiary_code, per.employee_no, v_pre_time_attendance_yyyymm);
        
        -- ???? ??
        UPDATE tb_att_annual_leave_n
        SET    annual_calibration_days    = per.difference_days
              ,annual_compensation_days   = 0                                               -- ???? (????? ???? ??? ??? ???)
              ,residual_annual_leave_days = NVL(pre_anl_rec.residual_annual_leave_days, 0)  -- ???? = ????
                                          + NVL(occur_basic_annual_leave_days, 0)           --          + ????????(5???)
                                          + NVL(occur_monthly_ann_lv_days, 0)               --          + ??????
                                          - NVL(use_annual_leave_days, 0)                   --          - ??????
                                          + per.difference_days                             --          + ????
              ,last_update_user_id        = p_user_id
              ,last_update_date           = SYSDATE
        WHERE  subsidiary_code            = v_subsidiary_code
        AND    employee_no                = per.employee_no
        AND    time_and_attendance_yyyymm = v_time_and_attendance_yyyymm
        ;
    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
END apply_att_annual_lv_correction;


/*************************************************************************************************/
/* Program Name : apply_att_annual_lv_corr_retir                                                    */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ???? ??? ?? ???? ????? ????.                             */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ???? ???? ??                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_payroll_calculation_set_id      in    number    ?????SetId              */
/*                p_employee_no                     in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/* 2019/09/29  TaiDD    The suspense period of maternity leave (Code: US_CHB) which was paid 
              by insurance, still be count as working days when calculate/adjust/correct the annual leave
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_annual_lv_corr_retir (p_ret_code                   OUT VARCHAR2
                                         ,p_ret_msg                    OUT VARCHAR2
                                         ,p_user_id                    IN  VARCHAR2
                                         ,p_subsidiary_code            IN  VARCHAR2
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
                       ,ROUND((working_days - unpaid_days) / full_days * 12, 0) AS calibration_days          -- ??? ?? ?? ????
                       ,yearly_annual_leave_days                                AS yearly_annual_leave_days  -- ??? ?? ?? ????
                       --,GREATEST(0, (ROUND((working_days - unpaid_days) / full_days * 12, 0) - yearly_annual_leave_days)) AS difference_days  -- ??? ?? ????
                       ,GREATEST(0, (ROUND((working_days - unpaid_days + pregnancy_days) / full_days * 12, 0) - yearly_annual_leave_days)) AS difference_days  --TaiDD 20190929 add the pregnancy_days
                       ,time_and_attendance_yyyymm
                 FROM   (
                         SELECT ar.employee_no
                               ,ar.full_days
                               ,ar.working_days
                               ,ar.unpaid_days
                               ,NVL(SUM(aa.occur_monthly_ann_lv_days), 0) AS yearly_annual_leave_days  -- ??? ?? ?? ????
                               ,MAX(aa.time_and_attendance_yyyymm)        AS time_and_attendance_yyyymm  -- ?? ??
                               ,ar.pregnancy_days --TaiDD 20190929
                         FROM   (
                                 SELECT ar.subsidiary_code
                                       ,ar.employee_no
                                       ,em.attendance_start_date
                                       ,em.attendance_end_date
                                       ,em.full_days                                                             -- 1? ????
                                       ,(em.attendance_end_date - em.attendance_start_date + 1) AS working_days  -- ??? ????
                                       ,NVL(SUM(ac.unpaid_days), 0)                             AS unpaid_days   -- ??? ????
                                       ,NVL(SUM(CASE WHEN ar.time_attend_detail_code = 'US_CHB' THEN 1 ELSE 0 END), 0) AS pregnancy_days --TaiDD 20190929 - Count the pregnancy day paid by Insurance
                                 FROM   (
                                         SELECT em.subsidiary_code      AS subsidiary_code
                                               ,em.employee_number      AS employee_number
                                               ,(TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '1231', 'YYYYMMDD') - TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '0101', 'YYYYMMDD') + 1) AS full_days  -- 1? ????
                                               ,GREATEST(em.date_hire_subsidiary, TO_DATE(TO_CHAR(em.date_retire, 'YYYY') || '0101', 'YYYYMMDD'))                                     AS attendance_start_date  -- ??? ?????
                                               ,em.date_retire                                                                                                                        AS attendance_end_date    -- ??? ?????
                                         FROM   tb_pay_calc_set_target_per_n ps
                                               ,emp_master                   em
                                         WHERE  ps.payroll_calculation_set_id = p_payroll_calculation_set_id  -- ?????SetId
                                         AND    ps.employee_no                = NVL(p_employee_no, ps.employee_no)
                                         AND    ps.employee_no                = em.employee_number
                                         AND    em.subsidiary_code            = p_subsidiary_code
                                         AND    em.date_retire               IS NOT NULL  -- ????
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
                                        ,ar.pregnancy_days --TaiDD 20190929
                        )
               )
    LOOP
        -- ?? ????
        pre_anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec(p_subsidiary_code, per.employee_no, TO_CHAR(ADD_MONTHS(TO_DATE(per.time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM'));
        
        -- ???? ??
        UPDATE tb_att_annual_leave_n
        SET    annual_calibration_days    = per.difference_days
              ,annual_compensation_days   = NVL(pre_anl_rec.residual_annual_leave_days, 0)  -- ???? = ????
                                          + NVL(occur_basic_annual_leave_days, 0)           --          + ????????(5???)
                                          + NVL(occur_monthly_ann_lv_days, 0)               --          + ??????
                                          - NVL(use_annual_leave_days, 0)                   --          - ??????
                                          + per.difference_days                             --          + ????
              ,residual_annual_leave_days = 0                                               -- ???? = 0 (??????, ?? ???)
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


/*************************************************************************************************/
/* Program Name : apply_att_contract_pl                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Part Leader ? ?? ??? PIC ? ????.                                    */
/*                ??? ????? ?? ???, ???? ??? ???? ???,                */
/*                last_update_user_id = -19 ? ????.(?? ????? ?????)             */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ??                                                                */
/*                ???? : ?? 45?                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2018/01/31  ???B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_contract_pl (p_ret_code                   OUT NUMBER
                                ,p_ret_msg                    OUT VARCHAR2
                                ,p_user_id                    IN  VARCHAR2 DEFAULT NULL
                                ,p_subsidiary_code            IN  VARCHAR2 DEFAULT NULL
                                )
IS
    v_subsidiary_code                  VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                          VARCHAR2(30) := NVL(p_user_id, g_user_id);

    ac_rec                             tb_att_contract_n%ROWTYPE;
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ?? Part Leader ? ?? ??? PIC ? ??
    FOR ptl IN (SELECT *
                FROM   emp_master em
                WHERE  em.subsidiary_code = v_subsidiary_code
                AND    em.date_retire    IS NULL
                AND    em.position        = '500'
               )
    LOOP
    
        FOR org IN (SELECT *
                    FROM   org_master om
                    WHERE  om.org_end_date IS NULL
                    START WITH om.subsidiary_code = ptl.subsidiary_code
                    AND        om.organization_id = ptl.organization_id
                    CONNECT BY NOCYCLE 
                               PRIOR om.subsidiary_code = om.subsidiary_code
                    AND        PRIOR om.organization_id = om.parent_org_id
                   )
        LOOP

            BEGIN
                SELECT *
                INTO   ac_rec
                FROM   tb_att_contract_n ac
                WHERE  ac.subsidiary_code             = ptl.subsidiary_code
                AND    ac.time_attend_contact_user_id = ptl.employee_number
                AND    ac.organization_id             = ptl.organization_id
                ;
                
                -- ????? ???
                IF (ac_rec.effective_end_date IS NOT NULL) THEN

                    UPDATE tb_att_contract_n
                    SET    effective_end_date  = NULL
                          ,last_update_user_id = '-19'  -- ???? ???
                          ,last_update_date    = SYSDATE
                    WHERE  subsidiary_code             = ptl.subsidiary_code
                    AND    time_attend_contact_user_id = ptl.employee_number
                    AND    organization_id             = ptl.organization_id
                    ;

                END IF;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- "-19" : ???? ???
                INSERT INTO tb_att_contract_n
                  ( subsidiary_code,      time_attend_contact_user_id, organization_id, 
                    effective_start_date, effective_end_date, 
                    creation_user_id,     creation_date,               last_update_user_id,     last_update_date
                  )
                VALUES
                  ( ptl.subsidiary_code,  ptl.employee_number,         ptl.organization_id, 
                    TRUNC(SYSDATE),       NULL,
                    '-19',                SYSDATE,                     '-19',                   SYSDATE
                  );
            END;
            
        END LOOP;

    END LOOP;


    -- Part Leader ????? PIC ? ?? Part Leader ???, PIC ??
    FOR pic IN (SELECT *
                FROM   tb_att_contract_n ac
                WHERE  subsidiary_code     = v_subsidiary_code
                AND    last_update_user_id = '-19'
                AND    NVL(effective_end_date, TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   emp_master em
                                   WHERE  em.subsidiary_code = ac.subsidiary_code
                                   AND    em.employee_number = ac.time_attend_contact_user_id
                                   AND    em.date_retire    IS NULL
                                   AND    em.position        = '500'
                                  )
               )
    LOOP
        -- PIC ??
        UPDATE tb_att_contract_n
        SET    effective_end_date  = TRUNC(SYSDATE)-1
              ,last_update_user_id = '-19'  -- ???? ???
              ,last_update_date    = SYSDATE
        WHERE  subsidiary_code             = pic.subsidiary_code
        AND    time_attend_contact_user_id = pic.time_attend_contact_user_id
        AND    organization_id             = pic.organization_id
        AND    last_update_user_id         = '-19'
        ;
    END LOOP;

    COMMIT;
    
    p_ret_code := 0;
    p_ret_msg  := '';

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END apply_att_contract_pl;


/*************************************************************************************************/
/* Program Name : apply_att_fr_asg                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ????? ????? ????? ????.                                     */
/*                                                                                               */
/*                p_att_type                                                                     */
/*                    NEW    : ?????                                                        */
/*                    RETIRE : ???                                                            */
/*                    SHIFT  : ????                                                          */
/*                    SUSP   : ????                                                          */
/*                    CANCEL : ?????                                                        */
/*                    RETIRE_CHG : ????                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ?? 6????                                                      */
/*                ???? : 01?, 07?, 13?, 19?                                              */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_att_type                        in    varchar2  ????                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_basic_date                      in    date      ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/* 2018/01/23  ???B     ???? = NW ??, ???? = NW_NRM ??                            */
/*                                                                                               */
/* 2018/02/05  ???B     ????(US) ??, 2?????? ???, ???? ??                */
/*                         ????? ???? ??? ?????, ??? ???? ???? ??  */
/*                         ????, ???/?? WH ??? ??                                  */
/*                                                                                               */
/* 2018/02/28  ???C     ?? ?? ??? HL?? ??                                          */
/*                                                                                               */
/* 2018/04/27  ???B     ????? ?? ????? ??? ?? : ??? ??? ??           */
/*                         ?????? ?? ?????? ??? ?? : ??? ?? ?? ??    */
/* 2019/11/14  TaiDD: For the p_att_type = RESIGN (att_code = NN) add the code to set te work_hour = 0 when update the tb_att_result_n           */
/* 2020/07/02  TaiDD: RETIRE_CHG section when insert the new data for tb_att_result_n (att_code = NN) should set te work_hour = 0, not get the work hour from tb_att_base_bas    */
/* 2021/07/17  HMT_20210717          Swap weekly holiday (Add p_employee_no)                   */
/* 2022/03/01  HMT_20220301          If had approval or confirm swap data --> no update this attendance day                    */
/*                          time_and_attendance_code  -->   NVL(lgvatt_common_pkg.get_att_date_type(p_subsidiary_code,employee_no, time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),time_and_attendance_code)
/*                          shift_type_code                  -->  NVL(lgvatt_common_pkg.get_att_date_type(p_subsidiary_code,employee_no, time_and_attendance_date,'SHIFT_CODE_SWAP'),shift_type_code)
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_fr_asg (p_ret_code         OUT VARCHAR2
                           ,p_ret_msg          OUT VARCHAR2
                           ,p_user_id          IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code  IN  VARCHAR2 DEFAULT NULL
                           ,p_att_type         IN  VARCHAR2 DEFAULT 'ALL'
                           ,p_basic_date       IN  DATE     DEFAULT NULL
                           ,p_employee_no      IN  VARCHAR2 DEFAULT NULL
                           )
IS
    v_subsidiary_code               VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                       VARCHAR2(30) := NVL(p_user_id, g_user_id);

    v_time_and_attendance_yyyymm    VARCHAR2(30);  -- ?????? ????
    v_anl_time_attendance_yyyymm    VARCHAR2(30);  -- ?????? ????
    v_time_attend_start_date        DATE;          -- ?????? ???? ???
    v_time_attend_end_date          DATE;          -- ?????? ???? ???

    v_basic_date                    DATE;          -- ????
    v_asg_basic_date                DATE;          -- ??????
    
    
    v_asg_start_date                DATE;
    v_asg_end_date                  DATE;
    
    v_asg_2nd_reason_code           VARCHAR2(30);

    v_shift_type_code               VARCHAR2(10);

    v_future_creation_months        NUMBER;        -- ???????

    v_apply_result_flag             VARCHAR2(30);
    v_ot_calc_status                VARCHAR2(100);    
    
    v_residual_annual_leave_days    NUMBER;
    v_prev_residual_leave_days      NUMBER;

    abb_rec                         tb_att_base_bas_n%ROWTYPE;
    ap_rec                          tb_att_plan_n%ROWTYPE;
    ar_rec                          tb_att_result_n%ROWTYPE;

    anl_rec                         tb_att_annual_leave_n%ROWTYPE;  -- ??????
    pre_anl_rec                     tb_att_annual_leave_n%ROWTYPE;  -- ??????

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    v_basic_date     := TRUNC(NVL(p_basic_date, SYSDATE));  -- ????(??? ??)
    v_asg_basic_date := TO_DATE(TO_CHAR(ADD_MONTHS(v_basic_date, -12), 'YYYYMM') || '01', 'YYYYMMDD');  -- ?????? : ???? - 12??
    
    v_time_and_attendance_yyyymm := lgvatt_common_pkg.get_curr_att_yyyymm(v_subsidiary_code, 'FIRST');  -- ?? ???? ?? ??? ???? : ???? ??
    v_time_attend_start_date     := TO_DATE(v_time_and_attendance_yyyymm || '01', 'YYYYMMDD');          -- ???? ???
    v_time_attend_end_date       := ADD_MONTHS(LAST_DAY(TRUNC(SYSDATE)), g_future_creation_months);     -- ???? ???
    
    v_anl_time_attendance_yyyymm := TO_CHAR(ADD_MONTHS(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), -1), 'YYYYMM');  -- ???? ??? ???? : ?????? - 1?? : ????? ????

--dbms_output.put_line ('v_basic_date                 = ' || TO_CHAR(v_basic_date, 'YYYY/MM/DD'));
--dbms_output.put_line ('v_asg_basic_date             = ' || TO_CHAR(v_asg_basic_date, 'YYYY/MM/DD'));
--dbms_output.put_line ('v_time_and_attendance_yyyymm = ' || v_time_and_attendance_yyyymm);
--dbms_output.put_line ('v_time_attend_start_date     = ' || TO_CHAR(v_time_attend_start_date, 'YYYY/MM/DD'));
--dbms_output.put_line ('v_time_attend_end_date       = ' || TO_CHAR(v_time_attend_end_date, 'YYYY/MM/DD'));
--dbms_output.put_line ('');


    -- ????? ? ???? ???
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'NEW')) THEN

--dbms_output.put_line ('NEW Start');
        BEGIN
            FOR per IN (SELECT em.*,
                               TO_DATE(TO_CHAR(em.date_hire_subsidiary, 'YYYYMM') || '01', 'YYYYMMDD') AS date_hire_subsidiary_first,  -- ???/01?
                               LAST_DAY(em.date_hire_subsidiary)                                       AS date_hire_subsidiary_last,   -- ???/??
                               LAST_DAY(em.date_retire)                                                AS date_retire_last             -- ???/??
                        FROM   emp_master em
                        WHERE  subsidiary_code       = v_subsidiary_code
                        AND    date_hire_subsidiary >= v_asg_basic_date
                        AND    employee_number       = NVL(p_employee_no, employee_number)
                        AND    NVL(fse_yn,  'N')    <> 'Y'  -- FSE ??
                        AND    NVL(flsa_yn, 'N')    <> 'Y'  -- ???? ??
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('NEW: per.employee_number = ' || per.employee_number || ', per.date_hire_subsidiary = ' || TO_CHAR(per.date_hire_subsidiary, 'YYYY/MM/DD'));
                END IF;

                -- ??? ?? ?? ??
                DELETE tb_att_plan_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date       < per.date_hire_subsidiary_first                       -- ???/01 ??
                ;
                
                -- ??? ?? NN ?? ?? ??
                DELETE tb_att_plan_n
                WHERE  subsidiary_code           = per.subsidiary_code
                AND    employee_no               = per.employee_number
                AND    time_and_attendance_date  < per.date_hire_subsidiary  -- ??? ??
                AND    time_and_attendance_code <> 'NN'
                ;
                
                -- ??? ?? ?? ??
                DELETE tb_att_result_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date       < per.date_hire_subsidiary_first                       -- ???/01 ??
                ;
                
                -- ??? ?? NN ?? ?? ??
                DELETE tb_att_result_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date                 -- ???? ???? ???? ??
                AND    time_and_attendance_date       < per.date_hire_subsidiary  -- ??? ??
                AND    time_and_attendance_code      <> 'NN'
                ;
                
                -- ??? ?? ???? ??
                DELETE tb_att_annual_leave_n
                WHERE  subsidiary_code                  = per.subsidiary_code
                AND    employee_no                      = per.employee_number
                AND    time_and_attendance_yyyymm BETWEEN TO_CHAR(v_time_attend_start_date, 'YYYYMM') AND TO_CHAR(v_time_attend_end_date, 'YYYYMM')  -- ???? ???? ???? ??
                AND    time_and_attendance_yyyymm       < TO_CHAR(per.date_hire_subsidiary, 'YYYYMM')  -- ??? ??
                ;
                
                -- ????? ???? ?? : ??? ???, ????? ???? ???? ?????? ???
                INSERT INTO tb_att_plan_n
                    (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                       employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                       time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                       planning_id,                    progress_status_code,           approval_request_id,            
                       request_code,                   time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                       creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                    )
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    bb.shift_type_code,
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       bb.time_and_attendance_code,    bb.night_shift_flag,            bb.evening_meal_flag,           bb.overtime_hours,
                       NULL,                           NULL,                           NULL,
                       NULL,                           DECODE(bb.time_and_attendance_code, 'NW', 'NW_NRM', NULL),  -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                                                                                       NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   emp_assig         ea
                      ,tb_att_base_bas_n bb
                WHERE  ea.subsidiary_code                = per.subsidiary_code 
                AND    ea.employee_number                = per.employee_number
                AND    bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN ea.assignment_start_date AND TO_DATE(ea.attribute1, 'YYYYMMDD')  -- ????? ????
                AND    bb.time_and_attendance_date      >= per.date_hire_subsidiary                                         -- ???? ??
                AND    bb.shift_type_code                = NVL(ea.attribute10, '1A')                                        -- ????? ??????
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                UNION ALL
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    bb.shift_type_code,
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       'NN',                           'N',                            'N',                            0,   -- NN ??
                       NULL,                           NULL,                           NULL,
                       NULL,                           NULL,                           NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   tb_att_base_bas_n bb
                WHERE  bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN per.date_hire_subsidiary_first AND (per.date_hire_subsidiary-1)  -- ???/01 ~ ????-1?
                AND    bb.shift_type_code                = '1A'
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                UNION ALL
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    bb.shift_type_code,
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       'NN',                           'N',                            'N',                            0,   -- NN ??
                       NULL,                           NULL,                           NULL,
                       NULL,                           NULL,                           NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   tb_att_base_bas_n bb
                WHERE  bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN (per.date_retire+1)      AND per.date_retire_last                -- ????+1? ~ ???/??         --> ???? ????? ????? ???? ??
                AND    bb.shift_type_code                = '1A'
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;

                -- ????? ???? ?? : ??? ???, ????? ???? ???? ?????? ???
                INSERT INTO tb_att_result_n
                  ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                    time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                    work_hours,                     work_start_time,
                    night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                    weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                    weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                    tardy_hours,                    early_leave_hours,              going_out_hours,
                    special_bonus_hours,            helpcall_support_hours,
                    approval_request_id,            request_code,                   progress_status_code,
                    time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                    creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                  )
                SELECT 
                    ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                    ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,       
                    ab.work_hours,                  ab.attendance_time,
                    ap.night_shift_flag,            ap.evening_meal_flag,           0,  -- ap.overtime_sum_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
                    0,                              0,                              0,                              0,
                    0,                              0,                              0,                              0,
                    0,                              0,                              0,
                    0,                              0,
                    NULL,                           NULL,                           NULL,
                    ap.time_attend_detail_code,     NULL,                           'T',  -- 2018.01.30 ??? : OT ??? ??? ?? ??
                    v_user_id,                      SYSDATE,                          v_user_id,                      SYSDATE
                FROM   tb_att_plan_n     ap
                      ,tb_att_base_bas_n ab
                WHERE  ap.subsidiary_code                = per.subsidiary_code
                AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    ap.employee_no                    = per.employee_number
                AND    ap.subsidiary_code                = ab.subsidiary_code
                AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                AND    ap.shift_type_code                = ab.shift_type_code
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_result_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = ap.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;

                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('????? ???? ?? = ' || SQL%ROWCOUNT);
                END IF;

            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;


    -- ???
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'RETIRE')) THEN

--dbms_output.put_line ('RETIRE Start');
        BEGIN
            FOR per IN (SELECT em.*,
                               TO_CHAR(em.date_retire, 'YYYYMM') AS date_retire_yyyymm  -- ???
                        FROM   emp_master em
                        WHERE  subsidiary_code    = v_subsidiary_code
                        AND    date_retire        > v_asg_basic_date  -- ???? ??
                        AND    employee_number    = NVL(p_employee_no, employee_number)
                        AND    NVL(fse_yn,  'N') <> 'Y'  -- FSE ??
                        AND    NVL(flsa_yn, 'N') <> 'Y'  -- ???? ??
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('RETIRE: per.employee_number = ' || per.employee_number || ', per.date_retire = ' || TO_CHAR(per.date_retire, 'YYYY/MM/DD'));
                END IF;

                -- ??? ?? ?? ??
                DELETE tb_att_plan_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_yyyymm     > per.date_retire_yyyymm  -- ???
                AND    time_and_attendance_date       > per.date_retire+1   -- ??? ???+1 ? ??? ??? : HR Master ? ???? Outer ??? ???, ???? ??? ??
                ;

                -- ??? ?? ?? ??
                DELETE tb_att_result_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_yyyymm     > per.date_retire_yyyymm  -- ???
                ;

                -- ??? ?? ???? ??
                DELETE tb_att_annual_leave_n
                WHERE  subsidiary_code                  = per.subsidiary_code
                AND    employee_no                      = per.employee_number
                AND    time_and_attendance_yyyymm BETWEEN TO_CHAR(v_time_attend_start_date, 'YYYYMM') AND TO_CHAR(v_time_attend_end_date, 'YYYYMM')  -- ???? ???? ???? ??
                AND    time_and_attendance_yyyymm       > per.date_retire_yyyymm  -- ???
                ;

                -- ??? ?? ?? NN ??
                UPDATE tb_att_plan_n
                SET    time_and_attendance_code      = 'NN'
                      ,overtime_sum_hours            = 0
                      ,planning_id                   = NULL
                      ,progress_status_code          = NULL
                      ,approval_request_id           = NULL
                      ,request_code                  = NULL
                      ,time_attend_detail_code       = NULL
                      ,time_attend_input_reason_desc = NULL
                      ,base_time_attend_apply_flag   = 'Y'
                      ,last_update_user_id           = v_user_id
                      ,last_update_date              = SYSDATE
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date       > per.date_retire
                AND    time_and_attendance_code      <> 'NN'
                ;

                -- ??? ?? ?? NN ??
                UPDATE tb_att_result_n
                SET    time_and_attendance_code       = 'NN'
                      ,work_hours                     = 0 --TaiDD 20191114: add the work_hours = 0 for the resign employee, att_code = NN
                      ,evening_meal_flag              = 'N'
                      ,overtime_sum_hours             = 0
                      ,weekday_overtime_hours         = 0
                      ,holiday_overtime_hours         = 0
                      ,public_holiday_overtime_hours  = 0
                      ,weekday_night_overtime_hours   = 0
                      ,weekday_ot_af_night_work_hours = 0
                      ,holiday_night_overtime_hours   = 0
                      ,public_holiday_night_ot_hours  = 0
                      ,normal_night_overtime_hours    = 0
                      ,tardy_hours                    = 0
                      ,early_leave_hours              = 0
                      ,going_out_hours                = 0
                      ,special_bonus_hours            = 0
                      ,helpcall_support_hours         = 0
                      ,approval_request_id            = NULL
                      ,request_code                   = NULL
                      ,progress_status_code           = NULL
                      ,time_attend_detail_code        = NULL
                      ,time_attend_input_reason_desc  = NULL
                      ,base_time_attend_apply_flag    = 'Y'
                      ,last_update_user_id            = v_user_id
                      ,last_update_date               = SYSDATE
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date       > per.date_retire
                AND    time_and_attendance_code      <> 'NN'
                ;

            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;    


    -- ??? ????
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'SHIFT')) THEN

dbms_output.put_line ('SHIFT Start');
        BEGIN
            -- ?????? ??? ????? ?? ??
            FOR per IN (/*
                        SELECT subsidiary_code, employee_number
                        FROM   emp_assig ea
                        WHERE  subsidiary_code        = v_subsidiary_code
                        AND    employee_number        = NVL(p_employee_no, employee_number)
                        AND    assignment_start_date >= v_asg_basic_date  -- ?????? ??
                        AND    EXISTS (SELECT 'Y'
                                       FROM   emp_master
                                       WHERE  subsidiary_code    = ea.subsidiary_code
                                       AND    employee_number    = ea.employee_number
                                       AND    NVL(fse_yn,  'N') <> 'Y'  -- FSE ??
                                       AND    NVL(flsa_yn, 'N') <> 'Y'  -- ???? ??
                                      )
                        GROUP BY subsidiary_code, 
                                 employee_number
                        HAVING COUNT(DISTINCT NVL(attribute10, '1A')) > 1  -- ????? ??
                               OR
                               lgvhr_common_pkg.get_shift_type_code_func(subsidiary_code, employee_number, v_basic_date) != (SELECT shift_type_code    -- ?? ??? ??? ??? ??????? 1 ???? ??? ?? ???
                                                                                                                             FROM   tb_att_result_n 
                                                                                                                             WHERE  employee_no              = ea.employee_number 
                                                                                                                             AND    time_and_attendance_date = v_basic_date
                                                                                                                            )
                        */
                        SELECT ea.subsidiary_code, ea.employee_number
                        FROM   emp_assig ea,
                               tb_att_result_n ar
                        WHERE  1 = 1
                        AND    ea.assignment_start_date    >= v_asg_basic_date
                        AND    ea.employee_number           = NVL(p_employee_no, employee_number)
                        AND    ea.employee_number           = ar.employee_no
                        AND    ar.time_and_attendance_date >= v_time_attend_start_date
                        AND    ar.time_and_attendance_code <> 'NN'
                        AND    ar.time_and_attendance_date BETWEEN ea.assignment_start_date AND TO_DATE(ea.attribute1, 'YYYYMMDD')
                        AND    ar.shift_type_code          <> ea.attribute10
                        GROUP BY ea.subsidiary_code, ea.employee_number
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('SHIFT: per.employee_number = ' || per.employee_number);
                END IF;
            
                -- ???? ??? ??
                FOR asg IN (SELECT employee_number                 AS employee_number
                                  ,assignment_start_date           AS asg_start_date   -- ?????
                                  ,TO_DATE(attribute1, 'YYYYMMDD') AS asg_end_date     -- ?????
                                  ,NVL(attribute10, '1A')          AS shift_type_code
                            FROM   emp_assig
                            WHERE  subsidiary_code = per.subsidiary_code
                            AND    employee_number = per.employee_number
                            AND    (assignment_start_date           BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                    OR
                                    TO_DATE(attribute1, 'YYYYMMDD') BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                    OR
                                    (assignment_start_date < v_time_attend_start_date AND TO_DATE(attribute1, 'YYYYMMDD') > v_time_attend_end_date)  -- ???? ??? ??? ????
                                   )
                            ORDER BY employee_number, assignment_start_date
                           )
                LOOP
                    IF (p_employee_no IS NOT NULL) THEN
                        dbms_output.put_line ('asg.asg_start_date = ' || TO_CHAR(asg.asg_start_date, 'YYYY/MM/DD') || ', asg.asg_end_date = ' || TO_CHAR(asg.asg_end_date, 'YYYY/MM/DD') || ', asg.shift_type_code = ' || asg.shift_type_code);
                    END IF;

                    -- ?????? ??????? ??? ?? ??
                    FOR att IN (SELECT *
                                FROM   tb_att_plan_n
                                WHERE  subsidiary_code                = per.subsidiary_code
                                AND    employee_no                    = per.employee_number
                                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                AND    time_and_attendance_date BETWEEN asg.asg_start_date       AND asg.asg_end_date        -- ????
                                AND    shift_type_code               != asg.shift_type_code                                  -- ??? ??
                               )
                    LOOP
                        IF (p_employee_no IS NOT NULL) THEN
                            dbms_output.put_line ('time_and_attendance_date = ' || TO_CHAR(att.time_and_attendance_date, 'YYYY/MM/DD') || ', att.shift_type_code = ' || att.shift_type_code || ', asg.shift_type_code = ' || asg.shift_type_code);
                        END IF;

                        -- ?? / ??? ???? ????
                        abb_rec := lgvatt_common_pkg.get_att_base_bas_rec(per.subsidiary_code, att.time_and_attendance_date, asg.shift_type_code);

                        
                        -- ??? ???? ????
                        ap_rec  := att;
                        
                        -- ????? ???? ????
                        --IF (NVL(ap_rec.base_time_attend_apply_flag, 'Y') = 'Y') THEN              HMT_20220301
                          IF lgvatt_common_pkg.get_att_date_type('LGDVN',ap_rec.employee_no, ap_rec.time_and_attendance_date,'ATTENDANCE_CODE_SWAP') IS NULL THEN --HMT_20220301 Add
                            ap_rec.shift_type_code          := abb_rec.shift_type_code;
                            ap_rec.time_and_attendance_code := abb_rec.time_and_attendance_code;
                            ap_rec.time_attend_detail_code  := CASE WHEN abb_rec.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END;  -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                            ap_rec.night_shift_flag         := abb_rec.night_shift_flag;
                            ap_rec.evening_meal_flag        := abb_rec.evening_meal_flag;
                            ap_rec.overtime_sum_hours       := abb_rec.overtime_hours;
                            ap_rec.last_update_user_id      := v_user_id;
                            ap_rec.last_update_date         := SYSDATE;
                        ELSE
                            --ap_rec.shift_type_code          := asg.shift_type_code;   HMT_20220301 
                            --ap_rec.night_shift_flag         := abb_rec.night_shift_flag;  HMT_20220301
                            ap_rec.last_update_user_id      := v_user_id;
                            ap_rec.last_update_date         := SYSDATE;
                        END IF;
                        
                        -- ???? ??
                        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_plan_record (ap_rec, 'UPDATE');
                        

                        -- ??? ???? ????
                        ar_rec  := lgvatt_common_pkg.get_att_result_rec(per.subsidiary_code, per.employee_number, att.time_and_attendance_date);

                        -- ????? ???? ????
                        --IF (NVL(ar_rec.base_time_attend_apply_flag, 'Y') = 'Y') THEN         HMT_20220301
                        IF lgvatt_common_pkg.get_att_date_type('LGDVN',ar_rec.employee_no, ar_rec.time_and_attendance_date,'ATTENDANCE_CODE_SWAP') IS NULL THEN --HMT_20220301 Add
                            ar_rec.shift_type_code          := abb_rec.shift_type_code;
                            ar_rec.time_and_attendance_code := abb_rec.time_and_attendance_code;
                            ar_rec.time_attend_detail_code  := CASE WHEN abb_rec.time_and_attendance_code = 'NW' THEN 'NW_NRM' ELSE NULL END;  -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                            ar_rec.work_hours               := abb_rec.work_hours;
                            ar_rec.work_start_time          := abb_rec.attendance_time;
                            ar_rec.night_shift_flag         := abb_rec.night_shift_flag;
                            ar_rec.evening_meal_flag        := abb_rec.evening_meal_flag;
                            ar_rec.overtime_sum_hours       := 0;  -- abb.overtime_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
                            ar_rec.last_update_user_id      := v_user_id;
                            ar_rec.last_update_date         := SYSDATE;
                        ELSE
                            --ar_rec.shift_type_code          := abb_rec.shift_type_code;   HMT_20220301
                            --ar_rec.work_hours               := abb_rec.work_hours;          HMT_20220301
                            --ar_rec.night_shift_flag         := abb_rec.night_shift_flag;      HMT_20220301
                            ar_rec.last_update_user_id      := v_user_id;
                            ar_rec.last_update_date         := SYSDATE;
                        END IF;

                        -- OT ???
                        lgvatt_ot_calculation_pkg.calculate_ot (p_subsidiary_code    => per.subsidiary_code
                                                               ,p_employee_no        => ar_rec.employee_no --HMT_20210717
                                                               ,p_date               => att.time_and_attendance_date
                                                               ,p_att_code           => ar_rec.time_and_attendance_code
                                                               ,p_shift_code         => ar_rec.shift_type_code
                                                               ,p_night_flag         => ar_rec.night_shift_flag
                                                               ,p_dinner_check       => ar_rec.evening_meal_flag
                                                               ,p_working_start_time => ar_rec.work_start_time
                                                               ,p_ot                 => ar_rec.overtime_sum_hours
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

                        -- ???? ??
                        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_record (ar_rec, 'UPDATE');

                    END LOOP;

                END LOOP;
            
            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;


    -- ????
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'SUSP')) THEN

dbms_output.put_line ('SUSP Start');
        BEGIN
            -- ?????? ??? ???
            FOR per IN (SELECT em.*, NVL(em.date_retire, v_time_attend_end_date) AS date_retire_last
                        FROM   emp_master em
                        WHERE  subsidiary_code    = v_subsidiary_code
                        AND    (date_retire IS NULL OR date_retire > v_asg_basic_date)  -- ???? ??
                        AND    employee_number    = NVL(p_employee_no, employee_number)
                        AND    NVL(fse_yn,  'N') <> 'Y'  -- FSE ??
                        AND    NVL(flsa_yn, 'N') <> 'Y'  -- ???? ??
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('????: per.employee_number = ' || per.employee_number);
                END IF;

                FOR asg IN (SELECT employee_number
                                  ,assignment_start_date           AS assignment_start_date
                                  ,TO_DATE(attribute1, 'YYYYMMDD') AS assignment_end_date
                                  ,assignment_type_1st             AS assignment_type_1st
                                  ,DECODE(assignment_type_2nd, NULL, lgvatt_common_pkg.get_last_assignment_type_2nd (subsidiary_code, employee_number, assignment_start_date, assignment_type_1st, 'TYPE'  ), assignment_type_2nd) AS assignment_type_2nd  -- 2018.02.05 ??? : 2?????
                                  ,DECODE(assignment_type_2nd, NULL, lgvatt_common_pkg.get_last_assignment_type_2nd (subsidiary_code, employee_number, assignment_start_date, assignment_type_1st, 'REASON'), attribute13        ) AS assignment_type_2nd_reason  -- 2018.02.05 ??? : 2???????
                                  ,NVL(attribute10, '1A')          AS shift_type_code        -- ???? ??????
                            FROM   emp_assig t
                            WHERE  subsidiary_code  = per.subsidiary_code
                            AND    employee_number  = per.employee_number
                            AND    (assignment_start_date           BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                    OR
                                    TO_DATE(attribute1, 'YYYYMMDD') BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                    OR
                                    (assignment_start_date < v_time_attend_start_date AND TO_DATE(attribute1, 'YYYYMMDD') > v_time_attend_end_date)  -- ???? ???? ???? ??
                                   )
                            ORDER BY assignment_start_date
                           )
                LOOP
                    v_asg_start_date := GREATEST(asg.assignment_start_date, v_time_attend_start_date);
                    v_asg_end_date   := GREATEST(LEAST(asg.assignment_end_date, v_time_attend_end_date), v_time_attend_start_date);

                    -- ????
                    IF (asg.assignment_type_1st = 'Active Assignment') THEN
                    
                        -- ?????? ?? ???? ??
                        DELETE tb_att_plan_n
                        WHERE  subsidiary_code                = per.subsidiary_code
                        AND    employee_no                    = per.employee_number
                        AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                        AND    time_and_attendance_date BETWEEN v_asg_start_date AND v_asg_end_date                  -- ????
                        AND    time_and_attendance_code      IN ( 'PS', 'US' )                                       -- ??/?? ??
                        AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                        ;
                        
                        -- ?????? ?? ???? ??
                        DELETE tb_att_result_n
                        WHERE  subsidiary_code                = per.subsidiary_code
                        AND    employee_no                    = per.employee_number
                        AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                        AND    time_and_attendance_date BETWEEN v_asg_start_date AND v_asg_end_date                  -- ????
                        AND    time_and_attendance_code      IN ( 'PS', 'US' )                                       -- ??/?? ??
                        AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                        ;

                        -- ????? ???? ??
                        INSERT INTO tb_att_plan_n
                            (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                               employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                               time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                               planning_id,                    progress_status_code,           approval_request_id,            request_code,                   
                               time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                               creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                            )
                        SELECT subsidiary_code,                time_and_attendance_date,       NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'SHIFT_CODE_SWAP'),shift_type_code), --HMT_20220301
                               per.employee_number,            time_and_attendance_yyyymm,     a_day_of_the_week_code,                   
                               NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),time_and_attendance_code),      --HMT_20220301
                                night_shift_flag,               NULL,                           overtime_hours,
                               NULL,                           NULL,                           NULL,                           NULL,                           
                               DECODE(time_and_attendance_code, 'NW', 'NW_NRM', NULL),      -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                                                               NULL,                           'Y',
                               v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                        FROM   tb_att_base_bas_n bb
                        WHERE  subsidiary_code                = per.subsidiary_code 
                        AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                        AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                        AND    shift_type_code                = asg.shift_type_code                                  -- ???? ??????
                        AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                        AND    NOT EXISTS (SELECT 'Y'
                                           FROM   tb_att_plan_n  -- ??? ?? ?????
                                           WHERE  subsidiary_code          = per.subsidiary_code
                                           AND    employee_no              = per.employee_number
                                           AND    time_and_attendance_date = bb.time_and_attendance_date
                                          )
                        ;
                        
                        -- ????? ???? ??
                        INSERT INTO tb_att_result_n
                          ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                            time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                            work_hours,                     work_start_time,
                            night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                            weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                            weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                            tardy_hours,                    early_leave_hours,              going_out_hours,
                            special_bonus_hours,            helpcall_support_hours,
                            approval_request_id,            request_code,                   progress_status_code,
                            time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                            creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                          )
                        SELECT 
                            ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                            ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,       
                            ab.work_hours,                  ab.attendance_time,   
                            ap.night_shift_flag,            ap.evening_meal_flag,           0,  -- ap.overtime_sum_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
                            NULL,                           NULL,                           NULL,                           NULL,
                            NULL,                           NULL,                           NULL,                           NULL,
                            NULL,                           NULL,                           NULL,
                            NULL,                           NULL,
                            NULL,                           NULL,                           NULL,
                            ap.time_attend_detail_code,     NULL,                           'T',  -- 2018.01.30 ??? : OT ??? ??? ?? ??
                            v_user_id,                      SYSDATE,                          v_user_id,                      SYSDATE
                        FROM   tb_att_plan_n     ap
                              ,tb_att_base_bas_n ab
                        WHERE  ap.subsidiary_code                = per.subsidiary_code
                        AND    ap.employee_no                    = per.employee_number
                        AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                        AND    ap.time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                        AND    ap.subsidiary_code                = ab.subsidiary_code           
                        AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                        AND    ap.shift_type_code                = ab.shift_type_code
                        AND    ap.time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                        AND    NOT EXISTS (SELECT 'Y'
                                           FROM   tb_att_result_n  -- ??? ?? ?????
                                           WHERE  subsidiary_code          = per.subsidiary_code
                                           AND    employee_no              = per.employee_number
                                           AND    time_and_attendance_date = ap.time_and_attendance_date
                                          )
                        ;

                    -- ????
                    ELSIF (asg.assignment_type_1st = 'Suspend Assignment') THEN

                        -- ??????                
                        IF (NVL(asg.assignment_type_2nd, 'Leave_Unpaid') = 'Leave_Paid') THEN

                            -- ?????? ???? ??
                            DELETE tb_att_plan_n
                            WHERE  subsidiary_code                = per.subsidiary_code
                            AND    employee_no                    = per.employee_number
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                            
                            -- ?????? ???? ??
                            DELETE tb_att_result_n
                            WHERE  subsidiary_code                = per.subsidiary_code
                            AND    employee_no                    = per.employee_number
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                        
                            -- ??????? ???? ??
                            INSERT INTO tb_att_plan_n
                                (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                                   employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                                   time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                                   planning_id,                    progress_status_code,           approval_request_id,            request_code,                   
                                   time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                                   creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                                )
                            SELECT subsidiary_code,                time_and_attendance_date,       NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'SHIFT_CODE_SWAP'),shift_type_code), --HMT_20220301
                                   per.employee_number,            time_and_attendance_yyyymm,     a_day_of_the_week_code,                   
                                   DECODE(NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),bb.time_and_attendance_code), 'WH', 'WH', 'PS'),  -- 2018.02.07 ??? : ??????, WH ? WH ?, ??? PS(????) ?? ??   --HMT_20220301
                                                                   night_shift_flag,               'N',                            0,
                                   NULL,                           NULL,                           NULL,                           NULL,
                                   NULL,                           NULL,                           'Y',
                                   v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                            FROM   tb_att_base_bas_n bb
                            WHERE  subsidiary_code                = per.subsidiary_code 
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    shift_type_code                = asg.shift_type_code                                  -- ???? ??????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                            
                            -- ????? ???? ??
                            INSERT INTO tb_att_result_n
                              ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                                time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                                work_hours,                     work_start_time,
                                night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                                weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                                weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                                tardy_hours,                    early_leave_hours,              going_out_hours,
                                special_bonus_hours,            helpcall_support_hours,
                                approval_request_id,            request_code,                   progress_status_code,
                                time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                                creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                              )
                            SELECT 
                                ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                                ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,    -- 2018.02.07 ??? : ??? ??? ???? ?? ???
                                0,                              ab.attendance_time,
                                ap.night_shift_flag,            ap.evening_meal_flag,           0,
                                0,                              0,                              0,                              0,   
                                0,                              0,                              0,                              0,   
                                0,                              0,                              0,
                                0,                              0,
                                NULL,                           NULL,                           NULL,
                                ap.time_attend_detail_code,     NULL,                           'Y',  -- ??? OT ?? 0 ??? ????? ??
                                v_user_id,                      SYSDATE,                          v_user_id,                      SYSDATE
                            FROM   tb_att_plan_n     ap
                                  ,tb_att_base_bas_n ab
                            WHERE  ap.subsidiary_code                = per.subsidiary_code
                            AND    ap.employee_no                    = per.employee_number
                            AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    ap.time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    ap.subsidiary_code                = ab.subsidiary_code
                            AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                            AND    ap.shift_type_code                = ab.shift_type_code
                            AND    ap.time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                        
                        -- ??????
                        ELSIF (NVL(asg.assignment_type_2nd, 'Leave_Unpaid') = 'Leave_Unpaid') THEN
                        
                            -- ?????? ???? ??
                            DELETE tb_att_plan_n
                            WHERE  subsidiary_code                = per.subsidiary_code
                            AND    employee_no                    = per.employee_number
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                            
                            -- ?????? ???? ??
                            DELETE tb_att_result_n
                            WHERE  subsidiary_code                = per.subsidiary_code
                            AND    employee_no                    = per.employee_number
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                            
                            -- US ?? 2?????? ??, ??????
                            v_asg_2nd_reason_code := NVL(lgvhr_common_pkg.decode_lookup('IF_ASSIGN_REASON', asg.assignment_type_2nd_reason, 'A2'), 'US_NRM');
                            
                            -- ??????? ???? ??
                            INSERT INTO tb_att_plan_n
                                (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                                   employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                                   time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                                   planning_id,                    progress_status_code,           approval_request_id,            
                                   request_code,                   time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                                   creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                                )
                            SELECT subsidiary_code,                time_and_attendance_date,       NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'SHIFT_CODE_SWAP'),shift_type_code), --HMT_20220301
                                   per.employee_number,            time_and_attendance_yyyymm,     a_day_of_the_week_code,                   
                                   DECODE(NVL(lgvatt_common_pkg.get_att_date_type(subsidiary_code,per.employee_number, time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),time_and_attendance_code), 'WH', 'WH', 'US'),  -- 2018.02.07 ??? : ??????, WH ? WH ?, ??? US(????) ?? ??  HMT_20220301
                                                                   night_shift_flag,               'N',                            0,
                                   NULL,                           NULL,                           NULL,
                                   NULL,                           DECODE(time_and_attendance_code, 'WH', NULL, v_asg_2nd_reason_code),  -- 2018.02.05 ??? : US ?? 2?????? ???? ??????
                                                                                                   NULL,                           'Y',
                                   v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                            FROM   tb_att_base_bas_n
                            WHERE  subsidiary_code                = per.subsidiary_code 
                            AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    shift_type_code                = asg.shift_type_code                                  -- ???? ??????
                            AND    time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;
                            
                            -- ????? ???? ??
                            INSERT INTO tb_att_result_n
                              ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                                time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                                work_hours,                     work_start_time,
                                night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                                weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                                weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                                tardy_hours,                    early_leave_hours,              going_out_hours,
                                special_bonus_hours,            helpcall_support_hours,
                                approval_request_id,            request_code,                   progress_status_code,
                                time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                                creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                              )
                            SELECT 
                                ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                                ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,    -- 2018.02.07 ??? : ??? ??? ???? ?? ???
                                0,                              ab.attendance_time,
                                ap.night_shift_flag,            ap.evening_meal_flag,           0,
                                0,                              0,                              0,                              0,   
                                0,                              0,                              0,                              0,   
                                0,                              0,                              0,
                                0,                              0,
                                NULL,                           NULL,                           NULL,
                                ap.time_attend_detail_code,     NULL,                           'Y',  -- ??? OT ?? 0 ??? ????? ??
                                v_user_id,                      SYSDATE,                          v_user_id,                      SYSDATE
                            FROM   tb_att_plan_n     ap
                                  ,tb_att_base_bas_n ab
                            WHERE  ap.subsidiary_code                = per.subsidiary_code
                            AND    ap.employee_no                    = per.employee_number
                            AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                            AND    ap.time_and_attendance_date BETWEEN v_asg_start_date         AND v_asg_end_date          -- ????
                            AND    ap.subsidiary_code                = ab.subsidiary_code
                            AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                            AND    ap.shift_type_code                = ab.shift_type_code
                            AND    ap.time_and_attendance_date      <= per.date_retire_last                                 -- ???????
                            ;

                        END IF;
                    END IF;
                    
                END LOOP;

            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;
    

    -- ???? : ??? ? ??? ?? NN ??? ???, ????? ?? ??, ???? ??
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'CANCEL')) THEN

dbms_output.put_line ('CANCEL Start');
        BEGIN
            FOR per IN (SELECT *
                        FROM   emp_master em
                        WHERE  subsidiary_code    = v_subsidiary_code
                        AND    date_retire       IS NULL  -- ???? ??
                        AND    employee_number    = NVL(p_employee_no, employee_number)
                        AND    NVL(fse_yn,  'N') <> 'Y'  -- FSE ??
                        AND    NVL(flsa_yn, 'N') <> 'Y'  -- ???? ??
                        AND    EXISTS (SELECT 'Y'
                                       FROM   tb_att_result_n
                                       WHERE  subsidiary_code                = em.subsidiary_code
                                       AND    employee_no                    = em.employee_number
                                       AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                       AND    time_and_attendance_date      >= GREATEST(v_asg_basic_date, em.date_hire_subsidiary)  -- ?????? ??
                                       AND    time_and_attendance_code       = 'NN'  -- NN ??? ???
                                      )
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('????: per.employee_number = ' || per.employee_number);
                END IF;
            
                -- ?? NN ?? ??
                DELETE tb_att_plan_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_code       = 'NN'  -- NN ??
                ;

                -- ?? NN ?? ??
                DELETE tb_att_result_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_code       = 'NN'  -- NN ??
                ;

                -- ????? ???? ??
                INSERT INTO tb_att_plan_n
                    (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                       employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                       time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                       planning_id,                    progress_status_code,           approval_request_id,            request_code,                   
                       time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                       creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                    )
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    NVL(lgvatt_common_pkg.get_att_date_type(bb.subsidiary_code,per.employee_number, bb.time_and_attendance_date,'SHIFT_CODE_SWAP'),bb.shift_type_code), --HMT_20220301
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       NVL(lgvatt_common_pkg.get_att_date_type(bb.subsidiary_code,per.employee_number, bb.time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),bb.time_and_attendance_code),      --HMT_20220301    
                       bb.night_shift_flag,            bb.evening_meal_flag,           bb.overtime_hours,
                       NULL,                           NULL,                           NULL,                           NULL,
                       DECODE(bb.time_and_attendance_code, 'NW', 'NW_NRM', NULL),      -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                                                       NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   emp_assig         ea
                      ,tb_att_base_bas_n bb
                WHERE  ea.subsidiary_code                = per.subsidiary_code 
                AND    ea.employee_number                = per.employee_number
                AND    bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN ea.assignment_start_date AND TO_DATE(ea.attribute1, 'YYYYMMDD')  -- ????? ????
                AND    bb.shift_type_code                = NVL(ea.attribute10, '1A')                                        -- ???? ??????
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;
                
                -- ????? ???? ??
                INSERT INTO tb_att_result_n
                  ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                    time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                    work_hours,                     work_start_time,
                    night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                    weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                    weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                    tardy_hours,                    early_leave_hours,              going_out_hours,
                    special_bonus_hours,            helpcall_support_hours,
                    approval_request_id,            request_code,                   progress_status_code,
                    time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                    creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                  )
                SELECT 
                    ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                    ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,       
                    ab.work_hours,                  ab.attendance_time,
                    ap.night_shift_flag,            ap.evening_meal_flag,           0,  -- ap.overtime_sum_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
                    NULL,                           NULL,                           NULL,                           NULL,
                    NULL,                           NULL,                           NULL,                           NULL,
                    NULL,                           NULL,                           NULL,
                    NULL,                           NULL,
                    NULL,                           NULL,                           NULL,
                    ap.time_attend_detail_code,     NULL,                           'T',  -- 2018.01.30 ??? : OT ??? ??? ?? ??
                    v_user_id,                      SYSDATE,                          v_user_id,                      SYSDATE
                FROM   tb_att_plan_n     ap
                      ,tb_att_base_bas_n ab
                WHERE  ap.subsidiary_code                = per.subsidiary_code
                AND    ap.employee_no                    = per.employee_number
                AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    ap.subsidiary_code                = ab.subsidiary_code
                AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                AND    ap.shift_type_code                = ab.shift_type_code
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_result_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = ap.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;
                
            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;
    

    -- 2018.02.05 ??? : ????? ?????
    IF (NVL(p_att_type, 'ALL') IN ( 'ALL', 'RETIRE_CHG')) THEN

dbms_output.put_line ('RETIRE_CHG Start');
        BEGIN
            -- ????(????? ???? ??? ??) : ??? ? ??? ~ ???? ???  NN ??? ?? ??, ???? ??
            FOR per IN (SELECT *
                        FROM   emp_master em
                        WHERE  subsidiary_code    = v_subsidiary_code
                        AND    date_retire       >= v_asg_basic_date  -- ?????? ?? ??????
                        AND    employee_number    = NVL(p_employee_no, employee_number)
                        AND    NVL(fse_yn,  'N') <> 'Y'  -- FSE ??
                        AND    NVL(flsa_yn, 'N') <> 'Y'  -- ???? ??
                        AND    EXISTS (SELECT 'Y'
                                       FROM   tb_att_result_n
                                       WHERE  subsidiary_code                = em.subsidiary_code
                                       AND    employee_no                    = em.employee_number
                                       AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                                       AND    time_and_attendance_date BETWEEN em.date_hire_subsidiary  AND em.date_retire          -- ???? ~ ???? ???
                                       AND    time_and_attendance_code       = 'NN'  -- NN ??? ???
                                      )
                       )
            LOOP
                IF (p_employee_no IS NOT NULL) THEN
                    dbms_output.put_line ('????(??): per.employee_number = ' || per.employee_number);
                END IF;

                -- ??? ????~???? ? NN?? ??
                DELETE tb_att_plan_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date BETWEEN per.date_hire_subsidiary AND per.date_retire         -- ???? ~ ????
                AND    time_and_attendance_code       = 'NN'
                ;
            
                -- ??? ????~???? ? NN?? ??
                DELETE tb_att_result_n
                WHERE  subsidiary_code                = per.subsidiary_code
                AND    employee_no                    = per.employee_number
                AND    time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    time_and_attendance_date BETWEEN per.date_hire_subsidiary AND per.date_retire         -- ???? ~ ????
                AND    time_and_attendance_code       = 'NN'
                ;

                -- ????? ???? ??
                INSERT INTO tb_att_plan_n
                    (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                       employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                       time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                       planning_id,                    progress_status_code,           approval_request_id,            
                       request_code,                   time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                       creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                    )
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    NVL(lgvatt_common_pkg.get_att_date_type(bb.subsidiary_code,per.employee_number, bb.time_and_attendance_date,'SHIFT_CODE_SWAP'),bb.shift_type_code), --HMT_20220301
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       NVL(lgvatt_common_pkg.get_att_date_type(bb.subsidiary_code,per.employee_number, bb.time_and_attendance_date,'ATTENDANCE_CODE_SWAP'),bb.time_and_attendance_code),      --HMT_20220301
                       bb.night_shift_flag,            bb.evening_meal_flag,           bb.overtime_hours,
                       NULL,                           NULL,                           NULL,
                       NULL,                           DECODE(bb.time_and_attendance_code, 'NW', 'NW_NRM', NULL),  -- ?????? : 2018.01.23 ??? : ???? = NW ??, ???? = NW_NRM
                                                                                       NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   emp_assig         ea
                      ,tb_att_base_bas_n bb
                WHERE  ea.subsidiary_code                = per.subsidiary_code 
                AND    ea.employee_number                = per.employee_number
                AND    bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN ea.assignment_start_date AND TO_DATE(ea.attribute1, 'YYYYMMDD')  -- ????? ????
                AND    bb.time_and_attendance_date BETWEEN per.date_hire_subsidiary AND per.date_retire                     -- ???? ~ ????
                AND    bb.shift_type_code                = NVL(ea.attribute10, '1A')                                        -- ???? ??????
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    employee_no              = per.employee_number
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                  )
                ;

                -- ????? ???? ??
                INSERT INTO tb_att_result_n
                  ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                    time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                    work_hours,                     work_start_time,
                    night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                    weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                    weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                    tardy_hours,                    early_leave_hours,              going_out_hours,
                    special_bonus_hours,            helpcall_support_hours,
                    approval_request_id,            request_code,                   progress_status_code,
                    time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                    creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                  )
                SELECT 
                    ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                    ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      ap.time_and_attendance_code,       
                    ab.work_hours,                  ab.attendance_time,
                    ap.night_shift_flag,            ap.evening_meal_flag,           0,  -- ap.overtime_sum_hours, -- 2017.12.21 ??? : ??? ?? OT ? 0 ? ???? ?
                    NULL,                           NULL,                           NULL,                           NULL,
                    NULL,                           NULL,                           NULL,                           NULL,
                    0,                              0,                              0,
                    0,                              0,
                    NULL,                           NULL,                           NULL,
                    ap.time_attend_detail_code,     NULL,                           'T',
                    v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   tb_att_plan_n     ap
                      ,tb_att_base_bas_n ab
                WHERE  ap.subsidiary_code                = per.subsidiary_code
                AND    ap.employee_no                    = per.employee_number
                AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date  -- ???? ???? ???? ??
                AND    ap.time_and_attendance_date BETWEEN per.date_hire_subsidiary AND per.date_retire         -- ???? ~ ????
                AND    ap.subsidiary_code                = ab.subsidiary_code
                AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                AND    ap.shift_type_code                = ab.shift_type_code
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_result_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    employee_no              = per.employee_number
                                   AND    time_and_attendance_date = ap.time_and_attendance_date
                                  )
                ;


                -- 2018.05.08 ??? : ????? ???? ???? ???, ??? ???? NN ??? ?? ???
                -- ??? ?? ????? ???? ??
                INSERT INTO tb_att_plan_n
                    (  subsidiary_code,                time_and_attendance_date,       shift_type_code,
                       employee_no,                    time_and_attendance_yyyymm,     a_day_of_the_week_code,                         
                       time_and_attendance_code,       night_shift_flag,               evening_meal_flag,              overtime_sum_hours, 
                       planning_id,                    progress_status_code,           approval_request_id,            request_code,                   
                       time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                       creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                    )
                SELECT bb.subsidiary_code,             bb.time_and_attendance_date,    bb.shift_type_code,
                       per.employee_number,            bb.time_and_attendance_yyyymm,  bb.a_day_of_the_week_code,                   
                       'NN',                           bb.night_shift_flag,            'N',                            0,
                       NULL,                           NULL,                           NULL,                           NULL,
                       NULL,                           NULL,                           'Y',
                       v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   tb_att_base_bas_n bb
                WHERE  bb.subsidiary_code                = per.subsidiary_code 
                AND    bb.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    bb.time_and_attendance_date BETWEEN per.date_retire+1        AND LAST_DAY(per.date_retire)           -- ????? ????
                AND    bb.shift_type_code                = NVL(per.attribute10, '1A')                                       -- ???? ??????
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_plan_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = bb.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;
                
                -- ????? ???? ??
                INSERT INTO tb_att_result_n
                  ( subsidiary_code,                time_and_attendance_date,       shift_type_code,                employee_no,
                    time_and_attendance_yyyymm,     a_day_of_the_week_code,         time_and_attendance_code,
                    work_hours,                     work_start_time,
                    night_shift_flag,               evening_meal_flag,              overtime_sum_hours,
                    weekday_overtime_hours,         holiday_overtime_hours,         public_holiday_overtime_hours,  weekday_night_overtime_hours,
                    weekday_ot_af_night_work_hours, holiday_night_overtime_hours,   public_holiday_night_ot_hours,  normal_night_overtime_hours,
                    tardy_hours,                    early_leave_hours,              going_out_hours,
                    special_bonus_hours,            helpcall_support_hours,
                    approval_request_id,            request_code,                   progress_status_code,
                    time_attend_detail_code,        time_attend_input_reason_desc,  base_time_attend_apply_flag,
                    creation_user_id,               creation_date,                  last_update_user_id,            last_update_date
                  )
                SELECT 
                    ap.subsidiary_code,             ap.time_and_attendance_date,    ap.shift_type_code,             per.employee_number,
                    ap.time_and_attendance_yyyymm,  ap.a_day_of_the_week_code,      'NN',
                    --ab.work_hours,                  ab.attendance_time,
                    0,                  ab.attendance_time,                                                                 --TaiDD 20200702: when the Attendance Code = NN, the work hours should be '0', not get from tb_att_base_bas_n
                    ap.night_shift_flag,            'N',                            0,
                    0,                              0,                              0,                              0,
                    0,                              0,                              0,                              0,
                    0,                              0,                              0,
                    0,                              0,
                    NULL,                           NULL,                           NULL,
                    NUlL,                           NULL,                           'Y',
                    v_user_id,                      SYSDATE,                        v_user_id,                      SYSDATE
                FROM   tb_att_plan_n     ap
                      ,tb_att_base_bas_n ab
                WHERE  ap.subsidiary_code                = per.subsidiary_code
                AND    ap.employee_no                    = per.employee_number
                AND    ap.time_and_attendance_date BETWEEN v_time_attend_start_date AND v_time_attend_end_date              -- ???? ???? ???? ??
                AND    ap.time_and_attendance_date BETWEEN per.date_retire+1        AND LAST_DAY(per.date_retire)           -- ????? ????
                AND    ap.subsidiary_code                = ab.subsidiary_code
                AND    ap.time_and_attendance_date       = ab.time_and_attendance_date
                AND    ap.shift_type_code                = ab.shift_type_code
                AND    NOT EXISTS (SELECT 'Y'
                                   FROM   tb_att_result_n  -- ??? ?? ?????
                                   WHERE  subsidiary_code          = per.subsidiary_code
                                   AND    time_and_attendance_date = ap.time_and_attendance_date
                                   AND    employee_no              = per.employee_number
                                  )
                ;

            END LOOP;
            
            COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
        END;

    END IF;


    BEGIN
        -- OT ?? ??
        lgvatt_transaction_pkg.apply_att_result_ot_calc (p_ret_code                    => p_ret_code
                                                        ,p_ret_msg                     => p_ret_msg
                                                        ,p_user_id                     => v_user_id
                                                        ,p_subsidiary_code             => v_subsidiary_code
                                                        ,p_base_time_attend_apply_flag => 'Y'
                                                        ,p_employee_no                 => p_employee_no
                                                        );
        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
    END;


    BEGIN
        -- ????
        SELECT LEAST(NVL(TO_CHAR(ADD_MONTHS(TO_DATE(MAX(time_and_attendance_yyyymm), 'YYYYMM'), 1), 'YYYYMM'), TO_CHAR(SYSDATE, 'YYYYMM'))
                    ,TO_CHAR(ADD_MONTHS(SYSDATE, g_future_creation_months), 'YYYYMM'))  -- ?? ??????
        INTO   v_time_and_attendance_yyyymm
        FROM   tb_att_close_n
        WHERE  subsidiary_code = v_subsidiary_code
        ;

        -- ???? ?? ??? ??(?????/????/?????)
        FOR em IN (
                   SELECT *
                   FROM   emp_master            em
                   WHERE  date_hire_subsidiary <= LAST_DAY(v_basic_date)  -- ??
                   AND    employee_number       = NVL(p_employee_no, employee_number)
                   AND    (date_retire         IS NULL
                           OR
                           date_retire         >= TO_DATE(TO_CHAR(v_basic_date, 'YYYYMM'), 'YYYYMM')  -- 1?
                          )
                   AND    fse_yn                = 'N'
                   AND    flsa_yn               = 'N'
                   AND    NOT EXISTS (SELECT 'Y'
                                      FROM   tb_att_annual_leave_n
                                      WHERE  subsidiary_code            = em.subsidiary_code
                                      AND    employee_no                = em.employee_number 
                                      AND    time_and_attendance_yyyymm = TO_CHAR(v_basic_date, 'YYYYMM')  -- ??? ???? ??
                                     )
                  )
        LOOP
            -- ?? ????
            pre_anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec (v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, -1), 'YYYYMM'));
            v_residual_annual_leave_days := NVL(pre_anl_rec.residual_annual_leave_days, 0);

            FOR mm IN 0..MONTHS_BETWEEN(TO_DATE(v_time_and_attendance_yyyymm, 'YYYYMM'), TO_DATE(TO_CHAR(v_basic_date, 'YYYYMM'), 'YYYYMM'))  -- ??????
            LOOP

                -- ?? ????        
                anl_rec := lgvatt_common_pkg.get_att_annual_leave_rec (v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM'));
                
                anl_rec.subsidiary_code               := v_subsidiary_code;
                anl_rec.employee_no                   := em.employee_number;
                anl_rec.time_and_attendance_yyyymm    := TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM');
                anl_rec.hire_date                     := em.date_hire_subsidiary;
                anl_rec.occur_basic_annual_leave_days := NVL(anl_rec.occur_basic_annual_leave_days, 0);
                anl_rec.occur_monthly_ann_lv_days     := NVL(anl_rec.occur_monthly_ann_lv_days    , 0);
                /* 2018/02/28  SSY : ?? ?? ??? ?? HL ??? ????? ??? => 2018.04.03 ??? : HL ? ??????? 2? ??? ?? */
                anl_rec.use_annual_leave_days         := NVL(anl_rec.use_annual_leave_days        
                                                             , lgvatt_common_pkg.get_att_result_code_use_days(v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM'), NULL, 'AL')
                                                             + (lgvatt_common_pkg.get_att_result_code_use_days(v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM'), NULL, 'HL') / 2)
                                                             + (lgvatt_common_pkg.get_att_result_code_use_days(v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM'), NULL, 'HL_FN') / 2)
                                                             + (lgvatt_common_pkg.get_att_result_code_use_days(v_subsidiary_code, em.employee_number, TO_CHAR(ADD_MONTHS(v_basic_date, mm), 'YYYYMM'), NULL, 'HL_SN') / 2)
                                                             );
                anl_rec.apply_date                    := NVL(anl_rec.apply_date                   , TRUNC(SYSDATE));
                anl_rec.annual_calibration_days       := NVL(anl_rec.annual_calibration_days      , 0);
                anl_rec.annual_compensation_days      := NVL(anl_rec.annual_compensation_days     , 0);
                anl_rec.residual_annual_leave_days    := NVL(v_residual_annual_leave_days         , 0)
                                                       + NVL(anl_rec.occur_basic_annual_leave_days, 0)
                                                       + NVL(anl_rec.occur_monthly_ann_lv_days    , 0)
                                                       - NVL(anl_rec.use_annual_leave_days        , 0)
                                                       - NVL(anl_rec.annual_calibration_days      , 0)
                                                       - NVL(anl_rec.annual_compensation_days     , 0);
                anl_rec.creation_user_id              := v_user_id;
                anl_rec.creation_date                 := SYSDATE;
                anl_rec.last_update_user_id           := v_user_id;
                anl_rec.last_update_date              := SYSDATE;
                
                v_residual_annual_leave_days          := anl_rec.residual_annual_leave_days;  -- ??? ??? ????? 

                v_apply_result_flag := lgvatt_transaction_pkg.apply_att_annual_leave_record(anl_rec);
                
            END LOOP;
        END LOOP;
        
        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
    END;
    

    BEGIN    
        -- ????? ???? ?? ?? ?? ??    
        FOR anl IN (    
                    SELECT employee_no, 
                           MIN(time_and_attendance_yyyymm) AS time_and_attendance_yyyymm,
                           TO_CHAR(ADD_MONTHS(TO_DATE(MIN(time_and_attendance_yyyymm), 'YYYYMM'), -1), 'YYYYMM') AS prev_time_attendance_yyyymm
                    FROM   (
                            SELECT al.employee_no, al.time_and_attendance_yyyymm
                            FROM   tb_att_annual_leave_n al,
                                   tb_att_result_n       ar
                            WHERE  al.time_and_attendance_yyyymm >= v_anl_time_attendance_yyyymm
                            AND    al.employee_no                 = ar.employee_no
                            AND    al.time_and_attendance_yyyymm  = ar.time_and_attendance_yyyymm
                            GROUP BY al.employee_no, al.time_and_attendance_yyyymm, NVL(al.use_annual_leave_days, 0)
                            HAVING   NVL(al.use_annual_leave_days, 0) <> SUM(DECODE(ar.time_and_attendance_code, 'AL', 1, 'HL', 0.5, 'HL_FN', 0.5, 'HL_SN', 0.5, 0))
                           )
                    GROUP BY employee_no
                   )
        LOOP
        
            -- ??? ?? ?? ???? ??
            UPDATE tb_att_annual_leave_n al
            SET    use_annual_leave_days = NVL((SELECT SUM(DECODE(ar.time_and_attendance_code, 'AL', 1, 'HL', 0.5, 'HL_FN', 0.5, 'HL_SN', 0.5, 0))
                                                FROM   tb_att_result_n ar
                                                WHERE  ar.employee_no                = al.employee_no
                                                AND    ar.time_and_attendance_yyyymm = al.time_and_attendance_yyyymm
                                                AND    ar.time_and_attendance_code  IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )
                                               ), 0)
            WHERE  employee_no                 = anl.employee_no
            AND    time_and_attendance_yyyymm >= anl.time_and_attendance_yyyymm
            ;

        
            BEGIN
                -- ??? ????
                SELECT NVL(residual_annual_leave_days, 0)
                INTO   v_prev_residual_leave_days
                FROM   tb_att_annual_leave_n
                WHERE  employee_no                = anl.employee_no
                AND    time_and_attendance_yyyymm = anl.prev_time_attendance_yyyymm
                ;
            EXCEPTION
            WHEN OTHERS THEN
                v_prev_residual_leave_days := 0;
            END;
            
            -- ???? ???
            v_residual_annual_leave_days := 0;
        
            -- ??? ?? ?? ???? ??
            FOR mm IN (SELECT *
                       FROM   tb_att_annual_leave_n
                       WHERE  employee_no                 = anl.employee_no
                       AND    time_and_attendance_yyyymm >= anl.time_and_attendance_yyyymm
                       ORDER BY time_and_attendance_yyyymm
                      )
            LOOP
                -- ????
                v_residual_annual_leave_days := NVL(v_prev_residual_leave_days,       0)  -- ????
                                              + NVL(mm.occur_monthly_ann_lv_days,     0)  -- ??????
                                              + NVL(mm.occur_basic_annual_leave_days, 0)  -- ??????(5???)
                                              - NVL(mm.use_annual_leave_days,         0)  -- ????
                                              + NVL(mm.annual_calibration_days,       0)  -- ????
                                              - NVL(mm.annual_compensation_days,      0)  -- ????
                                              ;

                UPDATE tb_att_annual_leave_n al
                SET    residual_annual_leave_days = v_residual_annual_leave_days
                WHERE  time_and_attendance_yyyymm = mm.time_and_attendance_yyyymm
                AND    employee_no                = anl.employee_no
                ;
                
                -- ????
                v_prev_residual_leave_days := v_residual_annual_leave_days;

            END LOOP;

        END LOOP;
        
        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
    END;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END apply_att_fr_asg;



/*************************************************************************************************/
/* Program Name : apply_att_result_fr_plan                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Line Worker ? ?? ?? ?? ???? ?? ???? ????.                 */
/*                                                                                               */
/*              : Office Worker ? ???????? ???, ?? ??? ??? ????.         */
/*                Office Worker ? ?? ?? ???? ??? ?? ??? ???? ???         */
/*                  - ??? ???? ?? ?????, ??? ???? ??? ???? ????, */
/*                    ???? ??? ???? ?? ??? ??.                                 */
/*                  - OW ? ??? ??? ???, ???? ????? ????, ??? ?? ??.*/
/*                  - ????? ?? ??? ????, ?? ?????? ?? ????           */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ??                                                                */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_assignment_caterogy_type        in    varhcar2  ??????(LGD_OW/LGW_LW)  */
/*                p_time_and_attendance_date        in    date      ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/* 2019/10/31  TaiDD          Change from get work hour from tb_att_result to tb_att_plan 
                                          because as the name show, it should get data from plan. not result
/* 2021/07/17  HMT_20210717          Swap weekly holiday (Add p_employee_no)                   */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_att_result_fr_plan (p_ret_code                 OUT VARCHAR2
                                   ,p_ret_msg                  OUT VARCHAR2
                                   ,p_user_id                  IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code          IN  VARCHAR2 DEFAULT NULL
                                   ,p_assignment_caterogy_type IN  VARCHAR2 DEFAULT NULL
                                   ,p_time_and_attendance_date IN  DATE     DEFAULT NULL
                                   ,p_employee_no              IN  VARCHAR2 DEFAULT NULL
                                   )
IS
    v_subsidiary_code             VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                     VARCHAR2(30) := NVL(p_user_id, g_user_id);

    v_time_and_attendance_date    tb_att_plan_n.time_and_attendance_date%TYPE;
    v_ot_calc_status              VARCHAR2(100);
    
    v_time_and_attendance_code_ar tb_att_result_n.time_and_attendance_code%TYPE;

    ar_rec                        tb_att_result_n%ROWTYPE;

    v_apply_result_flag           VARCHAR2(30);
 
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ??? 00:00 ??? ?????, SYSDATE-1
    v_time_and_attendance_date := TRUNC(NVL(p_time_and_attendance_date, SYSDATE-1));

    FOR pln IN (SELECT ap.*
                FROM   tb_att_plan_n   ap
                      ,emp_master      em
                      ,tb_att_result_n ar
                WHERE  ap.subsidiary_code             = v_subsidiary_code
                AND    ap.time_and_attendance_date    = v_time_and_attendance_date
                AND    ap.employee_no                 = NVL(p_employee_no, ap.employee_no)
                AND    ap.base_time_attend_apply_flag = 'N'  -- ??(??)? ??
                AND    ap.subsidiary_code             = em.subsidiary_code
                AND    ap.employee_no                 = em.employee_number
                AND    em.assignment_category         = 'LGD_LW'  -- Line Worker ?
                AND    'LGD_LW'                       = NVL(p_assignment_caterogy_type, 'LGD_LW')
                AND    ap.subsidiary_code             = ar.subsidiary_code
                AND    ap.employee_no                 = ar.employee_no
                AND    ap.time_and_attendance_date    = ar.time_and_attendance_date
                AND    NVL(ar.base_time_attend_apply_flag, 'Y') = 'Y'  -- ???? ?? ?? ??? ??? ?? ???? ??? ???

                UNION ALL

                SELECT ap.*
                FROM   tb_att_plan_n ap
                      ,emp_master    em
                      ,tb_att_lt_time_attend_plan_n lt
                WHERE  ap.subsidiary_code                = v_subsidiary_code
                AND    ap.time_and_attendance_date       = v_time_and_attendance_date
                AND    ap.employee_no                    = NVL(p_employee_no, ap.employee_no)
                AND    ap.base_time_attend_apply_flag    = 'N'  -- ??(??)? ??
                AND    ap.subsidiary_code                = em.subsidiary_code
                AND    ap.employee_no                    = em.employee_number
                AND    em.assignment_category            = 'LGD_OW'  -- Office Worker ?
                AND    'LGD_OW'                          = NVL(p_assignment_caterogy_type, 'LGD_OW')
                AND    ap.subsidiary_code                = lt.subsidiary_code
                AND    ap.employee_no                    = lt.employee_no
                AND    ap.time_and_attendance_date BETWEEN lt.plan_start_date AND lt.plan_end_date
                AND    lt.progress_status_code           = '40'  -- ?????? ??? ?
               )
    LOOP
        ar_rec := lgvatt_common_pkg.get_att_result_rec (pln.subsidiary_code, pln.employee_no, pln.time_and_attendance_date);
        v_time_and_attendance_code_ar         := ar_rec.time_and_attendance_code;  -- ?? ??? ????
        
        ar_rec.time_and_attendance_code       := pln.time_and_attendance_code;
        ar_rec.time_attend_detail_code        := pln.time_attend_detail_code;
        --ar_rec.work_hours                     := lgvatt_common_pkg.get_work_hours(pln.subsidiary_code, pln.employee_no, pln.time_and_attendance_date);  -- ???????? ???? ??
        ar_rec.work_hours                     := lgvatt_common_pkg.get_work_hours_by_plan(pln.subsidiary_code, pln.employee_no, pln.time_and_attendance_date);  -- TaiDD - 20191031 - create a new function and get work hour from tb_att_plan_n
        ar_rec.work_start_time                := lgvatt_common_pkg.get_attendance_time_by_att(pln.subsidiary_code, pln.time_and_attendance_date, pln.shift_type_code);  -- ???????? ?????? ??
        ar_rec.night_shift_flag               := pln.night_shift_flag;
        ar_rec.evening_meal_flag              := pln.evening_meal_flag;
        ar_rec.overtime_sum_hours             := pln.overtime_sum_hours;
        ar_rec.tardy_hours                    := 0;
        ar_rec.early_leave_hours              := 0;
        ar_rec.going_out_hours                := 0;
        ar_rec.base_time_attend_apply_flag    := 'N';  -- ??(??)? ?????? ??? ?????, ????? ??
        ar_rec.last_update_user_id            := v_user_id;
        ar_rec.last_update_date               := SYSDATE;

        lgvatt_ot_calculation_pkg.calculate_ot (p_subsidiary_code    => ar_rec.subsidiary_code
                                               ,p_employee_no        => ar_rec.employee_no --HMT_20210717
                                               ,p_date               => ar_rec.time_and_attendance_date
                                               ,p_att_code           => ar_rec.time_and_attendance_code
                                               ,p_shift_code         => ar_rec.shift_type_code
                                               ,p_night_flag         => ar_rec.night_shift_flag
                                               ,p_dinner_check       => ar_rec.evening_meal_flag
                                               ,p_working_start_time => ar_rec.work_start_time
                                               ,p_ot                 => ar_rec.overtime_sum_hours
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

        -- ????? ????? ??
        v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_record (ar_rec, 'UPDATE');

        -- ?????? ??
        IF (ar_rec.time_and_attendance_code IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' ) OR v_time_and_attendance_code_ar IN ( 'AL', 'HL', 'HL_FN', 'HL_SN' )) THEN

            lgvatt_transaction_pkg.apply_att_use_res_ann_lv(p_ret_code                   => p_ret_code
                                                           ,p_ret_msg                    => p_ret_msg
                                                           ,p_user_id                    => v_user_id
                                                           ,p_subsidiary_code            => v_subsidiary_code
                                                           ,p_employee_no                => ar_rec.employee_no
                                                           ,p_time_and_attendance_yyyymm => ar_rec.time_and_attendance_yyyymm
                                                           ,p_curr_year_apply_flag       => 'N'
                                                           ,p_next_year_apply_flag       => 'Y'
                                                           );
        END IF;

        COMMIT;

    END LOOP;
    
EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END apply_att_result_fr_plan;


/*************************************************************************************************/
/* Program Name : apply_not_approved_att_req                                                     */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : ???? ??? ???? ????.                                             */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ??                                                                */
/*                ???? : 00? ??                                                           */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_att_type                        in    varchar2  ????                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_basic_date                      in    date      ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_approver_employee_no            in    varchar2  ???????               */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE apply_not_approved_att_req (p_ret_code             OUT VARCHAR2
                                     ,p_ret_msg              OUT VARCHAR2
                                     ,p_user_id              IN  VARCHAR2 DEFAULT NULL
                                     ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                                     ,p_att_type             IN  VARCHAR2 DEFAULT NULL
                                     ,p_basic_date           IN  DATE     DEFAULT NULL
                                     ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                                     ,p_approver_employee_no IN  VARCHAR2 DEFAULT NULL
                                     )
IS
    v_subsidiary_code               VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                       VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm    VARCHAR2(30);

    v_basic_date                    DATE;          -- ????
    v_asg_basic_date                DATE;          -- ??????
    
    v_plan_time_attendance_date     DATE;
    v_result_time_attendance_date   DATE;

    v_shift_type_code               VARCHAR2(10);

    ap_rec                          tb_att_plan_n%ROWTYPE;
    ar_rec                          tb_att_result_n%ROWTYPE;
    
    v_ret_code                      VARCHAR2(100);
    v_ret_msg                       VARCHAR2(2000);
    
    v_ot_calc_status                VARCHAR2(30);

    v_not_appr_1st_msg              VARCHAR2(1000);
    v_not_appr_last_msg             VARCHAR2(1000);
    v_not_appr_apprv_flag           VARCHAR2(10);
    v_not_appr_mail_flag            VARCHAR2(10);
    
    v_language_code                 VARCHAR2(30);

    v_apply_result_flag             VARCHAR2(30);

    v_receipt_email_addr            lgcom_mail_info.receipt_email_addr%TYPE;
    v_prev_employee_no              VARCHAR2(30);

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ????(??? ??) : ??? 00:00 ??? ?????, SYSDATE-1
    v_basic_date := TRUNC(NVL(p_basic_date, SYSDATE-1));

    v_plan_time_attendance_date   := v_basic_date;  -- ????
    v_result_time_attendance_date := v_basic_date - 1;  -- ???? = ???? - 1
        
    -- ?? ????
    v_not_appr_1st_msg    := lgvhr_common_pkg.decode_message ('note.att.dayNotApproved1st');   -- 1???? ??? ???
    v_not_appr_last_msg   := lgvhr_common_pkg.decode_message ('note.att.dayNotApprovedLast');  -- ????? ??? ???
    v_not_appr_apprv_flag := lgvhr_common_pkg.decode_lookup ('LGVCOM_APPROVAL_REQUEST_CODE', 'ATT0001', 'A2');  -- ??? ??????
    v_not_appr_mail_flag  := lgvhr_common_pkg.decode_lookup ('LGVCOM_APPROVAL_REQUEST_CODE', 'ATT0001', 'A3');  -- ??? ??????
    
    v_language_code       := lgvhr_common_pkg.decode_lookup ('LGVHR_COMMON_CODE', 'LANGUAGE_CODE', 'A1');  -- ?????

    v_prev_employee_no := 'None';
    
    -- ????? ?????/?? ??? ???
    FOR att IN (SELECT ap.employee_no               AS employee_no
                      ,lasn.user_no                 AS approver_employee_no
                      ,lasn.approval_seqs           AS approval_seqs
                      ,ap.approval_request_id       AS plan_approval_request_id
                      ,ar.approval_request_id       AS result_approval_request_id
                      ,ap.time_and_attendance_date  AS plan_time_attendance_date
                      ,ar.time_and_attendance_date  AS result_time_attendance_date
                      ,ap.shift_type_code           AS plan_shift_type_code
                      ,ar.shift_type_code           AS result_shift_type_code
                      ,ap.request_code              AS plan_request_code
                      ,ar.request_code              AS result_request_code
                      ,lgvhr_common_pkg.get_application_user_id_func(ap.subsidiary_code, lasn.user_no) AS approver_user_id
                      ,(SELECT COUNT(*) 
                        FROM   lgcom_approval_status_n 
                        WHERE  request_master_id       = lasn.request_master_id
                        AND    request_code            = lasn.request_code
                        AND    approval_seqs           > 0
                        AND    approval_action_code    = 'APPROVAL'
                       )                            AS approval_cnt
                FROM   tb_att_plan_n            ap
                      ,lgcom_approval_request_n larn
                      ,lgcom_approval_status_n  lasn
                      ,tb_att_result_n          ar
                WHERE  ap.subsidiary_code           = v_subsidiary_code
                AND    ap.time_and_attendance_date  = v_plan_time_attendance_date
                AND    ap.approval_request_id       = larn.request_master_id
                AND    ap.request_code              = larn.request_code
                AND    larn.status_code            IN ( '20', '30')                              -- ????(20), ???(30)
                AND    larn.request_master_id       = lasn.request_master_id
                AND    larn.request_code            = lasn.request_code
                AND    lasn.approval_status_code    = '2'                                        -- ??????
                AND    lasn.approval_seqs           > 0                                          -- 0:??, >0: ???
                AND    lasn.approval_action_code    = 'APPROVAL'                                 -- ???
                AND    ap.subsidiary_code           = ar.subsidiary_code
                AND    ap.employee_no               = ar.employee_no
                AND    ar.time_and_attendance_date  = v_result_time_attendance_date              -- ???? = ????-1
                AND    ap.employee_no               = NVL(p_employee_no, ap.employee_no)         -- ???
                AND    lasn.user_no                 = NVL(p_approver_employee_no, lasn.user_no)  -- ???
                ORDER BY ap.employee_no
               )
    LOOP
        -- ?? ????? ????
        IF (NVL(att.plan_approval_request_id, 0) != 0) THEN

            -- ???? ????? ???? ????          
            ap_rec := lgvatt_common_pkg.get_att_plan_rec (v_subsidiary_code, att.employee_no, att.plan_time_attendance_date);
                
            -- ????? OT = 0 ??
            ap_rec.overtime_sum_hours            := 0;
            ap_rec.progress_status_code          := '50';  -- REJECT
            ap_rec.base_time_attend_apply_flag   := 'N';   -- ??????
            ap_rec.last_update_user_id           := v_user_id;
            ap_rec.last_update_date              := SYSDATE;

            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_plan_record (ap_rec, 'UPDATE');

            -- ????
            lgcom_bizweb_approval_pkg.main_proc (pi_command           => 'REJECT'
                                                ,pi_request_master_id => att.plan_approval_request_id
                                                ,pi_request_code      => att.plan_request_code
                                                ,pi_user_id           => att.approver_user_id  -- ??? id :  lgcom_user_m.application_user_id
                                                ,pi_comment           => CASE WHEN att.approval_seqs = att.approval_cnt THEN v_not_appr_last_msg ELSE v_not_appr_1st_msg END  -- ????? ???? ???
                                                ,pi_portal_flag       => v_not_appr_apprv_flag  -- ???? ToDo????
                                                ,pi_mail_flag         => v_not_appr_mail_flag   -- ??????
                                                ,po_return_code       => v_ret_code
                                                ,po_return_msg        => v_ret_msg
                                                );
        END IF;


        -- ?? ????? ????
        IF (NVL(att.result_approval_request_id, 0) != 0) THEN

            -- ???? ????? ???? ????          
            ar_rec := lgvatt_common_pkg.get_att_result_rec (v_subsidiary_code, att.employee_no, att.result_time_attendance_date);

            -- ?? ??? ?? ??            
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_hist_record (ar_rec, 'NOT_APPROVED');

            -- ????? OT = 0 ??
            ar_rec.overtime_sum_hours             := 0;
            ar_rec.weekday_overtime_hours         := 0;
            ar_rec.holiday_overtime_hours         := 0;
            ar_rec.public_holiday_overtime_hours  := 0;
            ar_rec.weekday_night_overtime_hours   := 0;
            ar_rec.weekday_ot_af_night_work_hours := 0;
            ar_rec.holiday_night_overtime_hours   := 0;
            ar_rec.public_holiday_night_ot_hours  := 0;
            ar_rec.normal_night_overtime_hours    := 0;
            ar_rec.progress_status_code           := '50';  -- REJECT
            ar_rec.base_time_attend_apply_flag    := 'N';   -- ??????
            ar_rec.last_update_user_id            := v_user_id;
            ar_rec.last_update_date               := SYSDATE;
                
            v_apply_result_flag := lgvatt_transaction_pkg.apply_att_result_record (ar_rec, 'UPDATE');

            -- ????
            lgcom_bizweb_approval_pkg.main_proc (pi_command           => 'REJECT'
                                                ,pi_request_master_id => att.result_approval_request_id
                                                ,pi_request_code      => att.result_request_code
                                                ,pi_user_id           => att.approver_user_id  -- ??? id :  lgcom_user_m.application_user_id
                                                ,pi_comment           => CASE WHEN att.approval_seqs = att.approval_cnt THEN v_not_appr_last_msg ELSE v_not_appr_1st_msg END  -- ????? ???? ???
                                                ,pi_portal_flag       => v_not_appr_apprv_flag  -- ???? ToDo????
                                                ,pi_mail_flag         => v_not_appr_mail_flag   -- ??????
                                                ,po_return_code       => v_ret_code
                                                ,po_return_msg        => v_ret_msg
                                                );
        END IF;
            

        -- ???? ????, ?? ??
        IF (v_prev_employee_no <> att.employee_no) THEN

            v_receipt_email_addr := lgvhr_common_pkg.get_mail_addr_func(v_subsidiary_code, att.employee_no);
            
            IF (v_receipt_email_addr IS NOT NULL) THEN
                lgvhr_transaction_pkg.send_mail (p_ret_code        => v_ret_code
                                                ,p_ret_msg         => v_ret_msg
                                                ,p_user_id         => v_user_id
                                                ,p_subsidiary_code => v_subsidiary_code
                                                ,p_mail_code       => CASE WHEN att.approval_seqs = att.approval_cnt THEN 'DAY_ATT_NOT_APPR_LAST' ELSE 'DAY_ATT_NOT_APPR_1ST' END
                                                ,p_receipt_info    => v_receipt_email_addr
                                                ,p_language_code   => v_language_code
                                                ,p_mail_mapp       => NULL
                                                ,p_sender_info     => NULL
                                                ,p_cc_info         => NULL
                                                );
            END IF;
            
            COMMIT;
        END IF;

        v_prev_employee_no := att.employee_no;

    END LOOP;
    
    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
    ROLLBACK;
    
END apply_not_approved_att_req;


/*************************************************************************************************/
/* Program Name : send_approver_lw_att_info                                                      */
/*-----------------------------------------------------------------------------------------------*/
/* Description  : Line Worker ? ??? ??? ??? 1/2? ????? ??? ????.          */
/*-----------------------------------------------------------------------------------------------*/
/* Schedule     : ???? : ??                                                                */
/*                ???? : ???(12?), ???(00?)                                          */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  ???ID                     */
/*                p_subsidiary_code                 in    varchar2  ????                     */
/*                p_shift_type_code                 in    varchar2  ??????                 */
/*                p_basic_date                      in    date      ????                     */
/*                p_employee_no                     in    varchar2  ????                     */
/*                p_approver_employee_no            in    varchar2  ???????               */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2017/10/25  ???B     Initial Release                                                       */
/*                                                                                               */
/*************************************************************************************************/
PROCEDURE send_approver_lw_att_info (p_ret_code             OUT VARCHAR2
                                    ,p_ret_msg              OUT VARCHAR2
                                    ,p_user_id              IN  VARCHAR2 DEFAULT NULL
                                    ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                                    ,p_night_shift_flag     IN  VARCHAR2 DEFAULT NULL
                                    ,p_basic_date           IN  DATE     DEFAULT NULL
                                    ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                                    ,p_approver_employee_no IN  VARCHAR2 DEFAULT NULL
                                    )
IS
    v_subsidiary_code               VARCHAR2(30) := NVL(p_subsidiary_code, g_subsidiary_code);
    v_user_id                       VARCHAR2(30) := NVL(p_user_id, g_user_id);
    v_time_and_attendance_yyyymm    VARCHAR2(30);

    v_basic_date                    DATE;
    V_night_shift_flag              VARCHAR2(10);

    v_arm_no                        VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVCOM_APPROVAL_REQUEST_CODE', 'ATT0003', 'A1');
    v_org_id                        NUMBER       := lgvhr_common_pkg.get_subsidiary_id_func( lgvhr_common_pkg.get_subsidiary_code_func );

    v_approver                      lgcom_approval_status_tbl;
    v_approver_seq                  NUMBER;

    v_person_seq                    NUMBER;

    v_subject_text                  lgcom_mail_content_n.subject_text%TYPE;
    
    v_mail_content                  CLOB;
    v_per_content                   CLOB;

    v_seq_no                        NUMBER;
    v_sys_user_id                   VARCHAR2(30)   := lgvhr_common_pkg.sys_user_id;
    v_basic_ymd                     VARCHAR2(10);
    
    v_mail_addr                     lgcom_mail_info.receipt_email_addr%TYPE;
    
    appr1_rec                       emp_master%ROWTYPE;
    appr2_rec                       emp_master%ROWTYPE;

BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- ???? ??? ???, ???/??? ?? : ???? ??? ???? ??
    IF (TO_CHAR(SYSDATE, 'HH24') BETWEEN '00' AND '08') THEN
        v_basic_date       := TRUNC(NVL(p_basic_date, SYSDATE-1));  -- ????(??? ??) : ??? 00:00 ??? ?????, SYSDATE-1
        v_night_shift_flag := NVL(p_night_shift_flag, 'Y');
    ELSE
        v_basic_date       := TRUNC(NVL(p_basic_date, SYSDATE));    -- ????(??? ??)
        v_night_shift_flag := NVL(p_night_shift_flag, 'N');
    END IF;

    v_basic_ymd   := TO_CHAR(v_basic_date, 'YYYYMMDD');

    -- ???? : [prefix](LW)Notification for the Daily Attendance Actual ([attendanceDate])
    SELECT REPLACE(mc.subject_text, '[attendanceDate]', TO_CHAR(v_basic_date, 'DD/MM/YYYY'))
    INTO   v_subject_text
    FROM   lgcom_common_code_c  cc
          ,lgcom_mail_content_n mc
    WHERE  cc.code_type_code              = 'LGVHR_MAIL_TEMPLATE_LIST'
    AND    cc.common_code                 = 'LW_DAY_ATT_RESULT_INFO'
    AND    TO_NUMBER(cc.code_data1_value) = mc.mail_id
    AND    mc.language_code               = 'en'
    ;    

    FOR apr IN (-- ????? ??? ??? ??? ???
                SELECT employee_no
                FROM   (
                        SELECT attribute1 AS employee_no  -- 1????
                        FROM   emp_master
                        WHERE  date_retire IS NULL
                        AND    assignment_category = 'LGD_LW'
                        AND    employee_number     = NVL(p_employee_no, employee_number)
                        UNION ALL
                        SELECT attribute2 AS employee_no  -- 2???? : 2?????? ??, ?? ?? 20? ??? ??? ?? : ?) VH000837 
                        FROM   emp_master
                        WHERE  date_retire IS NULL
                        AND    assignment_category = 'LGD_LW'
                        AND    employee_number     = NVL(p_employee_no, employee_number)
                       )
                WHERE  employee_no IS NOT NULL
                AND    employee_no  = NVL(p_approver_employee_no, employee_no)
                GROUP BY employee_no
               )
    LOOP

        v_mail_content := ''
                     || '<html> '
                     || '<head> '
                     || '<title></title> '
                     || '<style> '
                     || '  body  { font-size:10pt; font-family:Malgun Gothic; } '
                     || '  .left   { text-align:left;  padding-left:5px; } '
                     || '  .center { text-align:center; } '
                     || '  .right  { text-align:right; padding-right:5px; } '
                     || '</style> '
                     || '</head> '
                     || '<body> '
                     ;

        FOR org IN (-- ???? ???? ??
                    SELECT organization_id AS organization_id
                          ,position        AS position_code
                          ,attribute1      AS approver1_no
                          ,attribute2      AS approver2_no
                    FROM   emp_master t
                    WHERE  date_retire IS NULL
                    AND    assignment_category = 'LGD_LW'
                    AND    employee_number     = NVL(p_employee_no, employee_number)
                    AND    apr.employee_no    IN ( attribute1, attribute2 )  -- 1? / 2????
                   )
        LOOP
            appr1_rec := lgvhr_common_pkg.get_emp_master_rec (v_subsidiary_code, org.approver1_no);
            appr2_rec := CASE WHEN org.approver2_no IS NULL THEN NULL ELSE lgvhr_common_pkg.get_emp_master_rec (v_subsidiary_code, org.approver2_no) END;
            
            -- ??? ????, ?????
            v_mail_content := v_mail_content
                         || '?Date : ' || TO_CHAR(v_basic_date, 'DD/MM/YYYY') || '<br/>'
                         || '?Organization Name : ' || lgvhr_common_pkg.get_organization_name_func(v_subsidiary_code, org.organization_id) || '<br/>'
                         || '?PIC : ' || lgvatt_common_pkg.get_att_contract_info(v_subsidiary_code, org.organization_id, 'EMP_NO_NAME') || '<br/>'
                         || '?Approver : ' || CASE WHEN apr.employee_no = appr1_rec.employee_number THEN '<b>' || appr1_rec.full_name_local || '(' || appr1_rec.employee_number || ')' || '</b>' 
                                                    ELSE appr1_rec.full_name_local || '(' || appr1_rec.employee_number || ')' END
                                            || CASE WHEN org.approver2_no IS NULL THEN '' ELSE ' > ' END
                                            || CASE WHEN apr.employee_no = appr2_rec.employee_number THEN '<b>' || appr2_rec.full_name_local || '(' || appr2_rec.employee_number || ')' || '</b>' 
                                                    ELSE appr2_rec.full_name_local || '(' || appr2_rec.employee_number || ')' END || '<br/>'

                         || '<table style="border-collapse:collapse" width="1400" border="1" bordercolor="#6e6e6e" cellspacing="0" cellpadding="0" bgcolor="#ffffff"> '
                         || '  <colgroup> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                     || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '    <col style="width:;"/> '
                         || '  </colgroup> '
                         || '  <thead> '

                         || '  <tr style="font-weight:bold; text-align:center; background:#dfe9f2; white-space:nowrap;"> '
                         || '    <th rowspan="2">No</th> '
                         || '    <th colspan="3">Employee</th> '
                         || '    <th rowspan="2">Shift<br>Code</th> '
                         || '    <th rowspan="2">Day/<br>Night</th> '
                         || '    <th rowspan="2">In<br>Time</th> '
                         || '    <th rowspan="2">Out<br>Time</th> '
                         || '    <th colspan="2">Attendance</th> '
                         || '    <th rowspan="2">Normal<br>Start<br>Working<br>Time</th> '
                         || '    <th colspan="3">Deduction</th> '
                         || '    <th rowspan="2">Total<br>O/T</th> '
                         || '    <th rowspan="2">Dinner<br>Check</th> '
                         || '    <th colspan="1">Night</th> '
                         || '    <th colspan="3">O/T</th> '
                         || '    <th colspan="4">O/T at Night</th> '
                         || '  </tr> '
                         || '  <tr style="font-weight:bold; text-align:center; background:#dfe9f2; white-space:nowrap;"> '
                         || '    <th>ID</th> '
                         || '    <th>Name</th> '
                         || '    <th>Job Title</th> '
                         || '    <th>Category</th> '
                         || '    <th>Name</th> '
                         || '    <th>Lateness</th> '
                         || '    <th>Leaving<br>Early</th> '
                         || '    <th>Going<br>Out</th> '
                         || '    <th>30%</th> '
                         || '    <th>150%</th> '
                         || '    <th>200%</th> '
                         || '    <th>300%</th> '
                         || '    <th>200%</th> '
                         || '    <th>210%</th> '
                         || '    <th>270%</th> '
                         || '    <th>390%</th> '
                         || '  </tr> '
                         || '  </thead> '
                         ;

            v_person_seq := 0;

            FOR per IN (SELECT em.employee_number, 
                               em.full_name_local, 
                               lgvhr_common_pkg.decode_lookup('IF_VIETNAM_GRADE_TITLE', em.grade_title)                                       AS grade_title, 
                               ar.shift_type_code                                                                                             AS shift_type_code, 
                               DECODE(ar.night_shift_flag, 'Y', 'Night', 'Day')                                                               AS night_shift_name, 
                               TO_CHAR(lgvatt_common_pkg.get_idcard_inout_time(v_subsidiary_code, ar.employee_no, ar.time_and_attendance_date, 'IN'),  'HH24:MI') AS in_time,
                               TO_CHAR(lgvatt_common_pkg.get_idcard_inout_time(v_subsidiary_code, ar.employee_no, ar.time_and_attendance_date, 'OUT'), 'HH24:MI') AS out_time,
                               lgvhr_common_pkg.decode_lookup('LGVHR_ATTENDANCE_TYPE_CODE', ac.time_and_attendance_type_code)                 AS time_and_attendance_type_name, 
                               lgvatt_common_pkg.get_att_code_info(v_subsidiary_code, ar.time_and_attendance_code)                            AS time_and_attendance_name, 
                               ar.work_start_time, 
                               ar.tardy_hours, 
                               ar.early_leave_hours, 
                               ar.going_out_hours,
                               ar.overtime_sum_hours, 
                               ar.evening_meal_flag, 
                               ar.normal_night_overtime_hours, 
                               ar.weekday_overtime_hours, 
                               ar.holiday_overtime_hours, 
                               ar.public_holiday_overtime_hours, 
                               ar.weekday_night_overtime_hours, 
                               ar.weekday_ot_af_night_work_hours, 
                               ar.holiday_night_overtime_hours, 
                               ar.public_holiday_night_ot_hours
                        FROM   emp_master      em
                              ,tb_att_result_n ar
                              ,tb_att_code_c   ac
                        WHERE  em.organization_id            = org.organization_id
                        AND    em.subsidiary_code            = v_subsidiary_code
                        AND    em.assignment_category        = 'LGD_LW'
                        AND    NVL(em.position, 'XXX')       = NVL(org.position_code, 'XXX')
                        AND    em.employee_number            = ar.employee_no
                        AND    ar.subsidiary_code            = v_subsidiary_code
                        AND    ar.time_and_attendance_date   = v_basic_date
                        AND    NVL(ar.night_shift_flag, 'N') = v_night_shift_flag
                        AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
                        AND    ac.subsidiary_code            = v_subsidiary_code
                        ORDER BY ar.shift_type_code
                                ,ar.employee_no
                       )
            LOOP
                v_person_seq := v_person_seq + 1;

                v_per_content := ''
                            || '  <tr> '
                            || '    <td class="right">'  || v_person_seq                       || '</td> '
                            || '    <td class="center">' || per.employee_number                || '</td> '
                            || '    <td class="left">'   || per.full_name_local                || '</td> '
                            || '    <td class="left">'   || per.grade_title                    || '</td> '
                            || '    <td class="center">' || per.shift_type_code                || '</td> '
                            || '    <td class="left">'   || per.night_shift_name               || '</td> '
                            || '    <td class="center">' || per.in_time                        || '</td> '
                            || '    <td class="center">' || per.out_time                       || '</td> '
                            || '    <td class="left">'   || per.time_and_attendance_type_name  || '</td> '
                            || '    <td class="left">'   || per.time_and_attendance_name       || '</td> '
                            || '    <td class="center">' || per.work_start_time                || '</td> '
                            || '    <td class="right">'  || per.tardy_hours                    || '</td> '
                            || '    <td class="right">'  || per.early_leave_hours              || '</td> '
                            || '    <td class="right">'  || per.going_out_hours                || '</td> '
                            || '    <td class="right">'  || per.overtime_sum_hours             || '</td> '
                            || '    <td class="left">'   || per.evening_meal_flag              || '</td> '
                            || '    <td class="right">'  || per.normal_night_overtime_hours    || '</td> '
                            || '    <td class="right">'  || per.weekday_overtime_hours         || '</td> '
                            || '    <td class="right">'  || per.holiday_overtime_hours         || '</td> '
                            || '    <td class="right">'  || per.public_holiday_overtime_hours  || '</td> '
                            || '    <td class="right">'  || per.weekday_night_overtime_hours   || '</td> '
                            || '    <td class="right">'  || per.weekday_ot_af_night_work_hours || '</td> '
                            || '    <td class="right">'  || per.holiday_night_overtime_hours   || '</td> '
                            || '    <td class="right">'  || per.public_holiday_night_ot_hours  || '</td> '
                            || '  </tr> '
                            ;

                v_mail_content := v_mail_content || v_per_content;

            END LOOP;

            v_mail_content := v_mail_content
                         || '</table> '
                         || '<br/>'
                         || '<br/>'
                         ;
        END LOOP;

        v_mail_content := v_mail_content
                     || '</body> '
                     || '</html> '
                     ;

        v_mail_addr := lgvhr_common_pkg.get_mail_addr_func (v_subsidiary_code, apr.employee_no);
        lgvhr_transaction_pkg.send_mail_clob (p_ret_code, p_ret_msg, v_user_id, v_subsidiary_code, 'LW_DAY_ATT_RESULT_INFO', v_mail_addr, 'en', v_mail_content, NULL, NULL, v_subject_text);

        COMMIT;

    END LOOP;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);

    ROLLBACK;

END send_approver_lw_att_info;

/****************************************************************************/
/*                                                                          */
/* Procedure Name : daily_att_count                                         */
/* Description    : ?? ??? ??(????) ??, ????, ??, ??, ??      */
/*                  ??? ??? ?? (?? ?? ????)                       */
/*                                                                          */
/*                                                                          */
/* Parameter      : Name          I/O  Type      Description                */
/*                  ------------  ---  --------  -------------------------- */
/****************************************************************************/
/* Modification Log                                                         */
/*                                                                          */
/* Date         In Charge  Description                                      */
/* -----------  --------   ------------------------------------------------ */
/* 2023.03.15   Kim Biho   create                                           */
/****************************************************************************/
PROCEDURE daily_att_count
IS
    v_error_msg           varchar2(4000); --???? ???
    v_step                varchar2(4000); --?? ???
    v_lateness            number;
    v_leaving_early       number;
    v_outing              number;
    v_count_employee      number;
    v_error_cnt_check     number;
    v_att_date            date;
    v_time_and_attendance date;
    v_err_buf             VARCHAR(4000);
    v_module_code         CONSTANT lgcom_error_log.module_code%TYPE:='LGVATT';
    v_procedure_name      lgcom_error_log.program_id%TYPE:= NULL;
    v_count               number;
    
    --department 650, 500, 450, 400, 350, 300, 250, 200(VH LGD) ?? ?? ?? 250??? ??? ?
    v_unit_org_id         org_master.Organization_Id%TYPE; --650
    v_part_org_id         org_master.Organization_Id%TYPE; --500
    v_task_org_id         org_master.Organization_Id%TYPE; --400
    v_section_org_id      org_master.Organization_Id%TYPE; --350
    v_team_org_id         org_master.Organization_Id%TYPE; --300
    v_department_org_id   org_master.Organization_Id%TYPE; --250
    v_division_org_id     org_master.Organization_Id%TYPE; --200
    
    v_annual_leave        number;
    v_training            number;
    v_date_value          number;
    v_trip_value          number;
    v_unpaid_value        number;
    
    CURSOR om IS
            SELECT  
                    SUBSIDIARY_CODE
                   ,ORGANIZATION_ID
                   ,ORG_NAME_ENG
                   ,ORG_NAME_LOCAL
                   ,ORG_START_DATE
                   ,ORG_END_DATE
                   ,ORG_TYPE
                   ,PARENT_ORG_ID
                   ,PARENT_ORG_NAME
                   ,ORG_MANAGER_NUMBER
              FROM org_master
             WHERE (org_end_date > sysdate or org_end_date is null)
               and org_type in ('350','400','450','500','600','650')
          order by ORG_TYPE DESC, ORG_NAME_ENG ASC
          ;
BEGIN
   v_step := 'start';
   select to_date(to_char(sysdate-2,'YYYY-MM-DD'),'YYYY-MM-DD')
     into v_time_and_attendance
     from dual;
   
   v_step := 'first Delete';
   delete from TB_ATT_DAILY_REPORT_S
    where TIME_AND_ATTENDANCE_DATE = v_time_and_attendance;
   
   v_step := 'attDateSetting';
   v_att_date := v_time_and_attendance;
   
   --??? ?? ?? ? insert
   FOR oml IN om
      LOOP
        v_error_msg := null;
        v_error_cnt_check := 0;
        v_step := 'part loop start';
        v_lateness := 0;         --?? count
        v_leaving_early := 0;    --?? ?? count
        v_outing :=0;
        v_annual_leave :=0;
        v_training :=0;
        v_count_employee := 0;
        v_trip_value := 0;
        v_unpaid_value := 0;
        
        --part member cnt
        select 
               count(a.employee_number)
         into  v_count_employee
         from  emp_master a
              ,tb_att_idcard_acs_time_n b
              ,tb_att_plan_n c
              ,tb_att_result_n d
         where a.employee_number = b.employee_no
           and b.time_and_attendance_date = c.time_and_attendance_date
           and b.employee_no = c.employee_no
           and b.time_and_attendance_date = d.time_and_attendance_date
           and b.employee_no = d.employee_no
           and a.organization_id = oml.Organization_Id
           and status = 'Active Assignment'
           and b.TIME_AND_ATTENDANCE_DATE = v_time_and_attendance
        ;
        
        if v_count_employee > 0 then
          for rec IN (
                        select 
                               a.employee_number
                              ,a.status
                              ,a.full_name_english
                              ,a.organization_id
                              ,a.org_name_eng
                              ,a.PERSON_TYPE
                              ,a.position
                              ,b.employee_no
                              ,b.time_and_attendance_date
                              ,b.check_in_date
                              ,b.check_out_date
                              ,c.shift_type_code
                              ,c.time_and_attendance_code
                              ,c.night_shift_flag
                              ,d.time_and_attendance_code as res_time_and_attendance_code
                              ,d.a_Day_Of_The_Week_Code
                              ,d.work_start_time
                              ,d.night_shift_flag as res_night_shift_flag
                              ,to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' '||d.work_start_time,'YYYY-MM-DD HH24:MI') as work_start_datetime
                              ,case
                                 when b.CHECK_IN_DATE > to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' '||d.work_start_time,'YYYY-MM-DD HH24:MI') then 'Y'
                                 ELSE 'N'
                               end as in_time_over_yn
                              ,case
                                 when d.a_Day_Of_The_Week_Code = 'FRI' and c.shift_type_code = '1A' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 17:00','YYYY-MM-DD HH24:MI')
                                 when c.shift_type_code = '1A' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 18:00','YYYY-MM-DD HH24:MI') 
                                 when c.shift_type_code != '1A' and d.night_shift_flag = 'N' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 20:00','YYYY-MM-DD HH24:MI')
                                 when c.shift_type_code != '1A' and d.night_shift_flag = 'Y' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 08:00','YYYY-MM-DD HH24:MI')+1
                               end as work_end_datetime
                        from  emp_master a
                             ,tb_att_idcard_acs_time_n b
                             ,tb_att_plan_n c
                             ,tb_att_result_n d
                        where a.employee_number = b.employee_no
                          and b.time_and_attendance_date = c.time_and_attendance_date
                          and b.employee_no = c.employee_no
                          and b.time_and_attendance_date = d.time_and_attendance_date
                          and b.employee_no = d.employee_no
                          and a.organization_id = oml.Organization_Id
                          and status = 'Active Assignment'
                          and b.TIME_AND_ATTENDANCE_DATE = v_time_and_attendance
                       order by a.employee_number asc
          ) LOOP
            
            --attendance code check
            if rec.res_time_and_attendance_code = 'NW' THEN
              if rec.in_time_over_yn = 'Y' THEN
                v_lateness := v_lateness + 1;
              end if;
              
              if rec.check_out_date < rec.work_end_datetime then
                v_leaving_early := v_leaving_early + 1;
              end if;
              
            elsif rec.res_time_and_attendance_code = 'AL' then
              --annual leave count
              v_annual_leave := v_annual_leave + 1;
            elsif rec.res_time_and_attendance_code = 'OB' or rec.res_time_and_attendance_code = 'DB' then
              --business trip count
              v_trip_value := v_trip_value + 1;
            elsif rec.res_time_and_attendance_code = 'OR' or rec.res_time_and_attendance_code = 'DR' then
              --training count
              v_training := v_training + 1;
            elsif rec.res_time_and_attendance_code IN ('AB', 'UL', 'UM', 'UF', 'US', 'PF', 'PL', 'PM') then
              --AB, UL, UM, UF, US, PF, PL, PM
              v_unpaid_value := v_unpaid_value + 1;
            end if;
            
          end LOOP;
        end if;
        
        --Part Member count need insert row!
        v_step := 'get Department all information';
        get_organization_id(
                              v_unit_org_id
                             ,v_part_org_id
                             ,v_task_org_id
                             ,v_section_org_id
                             ,v_team_org_id
                             ,v_department_org_id
                             ,v_division_org_id
                             ,oml.organization_id
                             );
         
         --insert data
         v_step := 'insert in daily report tables';
         insert into TB_ATT_DAILY_REPORT_S
         (      
                 SEQ_VALUE
                ,DIVISION_CODE
                ,DEPARTMENT_CODE
                ,TEAM_ORGANIZATION_ORIGIN_ID
                ,SECTION_CODE
                ,TASK_CODE
                ,PART_GROUP_CODE
                ,UNIT_CODE
                ,EMPLOYEE_HEAD_COUNT
                ,TARDY_COUNT
                ,EARLY_LEAVE_DAYS
                ,GOING_OUT_COUNT
                ,SEL_TRAINING_COMPLT_COUNT
                ,USE_ANNUAL_LEAVE_DAYS
                ,TIME_AND_ATTENDANCE_DATE
                ,CREATION_USER_ID
                ,CREATION_DATE
                ,LAST_UPDATE_USER_ID
                ,LAST_UPDATE_DATE
         )
         values(
                 (SELECT NVL(MAX(SEQ_VALUE)+1,1) FROM TB_ATT_DAILY_REPORT_S)
                ,v_division_org_id
                ,v_department_org_id
                ,v_team_org_id
                ,v_section_org_id
                ,v_task_org_id
                ,v_part_org_id
                ,v_unit_org_id
                ,v_count_employee
                ,v_lateness
                ,v_leaving_early
                ,v_outing
                ,v_training
                ,v_annual_leave
                ,v_att_date
                ,'-1'
                ,SYSDATE
                ,'-1'
                ,SYSDATE
         )
         ;
         commit;
      END LOOP; --department count Loop

EXCEPTION
WHEN NO_DATA_FOUND THEN
    v_err_buf := 'v_step : '|| v_step || chr(20) || SQLERRM;
    v_step :=v_step||chr(20)|| 'User Exception Error()';
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
    lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
WHEN OTHERS THEN
    v_err_buf := 'v_step : '|| v_step || chr(20) || SQLERRM;
    v_step :=v_step||chr(20)|| 'User Exception Error()';
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
    lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END daily_att_count;


/****************************************************************************/
/*                                                                          */
/* Procedure Name : get_organization_id                                     */
/* Description    : ??? ??? ?? ?? ?? ??? ???? ??               */
/*                                                                          */
/*                                                                          */
/*                                                                          */
/* Parameter      : Name          I/O  Type      Description                */
/*                  ------------  ---  --------  -------------------------- */
/****************************************************************************/
/* Modification Log                                                         */
/*                                                                          */
/* Date         In Charge  Description                                      */
/* -----------  --------   ------------------------------------------------ */
/* 2023.03.31   Kim Biho   create                                           */
/****************************************************************************/
PROCEDURE get_organization_id(
                              P_unit_org_id          OUT VARCHAR2
                             ,p_part_org_id          OUT VARCHAR2
                             ,p_task_org_id          OUT VARCHAR2
                             ,p_section_org_id       OUT VARCHAR2
                             ,p_team_org_id          OUT VARCHAR2
                             ,p_department_org_id    OUT VARCHAR2
                             ,p_division_org_id      OUT VARCHAR2
                             ,p_organization_id       IN VARCHAR2
                             )
IS
   v_organization_id         org_master.organization_id%TYPE;
   v_org_type                org_master.org_type%TYPE;

BEGIN
    
    select organization_id, org_type 
      into v_organization_id, v_org_type
      from org_master
     where organization_id = p_organization_id
     ;
     
     if v_org_type = '650' then
       P_unit_org_id := v_organization_id;
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '500' then
       p_part_org_id := v_organization_id;
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '400' then
       p_task_org_id := v_organization_id;      
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '350' then
       p_section_org_id := v_organization_id;
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '300' then
       p_team_org_id := v_organization_id;
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '250' then
       p_department_org_id := v_organization_id;
       
       select organization_id, org_type 
         into v_organization_id, v_org_type
         from org_master
        where organization_id = (select parent_org_id from org_master where organization_id = v_organization_id)
        ;
     end if;
     
     if v_org_type = '200' then
       p_division_org_id := v_organization_id;
     end if
     ;
     
END get_organization_id;

PROCEDURE set_outing_count
IS
    v_error_msg           varchar2(4000);
    v_step                varchar2(4000);
    v_err_buf             VARCHAR(4000);
    v_module_code         CONSTANT lgcom_error_log.module_code%TYPE:='LGVATT';
    v_procedure_name      lgcom_error_log.program_id%TYPE:= NULL;
    
    v_outing_count          TB_ATT_DAILY_REPORT_S.Going_Out_Count%type := 0;
    v_unit_org_id         org_master.Organization_Id%TYPE; --650
    v_part_org_id         org_master.Organization_Id%TYPE; --500
    v_task_org_id         org_master.Organization_Id%TYPE; --400
    v_section_org_id      org_master.Organization_Id%TYPE; --350
    v_team_org_id         org_master.Organization_Id%TYPE; --300
    v_department_org_id   org_master.Organization_Id%TYPE; --250
    v_division_org_id     org_master.Organization_Id%TYPE; --200
    
    v_time_and_attendance date;
    
BEGIN
    
   v_step := 'start';
   select to_date(to_char(sysdate-2,'YYYY-MM-DD'),'YYYY-MM-DD')
     into v_time_and_attendance
     from dual;

   for rec IN (
                 select
                         a.employee_number
                        ,a.organization_id
                        ,count(b.employee_number) as cnt
                   from(    
                          select
                                 a.employee_number
                                ,a.organization_id
                                ,to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' '||d.work_start_time,'YYYY-MM-DD HH24:MI') as work_start_datetime
                                ,case
                                   when d.a_Day_Of_The_Week_Code = 'FRI' and c.shift_type_code = '1A' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 17:00','YYYY-MM-DD HH24:MI')
                                   when c.shift_type_code = '1A' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 18:00','YYYY-MM-DD HH24:MI') 
                                   when c.shift_type_code != '1A' and d.night_shift_flag = 'N' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 20:00','YYYY-MM-DD HH24:MI')
                                   when c.shift_type_code != '1A' and d.night_shift_flag = 'Y' THEN to_date(to_char(b.time_and_attendance_date,'YYYY-MM-DD')||' 08:00','YYYY-MM-DD HH24:MI')+1
                                 end as work_end_datetime
                            from emp_master a
                                ,tb_att_idcard_acs_time_n b
                                ,tb_att_plan_n c
                                ,tb_att_result_n d
                            where a.employee_number = b.employee_no
                              and b.time_and_attendance_date = c.time_and_attendance_date
                              and b.employee_no = c.employee_no
                              and b.time_and_attendance_date = d.time_and_attendance_date
                              and b.employee_no = d.employee_no
                              and status = 'Active Assignment'
                              and b.TIME_AND_ATTENDANCE_DATE = v_time_and_attendance
                         )a, XVH_ATT_IDCARD_HIST_IF b
                   where a.employee_number = b.employee_number(+)
                     and b.log_orgn_dtm > a.work_start_datetime
                     and b.log_orgn_dtm < work_end_datetime
                     and b.employee_number like 'VH%'
                     and b.IN_OUT_DV = 'OUT'
                     and b.EQUIP_NM like '%speedgate%'
                  group by a.employee_number, a.organization_id
    ) LOOP
      --part find
      v_step := 'get Department all information';
      get_organization_id(
                            v_unit_org_id
                           ,v_part_org_id
                           ,v_task_org_id
                           ,v_section_org_id
                           ,v_team_org_id
                           ,v_department_org_id
                           ,v_division_org_id
                           ,rec.organization_id
                           );
      
      v_step := 'update outing';
      --data update
      update TB_ATT_DAILY_REPORT_S set GOING_OUT_COUNT = GOING_OUT_COUNT + rec.cnt
       where NVL(DIVISION_CODE,0) = nvl(v_division_org_id,0)
         and NVL(DEPARTMENT_CODE,0) = nvl(v_department_org_id,0)
         and NVL(TEAM_ORGANIZATION_ORIGIN_ID,0) = nvl(v_team_org_id,0)
         and NVL(SECTION_CODE,0) = nvl(v_section_org_id,0)
         and NVL(TASK_CODE,0) = nvl(v_task_org_id,0)
         and NVL(PART_GROUP_CODE,0) = nvl(v_part_org_id,0)
         and NVL(UNIT_CODE,0) = nvl(v_unit_org_id,0)
         and TIME_AND_ATTENDANCE_DATE = v_time_and_attendance
      ;
      commit;
    END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    v_err_buf := 'v_step : '|| v_step || chr(20) || SQLERRM;
    v_step :=v_step||chr(20)|| 'User Exception Error()';
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
    lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
WHEN OTHERS THEN
    v_err_buf := 'v_step : '|| v_step || chr(20) || SQLERRM;
    v_step :=v_step||chr(20)|| 'User Exception Error()';
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
    lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
    
END set_outing_count;

                                    
END lgvatt_batch_pkg;
/
