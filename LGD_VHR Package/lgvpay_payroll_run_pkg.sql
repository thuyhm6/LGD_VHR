create or replace package vhr_mgr.lgvpay_payroll_run_pkg is
PROCEDURE run_proc( p_employee_no       IN VARCHAR2 DEFAULT NULL,
                     p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                     p_period_id         IN NUMBER , 
                     p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id           IN VARCHAR2,
                     p_errbuf            OUT VARCHAR,
                     p_payroll_calculation_exec_id OUT NUMBER );

PROCEDURE run_proc( p_employee_no        IN VARCHAR2 DEFAULT NULL,
                     p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                     p_period_id         IN NUMBER , 
                     p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id           IN VARCHAR2,
                     p_start_employee_no IN VARCHAR2,
                     p_end_employee_no   IN VARCHAR2,
                     p_payroll_calculation_exec_id IN  NUMBER,
                     p_errbuf                      OUT VARCHAR );


PROCEDURE retry_run    ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_subsidiary_code                IN VARCHAR2,
                         p_user_id                        in VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER );                      
                                          
PROCEDURE rollback_run ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  ) ;   
 
--급여실적집계                 
PROCEDURE summary_proc(p_payroll_calculation_exec_id    IN NUMBER
                      ,p_employee_no                    IN VARCHAR2
                      ,p_application_user_id            IN NUMBER
                      ,p_errbuf                         OUT VARCHAR2 
                      ); 

/*-- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAY.....';
    g_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    g_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;   */                     

end lgvpay_payroll_run_pkg;
/
create or replace package body vhr_mgr.lgvpay_payroll_run_pkg is
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : main_proc                                                */
/* Description    :  Payroll Run Main Program                                 */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28    SonSuyang        Initial Release                             */
/******************************************************************************/
PROCEDURE run_proc( p_employee_no        IN VARCHAR2 DEFAULT NULL,
                     p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                     p_period_id         IN NUMBER , 
                     p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id           IN VARCHAR2,
                     p_errbuf            OUT VARCHAR,
                     p_payroll_calculation_exec_id OUT NUMBER ) IS
                     
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
    
    p_errbuf_summary VARCHAR2(4000);
    
    
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_payroll_run_pkg';  
    

                         
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
      , creation_date
      , creation_user_id
    )
    SELECT l_execution_id
          , p_run_type_name
          , to_date(a.end_yyyymmdd ,'yyyymmdd')
          , p_assignment_set_id
          , 'N' 
          , SYSDATE
          , nvl(p_user_id,'admin')
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



    v_step :='call calc_proc';
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
   
        lgvpay_calculation_pkg.calc_proc(p_payroll_calculation_exec_id => l_execution_id,
                                          p_employee_no               => c.employee_no, 
                                          p_period_id                 => p_period_id, 
                                          p_run_type_name             => p_run_type_name,
                                          p_user_id                   => p_user_id
                                          );
                                          
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
        summary_proc(p_payroll_calculation_exec_id  => l_execution_id
                      ,p_employee_no                => c.employee_no
                      ,p_application_user_id        => p_user_id
                      ,p_errbuf                     => p_errbuf_summary
                      );     
        --DBMS_OUTPUT.PUT_LINE ('p_errbuf_summary=>'||p_errbuf_summary);                                                   
    END LOOP;
    

    
    p_errbuf := p_errbuf||'calc_proc Sucess !!' ;
    
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
/* Description    :  Payroll Run Main Program                                 */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28    SonSuyang        Initial Release                             */
/******************************************************************************/
PROCEDURE run_proc( p_employee_no        IN VARCHAR2 DEFAULT NULL,
                     p_assignment_set_id IN NUMBER   DEFAULT NULL, 
                     p_period_id         IN NUMBER , 
                     p_run_type_name     IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id           IN VARCHAR2,
                     p_start_employee_no IN VARCHAR2,
                     p_end_employee_no   IN VARCHAR2,
                     p_payroll_calculation_exec_id IN  NUMBER,
                     p_errbuf                      OUT VARCHAR ) IS
                     
    
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

    p_errbuf_summary   VARCHAR2(4000);
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_payroll_run_pkg';  
    
                         
BEGIN
    v_step :='';
    v_procedure_name := 'LGVPAY...: main_proc () ';
    
   --1)payroll_calculation_exec_id 채번 
   /*   SELECT sq_tb_pay_calc_exec_n.nextval
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
      , creation_date
      , creation_user_id
    )
    SELECT l_execution_id
          , p_run_type_name
          , to_date(a.end_yyyymmdd ,'yyyymmdd')
          , p_assignment_set_id
          , 'N' 
          , SYSDATE
          , nvl(p_user_id,'admin')
    FROM   tb_pay_calc_period_basis_n a
    WHERE  a.payroll_calculation_period_id = p_period_id
    ;
    
    p_payroll_calculation_exec_id := l_execution_id;
    
    p_errbuf :='Execution table Insert Sucess !! : Insert Count : '||sql%rowcount;
    
    lgcom_error_log_pkg.set_comment_text(v_step);
    lgcom_error_log_pkg.set_error_code(NULL);
    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
    lgcom_error_log_pkg.debug_prc(v_module_code, v_procedure_name);  */       
    
-- 1) assignment_set_id 가 있는경우   
-- 2) employee_no 가 있는 경우   

    v_step :='call calc_proc';
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
        
        
        lgvpay_calculation_pkg.calc_proc(p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                          p_employee_no               => c.employee_no, 
                                          p_period_id                 => p_period_id, 
                                          p_run_type_name             => p_run_type_name,
                                          p_user_id                   => p_user_id
                                          );
        /*\* Transfer result *\                                          
        summary_proc(p_payroll_calculation_exec_id  => p_payroll_calculation_exec_id
                      ,p_employee_no                => c.employee_no
                      ,p_application_user_id        => p_user_id
                      ,p_errbuf                     => p_errbuf
                      );   */
                                                  
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
        summary_proc(p_payroll_calculation_exec_id  => p_payroll_calculation_exec_id
                      ,p_employee_no                => c.employee_no
                      ,p_application_user_id        => p_user_id
                      ,p_errbuf                     => p_errbuf_summary
                      );                      
                                                                
        COMMIT;                                          
    END LOOP;
    
    p_errbuf := p_errbuf||'calc_proc Sucess !!' ;
    
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
/* Description    :  Retry payroll Run                                        */
/*                   Retry specific execution id   and Employee               */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/13   Son Suyang            Initial Release                         */
/******************************************************************************/
PROCEDURE retry_run    ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_subsidiary_code                IN VARCHAR2,
                         p_user_id                        in VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  )  IS
                         
    v_payroll_type_code   tb_pay_calc_exec_n.payroll_type_code%TYPE;  
    v_period_id           NUMBER; 
    p_errbuf_summary      VARCHAR2(4000);      
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_payroll_run_pkg';                  
BEGIN
    v_step := '';
    --1) delete table
    DELETE FROM  tb_pay_detail_calc_t pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete Result table ' ;              
    --2) Delete Result table
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM tb_pay_calc_result_n pcr
    WHERE  pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pcr.employee_no  IN ( SELECT pcst.employee_no
                                    FROM  tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pcr.employee_no = nvl(p_employee_no,pcr.employee_no))
            )
    ;
    
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';
    
    v_step :=v_step||chr(13) || ' 3) Delete Aggregate Result ' ;  
    --3) Delete Aggregate Result
    DELETE from tb_pay_calc_aggr_result_n pca
    WHERE  pca.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pca.employee_no  IN ( SELECT pcst.employee_no
                                    FROM  tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pca.employee_no = nvl(p_employee_no,pca.employee_no))
            );

    v_step := v_step||chr(13) ||v_step || SQL%ROWCOUNT ||' Deleted'; 
             
    
    DELETE FROM  tb_pay_calc_emp_exec_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete tb_pay_calc_emp_exec_n table ' ; 
    
    
    
    DELETE FROM  tb_pay_calc_emp_error_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete tb_pay_calc_emp_error_n table ' ; 
    
    
    SELECT a.payroll_type_code
         , b.payroll_calculation_period_id
    INTO   v_payroll_type_code
          ,v_period_id
    FROM   tb_pay_calc_exec_n  a
          ,tb_pay_calc_period_basis_n b
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    to_char(a.basis_date,'yyyymmdd') BETWEEN b.start_yyyymmdd AND b.end_yyyymmdd
    AND    b.subsidiary_code             = p_subsidiary_code
    ;
    
    -- payroll run
    
    lgvpay_payroll_run_pkg.run_proc( p_employee_no       => p_employee_no,
                                     p_assignment_set_id => p_payroll_calculation_set_id, 
                                     p_period_id         => v_period_id, 
                                     p_run_type_name     => v_payroll_type_code ,
                                     p_user_id           => p_user_id,
                                     p_start_employee_no => NULL,
                                     p_end_employee_no   => NULL,
                                     p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                     p_errbuf                      => p_errbuf );
                     
    
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
/* Description    :  Delete Payroll Run                                       */
/*                   Delete all date related with specific execution id       */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/13   Son Suyang            Initial Release                         */
/******************************************************************************/
PROCEDURE rollback_run ( p_payroll_calculation_exec_id    IN NUMBER,
                         p_payroll_calculation_set_id     IN NUMBER, 
                         p_employee_no                    IN VARCHAR2,
                         p_errbuf                         OUT VARCHAR2,
                         p_errcode                        OUT NUMBER  ) IS


    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAYC0013';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_payroll_run_pkg';                           
                             
BEGIN
    v_step := NULL;
    
    
    v_step := v_step||chr(13) ||' 1) Calculation Temp Table Delete' ;
    
    --1) Calculation Temp Table Delete
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM  tb_pay_detail_calc_t pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete Result table ' ;              
    --2) Delete Result table
    --  if calculation_set_id exists then , check tb_pay_calc_set_target_per_n
    --  or just check with employee_no 
    DELETE FROM tb_pay_calc_result_n pcr
    WHERE  pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pcr.employee_no  IN ( SELECT pcst.employee_no
                                    FROM  tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pcr.employee_no = nvl(p_employee_no,pcr.employee_no))
            )
    ;
    
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';
    
    v_step :=v_step||chr(13) || ' 3) Delete Aggregate Result ' ;  
    --3) Delete Aggregate Result
    DELETE from tb_pay_calc_aggr_result_n pca
    WHERE  pca.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pca.employee_no  IN ( SELECT pcst.employee_no
                                    FROM  tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pca.employee_no = nvl(p_employee_no,pca.employee_no))
            );

    v_step := v_step||chr(13) ||v_step || SQL%ROWCOUNT ||' Deleted'; 
    
    
    
    v_step := '4) Execution table DELETE';
    --4) Execution table Delete
    --   if only there is no data in tb_pay_calc_result_n, delete Data.
    DELETE FROM tb_pay_calc_exec_n pce
    WHERE  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    NOT EXISTS ( select 1 FROM  tb_pay_calc_result_n pcr WHERE pcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id)
    ;
    
    v_step := v_step||chr(13) || SQL%ROWCOUNT ||' Deleted';
    
    
    DELETE FROM  tb_pay_calc_emp_exec_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete tb_pay_calc_emp_exec_n table ' ; 
    
    
    
    DELETE FROM  tb_pay_calc_emp_error_n pdc
    WHERE  pdc.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ( 
            ( pdc.employee_no  IN ( SELECT pcst.employee_no
                                    FROM tb_pay_calc_set_target_per_n pcst 
                                    WHERE pcst.payroll_calculation_set_id = p_payroll_calculation_set_id
                                    AND   pcst.employee_no = nvl(p_employee_no,pcst.employee_no)
                               )) OR
            ( p_payroll_calculation_set_id IS NULL AND pdc.employee_no = nvl(p_employee_no,pdc.employee_no))
            );
     
    v_step :=v_step||chr(13) || v_step || SQL%ROWCOUNT ||' Deleted';            

    v_step :=v_step||chr(13) || ' 2) Delete tb_pay_calc_emp_error_n table ' ; 
    
    
    
    
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
/* Program Name    : summary_proc                                             */
/* Description    :  급여실적 집계                                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09   Kim jaehyun   Initial Release                                 */
/******************************************************************************/
PROCEDURE summary_proc(p_payroll_calculation_exec_id    IN NUMBER
                      ,p_employee_no                    IN VARCHAR2
                      ,p_application_user_id            IN NUMBER
                      ,p_errbuf                         OUT VARCHAR2 
                      )
IS
    v_program_id  lgcom_error_log.program_id%TYPE := 'LGVPAYC0008';
    v_user_id     number := -1; -- create_by, last_updated_by 에 이용
    
    v_rec         tb_pay_result_s%ROWTYPE;  --급여실적집계
    v_basis_date  date;      --기준일자
    v_retire_date date;      --퇴직일자
    v_chk_count   number;    --체크용
    v_exception   exception; --예외처리
    
    --20240828@Kimbiho Housing allow logic add
    v_housing_allow_nontaxable     NUMBER := 0;    
    v_housing_allow_taxable        NUMBER := 0;
    v_payroll_item_name            VARCHAR2(1000);
    v_increase_and_decrease_rate   NUMBER := 0;
    
    v_subsidiary_code VARCHAR2(30);
    
    -- error log기록을 위해서 global변수 선언.
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    v_procedure_name       lgcom_error_log.program_id%TYPE  := 'lgvpay_payroll_run_pkg';  
    
BEGIN
    v_step := '';
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    --기존 실적집계 삭제
    v_step := 'Delete tb_pay_result_s';
    delete
    from   tb_pay_result_s tpr
    where  tpr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    and    tpr.employee_no                 = p_employee_no
    ;
    
    -- subsidiary_code 가져오기
    SELECT subsidiary_code
    INTO   v_subsidiary_code
    FROM   emp_master
    WHERE  employee_number = p_employee_no
    ;
    
    
    --급여산출 실행 정보
    v_step := 'Get tb_pay_calc_exec_n';
    select pce.payroll_calculation_exec_id
          ,p_employee_no
          ,to_char(pce.basis_date, 'YYYYMM')
          ,pce.basis_date
          ,pce.payroll_type_code
          ,pce.payroll_calculation_set_id
          ,pcs.payroll_calculation_set_name
          ,ccc.common_code_desc
    into   v_rec.payroll_calculation_exec_id
          ,v_rec.employee_no
          ,v_rec.basis_yyyymm
          ,v_basis_date
          ,v_rec.payroll_type_code
          ,v_rec.payroll_calculation_set_id
          ,v_rec.payroll_calculation_set_name
          ,v_rec.payroll_type_name
    from   tb_pay_calc_exec_n  pce
          ,lgcom_common_code_c ccc
          ,tb_pay_calc_set_n   pcs
    where  pce.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    ccc.code_type_code= 'LGVHR_PAY_RUN_TYPE'
    AND    ccc.common_code = pce.payroll_type_code
    AND    pcs.payroll_calculation_set_id = pce.payroll_calculation_set_id
    ;
    
    v_step := 'Housing allowance logic add';
    -- Housing Allowance logic add 20240829@KimBiho
    -- v_basis_date
    SELECT NVL(result_value,0)
      INTO v_increase_and_decrease_rate
      FROM tb_pay_calc_var_n a
          ,tb_pay_calc_var_value_n b
     WHERE a.Payroll_Calc_Variable_Id = b.Payroll_Calc_Variable_Id
       AND to_char(v_basis_date,'YYYYMMDD') between b.effective_start_yyyymmdd and b.effective_end_yyyymmdd
       AND a.PAYROLL_CALC_VARIABLE_NAME = 'HOUSING_ALLW_RATE'
    ;
    
    IF v_increase_and_decrease_rate < 0 THEN v_increase_and_decrease_rate := 0;
    ELSIF v_increase_and_decrease_rate > 1 THEN v_increase_and_decrease_rate := 1;
    END IF;
    
    IF v_increase_and_decrease_rate = 0 THEN 
       v_housing_allow_nontaxable := 0;
    ELSE
       v_housing_allow_taxable := NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                            ,p_employee_no => p_employee_no
                                                            ,p_payroll_item_name => 'HOUSING_ALLW'
                                                            ,p_detail_name => 'PAY_VALUE'
                                                            ,p_subsidiary_code =>v_subsidiary_code ),0);
               
       v_housing_allow_nontaxable := (1 - v_increase_and_decrease_rate) * v_housing_allow_taxable;
    END IF;
    
    --급여산출 집계실적 정보
    v_step := 'Get tb_pay_calc_aggr_result_n';
    select count(*)
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'FIXED_ALLOWANCE',pcar.calculation_amount,0)) total_fixed_allowance  --고정급여총액 
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'ATTENDANCE_ALLOWANCE',pcar.calculation_amount,0))   --변동수당 
          /* 과세대상 총액에 주택자금을 받는 사람들은 별도 로직이 필요해서 부득이 하게 처리함 */
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'TAXALBE_EARNING_FOR_TAX',pcar.calculation_amount,0)) 
           - v_housing_allow_nontaxable -- Housing Allowance logic add 20240829@KimBiho
           
           /*  
           - NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                            ,p_employee_no => p_employee_no
                                                            ,p_payroll_item_name => 'HOUSING_ALLW'
                                                            ,p_detail_name => 'PAY_VALUE'
                                                            ,p_subsidiary_code =>v_subsidiary_code ),0)
           + NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                            ,p_employee_no => p_employee_no
                                            ,p_payroll_item_name => 'HOUSING_ALLW'
                                            ,p_detail_name => 'ALLOW_FOR_TAX'
                                            ,p_subsidiary_code =>v_subsidiary_code ),0) taxable_earning --과세대상총액
           */                                                 
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'TAXABLE_EARNINGS_IN_KIND',pcar.calculation_amount,0))   --과표추가 총액   
          /* 총 급료총액에 지각, 조퇴 , 외출이 들어가있으나 베트남에서는 해당 금액들을 공제로 보기 ??문에 
             총 급료총액에서 해당 금액을 다시 더해준다. 왜냐면 급료총액에서는 금액이 마이너스 되어있기 때문이다 . 
              */  
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'GROSS_SALARY',pcar.calculation_amount,0))   total_earning --Gross Salary
           
         /* 총 급료총액에 지각, 조퇴 , 외출이 들어가있으나 베트남에서는 해당 금액들을 공제로 보기 ??문에 총 공제총액에서 플러스  처리를 해준다. 
             그런데 이미 금액이 마이너스 이기 때문에 abs처리 후 더해준다.. */  
             
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'PRE_TAX_DEDUCTIONS',pcar.calculation_amount,0)) 
           + sum(DECODE(pia.payroll_item_aggregate_name ,'VOL_DEDUCTIONS',pcar.calculation_amount,0)) 
           + abs(sum(DECODE(pia.payroll_item_aggregate_name ,'TAXALBE_DEDUCTION',pcar.calculation_amount,0))) 
           + sum(DECODE(pia.payroll_item_aggregate_name ,'TAX_DEDUCTIONS',pcar.calculation_amount,0)) total_deductions
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'NET_AMOUNT',pcar.calculation_amount,0)) net_take --은행이체금액
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'HELPCALL_HR',pcar.calculation_amount,0)) helpcall --헬프콜지원시간수
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'NON_TAXALBE_EARNING',pcar.calculation_amount,0)) non_taxable_earning --비과세총액
          ,sum(DECODE(pia.payroll_item_aggregate_name ,'TOTAL_INCOME',pcar.calculation_amount,0)) total_income -- 총소득(세금과 보험은 따로 빼지 않음, 퇴직자들에 대해서 계산할때 사용함 )
    into   v_chk_count
          --,v_rec.base_pay_amount             --기본급금액
          ,v_rec.fixed_pay_total_amount      --고정급총금액
          ,v_rec.variable_allowance          --변동수당 
          ,v_rec.aggregate_taxation_amount   --집계계과세금액
          ,v_rec.assessment_add_amount       --과표추가금액
          ,v_rec.salary_total_amount         --급료총금액
          ,v_rec.deduction_total_amount      --공제총금액
          ,v_rec.bank_transfer_amount        --은행이체금액
          ,v_rec.helpcall_support_hours      --헬프콜지원시간수
          ,v_rec.tax_free_sum_amount         --비과세총액
          ,v_rec.total_income_amount
    from   tb_pay_calc_aggr_result_n pcar
          ,tb_pay_item_aggr_n        pia 
    where  pcar.payroll_item_aggregate_id   = pia.payroll_item_aggregate_id
    and    pcar.aggregate_cycle_type_code   = 'RUN'
    and    pcar.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    and    pcar.employee_no                 = p_employee_no
    ;
      
    if v_chk_count = 0
    then
        p_errbuf := 'No Data Found : Employee_no : ' || p_employee_no;
        raise v_exception;
    end if;
    
/*    --은행이체금액
    if v_rec.bank_transfer_amount < 0
    then
        v_rec.bank_transfer_amount := 0;
    end if;   */    
    
    --임직원정보
    v_step := 'Get Employee Info';
    select om.acc_org_code
          ,om.org_name_local
          ,ea.assignment_category
          ,lgvhr_common_pkg.decode_lookup('IF_EMP_CAT', ea.assignment_category)
          ,ea.grade_type
          ,ea.grade
          ,lgvhr_common_pkg.decode_lookup('IF_VIETNAM_GRADE_TITLE', ea.grade_title)
          ,pgp.competency_grade_point_code
          ,ea.job_group
          ,ea.job_family
          ,ea.job_detail 
          ,em.position
          ,lgvhr_common_pkg.decode_lookup('IF_POSITION', ea.position)
          ,to_char(em.date_hire_subsidiary, 'YYYYMMDD')
          ,to_char(em.date_absesce_leave, 'YYYYMMDD')
          ,to_char(em.date_retire, 'YYYYMMDD')
          ,em.probation_start_date
          ,em.probation_end_date
          ,em.bank_name
          ,em.account_number   
          ,em.date_retire   
          ,em.full_name_local  
    into   v_rec.organization_code
          ,v_rec.organization_name
          ,v_rec.employment_category_code
          ,v_rec.employment_category_name
          ,v_rec.grade_type_name
          ,v_rec.grade_title_code
          ,v_rec.grade_name
          ,v_rec.competency_grade_point_code
          ,v_rec.job_group_name
          ,v_rec.job_family_name
          ,v_rec.job_series_name
          ,v_rec.position_code
          ,v_rec.position_name
          ,v_rec.hire_yyyymmdd
          ,v_rec.absence_leave_yyyymmdd
          ,v_rec.resignation_yyyymmdd
          ,v_rec.probation_start_date
          ,v_rec.probation_end_date
          ,v_rec.bank_name
          ,v_rec.payment_bank_account_no
          ,v_retire_date 
          ,v_rec.full_name
    from   emp_master em
          ,emp_assig  ea
          ,org_master om
          ,tb_pay_emp_grade_point_n pgp
    where  em.employee_number = p_employee_no
    and    em.employee_number = ea.employee_number
    and    least(nvl(em.date_retire, v_basis_date), v_basis_date)  
                              between ea.assignment_start_date
                              and     to_date(ea.attribute1, 'YYYYMMDD')
    and    ea.organization_id = om.organization_id
    and    em.employee_number = pgp.employee_no(+)
    and    to_char(least(nvl(em.date_retire, v_basis_date), v_basis_date), 'YYYYMMDD') 
                              between pgp.start_yyyymmdd(+)
                              and     pgp.end_yyyymmdd(+)
    ;
    
    --통상임금
    v_step := 'Get Ordinary Wages';
    begin
        --급여기산기간안에 수습기간이 있으면 수습기간통상임금금액, 수습이 아닌 기간이 있으면 통상임금금액 구하기
        --수습시 : 수습종료일 or 급여기산종료일 작은값, 퇴직자는 퇴직일자로 
        --통상   : 퇴직일 or 급여기산종료일 작은값
        select case when ( cpb.start_yyyymmdd <= TO_CHAR(v_rec.probation_end_date,'YYYYMMDD')
                         and cpb.end_yyyymmdd >= TO_CHAR(v_rec.probation_start_date,'YYYYMMDD') ) 
                    then 
                        case WHEN v_retire_date IS NULL THEN  lgvpay_info_pkg.get_ordinary_wages(p_employee_no
                                                           ,least(to_char(v_rec.probation_end_date, 'YYYYMMDD'), cpb.end_yyyymmdd)
                                                           ,'A'
                                                           )
                        ELSE 
                            lgvpay_info_pkg.get_ordinary_wages(p_employee_no
                                                           ,least(to_char(v_retire_date, 'YYYYMMDD'), cpb.end_yyyymmdd)
                                                           ,'A'
                                                           )
                        END
                    else null
               end
              ,case when ( cpb.end_yyyymmdd > TO_CHAR(v_rec.probation_end_date,'YYYYMMDD') OR (v_rec.probation_start_date IS NULL AND v_rec.probation_end_date IS NULL ))
                    then lgvpay_info_pkg.get_ordinary_wages(p_employee_no
                                                           ,least(to_char(nvl(v_retire_date, lgvhr_common_pkg.end_of_time), 'YYYYMMDD'), cpb.end_yyyymmdd)
                                                           ,'B'
                                                           ) 
                    else null
               end 
        into   v_rec.probation_period_odwg_amount  --수습기간통상임금금액
              ,v_rec.ordinary_wages_amount         --통상임금금액
        from   tb_pay_calc_period_basis_n cpb
        where  cpb.subsidiary_code = 'LGDVN'
        and    to_char(v_basis_date, 'YYYYMMDD') between cpb.start_yyyymmdd
                                                 and     cpb.end_yyyymmdd
        ;
    exception 
        when others then
            lgcom_error_log_pkg.set_comment_text(v_step);
            lgcom_error_log_pkg.set_error_code(sqlcode);
            lgcom_error_log_pkg.set_error_explanation_text('Employee_no : ' || p_employee_no || ' - ' ||sqlerrm);
            lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);
    end;
    
    --계약정보
    v_step := 'Get Contract Info';
    begin
        select pec.contract_type_code
        into   v_rec.contract_type_code
        from   tb_pay_emp_contract_n pec
        where  pec.employee_no = p_employee_no
        and    v_basis_date    between pec.contract_period_start_date
                               and     nvl(pec.contract_period_end_date, v_basis_date)
        ;
    exception 
        when others then
            lgcom_error_log_pkg.set_comment_text(v_step);
            lgcom_error_log_pkg.set_error_code(sqlcode);
            lgcom_error_log_pkg.set_error_explanation_text('Employee_no : ' || p_employee_no || ' - ' ||sqlerrm);
            lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);
    end;
    
    --근태정보 + 세금정보 
    v_step := 'Get Attendance Info';
    begin
        SELECT lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id, p_employee_no, 'UNPAID_INFO', 'ABSENCE_DAYS',v_subsidiary_code)      --결근일수
              ,lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id, p_employee_no, 'UNPAID_INFO', 'UNPAID_LEAVES',v_subsidiary_code)     --무급휴가일수     
              ,lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id, p_employee_no, 'UNPAID_INFO', 'UNPAID_SUSPENSION',v_subsidiary_code) --무급휴직일수
              ,lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id, p_employee_no, 'UNPAID_INFO', 'WORKING_DAYS',v_subsidiary_code)      --근무일수 
              ,lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id, p_employee_no, 'PIT', 'PAY_VALUE',v_subsidiary_code)      --세금
        INTO   v_rec.absence_days
              ,v_rec.unpaid_vacation_days
              ,v_rec.unpaid_absence_leave_days
              ,v_rec.working_days
              ,v_rec.tax_amount
        FROM   dual
        ;
    exception 
        when others then
            lgcom_error_log_pkg.set_comment_text(v_step);
            lgcom_error_log_pkg.set_error_code(sqlcode);
            lgcom_error_log_pkg.set_error_explanation_text('Employee_no : ' || p_employee_no || ' - ' ||sqlerrm);
            lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);
    end;
    
    v_rec.creation_date       := sysdate;
    v_rec.creation_user_id    := v_user_id;
    v_rec.last_update_date    := sysdate;
    v_rec.last_update_user_id := v_user_id;
    
    --급여실적집계 저장
    v_step := 'Inset tb_pay_result_s';
    
    
    insert into tb_pay_result_s
    values v_rec
    ;
        
EXCEPTION
    WHEN v_exception THEN
          lgcom_error_log_pkg.set_comment_text(v_step);
          lgcom_error_log_pkg.set_error_code(NULL);
          lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
          lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);
    WHEN OTHERS THEN
          p_errbuf := SQLERRM;
          v_step :=v_step||chr(13)|| 'User Exception Error(summary_proc)';
          lgcom_error_log_pkg.set_comment_text(v_step);
          lgcom_error_log_pkg.set_error_code(NULL);
          lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
          lgcom_error_log_pkg.error_prc(v_module_code, v_program_id);                        
END summary_proc; 
                       
end lgvpay_payroll_run_pkg;
/
