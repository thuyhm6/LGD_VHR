CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_idcard_pkg
IS

PROCEDURE main (p_ret_code             OUT VARCHAR2
               ,p_ret_msg              OUT VARCHAR2
               ,p_user_id              IN  VARCHAR2 DEFAULT NULL
               ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
               ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
               );

PROCEDURE idcard_interface (p_user_id              IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                           ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                           );

PROCEDURE inout_time (p_user_id              IN  VARCHAR2 DEFAULT NULL
                     ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                     ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                     );

END lgvatt_idcard_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_idcard_pkg
IS

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2003                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : lgvatt_idcard_pkg.pck                                     */
/* Program ID     :                                                           */
/* Pakage Name    : lgvatt_idcard_pkg                                         */
/* Description    : 근태 ID카드 Interface Pkg                                 */
/* Procedure      :                                                           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/******************************************************************************/

PROCEDURE main (p_ret_code             OUT VARCHAR2
               ,p_ret_msg              OUT VARCHAR2
               ,p_user_id              IN  VARCHAR2 DEFAULT NULL
               ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
               ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
               )
IS
    v_user_id                      VARCHAR2(30);
    v_subsidiary_code              VARCHAR2(30);
BEGIN

    v_user_id         := NVL(p_user_id,          lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SYS_USER', 'A1'));
    v_subsidiary_code := NVL(p_subsidiary_code,  lgvhr_common_pkg.decode_lookup('LGVHR_COMMON_CODE', 'SUBSIDIARY_CODE', 'A1'));

    -- ID 카드 Interface 수행
    idcard_interface (v_user_id, v_subsidiary_code, p_employee_no);

    -- 출퇴근 시간 추출
    inout_time (v_user_id, v_subsidiary_code, p_employee_no);

END;



/****************************************************************************/
/*                                                                          */
/* Procedure Name : idcard_interface                                        */
/*--------------------------------------------------------------------------*/
/****************************************************************************/
PROCEDURE idcard_interface (p_user_id              IN  VARCHAR2 DEFAULT NULL
                           ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                           ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                           )
IS
    l_cnt NUMBER := 0;

    CURSOR idcard
    IS
        SELECT *
          FROM 
          (SELECT log_seqno
                    ,suss_yn
                    ,user_id
                    ,employee_number
                    ,loct_site_id
                    ,loct_site_nm
                    ,equip_id
                    ,in_out_dv
                    ,log_basc_dtm
                    ,log_orgn_dtm
                    ,log_recv_dtm
                    ,user_type_cd-- Regular Employee
                    ,eai_interface_date
                   -- ,ROWID          
              FROM   xvh_att_idcard_hist_if xai -- EAI에서 넣어 주는 인터페이스 테이블
              WHERE  xai.application_transfer_flag = 'N'
              AND    xai.employee_number          IS NOT NULL
              AND    xai.employee_number           = NVL(p_employee_no, employee_number)
              AND    xai.user_type_cd = 'C0226' -- 정규직 
            UNION ALL
              SELECT xai.log_seqno
                    ,xai.suss_yn
                    ,xai.user_id
                    ,tae.employee_no as  employee_number
                    ,xai.loct_site_id
                    ,xai.loct_site_nm
                    ,xai.equip_id
                    ,xai.in_out_dv
                    ,xai.log_basc_dtm
                    ,xai.log_orgn_dtm
                    ,xai.log_recv_dtm
                    ,xai.user_type_cd --user_type_cd-- OS(Out Sourcing Employee)     
                    ,xai.eai_interface_date 
              FROM   xvh_att_idcard_hist_if xai -- EAI에서 넣어 주는 인터페이스 테이블
                    ,tb_att_emp_idcard_m tae
              WHERE  xai.application_transfer_flag = 'N'
              AND    xai.user_type_cd IN (
                                           SELECT lcc.common_code
                                              FROM   lgcom_common_code_c lcc
                                              WHERE  1 = 1
                                              AND lcc.code_type_code = 'LGVHR_ATT_OS_EMP_IDP_IF'
                                              AND lcc.use_flag = 'Y' ) -- 'C0227'
              AND    to_char(xai.card_id) = tae.id_card_no
              AND    xai.log_orgn_dtm between tae.effective_start_date and nvl(tae.effective_end_date, sysdate + 1)
              AND    tae.employee_no          IS NOT NULL
              AND    tae.employee_no           = NVL(p_employee_no, tae.employee_no))
              ORDER  BY  user_type_cd, eai_interface_date 
              ;

BEGIN

    DELETE xvh_att_idcard_hist_if
    WHERE  application_transfer_flag = 'N'
    AND    employee_number          IS NULL
    AND    employee_number           = NVL(p_employee_no, employee_number)
    ;

    FOR c1 IN idcard
    LOOP

        l_cnt := l_cnt + 1;

        BEGIN
            INSERT INTO xvh_att_idcard_hist_n
                (log_seqno
                ,suss_yn
                ,user_id
                ,employee_number
                ,loct_site_id
                ,loct_site_nm
                ,equip_id
                ,in_out_dv
                ,log_basc_dtm
                ,log_orgn_dtm
                ,log_recv_dtm
                ,aggregate_type_code
                ,transdate
                ,creation_date)
            VALUES
                (c1.log_seqno
                ,c1.suss_yn
                ,c1.user_id
                ,c1.employee_number
                ,c1.loct_site_id
                ,c1.loct_site_nm
                ,c1.equip_id
                ,c1.in_out_dv
                ,c1.log_basc_dtm
                ,c1.log_orgn_dtm
                ,c1.log_recv_dtm
                ,''
                ,TO_CHAR(c1.log_orgn_dtm, 'YYYYMMDD')
                ,SYSDATE
                );
            -- xvh_att_idcard_hist_interface 에 넣고 Flag 정보 Update
            UPDATE xvh_att_idcard_hist_if xai
            SET    xai.application_transfer_flag = 'Y'
                  ,xai.application_transfer_date = SYSDATE
            WHERE  xai.log_seqno = c1.log_seqno ;           
           

        EXCEPTION
        WHEN OTHERS THEN
            NULL;
        END;

    END LOOP;
    
     BEGIN
         UPDATE xvh_att_idcard_hist_if xai
         SET    xai.application_transfer_flag = 'X' -- 비정상 데이터 
         WHERE  1 = 1
         AND    xai.application_transfer_flag = 'N'
         AND    xai.user_type_cd = 'C0227'
         AND    NOT EXISTS
          (SELECT 'x'
                 FROM   tb_att_emp_idcard_m tae
                 WHERE  1 = 1
                 AND    xai.application_transfer_flag = 'N'
                 AND    xai.user_type_cd = 'C0227'
                 AND    xai.log_orgn_dtm BETWEEN tae.effective_start_date AND
                        NVL(tae.effective_end_date, SYSDATE + 1)
                 AND    tae.id_card_no = TO_CHAR(xai.card_id));
     END;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;

END idcard_interface;



/****************************************************************************/
/*                                                                          */
/* Procedure Name : inout_time                                              */
/* Description    : 출/입 이력을 가져와서 실제 개인별 출/퇴근 시간을 추출   */
/*                  추출시 야간조 때문에 출입일자 와 출입일자 -1일 을 계산  */
/*                  만약 실적이 들어 있다면 이상여부까지 확인함             */
/*                                                                          */
/* Parameter      : Name          I/O  Type      Description                */
/*                  ------------  ---  --------  -------------------------- */
/****************************************************************************/
/* Modification Log                                                         */
/*                                                                          */
/* Date         In Charge  Description                                      */
/* -----------  --------   ------------------------------------------------ */
/****************************************************************************/
PROCEDURE inout_time (p_user_id              IN  VARCHAR2 DEFAULT NULL
                     ,p_subsidiary_code      IN  VARCHAR2 DEFAULT NULL
                     ,p_employee_no          IN  VARCHAR2 DEFAULT NULL
                     )
IS
    v_day_in_s_days     NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_IN_S_TIME',    'A2');  -- 기준일자 + 일수
    v_day_in_s_time     VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_IN_S_TIME',    'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_day_in_e_days     NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_IN_E_TIME',    'A2');  -- 기준일자 + 일수
    v_day_in_e_time     VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_IN_E_TIME',    'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_day_out_s_days    NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_OUT_S_TIME',   'A2');  -- 기준일자 + 일수
    v_day_out_s_time    VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_OUT_S_TIME',   'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_day_out_e_days    NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_OUT_E_TIME',   'A2');  -- 기준일자 + 일수
    v_day_out_e_time    VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'DAY_OUT_E_TIME',   'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_night_in_s_days   NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_IN_S_TIME',  'A2');  -- 기준일자 + 일수
    v_night_in_s_time   VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_IN_S_TIME',  'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_night_in_e_days   NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_IN_E_TIME',  'A2');  -- 기준일자 + 일수
    v_night_in_e_time   VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_IN_E_TIME',  'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_night_out_s_days  NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_OUT_S_TIME', 'A2');  -- 기준일자 + 일수
    v_night_out_s_time  VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_OUT_S_TIME', 'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_night_out_e_days  NUMBER       := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_OUT_E_TIME', 'A2');  -- 기준일자 + 일수
    v_night_out_e_time  VARCHAR2(30) := lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'NIGHT_OUT_E_TIME', 'A1');  -- 기준일자 시간(HH24:MI:SS)

    v_day_in_s_date     DATE;
    v_day_in_e_date     DATE;
    v_day_out_s_date    DATE;
    v_day_out_e_date    DATE;

    v_night_in_s_date   DATE;
    v_night_in_e_date   DATE;
    v_night_out_s_date  DATE;
    v_night_out_e_date  DATE;

    l_cnt                  NUMBER := 0;

    l_in_time              DATE;
    l_out_time             DATE;

    l_prev_in_time         DATE;

    v_apply_result_flag           VARCHAR2(30);

    ar_rec                        tb_att_result_n%ROWTYPE;
    aict_rec                      tb_att_idcard_acs_time_n%ROWTYPE;
    

    CURSOR emp_cur (c_employee_no IN VARCHAR2)
    IS
    SELECT *
    FROM   tb_att_plan_n
    WHERE  subsidiary_code          = p_subsidiary_code
    AND    time_and_attendance_date = TRUNC(SYSDATE)     -- 오늘기준의 대상자   
    AND    employee_no              = NVL(c_employee_no, employee_no)
    ORDER BY employee_no
    ;
    
    CURSOR cal_cur
    IS
    SELECT time_and_attendance_date
    FROM   tb_att_calendar_n
    WHERE  subsidiary_code                = p_subsidiary_code
    AND    time_and_attendance_date      >= TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE', 'IDCARD_ACS_TIME_START_DATE', 'A1'), 'YYYYMMDD')
    AND    time_and_attendance_date BETWEEN TRUNC(SYSDATE)+TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_TIME_RANGE', 'PAST_DAYS', 'A1')) AND TRUNC(SYSDATE)
    ORDER BY time_and_attendance_date DESC
    ;

    CURSOR idp_cur (c_employee_no IN VARCHAR2)
    IS
    SELECT MAX(DECODE(day_night, 'Day', in_time )) AS day_in_time,
           MAX(DECODE(day_night, 'Day', out_time)) AS day_out_time,
           (MAX(DECODE(day_night, 'Day', out_time)) - MAX(DECODE(day_night, 'Day', in_time))) * 24 AS day_in_gap,

           MAX(DECODE(day_night, 'Night', in_time )) AS night_in_time,
           MAX(DECODE(day_night, 'Night', out_time)) AS night_out_time,
           (MAX(DECODE(day_night, 'Night', out_time)) - MAX(DECODE(day_night, 'Night', in_time))) * 24 AS night_in_gap,
           
           MAX(DECODE(day_night, 'Day', in_time_prev )) AS day_in_time_prev,
           MAX(DECODE(day_night, 'Day', out_time_prev)) AS day_out_time_prev,
           (MAX(DECODE(day_night, 'Day', out_time_prev)) - MAX(DECODE(day_night, 'Day', in_time_prev))) * 24 AS day_in_gap_prev,

           MAX(DECODE(day_night, 'Night', in_time_prev )) AS night_in_time_prev,
           MAX(DECODE(day_night, 'Night', out_time_prev)) AS night_out_time_prev,
           (MAX(DECODE(day_night, 'Night', out_time_prev)) - MAX(DECODE(day_night, 'Night', in_time_prev))) * 24 AS night_in_gap_prev

    FROM   (
            SELECT 'Day' AS day_night, 
                   MIN(DECODE(in_out_dv,  'IN',  log_orgn_dtm)) AS in_time, 
                   MAX(DECODE(in_out_dv,  'OUT', log_orgn_dtm)) AS out_time,
                   MIN(CASE WHEN in_out_dv = 'IN'  AND xa.log_orgn_dtm < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time) THEN xa.log_orgn_dtm ELSE NULL END) AS in_time_prev,
                   MAX(CASE WHEN in_out_dv = 'OUT' AND xa.log_orgn_dtm < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time) THEN xa.log_orgn_dtm ELSE NULL END) AS out_time_prev
            FROM   xvh_att_idcard_hist_n xa
            WHERE  (
                    (xa.in_out_dv = 'IN'  AND xa.log_orgn_dtm BETWEEN v_day_in_s_date AND v_day_in_e_date)  -- Day 의 IN시간은 05:00 ~ 17:00 까지만 허용 : 상세사항은 Setup 확인
                    OR
                    (xa.in_out_dv = 'OUT' AND xa.log_orgn_dtm BETWEEN v_day_out_s_date AND v_day_out_e_date)  -- Day 의 OUT시간은 11:00 ~ 03:00 까지만 허용 : 상세사항은 Setup 확인
                   )
            AND    xa.log_orgn_dtm          < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time)
            AND    xa.employee_number       = c_employee_no
            UNION ALL
            SELECT 'Night' AS day_night, 
                   MIN(DECODE(in_out_dv,  'IN',  log_orgn_dtm)) AS in_time, 
                   MAX(DECODE(in_out_dv,  'OUT', log_orgn_dtm)) AS out_time,
                   MIN(CASE WHEN in_out_dv = 'IN'  AND xa.log_orgn_dtm < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time) THEN xa.log_orgn_dtm ELSE NULL END) AS in_time_prev,
                   MAX(CASE WHEN in_out_dv = 'OUT' AND xa.log_orgn_dtm < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time) THEN xa.log_orgn_dtm ELSE NULL END) AS out_time_prev
            FROM   xvh_att_idcard_hist_n xa
            WHERE  (
                    (xa.in_out_dv = 'IN'  AND xa.log_orgn_dtm BETWEEN v_night_in_s_date AND v_night_in_e_date)  -- Night 의 IN시간은 17:00 ~ 05:00 까지만 허용 : 상세사항은 Setup 확인
                    OR
                    (xa.in_out_dv = 'OUT' AND xa.log_orgn_dtm BETWEEN v_night_out_s_date AND v_night_out_e_date)  -- Night 의 OUT시간은 23:00 ~ 12:00 까지만 허용 : 상세사항은 Setup 확인
                   )
            AND    xa.log_orgn_dtm          < NVL(l_prev_in_time, lgvhr_common_pkg.end_of_time)
            AND    xa.employee_number       = c_employee_no
           )
    ;

BEGIN

    l_cnt := 0;
    
    FOR emp IN emp_cur(p_employee_no)
    LOOP

        l_prev_in_time := NULL;

        FOR cal IN cal_cur
        LOOP
        
            DELETE tb_att_idcard_acs_time_n
            WHERE  time_and_attendance_date = cal.time_and_attendance_date
            AND    employee_no              = emp.employee_no
            ;

            v_day_in_s_date    := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_day_in_s_days,    'YYYYMMDD') || ' ' || v_day_in_s_time,    'YYYYMMDD HH24:MI:SS');  -- Day 의 IN 범위 시작일시
            v_day_in_e_date    := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_day_in_e_days,    'YYYYMMDD') || ' ' || v_day_in_e_time,    'YYYYMMDD HH24:MI:SS');  -- Day 의 IN 범위 종료일시
            v_day_out_s_date   := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_day_out_s_days,   'YYYYMMDD') || ' ' || v_day_out_s_time,   'YYYYMMDD HH24:MI:SS');  -- Day 의 OUT 범위 시작일시
            v_day_out_e_date   := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_day_out_e_days,   'YYYYMMDD') || ' ' || v_day_out_e_time,   'YYYYMMDD HH24:MI:SS');  -- Day 의 OUT 범위 종료일시

            v_night_in_s_date  := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_night_in_s_days,  'YYYYMMDD') || ' ' || v_night_in_s_time,  'YYYYMMDD HH24:MI:SS');  -- Night 의 IN 범위 시작일시
            v_night_in_e_date  := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_night_in_e_days,  'YYYYMMDD') || ' ' || v_night_in_e_time,  'YYYYMMDD HH24:MI:SS');  -- Night 의 IN 범위 종료일시
            v_night_out_s_date := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_night_out_s_days, 'YYYYMMDD') || ' ' || v_night_out_s_time, 'YYYYMMDD HH24:MI:SS');  -- Night 의 OUT 범위 시작일시
            v_night_out_e_date := TO_DATE(TO_CHAR(cal.time_and_attendance_date + v_night_out_e_days, 'YYYYMMDD') || ' ' || v_night_out_e_time, 'YYYYMMDD HH24:MI:SS');  -- Night 의 OUT 범위 종료일시

IF (p_employee_no IS NOT NULL) THEN
    dbms_output.put_line ('');
    dbms_output.put_line ('l_prev_in_time     = ' || TO_CHAR(l_prev_in_time    , 'YYYY-MM-DD HH24:MI:SS'));
    dbms_output.put_line ('v_day_in_s_date    = ' || TO_CHAR(v_day_in_s_date   , 'YYYY-MM-DD HH24:MI:SS') || ' ~ ' || TO_CHAR(v_day_in_e_date   , 'YYYY-MM-DD HH24:MI:SS'));
    dbms_output.put_line ('v_day_out_s_date   = ' || TO_CHAR(v_day_out_s_date  , 'YYYY-MM-DD HH24:MI:SS') || ' ~ ' || TO_CHAR(v_day_out_e_date  , 'YYYY-MM-DD HH24:MI:SS'));
    dbms_output.put_line ('v_night_in_s_date  = ' || TO_CHAR(v_night_in_s_date , 'YYYY-MM-DD HH24:MI:SS') || ' ~ ' || TO_CHAR(v_night_in_e_date , 'YYYY-MM-DD HH24:MI:SS'));
    dbms_output.put_line ('v_night_out_s_date = ' || TO_CHAR(v_night_out_s_date, 'YYYY-MM-DD HH24:MI:SS') || ' ~ ' || TO_CHAR(v_night_out_e_date, 'YYYY-MM-DD HH24:MI:SS'));
END IF;        
            FOR idp IN idp_cur(emp.employee_no)
            LOOP
                l_cnt := l_cnt + 1;
                
                l_in_time  := NULL;
                l_out_time := NULL;

                ar_rec := lgvatt_common_pkg.get_att_result_rec(p_subsidiary_code, emp.employee_no, cal.time_and_attendance_date);
                ar_rec.work_start_time := NVL(ar_rec.work_start_time, '08:00');
                
                IF (ar_rec.work_start_time = '08:00') THEN

                    l_in_time  := idp.day_in_time;
                    l_out_time := idp.day_out_time;

                    IF ((idp.day_in_time IS NULL OR idp.day_out_time IS NULL) AND idp.night_in_time IS NOT NULL AND idp.night_out_time IS NOT NULL AND idp.night_in_gap >= 2) THEN  -- 최소 2시간 차이는 날때
                        l_in_time  := idp.night_in_time;
                        l_out_time := idp.night_out_time;
                    END IF;

                    IF (l_in_time IS NULL) THEN
                        l_in_time  := LEAST(NVL(idp.day_in_time, idp.night_in_time), NVL(idp.night_in_time, idp.day_in_time));
                    END IF;
                    
                    IF (l_out_time IS NULL) THEN
                        l_out_time  := LEAST(NVL(idp.day_out_time, idp.night_out_time), NVL(idp.night_out_time, idp.day_out_time));
                    END IF;
                    
                    IF (l_out_time IS NOT NULL AND l_in_time IS NOT NULL AND l_out_time <= l_in_time) THEN
                        l_out_time := NULL;
                    END IF;
                    
                ELSIF (ar_rec.work_start_time = '20:00') THEN

                    l_in_time  := idp.night_in_time;
                    l_out_time := idp.night_out_time;

                    IF ((idp.night_in_time IS NULL OR idp.night_out_time IS NULL) AND idp.day_in_time IS NOT NULL AND idp.day_out_time IS NOT NULL AND idp.day_in_gap >= 2) THEN  -- 최소 2시간 차이는 날때
                        l_in_time  := idp.day_in_time;
                        l_out_time := idp.day_out_time;
                    END IF;

                    IF (l_in_time IS NULL) THEN
                        l_in_time  := LEAST(NVL(idp.day_in_time, idp.night_in_time), NVL(idp.night_in_time, idp.day_in_time));
                    END IF;
                    
                    IF (l_out_time IS NULL) THEN
                        l_out_time  := LEAST(NVL(idp.day_out_time, idp.night_out_time), NVL(idp.night_out_time, idp.day_out_time));
                    END IF;
                    
                    IF (l_out_time IS NOT NULL AND l_in_time IS NOT NULL AND l_out_time <= l_in_time) THEN
                        l_out_time := NULL;
                    END IF;
                
                -- 08:00 / 20:00 아니면    
                ELSE
                    l_in_time  := LEAST(NVL(idp.day_in_time, idp.night_in_time), NVL(idp.night_in_time, idp.day_in_time));
                    l_out_time  := LEAST(NVL(idp.day_out_time, idp.night_out_time), NVL(idp.night_out_time, idp.day_out_time));

                    IF (l_out_time IS NOT NULL AND l_in_time IS NOT NULL AND l_out_time <= l_in_time) THEN
                        l_out_time := NULL;
                    END IF;
                END IF;
                

                aict_rec.subsidiary_code          := p_subsidiary_code;
                aict_rec.employee_no              := emp.employee_no;
                aict_rec.time_and_attendance_date := cal.time_and_attendance_date;
                aict_rec.check_in_date            := l_in_time;
                aict_rec.check_out_date           := l_out_time;
                aict_rec.creation_user_id         := p_user_id;
                aict_rec.creation_date            := SYSDATE;
                aict_rec.last_update_user_id      := p_user_id;
                aict_rec.last_update_date         := SYSDATE;

                v_apply_result_flag := lgvatt_transaction_pkg.apply_att_idcard_acs_record(aict_rec);
                
IF (p_employee_no IS NOT NULL) THEN
    dbms_output.put_line ('in_time ~ out_time = ' || LPAD(NVL(TO_CHAR(l_in_time,      'YYYY-MM-DD HH24:MI:SS'), ' '), 19, ' ') || ' ~ '     || LPAD(NVL(TO_CHAR(l_out_time,     'YYYY-MM-DD HH24:MI:SS'), ' '), 19, ' '));
END IF;        
                l_prev_in_time := l_in_time;

                -- 출입데이타가 한꺼번에 들어오는 경우에, 락이 걸리는 경우가 발생하여, 1000 건마다 Commit 하도록 함
                IF (MOD(l_cnt, 1000) = 0) THEN
                    COMMIT;
                END IF;
            
            END LOOP;

        END LOOP;

    END LOOP;

    COMMIT;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;

END inout_time;


END lgvatt_idcard_pkg;
/
