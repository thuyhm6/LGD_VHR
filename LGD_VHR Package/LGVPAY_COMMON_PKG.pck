CREATE OR REPLACE PACKAGE VHR_MGR.LGVPAY_COMMON_PKG IS

FUNCTION get_planned_item_value( p_employee_no      IN VARCHAR2
                               , p_effective_date   IN DATE
                               , p_payroll_item_id  IN NUMBER
                               , p_item_detail_name IN VARCHAR2 ) RETURN VARCHAR2 ;
                               
FUNCTION get_chcek_planned_item( p_employee_no     IN VARCHAR2
                               , p_effective_date  IN DATE
                               , p_payroll_item_id IN NUMBER ) RETURN VARCHAR2 ;
                               
FUNCTION get_planned_item_value( p_employee_no       IN VARCHAR2
                               , p_effective_date    IN DATE
                               , p_payroll_item_name IN VARCHAR2
                               , p_item_detail_name  IN VARCHAR2
                                , p_subsidiary_code   in VARCHAR2
                                ) RETURN VARCHAR2 ;
                               
FUNCTION get_chcek_planned_item( p_employee_no       IN VARCHAR2
                               , p_effective_date    IN DATE
                               , p_payroll_item_name IN VARCHAR2
                               , p_subsidiary_code   in VARCHAR2) RETURN VARCHAR2 ;

FUNCTION get_calc_var_value( p_subsidiary_code    IN VARCHAR2
                           , p_payroll_calc_variable_name IN VARCHAR2
                           , p_effective_yyyymmdd IN VARCHAR2) RETURN VARCHAR2;
                           
FUNCTION get_hardship_deduction_amount( p_employee_no    IN VARCHAR2
                           , p_payroll_calculation_exec_id IN NUMBER
                           , p_payroll_item_id IN NUMBER
                           , p_period_id IN NUMBER
                           ) RETURN VARCHAR2;
end LGVPAY_COMMON_PKG;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.LGVPAY_COMMON_PKG IS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Function Name    : get_planned_item_value                                  */
/* Description    :  ???? ?? ??? ?? ???? ??? ?? ??
/*                   ?? ?????? ?? ???? function (??id? )     */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                  p_employee_no          in     varchar2    ??            */
/*                  p_effective_date       in     date        ????        */
/*                  p_payroll_item_id      in     number      ??id          */
/*                  p_item_detail_name     in     varchar2     ??? ???  */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/ 
FUNCTION get_planned_item_value( p_employee_no      IN VARCHAR2
                               , p_effective_date   IN DATE
                               , p_payroll_item_id  IN NUMBER
                               , p_item_detail_name IN VARCHAR2 ) RETURN VARCHAR2 IS 
                                
    v_return            tb_pay_payment_plan_detail_n.apply_target_value%TYPE;
    v_detail_type_code  VARCHAR2(10);
    
BEGIN
     --????? charater?? ???? ??
     SELECT a.pay_calc_rslt_detail_type_code
     INTO   v_detail_type_code
     FROM   tb_pay_item_detail_n a
     WHERE  a.payroll_item_id        = p_payroll_item_id
     AND    a.additional_input_value =p_item_detail_name
     ;
     
     
     IF v_detail_type_code IN ('A','N') THEN 
         /* ??? ?? ?? ??(??, ??) ? sum?? ??? max? ?? ????. */
         /* parameter? ??? effective date? ?? ???? ?? ?? ?? return ??. */
         SELECT to_char(SUM(nvl(ppdn.apply_target_value,0)))                
         INTO   v_return
         FROM   tb_pay_item_payment_plan_n    ipp
               ,tb_pay_payment_plan_detail_n  ppdn
               ,tb_pay_item_detail_n          pid
         WHERE  ipp.employee_no                    = p_employee_no
         AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
         AND    ipp.payroll_item_id                = p_payroll_item_id
         AND    ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
         AND    ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id 
         AND    pid.additional_input_value         = p_item_detail_name
         GROUP BY pid.pay_calc_rslt_detail_type_code
         ;
     ELSE
         SELECT MAX(ppdn.apply_target_value) 
         INTO   v_return
         FROM   tb_pay_item_payment_plan_n    ipp
               ,tb_pay_payment_plan_detail_n  ppdn
               ,tb_pay_item_detail_n          pid
         WHERE  ipp.employee_no                    = p_employee_no
         AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
         AND    ipp.payroll_item_id                = p_payroll_item_id
         AND    ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
         AND    ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id 
         AND    pid.additional_input_value         = p_item_detail_name
         GROUP BY pid.pay_calc_rslt_detail_type_code
         ;
     END IF;
                     
                     
     RETURN v_return;

EXCEPTION
    WHEN OTHERS THEN 
        v_return := NULL; 
        RETURN  v_return;                                 
END;  

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Function Name    : get_planned_item_value                                  */
/* Description    :  ???? ?? ??? ?? ???? ??? ?? ??
/*                   ?? ?????? ?? ???? function  (?????)   */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                  p_employee_no          in     varchar2    ??            */
/*                  p_effective_date       in     date        ????        */
/*                  p_payroll_item_name    in     varchar2    ???          */
/*                  p_item_detail_name     in     varchar2     ??? ???  */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/ 
FUNCTION get_planned_item_value( p_employee_no       IN VARCHAR2
                               , p_effective_date    IN DATE
                               , p_payroll_item_name IN VARCHAR2
                               , p_item_detail_name  IN VARCHAR2
                               , p_subsidiary_code   IN VARCHAR2 ) RETURN VARCHAR2 IS  
                               
    v_return  tb_pay_payment_plan_detail_n.apply_target_value%TYPE;
    v_detail_type_code   VARCHAR2(10);
    
BEGIN
    --????? charater?? ???? ??
    SELECT pid.pay_calc_rslt_detail_type_code
    INTO   v_detail_type_code
    FROM   tb_pay_payroll_item_m ppi
         , tb_pay_item_detail_n pid
    WHERE  ppi.payroll_item_name      = p_payroll_item_name
    AND    ppi.subsidiary_code        = p_subsidiary_code
    AND    pid.payroll_item_id        = ppi.payroll_item_id
    AND    pid.additional_input_value = p_item_detail_name
    ;
     
    IF v_detail_type_code IN ('A','N') THEN 
        /* ??? ?? ?? ??(??, ??) ? sum?? ??? max? ?? ????. */
        /* parameter? ??? effective date? ?? ???? ?? ?? ?? return ??. */
        SELECT to_char(SUM(nvl(ppdn.apply_target_value,0)))
        INTO   v_return
        FROM   tb_pay_item_payment_plan_n ipp
              ,tb_pay_payment_plan_detail_n ppdn
              ,tb_pay_item_detail_n pid
              ,tb_pay_payroll_item_m ppi
        WHERE  ppi.payroll_item_name              = p_payroll_item_name
        AND    ppi.subsidiary_code                = p_subsidiary_code
        AND    TO_CHAR(p_effective_date,'YYYYMMDD')   BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231')
        AND    ipp.employee_no                    = p_employee_no
        AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
        AND    ipp.payroll_item_id                = ppi.payroll_item_id
        AND    ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
        AND    ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id 
        AND    pid.additional_input_value         = p_item_detail_name 
        GROUP BY pid.pay_calc_rslt_detail_type_code
        ;
    ELSE
        /* ??? ?? ?? ??(??, ??) ? sum?? ??? max? ?? ????. */
        /* parameter? ??? effective date? ?? ???? ?? ?? ?? return ??. */
        SELECT MAX(ppdn.apply_target_value)
        INTO   v_return
        FROM   tb_pay_item_payment_plan_n ipp
              ,tb_pay_payment_plan_detail_n ppdn
              ,tb_pay_item_detail_n pid
              ,tb_pay_payroll_item_m ppi
        WHERE  ppi.payroll_item_name              = p_payroll_item_name
        AND    ppi.subsidiary_code                = p_subsidiary_code
        AND    TO_CHAR(p_effective_date,'YYYYMMDD')   BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231')
        AND    ipp.employee_no                    = p_employee_no
        AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
        AND    ipp.payroll_item_id                = ppi.payroll_item_id
        AND    ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
        AND    ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id 
        AND    pid.additional_input_value         = p_item_detail_name 
        GROUP BY pid.pay_calc_rslt_detail_type_code
        ;
    END IF;                
                     
    RETURN v_return;

EXCEPTION
    WHEN OTHERS THEN 
        v_return := NULL; 
        RETURN  v_return;                                 
END; 

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Function Name    : get_chcek_planned_item                                  */
/* Description    :  ???? ?? ??? ?? ???? ??? ??? ??? 
/*                   flag ? return?? function  (??id ????)           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                  p_employee_no          in     varchar2    ??            */
/*                  p_effective_date       in     date        ????        */
/*                  p_payroll_item_id      in     number      ??id          */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/ 
FUNCTION get_chcek_planned_item( p_employee_no     IN VARCHAR2
                               , p_effective_date  IN DATE
                               , p_payroll_item_id IN NUMBER) RETURN VARCHAR2 IS
    
    v_return  VARCHAR2(1) :=  'N'; 
    
BEGIN
  /* pay value ??? ??? ??????? ????. */
  /* pay value ? ??????? ?? ? ??? ?? ????? return ???? ?????
     ?? ??? ? ??? ?? ?????. */
     SELECT 'Y'
     INTO   v_return
     FROM   dual
     WHERE  EXISTS ( SELECT 1
                     FROM   tb_pay_item_payment_plan_n    ipp
                           , tb_pay_payment_plan_detail_n ppdd
                           , tb_pay_item_detail_n         pid
                     WHERE  ipp.employee_no                    = p_employee_no
                     AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
                     AND    ipp.payroll_item_id                = p_payroll_item_id
                     AND    pid.payroll_item_id                = ipp.payroll_item_id
                     AND    pid.additional_input_value         = 'PAY_VALUE'
                     AND    ppdd.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
                     AND    ppdd.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id
                     AND    ppdd.apply_target_value IS NOT NULL
                    );
     RETURN v_return;

EXCEPTION
    WHEN OTHERS THEN 
        v_return := 'N';  
        RETURN v_return;                                 
END; 

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Function Name    : get_chcek_planned_item                                  */
/* Description    :  ???? ?? ??? ?? ???? ??? ??? ??? 
/*                   flag ? return?? function  (??id ????)           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/*                  p_employee_no          in     varchar2    ??            */
/*                  p_effective_date       in     date        ????        */
/*                  p_payroll_item_name    in     varchar2    ???          */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/ 


FUNCTION get_chcek_planned_item(  p_employee_no       IN VARCHAR2
                                , p_effective_date    IN DATE
                                , p_payroll_item_name IN VARCHAR2
                                , p_subsidiary_code   in VARCHAR2) RETURN VARCHAR2 IS
    
    v_return  VARCHAR2(1) :=  'N'; 
    
BEGIN
  /* pay value ??? ??? ??????? ????. */
  /* pay value ? ??????? ?? ? ??? ?? ????? return ???? ?????
     ?? ??? ? ??? ?? ?????. */  
     SELECT 'Y'
     INTO   v_return
     FROM   dual
     WHERE  EXISTS ( SELECT 1
                     FROM   tb_pay_item_payment_plan_n    ipp
                           , tb_pay_payment_plan_detail_n ppdd
                           , tb_pay_item_detail_n         pid
                           , tb_pay_payroll_item_m        ppi
                     WHERE  ppi.payroll_item_name              = p_payroll_item_name
                     AND    ppi.subsidiary_code                = p_subsidiary_code
                     AND    to_char(p_effective_date,'yyyymmdd')  BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231')
                     AND    employee_no                        = p_employee_no
                     AND    trunc(p_effective_date)  BETWEEN trunc(ipp.apply_start_date) AND trunc(ipp.apply_end_date)
                     AND    ipp.payroll_item_id                = ppi.payroll_item_id
                     AND    pid.payroll_item_id                = ipp.payroll_item_id
                     AND    pid.additional_input_value         = 'PAY_VALUE'
                     AND    ppdd.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
                     AND    ppdd.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id
                     AND    ppdd.apply_target_value IS NOT NULL
                    );
     RETURN v_return;

EXCEPTION
    WHEN OTHERS THEN 
        v_return := 'N';  
        RETURN v_return;                                 
END; 

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_calc_var_value                                       */
/* Description    :  Select Payroll Variable Value                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_subsidiary_code            in     varchar2   Subsidiary Code
/*                   p_payroll_calc_variable_name in     varchar2   Variabale Name 
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/17            Initial Release                                      */
/******************************************************************************/
FUNCTION get_calc_var_value( p_subsidiary_code            IN VARCHAR2
                           , p_payroll_calc_variable_name IN VARCHAR2
                           , p_effective_yyyymmdd         IN VARCHAR2) RETURN VARCHAR2 IS
                           
    v_result_value VARCHAR2(1000);                           
  
BEGIN
    SELECT  pcvv.result_value
    INTO    v_result_value
    FROM    tb_pay_calc_var_n pcv
           ,tb_pay_calc_var_value_n pcvv
    WHERE   pcv.subsidiary_code            = p_subsidiary_code
    AND     pcv.payroll_calc_variable_name = p_payroll_calc_variable_name
    AND     pcvv.payroll_calc_variable_id  = pcv.payroll_calc_variable_id
    AND     p_effective_yyyymmdd BETWEEN pcvv.effective_start_yyyymmdd  AND pcvv.effective_end_yyyymmdd
    ;
    
    RETURN v_result_value;
EXCEPTION
    WHEN OTHERS THEN 
          RETURN '';    
    
    
END; 

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_calc_var_value                                       */
/* Description    :  Select Payroll Variable Value                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no            in     varchar2   Subsidiary Code
/*                   p_payroll_calculation_exec_id in     Number   Variabale Name 
/*                   p_payroll_item_id in     Number   effective_yyyymmdd 
/*                   p_period_id in     Number   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2024/08/22            Initial Release                                      */
/******************************************************************************/
FUNCTION get_hardship_deduction_amount( p_employee_no            IN VARCHAR2
                           , p_payroll_calculation_exec_id       IN NUMBER
                           , p_payroll_item_id                   IN NUMBER
                           , p_period_id                         IN NUMBER
                           ) RETURN VARCHAR2 IS
                           
    v_result_value VARCHAR2(1000);
    perfect_work_hours NUMBER;
    deduct_hours NUMBER;
    deduct_hour NUMBER;
    v_total_amount VARCHAR2(1000);
    v_subsidiary_code VARCHAR2(1000);
    v_total_period NUMBER;
    v_yyyymm           tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    
    CURSOR c_cur IS
    SELECT a.basis_start_date
         , a.basis_end_date
         , a.payment_base_amount
         , a.increase_and_decrease_rate
         , a.payroll_calculation_exec_id
         , a.employee_no
         , a.payroll_item_id
    FROM   tb_pay_detail_calc_t a
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    a.employee_no                 = p_employee_no
    AND    a.payroll_item_id             = p_payroll_item_id
    ;                           
  
BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.subsidiary_code
    INTO   v_yyyymm,
           v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;  
    
    --get perfect work hours
    SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours'))
        INTO   v_total_period,
               perfect_work_hours
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm; 
    
    v_result_value := 0;
       
    FOR c IN c_cur
    LOOP
          deduct_hours := 0;
 
          FOR c_r IN (SELECT ( c.basis_start_date -1 + rownum)  ymd
                      FROM   dual
                      CONNECT BY LEVEL <= c.basis_end_date - c.basis_start_date +1 )
          LOOP
              
              SELECT nvl(SUM(nvl(r.tardy_hours,0)) + SUM(nvl(r.going_out_hours,0)) + SUM(nvl(r.early_leave_hours,0)),0) DEDUC_HOURS
              INTO deduct_hour
              FROM TB_ATT_RESULT_N R
              WHERE r.employee_no = p_employee_no
              AND  r.time_and_attendance_date = c_r.ymd
              AND   r.time_and_attendance_yyyymm = v_yyyymm;
              
              IF deduct_hour > 0  THEN
                 deduct_hours := deduct_hours + deduct_hour;
              END IF;

          END LOOP;
          
          BEGIN
              SELECT deduct_hours / perfect_work_hours * c.payment_base_amount
              INTO   v_total_amount
              FROM   DUAL;
          EXCEPTION
              WHEN OTHERS THEN
                  v_total_amount := 0;
          END;

          v_result_value := v_result_value + v_total_amount;          
    END LOOP;
    RETURN nvl(round(v_result_value), 0);
EXCEPTION
    WHEN OTHERS THEN 
          RETURN '';    
    
    
END; 

end LGVPAY_COMMON_PKG;
/
