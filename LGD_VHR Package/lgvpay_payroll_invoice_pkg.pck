CREATE OR REPLACE PACKAGE VHR_MGR.lgvpay_payroll_invoice_pkg IS
    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0008';
    g_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    
PROCEDURE send_pay_result( p_payroll_calculation_exec_id IN NUMBER
                          , p_errcode                    OUT NUMBER
                          , p_errbuf                     OUT VARCHAR2) ;

end lgvpay_payroll_invoice_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvpay_payroll_invoice_pkg IS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : send_pay_result                                          */
/* Description    :  급여작업이 완료된 이후 confirm 된 건에 대해 ERP로 전송   */
/*                   하기 위해 ineterface테이블로 데이터 전송함               */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/01/208   SonSuyang       Initial Release                              */
/* 2025/11/01    HMT_20251101   Add new monthly payroll - resign (MTH_RS)     */
/******************************************************************************/  
 PROCEDURE send_pay_result( p_payroll_calculation_exec_id IN NUMBER
                          , p_errcode                    OUT NUMBER
                          , p_errbuf                     OUT VARCHAR2) IS
    V_CONFIRM_FLAG      VARCHAR2(1);
    V_CURR_EAI_ID       NUMBER ; 
    v_total_sum_net_pay NUMBER;
    v_total_count       NUMBER;
    v_if_exists         VARCHAR2(1) := 'N';
    
BEGIN
    --1) 만약 해당 실행건이 confirm이 안되어있으면 처리안되도록 한다.
    SELECT pce.confirm_flag
    INTO   v_confirm_flag
    FROM   tb_pay_calc_exec_n  pce
    WHERE  pce.payroll_calculation_exec_id =   p_payroll_calculation_exec_id
    ;   
    
    
    IF v_confirm_flag is NULL OR v_confirm_flag = 'N' THEN
      
        g_step    := 'Payroll Result is not confirmed yet';
        p_errcode := SQLCODE;
        p_errbuf  := g_step;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
        
        RETURN;
    END IF;
    
    
    --2) 현재 인터페이스 테이블에 인터페이스 되지 않은 데이터가 있는지 확인
    BEGIN
        SELECT 'Y'
        INTO   v_if_exists
        FROM   dual
        WHERE  exists ( 
                          SELECT 1
                          FROM   xvh_pay_invoice_if pii
                          WHERE  pii.eai_transfer_flag = 'N'
                          AND   (pii.payment_date, NVL(pii.attribute3,'XX') ) IN  ( SELECT pce.basis_date, pce.payroll_type_code
                                                                                    FROM   tb_pay_calc_exec_n pce
                                                                                    WHERE  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id )
                        );
    EXCEPTION
        WHEN OTHERS THEN
            v_if_exists := 'N';
    END;
     
    
    IF v_if_exists = 'Y' THEN
        g_step    := 'Interface Data is already exists';
        p_errcode := SQLCODE;
        p_errbuf  := g_step;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
        
        RETURN;
    END IF;
    
                    
                   
                   
    
    /* 현재 eai_seq_id 번호 가져오기 */
    SELECT  sq_xvh_pay_invoice_if.nextval
    INTO    v_curr_eai_id
    FROM    dual;
    
    
    
    INSERT INTO XVH_PAY_INVOICE_IF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    (eai_seq_id
    ,data_interface_type_code
    ,data_interface_date
    ,eai_transfer_flag
    ,eai_transfer_date
    ,subsidiary
    ,yyyymm
    ,payment_date
    ,branch
    ,period
    ,employee_number
    ,salary_type
    ,debit
    ,credit
    ,currency
    ,retire_pay_flag
    ,attribute2
    ,attribute3
    ,last_update_date
    ,sys_date
    ,transfer_date
    ,transfer_flag
    )
    SELECT  sq_xvh_pay_invoice_if.nextval                      --      ,EAI_SEQ_ID
             , 'I'                                                 -- ,DATA_INTERFACE_TYPE_CODE
             , SYSDATE                                               -- ,DATA_INTERFACE_DATE
             , 'N'                                                   -- ,EAI_TRANSFER_FLAG
             , NULL                                                   -- ,EAI_TRANSFER_DATE
             , 'LGDVN'                                               -- ,SUBSIDIARY
             , basis_yyyymm                                              -- ,YYYYMM
             , basis_date--PAYMENT DATE                                -- ,PAYMENT_DATE
             , 'LGDVN'                                               -- ,BRANCH
             , 'M'                                                   -- ,PERIOD
             , employee_no                                           -- ,EMPLOYEE_NUMBER
             , salary_type                                          --  ,SALARY_TYPE
             , amount --debit                                      --   ,DEBIT
             , 0 --credit                                       --   ,CREDIT
             ,'VND'
             , 'N' --RETIRE_PAY_FLAG                                  ,RETIRE_PAY_FLAG
             /* ERP 에서 
                SELECT *
                FROM  xxlge_lookup_values a
                WHERE a.lookup_type = 'XXPAYH_PAY_SLIP_TYPE'; 에 셋업되어있음
             */
             , decode(payroll_type_code,'MTH','PAY_RS','MTH_RS','PAY_RSR',payroll_type_code)  --payroll regular salary ( 급여용) HMT_20251101 Add ,'MTH_RS','PAY_RSR'
             , decode(payroll_type_code,'MTH_RS','MTH',payroll_type_code) --HMT_20251101 Add ,'MTH_RS','MTH'
             , SYSDATE -- LAST_UPDATE_DATE
             ,SYSDATE --                             ,SYS_DATE
             ,SYSDATE --                             ,TRANSFER_DATE
             , 'Y' --,TRANSFER_FLAG
                                         
    FROM ( 
          SELECT ccc.common_code salary_type
                ,prs.employee_no
                ,prs.basis_yyyymm
                ,prs.payroll_type_code
                ,pce.basis_date
                ,SUM(pcr.Result_Value*decode(ccc1.code_data1_value,'ADD',1,'SUBTRACTION',-1,0)) amount
          FROM   tb_pay_calc_result_n   pcr 
              , tb_pay_payroll_item_m   ppi
              , tb_pay_item_detail_n    pid
              , lgcom_common_code_c     ccc
              , tb_pay_result_s         prs
              , lgcom_common_code_c     ccc1
              , tb_pay_calc_exec_n      pce
          WHERE pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
          AND   ppi.payroll_item_id             = pcr.payroll_item_id
          AND   pid.payroll_item_id             = ppi.payroll_item_id
          AND   pid.additional_input_value      = 'PAY_VALUE'
          AND   pid.payroll_item_detail_detail_id   = pcr.payroll_item_detail_detail_id
          AND   ccc.code_type_code              = 'LGDVH_PAY_ITEM_ACC_GROUP_CODE'
          AND   prs.payroll_calculation_exec_id = pcr.payroll_calculation_exec_id
          AND   prs.employee_no                 = pcr.employee_no
          AND   ccc.common_code                 IN ( DECODE(prs.employment_category_code ,'LGD_OW', ppi.ofc_wrk_pay_account_class_code,ppi.tech_wrk_pay_acct_class_code), 'ALL')
          AND   ccc1.code_type_code             = 'LGDVHR_PAY_CLASS_TYPE_CODE'
          AND   ccc1.common_code                = ppi.pay_item_classification_code
          AND   pce.payroll_calculation_exec_id  = pcr.payroll_calculation_exec_id
          --AND   prs.bank_transfer_amount        > 0 
          GROUP BY ccc.common_code,prs.employee_no ,prs.basis_yyyymm,prs.payroll_type_code , pce.basis_date
          HAVING SUM(pcr.Result_Value)          <> 0
          UNION ALL
          SELECT  'NET_PAY' salary_type
                ,prs.employee_no
                ,prs.basis_yyyymm
                ,prs.payroll_type_code
                ,pce.basis_date
                ,PRS.BANK_TRANSFER_AMOUNT*(-1)
          FROM    tb_pay_result_s     prs
                , tb_pay_calc_exec_n  pce
          WHERE  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id
          AND    prs.payroll_calculation_exec_id = pce.payroll_calculation_exec_id
          ---AND   prs.bank_transfer_amount        > 0 
       ) res
    ;
    
    
    SELECT SUM(eai.debit)*(-1), count(*)
    INTO   v_total_sum_net_pay
          ,v_total_count
    FROM   xvh_pay_invoice_if EAI 
    WHERE  eai.eaI_seq_id > v_curr_eai_id
    AND    SALARY_TYPE    = 'NET_PAY'
    ;
    
    
    
       
    p_errcode :=0;
    P_ERRBUF  := 'Total Insert Data : ' || v_total_count ||'<br>'||
                 'Total Net Amount : '||to_char(v_total_sum_net_pay,'999,999,999,999,999');
                 
    --COMMIT;
   
    
EXCEPTION
    WHEN OTHERS THEN
        G_STEP    := 'Payroll Result send Error';
        p_errcode := SQLCODE;
        p_errbuf  := SQLERRM;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, g_program_id);
END;
END lgvpay_payroll_invoice_pkg;
/
