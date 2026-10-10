create or replace package vhr_mgr.lgvpay_aggr_pkg is
PROCEDURE calculation_aggr(p_period_id                   IN NUMBER
                          ,p_subsidiary_code             IN VARCHAR2
                          ,p_payroll_calculation_exec_id IN NUMBER
                          ,p_employee_no                 IN VARCHAR2
                          ,p_user_id                     IN VARCHAR2
                          ,p_payroll_item_id             IN NUMBER);


FUNCTION get_aggr_result(p_payroll_item_aggregate_name   IN VARCHAR2
                       , p_aggregate_cycle_type_code     IN VARCHAR2
                       , p_payroll_calculation_exec_id   IN NUMBER
                       , p_employee_no                   IN VARCHAR2
                       --< 20181001 KTH Start Add
                       , p_retropay_target_yyyymm        IN VARCHAR2 DEFAULT NULL
                       -->
                       ) RETURN NUMBER ;                          
                          
end lgvpay_aggr_pkg;
/
create or replace package body vhr_mgr.lgvpay_aggr_pkg IS

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_aggr                                         */
/* Description    :  payroll 이 run되고 난 후, run result를 항목별로 집계하는 */
/*                   프로그램                                                 */
/*                   aggregate 별로 Type이 Class인지  item인지를 구별해서     */
/*                   Class 는 payroll Class 별로, item은 payroll item별로     */
/*                   가져와서 금액을 계산해서 집계 테이블에 넣는다.           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09   SonSuyang     Initial Release                                 */
/* 2018/09/28   KimTaehyun    Separation Retroactive Payroll                  */
/******************************************************************************/
--집게하는 프로그램 
PROCEDURE calculation_aggr(p_period_id                   IN NUMBER
                          ,p_subsidiary_code             IN VARCHAR2
                          ,p_payroll_calculation_exec_id IN NUMBER
                          ,p_employee_no                 IN VARCHAR2
                          ,p_user_id                     IN VARCHAR2
                          ,p_payroll_item_id             IN NUMBER) IS
  /* 해당 법인에 셋업되어있는 , 집계 항목 전체 쿼리 */                          
    CURSOR c_aggr_cur ( c_basis_end_yyyymmdd IN VARCHAR2) IS
    SELECT  pia.payroll_item_aggregate_id
          , pia.payroll_aggregate_type_code
          , pia.payroll_item_aggregate_name
    FROM    tb_pay_payroll_item_m     ppi 
          , tb_pay_item_aggr_n        pia 
          , tb_pay_item_aggr_detail_n piad
    WHERE  ppi.payroll_item_id             = p_payroll_item_id
    AND    pia.payroll_aggregate_type_code = 'ITEM' 
    AND    piad.Payroll_Item_Id            = ppi.payroll_item_id
    AND    piad.payroll_item_aggregate_id  = pia.payroll_item_aggregate_id
    AND    c_basis_end_yyyymmdd BETWEEN piad.effective_start_yyyymmdd AND piad.effective_end_yyyymmdd
    UNION ALL
    SELECT pia.payroll_item_aggregate_id
         , pia.payroll_aggregate_type_code
         , pia.payroll_item_aggregate_name
    FROM   tb_pay_calc_mthd_n         pcm
         , tb_pay_item_aggr_n         pia 
         , tb_pay_item_aggr_detail_n  piad
    WHERE  pcm.payroll_item_id               = p_payroll_item_id
    AND    pia.subsidiary_code               = p_subsidiary_code
    AND    pia.payroll_aggregate_type_code   = 'METHOD'
    AND    piad.payroll_item_aggregate_id    = pia.payroll_item_aggregate_id
    AND    piad.pay_item_classification_code = pcm.payroll_calc_method_code
    AND    c_basis_end_yyyymmdd BETWEEN piad.effective_start_yyyymmdd AND piad.effective_end_yyyymmdd
    UNION ALL
    SELECT  pia.payroll_item_aggregate_id
          , pia.payroll_aggregate_type_code
          , pia.payroll_item_aggregate_name
    FROM    tb_pay_payroll_item_m ppi 
          , tb_pay_item_aggr_n   pia 
          , tb_pay_item_aggr_detail_n piad
    WHERE  ppi.payroll_item_id               = p_payroll_item_id
    AND    pia.payroll_aggregate_type_code   = 'CLASS' 
    AND    piad.Pay_Item_Classification_Code = ppi.Pay_Item_Classification_Code
    AND    piad.payroll_item_aggregate_id    = pia.payroll_item_aggregate_id
    AND    c_basis_end_yyyymmdd BETWEEN piad.effective_start_yyyymmdd AND piad.effective_end_yyyymmdd  
  ;
  
  
  /* 해당 법인에 셋업되어 있는 cycle정보를 가져온다. */
  CURSOR c_aggr_cycle( c_payroll_item_aggregate_id IN NUMBER) IS
  SELECT cycle.payroll_item_aggregate_id
        ,cycle.aggregate_cycle_type_code
  FROM   tb_pay_item_aggr_cycle_n cycle 
  WHERE  cycle.payroll_item_aggregate_id = c_payroll_item_aggregate_id
  ;
  
  
  /*집계기준이 class인지 item인지에 따라..*/
  CURSOR c_cur_aggr_item ( c_payroll_item_aggregate_id IN NUMBER, c_end_yyyymmdd IN VARCHAR2  ) IS
  SELECT  item.payroll_item_id
         ,item_d.payroll_item_detail_detail_id
         ,decode(code.code_data1_value,'ADD',1,'SUBTRACTION',-1,0) muliplier        
  FROM    tb_pay_item_aggr_n aggr
         ,tb_pay_item_aggr_detail_n aggr_d
         ,tb_pay_payroll_item_m item  
         ,tb_pay_item_detail_n item_d  
         ,lgcom_common_code_c  code                 
  WHERE   aggr.payroll_item_aggregate_id        = c_payroll_item_aggregate_id
  AND     aggr_d.payroll_item_aggregate_id     = aggr.payroll_item_aggregate_id
  AND     c_end_yyyymmdd BETWEEN aggr_d.effective_start_yyyymmdd AND aggr_d.effective_end_yyyymmdd
  AND     aggr.payroll_aggregate_type_code     = 'CLASS' --class 인 경우 class 인 정보를 모아서 가져온다. 
  AND     item.pay_item_classification_code    = aggr_d.pay_item_classification_code
  AND     c_end_yyyymmdd BETWEEN item.start_yyyymmdd AND item.end_yyyymmdd
  AND     item_d.payroll_item_id               = item.payroll_item_id
  AND     item_d.additional_input_value        = 'PAY_VALUE'
  AND     code.code_type_code                  = 'LGDVHR_PAY_CLASS_TYPE_CODE'
  AND     code.common_code                     = item.pay_item_classification_code
  
  UNION ALL
  SELECT  item.payroll_item_id
         ,item_d.payroll_item_detail_detail_id
         ,decode(code.code_data1_value,'ADD',1,'SUBTRACTION',-1) muliplier         
  FROM    tb_pay_item_aggr_n aggr
         ,tb_pay_item_aggr_detail_n aggr_d
         ,tb_pay_payroll_item_m item  
         ,tb_pay_item_detail_n item_d  
         ,lgcom_common_code_c  code                    
  WHERE   aggr.payroll_item_aggregate_id       = c_payroll_item_aggregate_id
  AND     aggr_d.payroll_item_aggregate_id     = aggr.payroll_item_aggregate_id
  AND     c_end_yyyymmdd BETWEEN aggr_d.effective_start_yyyymmdd AND aggr_d.effective_end_yyyymmdd
  AND     aggr.payroll_aggregate_type_code     = 'ITEM' --class 인 경우 class 인 정보를 모아서 가져온다. 
  AND     item.payroll_item_id                 = aggr_d.payroll_item_id
  AND     c_end_yyyymmdd BETWEEN item.start_yyyymmdd AND item.end_yyyymmdd
  AND     item_d.payroll_item_id               = item.payroll_item_id
  AND     item_d.payroll_item_detail_detail_id = aggr_d.payroll_item_detail_detail_id  
  AND     code.code_type_code                  = 'LGDVHR_PAY_CLASS_TYPE_CODE'
  AND     code.common_code                     = item.pay_item_classification_code
  UNION ALL
  SELECT  item.payroll_item_id
         ,item_d.payroll_item_detail_detail_id
         ,decode(code.code_data1_value,'ADD',1,'SUBTRACTION',-1,0) muliplier         
  FROM   tb_pay_item_aggr_n         aggr
        ,tb_pay_item_aggr_detail_n  aggr_d
        ,tb_pay_payroll_item_m      item  
        ,tb_pay_item_detail_n       item_d
        ,tb_pay_calc_mthd_n         mthd 
        ,lgcom_common_code_c  code                  
  WHERE   aggr.payroll_item_aggregate_id       = c_payroll_item_aggregate_id
  AND     aggr_d.payroll_item_aggregate_id     = aggr.payroll_item_aggregate_id
  AND     c_end_yyyymmdd BETWEEN aggr_d.effective_start_yyyymmdd AND aggr_d.effective_end_yyyymmdd
  AND     aggr.payroll_aggregate_type_code     = 'METHOD' --Method 인 경우 급여항목의 method 값을 기준으로 가져온다. 
  AND     c_end_yyyymmdd BETWEEN item.start_yyyymmdd AND item.end_yyyymmdd
  AND     item_d.payroll_item_id               = item.payroll_item_id
  AND     item_d.additional_input_value        = 'PAY_VALUE'
  AND     item.payroll_item_id                 = mthd.payroll_item_id
  AND     mthd.payroll_calc_method_code        = aggr_d.pay_item_classification_code  
  AND     mthd.payroll_apply_flag              = 'Y'    -- Aggregate 가 method 인 경우에는 해당 속성이 y인 값만 가져와서 집계한다.
  AND     code.code_type_code                  = 'LGDVHR_PAY_CLASS_TYPE_CODE'  
  AND     code.common_code                     = item.pay_item_classification_code
  ;
  
  v_amount                     NUMBER :=0;
  v_sum                        NUMBER := 0;
  v_end_yyyymmdd               VARCHAR2(20);
  v_payroll_calc_period_value  VARCHAR2(20);
  v_retroactive_flag           VARCHAR2(1);
  v_err_buf                    VARCHAR2(4000);
   
  BEGIN
      --
      SELECT  pcp.end_yyyymmdd
              --< 20181001 KTH Start Add
             ,pcp.payroll_calc_period_value 
              -->
      INTO    v_end_yyyymmdd
             ,v_payroll_calc_period_value
      FROM    tb_pay_calc_period_basis_n pcp
      WHERE   pcp.payroll_calculation_period_id = p_period_id
      ;
      
    
      FOR c IN c_aggr_cur(v_end_yyyymmdd)
      LOOP     
          FOR c_cycle IN  c_aggr_cycle( c.payroll_item_aggregate_id )
          LOOP 
            
              v_sum :=0;
              
              FOR c_summary in c_cur_aggr_item (  c.payroll_item_aggregate_id, v_end_yyyymmdd )
              LOOP
                
              v_amount := 0;
                   
          --1) RUN일때는 해당 EXEC_ID 에 대한 내역만 가져온다.
              IF c_cycle.aggregate_cycle_type_code = 'RUN' THEN
                  
                  --< 20180928 KTH Start Add
                  -- Seperation Retroactive Payroll
                  SELECT NVL(pce.retroactive_flag,'N')
                  INTO   v_retroactive_flag
                  FROM   tb_pay_calc_exec_n pce
                  WHERE  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id;
                  
                  IF v_retroactive_flag = 'N' THEN
                  -->
                      SELECT nvl(SUM(res.result_value*c_summary.muliplier),0)
                      INTO   v_amount
                      FROM   tb_pay_calc_result_n res
                      WHERE  res.payroll_calculation_exec_id    = p_payroll_calculation_exec_id
                      AND    res.employee_no                    = p_employee_no
                      AND    res.payroll_item_id                = c_summary.payroll_item_id
                      AND    res.payroll_item_detail_detail_id  = c_summary.payroll_item_detail_detail_id
                      ;
                  --< 20180928 KTH Start Add    
                  ELSE
                  
                      SELECT nvl(SUM(rpr.result_value*c_summary.muliplier),0)
                      INTO   v_amount
                      FROM   tb_retro_pay_calc_result_n rpr
                      WHERE  rpr.payroll_calculation_exec_id    = p_payroll_calculation_exec_id
                      AND    rpr.employee_no                    = p_employee_no
                      AND    rpr.payroll_item_id                = c_summary.payroll_item_id
                      AND    rpr.payroll_item_detail_detail_id  = c_summary.payroll_item_detail_detail_id
                      AND    rpr.retroactive_pay_target_yyyymm  = v_payroll_calc_period_value
                      ;
                  END IF;
                  -->
                                    
                  
              /* We don't have to use this logic.
                 in our system, not yet there is no request for summary of month or year 
                 and this logic cac effect on calculation speed */    
              /*ELSIF c_cycle.aggregate_cycle_type_code = 'MONTH' THEN
                  SELECT nvl(SUM(res.result_value*c_summary.muliplier),0)
                  INTO   v_amount
                  FROM   tb_pay_calc_period_basis_n p
                        ,tb_pay_calc_period_basis_n p1
                        ,tb_pay_calc_exec_n exec
                        ,tb_pay_calc_result_n res
                  WHERE  p.payroll_calculation_period_id = p_period_id
                  AND    p1.end_yyyymmdd BETWEEN substr(p.end_yyyymmdd,1,6)||'01'  AND to_char(last_day(TO_date(p.end_yyyymmdd,'yyyymmdd')),'yyyymmdd')
                  AND    exec.basis_date BETWEEN to_date(p1.start_yyyymmdd,'yyyymmdd') AND  TO_date(p1.end_yyyymmdd,'yyyymmdd')
                  AND    res.payroll_calculation_exec_id  = exec.payroll_calculation_exec_id
                  AND    res.employee_no  = p_employee_no
                  AND    res.payroll_item_id = c_summary.payroll_item_id
                  AND    res.payroll_item_detail_detail_id  = c_summary.payroll_item_detail_detail_id
                  ;
              ELSIF  c_cycle.aggregate_cycle_type_code = 'YEAR' THEN
                            
                                      
                  SELECT nvl(SUM(res.result_value*c_summary.muliplier),0)
                  INTO   v_amount
                  FROM   tb_pay_calc_period_basis_n p
                        ,tb_pay_calc_period_basis_n p1
                        ,tb_pay_calc_exec_n exec
                        ,tb_pay_calc_result_n res
                  WHERE  p.payroll_calculation_period_id = p_period_id
                  AND    p1.end_yyyymmdd BETWEEN TO_CHAR(TRUNC(to_date(p.end_yyyymmdd,'yyyymmdd'),'yyyy'),'YYYYMMDD')  AND TO_CHAR(TRUNC(to_date(p.end_yyyymmdd,'yyyymmdd'),'yyyy'),'YYYY')||'1231'
                  AND    exec.basis_date BETWEEN to_date(p1.start_yyyymmdd,'yyyymmdd') AND  TO_date(p1.end_yyyymmdd,'yyyymmdd')
                  AND    res.payroll_calculation_exec_id  = exec.payroll_calculation_exec_id
                  AND    res.employee_no  = p_employee_no
                  AND    res.payroll_item_id = c_summary.payroll_item_id
                  AND    res.payroll_item_detail_detail_id  = c_summary.payroll_item_detail_detail_id
                  ;*/
              END IF;
              
              v_sum := v_sum + v_amount;
              
             /* IF c.payroll_item_aggregate_name = 'TOTAL_EARNING' AND c_cycle.aggregate_cycle_type_code = 'RUN' THEN
                  dbms_output.put_line(v_sum);
              END IF;*/
          END LOOP; --amount sum 
          
          /* 은행이체 금액이 마이너스 이면 0으로 처리해줌 */
          /*IF c.payroll_item_aggregate_name = 'NET_AMOUNT' THEN
              IF v_sum < 0 THEN
                  v_sum := 0;
              END IF;
          END IF;*/
          
          MERGE INTO tb_pay_calc_aggr_result_n aggr_r
          USING 
          (
              SELECT c.payroll_item_aggregate_id        payroll_item_aggregate_id
                    , c_cycle.aggregate_cycle_type_code aggregate_cycle_type_code
                    , p_payroll_calculation_exec_id     payroll_calculation_exec_id
                    , p_employee_no                     employee_no
                    , v_payroll_calc_period_value       retroactive_pay_target_yyyymm
              FROM   dual
           ) tmp
          ON
          (
              aggr_r.payroll_item_aggregate_id        = tmp.payroll_item_aggregate_id
          AND aggr_r.aggregate_cycle_type_code        = tmp.aggregate_cycle_type_code
          AND aggr_r.payroll_calculation_exec_id      = tmp.payroll_calculation_exec_id
          AND aggr_r.employee_no                      = tmp.employee_no
          AND aggr_r.retroactive_pay_target_yyyymm    = tmp.retroactive_pay_target_yyyymm
           )
          WHEN MATCHED THEN /* Deduction 관련 누계는 누계금액을 abs로 처리한다. */
              UPDATE 
              SET    calculation_amount   = CASE WHEN c.payroll_item_aggregate_name IN ( 'PRE_TAX_DEDUCTIONS','VOL_DEDUCTIONS','TAXALBE_DEDUCTION','TAX_DEDUCTIONS') THEN 
                                                abs(v_sum)
                                            ELSE v_sum end  --/* Deduction 관련 누계는 누계금액을 abs로 처리한다. */          
          WHEN NOT MATCHED THEN
          INSERT ( payroll_item_aggregate_id  
                  ,aggregate_cycle_type_code  
                  ,payroll_calculation_exec_id
                  ,employee_no                
                  ,calculation_amount
                  ,creation_date   
                  ,creation_user_id
                  ,retroactive_pay_target_yyyymm
                  )
          VALUES
              ( tmp.payroll_item_aggregate_id  
               ,tmp.aggregate_cycle_type_code  
               ,tmp.payroll_calculation_exec_id
               ,tmp.employee_no                
               ,CASE WHEN c.payroll_item_aggregate_name IN ( 'PRE_TAX_DEDUCTIONS','VOL_DEDUCTIONS','TAXALBE_DEDUCTION','TAX_DEDUCTIONS') THEN 
                    abs(v_sum)
                ELSE v_sum end    --/* Deduction 관련 누계는 누계금액을 abs로 처리한다. */ 
               ,SYSDATE   
               ,p_user_id
               ,v_payroll_calc_period_value
               );  
               
          
      END LOOP; --cycle                  
      
      
      END LOOP; --aggr
EXCEPTION
    WHEN OTHERS THEN 
        --dbms_output.put_line('aggregate error  =>'||SQLERRM);      
        v_err_buf := 'aggregate err =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );     
  END;
  
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_aggr_result                                          */
/* Description    :  집계된 금액을 가져오는 function                          */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09   SonSuyang     Initial Release                                 */
/* 2018/10/01   KimTaehyun    Separation Retroactive Payroll                  */
/******************************************************************************/  
FUNCTION get_aggr_result(p_payroll_item_aggregate_name   IN VARCHAR2
                       , p_aggregate_cycle_type_code     IN VARCHAR2
                       , p_payroll_calculation_exec_id   IN NUMBER
                       , p_employee_no                   IN VARCHAR2
                       --< 20181001 KTH Start Add
                       , p_retropay_target_yyyymm        IN VARCHAR2 DEFAULT NULL
                       -->
                       ) RETURN NUMBER IS
    v_return NUMBER := 0;
                           
  
BEGIN
  
    SELECT nvl(SUM(nvl(aggr_r.calculation_amount,0)),0)
    INTO   v_return
    FROM   tb_pay_item_aggr_n aggr
          ,tb_pay_item_aggr_cycle_n cycle 
          ,tb_pay_calc_aggr_result_n aggr_r
    WHERE  aggr.payroll_item_aggregate_name     = p_payroll_item_aggregate_name
    AND    cycle.payroll_item_aggregate_id      = aggr.payroll_item_aggregate_id
    AND    cycle.aggregate_cycle_type_code      = p_aggregate_cycle_type_code
    AND    aggr_r.payroll_item_aggregate_id     = aggr.payroll_item_aggregate_id
    AND    aggr_r.aggregate_cycle_type_code     = cycle.aggregate_cycle_type_code
    AND    aggr_r.payroll_calculation_exec_id   = p_payroll_calculation_exec_id
    AND    aggr_r.employee_no                   = p_employee_no
    --< 20181001 KTH Start Add
    AND    aggr_r.retroactive_pay_target_yyyymm = NVL(p_retropay_target_yyyymm,aggr_r.retroactive_pay_target_yyyymm)
    -->
    ;  
    
    RETURN v_return;
EXCEPTION
   WHEN OTHERS THEN 
       RETURN 0;    
    
END ; 
                      
end lgvpay_aggr_pkg;
/
