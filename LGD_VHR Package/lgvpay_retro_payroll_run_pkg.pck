create or replace package vhr_mgr.lgvpay_retro_payroll_run_pkg is
PROCEDURE run_proc( p_employee_no       IN VARCHAR2 DEFAULT NULL,
                    p_assignment_set_id IN NUMBER   DEFAULT NULL,
                    p_period_id         IN NUMBER ,
                    p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                    p_user_id           IN VARCHAR2,
                    p_start_yyyymm      IN VARCHAR2,
                    p_end_yyyymm        IN VARCHAR2,
                    p_errbuf            OUT VARCHAR,
                    p_payroll_calculation_exec_id OUT NUMBER );

PROCEDURE run_proc( p_employee_no       IN VARCHAR2 DEFAULT NULL,
                    p_assignment_set_id IN NUMBER   DEFAULT NULL,
                    p_period_id         IN NUMBER ,
                    p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                    p_user_id           IN VARCHAR2,
                    p_start_employee_no IN VARCHAR2,
                    p_end_employee_no   IN VARCHAR2,
                    p_payroll_calculation_exec_id IN  NUMBER,
                    p_start_yyyymm      IN VARCHAR2,
                    p_end_yyyymm        IN VARCHAR2,
                    p_errbuf                      OUT VARCHAR );


PROCEDURE retry_run    ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER,
                         p_employee_no                    IN VARCHAR2,
                         p_subsidiary_code                IN VARCHAR2,
                         p_user_id                        IN VARCHAR2,
                         p_start_yyyymm                   IN VARCHAR2,
                         p_end_yyyymm                     IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER );

PROCEDURE rollback_run ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER,
                         p_employee_no                    IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  ) ;

--소급급여차이집계 및 tb_pay_payment_plan_detail_n 등록
PROCEDURE difference_proc(p_payroll_calculation_exec_id    IN NUMBER
                         ,p_employee_no                    IN VARCHAR2
                         ,p_application_user_id            IN NUMBER
                         ,p_errbuf                         OUT VARCHAR2 );

/*-- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAY.....';
    g_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    g_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;   */

end lgvpay_retro_payroll_run_pkg;
/
create or replace package body vhr_mgr.lgvpay_retro_payroll_run_pkg is
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2018                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : main_proc                                                */
/* Description     : Retroactive Payroll Run Main Program                     */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/09/14    KimTaehyun     Initial Release                               */
/* 2025/11/01    HMT_20251101   Add new monthly payroll - resign (MTH_RS)     */
/******************************************************************************/
PROCEDURE run_proc( p_employee_no       IN VARCHAR2 DEFAULT NULL,
                    p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                    p_period_id         IN NUMBER , 
                    p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                    p_user_id           IN VARCHAR2,
                    p_start_yyyymm      IN VARCHAR2,
                    p_end_yyyymm        IN VARCHAR2,
                    p_errbuf            OUT VARCHAR,
                    p_payroll_calculation_exec_id OUT NUMBER )
IS
                     
    l_execution_id NUMBER;
    
    CURSOR c_target_per_cur IS
    SELECT a.payroll_calculation_set_id, 
           a.employee_no
    FROM   tb_pay_calc_set_target_per_n a
    WHERE  a.payroll_calculation_set_id = p_assignment_set_id
    AND    a.employee_no                = nvl(p_employee_no, a.employee_no)
    UNION 
    SELECT p_assignment_set_id 
           ,p_employee_no
    FROM   dual
    WHERE  p_assignment_set_id IS NULL
    AND    p_employee_no IS not NULL
    ;
    
    CURSOR c_month_cur IS
    SELECT a.payroll_calculation_period_id
          ,a.payroll_calc_period_value
    FROM   tb_pay_calc_period_basis_n a
    WHERE  a.payroll_calc_period_value between TO_CHAR(TO_DATE(p_start_yyyymm,'MM/YYYY'),'YYYYMM') and TO_CHAR(TO_DATE(p_end_yyyymm,'MM/YYYY'),'YYYYMM')
    ORDER BY 1
    ;
    
    p_errbuf_summary VARCHAR2(4000);
    v_chk            NUMBER;
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_retro_payroll_run_pkg';  
    
BEGIN
  
   -- dbms_output.put_line('start ->'||to_char(sysdate,'yyyymmdd hh24:mi:ss'));
    v_step :='';
    v_procedure_name := 'LGVPAY...: main_proc () ';
    
   --1)payroll_calculation_exec_id 채번 
    SELECT sq_tb_pay_calc_exec_n.nextval
    INTO   l_execution_id
    FROM   dual
    ;
    
    v_step :='Execution table Insert Start';
    
    -- Execution table Insert
    INSERT INTO tb_pay_calc_exec_n
    ( payroll_calculation_exec_id
      , payroll_type_code
      , basis_date
      , payroll_calculation_set_id
      , retroactive_flag
      --, confirm_flag
      , creation_date
      , creation_user_id
      , retroactive_pay_start_yyyymm
      , retroactive_payroll_end_yyyymm
    )
    SELECT l_execution_id
          , p_run_type_name
          , to_date(a.end_yyyymmdd ,'yyyymmdd')
          , p_assignment_set_id
          , 'Y' 
          --, 'N'
          , SYSDATE
          , nvl(p_user_id,'admin')
          , TO_CHAR(TO_DATE(p_start_yyyymm,'MM/YYYY'),'YYYYMM')
          , TO_CHAR(TO_DATE(p_end_yyyymm,'MM/YYYY'),'YYYYMM')
    FROM   tb_pay_calc_period_basis_n a
    WHERE  a.payroll_calculation_period_id = p_period_id
    ;
    
   -- dbms_output.put_line('start 1->'||to_char(sysdate,'yyyymmdd hh24:mi:ss'));
    
    p_payroll_calculation_exec_id := l_execution_id;
    
    p_errbuf :='Execution table Insert Sucess !! : Insert Count : '||sql%rowcount;
    
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
    lgcom_error_log_pkg.debug_prc(v_module_code, v_procedure_name);         
    
-- 1) assignment_set_id 가 있는경우   
-- 2) employee_no 가 있는 경우  



    v_step :='Call Retroactive calc_proc';
    FOR c IN c_target_per_cur
    LOOP
        p_errbuf := NULL;
        
        INSERT INTO tb_pay_calc_emp_exec_n
        ( payroll_calculation_exec_id
          , employee_no
          , error_flag
          , creation_user_id
          , creation_date 
         )
        VALUES
        (  l_execution_id
          ,c.employee_no
          ,NULL
          ,p_user_id
          ,sysdate)
        ;
        
        FOR cc IN c_month_cur
        LOOP
   
            BEGIN
                
                -- 신입사원의 경우처럼 과거 급여내역이 없으면 소급계산시 error로 빠지는것을 방지하기 위함
                SELECT 1
                INTO   v_chk
                FROM   tb_pay_calc_exec_n tpce
                WHERE  tpce.payroll_type_code         IN ('MTH', 'MTH_RS') --HMT_20251101
                AND    NVL(tpce.retroactive_flag,'N') = 'N'
                AND    NVL(tpce.confirm_flag,'N')     = 'Y'
                AND    tpce.basis_date                = LAST_DAY(TO_DATE(cc.payroll_calc_period_value,'YYYYMM'))
                AND    EXISTS (SELECT 1
                               FROM   tb_pay_calc_result_n tpcr
                               WHERE  tpcr.payroll_calculation_exec_id = tpce.payroll_calculation_exec_id
                               AND    tpcr.employee_no                 = c.employee_no
                               AND    ROWNUM = 1);
                
                lgvpay_calculation_pkg.calc_proc(p_payroll_calculation_exec_id => l_execution_id,
                                                 p_employee_no                 => c.employee_no, 
                                                 p_period_id                   => cc.payroll_calculation_period_id, 
                                                 p_run_type_name               => p_run_type_name,
                                                 p_user_id                     => p_user_id
                                                 );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            
        END LOOP;
                                          
        /* error 가 난 사람은  tb_pay_calc_emp_exec_n 의 error_flag = 'Y' 로 처리한다. */
        UPDATE tb_pay_calc_emp_exec_n a
        SET    a.error_flag = 'Y'
        WHERE  a.payroll_calculation_exec_id = l_execution_id
        AND    a.employee_no                 = c.employee_no
        AND    EXISTS ( SELECT * 
                        FROM   tb_pay_calc_emp_error_n pcee
                        WHERE  pcee.payroll_calculation_exec_id = l_execution_id
                        AND    pcee.employee_no                 = c.employee_no
                       ) ;
                                    
        /* Transfer result */                                          
        difference_proc(p_payroll_calculation_exec_id => l_execution_id
                       ,p_employee_no                 => c.employee_no
                       ,p_application_user_id         => p_user_id
                       ,p_errbuf                      => p_errbuf_summary
                       );     
        --DBMS_OUTPUT.PUT_LINE ('p_errbuf_summary=>'||p_errbuf_summary);                                                   
    END LOOP;
    

    
    p_errbuf := p_errbuf||'Retroactive calc_proc Sucess !!' ;
    
    COMMIT;
    
        
EXCEPTION
    WHEN OTHERS THEN
        p_errbuf := SQLERRM;
        v_step :=v_step||chr(13)|| 'User Exception Error(main)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);  
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : main_proc                                                */
/* Description     : Retroactive Payroll Run Main Program                     */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/09/14    KimTaehyun     Initial Release                               */
/******************************************************************************/
PROCEDURE run_proc( p_employee_no       IN VARCHAR2 DEFAULT NULL,
                    p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                    p_period_id         IN NUMBER , 
                    p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                    p_user_id           IN VARCHAR2,
                    p_start_employee_no IN VARCHAR2,
                    p_end_employee_no   IN VARCHAR2,
                    p_payroll_calculation_exec_id IN  NUMBER,
                    p_start_yyyymm      IN VARCHAR2,
                    p_end_yyyymm        IN VARCHAR2,
                    p_errbuf                      OUT VARCHAR )
IS                   
    
    CURSOR c_target_per_cur IS
    SELECT a.payroll_calculation_set_id, 
           a.employee_no
    FROM   tb_pay_calc_set_target_per_n a
    WHERE  a.payroll_calculation_set_id = p_assignment_set_id
    AND    a.employee_no                = nvl(p_employee_no, a.employee_no)
    AND    a.employee_no BETWEEN p_start_employee_no AND p_end_employee_no
    AND    p_start_employee_no IS NOT NULL
    AND    p_end_employee_no   IS NOT NULL
    UNION 
    SELECT p_assignment_set_id 
           ,p_employee_no
    FROM   dual
    WHERE  p_employee_no IS not NULL    
    ;
    
    CURSOR c_month_cur IS
    SELECT a.payroll_calculation_period_id
          ,a.payroll_calc_period_value
    FROM   tb_pay_calc_period_basis_n a
    WHERE  a.payroll_calc_period_value between TO_CHAR(TO_DATE(p_start_yyyymm,'MM/YYYY'),'YYYYMM') and TO_CHAR(TO_DATE(p_end_yyyymm,'MM/YYYY'),'YYYYMM')
    ORDER BY 1
    ;

    p_errbuf_summary   VARCHAR2(4000);
    v_chk            NUMBER;
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_retro_payroll_run_pkg';  
                         
BEGIN
    v_procedure_name := 'LGVPAY...: main_proc () ';
    
    -- 1) assignment_set_id 가 있는경우   
    -- 2) employee_no 가 있는 경우   

    v_step :='Call Retroactive calc_proc';
    FOR c IN c_target_per_cur
    LOOP
        INSERT INTO tb_pay_calc_emp_exec_n
        ( payroll_calculation_exec_id
          , employee_no
          , error_flag
          , creation_user_id
          , creation_date 
         )
        VALUES
        (  p_payroll_calculation_exec_id
          ,c.employee_no
          ,NULL
          ,p_user_id
          ,sysdate)
        ;
        
        FOR cc IN c_month_cur
        LOOP
        
            BEGIN
                
                -- 신입사원의 경우처럼 과거 급여내역이 없으면 소급계산시 error로 빠지는것을 방지하기 위함
                SELECT 1
                INTO   v_chk
                FROM   tb_pay_calc_exec_n tpce
                WHERE  tpce.payroll_type_code         IN ('MTH', 'MTH_RS') --HMT_20251101
                AND    NVL(tpce.retroactive_flag,'N') = 'N'
                AND    NVL(tpce.confirm_flag,'N')     = 'Y'
                AND    tpce.basis_date                = LAST_DAY(TO_DATE(cc.payroll_calc_period_value,'YYYYMM'))
                AND    EXISTS (SELECT 1
                               FROM   tb_pay_calc_result_n tpcr
                               WHERE  tpcr.payroll_calculation_exec_id = tpce.payroll_calculation_exec_id
                               AND    tpcr.employee_no                 = c.employee_no
                               AND    ROWNUM = 1);
                
                lgvpay_calculation_pkg.calc_proc(p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                                 p_employee_no                 => c.employee_no, 
                                                 p_period_id                   => cc.payroll_calculation_period_id, 
                                                 p_run_type_name               => p_run_type_name,
                                                 p_user_id                     => p_user_id
                                                 );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
                                          
        END LOOP;
                                                  
        /* error 가 난 사람은  tb_pay_calc_emp_exec_n 의 error_flag = 'Y' 로 처리한다. */
        UPDATE tb_pay_calc_emp_exec_n a
        SET    a.error_flag = 'Y'
        WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
        AND    a.employee_no                 = c.employee_no
        AND    EXISTS ( SELECT * 
                        FROM   tb_pay_calc_emp_error_n pcee
                        WHERE  pcee.payroll_calculation_exec_id = p_payroll_calculation_exec_id
                        AND    pcee.employee_no                 = c.employee_no
                       ) ;
                                          
        /* Transfer result */                                          
        difference_proc(p_payroll_calculation_exec_id  => p_payroll_calculation_exec_id
                       ,p_employee_no                => c.employee_no
                       ,p_application_user_id        => p_user_id
                       ,p_errbuf                     => p_errbuf_summary
                       );
        
    END LOOP;
    
    p_errbuf := p_errbuf||'Retroactive calc_proc Sucess !!' ;
    
    COMMIT;
    
        
EXCEPTION
    WHEN OTHERS THEN
        p_errbuf := SQLERRM;
        v_step :=v_step||chr(13)|| 'User Exception Error(main)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);  
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : retry_run                                                */
/* Description     : Retry Retroactive payroll Run                            */
/*                   Retry specific execution id   and Employee               */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/09/14    KimTaehyun     Initial Release                               */
/******************************************************************************/
PROCEDURE retry_run    ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_subsidiary_code                IN VARCHAR2,
                         p_user_id                        IN VARCHAR2,
                         p_start_yyyymm                   IN VARCHAR2,
                         p_end_yyyymm                     IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  )
IS
                         
    v_payroll_type_code   tb_pay_calc_exec_n.payroll_type_code%TYPE;  
    v_period_id           NUMBER; 
    p_errbuf_summary      VARCHAR2(4000);      
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_retro_payroll_run_pkg';                  
BEGIN
    v_step := ' 1) Delete tb_pay_detail_calc_t table ' ;
    --1) delete table
    DELETE FROM  tb_pay_detail_calc_t pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no)
    /*
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM   tb_pay_calc_set_target_per_n pcst 
                                    WHERE  pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND    pcst.employee_no                = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
           )
    */
    ;
     
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';            

    v_step := v_step||chr(13) || ' 2) Delete Result table ' ;              
    --2) Delete Result table
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM tb_retro_pay_calc_result_n pcr
    WHERE  pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pcr.employee_no                 = nvl(p_employee_no,pcr.employee_no);
    
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    v_step := v_step||chr(13) || ' 3) Delete Difference Result ' ;  
    --3) Delete Difference Result
    DELETE from tb_retro_actual_pay_diff_n rapd
    WHERE  rapd.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    rapd.employee_no                 = nvl(p_employee_no,rapd.employee_no);

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    v_step :=v_step||chr(13) || ' 4) Delete Aggregate Result ' ;  
    --4) Delete Aggregate Result
    DELETE from tb_pay_calc_aggr_result_n pca
    WHERE  pca.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pca.employee_no                 = nvl(p_employee_no,pca.employee_no);

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    v_step := v_step||chr(13) || ' 5) Delete tb_pay_payment_plan_detail_n ' ;  
    --5) Delete tb_pay_payment_plan_detail_n
    DELETE
    FROM   tb_pay_payment_plan_detail_n ppd
    WHERE  ppd.payroll_item_payment_plan_id IN (SELECT ppp.payroll_item_payment_plan_id
                                                FROM   tb_pay_item_payment_plan_n ppp
                                                WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
                                                AND    ppp.employee_no                 = NVL(p_employee_no,ppp.employee_no)
                                                AND    NVL(ppp.retroactive_flag,'N')   = 'Y');

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    
    v_step := v_step||chr(13) || ' 6) Delete tb_pay_item_payment_plan_n ' ;  
    --6) Delete tb_pay_item_payment_plan_n
    DELETE
    FROM   tb_pay_item_payment_plan_n ppp
    WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ppp.employee_no                 = NVL(p_employee_no,ppp.employee_no)
    AND    NVL(ppp.retroactive_flag,'N')   = 'Y';

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    v_step := v_step||chr(13) || ' 7) Delete tb_pay_calc_emp_exec_n ' ;  
    --7) Delete tb_pay_calc_emp_exec_n
    DELETE FROM  tb_pay_calc_emp_exec_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no);
     
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    
    v_step := v_step||chr(13) || ' 8) Delete tb_pay_calc_emp_error_n table ' ; 
    DELETE FROM  tb_pay_calc_emp_error_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no);
     
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';    
    
    SELECT a.payroll_type_code
          ,b.payroll_calculation_period_id
          --,a.retroactive_pay_start_yyyymm
          --,a.retroactive_payroll_end_yyyymm
    INTO   v_payroll_type_code
          ,v_period_id
    FROM   tb_pay_calc_exec_n  a
          ,tb_pay_calc_period_basis_n b
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    to_char(a.basis_date,'yyyymmdd') BETWEEN b.start_yyyymmdd AND b.end_yyyymmdd
    AND    b.subsidiary_code             = p_subsidiary_code;
    
    -- retroactive payroll run
    lgvpay_retro_payroll_run_pkg.run_proc( p_employee_no                 => p_employee_no,
                                           p_assignment_set_id           => p_payroll_calculation_set_id, 
                                           p_period_id                   => v_period_id, 
                                           p_run_type_name               => v_payroll_type_code ,
                                           p_user_id                     => p_user_id,
                                           p_start_employee_no           => NULL,
                                           p_end_employee_no             => NULL,
                                           p_start_yyyymm                => p_start_yyyymm,
                                           p_end_yyyymm                  => p_end_yyyymm,
                                           p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                           p_errbuf                      => p_errbuf );
                     
    
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
    lgcom_error_log_pkg.debug_prc(v_module_code, v_program_id);  
    
    p_errcode := 0;    
    
    --COMMIT;  


EXCEPTION
    WHEN OTHERS THEN 
         p_errcode := -1;
         p_errbuf := v_step||':'||SQLERRM;
         v_step :=v_step||chr(13)|| 'User Exception Error(Retry Run)';
         lgcom_error_log_pkg.set_comment_text(v_step);
         lgcom_error_log_pkg.set_error_code(NULL);
         lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
         lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);   
         
END;                         

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : rollback_run                                             */
/* Description    :  Delete Retroactive Payroll Run                           */
/*                   Delete all date related with specific execution id       */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/09/14    KimTaehyun     Initial Release                               */
/******************************************************************************/
PROCEDURE rollback_run ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  )
IS

    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_retro_payroll_run_pkg';                           
                             
BEGIN
    v_step := NULL;
    
    
    v_step := v_step||chr(13) ||' 1) Calculation Temp Table Delete' ;
    
    --1) Calculation Temp Table Delete
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM  tb_pay_detail_calc_t pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no);
     
    v_step :=v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete Result table ' ;              
    --2) Delete Retroactive Result table
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM tb_retro_pay_calc_result_n pcr
    WHERE  pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pcr.employee_no                 = nvl(p_employee_no,pcr.employee_no);
    
    v_step :=v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    v_step :=v_step||chr(13) || ' 3) Delete Difference Result ' ;  
    --3) Delete Difference Result
    DELETE from tb_retro_actual_pay_diff_n rapd
    WHERE  rapd.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    rapd.employee_no = nvl(p_employee_no,rapd.employee_no);

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    
    v_step :=v_step||chr(13) || ' 4) Delete Aggregate Result ' ;  
    --4) Delete Aggregate Result
    DELETE from tb_pay_calc_aggr_result_n pca
    WHERE  pca.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pca.employee_no = nvl(p_employee_no,pca.employee_no);

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    v_step :=v_step||chr(13) || ' 5) Delete tb_pay_payment_plan_detail_n ' ;  
    --5) Delete tb_pay_payment_plan_detail_n
    DELETE
    FROM   tb_pay_payment_plan_detail_n ppd
    WHERE  ppd.payroll_item_payment_plan_id IN (SELECT ppp.payroll_item_payment_plan_id
                                                FROM   tb_pay_item_payment_plan_n ppp
                                                WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
                                                AND    ppp.employee_no                 = NVL(p_employee_no,ppp.employee_no)
                                                AND    NVL(ppp.retroactive_flag,'N')   = 'Y');

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    
    v_step :=v_step||chr(13) || ' 6) Delete tb_pay_item_payment_plan_n ' ;  
    --6) Delete tb_pay_item_payment_plan_n
    DELETE
    FROM   tb_pay_item_payment_plan_n ppp
    WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ppp.employee_no                 = NVL(p_employee_no,ppp.employee_no)
    AND    NVL(ppp.retroactive_flag,'N')   = 'Y';

    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted'; 
    
    v_step := '7) Execution table DELETE';
    --7) Execution table Delete
    --   if only there is no data in tb_pay_calc_result_n, delete Data.
    DELETE FROM tb_pay_calc_exec_n pce
    WHERE  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    p_employee_no IS NULL
    AND    NOT EXISTS ( SELECT 1 
                        FROM   tb_retro_pay_calc_result_n rcr 
                        WHERE  rcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id);
    
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    v_step := '8) Execution Employee table DELETE';
    --8) Execution Employee table Delete
    DELETE FROM  tb_pay_calc_emp_exec_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no);
     
    v_step :=v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    
    v_step := '9) Execution Employee Error table DELETE';
    --9) Execution Employee Error table Delete
    DELETE FROM  tb_pay_calc_emp_error_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdc.employee_no                 = nvl(p_employee_no,pdc.employee_no);
     
    v_step :=v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
    lgcom_error_log_pkg.debug_prc(v_module_code, v_program_id);  
    
    p_errcode := 0;
    
    COMMIT;               
    

EXCEPTION
    WHEN OTHERS THEN
          p_errcode := -1;
          p_errbuf := SQLERRM;
          v_step :=v_step||chr(13)|| 'User Exception Error(main)';
          lgcom_error_log_pkg.set_comment_text(v_step);
          lgcom_error_log_pkg.set_error_code(NULL);
          lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
          lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);                        
    
    
END;   

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : difference_proc                                          */
/* Description    :  소급급여차이집계 및 tb_pay_payment_plan_detail_n 등록    */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/09/14    KimTaehyun     Initial Release                               */
/******************************************************************************/
PROCEDURE difference_proc(p_payroll_calculation_exec_id    IN NUMBER
                         ,p_employee_no                    IN VARCHAR2
                         ,p_application_user_id            IN NUMBER
                         ,p_errbuf                         OUT VARCHAR2 
                         )
IS

    --실제 해당월의 급여 산출정보
    CURSOR c_actual_cur(c_start_yyyymm IN VARCHAR2, c_end_yyyymm IN VARCHAR2) IS
    SELECT tpce.payroll_calculation_exec_id
          ,tpce.basis_date
          ,TO_CHAR(tpce.basis_date,'YYYYMM') as current_yyyymm
    FROM   tb_pay_calc_exec_n         tpce
    WHERE  tpce.basis_date BETWEEN TRUNC(TO_DATE(c_start_yyyymm,'YYYYMM'),'MONTH') AND LAST_DAY(TO_DATE(c_end_yyyymm,'YYYYMM'))
    AND    NVL(tpce.retroactive_flag,'N') = 'N'
    AND    tpce.payroll_type_code         IN ('MTH', 'MTH_RS') --HMT_20251101
    AND    NVL(tpce.confirm_flag,'N')     = 'Y'
    ORDER BY tpce.basis_date;
    
    --소급급여대상 아이템 정보
    CURSOR c_item_cur(c_current_yyyymm IN VARCHAR2) IS
    SELECT pppi.payroll_item_id
    FROM   tb_pay_payroll_item_m          pppi
    WHERE  NVL(pppi.retroactive_flag,'N') = 'Y'
    AND    c_current_yyyymm||'01' BETWEEN pppi.start_yyyymmdd AND pppi.end_yyyymmdd;
    
    --소급급여 차액 SUM 정보
    CURSOR c_differ_cur IS
    SELECT tppi.aggr_retroactive_pay_item_id
          ,tpid.payroll_item_detail_detail_id
          ,SUM(NVL(trpd.retroact_act_pay_diff_amount,0)) as differ_amt
    FROM   tb_retro_actual_pay_diff_n trpd
          ,tb_pay_payroll_item_m      tppi
          ,tb_pay_item_detail_n       tpid
    WHERE  trpd.payroll_calculation_exec_id  = p_payroll_calculation_exec_id
      AND  trpd.employee_no                  = p_employee_no
      AND  trpd.payroll_item_id              = tppi.payroll_item_id
      AND  tppi.aggr_retroactive_pay_item_id = tpid.payroll_item_id
      AND  tpid.additional_input_value       = 'PAY_VALUE'
    GROUP BY tppi.aggr_retroactive_pay_item_id
          ,tpid.payroll_item_detail_detail_id
    ORDER BY tppi.aggr_retroactive_pay_item_id;
    
    v_program_id  lgcom_error_log.program_id%TYPE := 'LGVPAYC0008';
    v_user_id     number := -1; -- create_by, last_updated_by 에 이용
    
    v_exception   exception; --예외처리
    
    v_apply_start_date             DATE;
    v_apply_end_date               DATE;
    v_start_yyyymm                 VARCHAR2(6);
    v_end_yyyymm                   VARCHAR2(6);
    v_current_yyyymm               VARCHAR2(6);
    v_retire_yyyymmdd              VARCHAR2(8);
    v_result_amt                   NUMBER := 0;
    v_retro_amt                    NUMBER := 0;
    v_plan_id                      NUMBER;
    v_chk_cnt                      NUMBER := 0;
    v_aggr_retroactive_pay_item_id NUMBER := -99;
    v_subsidiary_code              VARCHAR2(10);
    v_bounds_amt                   NUMBER := 0;
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_retro_payroll_run_pkg';  
    
BEGIN
    v_step := '';
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    -- 소급급여실행아이디를 가지고 실제급여에 필요한 일자를 구한다.
    v_step := 'Get Retroactive Payroll From ~ To';
    SELECT tpce.retroactive_pay_start_yyyymm
          ,tpce.retroactive_payroll_end_yyyymm
          ,TRUNC(tpce.basis_date,'MONTH')
          ,tpce.basis_date
          ,tppb.subsidiary_code
    INTO   v_start_yyyymm
          ,v_end_yyyymm
          ,v_apply_start_date
          ,v_apply_end_date
          ,v_subsidiary_code
    FROM   tb_pay_calc_exec_n         tpce
          ,tb_pay_calc_period_basis_n tppb
    WHERE  tpce.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    to_char(tpce.basis_date,'yyyymmdd') BETWEEN tppb.start_yyyymmdd AND tppb.end_yyyymmdd
    ;
    
    BEGIN
        SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'RETROPAY_REMAIN_BOUNDS',TO_CHAR(v_apply_end_date,'YYYYMMDD')),0)
        INTO   v_bounds_amt
        FROM   dual;
    EXCEPTION
        WHEN OTHERS THEN
            v_bounds_amt := 0;
    END;
    
    --기존 차이집계 삭제
    v_step := 'Delete tb_retro_actual_pay_diff_n';
    DELETE
    FROM   tb_retro_actual_pay_diff_n trap
    WHERE  trap.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    trap.employee_no                 = p_employee_no;
    
    v_step := 'Delete tb_pay_payment_plan_detail_n';
    DELETE
    FROM   tb_pay_payment_plan_detail_n ppd
    WHERE  ppd.payroll_item_payment_plan_id IN (SELECT ppp.payroll_item_payment_plan_id
                                                FROM   tb_pay_item_payment_plan_n ppp
                                                WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
                                                AND    ppp.employee_no                 = p_employee_no
                                                AND    NVL(ppp.retroactive_flag,'N')   = 'Y');
    
    v_step := 'Delete tb_pay_item_payment_plan_n';
    DELETE
    FROM   tb_pay_item_payment_plan_n ppp
    WHERE  ppp.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ppp.employee_no                 = p_employee_no
    AND    NVL(ppp.retroactive_flag,'N')   = 'Y';
    
    --
    v_step :='Cal Difference Amount';
    FOR c IN c_actual_cur (v_start_yyyymm, v_end_yyyymm)
    LOOP
    
        /*
        Actual Payroll    Retroactive Payroll     Difference Payroll    
        실제급여월 실제급여금액  지급급여월(소급) 소급대상급여월 소급급여금액  지급급여월(소급) 소급대상급여월 차액
        6월  100 9월  6월  90  9월  6월  -10
        7월  100 9월  7월  100 9월  7월  0
        8월  110 9월  8월  130 9월  8월  20
                      
        1. 9월 소급금액은 지급급여월 기준으로 Differ 차액(= 소급급여금액 - 실제급여금액)을 Sum하여 나간다.             
        2. 급여월 10월에 6월소급을 다시 돌리면, Actual 6월 과 (Retro 6월 + Differ(차액 * -1))를 비교하여 차액이 나갔는지를 비교한다             
           - 비교할때 payroll_item_detail_detail_id,pay_calc_rslt_detail_type_code 관계없이 월별, Item별로만 Sum한다.
        */
        
        v_current_yyyymm := c.current_yyyymm;
          
        v_step :='Cal Difference Amount';
        FOR cc IN c_item_cur(v_current_yyyymm)
        LOOP
        
            -- 기존에 소급을 돌린것이 있는지를 확인하여 있다면 최종 소급돌린금액과 비교하여
            -- 같으면 소급분이 지급되었다고 보고, 다르면 최종 소급돌린금액과의 차액으로만 생성함
            -- 해당월의 지난(이번달이 아닌) 소급급여 실적이 있는지를 확인.
            BEGIN
                SELECT 1
                INTO   v_chk_cnt
                FROM   tb_retro_pay_calc_result_n    trcr
                WHERE  trcr.payroll_calculation_exec_id    <> p_payroll_calculation_exec_id
                AND    trcr.retroactive_pay_target_yyyymm  = v_current_yyyymm
                AND    trcr.employee_no                    = p_employee_no
                AND    trcr.payroll_item_id                = cc.payroll_item_id
                AND    trcr.pay_calc_rslt_detail_type_code = 'A'
                AND    ROWNUM = 1;
              
                SELECT rank_view.amt
                INTO   v_result_amt
                FROM   (SELECT trcr.payroll_calculation_exec_id
                              ,SUM(NVL(trcr.result_value,0)) amt
                              ,rank() over(ORDER BY trcr.payroll_calculation_exec_id DESC) rank
                        FROM   tb_retro_pay_calc_result_n    trcr
                        WHERE  trcr.payroll_calculation_exec_id    <> p_payroll_calculation_exec_id
                        AND    trcr.retroactive_pay_target_yyyymm  = v_current_yyyymm
                        AND    trcr.employee_no                    = p_employee_no
                        AND    trcr.payroll_item_id                = cc.payroll_item_id
                        AND    trcr.pay_calc_rslt_detail_type_code = 'A'
                        GROUP BY trcr.payroll_calculation_exec_id) rank_view
                WHERE  rank_view.rank = 1;
            EXCEPTION
                WHEN OTHERS THEN
                    --이전에 소급계산한 내역이 없으면, 실제 해당월의 급여실적을 가져온다
                    --실제 해당월의 급여 실적
                    BEGIN
                        SELECT SUM(NVL(tpcr.result_value,0)) amt
                        INTO   v_result_amt
                        FROM   tb_pay_calc_result_n       tpcr
                        WHERE  tpcr.payroll_calculation_exec_id    = c.payroll_calculation_exec_id
                        AND    tpcr.employee_no                    = p_employee_no
                        AND    tpcr.payroll_item_id                = cc.payroll_item_id
                        AND    tpcr.pay_calc_rslt_detail_type_code = 'A' --항목의 상세 값이 숫자(금액)
                        ;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_result_amt := 0;
                    END;
            END;
                           
            --해당월의 소급급여 실적
            BEGIN
                SELECT SUM(NVL(trcr.result_value,0)) amt
                INTO   v_retro_amt
                FROM   tb_retro_pay_calc_result_n    trcr
                WHERE  trcr.payroll_calculation_exec_id    = p_payroll_calculation_exec_id
                AND    trcr.retroactive_pay_target_yyyymm  = v_current_yyyymm
                AND    trcr.employee_no                    = p_employee_no
                AND    trcr.payroll_item_id                = cc.payroll_item_id
                AND    trcr.pay_calc_rslt_detail_type_code = 'A';
            EXCEPTION
                WHEN OTHERS THEN
                    v_retro_amt := 0;
            END;
            
            -- 해당월의 소급급여 혹은 실제급여와 이번에 계산된 소급금액과 차이가 발생하면 데이터를 쌓는다.
            -- 단, Oracle의 Order by와 Round에 의한 단수차이 발생으로 인하여 설정된 값이 범위를 벗어나는것만 쌓는다.
            IF ABS(v_retro_amt - v_result_amt) > v_bounds_amt THEN
            
                INSERT INTO tb_retro_actual_pay_diff_n
                (retroactive_actual_pay_diff_id
                  ,payroll_calculation_exec_id
                  ,employee_no
                  ,payroll_item_id
                  --,payroll_item_detail_detail_id
                  --,pay_calc_rslt_detail_type_code
                  ,retroact_act_pay_diff_amount
                  ,retroactive_pay_target_yyyymm
                  ,creation_date
                  ,creation_user_id
                  )
                SELECT sq_tb_retro_actual_pay_diff_n.nextval
                      ,p_payroll_calculation_exec_id 
                      ,p_employee_no
                      ,cc.payroll_item_id
                      --,p_payroll_item_detail_id
                      --,p_rslt_detail_type_code
                      ,v_retro_amt - v_result_amt
                      ,v_current_yyyymm
                      ,SYSDATE
                      ,v_user_id
                FROM dual ;
                
            END IF;
            
        END LOOP;
        
    END LOOP;
    
    v_step :='Difference Amount Data : Payment Plan';
    FOR c IN c_differ_cur
    LOOP
    
        --퇴직일자
        v_step :='Get Retire Date : Payment Plan';
        SELECT nvl(to_char(em.date_retire,'yyyymmdd'),'47121231')
        INTO   v_retire_yyyymmdd
        FROM   emp_master em
        WHERE  employee_number = p_employee_no;
        
        IF TO_DATE(v_retire_yyyymmdd,'YYYYMMDD') >= v_apply_start_date AND
            TO_DATE(v_retire_yyyymmdd,'YYYYMMDD') <= v_apply_end_date THEN
            
            v_apply_end_date := TO_DATE(v_retire_yyyymmdd,'YYYYMMDD');
            
        END IF;
        
        ----------
        -- 기존 데이터 여부를 체크해야 하나, 기존에 Upload시는 소급여부가 'N' 이라서 재 작업시 삭제불가
        -- Detail에 소급여부를 두는 방법과 상관없이 그냥 소급분만 생성하고 지우는 방법이 있음
        ----------
        
        IF v_aggr_retroactive_pay_item_id <> c.aggr_retroactive_pay_item_id THEN
        
            v_step :='Insert tb_pay_item_payment_plan_n : Payment Plan';
            v_plan_id := sq_tb_pay_item_payment_plan_n.nextval;
            
            INSERT INTO tb_pay_item_payment_plan_n 
                  (payroll_item_payment_plan_id
                  ,payroll_item_id
                  ,employee_no
                  ,apply_start_date
                  ,apply_end_date
                  ,retroactive_flag
                  ,creation_date
                  ,creation_user_id
                  ,payroll_calculation_exec_id
                  )
            VALUES(v_plan_id                --payroll_item_payment_plan_id
                  ,c.aggr_retroactive_pay_item_id
                  ,p_employee_no            --employee_no
                  ,v_apply_start_date       --apply_start_date
                  ,v_apply_end_date         --apply_end_date
                  ,'Y'                      --retroactive_flag
                  ,sysdate                  --creation_date
                  ,v_user_id                --creation_user_id
                  ,p_payroll_calculation_exec_id
                  )
            ;
            
        END IF;
        
        v_aggr_retroactive_pay_item_id := c.aggr_retroactive_pay_item_id;
        
        v_step :='Insert tb_pay_payment_plan_detail_n : Payment Plan';
        INSERT INTO tb_pay_payment_plan_detail_n
              (payroll_item_pay_pln_detail_id
              ,payroll_item_payment_plan_id
              ,payroll_item_detail_detail_id
              ,apply_target_value
              ,creation_date
              ,creation_user_id
              ,last_update_date
              ,last_update_user_id
              )
        SELECT sq_tb_pay_pay_plan_detail_n.nextval
              ,v_plan_id
              ,c.payroll_item_detail_detail_id
              ,c.differ_amt
              ,sysdate
              ,v_user_id
              ,sysdate
              ,v_user_id
        FROM   dual
        ;
        
    END LOOP;
    
EXCEPTION
    WHEN v_exception THEN
          lgcom_error_log_pkg.set_comment_text(v_step);
          lgcom_error_log_pkg.set_error_code(NULL);
          lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
          lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);
    WHEN OTHERS THEN
          p_errbuf := SQLERRM;
          v_step :=v_step||chr(13)||' User Exception Error(difference_proc)';
          lgcom_error_log_pkg.set_comment_text(v_step);
          lgcom_error_log_pkg.set_error_code(NULL);
          lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
          lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);                        
END difference_proc; 
                       
end lgvpay_retro_payroll_run_pkg;
/
