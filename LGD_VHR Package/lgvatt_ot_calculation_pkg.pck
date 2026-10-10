CREATE OR REPLACE PACKAGE lgvatt_ot_calculation_pkg
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       : 
/* Program Name : lgvatt_ot_calculation_pkg_s.pls
/* Description  : Ot Calculation Package
/*
/*               
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date         In Charge           Description
/*------------------------------------------------------------------------------
/*  02-OCT-2017                       Initialized
/*  2021/03/17  HMT_20210317          Change start time of caculate ot (add week code)
/*
/******************************************************************************/
/******************************************************************************/
AS

TYPE ARRAY_CHAR IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE ARRAY_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

C_MAX_ARRAY NUMBER := 9;

C_OT150 NUMBER := 1;
C_OT200 NUMBER := 2;
C_OT300 NUMBER := 3;
C_NT200 NUMBER := 4;
C_NT210 NUMBER := 5;
C_NT270 NUMBER := 6;
C_NT390 NUMBER := 7;
C_NT30  NUMBER := 8;
C_HP    NUMBER := 9;

C_DAY_WORKING_START_HOUR NUMBER := 8;
C_WORKING_HOUR           NUMBER := 9;
C_3SHIFT_WORKING_HOUR    NUMBER := 10.5;

FUNCTION calculate_ot_test(p_subsidiary_code    IN VARCHAR2,
                           p_date               IN DATE,
                           p_att_code           IN VARCHAR2,
                           p_shift_code         IN VARCHAR2,
                           p_night_flag         IN VARCHAR2,
                           p_dinner_check       IN VARCHAR2,
                           p_working_start_time IN VARCHAR2,
                           p_ot                 IN NUMBER
                          )
RETURN VARCHAR2;

   
PROCEDURE main(p_subsidiary_code    IN  VARCHAR2,
               p_date               IN  DATE,
               p_att_code           IN  VARCHAR2,
               p_shift_code         IN  VARCHAR2,
               p_night_flag         IN  VARCHAR2,
               p_dinner_check       IN  VARCHAR2,
               p_working_start_time IN  VARCHAR2,
               p_ot                 IN  NUMBER,
               p_ot150              OUT NUMBER,
               p_ot200              OUT NUMBER,
               p_ot300              OUT NUMBER,
               p_nt200              OUT NUMBER,
               p_nt210              OUT NUMBER,
               p_nt270              OUT NUMBER,
               p_nt390              OUT NUMBER,
               p_nt30               OUT NUMBER,
               p_ret_code           OUT NUMBER,
               p_ret_message        OUT VARCHAR2
              );
   

PROCEDURE calculate_ot(p_subsidiary_code    IN  VARCHAR2,
                       p_employee_no         IN  VARCHAR2 DEFAULT NULL, --HMT_20210717
                       p_date               IN  DATE,
                       p_att_code           IN  VARCHAR2,
                       p_shift_code         IN  VARCHAR2,
                       p_night_flag         IN  VARCHAR2,
                       p_dinner_check       IN  VARCHAR2,
                       p_working_start_time IN  VARCHAR2,
                       p_lateness           IN  NUMBER DEFAULT 0,
                       p_leaving_early      IN  NUMBER DEFAULT 0,
                       p_going_out          IN  NUMBER DEFAULT 0,
                       p_ot                 IN  NUMBER,
                       p_ot150              OUT NUMBER,
                       p_ot200              OUT NUMBER,
                       p_ot300              OUT NUMBER,
                       p_nt200              OUT NUMBER,
                       p_nt210              OUT NUMBER,
                       p_nt270              OUT NUMBER,
                       p_nt390              OUT NUMBER,
                       p_nt30               OUT NUMBER,
                       p_status             OUT VARCHAR2
                      );

PROCEDURE set_1_shift_ot(p_work_start_hour IN  NUMBER,
                         p_start_hour      IN  NUMBER,
                         p_over_time       IN  NUMBER,
                         p_today_type      IN  VARCHAR2,
                         p_week_code       IN  VARCHAR2, --2021/03/17  HMT_20210317
                         p_tomorrow_type   IN  VARCHAR2,
                         p_dinner_check    IN  VARCHAR2,
                         p_shift_code      IN  VARCHAR2 DEFAULT NULL, -- HMT_NEW: phuc vu ngoai le shift 1A + start<18:00
                         p_array_ot        OUT ARRAY_NUM
                        );
                           
                        
PROCEDURE set_2_day_shift_ot(p_work_start_hour IN  NUMBER,
                             p_start_hour      IN  NUMBER,
                             p_over_time       IN  NUMBER,
                             p_today_type      IN  VARCHAR2,
                             p_week_code       IN  VARCHAR2, --2021/03/17  HMT_20210317
                             p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                             p_array_ot        OUT ARRAY_NUM
                            );


PROCEDURE set_2_night_shift_ot(p_work_start_hour IN  NUMBER,
                               p_start_hour      IN  NUMBER,
                               p_over_time       IN  NUMBER,
                               p_lateness        IN  NUMBER DEFAULT 0,
                               p_leaving_early   IN  NUMBER DEFAULT 0,
                               p_going_out       IN  NUMBER DEFAULT 0,
                               p_today_type      IN  VARCHAR2,
                               p_week_code       IN  VARCHAR2, --2021/03/17  HMT_20210317
                               p_att_code        IN  VARCHAR2,
                               p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              );
                              
PROCEDURE set_10_day_shift_ot(p_work_start_hour IN  NUMBER,
                             p_start_hour      IN  NUMBER,
                             p_over_time       IN  NUMBER,
                             p_today_type      IN  VARCHAR2,
                             p_week_code       IN  VARCHAR2, --2021/03/17  HMT_20210317
                             p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                             p_array_ot        OUT ARRAY_NUM
                            );


PROCEDURE set_10_night_shift_ot(p_work_start_hour IN  NUMBER,
                               p_start_hour      IN  NUMBER,
                               p_over_time       IN  NUMBER,
                               p_lateness        IN  NUMBER DEFAULT 0,
                               p_leaving_early   IN  NUMBER DEFAULT 0,
                               p_going_out       IN  NUMBER DEFAULT 0,
                               p_today_type      IN  VARCHAR2,
                               p_week_code       IN  VARCHAR2, --2021/03/17  HMT_20210317
                               p_att_code        IN  VARCHAR2,
                               p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              );

PROCEDURE set_3_day_shift_ot(p_work_start_hour IN  NUMBER,
                             p_start_hour      IN  NUMBER,
                             p_over_time       IN  NUMBER,
                             p_today_type      IN  VARCHAR2,
                             p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                             p_array_ot        OUT ARRAY_NUM
                            );

PROCEDURE set_3_night_shift_ot(p_work_start_hour IN  NUMBER,
                               p_start_hour      IN  NUMBER,
                               p_over_time       IN  NUMBER,
                               p_lateness        IN  NUMBER DEFAULT 0,
                               p_leaving_early   IN  NUMBER DEFAULT 0,
                               p_going_out       IN  NUMBER DEFAULT 0,
                               p_today_type      IN  VARCHAR2,
                               p_att_code        IN  VARCHAR2,
                               p_tomorrow_type   IN  VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              );

FUNCTION get_holiday(p_subsidiary_code IN  VARCHAR2,
                     p_employee_no     IN  VARCHAR2 DEFAULT NULL, --HMT_20210717
                     p_shift_code      IN  VARCHAR2,
                     p_date            IN  DATE
                    ) 
RETURN VARCHAR2;


FUNCTION get_shift_code_info(p_subsidiary_code IN  VARCHAR2,
                             p_shift_code      IN  VARCHAR2,
                             p_info_num        IN  NUMBER DEFAULT 1
                            )
RETURN VARCHAR2;


FUNCTION get_night_check(p_subsidiary_code IN  VARCHAR2,
                         p_date            IN  DATE,
                         p_shfit_code      IN  VARCHAR2
                        )
RETURN VARCHAR2;

--HMT_20210317 Add get_date_type function
FUNCTION get_date_type(p_subsidiary_code   IN  VARCHAR2,
                       p_employee_no       IN  VARCHAR2 DEFAULT NULL,
                       p_shift_code        IN  VARCHAR2,
                       p_date              IN  DATE,
                       p_get_type          IN  VARCHAR2
                        )
RETURN VARCHAR2;

--HMT_20210326 Add get_ot_total function
FUNCTION get_ot_total(p_subsidiary_code    IN  VARCHAR2,
                      p_employee_no        IN  VARCHAR2,
                      p_start_date         IN  DATE,
                      p_end_date           IN  DATE,
                      p_get_type           IN  VARCHAR2
                        )
RETURN NUMBER;

--HMT_20210413 Add get_item_ot_total function
FUNCTION get_item_ot_total(p_subsidiary_code    IN  VARCHAR2,
                           p_employee_no        IN  VARCHAR2,
                           p_start_date         IN  DATE,
                           p_end_date           IN  DATE,
                           p_item               IN  VARCHAR2,
                           p_get_type           IN  VARCHAR2
                            )
RETURN NUMBER;

--HMT_20210326 Add get_over_year_ot function
FUNCTION get_over_year_ot_hours(p_subsidiary_code    IN  VARCHAR2,
                                p_employee_no        IN  VARCHAR2,
                                p_date               IN  DATE,
                                p_item               IN  VARCHAR2,
                                p_get_type           IN  VARCHAR2
                                  )
RETURN NUMBER;

--HMT_20260601 Add get_over_month_ot function
FUNCTION get_over_month_ot_hours(p_subsidiary_code    IN  VARCHAR2,
                                p_employee_no        IN  VARCHAR2,
                                p_date               IN  DATE,
                                p_item               IN  VARCHAR2,
                                p_get_type           IN  VARCHAR2
                                  )
RETURN NUMBER;

--HMT_20210326 get_conv_ot_hour Add function 
FUNCTION get_conv_ot_hour(p_ot_hour IN  NUMBER)                         
RETURN NUMBER;

FUNCTION get_conv_hour(p_text_hour IN  VARCHAR2)                         
RETURN NUMBER;


PROCEDURE validate_calculation(p_ret_code           OUT NUMBER,
                               p_ret_message        OUT VARCHAR2,
                               p_subsidiary_code    IN  VARCHAR2,
                               p_date               IN  DATE,
                               p_shift_code         IN  VARCHAR2,
                               p_night_flag         IN  VARCHAR2,
                               p_dinner_check       IN  VARCHAR2,
                               p_working_start_time IN VARCHAR2,
                               p_ot                 IN NUMBER
                              );


PROCEDURE put_ot_validation (p_work_type          IN VARCHAR2,
                             p_employee_no        IN VARCHAR2,
                             p_subsidiary_code    IN VARCHAR2,
                             p_date               IN DATE,
                             p_att_code           IN VARCHAR2,
                             p_shift_code         IN VARCHAR2,
                             p_night_flag         IN VARCHAR2,
                             p_dinner_check       IN VARCHAR2,
                             p_working_start_time IN VARCHAR2,
                             p_lateness           IN NUMBER,
                             p_leaving_early      IN NUMBER,
                             p_going_out          IN NUMBER,
                             p_ot                 IN NUMBER,
                             p_ot150              IN NUMBER,
                             p_ot200              IN NUMBER,
                             p_ot300              IN NUMBER,
                             p_nt200              IN NUMBER,
                             p_nt210              IN NUMBER,
                             p_nt270              IN NUMBER,
                             p_nt390              IN NUMBER,
                             p_nt30               IN NUMBER
                            );


END lgvatt_ot_calculation_pkg;
/**********************************************************/
/* End of Program
/**********************************************************/
/
CREATE OR REPLACE PACKAGE BODY lgvatt_ot_calculation_pkg
/******************************************************************************/
/*VHR_MGR !dlatl00  2017-11-16 09:58
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : lgvatt_ot_calculation_pkg_b.pls
/* Description  : Ot Calculation Package
/*
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date         In Charge           Description
/*------------------------------------------------------------------------------
/*  02-OCT-2017                       Initialized
/*  2021/03/17  HMT_20210317          Change start time of caculate ot
/*  2021/07/17  HMT_20210717          Swap weekly holiday (Add p_employee_no)
/*  2021/08/27  HMT_20210827          If have dinner check, -0.5h OT
/*  2022/02/28  HMT_20220228          Fix Dinner_check with 1A, 1A with start_time = 20:00 not like 21-22AB
/*  2022/07/05  HMT_20220705          Fix night working with shift type = 1A
/*  2026/08/01  HMT_20260801          Add a condition to calculate overtime when the following day is a public holiday, 
                                     and include cases where the Total Overtime value is not equal to 0.5.
/******************************************************************************/
AS

-- SQL ?? ?? ??? ?? ??
FUNCTION calculate_ot_test(p_subsidiary_code    IN VARCHAR2
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
    calculate_ot(p_subsidiary_code    => p_subsidiary_code
                ,p_employee_no        => NULL --HMT_20210717
                ,p_date               => p_date
                ,p_att_code           => p_att_code
                ,p_shift_code         => p_shift_code
                ,p_night_flag         => p_night_flag
                ,p_dinner_check       => p_dinner_check
                ,p_working_start_time => p_working_start_time
                ,p_ot                 => p_ot
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

END calculate_ot_test;


PROCEDURE main(p_subsidiary_code    IN VARCHAR2,
               p_date               IN DATE,
               p_att_code           IN VARCHAR2,
               p_shift_code         IN VARCHAR2,
               p_night_flag         IN VARCHAR2,
               p_dinner_check       IN VARCHAR2,
               p_working_start_time IN VARCHAR2,
               p_ot                 IN NUMBER,
               p_ot150              OUT NUMBER,
               p_ot200              OUT NUMBER,
               p_ot300              OUT NUMBER,
               p_nt200              OUT NUMBER,
               p_nt210              OUT NUMBER,
               p_nt270              OUT NUMBER,
               p_nt390              OUT NUMBER,
               p_nt30               OUT NUMBER,
               p_ret_code           OUT NUMBER,
               p_ret_message        OUT VARCHAR2
              )
IS

    v_ot150              NUMBER;
    v_ot200              NUMBER;
    v_ot300              NUMBER;
    v_nt200              NUMBER;
    v_nt210              NUMBER;
    v_nt270              NUMBER;
    v_nt390              NUMBER;
    v_nt30               NUMBER;
    v_status             VARCHAR2(1000);
    x_ret_code           NUMBER ;
    x_ret_message        VARCHAR2(1000);

BEGIN

  -- Input Parameer Check


  validate_calculation(p_ret_code           => x_ret_code,
                       p_ret_message        => x_ret_message,
                       p_subsidiary_code    => p_subsidiary_code,
                       p_date               => p_date  ,
                       p_shift_code         => p_shift_code,
                       p_night_flag         => p_night_flag,
                       p_dinner_check       => p_dinner_check,
                       p_working_start_time => p_working_start_time,
                       p_ot                 => p_ot);

    -- x_ret_code ? ??? ?? return?? ?? ??? ??
    IF x_ret_code <> 0 THEN

      p_ret_code    := x_ret_code ;
      p_ret_message := x_ret_message ;
      RETURN  ;

    ELSE
      p_ret_code    := x_ret_code ;
      p_ret_message := '' ;

    END IF ;

    calculate_ot(p_subsidiary_code    => p_subsidiary_code
                ,p_employee_no        => NULL --HMT_20210717
                ,p_date               => p_date
                ,p_att_code           => p_att_code
                ,p_shift_code         => p_shift_code
                ,p_night_flag         => p_night_flag
                ,p_dinner_check       => p_dinner_check
                ,p_working_start_time => p_working_start_time
                ,p_ot                 => p_ot
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

         -- ???? OT Calcuation ??
         p_ot150 := v_ot150 ;
         p_ot200 := v_ot200 ;
         p_ot300 := v_ot300 ;
         p_nt200 := v_nt200 ;
         p_nt210 := v_nt210 ;
         p_nt270 := v_nt270 ;
         p_nt390 := v_nt390 ;
         p_nt30  := v_nt30  ;




EXCEPTION
WHEN OTHERS THEN
     p_ret_code := 1 ;
     p_ret_message  := TO_CHAR(SQLCODE);

END main;



PROCEDURE calculate_ot(p_subsidiary_code    IN VARCHAR2,
                       p_employee_no        IN VARCHAR2 DEFAULT NULL, --HMT_20210717
                       p_date               IN DATE,
                       p_att_code           IN VARCHAR2,
                       p_shift_code         IN VARCHAR2,
                       p_night_flag         IN VARCHAR2,
                       p_dinner_check       IN VARCHAR2,
                       p_working_start_time IN VARCHAR2,
                       p_lateness           IN NUMBER DEFAULT 0,
                       p_leaving_early      IN NUMBER DEFAULT 0,
                       p_going_out          IN NUMBER DEFAULT 0,
                       p_ot                 IN NUMBER,
                       p_ot150              OUT NUMBER,
                       p_ot200              OUT NUMBER,
                       p_ot300              OUT NUMBER,
                       p_nt200              OUT NUMBER,
                       p_nt210              OUT NUMBER,
                       p_nt270              OUT NUMBER,
                       p_nt390              OUT NUMBER,
                       p_nt30               OUT NUMBER,
                       p_status             OUT VARCHAR2
                      )
IS
    a_over_time           ARRAY_NUM;

    x_today_type          VARCHAR2(10);
    x_tomorrow_type       VARCHAR2(10);
    x_night_flag          VARCHAR2(10);
    x_week_code           VARCHAR2(10); --2021/03/17  HMT_20210317

    x_shift_cycle         NUMBER;
    x_start_hour          NUMBER;
    x_working_start_hour  NUMBER;

BEGIN

    -- Validation
    put_ot_validation (p_work_type          => 'pkgStartCalcOT',
                       p_employee_no        => NULL,
                       p_subsidiary_code    => p_subsidiary_code,
                       p_date               => p_date,
                       p_att_code           => p_att_code,
                       p_shift_code         => p_shift_code,
                       p_night_flag         => p_night_flag,
                       p_dinner_check       => p_dinner_check,
                       p_working_start_time => p_working_start_time,
                       p_lateness           => p_lateness,
                       p_leaving_early      => p_leaving_early,
                       p_going_out          => p_going_out,
                       p_ot                 => p_ot,
                       p_ot150              => p_ot150,
                       p_ot200              => p_ot200,
                       p_ot300              => p_ot300,
                       p_nt200              => p_nt200,
                       p_nt210              => p_nt210,
                       p_nt270              => p_nt270,
                       p_nt390              => p_nt390,
                       p_nt30               => p_nt30
                      );

    x_night_flag := get_night_check(p_subsidiary_code, p_date, p_shift_code);

    IF NVL(p_night_flag, x_night_flag) = 'N' THEN
        x_night_flag := 'N';
    ELSIF NVL(p_night_flag, x_night_flag) = 'Y' THEN
        x_night_flag := 'Y'; -- 'NIGHT';
    END IF;

    -- Night, Day ?? ??? ?????? ?? ? ???? ?? ??
    
    IF p_working_start_time < '06:00' AND p_att_code IN ('WH', 'PH') THEN -- NVS_20230811 Fix error
      x_night_flag := 'N';
    END IF;

    IF  p_working_start_time >= '18:00' AND p_working_start_time < '24:00'
        AND p_shift_code <> '1A' THEN --HMT_20220228 Add p_shift_code <> '1A'
                                        --HMT_20260801 FIX: doi tu so khop tuyet doi '20:00' sang khoang gio toi
                                        --(18:00-23:59) de khong bo sot cac gio vao ca le nhu 19:30, 20:30...
       x_night_flag := 'Y';
    END IF;
    
    IF  p_working_start_time >= '18:00' AND p_working_start_time < '24:00'
        AND p_shift_code = '1A' AND p_att_code NOT IN ('WH','PH') THEN --HMT_20220705 Add p_shift_code = '1A'
                                        --HMT_20260801 FIX: doi tu so khop tuyet doi '20:00' sang khoang gio toi
       x_night_flag := 'Y';
    END IF;

    IF  p_working_start_time = '08:00' THEN
       x_night_flag := 'N';
    END IF ;

    IF (NVL(p_ot, 0) <= 0) AND (x_night_flag = 'N') THEN  --Day
        p_ot150 := 0;
        p_ot200 := 0;
        p_ot300 := 0;
        p_nt200 := 0;
        p_nt210 := 0;
        p_nt270 := 0;
        p_nt390 := 0;
        p_nt30  := 0;

        IF p_night_flag = 'Y' THEN
           p_status := 'NIGHT';
        ELSE
           p_status := 'DAY';
        END IF;

        RETURN;
    END IF;

    -- initial
    x_today_type := get_holiday(p_subsidiary_code, p_employee_no, p_shift_code, p_date); --HMT_20210717

    x_tomorrow_type := get_holiday(p_subsidiary_code, p_employee_no, p_shift_code, p_date + 1); --HMT_20210717

    x_shift_cycle := TO_NUMBER(get_shift_code_info(p_subsidiary_code, p_shift_code, 1));

    x_working_start_hour :=  get_conv_hour(p_working_start_time);
    
    --2021/03/17  HMT_20210317 Start
    x_week_code := get_date_type(p_subsidiary_code,p_employee_no,p_shift_code, p_date,'week_code');  
    
    /*Check if the attendance date is before or after the apply date of "All Saturday off". 
    If before the apply date, x_week_code set as 'FRI' --> work end time is 17:00 or 05:00 for all weekday*/
    IF p_date < TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD') THEN 
      x_week_code := 'FRI';
      END IF; --2021/03/17  HMT_20210317 End

    IF x_shift_cycle = 1 THEN
      x_start_hour := get_conv_hour(get_shift_code_info(p_subsidiary_code, p_shift_code, 4));
      x_working_start_hour := NVL(x_working_start_hour, x_start_hour);

      IF x_night_flag = 'Y' THEN

        -- 2017.12.06 : 1-Shift???  Night??? ??  ????? ???? ??? Working Start Time?? ??
        x_start_hour := get_conv_hour(p_working_start_time) ;
        set_2_night_shift_ot(x_working_start_hour,
                             x_start_hour,
                             NVL(p_ot, 0),
                             p_lateness,
                             p_leaving_early,
                             p_going_out,
                             x_today_type,
                             x_week_code, --2021/03/17  HMT_20210317
                             p_att_code,
                             x_tomorrow_type, -- HMT_20260801
                             a_over_time);
      ELSE
        set_1_shift_ot(x_working_start_hour,
                       x_start_hour,
                       NVL(p_ot, 0),
                       x_today_type,
                       x_week_code, --2021/03/17  HMT_20210317
                       x_tomorrow_type,
                       p_dinner_check,
                       p_shift_code, -- HMT_NEW: phuc vu ngoai le shift 1A + start<18:00
                       a_over_time);
      END IF;

    ELSE

      IF x_night_flag = 'N' THEN   --Day
        x_start_hour := get_conv_hour(get_shift_code_info(p_subsidiary_code, p_shift_code, 4));
      ELSE
        x_start_hour := get_conv_hour(get_shift_code_info(p_subsidiary_code, p_shift_code, 5));
      END IF;

      x_working_start_hour := NVL(x_working_start_hour, x_start_hour);

      IF x_night_flag = 'N' THEN  --Day
        --< Start 2023.03.09 : 2S10G Shift condition add
        IF x_shift_cycle = 6 THEN
          set_3_day_shift_ot(x_working_start_hour,
                           x_start_hour,
                           NVL(p_ot, 0),
                           x_today_type,
                           x_tomorrow_type, -- HMT_20260801
                           a_over_time);
        --< Start 2023.03.09 : 2S10G Shift condition add
        ELSIF x_shift_cycle = 5 THEN
          set_10_day_shift_ot(x_working_start_hour,
                           x_start_hour,
                           NVL(p_ot, 0),
                           x_today_type,
                           x_week_code, --2021/03/17  HMT_20210317
                           x_tomorrow_type, -- HMT_20260801
                           a_over_time);
          
        ELSE
          set_2_day_shift_ot(x_working_start_hour,
                             x_start_hour,
                             NVL(p_ot, 0),
                             x_today_type,
                             x_week_code, --2021/03/17  HMT_20210317
                             x_tomorrow_type, -- HMT_20260801
                             a_over_time);
        END IF;
      ELSE
        --< Start 2023.03.09 : 2S10G Shift condition add
        IF x_shift_cycle = 6  THEN
          set_3_night_shift_ot(x_working_start_hour,
                               x_start_hour,
                               NVL(p_ot, 0),
                               p_lateness,
                               p_leaving_early,
                               p_going_out,
                               x_today_type,
                               p_att_code,
                               x_tomorrow_type, -- HMT_20260801
                               a_over_time);
                               
        --< Start 2023.03.09 : 2S10G Shift condition add                       
        ELSIF x_shift_cycle = 5  THEN
          set_10_night_shift_ot(x_working_start_hour,
                               x_start_hour,
                               NVL(p_ot, 0),
                               p_lateness,
                               p_leaving_early,
                               p_going_out,
                               x_today_type,
                               x_week_code, --2021/03/17  HMT_20210317
                               p_att_code,
                               x_tomorrow_type, -- HMT_20260801
                               a_over_time);
        ELSE
          set_2_night_shift_ot(x_working_start_hour,
                               x_start_hour,
                               NVL(p_ot, 0),
                               p_lateness,
                               p_leaving_early,
                               p_going_out,
                               x_today_type,
                               x_week_code, --2021/03/17  HMT_20210317
                               p_att_code,
                               x_tomorrow_type, -- HMT_20260801
                               a_over_time);
        END IF;
      END IF;

    END IF;

    p_ot150 := a_over_time(C_OT150);
    p_ot200 := a_over_time(C_OT200);
    p_ot300 := a_over_time(C_OT300);
    p_nt200 := a_over_time(C_NT200);
    p_nt210 := a_over_time(C_NT210);
    p_nt270 := a_over_time(C_NT270);
    p_nt390 := a_over_time(C_NT390);
    p_nt30  := a_over_time(C_NT30);

    IF x_night_flag = 'Y' THEN
       p_status := 'NIGHT';
    ELSE
       p_status := 'DAY';
    END IF;


    -- Validation
    put_ot_validation (p_work_type          => 'pkgEndCalcOT',
                       p_employee_no        => NULL,
                       p_subsidiary_code    => p_subsidiary_code,
                       p_date               => p_date,
                       p_att_code           => p_att_code,
                       p_shift_code         => p_shift_code,
                       p_night_flag         => p_night_flag,
                       p_dinner_check       => p_dinner_check,
                       p_working_start_time => p_working_start_time,
                       p_lateness           => p_lateness,
                       p_leaving_early      => p_leaving_early,
                       p_going_out          => p_going_out,
                       p_ot                 => p_ot,
                       p_ot150              => p_ot150,
                       p_ot200              => p_ot200,
                       p_ot300              => p_ot300,
                       p_nt200              => p_nt200,
                       p_nt210              => p_nt210,
                       p_nt270              => p_nt270,
                       p_nt390              => p_nt390,
                       p_nt30               => p_nt30
                      );


EXCEPTION
WHEN OTHERS THEN
    p_status := 'error';

    -- Validation
    put_ot_validation (p_work_type          => 'pkgErrorCalcOT',
                       p_employee_no        => SQLCODE,
                       p_subsidiary_code    => p_subsidiary_code,
                       p_date               => p_date,
                       p_att_code           => p_att_code,
                       p_shift_code         => p_shift_code,
                       p_night_flag         => p_night_flag,
                       p_dinner_check       => p_dinner_check,
                       p_working_start_time => p_working_start_time,
                       p_lateness           => p_lateness,
                       p_leaving_early      => p_leaving_early,
                       p_going_out          => p_going_out,
                       p_ot                 => p_ot,
                       p_ot150              => p_ot150,
                       p_ot200              => p_ot200,
                       p_ot300              => p_ot300,
                       p_nt200              => p_nt200,
                       p_nt210              => p_nt210,
                       p_nt270              => p_nt270,
                       p_nt390              => p_nt390,
                       p_nt30               => p_nt30
                      );

END calculate_ot;


PROCEDURE set_1_shift_ot(p_work_start_hour IN NUMBER,
                         p_start_hour      IN NUMBER,
                         p_over_time       IN NUMBER,
                         p_today_type      IN VARCHAR2,
                         p_week_code       IN VARCHAR2, --2021/03/17  HMT_20210317
                         p_tomorrow_type   IN VARCHAR2,
                         p_dinner_check    IN VARCHAR2,
                         p_shift_code      IN VARCHAR2 DEFAULT NULL, -- HMT_NEW: phuc vu ngoai le shift 1A + start<18:00
                         p_array_ot        OUT ARRAY_NUM
                        )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_1_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/* 2025/11/09    HMT_20251109        Flexible Working Time function improvement
/******************************************************************************/
IS
    x_ot_start_hour number;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  number;
    jj_step         NUMBER;
    x_lunch_time_flag VARCHAR2(01);
    x_loop_start_hour NUMBER;  -- HMT_20251109 Add

BEGIN

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      --< Start HMT_20210317 : Change start time of caculate ot
      IF p_week_code = 'FRI' THEN
        x_ot_start_hour := p_work_start_hour + C_WORKING_HOUR; --HMT_20251109 replace p_start_hour with p_work_start_hour
        ELSE x_ot_start_hour := p_work_start_hour + C_WORKING_HOUR + 1; --HMT_20251109 replace p_start_hour with p_work_start_hour
      END IF;
      --> End
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 12 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_lunch_time_flag := 'Y';
      ELSE
        x_lunch_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_lunch_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_NEW: cong bu +1h khi khung 00:00-01:00 bi loai tru khoi tinh toan.
    -- Ap dung cho: hom nay=PH, hoac ngay mai=PH, hoac (shift 1A + start<18h + hom nay KHAC NW).
    -- Rieng shift 1A + start<18h + hom nay=NW: KHONG loai tru gio nao (chuyen ngay tu 00:00),
    -- nen KHONG can cong bu.
    IF (p_today_type = 'PH'
        OR p_tomorrow_type = 'PH'
        OR (p_shift_code = '1A' AND p_work_start_hour < 18 AND p_today_type <> 'NW'))
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24 THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    --sangnv
    jj_step := x_ot_start_hour;
    IF jj_step < 6 then
      jj_step := jj_step + 24;
    END IF;
      
    IF jj_step >= 46 THEN
      jj_step := jj_step - 24;
    END IF;  
    --end
    IF jj_step - TRUNC(jj_step, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF (TRUNC(jj_step, 0) = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';
      ELSIF TRUNC(jj_step, 0) < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 30 THEN
        IF p_shift_code = '1A' AND p_today_type = 'NW' AND p_work_start_hour < 18 THEN
          -- Ngoai le: shift 1A + hom nay NW + start<18h -> chuyen sang ngay mai NGAY TU 00:00,
          -- KHONG loai tru 00:00-01:00
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSIF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN -- HMT_20260801_v3: hom nay la PH (hoac shift 1A + start<18h) -> tu 01:00 chuyen theo NGAY MAI
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF p_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF p_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 32 THEN
        IF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 46 THEN
        IF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;
      
dbms_output.put_line('jj_step : ' || jj_step || ', x_apply_mid_ot : ' || x_apply_mid_ot);
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    -- HMT_20251109 Start, New logic to determine loop start
    x_loop_start_hour := TRUNC(x_ot_start_hour);
    -- If the start hour is odd (e.g. 17.5), the loop will start at 18
    IF (x_ot_start_hour - TRUNC(x_ot_start_hour) = 0.5) THEN
        x_loop_start_hour := TRUNC(x_ot_start_hour) + 1;
    END IF;
    -- Main loop now uses new variable
    FOR jj IN x_loop_start_hour .. TRUNC(x_ot_end_hour) LOOP
      --HMT_20251109 End
       -- SANGNV
      jj_step := jj;
      IF jj_step < 6 then
        jj_step := jj_step + 24;
      END IF;
      
      IF jj_step >= 46 THEN
        jj_step := jj_step - 24;
      END IF;  
    -- END SANGNV
    
      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj_step : ' || jj_step || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF (x_ot_start_hour < 12 AND jj = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';
      ELSIF jj_step < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;
      ELSIF jj_step < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;
      ELSIF jj_step < 30 THEN
        IF p_shift_code = '1A' AND p_today_type = 'NW' AND p_work_start_hour < 18 THEN
          -- Ngoai le: shift 1A + hom nay NW + start<18h -> chuyen sang ngay mai NGAY TU 00:00,
          -- KHONG loai tru 00:00-01:00
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSIF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN -- HMT_20260801_v3: hom nay la PH (hoac shift 1A + start<18h) -> tu 01:00 chuyen theo NGAY MAI
          IF jj_step < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF p_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF p_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF jj_step < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 32 THEN
        IF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 46 THEN
        IF p_today_type = 'PH' OR (p_shift_code = '1A' AND p_work_start_hour < 18) THEN
          IF p_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF p_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;

    END LOOP;

    IF (p_today_type = 'NW' AND NVL(p_dinner_check, 'N') = 'Y') THEN 
      p_array_ot(C_OT150) := p_array_ot(C_OT150) - 0.5;
      --HMT_20210827 Start
    ELSIF (p_today_type = 'WH' AND NVL(p_dinner_check, 'N') = 'Y') AND p_array_ot(C_OT200) >= 0.5 THEN -- HMT_20220228 Add p_array_ot(C_OT200) >= 0.5
      p_array_ot(C_OT200) := p_array_ot(C_OT200) - 0.5;
    ELSIF (p_today_type = 'PH' AND NVL(p_dinner_check, 'N') = 'Y') AND p_array_ot(C_OT300) >= 0.5 THEN -- HMT_20220228 Add p_array_ot(C_OT300) >= 0.5
      p_array_ot(C_OT300) := p_array_ot(C_OT300) - 0.5;
      --HMT_20210827 End
    END IF;

END set_1_shift_ot;


PROCEDURE set_2_day_shift_ot(p_work_start_hour IN NUMBER,
                             p_start_hour      IN NUMBER,
                             p_over_time       IN NUMBER,
                             p_today_type      IN VARCHAR2,
                             p_week_code       IN VARCHAR2, --2021/03/17  HMT_20210317
                             p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                             p_array_ot        OUT ARRAY_NUM
                            )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_2_day_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
IS
    x_ot_start_hour number;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  number;
    jj_step         NUMBER;

    x_lunch_time_flag  VARCHAR2(01);
    x_night_time_flag VARCHAR2(01);

    x_tomorrow_type    VARCHAR2(10);
BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      --< Start  HMT_20210317 : Change start time of caculate ot
      IF p_week_code = 'FRI' THEN
        x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
        ELSE x_ot_start_hour := p_start_hour + C_WORKING_HOUR + 1;
      END IF;
      --> End
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 12 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_lunch_time_flag := 'Y';
      ELSE
        x_lunch_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_lunch_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24 THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    --sangnv
    jj_step := x_ot_start_hour;
    IF jj_step < 6 then
      jj_step := jj_step + 24;
    END IF;
      
    IF jj_step >= 46 THEN
      jj_step := jj_step - 24;
    END IF;  
    --end
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    IF jj_step - TRUNC(jj_step, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF (TRUNC(jj_step, 0) = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';
      ELSIF TRUNC(jj_step, 0) < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;
dbms_output.put_line('jj : ' || jj_step || ', x_apply_mid_ot : ' || x_apply_mid_ot);
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP
      
       -- SANGNV
      jj_step := jj;
      IF jj_step < 6 then
        jj_step := jj_step + 24;
      END IF;
      
      IF jj_step >= 46 THEN
        jj_step := jj_step - 24;
      END IF;  
    -- END SANGNV
    
      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF (x_ot_start_hour < 12 AND jj = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';

      ELSIF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
        x_night_time_flag := 'N';

      ELSIF jj_step < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF jj_step < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF jj_step < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;

    END LOOP;

END set_2_day_shift_ot;


PROCEDURE set_2_night_shift_ot(p_work_start_hour IN NUMBER,
                               p_start_hour      IN NUMBER,
                               p_over_time       IN NUMBER,
                               p_lateness        IN NUMBER DEFAULT 0,
                               p_leaving_early   IN NUMBER DEFAULT 0,
                               p_going_out       IN NUMBER DEFAULT 0,
                               p_today_type      IN VARCHAR2,
                               p_week_code       IN VARCHAR2, --2021/03/17  HMT_20210317
                               p_att_code        IN VARCHAR2,
                               p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_2_night_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
IS
    x_ot_start_hour NUMBER;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  NUMBER;
    x_lateness      NUMBER;
    x_leaving_early NUMBER;
    x_going_out     NUMBER;
    x_cnt30         NUMBER;

    x_night_time_flag VARCHAR2(01);
    x_tomorrow_type   VARCHAR2(10);
    jj_step         NUMBER;
    x_nt30_calc_fg    VARCHAR2(1);

BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
      IF p_week_code = 'FRI' THEN
        x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
        ELSE x_ot_start_hour := p_start_hour + C_WORKING_HOUR + 1;
      END IF;
      --> End
      -- HMT_20260801: neu ngay mai la PH, tinh OT tu 01:00 ngay mai (khong doi theo cong
      -- thuc chuan neu cong thuc do cho ket qua muon hon 01:00)
      IF x_tomorrow_type = 'PH' AND x_ot_start_hour > 25 THEN
        x_ot_start_hour := 25;
      END IF;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 24 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_night_time_flag := 'Y';
      ELSE
        x_night_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_night_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao.
    -- CHI cong bu khi co che nghi-giua-ca (x_night_time_flag='Y') CHUA tu loai tru
    -- gio nay roi (neu khong se bi cong bu 2 LAN cho cung 1 gio -> du 1h).
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24
       AND NVL(x_night_time_flag, 'N') <> 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    IF x_ot_start_hour - TRUNC(x_ot_start_hour, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF p_today_type = 'NW' THEN
        IF TRUNC(x_ot_start_hour, 0) = 29 AND x_tomorrow_type <> 'PH' THEN -- HMT_20260801
          -- AM 5:00
          p_array_ot(C_NT200) := p_array_ot(C_NT200) + x_apply_mid_ot;
        ELSIF TRUNC(x_ot_start_hour, 0) < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (TRUNC(x_ot_start_hour, 0) = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF TRUNC(x_ot_start_hour, 0) < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 24 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 46 THEN
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF;
      
    END IF;
    
    SELECT CASE WHEN attendance_days > 0 AND p_att_code NOT IN ('HL', 'HL_FD')
                THEN 'Y'
                ELSE 'N'
           END AS nt30_calc_fg
    INTO   x_nt30_calc_fg
    FROM   tb_att_code_c
    WHERE  time_and_attendance_code = p_att_code;

    IF x_nt30_calc_fg = 'N' THEN
       p_array_ot(C_NT30) := 0;
    ELSE
      IF (p_att_code = 'HL_FN') THEN
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_week_code = 'FRI' THEN
          x_cnt30 := 4;
          ELSE x_cnt30 := 4.5;
        END IF;
        --> End
        x_lateness := p_lateness;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
      ELSIF (p_att_code = 'HL_SN') THEN
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_week_code = 'FRI' THEN
          x_cnt30 :=2;
          ELSE x_cnt30 := 2.5;
        END IF;
        --> End
        x_leaving_early := p_leaving_early;
        x_going_out := 0;

        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0;
        END IF;
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_going_out > 2 THEN
           x_going_out := p_going_out-2;
        ELSE
           x_going_out := 0;
        END IF;
        --> End
      ELSE
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_week_code = 'FRI' THEN
          x_cnt30 := 6;
          ELSE x_cnt30 := 7;
        END IF;
        --> End
        -- HMT_20260801: neu ngay mai la PH, chi con 2h (22:00-24:00) duoc tinh NT30;
        -- phan con lai (00:00 tro di) da duoc tra o muc PH (NT390/OT300) roi
        IF x_tomorrow_type = 'PH' THEN
          x_cnt30 := 2;
        END IF;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
        
        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0;
        END IF;
        
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_going_out > 2 THEN
           x_going_out := p_going_out-2;
        ELSE
           x_going_out := 0;
        END IF;
        --> End
      END IF;
      
      IF (x_cnt30 - x_lateness - x_leaving_early - x_going_out) < 0 THEN
         p_array_ot(C_NT30) := 0;
      ELSE
         p_array_ot(C_NT30) := x_cnt30 - x_lateness - x_leaving_early - x_going_out;
      END IF;
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP
      
      -- HMT_20260801: FIX - jj_step duoc khai bao nhung truoc gio CHUA duoc gan gia tri
      -- trong vong lap nay, khien moi so sanh "jj_step < 30" luon la NULL (sai),
      -- lam toan bo gio bi don het vao nhanh ELSE (OT300). Bo sung tinh jj_step
      -- giong cac thu tuc ca ngay (set_1/set_2_day/set_10_day/set_3_day).
      jj_step := jj;
      IF jj_step < 6 THEN
        jj_step := jj_step + 24;
      END IF;
      IF jj_step >= 46 THEN
        jj_step := jj_step - 24;
      END IF;


      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF p_today_type = 'NW' THEN
        IF jj = 29 AND x_tomorrow_type <> 'PH' THEN -- HMT_20260801
          -- AM 5:00
          p_array_ot(C_NT200) := p_array_ot(C_NT200) + x_apply_mid_ot;
        ELSIF jj_step < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF jj_step < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF jj < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 24 THEN
          IF p_today_type = 'WH' THEN
          -- 2017.12.06 : ?? Over Time Code ??(C_OT200 -> C_NT270)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF jj < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF jj < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 46 THEN
          -- 2017.12.09 : Night ???? => ???( 20:00 + 24)(???:32)
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF; --IF p_today_type = 'NW' THEN

    END LOOP;

END set_2_night_shift_ot;

PROCEDURE set_10_day_shift_ot(p_work_start_hour IN NUMBER,
                              p_start_hour      IN NUMBER,
                              p_over_time       IN NUMBER,
                              p_today_type      IN VARCHAR2,
                              p_week_code       IN VARCHAR2, --2021/03/17  HMT_20210317
                              p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                              p_array_ot        OUT ARRAY_NUM
                            )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_10_day_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 24-MAY-2023                       Initialized
/*
/******************************************************************************/
IS
    x_ot_start_hour number;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  number;
    jj_step         NUMBER;

    x_lunch_time_flag  VARCHAR2(01);
    x_night_time_flag VARCHAR2(01);

    x_tomorrow_type    VARCHAR2(10);
BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      --< Start  HMT_20210317 : Change start time of caculate ot
      x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
      /*IF p_week_code = 'FRI' THEN
        x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
        ELSE x_ot_start_hour := p_start_hour + C_WORKING_HOUR + 1;
      END IF;*/
      --> End
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 12 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_lunch_time_flag := 'Y';
      ELSE
        x_lunch_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_lunch_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24 THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    
    --sangnv
    jj_step := x_ot_start_hour;
    IF jj_step < 6 then
      jj_step := jj_step + 24;
    END IF;
      
    IF jj_step >= 46 THEN
      jj_step := jj_step - 24;
    END IF;  
    --end
    
    IF jj_step - TRUNC(jj_step, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF (TRUNC(jj_step, 0) = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';
      ELSIF TRUNC(jj_step, 0) < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP
      
    -- SANGNV
      jj_step := jj;
      IF jj_step < 6 then
        jj_step := jj_step + 24;
      END IF;
      
      IF jj_step >= 46 THEN
        jj_step := jj_step - 24;
      END IF;  
    -- END SANGNV

      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF (x_ot_start_hour < 12 AND jj = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';

      ELSIF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
        x_night_time_flag := 'N';

      ELSIF jj_step < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF jj_step < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF jj_step < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;

    END LOOP;

END set_10_day_shift_ot;


PROCEDURE set_10_night_shift_ot(p_work_start_hour IN NUMBER,
                               p_start_hour      IN NUMBER,
                               p_over_time       IN NUMBER,
                               p_lateness        IN NUMBER DEFAULT 0,
                               p_leaving_early   IN NUMBER DEFAULT 0,
                               p_going_out       IN NUMBER DEFAULT 0,
                               p_today_type      IN VARCHAR2,
                               p_week_code       IN VARCHAR2, --2021/03/17  HMT_20210317
                               p_att_code        IN VARCHAR2,
                               p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_10_night_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 23-MAR-2023                       Initialized
/*
/******************************************************************************/
IS
    x_ot_start_hour NUMBER;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  NUMBER;
    x_lateness      NUMBER;
    x_leaving_early NUMBER;
    x_going_out     NUMBER;
    x_cnt30         NUMBER;

    x_night_time_flag VARCHAR2(01);
    x_tomorrow_type   VARCHAR2(10);
    
    x_nt30_calc_fg    VARCHAR2(1);

BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
      x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
      /*IF p_week_code = 'FRI' THEN
        x_ot_start_hour := p_start_hour + C_WORKING_HOUR;
      ELSE x_ot_start_hour := p_start_hour + C_WORKING_HOUR + 1;
      
      END IF; */
      --> End
      -- HMT_20260801: neu ngay mai la PH, tinh OT tu 01:00 ngay mai (khong doi theo cong
      -- thuc chuan neu cong thuc do cho ket qua muon hon 01:00)
      IF x_tomorrow_type = 'PH' AND x_ot_start_hour > 25 THEN
        x_ot_start_hour := 25;
      END IF;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 24 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_night_time_flag := 'Y';
      ELSE
        x_night_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_night_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao.
    -- CHI cong bu khi co che nghi-giua-ca (x_night_time_flag='Y') CHUA tu loai tru
    -- gio nay roi (neu khong se bi cong bu 2 LAN cho cung 1 gio -> du 1h).
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24
       AND NVL(x_night_time_flag, 'N') <> 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    IF x_ot_start_hour - TRUNC(x_ot_start_hour, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF p_today_type = 'NW' THEN
        IF TRUNC(x_ot_start_hour, 0) = 29 AND x_tomorrow_type <> 'PH' THEN -- HMT_20260801
          -- AM 5:00
          p_array_ot(C_NT200) := p_array_ot(C_NT200) + x_apply_mid_ot;
        ELSIF TRUNC(x_ot_start_hour, 0) < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (TRUNC(x_ot_start_hour, 0) = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF TRUNC(x_ot_start_hour, 0) < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 24 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 46 THEN
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF;
      
    END IF;
    
    SELECT CASE WHEN attendance_days > 0 AND p_att_code NOT IN ('HL', 'HL_FD')
                THEN 'Y'
                ELSE 'N'
           END AS nt30_calc_fg
    INTO   x_nt30_calc_fg
    FROM   tb_att_code_c
    WHERE  time_and_attendance_code = p_att_code;

    IF x_nt30_calc_fg = 'N' THEN
       p_array_ot(C_NT30) := 0;
    ELSE
      IF (p_att_code = 'HL_FN') THEN
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        x_cnt30 := 4;
        /*IF p_week_code = 'FRI' THEN
          x_cnt30 := 4;
          ELSE x_cnt30 := 4.5;
        END IF; */
        --> End
        x_lateness := p_lateness;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
      ELSIF (p_att_code = 'HL_SN') THEN
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
         x_cnt30 :=2;
        /*IF p_week_code = 'FRI' THEN
          x_cnt30 :=2;
          ELSE x_cnt30 := 2.5;
        END IF; */
        --> End
        x_leaving_early := p_leaving_early;
        x_going_out := 0;

        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0;
        END IF;
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_going_out > 2 THEN
           x_going_out := p_going_out-2;
        ELSE
           x_going_out := 0;
        END IF;
        --> End
      ELSE
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
          x_cnt30 := 6;
        /*IF p_week_code = 'FRI' THEN
          x_cnt30 := 6;
          ELSE x_cnt30 := 7;
        END IF; */
        --> End  
        -- HMT_20260801: neu ngay mai la PH, chi con 2h (22:00-24:00) duoc tinh NT30;
        -- phan con lai (00:00 tro di) da duoc tra o muc PH (NT390/OT300) roi
        IF x_tomorrow_type = 'PH' THEN
          x_cnt30 := 2;
        END IF;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
        
        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0;
        END IF;
        
        --< Start 2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_going_out > 2 THEN
           x_going_out := p_going_out-2;
        ELSE
           x_going_out := 0;
        END IF;
        --> End
      END IF;
      
      IF (x_cnt30 - x_lateness - x_leaving_early - x_going_out) < 0 THEN
         p_array_ot(C_NT30) := 0;
      ELSE
         p_array_ot(C_NT30) := x_cnt30 - x_lateness - x_leaving_early - x_going_out;
      END IF;
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP

      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF p_today_type = 'NW' THEN
        IF jj = 29 AND x_tomorrow_type <> 'PH' THEN -- HMT_20260801
          -- AM 5:00
          p_array_ot(C_NT200) := p_array_ot(C_NT200) + x_apply_mid_ot;
        ELSIF jj < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF jj < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF jj < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 24 THEN
          IF p_today_type = 'WH' THEN
          -- 2017.12.06 : ?? Over Time Code ??(C_OT200 -> C_NT270)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF jj < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF jj < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 46 THEN
          -- 2017.12.09 : Night ???? => ???( 20:00 + 24)(???:32)
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF; --IF p_today_type = 'NW' THEN

    END LOOP;

END set_10_night_shift_ot;

PROCEDURE set_3_day_shift_ot(p_work_start_hour IN NUMBER,
                             p_start_hour      IN NUMBER,
                             p_over_time       IN NUMBER,
                             p_today_type      IN VARCHAR2,
                             p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                             p_array_ot        OUT ARRAY_NUM
                            )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_3_day_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 04-OCT-2018                       Initialized
/*
/******************************************************************************/
IS
    x_ot_start_hour NUMBER;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  NUMBER;

    x_lunch_time_flag  VARCHAR2(01);
    x_night_time_flag  VARCHAR2(01);
    jj_step         NUMBER;

    x_tomorrow_type    VARCHAR2(10);
BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      x_ot_start_hour := p_start_hour + C_3SHIFT_WORKING_HOUR;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 12 AND (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_lunch_time_flag := 'Y';
      ELSE
        x_lunch_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_lunch_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24 THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    --sangnv
    jj_step := x_ot_start_hour;
    IF jj_step < 6 then
      jj_step := jj_step + 24;
    END IF;
      
    IF jj_step >= 46 THEN
      jj_step := jj_step - 24;
    END IF;  
    --end
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    IF jj_step - TRUNC(jj_step, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF (TRUNC(jj_step, 0) = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';
      ELSIF TRUNC(jj_step, 0) < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF TRUNC(jj_step, 0) < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF TRUNC(jj_step, 0) < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP
      
     -- SANGNV
      jj_step := jj;
      IF jj_step < 6 then
        jj_step := jj_step + 24;
      END IF;
      
      IF jj_step >= 46 THEN
        jj_step := jj_step - 24;
      END IF;  
    -- END SANGNV
    
      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF (x_ot_start_hour < 12 AND jj = 12 AND x_lunch_time_flag = 'Y') THEN
        x_lunch_time_flag := 'N';

      ELSIF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
        x_night_time_flag := 'N';

      ELSIF jj_step < 22 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 24 THEN
        IF p_today_type = 'NW' THEN
          p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
        ELSIF p_today_type = 'WH' THEN
          p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
        ELSIF p_today_type = 'PH' THEN
          p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
        END IF;

      ELSIF jj_step < 30 THEN
        IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
          IF jj_step < 25 THEN
            NULL; -- 00:00-01:00 khong tinh
          ELSE
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
            END IF;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
          IF jj_step < 25 THEN
            NULL;
          ELSE
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;
        ELSE -- khong lien quan PH -> tiep tuc theo LOAI CUA HOM NAY
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 32 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      ELSIF jj_step < 46 THEN
        IF p_today_type = 'PH' THEN
          IF x_tomorrow_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        ELSIF x_tomorrow_type = 'PH' THEN
          p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
        ELSE
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;

      END IF;

    END LOOP;

END set_3_day_shift_ot;


PROCEDURE set_3_night_shift_ot(p_work_start_hour IN NUMBER,
                               p_start_hour      IN NUMBER,
                               p_over_time       IN NUMBER,
                               p_lateness        IN NUMBER DEFAULT 0,
                               p_leaving_early   IN NUMBER DEFAULT 0,
                               p_going_out       IN NUMBER DEFAULT 0,
                               p_today_type      IN VARCHAR2,
                               p_att_code        IN VARCHAR2,
                               p_tomorrow_type   IN VARCHAR2 DEFAULT NULL, -- HMT_20260801: truyen that ngay mai
                               p_array_ot        OUT ARRAY_NUM
                              )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : set_3_night_shift_ot
/* Description  :
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 04-OCT-2018                       Initialized
/* 29-07-2019     TaiDD-20190729     Change the condition to calculate the N30% when employee have Early Leave, 
                                                       minus 0.5 is only applied to full night working or HL_FN, not for HL_SN 
/******************************************************************************/
IS
    x_ot_start_hour NUMBER;
    x_ot_end_hour   NUMBER;
    x_apply_mid_ot  NUMBER;
    x_lateness      NUMBER;
    x_leaving_early NUMBER;
    x_going_out     NUMBER;
    x_cnt30         NUMBER;

    x_night_time_flag VARCHAR2(01);
    x_tomorrow_type   VARCHAR2(10);
    
    x_nt30_calc_fg    VARCHAR2(1);

BEGIN

    x_tomorrow_type := NVL(p_tomorrow_type, p_today_type); -- HMT_20260801: dung ngay mai THAT, fallback ve hom nay neu khong truyen

    FOR jj IN 1 .. C_MAX_ARRAY LOOP
      p_array_ot(JJ) := 0;
    END LOOP;

    IF p_today_type = 'NW' THEN
      x_ot_start_hour := p_start_hour + C_3SHIFT_WORKING_HOUR;
      -- HMT_20260801: neu ngay mai la PH, tinh OT tu 01:00 ngay mai (khong doi theo cong
      -- thuc chuan neu cong thuc do cho ket qua muon hon 01:00)
      IF x_tomorrow_type = 'PH' AND x_ot_start_hour > 25 THEN
        x_ot_start_hour := 25;
      END IF;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
    ELSE
      x_ot_start_hour := p_work_start_hour;
      x_ot_end_hour   := x_ot_start_hour + p_over_time;
      IF x_ot_start_hour < 24 AND
         (x_ot_start_hour - p_start_hour + p_over_time) > 4 THEN
        x_night_time_flag := 'Y';
      ELSE
        x_night_time_flag := 'N';
      END IF;

    END IF;
    
    -- ???? ??? ?? end hour+1
    IF x_night_time_flag = 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    -- HMT_20260801: neu OT (wall-clock) vuot qua 00:00 va ngay mai la PH,
    -- cong bu them 1h vi khung 00:00-01:00 khong duoc tinh vao bucket nao.
    -- CHI cong bu khi co che nghi-giua-ca (x_night_time_flag='Y') CHUA tu loai tru
    -- gio nay roi (neu khong se bi cong bu 2 LAN cho cung 1 gio -> du 1h).
    IF (p_today_type = 'PH' OR x_tomorrow_type = 'PH')
       AND x_ot_start_hour < 25 AND x_ot_end_hour > 24
       AND NVL(x_night_time_flag, 'N') <> 'Y' THEN
      x_ot_end_hour := x_ot_end_hour + 1;
    END IF;
    
    -- ??????? 30???? ?? LOOP ????? 30?? ???? OT ??
    IF x_ot_start_hour - TRUNC(x_ot_start_hour, 0) = 0.5 AND p_over_time <> 0 THEN 
      x_apply_mid_ot := 0.5;
      IF p_today_type = 'NW' THEN
        IF TRUNC(x_ot_start_hour, 0) < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (TRUNC(x_ot_start_hour, 0) = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF TRUNC(x_ot_start_hour, 0) < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 24 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF TRUNC(x_ot_start_hour, 0) < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF TRUNC(x_ot_start_hour, 0) < 46 THEN
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF;
      
    END IF;
    
    SELECT CASE WHEN attendance_days > 0 AND p_att_code NOT IN ('HL', 'HL_FD')
                THEN 'Y'
                ELSE 'N'
           END AS nt30_calc_fg
    INTO   x_nt30_calc_fg
    FROM   tb_att_code_c
    WHERE  time_and_attendance_code = p_att_code;

    -- Normal(30%) OT
    IF x_nt30_calc_fg = 'N' THEN
       p_array_ot(C_NT30) := 0;
    ELSE
      IF (p_att_code = 'HL_FN') THEN
        x_cnt30 := 4.5; --2021/03/17 HMT_20210317 : Change start time of caculate ot (5 --> 4.5)
        x_lateness := p_lateness;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
        
      /*------------TaiDD-20190729-----------*/
      x_leaving_early := CASE WHEN x_leaving_early - 0.5 < 0 THEN 0 ELSE x_leaving_early - 0.5 END;
      --------------TaiDD-20190729----End----*/
      ELSIF (p_att_code = 'HL_SN') THEN
        x_cnt30 := 2;
        x_leaving_early := p_leaving_early;
        x_going_out := 0;

        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0;
        END IF;
        
        --2021/03/17 HMT_20210317 : Change start time of caculate ot
        IF p_going_out > 2 THEN
           x_going_out := p_going_out-2;
        ELSE
           x_going_out := 0;
        END IF;
        --> End

      ELSE
        x_cnt30 := 7;
        -- HMT_20260801: neu ngay mai la PH, chi con 2h (22:00-24:00) duoc tinh NT30;
        -- phan con lai (00:00 tro di) da duoc tra o muc PH (NT390/OT300) roi
        IF x_tomorrow_type = 'PH' THEN
          x_cnt30 := 2;
        END IF;
        x_leaving_early := p_leaving_early;
        x_going_out := p_going_out;
        
        IF p_lateness > 2 THEN
           x_lateness := p_lateness-2;
        ELSE
           x_lateness := 0; 
        END IF;
        
      /*------------TaiDD-20190729-----------*/
      x_leaving_early := CASE WHEN x_leaving_early - 0.5 < 0 THEN 0 ELSE x_leaving_early - 0.5 END;
      --------------TaiDD-20190729----End----*/
      END IF;
      
      /*------------TaiDD-20190729---------------
      x_leaving_early := CASE WHEN x_leaving_early - 0.5 < 0 THEN 0 ELSE x_leaving_early - 0.5 END;
      --------------TaiDD-20190729----End----*/
      
      IF (x_cnt30 - x_lateness - x_leaving_early - x_going_out) < 0 THEN
         p_array_ot(C_NT30) := 0;
      ELSE
         p_array_ot(C_NT30) := x_cnt30 - x_lateness - x_leaving_early - x_going_out;
      END IF;
    END IF;
dbms_output.put_line('start_hour : ' || x_ot_start_hour || ', end_hour : ' || x_ot_end_hour);
    FOR jj IN x_ot_start_hour .. x_ot_end_hour LOOP

      x_apply_mid_ot := 1;
      
      IF jj = TRUNC(x_ot_end_hour, 0) + 1 THEN
        x_apply_mid_ot := 0;
      ELSIF jj = TRUNC(x_ot_end_hour, 0) THEN
							  
        x_apply_mid_ot := x_ot_end_hour - TRUNC(x_ot_end_hour, 0); -- FIX: nhan moi phan du (khong chi 0/0.5)
      END IF;
dbms_output.put_line('jj : ' || jj || ', x_apply_mid_ot : ' || x_apply_mid_ot);
      IF p_today_type = 'NW' THEN
        IF jj < 30 THEN -- truoc 06:00 ngay mai (hom nay chac chan la NW o day)
          IF x_tomorrow_type = 'PH' THEN
            IF jj < 25 THEN
              NULL; -- 00:00-01:00 ngay mai (PH) -> khong tinh
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- tomorrow = NW hoac WH: khong lien quan PH -> tiep tuc theo hom nay (NW)
            p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
          END IF;
        ELSE -- tu 06:00 ngay mai tro di
          IF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE
            p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
          END IF;
        END IF;
      ELSE
        IF (x_ot_start_hour < 24 AND jj = 24 AND x_night_time_flag = 'Y') THEN
          x_night_time_flag := 'N';
        ELSIF jj < 22 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 24 THEN
          IF p_today_type = 'WH' THEN
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          ELSIF p_today_type = 'PH' THEN
            p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 30 THEN
          IF p_today_type = 'PH' THEN -- HMT_20260801_v3: hom nay la PH -> tu 01:00 chuyen theo NGAY MAI
            IF jj < 25 THEN
              NULL; -- 00:00-01:00 khong tinh
            ELSE
              IF x_tomorrow_type = 'WH' THEN
                p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
              ELSIF x_tomorrow_type = 'PH' THEN
                p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
              ELSE
                p_array_ot(C_NT210) := p_array_ot(C_NT210) + x_apply_mid_ot;
              END IF;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN -- hom nay khong PH, nhung ngay mai la PH
            IF jj < 25 THEN
              NULL;
            ELSE
              p_array_ot(C_NT390) := p_array_ot(C_NT390) + x_apply_mid_ot;
            END IF;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_NT270) := p_array_ot(C_NT270) + x_apply_mid_ot;
          END IF;

        ELSIF jj < 46 THEN
          IF p_today_type = 'PH' THEN
            IF x_tomorrow_type = 'WH' THEN
              p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
            ELSIF x_tomorrow_type = 'PH' THEN
              p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
            ELSE
              p_array_ot(C_OT150) := p_array_ot(C_OT150) + x_apply_mid_ot;
            END IF;
          ELSIF x_tomorrow_type = 'PH' THEN
            p_array_ot(C_OT300) := p_array_ot(C_OT300) + x_apply_mid_ot;
          ELSE -- khong lien quan PH -> tiep tuc theo hom nay (WH)
            p_array_ot(C_OT200) := p_array_ot(C_OT200) + x_apply_mid_ot;
          END IF;

        END IF;

      END IF;

    END LOOP;

END set_3_night_shift_ot;

FUNCTION get_holiday(p_subsidiary_code VARCHAR2, p_employee_no VARCHAR2 DEFAULT NULL, p_shift_code VARCHAR2, p_date date) --HMT_20210717
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_holiday
/* Description  : Return value
/*               1. 'PH'  PUBULIC HOLIDAY
/*               2. 'WH'  WEEKDAY HOLIDAY
/*               3. 'NW'  WEEKDAY
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
RETURN VARCHAR2
IS
    CURSOR C1 IS
      SELECT t.time_and_attendance_code
        FROM TB_ATT_BASE_BAS_N t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.time_and_attendance_date = TRUNC(p_date)
         AND t.shift_type_code = p_shift_code;
         
    x_return_value        VARCHAR2(10) := 'NW';
    x_swap_weekly_holiday NUMBER := 0;
    x_swap_working_day    NUMBER := 0;

BEGIN

    FOR r1 IN c1 LOOP
      x_return_value := r1.time_and_attendance_code;
    END LOOP;
    --HMT_20210717 Start
    IF p_employee_no IS NOT NULL THEN 
        SELECT COUNT(1) INTO x_swap_weekly_holiday  
          FROM tb_att_swap_holiday_request_n r
          WHERE r.employee_no = p_employee_no
            AND r.subsidiary_code = p_subsidiary_code
            AND (r.progress_status_code = '40' OR r.confirm_flag = 'Y')
            AND TO_CHAR(r.weekly_holiday, 'YYYY/MM/DD') = TO_CHAR(p_date, 'YYYY/MM/DD');
            
         SELECT COUNT(1) INTO x_swap_working_day  
           FROM tb_att_swap_holiday_request_n r
          WHERE r.employee_no = p_employee_no
            AND r.subsidiary_code = p_subsidiary_code
            AND (r.progress_status_code = '40' OR r.confirm_flag = 'Y')
            AND TO_CHAR(r.working_day, 'YYYY/MM/DD') = TO_CHAR(p_date, 'YYYY/MM/DD');
            
        IF x_swap_weekly_holiday > 0 THEN x_return_value := 'NW'; END IF;
        IF x_swap_working_day > 0 THEN x_return_value := 'WH'; END IF;

       END IF;
     --HMT_20210717 End

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN 'NW';

END get_holiday;


FUNCTION get_shift_code_info(p_subsidiary_code VARCHAR2,
                             p_shift_code      VARCHAR2,
                             p_info_num        NUMBER Default 1
                            )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_shift_code_info
/* Description  : p_info_num
/*               1. ATTENDANCE_CYCLE
/*               2. ATTENDANCE_START_DATE
/*               3. START_WORKING_TIME
/*               4. DAY_SHIFT_START_TIME
/*               5. NIGHT_SHIFT_START_TIME
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
RETURN VARCHAR2
IS
    CURSOR C1 IS
      SELECT LCC.COMMON_CODE,
             NVL(LCC.CODE_DATA1_VALUE, 0)       AS ATTENDANCE_CYCLE,
             LCC.CODE_DATA2_VALUE               AS ATTENDANCE_START_DATE,
             NVL(LCC.CODE_DATA3_VALUE, '08:00') AS START_WORKING_TIME,        -- 2017.10.25 ???? ?? ?? -> ??? 3?? ???? Alias ???? ???? ?? ??? ???? ??? (NOON_WORKIN_TIME ??)
             NVL(LCC.CODE_DATA4_VALUE, '08:00') AS DAY_SHIFT_START_TIME,
             NVL(LCC.CODE_DATA5_VALUE, '20:00') AS NIGHT_SHIFT_START_TIME
        FROM LGCOM_COMMON_CODE_C LCC
       WHERE 1 = 1
         AND lcc.code_type_code = 'LGVHR_SHIFT_TYPE_CODE'
         AND lcc.common_code = p_shift_code;

    x_return_value VARCHAR2(30) := 'NW';

BEGIN

    FOR r1 IN c1 LOOP
      IF p_info_num = 1 THEN
        x_return_value := r1.ATTENDANCE_CYCLE;
      ELSIF p_info_num = 2 THEN
        x_return_value := r1.ATTENDANCE_START_DATE;
      ELSIF p_info_num = 3 THEN
        x_return_value := r1.START_WORKING_TIME;
      ELSIF p_info_num = 4 THEN
        x_return_value := r1.DAY_SHIFT_START_TIME;
      ELSIF p_info_num = 5 THEN
        x_return_value := r1.NIGHT_SHIFT_START_TIME;

      END IF;

    END LOOP;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN 'NW';

END get_shift_code_info;


FUNCTION get_night_check(p_subsidiary_code IN VARCHAR2,
                         p_date            IN DATE,
                         p_shfit_code      IN VARCHAR2
                        )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_day_night
/* Description  : Return value
/*               1. 'N'    Day Working
/*               2. 'Y'    Night Working
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
RETURN VARCHAR2
IS
    CURSOR C1 IS
      SELECT NVL(t.night_shift_flag, 'N') AS night_flag
        FROM TB_ATT_BASE_BAS_N t
       WHERE subsidiary_code = p_subsidiary_code
         AND time_and_attendance_date = p_date
         AND shift_type_code = p_shfit_code;

    x_return_value VARCHAR2(10) := 'N';

BEGIN

    FOR r1 IN c1 LOOP

        x_return_value := r1.night_flag;

    END LOOP;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN 'N';

END get_night_check;

FUNCTION get_date_type(p_subsidiary_code IN VARCHAR2,
                       p_employee_no     IN VARCHAR2 DEFAULT NULL,
                       p_shift_code      IN VARCHAR2,
                       p_date            IN DATE,
                       p_get_type        IN VARCHAR2
                        )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_date_type
/* Description  : Return value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/17  HMT_20210317        Add get_date_type function  
/*
/******************************************************************************/
RETURN VARCHAR2
IS
    CURSOR C1 IS
      SELECT t.a_day_of_the_week_code, t.time_and_attendance_code, t.time_and_attendance_date, t.night_shift_flag, t.work_hours
        FROM tb_att_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.time_and_attendance_date = TRUNC(p_date)
         AND t.shift_type_code = p_shift_code
         AND t.employee_no = p_employee_no;

    x_return_value VARCHAR2(10) := '';

BEGIN

    FOR r1 IN c1 LOOP
      IF p_get_type = 'week_code' THEN
      x_return_value := r1.a_day_of_the_week_code;
      IF r1.work_hours IN ('4','8') THEN 
        x_return_value := 'FRI';
        END IF;
      END IF;
    END LOOP;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN '';

END get_date_type;

FUNCTION get_ot_total(p_subsidiary_code  IN VARCHAR2,
                       p_employee_no     IN VARCHAR2,
                       p_start_date      IN  DATE,
                       p_end_date        IN  DATE,
                       p_get_type        IN VARCHAR2
                        )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Program Name : get_ot_total
/* Description  : Return total employee's overtime value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/26  HMT_20210326        Add get_ot_total function  
/*
/******************************************************************************/
RETURN NUMBER
IS
    ot_total             NUMBER := 0;
    ot_total_result      NUMBER := 0;
    ot_total_request     NUMBER := 0;
    ot_total_request_old NUMBER := 0;
    ot_total_special     NUMBER := 0;
    v_start_day_of_month DATE := trunc((p_end_date),'month');
    v_start_day_of_year  DATE := trunc((p_end_date),'year');

BEGIN
  --Get Month ot total from start day of month to p_end_date   (Include request)
    IF p_get_type = 'month_total_ot' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)  INTO ot_total_result
        FROM tb_att_result_n t
       WHERE t.time_and_attendance_date between p_start_date AND p_end_date
        AND   t.employee_no = p_employee_no;
        
     SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'NEW'
        AND tu.time_and_attendance_date between p_start_date AND p_end_date
        AND tu.employee_no = p_employee_no;
        
     SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request_old
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'OLD'
        AND tu.time_and_attendance_date between p_start_date AND p_end_date
        AND tu.employee_no = p_employee_no;

     SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0)
                   + NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag IN ('N', 'Y')
        AND ts.progress_status_code IN ('20','30','40')
        AND ts.time_and_attendance_date between p_start_date AND p_end_date
        AND ts.employee_no = p_employee_no;
    
    --Get Year ot total from start day of year to p_end_date  (Include request)  
    ELSIF p_get_type = 'year_total_ot' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)  INTO ot_total_result
        FROM tb_att_result_n t
       WHERE t.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'NEW'
        AND tu.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND tu.employee_no = p_employee_no;
        
     SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request_old
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'OLD'
        AND tu.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND tu.employee_no = p_employee_no;

     SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag IN ('N', 'Y')
        AND ts.progress_status_code IN ('20','30','40')
        AND ts.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND ts.employee_no = p_employee_no;
    
    --Get Month ot total     (Include request)
    ELSIF p_get_type = 'month_total_ot_yyyymm' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)  INTO ot_total_result
        FROM tb_att_result_n t
       WHERE t.time_and_attendance_yyyymm = TO_CHAR(p_end_date,'YYYYMM')
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'NEW'
        AND TO_CHAR(tu.time_and_attendance_date,'YYYYMM') = TO_CHAR(p_end_date,'YYYYMM')
        AND tu.employee_no = p_employee_no;
        
     SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request_old
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'OLD'
        AND TO_CHAR(tu.time_and_attendance_date,'YYYYMM') = TO_CHAR(p_end_date,'YYYYMM')
        AND tu.employee_no = p_employee_no;

     SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag IN ('N', 'Y')
        AND ts.progress_status_code IN ('20','30','40')
        AND TO_CHAR(ts.time_and_attendance_date,'YYYYMM') = TO_CHAR(p_end_date,'YYYYMM')
        AND ts.employee_no = p_employee_no;
    
    --Get Year ot total    (Include request)
    ELSIF p_get_type = 'year_total_ot_yyyy' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)   INTO ot_total_result
        FROM tb_att_result_n t
       WHERE TO_CHAR(t.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'NEW'
        AND TO_CHAR(tu.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND tu.employee_no = p_employee_no;
        
     SELECT NVL(SUM(NVL(tu.weekday_overtime_hours, 0) + NVL(tu.holiday_overtime_hours, 0) + NVL(tu.public_holiday_overtime_hours, 0) + NVL(tu.weekday_night_overtime_hours, 0) 
                   + NVL(tu.weekday_ot_af_night_work_hours, 0) + NVL(tu.holiday_night_overtime_hours, 0) + NVL(tu.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_request_old
      from tb_att_update_req_n tu
      where tu.progress_status_code IN ('20','30')
        AND tu.data_old_new_type_code = 'OLD'
        AND TO_CHAR(tu.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND tu.employee_no = p_employee_no;

     SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag IN ('N', 'Y')
        AND ts.progress_status_code IN ('20','30','40')
        AND TO_CHAR(ts.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND ts.employee_no = p_employee_no;
      
      --Get Month ot total from start day of month to p_end_date   (Only result)
      ELSIF p_get_type = 'month_total_ot_result' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)   INTO ot_total_result
        FROM tb_att_result_n t
       WHERE t.time_and_attendance_date between v_start_day_of_month AND p_end_date
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag = 'Y'
        AND ts.time_and_attendance_date between v_start_day_of_month AND p_end_date
        AND ts.employee_no = p_employee_no;
        
      --Get Month ot total from start day of month to p_end_date   (Only special ot)
      ELSIF p_get_type = 'special_ot_y' THEN
      SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag = 'Y'
        AND ts.time_and_attendance_date between p_start_date AND p_end_date
        AND ts.employee_no = p_employee_no;
        
      ELSIF p_get_type = 'special_ot_n' THEN
      SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag IN ('N', 'Y')
        AND ts.progress_status_code IN ('10','20','30','40')
        AND ts.time_and_attendance_date between p_start_date AND p_end_date
        AND ts.employee_no = p_employee_no;
      
      --Get Year ot total from start day of year to p_end_date   (Only result)
      ELSIF p_get_type = 'year_total_ot_result' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)   INTO ot_total_result
        FROM tb_att_result_n t
       WHERE t.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag = 'Y'
        AND ts.time_and_attendance_date between v_start_day_of_year AND p_end_date
        AND ts.employee_no = p_employee_no;
      
      --Get Month ot total (Only result)  
      ELSIF p_get_type = 'month_total_ot_result_yyyymm' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)   INTO ot_total_result
        FROM tb_att_result_n t
       WHERE TO_CHAR(t.time_and_attendance_date,'YYYYMM') = TO_CHAR(p_end_date,'YYYYMM')
        AND   t.employee_no = p_employee_no;
        
      SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag = 'Y'
        AND TO_CHAR(ts.time_and_attendance_date,'YYYYMM') = TO_CHAR(p_end_date,'YYYYMM')
        AND ts.employee_no = p_employee_no;
      
      --Get Year ot total (Only result)  
      ELSIF p_get_type = 'year_total_ot_result_yyyy' THEN
      SELECT NVL(SUM(NVL(t.weekday_overtime_hours, 0) + NVL(t.holiday_overtime_hours, 0) + NVL(t.public_holiday_overtime_hours, 0) + NVL(t.weekday_night_overtime_hours, 0) 
                   + NVL(t.weekday_ot_af_night_work_hours, 0) + NVL(t.holiday_night_overtime_hours, 0) + NVL(t.public_holiday_night_ot_hours, 0)), 0)   INTO ot_total_result
        FROM tb_att_result_n t
       WHERE TO_CHAR(t.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND   t.employee_no = p_employee_no;
        
       SELECT NVL(SUM(NVL(ts.weekday_overtime_hours, 0) + NVL(ts.holiday_overtime_hours, 0) + NVL(ts.public_holiday_overtime_hours, 0) + NVL(ts.weekday_night_overtime_hours, 0) + 
                  NVL(ts.weekday_ot_af_night_work_hours, 0) + NVL(ts.holiday_night_overtime_hours, 0) + NVL(ts.public_holiday_night_ot_hours, 0)), 0) INTO ot_total_special
      from tb_att_special_ot_result_n ts
      where ts.confirm_flag = 'Y'
        AND TO_CHAR(ts.time_and_attendance_date,'YYYY') = TO_CHAR(p_end_date,'YYYY')
        AND ts.employee_no = p_employee_no;
        
      END IF;
      ot_total := ot_total_result + ot_total_request + ot_total_special - ot_total_request_old;
   return ot_total;

EXCEPTION
WHEN OTHERS THEN
    RETURN ot_total;

END get_ot_total;

FUNCTION get_item_ot_total(p_subsidiary_code  IN VARCHAR2,
                           p_employee_no     IN VARCHAR2,
                           p_start_date      IN  DATE,
                           p_end_date        IN  DATE,
                           p_item            IN VARCHAR2,
                           p_get_type        IN VARCHAR2
                            )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Program Name : get_item_ot_total
/* Description  : Return total employee's overtime value with item
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/04/13  HMT_20210413        Add get_ot_total function  
/*
/******************************************************************************/
RETURN NUMBER
IS
    ot_total         NUMBER := 0;
    ot_total_result  NUMBER := 0;
    ot_total_special  NUMBER := 0;
    v_start_day_of_month DATE := trunc((p_end_date),'month');
    v_start_day_of_year  DATE := trunc((p_end_date),'year');

BEGIN
  --Get Month ot total from start day of month to p_end_date   (Include request)
    IF p_get_type = 'month_total_ot' THEN
      
      IF p_item = 'weekday_day' THEN
        SELECT NVL(SUM(t.weekday_overtime_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.weekday_overtime_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
       
       ELSIF p_item = 'holiday_day' THEN
         SELECT NVL(SUM(t.holiday_overtime_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
         SELECT NVL(SUM(ts.holiday_overtime_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
       
       ELSIF p_item = 'public_holiday_day' THEN
         SELECT NVL(SUM(t.public_holiday_overtime_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.public_holiday_overtime_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_night' THEN
         SELECT NVL(SUM(t.weekday_night_overtime_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.weekday_night_overtime_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_af_night' THEN
         SELECT NVL(SUM(t.weekday_ot_af_night_work_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.weekday_ot_af_night_work_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
        
       ELSIF p_item = 'holiday_night' THEN
         SELECT NVL(SUM(t.holiday_night_overtime_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.holiday_night_overtime_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
        
       ELSIF p_item = 'public_holiday_night' THEN
         SELECT NVL(SUM(t.public_holiday_night_ot_hours), 0)  INTO ot_total_result
          FROM tb_att_result_n t
         WHERE t.time_and_attendance_date between p_start_date AND p_end_date
          AND   t.employee_no = p_employee_no;
          
        SELECT NVL(SUM(ts.public_holiday_night_ot_hours), 0) INTO ot_total_special
          FROM tb_att_special_ot_result_n ts
          WHERE ts.confirm_flag = 'Y'
            AND ts.time_and_attendance_date between p_start_date AND p_end_date
            AND ts.employee_no = p_employee_no;
         
       END IF; 
       --Get OT with over year limit (300h)
      ELSIF p_get_type = 'year_total_ot_over_limit' THEN
        
        IF p_item = 'weekday_day' THEN
          SELECT NVL(SUM(v.weekday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       
       ELSIF p_item = 'holiday_day' THEN
           SELECT NVL(SUM(v.holiday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.holiday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       
       ELSIF p_item = 'public_holiday_day' THEN
           SELECT NVL(SUM(v.public_holiday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.public_holiday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_night' THEN
           SELECT NVL(SUM(v.weekday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_af_night' THEN
           SELECT NVL(SUM(v.weekday_af_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_af_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'holiday_night' THEN
           SELECT NVL(SUM(v.holiday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.holiday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'public_holiday_night' THEN
           SELECT NVL(SUM(v.public_holiday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_YEAR_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.public_holiday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_YEAR_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       
       END IF;
       
       --Get OT with over month limit (400h)
       ELSIF p_get_type = 'month_total_ot_over_limit' THEN
        
        IF p_item = 'weekday_day' THEN
          SELECT NVL(SUM(v.weekday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       
       ELSIF p_item = 'holiday_day' THEN
           SELECT NVL(SUM(v.holiday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.holiday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       
       ELSIF p_item = 'public_holiday_day' THEN
           SELECT NVL(SUM(v.public_holiday_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.public_holiday_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_night' THEN
           SELECT NVL(SUM(v.weekday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'weekday_af_night' THEN
           SELECT NVL(SUM(v.weekday_af_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.weekday_af_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'holiday_night' THEN
           SELECT NVL(SUM(v.holiday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.holiday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
        
       ELSIF p_item = 'public_holiday_night' THEN
           SELECT NVL(SUM(v.public_holiday_night_ot_over), 0)  INTO ot_total_result
            FROM NV_TB_ATT_MONTH_OT_OVER_V v
           WHERE v.time_and_attendance_date between p_start_date AND p_end_date
            AND  v.employee_no = p_employee_no;
            
          SELECT NVL(SUM(vs.public_holiday_night_ot_over), 0)  INTO ot_total_special
            FROM NV_TB_ATT_MONTH_OT_OVER_RQ_V vs
           WHERE vs.time_and_attendance_date between p_start_date AND p_end_date
            AND  vs.employee_no = p_employee_no;
       END IF;
      END IF;
      ot_total := ot_total_result + ot_total_special;
   return ot_total;

EXCEPTION
WHEN OTHERS THEN
    RETURN ot_total;

END get_item_ot_total;

FUNCTION get_over_year_ot_hours(p_subsidiary_code IN VARCHAR2,
                                p_employee_no     IN VARCHAR2,
                                p_date            IN DATE,
                                p_item            IN  VARCHAR2,
                                p_get_type        IN VARCHAR2
                                 )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Program Name : get_over_year_ot_hours
/* Description  : Return  employee's over year OT of hours value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/26  HMT_20210326        Add get_over_year_ot_hours function  
/*
/******************************************************************************/
RETURN NUMBER
IS
    v_hours                   NUMBER := 0;
    v_year_ot_limit           NUMBER := 0;
    v_year_ot_total_result    NUMBER := 0;
    v_curent_ot_total_result  NUMBER := 0;
    v_tomorrow_type         VARCHAR2(10);
    v_weekday_ot                       NUMBER := 0;
    v_holiday_ot                       NUMBER := 0;
    v_public_holiday_ot                NUMBER := 0;
    v_weekday_night_ot                 NUMBER := 0;
    v_weekday_af_night_ot              NUMBER := 0;
    v_holiday_night_ot                 NUMBER := 0;
    v_public_holiday_night_ot          NUMBER := 0;
    p_att_code           VARCHAR2(10);
    p_shift_code         VARCHAR2(10);
    p_night_flag         VARCHAR2(2);
    p_dinner_check       VARCHAR2(2);
    p_working_start_time VARCHAR2(10);
    p_ot                 NUMBER := 0;
    v_ot150              NUMBER;
    v_ot200              NUMBER;
    v_ot300              NUMBER;
    v_nt200              NUMBER;
    v_nt210              NUMBER;
    v_nt270              NUMBER;
    v_nt390              NUMBER;
    v_nt30               NUMBER;
    v_ot_before_over     NUMBER;
    v_ot_after_over      NUMBER;
    v_status             VARCHAR2(100);
    v_start_day_of_month DATE := trunc((p_date),'month');
    v_start_day_of_year  DATE := trunc((p_date),'year');
    v_ot_redundancy      NUMBER := 0;

     --Get tb_att_result_n infor
      CURSOR emp_result IS
      SELECT t.subsidiary_code, t.time_and_attendance_date, t.shift_type_code, t.employee_no, t.time_and_attendance_yyyymm, 
             t.a_day_of_the_week_code, t.time_and_attendance_code, t.work_hours, t.work_start_time, t.night_shift_flag, 
             t.evening_meal_flag, t.overtime_sum_hours, t.weekday_overtime_hours, t.holiday_overtime_hours, 
             t.public_holiday_overtime_hours, t.weekday_night_overtime_hours, t.weekday_ot_af_night_work_hours, 
             t.holiday_night_overtime_hours, t.public_holiday_night_ot_hours
        FROM tb_att_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.employee_no = p_employee_no
         AND t.time_and_attendance_date = p_date;
      
      --Get tb_att_special_ot_result_n infor   
      CURSOR emp_special IS
      SELECT t.subsidiary_code, t.time_and_attendance_date, t.employee_no, t.time_and_attendance_yyyymm, 
             t.work_start_time, t.night_shift_flag, 
             t.evening_meal_flag, t.overtime_sum_hours, t.weekday_overtime_hours, t.holiday_overtime_hours, 
             t.public_holiday_overtime_hours, t.weekday_night_overtime_hours, t.weekday_ot_af_night_work_hours, 
             t.holiday_night_overtime_hours, t.public_holiday_night_ot_hours
        FROM tb_att_special_ot_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.employee_no = p_employee_no
         AND t.time_and_attendance_date = p_date
         AND t.confirm_flag = 'Y';

BEGIN
    --Caculate in tb_att_result_n table
    IF p_get_type = 'result_over' THEN
    FOR r1 IN emp_result LOOP
      
    SELECT NVL(MAX(cvh.result_value), 99999999) INTO v_year_ot_limit
        FROM   tb_pay_calc_var_value_n cvh
        WHERE  r1.time_and_attendance_date between TO_DATE(cvh.effective_start_yyyymmdd, 'YYYYMMDD') AND TO_DATE(cvh.effective_end_yyyymmdd, 'YYYYMMDD')
           AND cvh.payroll_calc_variable_id = (select MAX(payroll_calc_variable_id) from tb_pay_calc_var_n 
                                                      where subsidiary_code = 'LGDVN' 
                                                        and payroll_calc_variable_name = 'YEAR_OT_OVER');
                                                        
      --v_year_ot_limit          := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','YEAR_OT_LIMIT','A1',''));
      v_year_ot_total_result   := get_ot_total(r1.subsidiary_code, r1.employee_no, r1.time_and_attendance_date,r1.time_and_attendance_date,'year_total_ot_result');
      v_curent_ot_total_result := NVL((NVL(r1.weekday_overtime_hours, 0) + NVL(r1.holiday_overtime_hours, 0) + NVL(r1.public_holiday_overtime_hours, 0) + NVL(r1.weekday_night_overtime_hours, 0) 
                   + NVL(r1.weekday_ot_af_night_work_hours, 0) + NVL(r1.holiday_night_overtime_hours, 0) + NVL(r1.public_holiday_night_ot_hours, 0)), 0);
    IF v_year_ot_total_result > v_year_ot_limit THEN
    
    --Weekday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.weekday_overtime_hours THEN
       v_weekday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.weekday_overtime_hours THEN
       v_weekday_ot := r1.weekday_overtime_hours;
       END IF;
         
    --Holiday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.holiday_overtime_hours THEN
       v_holiday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.holiday_overtime_hours THEN
       v_holiday_ot := r1.holiday_overtime_hours;
       END IF;
    
    --Public holiday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.public_holiday_overtime_hours THEN
       v_public_holiday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.public_holiday_overtime_hours THEN
       v_public_holiday_ot := r1.public_holiday_overtime_hours;
       END IF;
         
    --Weekday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.weekday_night_overtime_hours THEN
       v_weekday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.weekday_night_overtime_hours THEN
       v_weekday_night_ot := r1.weekday_night_overtime_hours;
       END IF;
         
    --Weekday af night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := r1.weekday_ot_af_night_work_hours;
       END IF;
         
    --Holiday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.holiday_night_overtime_hours THEN
       v_holiday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.holiday_night_overtime_hours THEN
       v_holiday_night_ot := r1.holiday_night_overtime_hours;
       END IF;
         
    --Plublic holiday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r1.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r1.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := r1.public_holiday_night_ot_hours;
       END IF;
       
     IF v_year_ot_total_result - v_year_ot_limit < v_curent_ot_total_result THEN
       v_ot_before_over := v_curent_ot_total_result - (v_year_ot_total_result - v_year_ot_limit);
       IF r1.evening_meal_flag = 'Y' AND r1.shift_type_code = '1A' AND v_curent_ot_total_result <> r1.overtime_sum_hours THEN
         v_ot_before_over := v_ot_before_over + 0.5;
       END IF;
        calculate_ot(p_subsidiary_code    => p_subsidiary_code
                    ,p_date               => p_date
                    ,p_att_code           => r1.time_and_attendance_code
                    ,p_shift_code         => r1.shift_type_code
                    ,p_night_flag         => r1.night_shift_flag
                    ,p_dinner_check       => nvl(r1.evening_meal_flag, 'N')
                    ,p_working_start_time => r1.work_start_time
                    ,p_ot                 => v_ot_before_over
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
                    
      v_weekday_ot                := r1.weekday_overtime_hours         - v_ot150;
      v_holiday_ot                := r1.holiday_overtime_hours         - v_ot200;
      v_public_holiday_ot         := r1.public_holiday_overtime_hours  - v_ot300;
      v_weekday_night_ot          := r1.weekday_night_overtime_hours   - v_nt200;
      v_weekday_af_night_ot       := r1.weekday_ot_af_night_work_hours - v_nt210;
      v_holiday_night_ot          := r1.holiday_night_overtime_hours   - v_nt270;
      v_public_holiday_night_ot   := r1.public_holiday_night_ot_hours  - v_nt390;
     END IF;     
         
        IF p_item = 'weekday_ot'                       THEN          v_hours := v_weekday_ot;
          ELSIF p_item = 'holiday_ot'                  THEN          v_hours := v_holiday_ot;
          ELSIF p_item = 'public_holiday_ot'           THEN          v_hours := v_public_holiday_ot;
          ELSIF p_item = 'weekday_night_ot'            THEN          v_hours := v_weekday_night_ot;
          ELSIF p_item = 'weekday_af_night_ot'         THEN          v_hours := v_weekday_af_night_ot;
          ELSIF p_item = 'holiday_night_ot'            THEN          v_hours := v_holiday_night_ot;
          ELSIF p_item = 'public_holiday_night_ot'     THEN          v_hours := v_public_holiday_night_ot;
        END IF;
      END IF;
    END LOOP;
    
    ELSIF p_get_type = 'request_over' THEN
    --Caculate tb_att_special_ot_result_n
    FOR r2 IN emp_special LOOP
      SELECT NVL(MAX(cvh.result_value), 999999999) INTO v_year_ot_limit
        FROM   tb_pay_calc_var_value_n cvh
        WHERE  r2.time_and_attendance_date between TO_DATE(cvh.effective_start_yyyymmdd, 'YYYYMMDD') AND TO_DATE(cvh.effective_end_yyyymmdd, 'YYYYMMDD')
           AND cvh.payroll_calc_variable_id = (select MAX(payroll_calc_variable_id) from tb_pay_calc_var_n 
                                                      where subsidiary_code = 'LGDVN' 
                                                        and payroll_calc_variable_name = 'YEAR_OT_OVER');
      --v_year_ot_limit          := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','YEAR_OT_LIMIT','A1',''));
      v_year_ot_total_result   := get_ot_total(r2.subsidiary_code, r2.employee_no, r2.time_and_attendance_date,r2.time_and_attendance_date,'year_total_ot_result');
      v_curent_ot_total_result := NVL((NVL(r2.weekday_overtime_hours, 0) + NVL(r2.holiday_overtime_hours, 0) + NVL(r2.public_holiday_overtime_hours, 0) + NVL(r2.weekday_night_overtime_hours, 0) + 
                  NVL(r2.weekday_ot_af_night_work_hours, 0) + NVL(r2.holiday_night_overtime_hours, 0) + NVL(r2.public_holiday_night_ot_hours, 0)), 0);
    IF v_year_ot_total_result > v_year_ot_limit THEN
    
    --Weekday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.weekday_overtime_hours THEN
       v_weekday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.weekday_overtime_hours THEN
       v_weekday_ot := r2.weekday_overtime_hours;
       END IF;
         
    --Holiday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.holiday_overtime_hours THEN
       v_holiday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.holiday_overtime_hours THEN
       v_holiday_ot := r2.holiday_overtime_hours;
       END IF;
    
    --Public holiday OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.public_holiday_overtime_hours THEN
       v_public_holiday_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.public_holiday_overtime_hours THEN
       v_public_holiday_ot := r2.public_holiday_overtime_hours;
       END IF;
         
    --Weekday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.weekday_night_overtime_hours THEN
       v_weekday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.weekday_night_overtime_hours THEN
       v_weekday_night_ot := r2.weekday_night_overtime_hours;
       END IF;
         
    --Weekday af night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := r2.weekday_ot_af_night_work_hours;
       END IF;
         
    --Holiday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.holiday_night_overtime_hours THEN
       v_holiday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.holiday_night_overtime_hours THEN
       v_holiday_night_ot := r2.holiday_night_overtime_hours;
       END IF;
         
    --Plublic holiday night OT
    IF v_year_ot_total_result - v_year_ot_limit <= r2.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := v_year_ot_total_result - v_year_ot_limit;
     ELSIF v_year_ot_total_result - v_year_ot_limit > r2.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := r2.public_holiday_night_ot_hours;
       END IF;
       
     IF v_year_ot_total_result - v_year_ot_limit < v_curent_ot_total_result THEN
       v_ot_before_over := v_year_ot_total_result - v_year_ot_limit;
       
       v_weekday_ot               := get_conv_ot_hour(ROUND((r2.weekday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_holiday_ot                := get_conv_ot_hour(ROUND((r2.holiday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_public_holiday_ot         := get_conv_ot_hour(ROUND((r2.public_holiday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_weekday_night_ot         := get_conv_ot_hour(ROUND((r2.weekday_night_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_weekday_af_night_ot       := get_conv_ot_hour(ROUND((r2.weekday_ot_af_night_work_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_holiday_night_ot         := get_conv_ot_hour(ROUND((r2.holiday_night_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_public_holiday_night_ot  := get_conv_ot_hour(ROUND((r2.public_holiday_night_ot_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       
       v_ot_redundancy := (v_weekday_ot + v_weekday_night_ot + v_holiday_ot + v_weekday_af_night_ot + v_holiday_night_ot + v_public_holiday_ot + v_public_holiday_night_ot) - v_ot_before_over;
       IF v_ot_redundancy > 0 THEN 
         IF v_public_holiday_night_ot > v_ot_redundancy THEN v_public_holiday_night_ot := v_public_holiday_night_ot - v_ot_redundancy;
           ELSIF v_public_holiday_ot > v_ot_redundancy THEN v_public_holiday_ot := v_public_holiday_ot - v_ot_redundancy;
           ELSIF v_holiday_night_ot > v_ot_redundancy THEN v_holiday_night_ot := v_holiday_night_ot - v_ot_redundancy;
           ELSIF v_weekday_af_night_ot > v_ot_redundancy THEN v_weekday_af_night_ot := v_weekday_af_night_ot - v_ot_redundancy;
           ELSIF v_holiday_ot > v_ot_redundancy THEN v_holiday_ot := v_holiday_ot - v_ot_redundancy;
           ELSIF v_weekday_night_ot > v_ot_redundancy THEN v_weekday_night_ot := v_weekday_night_ot - v_ot_redundancy;
           ELSIF v_weekday_ot > v_ot_redundancy THEN v_weekday_ot := v_weekday_ot - v_ot_redundancy;
          END IF;
         END IF;
 
     END IF;     
         
        IF p_item = 'weekday_ot'                       THEN          v_hours := v_weekday_ot;
          ELSIF p_item = 'holiday_ot'                  THEN          v_hours := v_holiday_ot;
          ELSIF p_item = 'public_holiday_ot'           THEN          v_hours := v_public_holiday_ot;
          ELSIF p_item = 'weekday_night_ot'            THEN          v_hours := v_weekday_night_ot;
          ELSIF p_item = 'weekday_af_night_ot'         THEN          v_hours := v_weekday_af_night_ot;
          ELSIF p_item = 'holiday_night_ot'            THEN          v_hours := v_holiday_night_ot;
          ELSIF p_item = 'public_holiday_night_ot'     THEN          v_hours := v_public_holiday_night_ot;
        END IF;
        
        IF v_hours - FLOOR(v_hours) < 0.25 THEN v_hours := FLOOR(v_hours) ;     END IF;
        IF v_hours - FLOOR(v_hours) >= 0.25 AND v_hours - FLOOR(v_hours) < 0.75 THEN v_hours := FLOOR(v_hours) + 0.5; END IF;
        IF v_hours - FLOOR(v_hours) >= 0.75 THEN v_hours := FLOOR(v_hours) + 1;   END IF;
        
      END IF;
    END LOOP;
    END IF;  
    
    RETURN v_hours;

EXCEPTION
WHEN OTHERS THEN
    RETURN v_hours;

END get_over_year_ot_hours;

FUNCTION get_over_month_ot_hours(p_subsidiary_code IN VARCHAR2,
                                p_employee_no     IN VARCHAR2,
                                p_date            IN DATE,
                                p_item            IN  VARCHAR2,
                                p_get_type        IN VARCHAR2
                                 )
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Program Name : get_over_month_ot_hours
/* Description  : Return  employee's over month OT of hours value
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/26  HMT_20210326        Add get_over_month_ot_hours function  
/*
/******************************************************************************/
RETURN NUMBER
IS
    v_hours                   NUMBER := 0;
    v_month_ot_limit           NUMBER := 0;
    v_month_ot_total_result    NUMBER := 0;
    v_curent_ot_total_result  NUMBER := 0;
    v_tomorrow_type         VARCHAR2(10);
    v_weekday_ot                       NUMBER := 0;
    v_holiday_ot                       NUMBER := 0;
    v_public_holiday_ot                NUMBER := 0;
    v_weekday_night_ot                 NUMBER := 0;
    v_weekday_af_night_ot              NUMBER := 0;
    v_holiday_night_ot                 NUMBER := 0;
    v_public_holiday_night_ot          NUMBER := 0;
    p_att_code           VARCHAR2(10);
    p_shift_code         VARCHAR2(10);
    p_night_flag         VARCHAR2(2);
    p_dinner_check       VARCHAR2(2);
    p_working_start_time VARCHAR2(10);
    p_ot                 NUMBER := 0;
    v_ot150              NUMBER;
    v_ot200              NUMBER;
    v_ot300              NUMBER;
    v_nt200              NUMBER;
    v_nt210              NUMBER;
    v_nt270              NUMBER;
    v_nt390              NUMBER;
    v_nt30               NUMBER;
    v_ot_before_over     NUMBER;
    v_ot_after_over      NUMBER;
    v_status             VARCHAR2(100);
    v_start_day_of_month DATE := trunc((p_date),'month');
    v_ot_redundancy      NUMBER := 0;

     --Get tb_att_result_n infor
      CURSOR emp_result IS
      SELECT t.subsidiary_code, t.time_and_attendance_date, t.shift_type_code, t.employee_no, t.time_and_attendance_yyyymm, 
             t.a_day_of_the_week_code, t.time_and_attendance_code, t.work_hours, t.work_start_time, t.night_shift_flag, 
             t.evening_meal_flag, t.overtime_sum_hours, t.weekday_overtime_hours, t.holiday_overtime_hours, 
             t.public_holiday_overtime_hours, t.weekday_night_overtime_hours, t.weekday_ot_af_night_work_hours, 
             t.holiday_night_overtime_hours, t.public_holiday_night_ot_hours
        FROM tb_att_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.employee_no = p_employee_no
         AND t.time_and_attendance_date = p_date;
      
      --Get tb_att_special_ot_result_n infor   
      CURSOR emp_special IS
      SELECT t.subsidiary_code, t.time_and_attendance_date, t.employee_no, t.time_and_attendance_yyyymm, 
             t.work_start_time, t.night_shift_flag, 
             t.evening_meal_flag, t.overtime_sum_hours, t.weekday_overtime_hours, t.holiday_overtime_hours, 
             t.public_holiday_overtime_hours, t.weekday_night_overtime_hours, t.weekday_ot_af_night_work_hours, 
             t.holiday_night_overtime_hours, t.public_holiday_night_ot_hours
        FROM tb_att_special_ot_result_n t
       WHERE t.subsidiary_code = p_subsidiary_code
         AND t.employee_no = p_employee_no
         AND t.time_and_attendance_date = p_date
         AND t.confirm_flag = 'Y';

BEGIN
    --Caculate in tb_att_result_n table
    IF p_get_type = 'result_over' THEN
    FOR r1 IN emp_result LOOP
      
    SELECT NVL(MAX(cvh.result_value), 99999999) INTO v_month_ot_limit
        FROM   tb_pay_calc_var_value_n cvh
        WHERE  r1.time_and_attendance_date between TO_DATE(cvh.effective_start_yyyymmdd, 'YYYYMMDD') AND TO_DATE(cvh.effective_end_yyyymmdd, 'YYYYMMDD')
           AND cvh.payroll_calc_variable_id = (select MAX(payroll_calc_variable_id) from tb_pay_calc_var_n 
                                                      where subsidiary_code = 'LGDVN' 
                                                        and payroll_calc_variable_name = 'MONTH_OT_OVER');
                                                        
      --v_month_ot_limit          := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','MONTH_OT_LIMIT','A1',''));
      v_month_ot_total_result   := get_ot_total(r1.subsidiary_code, r1.employee_no, r1.time_and_attendance_date,r1.time_and_attendance_date,'month_total_ot_result');
      v_curent_ot_total_result := NVL((NVL(r1.weekday_overtime_hours, 0) + NVL(r1.holiday_overtime_hours, 0) + NVL(r1.public_holiday_overtime_hours, 0) + NVL(r1.weekday_night_overtime_hours, 0) 
                   + NVL(r1.weekday_ot_af_night_work_hours, 0) + NVL(r1.holiday_night_overtime_hours, 0) + NVL(r1.public_holiday_night_ot_hours, 0)), 0);
    IF v_month_ot_total_result > v_month_ot_limit THEN
    
    --Weekday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.weekday_overtime_hours THEN
       v_weekday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.weekday_overtime_hours THEN
       v_weekday_ot := r1.weekday_overtime_hours;
       END IF;
         
    --Holiday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.holiday_overtime_hours THEN
       v_holiday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.holiday_overtime_hours THEN
       v_holiday_ot := r1.holiday_overtime_hours;
       END IF;
    
    --Public holiday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.public_holiday_overtime_hours THEN
       v_public_holiday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.public_holiday_overtime_hours THEN
       v_public_holiday_ot := r1.public_holiday_overtime_hours;
       END IF;
         
    --Weekday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.weekday_night_overtime_hours THEN
       v_weekday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.weekday_night_overtime_hours THEN
       v_weekday_night_ot := r1.weekday_night_overtime_hours;
       END IF;
         
    --Weekday af night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := r1.weekday_ot_af_night_work_hours;
       END IF;
         
    --Holiday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.holiday_night_overtime_hours THEN
       v_holiday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.holiday_night_overtime_hours THEN
       v_holiday_night_ot := r1.holiday_night_overtime_hours;
       END IF;
         
    --Plublic holiday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r1.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r1.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := r1.public_holiday_night_ot_hours;
       END IF;
       
     IF v_month_ot_total_result - v_month_ot_limit < v_curent_ot_total_result THEN
       v_ot_before_over := v_curent_ot_total_result - (v_month_ot_total_result - v_month_ot_limit);
       IF r1.evening_meal_flag = 'Y' AND r1.shift_type_code = '1A' AND v_curent_ot_total_result <> r1.overtime_sum_hours THEN
         v_ot_before_over := v_ot_before_over + 0.5;
       END IF;
        calculate_ot(p_subsidiary_code    => p_subsidiary_code
                    ,p_date               => p_date
                    ,p_att_code           => r1.time_and_attendance_code
                    ,p_shift_code         => r1.shift_type_code
                    ,p_night_flag         => r1.night_shift_flag
                    ,p_dinner_check       => nvl(r1.evening_meal_flag, 'N')
                    ,p_working_start_time => r1.work_start_time
                    ,p_ot                 => v_ot_before_over
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
                    
      v_weekday_ot                := r1.weekday_overtime_hours         - v_ot150;
      v_holiday_ot                := r1.holiday_overtime_hours         - v_ot200;
      v_public_holiday_ot         := r1.public_holiday_overtime_hours  - v_ot300;
      v_weekday_night_ot          := r1.weekday_night_overtime_hours   - v_nt200;
      v_weekday_af_night_ot       := r1.weekday_ot_af_night_work_hours - v_nt210;
      v_holiday_night_ot          := r1.holiday_night_overtime_hours   - v_nt270;
      v_public_holiday_night_ot   := r1.public_holiday_night_ot_hours  - v_nt390;
     END IF;     
         
        IF p_item = 'weekday_ot'                       THEN          v_hours := v_weekday_ot;
          ELSIF p_item = 'holiday_ot'                  THEN          v_hours := v_holiday_ot;
          ELSIF p_item = 'public_holiday_ot'           THEN          v_hours := v_public_holiday_ot;
          ELSIF p_item = 'weekday_night_ot'            THEN          v_hours := v_weekday_night_ot;
          ELSIF p_item = 'weekday_af_night_ot'         THEN          v_hours := v_weekday_af_night_ot;
          ELSIF p_item = 'holiday_night_ot'            THEN          v_hours := v_holiday_night_ot;
          ELSIF p_item = 'public_holiday_night_ot'     THEN          v_hours := v_public_holiday_night_ot;
        END IF;
      END IF;
    END LOOP;
    
    ELSIF p_get_type = 'request_over' THEN
    --Caculate tb_att_special_ot_result_n
    FOR r2 IN emp_special LOOP
      SELECT NVL(MAX(cvh.result_value), 999999999) INTO v_month_ot_limit
        FROM   tb_pay_calc_var_value_n cvh
        WHERE  r2.time_and_attendance_date between TO_DATE(cvh.effective_start_yyyymmdd, 'YYYYMMDD') AND TO_DATE(cvh.effective_end_yyyymmdd, 'YYYYMMDD')
           AND cvh.payroll_calc_variable_id = (select MAX(payroll_calc_variable_id) from tb_pay_calc_var_n 
                                                      where subsidiary_code = 'LGDVN' 
                                                        and payroll_calc_variable_name = 'MONTH_OT_OVER');
      --v_month_ot_limit          := TO_NUMBER(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','MONTH_OT_LIMIT','A1',''));
      v_month_ot_total_result   := get_ot_total(r2.subsidiary_code, r2.employee_no, r2.time_and_attendance_date,r2.time_and_attendance_date,'month_total_ot_result');
      v_curent_ot_total_result := NVL((NVL(r2.weekday_overtime_hours, 0) + NVL(r2.holiday_overtime_hours, 0) + NVL(r2.public_holiday_overtime_hours, 0) + NVL(r2.weekday_night_overtime_hours, 0) + 
                  NVL(r2.weekday_ot_af_night_work_hours, 0) + NVL(r2.holiday_night_overtime_hours, 0) + NVL(r2.public_holiday_night_ot_hours, 0)), 0);
    IF v_month_ot_total_result > v_month_ot_limit THEN
    
    --Weekday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.weekday_overtime_hours THEN
       v_weekday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.weekday_overtime_hours THEN
       v_weekday_ot := r2.weekday_overtime_hours;
       END IF;
         
    --Holiday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.holiday_overtime_hours THEN
       v_holiday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.holiday_overtime_hours THEN
       v_holiday_ot := r2.holiday_overtime_hours;
       END IF;
    
    --Public holiday OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.public_holiday_overtime_hours THEN
       v_public_holiday_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.public_holiday_overtime_hours THEN
       v_public_holiday_ot := r2.public_holiday_overtime_hours;
       END IF;
         
    --Weekday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.weekday_night_overtime_hours THEN
       v_weekday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.weekday_night_overtime_hours THEN
       v_weekday_night_ot := r2.weekday_night_overtime_hours;
       END IF;
         
    --Weekday af night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.weekday_ot_af_night_work_hours THEN
       v_weekday_af_night_ot := r2.weekday_ot_af_night_work_hours;
       END IF;
         
    --Holiday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.holiday_night_overtime_hours THEN
       v_holiday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.holiday_night_overtime_hours THEN
       v_holiday_night_ot := r2.holiday_night_overtime_hours;
       END IF;
         
    --Plublic holiday night OT
    IF v_month_ot_total_result - v_month_ot_limit <= r2.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := v_month_ot_total_result - v_month_ot_limit;
     ELSIF v_month_ot_total_result - v_month_ot_limit > r2.public_holiday_night_ot_hours THEN
       v_public_holiday_night_ot := r2.public_holiday_night_ot_hours;
       END IF;
       
     IF v_month_ot_total_result - v_month_ot_limit < v_curent_ot_total_result THEN
       v_ot_before_over := v_month_ot_total_result - v_month_ot_limit;
       
       v_weekday_ot               := get_conv_ot_hour(ROUND((r2.weekday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_holiday_ot                := get_conv_ot_hour(ROUND((r2.holiday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_public_holiday_ot         := get_conv_ot_hour(ROUND((r2.public_holiday_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_weekday_night_ot         := get_conv_ot_hour(ROUND((r2.weekday_night_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_weekday_af_night_ot       := get_conv_ot_hour(ROUND((r2.weekday_ot_af_night_work_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_holiday_night_ot         := get_conv_ot_hour(ROUND((r2.holiday_night_overtime_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       v_public_holiday_night_ot  := get_conv_ot_hour(ROUND((r2.public_holiday_night_ot_hours / v_curent_ot_total_result) * v_ot_before_over ,3));
       
       v_ot_redundancy := (v_weekday_ot + v_weekday_night_ot + v_holiday_ot + v_weekday_af_night_ot + v_holiday_night_ot + v_public_holiday_ot + v_public_holiday_night_ot) - v_ot_before_over;
       IF v_ot_redundancy > 0 THEN 
         IF v_public_holiday_night_ot > v_ot_redundancy THEN v_public_holiday_night_ot := v_public_holiday_night_ot - v_ot_redundancy;
           ELSIF v_public_holiday_ot > v_ot_redundancy THEN v_public_holiday_ot := v_public_holiday_ot - v_ot_redundancy;
           ELSIF v_holiday_night_ot > v_ot_redundancy THEN v_holiday_night_ot := v_holiday_night_ot - v_ot_redundancy;
           ELSIF v_weekday_af_night_ot > v_ot_redundancy THEN v_weekday_af_night_ot := v_weekday_af_night_ot - v_ot_redundancy;
           ELSIF v_holiday_ot > v_ot_redundancy THEN v_holiday_ot := v_holiday_ot - v_ot_redundancy;
           ELSIF v_weekday_night_ot > v_ot_redundancy THEN v_weekday_night_ot := v_weekday_night_ot - v_ot_redundancy;
           ELSIF v_weekday_ot > v_ot_redundancy THEN v_weekday_ot := v_weekday_ot - v_ot_redundancy;
          END IF;
         END IF;
 
     END IF;     
         
        IF p_item = 'weekday_ot'                       THEN          v_hours := v_weekday_ot;
          ELSIF p_item = 'holiday_ot'                  THEN          v_hours := v_holiday_ot;
          ELSIF p_item = 'public_holiday_ot'           THEN          v_hours := v_public_holiday_ot;
          ELSIF p_item = 'weekday_night_ot'            THEN          v_hours := v_weekday_night_ot;
          ELSIF p_item = 'weekday_af_night_ot'         THEN          v_hours := v_weekday_af_night_ot;
          ELSIF p_item = 'holiday_night_ot'            THEN          v_hours := v_holiday_night_ot;
          ELSIF p_item = 'public_holiday_night_ot'     THEN          v_hours := v_public_holiday_night_ot;
        END IF;
        
        IF v_hours - FLOOR(v_hours) < 0.25 THEN v_hours := FLOOR(v_hours) ;     END IF;
        IF v_hours - FLOOR(v_hours) >= 0.25 AND v_hours - FLOOR(v_hours) < 0.75 THEN v_hours := FLOOR(v_hours) + 0.5; END IF;
        IF v_hours - FLOOR(v_hours) >= 0.75 THEN v_hours := FLOOR(v_hours) + 1;   END IF;
        
      END IF;
    END LOOP;
    END IF;  
    
    RETURN v_hours;

EXCEPTION
WHEN OTHERS THEN
    RETURN v_hours;

END get_over_month_ot_hours;

FUNCTION get_conv_ot_hour(p_ot_hour IN NUMBER)
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_conv_ot_hour
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 2021/03/26     HMT                Initialized
/*
/******************************************************************************/
RETURN NUMBER
IS
    x_return_value NUMBER := 0;

BEGIN

    IF p_ot_hour - FLOOR(p_ot_hour) < 0.25 THEN x_return_value := FLOOR(p_ot_hour) ;     END IF;
    IF p_ot_hour - FLOOR(p_ot_hour) >= 0.25 AND p_ot_hour - FLOOR(p_ot_hour) < 0.75 THEN x_return_value := FLOOR(p_ot_hour) + 0.5; END IF;
    IF p_ot_hour - FLOOR(p_ot_hour) >= 0.75 THEN x_return_value := FLOOR(p_ot_hour) + 1;   END IF;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN 0;

END get_conv_ot_hour;

FUNCTION get_conv_hour(p_text_hour IN VARCHAR2)
/******************************************************************************/
/*
/* Project      : LGDVH LOCAL HR Project
/* Module       :
/* Program Name : get_conv_hour
/* Description  :
/*               p_text_hour : 08:00
/*               return : 8
/*
/* Reference by :
/* Program History
/*------------------------------------------------------------------------------
/* Date          In Charge           Description
/*------------------------------------------------------------------------------
/* 02-OCT-2017                       Initialized
/*
/******************************************************************************/
RETURN NUMBER
IS
    x_return_value NUMBER := C_DAY_WORKING_START_HOUR;

BEGIN

    SELECT TO_NUMBER(SUBSTR(p_text_hour, 1, INSTR(p_text_hour, ':')-1) )
          +CASE WHEN INSTR(p_text_hour, ':30') > 0 THEN 0.5 ELSE 0 END
    INTO   x_return_value
    FROM   dual;

    RETURN x_return_value;

EXCEPTION
WHEN OTHERS THEN
    RETURN C_DAY_WORKING_START_HOUR;

END get_conv_hour;


PROCEDURE validate_calculation(p_ret_code           OUT NUMBER
                              ,p_ret_message        OUT VARCHAR2
                              ,p_subsidiary_code    IN VARCHAR2
                              ,p_date               IN DATE
                              ,p_shift_code         IN VARCHAR2
                              ,p_night_flag         IN VARCHAR2
                              ,p_dinner_check       IN VARCHAR2
                              ,p_working_start_time IN VARCHAR2
                              ,p_ot                 IN NUMBER
                              )
IS

    x_cnt         NUMBER := 0; -- Calendar Count

BEGIN

      -- Over Time Check
      IF p_ot > 24 THEN
          p_ret_code    := 1;
          p_ret_message := 'Over time cannot be over 24 Hours';
          RETURN ;

      END IF;

      -- Working Calendar Check
      IF p_date IS NOT NULL THEN

          BEGIN
              SELECT COUNT(*)
              INTO   x_cnt
              FROM   tb_att_calendar_n tac
              WHERE  1 = 1
              AND    tac.subsidiary_code = p_subsidiary_code
              AND    tac.time_and_attendance_date = p_date;
          END;

          IF x_cnt = 0 THEN
              p_ret_code    := 1;
              p_ret_message := 'Planed date is not existed in Calendar';
              RETURN;
          END IF;

      END IF;

       p_ret_code    := 0;
       p_ret_message := '';

EXCEPTION
WHEN OTHERS THEN
    p_ret_code    := 1;
    p_ret_message := TO_CHAR(SQLCODE);

END validate_calculation;


-- Validation ??? ??? ??? ???, ???????? ??
PROCEDURE put_ot_validation (p_work_type          IN VARCHAR2,
                             p_employee_no        IN VARCHAR2,
                             p_subsidiary_code    IN VARCHAR2,
                             p_date               IN DATE,
                             p_att_code           IN VARCHAR2,
                             p_shift_code         IN VARCHAR2,
                             p_night_flag         IN VARCHAR2,
                             p_dinner_check       IN VARCHAR2,
                             p_working_start_time IN VARCHAR2,
                             p_lateness           IN NUMBER,
                             p_leaving_early      IN NUMBER,
                             p_going_out          IN NUMBER,
                             p_ot                 IN NUMBER,
                             p_ot150              IN NUMBER,
                             p_ot200              IN NUMBER,
                             p_ot300              IN NUMBER,
                             p_nt200              IN NUMBER,
                             p_nt210              IN NUMBER,
                             p_nt270              IN NUMBER,
                             p_nt390              IN NUMBER,
                             p_nt30               IN NUMBER
                            )
IS
--PRAGMA AUTONOMOUS_TRANSACTION;

v_validation_seq     NUMBER;

BEGIN

    -- 2018.01.15 ??? : ??? ???? ??
    RETURN ;
/*
    SELECT tb_att_ot_validation_seq.NEXTVAL INTO v_validation_seq FROM dual;

    INSERT INTO tb_att_ot_validation_n
      (
        validation_seq,                 work_type,
        employee_no,                    subsidiary_code,                  time_and_attendance_date,       shift_type_code,
        time_and_attendance_code,       night_shift_flag,                 work_start_time,                evening_meal_flag,
        overtime_sum_hours,             weekday_overtime_hours,           holiday_overtime_hours,         public_holiday_overtime_hours,
        weekday_night_overtime_hours,   weekday_ot_af_night_work_hours,   holiday_night_overtime_hours,   public_holiday_night_ot_hours,
        normal_night_overtime_hours,    tardy_hours,                      early_leave_hours,              going_out_hours,
        creation_date
      )
    VALUES
      ( v_validation_seq,               p_work_type,
        p_employee_no,                  p_subsidiary_code,                TO_CHAR(p_date, 'DD/MM/YYYY'),  p_shift_code,
        p_att_code,                     p_night_flag,                     p_working_start_time,           p_dinner_check,
        p_ot,                           p_ot150,                          p_ot200,                        p_ot300,
        p_nt200,                        p_nt210,                          p_nt270,                        p_nt390,
        p_nt30,                         p_lateness,                       p_leaving_early,                p_going_out,
        SYSDATE
      );
      
    COMMIT;
*/
EXCEPTION
WHEN OTHERS THEN
    --ROLLBACK;
    NULL;
    
END put_ot_validation;


END lgvatt_ot_calculation_pkg;
/**********************************************************/
/* End of Program
/**********************************************************/
