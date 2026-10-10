CREATE OR REPLACE PACKAGE VHR_MGR.lgvatt_ot_level_pkg
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : lgvatt_ot_level_pkg.pls
/* Description  : Ot Level Package
/*
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date         In Charge           Description
/*------------------------------------------------------------------------------
/*  2021/04/06                       Initialized
/*
/******************************************************************************/
/******************************************************************************/
IS

FUNCTION calculate_ot_level(p_subsidiary_code    IN VARCHAR2,
                           p_date               IN DATE,
                           p_att_code           IN VARCHAR2,
                           p_shift_code         IN VARCHAR2,
                           p_night_flag         IN VARCHAR2,
                           p_dinner_check       IN VARCHAR2,
                           p_working_start_time IN VARCHAR2,
                           p_ot                 IN NUMBER
                          ) RETURN VARCHAR2;

PROCEDURE apply_att_ot_level_calc  (p_ret_code                    OUT VARCHAR2
                                   ,p_ret_msg                     OUT VARCHAR2
                                   ,p_user_id                     IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code             IN  VARCHAR2 DEFAULT NULL
                                   ,p_apply_flag                  IN  VARCHAR2 DEFAULT 'Y'
                                   ,p_employee_no                 IN  VARCHAR2 DEFAULT NULL
                                   );
FUNCTION get_ot_length_level(p_atendance_yyyymm IN  VARCHAR2,
                             p_shift_code       IN  VARCHAR2,
                             p_level            IN  VARCHAR2
                    ) RETURN NUMBER;

FUNCTION get_ot_level(p_subsidiary_code    IN  VARCHAR2,
                      p_employee_no        IN  VARCHAR2,
                      p_attendance_yyyymm  IN  VARCHAR2,
                      p_get_type           IN  VARCHAR2
                        )
RETURN VARCHAR2;


END lgvatt_ot_level_pkg;
/**********************************************************/
/* End of Program
/**********************************************************/
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvatt_ot_level_pkg
/******************************************************************************/
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : lgvatt_ot_level_pkg.pls
/* Description  : Ot Calculation Package
/*
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date         In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/04/06    HMT_20210406       Initialized
/*
/******************************************************************************/
IS

FUNCTION calculate_ot_level(p_subsidiary_code    IN VARCHAR2
                          ,p_date               IN DATE
                          ,p_att_code           IN VARCHAR2
                          ,p_shift_code         IN VARCHAR2
                          ,p_night_flag         IN VARCHAR2
                          ,p_dinner_check       IN VARCHAR2
                          ,p_working_start_time IN VARCHAR2
                          ,p_ot                 IN NUMBER
                          )
RETURN VARCHAR2
IS
    v_ot150              NUMBER;
    v_ot200              NUMBER;
    v_ot300              NUMBER;
    v_nt200              NUMBER;
    v_nt210              NUMBER;
    v_nt270              NUMBER;
    v_nt390              NUMBER;
    v_nt30               NUMBER;
    v_status             VARCHAR2(100);

BEGIN
    

    IF (v_status NOT IN ( 'DAY', 'NIGHT' )) THEN
        RETURN '';
    ELSE
        RETURN 'OT150=' || v_ot150 || ':' ||
               'OT200=' || v_ot200 || ':' ||
               'OT300=' || v_ot300 || ':' ||
               'NT200=' || v_nt200 || ':' ||
               'NT210=' || v_nt210 || ':' ||
               'NT270=' || v_nt270 || ':' ||
               'NT390=' || v_nt390 || ':' ||
               'NT30='  || v_nt30 ;
    END IF;

EXCEPTION
WHEN OTHERS THEN
     RETURN '';

END calculate_ot_level;

/*************************************************************************************************/
/* Program Name : calculate_ot_level                                                       */
/*-----------------------------------------------------------------------------------------------*/
/* Parameter    : name                            in/out  type      description                  */
/*                -------------------------------------------------------------------------------*/
/*                p_user_id                         in    varchar2  사용자ID                     */
/*                p_subsidiary_code                 in    varchar2  법인코드                     */
/*                p_apply_flag                      in    varchar2  기본근태적용여부             */
/*                p_employee_no                     in    varchar2  사원번호                     */
/*-----------------------------------------------------------------------------------------------*/
/* Program History                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/* Date        In Charge    Description                                                          */
/*-----------------------------------------------------------------------------------------------*/
/* 2021/04/06  HMT           Add                                                       */
/*************************************************************************************************/
PROCEDURE apply_att_ot_level_calc (p_ret_code                    OUT VARCHAR2
                                   ,p_ret_msg                     OUT VARCHAR2
                                   ,p_user_id                     IN  VARCHAR2 DEFAULT NULL
                                   ,p_subsidiary_code             IN  VARCHAR2 DEFAULT NULL
                                   ,p_apply_flag                  IN  VARCHAR2 DEFAULT 'Y'
                                   ,p_employee_no                 IN  VARCHAR2 DEFAULT NULL
                                   )
IS
    v_subsidiary_code               VARCHAR2(30) := NVL(p_subsidiary_code, 'LGDVN');
    v_user_id                       VARCHAR2(30) := NVL(p_user_id, lgvhr_common_pkg.sys_user_id);

    v_ot_calc_status                VARCHAR2(100);
    v_level_0                       NUMBER := 0;
    v_level_1                       NUMBER := 0;
    v_level_2                       NUMBER := 0;
    v_level_3                       NUMBER := 0;
    v_level_4                       VARCHAR2(30) := 'No Limit';
    v_shift_1A                      NUMBER := 0;
    v_shift_2B                      NUMBER := 0;
    v_shift_3C                      NUMBER := 0;
    v_perfect_day                   NUMBER := 0;
BEGIN

    p_ret_code := '0';
    p_ret_msg  := ' ';

    -- 2018.01.30 박귀희 : OT 계산을 위하여 변경 구분된 컬럼에 대하여 OT 계산
    -- 동일한 근태사항끼리 그룹핑 : 속도빠르게
    FOR res IN (SELECT 
                       employee_no                AS employee_no 
                      ,time_and_attendance_yyyymm                AS time_and_attendance_yyyymm 
                FROM   tb_att_ot_level_info_n ar
                WHERE  subsidiary_code             = v_subsidiary_code
                AND    apply_flag = 'T'
                AND    employee_no                 = NVL(p_employee_no, employee_no)
                GROUP BY  employee_no, time_and_attendance_yyyymm
               )
    LOOP
        
    select count(1) into v_perfect_day
      from tb_att_result_n a
      where a.time_and_attendance_yyyymm = res.time_and_attendance_yyyymm
        and a.employee_no                = res.employee_no;
        
      select count(1) into v_shift_1A
      from tb_att_result_n a
      where a.time_and_attendance_yyyymm = res.time_and_attendance_yyyymm
        and a.employee_no                = res.employee_no
        and a.shift_type_code like '1%';
      
      select count(1) into v_shift_2B
      from tb_att_result_n a
      where a.time_and_attendance_yyyymm = res.time_and_attendance_yyyymm
        and a.employee_no                = res.employee_no
        and a.shift_type_code like '2%';
        
      select count(1) into v_shift_3C
      from tb_att_result_n a
      where a.time_and_attendance_yyyymm = res.time_and_attendance_yyyymm
        and a.employee_no                = res.employee_no
        and a.shift_type_code like '3%';
        
        v_level_0 := FLOOR((get_ot_length_level(res.time_and_attendance_yyyymm,'1A','L0') * v_shift_1A + 
                     get_ot_length_level(res.time_and_attendance_yyyymm,'2B','L0') * v_shift_2B +
                     get_ot_length_level(res.time_and_attendance_yyyymm,'3C','L0') * v_shift_3C ) / v_perfect_day);
                   
        v_level_1 := FLOOR((get_ot_length_level(res.time_and_attendance_yyyymm,'1A','L1') * v_shift_1A + 
                     get_ot_length_level(res.time_and_attendance_yyyymm,'2B','L1') * v_shift_2B +
                     get_ot_length_level(res.time_and_attendance_yyyymm,'3C','L1') * v_shift_3C ) / v_perfect_day);
                    
        v_level_2 := FLOOR((get_ot_length_level(res.time_and_attendance_yyyymm,'1A','L2') * v_shift_1A + 
                     get_ot_length_level(res.time_and_attendance_yyyymm,'2B','L2') * v_shift_2B +
                     get_ot_length_level(res.time_and_attendance_yyyymm,'3C','L2') * v_shift_3C ) / v_perfect_day);
                    
        v_level_3 := FLOOR((get_ot_length_level(res.time_and_attendance_yyyymm,'1A','L3') * v_shift_1A + 
                     get_ot_length_level(res.time_and_attendance_yyyymm,'2B','L3') * v_shift_2B +
                     get_ot_length_level(res.time_and_attendance_yyyymm,'3C','L3') * v_shift_3C ) / v_perfect_day);

        -- OT 상세 계산을 위해서 호출되므로, last 컬럼은 변경하지 않음
        UPDATE tb_att_ot_level_info_n
        SET   apply_flag                   = p_apply_flag
              ,level_0                     = v_level_0
              ,level_1                     = v_level_1
              ,level_2                     = v_level_2
              ,level_3                     = v_level_3
              ,level_4                     = v_level_4       
        WHERE  subsidiary_code             = v_subsidiary_code
        AND    apply_flag                  = 'T'
        AND    employee_no                 = res.employee_no
        AND    time_and_attendance_yyyymm  = res.time_and_attendance_yyyymm         
        ;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN

    dbms_output.put_line (SQLERRM);

    p_ret_code := '-1';
    p_ret_msg  := TO_CHAR(SQLCODE);
    
END apply_att_ot_level_calc;


FUNCTION get_ot_length_level(p_atendance_yyyymm IN  VARCHAR2,
                             p_shift_code       IN  VARCHAR2,
                             p_level            IN  VARCHAR2)
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_ot_length_level
/* Description  : Return value
/*               
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/04/06                       Initialized
/*
/******************************************************************************/
RETURN NUMBER
IS
    x_return_value NUMBER := 0;

BEGIN

    select t.upper_limit into x_return_value 
    from tb_att_ot_level t
    where t.time_and_attendance_yyyymm = p_atendance_yyyymm
      and t.shift_type_code            = p_shift_code
      and t.ot_level                   = p_level;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN x_return_value;

END get_ot_length_level;

FUNCTION get_ot_level(p_subsidiary_code         IN VARCHAR2,
                       p_employee_no            IN VARCHAR2,
                       p_attendance_yyyymm      IN VARCHAR2,
                       p_get_type               IN VARCHAR2
                        )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_ot_level
/* Description  : Return value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/26  HMT_20210326        Add get_ot_level function  
/*
/******************************************************************************/
RETURN VARCHAR2
IS

    v_return_value    VARCHAR2(10) := '';
    v_ot_level        VARCHAR2(10) := '';
    v_level_requested VARCHAR2(10) := '';
    v_level_approval  VARCHAR2(10) := '';
    v_next_level      VARCHAR2(10) := '';
    v_level_0         NUMBER :=0;
    v_level_1         NUMBER :=0;
    v_level_2         NUMBER :=0;
    v_level_3         NUMBER :=0;
    v_level_4         VARCHAR2(40) := '';
    v_lower_limit            NUMBER :=0;
    v_upper_limit            NUMBER :=0;
    v_month_ot_total         NUMBER :=0;

BEGIN
    --Get the Level's Requested, In-progress or Approved
    SELECT NVL(MAX(ol.ot_level), 'L0') INTO v_level_requested
      FROM tb_att_ot_level_request_n ol
     WHERE ol.employee_no = p_employee_no
     AND   ol.time_and_attendance_yyyymm = p_attendance_yyyymm
     AND   ol.progress_status_code IN ('20', '30', '40');
     --Get the Level's Approved
     SELECT NVL(MAX(ol.ot_level), 'L0') INTO v_level_approval
      FROM tb_att_ot_level_request_n ol
     WHERE ol.employee_no = p_employee_no
     AND   ol.time_and_attendance_yyyymm = p_attendance_yyyymm
     AND   ol.progress_status_code = '40';
     --Get next level
     select 'L'||TO_CHAR(DECODE((substr(v_level_requested, 2)+1),5,4,substr(v_level_requested, 2)+1)) INTO v_next_level from dual;
 
    SELECT  ti.level_0, ti.level_1,   ti.level_2, ti.level_3, ti.level_4 
     INTO   v_level_0,  v_level_1,    v_level_2,  v_level_3,  v_level_4
		    FROM tb_att_ot_level_info_n ti 
		    WHERE ti.subsidiary_code = p_subsidiary_code 
          AND ti.time_and_attendance_yyyymm = p_attendance_yyyymm
          AND ti.employee_no = p_employee_no;
          
          IF v_next_level = 'L1' THEN 
              v_lower_limit := v_level_0;
              v_upper_limit := v_level_1;
            
          ELSIF v_next_level = 'L2' THEN 
              v_lower_limit := v_level_1;
              v_upper_limit := v_level_2;
              
              ELSIF v_next_level = 'L3' THEN 
              v_lower_limit := v_level_2;
              v_upper_limit := v_level_3;
              
              ELSIF v_next_level = 'L4' THEN 
              v_lower_limit := v_level_3;
              v_upper_limit := '';
            END IF;
        
        IF p_get_type = 'request_next_ot_level' THEN v_return_value := v_next_level; 
           ELSIF p_get_type = 'level_requested' THEN v_return_value := v_level_requested;
           ELSIF p_get_type = 'request_lower_limit' THEN v_return_value := TO_CHAR(v_lower_limit);
           ELSIF p_get_type = 'request_upper_limit' THEN v_return_value := TO_CHAR(v_upper_limit);
           ELSIF p_get_type = 'level_actual' THEN 
             v_month_ot_total := lgvatt_ot_calculation_pkg.get_ot_total('LGDVN', p_employee_no, 
                                        TO_DATE(p_attendance_yyyymm, 'YYYYMM'), TO_DATE(p_attendance_yyyymm, 'YYYYMM'),'month_total_ot_yyyymm');
             IF v_month_ot_total <= v_level_0 THEN v_return_value := 'L0'; END IF;
             IF v_month_ot_total > v_level_0  THEN v_return_value := 'L1'; END IF;
             IF v_month_ot_total > v_level_1  THEN v_return_value := 'L2'; END IF;
             IF v_month_ot_total > v_level_2  THEN v_return_value := 'L3'; END IF;
             IF v_month_ot_total > v_level_3  THEN v_return_value := 'L4'; END IF;
             
        END IF;
         
    
    RETURN v_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN v_return_value;

END get_ot_level;


END lgvatt_ot_level_pkg;
/**********************************************************/
/* End of Program
/**********************************************************/
/
