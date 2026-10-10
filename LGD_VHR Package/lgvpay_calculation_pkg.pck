CREATE OR REPLACE PACKAGE VHR_MGR.lgvpay_calculation_pkg IS
PROCEDURE calc_proc(p_payroll_calculation_exec_id IN NUMBER ,
                    p_employee_no IN VARCHAR2, 
                    p_period_id IN NUMBER, 
                    p_run_type_name        IN VARCHAR2 DEFAULT 'MTH',
                    p_user_id             IN VARCHAR2);
FUNCTION calculate_pay(p_employee_no IN VARCHAR2, 
                     p_payroll_calculation_exec_id IN NUMBER,
                     p_payroll_item_id IN NUMBER, 
                     p_period_id IN NUMBER, 
                     p_run_type_name        IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id             IN VARCHAR2)
RETURN NUMBER ;
PROCEDURE calculation_base_pay( p_employee_no IN VARCHAR2, 
                               p_period_id   IN NUMBER,
                               p_payroll_calculation_exec_id IN NUMBER,
                               p_payroll_item_id IN NUMBER,
                               p_run_type_name   IN VARCHAR2,
                               p_user_id             IN VARCHAR2
                              );

PROCEDURE calculation_position_allw( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );   
                                
PROCEDURE calculation_encour_allw( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );
                                
PROCEDURE calculation_hardship_allw( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );                                
                     
PROCEDURE calculation_qualification_allw( p_employee_no                 IN VARCHAR2, 
                                          p_period_id                   IN NUMBER,
                                          p_payroll_calculation_exec_id IN NUMBER,
                                          p_payroll_item_id             IN NUMBER,
                                          p_run_type_name               IN VARCHAR2,
                                          p_user_id                     IN VARCHAR2 );  

PROCEDURE calculation_job_allw( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 ); 

PROCEDURE calculation_adj1( p_employee_no                 IN VARCHAR2, 
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 );    


PROCEDURE calculation_adj2( p_employee_no                 IN VARCHAR2, 
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 );    
                            

PROCEDURE calculation_adj3( p_employee_no                 IN VARCHAR2, 
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 );                                                                                                                                 
                                                                                           
PROCEDURE create_result( p_payroll_calculation_exec_id    IN NUMBER,
                         p_employee_no                    IN VARCHAR2,       
                         p_payroll_item_id                IN NUMBER,  
                         p_payroll_item_detail_id         IN NUMBER  ,
                         p_rslt_detail_type_code IN VARCHAR2,
                         p_result_value                   IN VARCHAR2,
                         p_user_id                        IN VARCHAR2,
                         p_period_id                      IN NUMBER);                         
  
PROCEDURE calculation_std_ot( p_employee_no                 IN VARCHAR2, 
                              p_period_id                   IN NUMBER,
                              p_payroll_calculation_exec_id IN NUMBER,
                              p_payroll_item_id             IN NUMBER,
                              p_run_type_name               IN VARCHAR2,
                              p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_std_ot( p_employee_no                 IN VARCHAR2, 
                              p_period_id                   IN NUMBER,
                              p_payroll_calculation_exec_id IN NUMBER,
                              p_payroll_item_id             IN NUMBER,
                              p_run_type_name               IN VARCHAR2,
                              p_user_id                     IN VARCHAR2,
                              p_tax_amount                  OUT NUMBER,
                              p_nontax_amount                  OUT NUMBER,
                              p_ot_count                    OUT NUMBER );  

PROCEDURE calculation_150ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_150ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER  );      


PROCEDURE calculation_200ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_200ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );  
                                
                                                                                           
                                                                                    
PROCEDURE calculation_300ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_300ot( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );  
                                
PROCEDURE calculation_200nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_200nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );  


PROCEDURE calculation_210nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_210nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );     
                                


PROCEDURE calculation_270nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_270nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER, 
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );   


PROCEDURE calculation_390nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_390nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER );     


PROCEDURE calculation_30nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_30nt( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER );                                                                                                                          
                                                                

PROCEDURE calculation_tardy ( p_employee_no                IN VARCHAR2, 
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 );

PROCEDURE calculation_tardy ( p_employee_no                IN VARCHAR2, 
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_ded_amount                  OUT NUMBER,
                             p_ot_count                    OUT NUMBER ) ;      


PROCEDURE calculation_goout ( p_employee_no                IN VARCHAR2, 
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 );

PROCEDURE calculation_goout ( p_employee_no                IN VARCHAR2, 
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_ded_amount                  OUT NUMBER,
                             p_ot_count                    OUT NUMBER ) ;   


PROCEDURE calculation_early_leave ( p_employee_no                IN VARCHAR2, 
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2 );

PROCEDURE calculation_early_leave ( p_employee_no                 IN VARCHAR2, 
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2,
                                    p_ded_amount                  OUT NUMBER,
                                    p_ot_count                    OUT NUMBER ) ;
                                                            


PROCEDURE calculation_unpaid_deduction (  p_employee_no                 IN VARCHAR2, 
                                          p_period_id                   IN NUMBER,
                                          p_payroll_calculation_exec_id IN NUMBER,
                                          p_payroll_item_id             IN NUMBER,
                                          p_run_type_name               IN VARCHAR2,
                                          p_user_id                     IN VARCHAR2 );


PROCEDURE calculation_unpaid_deduction ( p_employee_no                 IN VARCHAR2, 
                                         p_period_id                   IN NUMBER,
                                         p_payroll_calculation_exec_id IN NUMBER,
                                         p_payroll_item_id             IN NUMBER,
                                         p_run_type_name               IN VARCHAR2,
                                         p_user_id                     IN VARCHAR2,
                                         p_ded_amount                  OUT NUMBER,
                                         p_total_unpaid_days           OUT NUMBER,
                                         p_absence_days                OUT number,
                                         p_unpaid_leaves               OUT NUMBER,
                                         p_unpaid_suspension           OUT NUMBER,
                                         p_working_days                OUT NUMBER );


PROCEDURE calculation_annual_leave ( p_employee_no                IN VARCHAR2, 
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2 );

PROCEDURE calculation_annual_leave ( p_employee_no                IN VARCHAR2, 
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2,
                                    p_retire_flag                 IN VARCHAR2,
                                    p_ded_amount                  OUT NUMBER,
                                    p_an_count                    OUT NUMBER ) ;                                                                                                                                                                                                 
                                
                                
PROCEDURE calculation_pit( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 );

PROCEDURE calculation_pit( p_employee_no                 IN VARCHAR2, 
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_pit                            OUT NUMBER,
                                p_dependant_deduction            OUT NUMBER,
                                p_total_incom_for_tax         OUT NUMBER,
                                p_exception_flag              OUT VARCHAR2 );   


PROCEDURE calculation_si( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) ;

PROCEDURE calculation_si( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_si_employee                 OUT NUMBER,
                          p_si_employer                 OUT NUMBER );    


PROCEDURE calculation_tu( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) ;

PROCEDURE calculation_tu( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_tu_employee                 OUT NUMBER,
                          p_tu_employer                 OUT NUMBER );                            

                          
PROCEDURE calculation_hi( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) ;

PROCEDURE calculation_hi( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_hi_employee                 OUT NUMBER,
                          p_hi_employer                 OUT NUMBER );   



PROCEDURE calculation_ui( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) ;

PROCEDURE calculation_ui( p_employee_no                 IN VARCHAR2, 
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_ui_employee                 OUT NUMBER,
                          p_ui_employer                 OUT NUMBER );  

FUNCTION get_ordinary_wage(p_payroll_calculation_exec_id    IN NUMBER,
                           p_employee_no                    IN VARCHAR2,
                           p_basis_yyyymmdd                 IN VARCHAR2 ) RETURN NUMBER;


PROCEDURE calculation_housing_allw( p_employee_no                 IN VARCHAR2, 
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                    IN VARCHAR2 );  


PROCEDURE calculation_transport_allw( p_employee_no                 IN VARCHAR2, 
                                      p_period_id                   IN NUMBER,
                                      p_payroll_calculation_exec_id IN NUMBER,
                                      p_payroll_item_id             IN NUMBER,
                                      p_run_type_name               IN VARCHAR2,
                                      p_user_id                     IN VARCHAR2 );   


PROCEDURE calculation_att_incentive( p_employee_no                 IN VARCHAR2, 
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 );    
                                     
/* 20180402 new allowance add
    menstruation allowance */                                    
PROCEDURE calculation_mens_allowance( p_employee_no                 IN VARCHAR2, 
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 );  
                                     
--HMT 20250513 child incentive
PROCEDURE calculation_child_incentive( p_employee_no                 IN VARCHAR2, 
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 );                                                                                            
                                                                                                                                                                

/*    -- error log??? ??? global?? ??.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'LGVPAY.....';
    g_step lgcom_error_log.error_explanation_text%TYPE      := NULL; 
    g_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;*/   
    
    TYPE out_param_res_type IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER ;
 
    
       
                                                                                                      
end lgvpay_calculation_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvpay_calculation_pkg IS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calc_proc                                                */
/* Description    :  Payoll Running by Employee                               */
/*                   call Program ordering Payroll Item Priority              */
/*                   Calcuation using Dynamic SQL                             */
/*                   Payroll ? run?? ?? payroll item?? ????.       */
/*                   ?? )                                                   */
/*                   1. Payroll_item ? AUTO_FLAG = 'Y'                       */
/*                   2. ???? PLAN?? ??? ???? PAY_VALUE ? ?? ??
/*                       -> ??? ? ?? ??? ????.
/*                   3. ???? PLAN ?? ??? ?? ?? FORMULA? ??? ??
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28    SonSuyang      Initial Release                               */
/* 2018/09/14    KimTaehyun     Retroactive Payroll Calculate                 */
/* 2021/03/23    HMT_20210323   Change payroll cacualtion (v_total_time): 
                                Use "work_hour" to caculate the month of perfect_work_hours*/
/* 2021/04/20    HMT_20210420   Year over OT caculate                         */
/* 2025/11/01    HMT_20251101   Add new monthly payroll - resign (MTH_RS)              */
/******************************************************************************/

g_add_ot_time             NUMBER;

PROCEDURE calc_proc( p_payroll_calculation_exec_id IN NUMBER ,
                     p_employee_no                 IN VARCHAR2,
                     p_period_id                   IN NUMBER,
                     p_run_type_name               IN VARCHAR2 DEFAULT 'MTH',
                     p_user_id                     IN VARCHAR2 ) IS

CURSOR c_item_cur IS
SELECT *
FROM (
        SELECT  a.payroll_item_id
              , a.payroll_calculation_formula_id
              , b.payroll_calc_formula_value
              , -1     payroll_item_detail_detail_id
              , 'xx'   apply_target_value
              , a.payroll_item_calc_prrt_value
              , 'calc' calc_type
              --< 20180914 KTH Start Add
              -- Seperation Actual or Retroactive
              , NVL(a.retroactive_flag,'N') retroactive_flag
              -->
        FROM    tb_pay_payroll_item_m      a
              , tb_pay_calc_formula_n      b
              , tb_pay_calc_period_basis_n c
              , tb_pay_calc_mthd_n         d
        WHERE   b.payroll_calculation_formula_id = a.payroll_calculation_formula_id
        AND     c.payroll_calculation_period_id  = p_period_id
        AND    c.end_yyyymmdd                    BETWEEN a.start_yyyymmdd AND nvl(a.end_yyyymmdd,'47121231')
        AND    d.payroll_item_id                 = a.payroll_item_id
        AND    d.payroll_calc_method_code        ='AUTO_FLAG'
        AND    d.payroll_apply_flag              = 'Y'
        AND    EXISTS  ( SELECT 1
                         FROM  tb_pay_payroll_item_use_n piu
                         WHERE piu.payroll_item_id   = a.payroll_item_id
                         AND   c.end_yyyymmdd      BETWEEN piu.effective_start_yyyymmdd AND piu.effective_end_yyyymmdd
                         AND   piu.payroll_type_code = p_run_type_name) -- ?? run ??? ???? ??
        UNION
        /* Planned ? item ?? pay value ? ?? ?? ???? ?? ??? ??? result ? ??? */
        SELECT /*+ INDEX ( PPPD TB_PAY_PAYMENT_P_DET_N_N1 ) */
                pipp.payroll_item_id
              , 0    payroll_calculation_formula_id
              , NULL payroll_calc_formula_value
              , pppd.payroll_item_detail_detail_id
              , to_char(sum(to_number(pppd.apply_target_value)))   apply_target_value  -- IF Amount then add or subtract amount
              , ppi.payroll_item_calc_prrt_value
              , 'entry' calc_type
              , NVL(ppi.retroactive_flag,'N') retroactive_flag
        FROM    tb_pay_calc_period_basis_n   pcpb
              , tb_pay_item_payment_plan_n   pipp
              , tb_pay_payment_plan_detail_n pppd
              , tb_pay_payroll_item_m        ppi
              , lgcom_common_code_c          cc
              , tb_pay_item_detail_n         pid
              , emp_master                    em
        WHERE em.employee_number                   = p_employee_no
        AND   pcpb.payroll_calculation_period_id   = p_period_id
        AND   least(nvl(em.date_retire,to_date('47121231','yyyymmdd')),to_date(pcpb.end_yyyymmdd,'yyyymmdd')) BETWEEN pipp.apply_start_date AND pipp.apply_end_date
        AND   pipp.employee_no                     = em.employee_number
        AND   pppd.payroll_item_payment_plan_id    = pipp.payroll_item_payment_plan_id
        AND   ppi.payroll_item_id                  = pipp.payroll_item_id
        AND   pid.payroll_item_detail_detail_id    = pppd.payroll_item_detail_detail_id
        AND   cc.code_type_code                    = 'LGDVHR_PAY_CLASS_TYPE_CODE'
        AND   cc.common_code                       = ppi.pay_item_classification_code
        AND   pid.additional_input_value                = 'PAY_VALUE'
        AND   pppd.apply_target_value IS NOT NULL
        AND    EXISTS  ( SELECT 1
                         FROM  tb_pay_payroll_item_use_n piu
                         WHERE piu.payroll_item_id    = ppi.payroll_item_id
                         AND   pcpb.end_yyyymmdd      BETWEEN piu.effective_start_yyyymmdd AND piu.effective_end_yyyymmdd
                         AND   piu.payroll_type_code  = p_run_type_name) -- ?? run ??? ???? ??
        GROUP BY pipp.payroll_item_id
               , pppd.payroll_item_detail_detail_id
               , ppi.payroll_item_calc_prrt_value
               , NVL(ppi.retroactive_flag,'N')
        UNION
        SELECT  pppi.payroll_item_id
              , pppi.payroll_calculation_formula_id    payroll_calculation_formula_id
              , pcf.payroll_calc_formula_value  payroll_calc_formula_value
              , -1   payroll_item_detail_detail_id
              , 'xx'   apply_target_value  -- IF Amount then add or subtract amount
              , pppi.payroll_item_calc_prrt_value
              , 'calc' calc_type
          --  , pppi.payroll_item_name
              , NVL(pppi.retroactive_flag,'N') retroactive_flag
        FROM    tb_pay_calc_period_basis_n   pcpb
              , tb_pay_item_payment_plan_n   pipp
              , tb_pay_payment_plan_detail_n pppd
              , tb_pay_payroll_item_m        pppi  -- caludation item only
              , tb_pay_item_detail_n         pid
              , tb_pay_payment_plan_detail_n pppd1
              , tb_pay_item_detail_n         pid1
              , tb_pay_calc_formula_n        pcf
              , emp_master                    em
        WHERE  em.employee_number                   = p_employee_no
        and   pcpb.payroll_calculation_period_id = p_period_id
        --AND   least(nvl(em.date_retire,to_date('47121231','yyyymmdd')),to_date(pcpb.end_yyyymmdd,'yyyymmdd')) BETWEEN pipp.apply_start_date AND pipp.apply_end_date
        AND   ( pipp.apply_end_date >= to_date(pcpb.start_yyyymmdd,'yyyymmdd') and pipp.apply_start_date <= to_date(pcpb.end_yyyymmdd,'yyyymmdd'))
        AND   pipp.employee_no                    = em.employee_number
        AND   pppd.payroll_item_payment_plan_id   = pipp.payroll_item_payment_plan_id
        AND   pppi.payroll_item_id                = pipp.payroll_item_id
        AND   pcpb.end_yyyymmdd                    BETWEEN pppi.start_yyyymmdd AND nvl(pppi.end_yyyymmdd,'47121231')
        AND   pppi.payroll_calculation_formula_id > 0
        AND   pid.additional_input_value          = 'PAY_VALUE'
        AND   pppd.payroll_item_detail_detail_id  = pid.payroll_item_detail_detail_id
        AND   pppd.apply_target_value             IS NULL
        AND   pppd1.payroll_item_payment_plan_id  = pipp.payroll_item_payment_plan_id
        AND   pid1.payroll_item_detail_detail_id  = pppd1.payroll_item_detail_detail_id
        AND   pid1.additional_input_value         <> 'PAY_VALUE'
        AND   pppd1.apply_target_value            IS NOT NULL
        AND   pcf.payroll_calculation_formula_id  = pppi.payroll_calculation_formula_id
        AND   EXISTS  ( SELECT 1
                         FROM  tb_pay_payroll_item_use_n piu
                         WHERE piu.payroll_item_id   = pppi.payroll_item_id
                         AND   pcpb.end_yyyymmdd     BETWEEN piu.effective_start_yyyymmdd AND piu.effective_end_yyyymmdd
                         AND   piu.payroll_type_code = p_run_type_name) -- ?? run ??? ???? ??
      )
ORDER BY payroll_item_calc_prrt_value
;

/* ??? ?? ( formula? parameter list) */
CURSOR c_cur_param (c_payroll_calc_formula_id IN NUMBER) IS
SELECT upper(a.parameter_value) parameter_value
      , a.parameter_io_type_code
      , a.data_type_code
FROM   tb_pay_calc_formula_param_n  a
WHERE  a.payroll_calculation_formula_id = c_payroll_calc_formula_id
AND    a.parameter_io_type_code         = 'IN'
ORDER BY a.sort_order_no;



    v_sql_f         VARCHAR2(100) ;
    v_sql_m         VARCHAR2(4000):=' ';
    v_sql_l         VARCHAR2(4000);
    v_sql           CLOB;
    v_sql_value     VARCHAR2(4000);
    l_count         NUMBER        := 0;
    v_separate      VARCHAR2(10);
    v_char_argu     VARCHAR2(10)  := '''';
    v_param_type    VARCHAR2(10);
    v_item_count    NUMBER        := 0;
    v_param_value   VARCHAR2(4000);
    v_sql_header    VARCHAR2(100);

    v_err_buf       VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := '';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;
    v_retroactive_flag     tb_pay_calc_exec_n.retroactive_flag%TYPE := NULL;


BEGIN

    --< 20181030 KTH Start Add
    --32 Shift? ?? ??????? ??? ?? ???
    g_add_ot_time    := 0;
    -->
    v_procedure_name := 'calc_proc()';

    v_sql_header := 'BEGIN'||chr(13);
    /* item? ??? ??? ???? paramter ? ????
       begin procedure1; procedure2 ;....end ; ??? ?????.
    */

    --< 20180914 KTH Start Add
    -- Seperation Actual or Retroactive
    SELECT NVL(a.retroactive_flag,'N')
    INTO   v_retroactive_flag
    FROM   tb_pay_calc_exec_n a
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    ;
    -->

    FOR c IN c_item_cur
    LOOP

        --< 20180914 KTH Start Add
        -- Seperation Actual or Retroactive
        IF v_retroactive_flag = 'N' THEN
        -->
            v_item_count := v_item_count +1;

            IF c.calc_type = 'calc' THEN

                v_sql_f := c.payroll_calc_formula_value||'(';
                v_param_value := '';
                v_sql_m       := '';
                l_count       := 0;

                FOR c_param IN c_cur_param(c.payroll_calculation_formula_id)
                LOOP

                    l_count:= l_count+1;
                    IF l_count = 1 THEN
                        v_separate := ' ';
                    ELSE
                        v_separate := ' , ';
                    END IF;

                    IF c_param.data_type_code = 'C' THEN
                        v_param_type := v_char_argu;
                    ELSE
                        v_param_type := '';
                    END IF;

                    IF c_param.parameter_value = 'P_EMPLOYEE_NO'  THEN
                         v_param_value := v_separate||v_param_type||P_EMPLOYEE_NO||v_param_type;
                    ELSIF c_param.parameter_value = 'P_PERIOD_ID'  THEN
                        v_param_value := v_separate||v_param_type||P_PERIOD_ID||v_param_type ;
                    ELSIF c_param.parameter_value = 'P_PAYROLL_CALCULATION_EXEC_ID'  THEN
                        v_param_value := v_separate||v_param_type||P_PAYROLL_CALCULATION_EXEC_ID||v_param_type;
                    ELSIF c_param.parameter_value = 'P_PAYROLL_ITEM_ID'  THEN
                        v_param_value := v_separate||v_param_type||c.payroll_item_id||v_param_type;
                    ELSIF c_param.parameter_value = 'P_RUN_TYPE_NAME'  THEN
                        v_param_value := v_separate||v_param_type||P_RUN_TYPE_NAME||v_param_type;
                    ELSIF c_param.parameter_value = 'P_USER_ID'  THEN
                        v_param_value := v_separate||v_param_type||P_USER_ID||v_param_type;
                    END IF;

                    v_sql_m := v_sql_m || v_param_value;

                END LOOP;

               v_sql := v_sql|| v_sql_f||v_sql_m || ') ;'|| chr(13);        --v_sql_l := ');  end;';

            ELSE
               v_sql := v_sql|| 'lgvpay_calculation_pkg.create_result('||p_payroll_calculation_exec_id
                                                ||', '||''''||p_employee_no||''''
                                                ||', '||c.payroll_item_id
                                                ||', '||c.payroll_item_detail_detail_id
                                                ||', '||''''||'A'||''''
                                                ||', '||''''||c.apply_target_value||''''
                                                ||', '||''''||p_user_id||''''
                                                ||', '||p_period_id
                                                ||');'||chr(13);
            END IF;

        --< 20180914 KTH Start Add
        -- Retroactive Payroll Case
        ELSE

            -- Retroactive Payroll Item Only
            IF c.retroactive_flag = 'Y' THEN

                v_item_count := v_item_count +1;

                IF c.calc_type = 'calc' THEN

                    v_sql_f := c.payroll_calc_formula_value||'(';
                    v_param_value := '';
                    v_sql_m       := '';
                    l_count       := 0;

                    FOR c_param IN c_cur_param(c.payroll_calculation_formula_id)
                    LOOP

                        l_count:= l_count+1;
                        IF l_count = 1 THEN
                            v_separate := ' ';
                        ELSE
                            v_separate := ' , ';
                        END IF;

                        IF c_param.data_type_code = 'C' THEN
                            v_param_type := v_char_argu;
                        ELSE
                            v_param_type := '';
                        END IF;

                        IF c_param.parameter_value = 'P_EMPLOYEE_NO'  THEN
                             v_param_value := v_separate||v_param_type||P_EMPLOYEE_NO||v_param_type;
                        ELSIF c_param.parameter_value = 'P_PERIOD_ID'  THEN
                            v_param_value := v_separate||v_param_type||P_PERIOD_ID||v_param_type ;
                        ELSIF c_param.parameter_value = 'P_PAYROLL_CALCULATION_EXEC_ID'  THEN
                            v_param_value := v_separate||v_param_type||P_PAYROLL_CALCULATION_EXEC_ID||v_param_type;
                        ELSIF c_param.parameter_value = 'P_PAYROLL_ITEM_ID'  THEN
                            v_param_value := v_separate||v_param_type||c.payroll_item_id||v_param_type;
                        ELSIF c_param.parameter_value = 'P_RUN_TYPE_NAME'  THEN
                            v_param_value := v_separate||v_param_type||P_RUN_TYPE_NAME||v_param_type;
                        ELSIF c_param.parameter_value = 'P_USER_ID'  THEN
                            v_param_value := v_separate||v_param_type||P_USER_ID||v_param_type;
                        END IF;

                        v_sql_m := v_sql_m || v_param_value;

                    END LOOP;

                   v_sql := v_sql|| v_sql_f||v_sql_m || ') ;'|| chr(13);        --v_sql_l := ');  end;';

                ELSE
                   v_sql := v_sql|| 'lgvpay_calculation_pkg.create_result('||p_payroll_calculation_exec_id
                                                    ||', '||''''||p_employee_no||''''
                                                    ||', '||c.payroll_item_id
                                                    ||', '||c.payroll_item_detail_detail_id
                                                    ||', '||''''||'A'||''''
                                                    ||', '||''''||c.apply_target_value||''''
                                                    ||', '||''''||p_user_id||''''
                                                    ||', '||p_period_id
                                                    ||');'||chr(13);
                END IF;
            END IF;

        END IF;
        -->

    END LOOP;



    v_sql :=v_sql_header|| v_sql || '  END;';

   --dbms_output.put_line(v_sql);

    v_step := 'Calculation Payroll : clac_proc()';

    EXECUTE IMMEDIATE v_sql;



EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calc_proc : =>'||SQLERRM);
        v_err_buf := 'calc_proc error =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculate_pay                                            */
/* Description    :  ???? ?? ??? ???? funciton                   */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28                   Initial Release                               */
/* 2018/10/05    KimTaehyun     Change Shift Type Code                        */
/* 2018/10/25    KimTaehyun     32 Shift? ?? ???? ????             */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/* 2021/10/08    HMT_20211008   Use result_n's shift_code change for assignment's shift_code      */
/* 2022/02/16    HMT_20220216   Use result_n's to caculate work_days      */
/******************************************************************************/
FUNCTION calculate_pay(p_employee_no                 IN VARCHAR2,
                       p_payroll_calculation_exec_id IN NUMBER,
                       p_payroll_item_id             IN NUMBER,
                       p_period_id                   IN NUMBER,
                       p_run_type_name               IN VARCHAR2 DEFAULT 'MTH',
                       p_user_id                     IN VARCHAR2)
RETURN NUMBER IS
    v_total_period     NUMBER; --?????
    v_shift_period     NUMBER; --?????
    v_total_time       NUMBER; --?????
    v_shift_tot_time   NUMBER := 0; --?????
    v_shift_time       NUMBER := 0; --???? HMT_20210323 default = 0
    v_total_amount     NUMBER := 0; --Total amount of return
    v_return           NUMBER := 0;
    v_shift_type_code  VARCHAR2(10);
    v_subsidiary_code  VARCHAR2(10);
    v_yyyymm           tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_amount           NUMBER := 0;
    v_err_buf          VARCHAR2(4000);
    v_working_days     NUMBER := 0;
    v_total_days       NUMBER := 0;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := '';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

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

--dbms_output.put_line('p_payroll_item_id=.'||p_payroll_item_id||'start=.'|| to_char(SYSDATE,'yyyymmdd hh24:mi:ss'));

    --< 20181005 KTH Start Add
    -- ????? shift code? emp_master => emp_assig
    --get employee master
    /*
    SELECT NVL(em.attribute10 ,'1A')
          ,pcpb.payroll_calc_period_value
          ,pcpb.subsidiary_code
    INTO   v_shift_type_code,
           v_yyyymm,
           v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
          ,emp_master em
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                 = p_employee_no
    ;
    */
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.subsidiary_code
    INTO   v_yyyymm,
           v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;
    -->

    IF p_run_type_name IN ('MTH', 'MTH_RS') --HMT_20251101
    THEN
        --Total working days for a month
        v_step := 'Calculation Payroll : perfect_attendance_days';

        /*SELECT acn.perfect_attendance_days
              ,acn.perfect_attendance_days * 8
        INTO   v_total_period
              ,v_total_time
        FROM   tb_att_close_n acn
        WHERE  acn.subsidiary_code                   = v_subsidiary_code
        AND    acn.time_and_attendance_yyyymm        = v_yyyymm
        ;*/
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days, --Old           
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0) *  DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours --Old 

        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
    END IF;


    FOR c IN c_cur
    LOOP
        /*------------TaiDD------------Start--------*/
        v_shift_tot_time := 0;
        v_total_days := 0;
       /*------------TaiDD------------End--------*/
        --< 20181025 KTH Start Add

        --?? ?? ??(?? ??(???? / ?? ? ??) * ?? ??)
        --????*(????-????+1)/?? ? ??*(+1?? -1??? ?? ?)
        /*
        SELECT c.payment_base_amount * c.increase_and_decrease_rate / v_total_period * COUNT(*), COUNT(*)
        INTO   v_amount, v_working_days
        FROM  (
                  SELECT ( c.basis_start_date -1 + rownum)  ymd
                  FROM   dual
                  CONNECT BY LEVEL <= c.basis_end_date - c.basis_start_date +1
               ) days
              , tb_att_base_bas_n bas
              , tb_att_code_c     acc
        WHERE bas.time_and_attendance_yyyymm  = v_yyyymm
        AND   bas.shift_type_code             = v_shift_type_code
        AND   acc.time_and_attendance_code    = bas.time_and_attendance_code
        AND   ( acc.attendance_days > 0 OR acc.unpaid_days > 0 OR acc.paid_days > 0)
        AND   days.ymd                        = bas.time_and_attendance_date;

        v_return := v_return + v_amount;

        UPDATE  tb_pay_detail_calc_t pdcc
        SET     pdcc.working_days = v_working_days
        WHERE   pdcc.payroll_calculation_exec_id = c.payroll_calculation_exec_id
        AND     pdcc.employee_no                 = c.employee_no
        AND     pdcc.payroll_item_id             = c.payroll_item_id
        AND     pdcc.basis_start_date            = c.basis_start_date
        ;
        */

        FOR c_r IN (SELECT ( c.basis_start_date -1 + rownum)  ymd
                    FROM   dual
                    CONNECT BY LEVEL <= c.basis_end_date - c.basis_start_date +1 )
        LOOP

            v_step := 'Calculation Payroll : Emplyoee Shift Code';
            SELECT --NVL(ea.attribute10 ,'1A')  --HMT_20211008
                   ar.shift_type_code
                  ,pcpb.payroll_calc_period_value
                  ,pcpb.subsidiary_code
            INTO   v_shift_type_code,
                   v_yyyymm,
                   v_subsidiary_code
            FROM   tb_pay_calc_period_basis_n pcpb
                  ,emp_master em
                  ,emp_assig  ea
                  ,tb_att_result_n ar
            WHERE  pcpb.payroll_calculation_period_id = p_period_id
            AND    em.employee_number                 = p_employee_no
            AND    ea.employee_number                 = em.employee_number
            AND    least(nvl(em.date_retire,c_r.ymd) , c_r.ymd) BETWEEN ea.assignment_start_date AND to_date(ea.attribute1,'yyyymmdd')
            AND    em.employee_number = ar.employee_no--HMT_20211008
            AND    c_r.ymd = ar.time_and_attendance_date --HMT_20211008
            ;

            v_step := 'Calculation Payroll : 1 Day Work Time';
            --32 Shift? ?? 9.5?? ??, ??? 8?? ?? ?? ? ????? ??
            --HMT_20220216 Start
            /*
            SELECT DECODE(SUBSTR(v_shift_type_code,1,1),'3',9.5,8) * COUNT(*)
                   ,COUNT(*)
            INTO   v_shift_time, v_working_days
            FROM   tb_att_base_bas_n bas
                  ,tb_att_code_c     acc
            WHERE  bas.time_and_attendance_yyyymm  = v_yyyymm
            AND    bas.shift_type_code             = v_shift_type_code
            AND    acc.time_and_attendance_code    = bas.time_and_attendance_code
            AND    ( acc.attendance_days > 0 OR acc.unpaid_days > 0 OR acc.paid_days > 0)
            AND    c_r.ymd                         = bas.time_and_attendance_date;
            */
            SELECT DECODE(SUBSTR(v_shift_type_code,1,1),'3',9.5,8) * COUNT(*)
                   ,COUNT(*)
            INTO   v_shift_time, v_working_days
            FROM   tb_att_result_n r
                  ,tb_att_base_bas_n bas
                  ,tb_att_code_c     acc
            WHERE  r.time_and_attendance_yyyymm = bas.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = bas.time_and_attendance_date
        AND    r.shift_type_code = bas.shift_type_code
        AND bas.time_and_attendance_yyyymm  = v_yyyymm
            AND    bas.shift_type_code             = v_shift_type_code
            AND    r.employee_no = p_employee_no
            AND    acc.time_and_attendance_code    = r.time_and_attendance_code
            AND    ( acc.attendance_days > 0 OR acc.unpaid_days > 0 OR acc.paid_days > 0)
            AND    c_r.ymd                         = bas.time_and_attendance_date; 
            --HMT_20220216 End
            ---HMT_20210323 Start
            IF v_shift_time = 8  THEN
              v_shift_time := lgvpay_info_pkg.get_work_hours('LGDVN', p_employee_no, c_r.ymd, '21', v_shift_type_code, 8, 'pay_perfect_hours');
            END IF;
            ---HMT_20210323 End
            v_shift_tot_time := v_shift_tot_time + v_shift_time;
            v_total_days     := v_total_days + v_working_days;

        END LOOP;

        IF v_shift_tot_time >= v_total_time THEN
            v_shift_period := 1;
            --g_add_ot_time  := v_shift_tot_time - v_total_time;
        ELSE
            v_shift_period := v_shift_tot_time / v_total_time;
        END IF;

        v_step := 'Calculation Payroll : 1 Day Calculation';
        --?? ?? ??(?? ??(????? / ?????) * ?? ??)
        BEGIN
            SELECT c.payment_base_amount * c.increase_and_decrease_rate * v_shift_period
            INTO   v_total_amount
            FROM   DUAL;
        EXCEPTION
            WHEN OTHERS THEN
                v_total_amount := 0;
        END;
        -->
        v_return := v_return + v_total_amount;          
        
        v_step := 'Calculation Payroll : Update perfect_attendance_days';
        UPDATE  tb_pay_detail_calc_t pdcc
        SET     pdcc.working_days = v_total_days
        WHERE   pdcc.payroll_calculation_exec_id = c.payroll_calculation_exec_id
        AND     pdcc.employee_no                 = c.employee_no
        AND     pdcc.payroll_item_id             = c.payroll_item_id
        AND     pdcc.basis_start_date            = c.basis_start_date
        ;

    END LOOP;


    dbms_output.put_line('p_payroll_item_id=.'||p_payroll_item_id||'end=.'|| to_char(SYSDATE,'yyyymmdd hh24:mi:ss'));
    RETURN nvl(round(v_return), 0);


EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculate_pay ; ' ||SQLERRM);
        v_err_buf := 'calculate_pay Error ; '||v_step||' : '|| substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );
        RETURN nvl(v_return, 0);
END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_base_pay                                     */
/* Description    :  Base salary ???? ????                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
PROCEDURE calculation_base_pay( p_employee_no                 IN VARCHAR2,
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 ) IS

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_subsidiary_code      VARCHAR2(100);
    v_err_buf              VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN
    v_procedure_name := 'calculation_base_pay';


    --1) ???? / ?? ?? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          ,period.subsidiary_code
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;

    /* ??? ????? ??? ??? ?? ?? , ??? ??? ?? ? ?? ????
       ??? ??? ???? ??? ??? row? ????. */
    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , lgvpay_info_pkg.get_base_pay(p_employee_no, to_char(ymd,'yyyymmdd'),v_subsidiary_code, 'A') base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;

    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );



    -- pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;


EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation position allowance error ; ' ||SQLERRM);
        v_err_buf := 'calcuation_base pay Error ; '|| substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_position_pay                                  */
/* Description    :  Position Pay ???? ????                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
PROCEDURE calculation_position_allw( p_employee_no                 IN VARCHAR2,
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 ) IS

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

    v_procedure_name := 'calculation_position_allw';
    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;


--Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;


    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , lgvpay_info_pkg.get_position_allowance(p_employee_no, to_char(ymd,'yyyymmdd')) base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;



    v_return := calculate_pay(p_employee_no => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id => p_payroll_item_id
                            ,p_period_id => p_period_id
                            ,p_run_type_name => p_run_type_name
                            ,p_user_id                  => p_user_id
                            );



    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation position allowance allwance error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation position allowance allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(position error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_qualification_allw                           */
/* Description    :  Qualification Allowance calcuation                       */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_qualification_allw( p_employee_no                 IN VARCHAR2,
                                          p_period_id                   IN NUMBER,
                                          p_payroll_calculation_exec_id IN NUMBER,
                                          p_payroll_item_id             IN NUMBER,
                                          p_run_type_name               IN VARCHAR2,
                                          p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_subsidiary_code      VARCHAR2(30);

    v_err_buf              VARCHAR(4000);


    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

    v_procedure_name := 'calculation_qualification_allw';


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          ,em.subsidiary_code
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;



    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , lgvpay_info_pkg.get_qualification_allowance(p_employee_no, to_char(ymd,'yyyymmdd'),v_subsidiary_code) base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;


    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );



    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;



EXCEPTION
    WHEN OTHERS THEN
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation qualification allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(qaulification error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);


END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_job_allw                                     */
/* Description    :  Job Allowance calculation                                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_job_allw( p_employee_no                 IN VARCHAR2,
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN

    v_procedure_name := 'calculation_job_allw';


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;



    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , lgvpay_info_pkg.get_job_allowance(p_employee_no, to_char(ymd,'yyyymmdd')) base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;


    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );



    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation position allowance allwance error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation position allowance allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(position error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_hardship_allw                                     */
/* Description    :  Hardship Allowance calculation                                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2024/08/21    NguyenVanSang       Initial Release                          */
/******************************************************************************/
PROCEDURE calculation_hardship_allw ( p_employee_no                 IN VARCHAR2,
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2)

IS

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_input_value_id       NUMBER;
    v_employee_number      tb_att_result_n.employee_no%TYPE := '';
    v_deduction_amount     NUMBER;
    v_perfect_work_hours   NUMBER;
    v_perfect_work_days    NUMBER;
    v_attendance_yyyymm    tb_att_result_n.time_and_attendance_yyyymm%TYPE := '';
    v_shift_period         NUMBER;
    v_total_amount         NUMBER := 0; --Total amount of return
    v_result_value         NUMBER := 0;

    v_subsidiary_code      VARCHAR2(100);
    v_err_buf              VARCHAR2(4000);
    v_actual_hours         NUMBER;
    v_cnt                  NUMBER := 0;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

      v_procedure_name := 'calculation_hardship_allowance';
      v_pay_step := 'start';
      
      --CHECK KISE Employee
      SELECT count(*)
      INTO v_cnt
      FROM emp_info ei, emp_master em
      WHERE ei.employee_number = em.employee_number
      AND em.flsa_yn = 'N'
      AND ei.nationality = 'XXHR_KR'
      AND ei.employee_number = p_employee_no
      ;
      
      IF v_cnt <= 0 THEN
         RETURN ;
      END IF;
      --why need duplicate code? not clear code!
      SELECT ei.employee_number
      INTO v_employee_number
      FROM emp_info ei, emp_master em
      WHERE ei.employee_number = em.employee_number
      AND em.flsa_yn = 'N'
      AND ei.nationality = 'XXHR_KR'
      AND ei.employee_number = p_employee_no
      ;
      
      SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          ,period.subsidiary_code
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;
    
    v_pay_step := 'Get perfect work hours';
    SELECT 
           r.employee_no
          ,r.time_and_attendance_yyyymm
          ,SUM(
                   lgvpay_info_pkg.get_work_hours(
                                               'LGDVN'
                                               ,r.employee_no
                                               ,b.time_and_attendance_date
                                               ,DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW')
                                               ,b.shift_type_code
                                               ,b.work_hours
                                               ,'pay_perfect_hours'
                   )
           ) as perfect_work_hours
    INTO  v_employee_number
         ,v_attendance_yyyymm
         ,v_perfect_work_hours
    FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
    WHERE r.time_and_attendance_code = c.time_and_attendance_code
    AND r.shift_type_code = b.shift_type_code
    AND r.time_and_attendance_date = b.time_and_attendance_date
    AND r.time_and_attendance_yyyymm = to_char(to_date(v_start_yyyymmdd,'YYYYMMDD'),'YYYYMM')
    AND em.employee_number = r.employee_no
    AND employee_no = p_employee_no
    GROUP BY r.employee_no, r.time_and_attendance_yyyymm
    ;

    v_pay_step := 'Caculator price for per grade';
    for grade_value in(
      SELECT ymd start_date
                , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) end_date
                , base_value
          FROM (
                 SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                 FROM (
                         SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                         FROM (
                                 SELECT  ymd
                                       , lgvpay_info_pkg.get_hardship_allowance(p_employee_no, to_char(ymd,'yyyymmdd')) base_value
                                 FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                         FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                       ,  emp_assig          ass
                                 WHERE ass.employee_number= p_employee_no
                                 AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                               )
                       )
                 )
           WHERE  diff = 2
           )
    LOOP
      -- get actual hours
           SELECT
                SUM(
                    CASE 
                        WHEN (c.paid_days > 0 OR c.attendance_days > 0) THEN
                            lgvpay_info_pkg.get_work_hours(
                                             'LGDVN'
                                             ,r.employee_no
                                             ,b.time_and_attendance_date
                                             ,DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW')
                                             ,b.shift_type_code
                                             ,b.work_hours
                                             ,'pay_perfect_hours'
                            )
                      END
                ) AS actual_hours,
                SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days
           INTO v_actual_hours
                ,v_perfect_work_days
           FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
          WHERE r.time_and_attendance_code = c.time_and_attendance_code
            AND r.shift_type_code = b.shift_type_code
            AND r.time_and_attendance_date = b.time_and_attendance_date
            AND r.time_and_attendance_date between grade_value.start_date and grade_value.end_date
            AND r.time_and_attendance_yyyymm = to_char(to_date(v_start_yyyymmdd,'YYYYMMDD'),'YYYYMM')
            AND em.employee_number = r.employee_no
            AND employee_no = p_employee_no
          GROUP BY r.employee_no, r.time_and_attendance_yyyymm
          ;
          
      -- insert item value
      INSERT INTO tb_pay_detail_calc_t a
              (payroll_calculation_exec_id
              ,employee_no
              ,payroll_item_id
              ,basis_start_date
              ,basis_end_date
              ,payment_base_amount
              ,ordinary_wages_base_amount
              ,increase_and_decrease_rate
              ,working_days
              ,creation_date
              ,creation_user_id
              )
      SELECT p_payroll_calculation_exec_id
            , p_employee_no
            ,p_payroll_item_id
            ,grade_value.start_date
            ,grade_value.end_date
            ,grade_value.base_value
            ,grade_value.base_value
            ,1
            ,v_perfect_work_days
            ,SYSDATE
            ,p_user_id 
      FROM dual;
        
      IF v_actual_hours >= v_perfect_work_hours THEN
          v_shift_period := 1;
      ELSE
          v_shift_period := v_actual_hours / v_perfect_work_hours;
      END IF;
    
      BEGIN
          SELECT v_shift_period * grade_value.base_value
          INTO   v_total_amount
          FROM   DUAL;
      EXCEPTION
          WHEN OTHERS THEN
              v_total_amount := 0;
      END;
        
      v_result_value := v_result_value + v_total_amount;  
            
    END LOOP;
    v_result_value := nvl(round(v_result_value), 0);
                            
    
    SELECT lgvpay_common_pkg.get_hardship_deduction_amount( p_employee_no, p_payroll_calculation_exec_id ,p_payroll_item_id, p_period_id)
    INTO   v_deduction_amount
    FROM   dual;
    
    IF v_deduction_amount > 0 THEN
      v_result_value := v_result_value - v_deduction_amount;
    END IF;



    -- pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_result_value,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;
EXCEPTION
    WHEN OTHERS THEN
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        v_step :=v_step||chr(13)|| 'User Exception Error()';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_job_allw                                     */
/* Description    :  Job Allowance calculation                                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    Kim Biho       Initial Release                               */
/******************************************************************************/
PROCEDURE calculation_encour_allw ( p_employee_no                 IN VARCHAR2,
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2)

IS

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_total_amount         NUMBER := 0; --Total amount of return
    v_shift_period         NUMBER;
    
    v_err_buf              VARCHAR(4000);
    
    v_cnt                  NUMBER;
    v_amont_cnt            NUMBER;
    v_allow_amount         NUMBER;
    v_perfect_work_hours   NUMBER;
    v_actual_hours         NUMBER;
    v_actual_hours_cnt     NUMBER;
    v_result_value         NUMBER := 0;
    v_cell_value           tb_pay_user_dfin_table_value_n.table_cell_value%TYPE := '';
    v_employee_no          tb_att_result_n.employee_no%TYPE := '';
    v_attendance_yyyymm    tb_att_result_n.time_and_attendance_yyyymm%TYPE := '';
    
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := 'calculation encour allw';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

      v_procedure_name := 'calculation_encouragement_incentive';
      v_pay_step := 'start';      
      
      --start and end date get      
      SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
            --,period.end_yyyymmdd
            ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                  THEN to_char(em.date_retire,'yyyymmdd')
                  ELSE period.end_yyyymmdd
             END
      INTO   v_start_yyyymmdd
            ,v_end_yyyymmdd
      FROM   tb_pay_calc_period_basis_n period
            ,emp_master em
            ,emp_assig  ass
      WHERE  period.payroll_calculation_period_id = p_period_id
      AND    em.employee_number                   = p_employee_no
      AND    ass.employee_number                  = em.employee_number
      AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
      ;
      
      --SangNV: Check whether there is a planned item in this period, if exists, don't calculate.
      IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
          RETURN ;
      END IF;
      
      v_pay_step := 'Get perfect work hours';
      SELECT 
             r.employee_no
            ,r.time_and_attendance_yyyymm
            ,SUM(
                     lgvpay_info_pkg.get_work_hours(
                                                 'LGDVN'
                                                 ,r.employee_no
                                                 ,b.time_and_attendance_date
                                                 ,DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW')
                                                 ,b.shift_type_code
                                                 ,b.work_hours
                                                 ,'pay_perfect_hours'
                     )
             ) as perfect_work_hours
      INTO  v_employee_no
           ,v_attendance_yyyymm
           ,v_perfect_work_hours
      FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
      WHERE r.time_and_attendance_code = c.time_and_attendance_code
      AND r.shift_type_code = b.shift_type_code
      AND r.time_and_attendance_date = b.time_and_attendance_date
      AND r.time_and_attendance_yyyymm = to_char(to_date(v_start_yyyymmdd,'YYYYMMDD'),'YYYYMM')
      AND em.employee_number = r.employee_no
      AND employee_no = p_employee_no
      GROUP BY r.employee_no, r.time_and_attendance_yyyymm
      ;
      
      v_pay_step := 'Caculator price for per grade';
      for grade_value in(
        SELECT ymd start_date
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) end_date
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , lgvpay_info_pkg.get_encour_allowance(p_employee_no, to_char(ymd,'yyyymmdd')) base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
             )
      LOOP
        -- get actual hours
             SELECT
                  SUM(
                      CASE 
                          WHEN ((c.paid_days > 0 OR c.attendance_days > 0) AND b.shift_type_code like '%102%') THEN
                              lgvpay_info_pkg.get_work_hours(
                                               'LGDVN'
                                               ,r.employee_no
                                               ,b.time_and_attendance_date
                                               ,DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW')
                                               ,b.shift_type_code
                                               ,b.work_hours
                                               ,'pay_perfect_hours'
                              )
                        END
                  ) AS actual_hours
             INTO v_actual_hours
             FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
            WHERE r.time_and_attendance_code = c.time_and_attendance_code
              AND r.shift_type_code = b.shift_type_code
              AND r.time_and_attendance_date = b.time_and_attendance_date
              AND r.time_and_attendance_date between grade_value.start_date and grade_value.end_date
              AND r.time_and_attendance_yyyymm = to_char(to_date(v_start_yyyymmdd,'YYYYMMDD'),'YYYYMM')
              AND em.employee_number = r.employee_no
              AND employee_no = p_employee_no
            GROUP BY r.employee_no, r.time_and_attendance_yyyymm
            ;
        
        IF v_actual_hours >= v_perfect_work_hours THEN
            v_shift_period := 1;
        ELSE
            v_shift_period := v_actual_hours / v_perfect_work_hours;
        END IF;
    
        BEGIN
            SELECT v_shift_period * grade_value.base_value
            INTO   v_total_amount
            FROM   DUAL;
        EXCEPTION
            WHEN OTHERS THEN
                v_total_amount := 0;
        END;
        
        v_result_value := v_result_value + v_total_amount;  
            
      END LOOP;
      v_result_value := nvl(round(v_result_value), 0);
      
      
      SELECT a.payroll_item_detail_detail_id
      INTO   v_input_value_id
      FROM   tb_pay_item_detail_n a
      WHERE  a.payroll_item_id        = p_payroll_item_id
      AND    a.additional_input_value = 'PAY_VALUE'
      ;
      
      create_result(     p_payroll_calculation_exec_id   => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                  => v_result_value,
                         p_user_id                       => p_user_id,
                         p_period_id                     => p_period_id)
      ;
      -- finish
EXCEPTION
    WHEN OTHERS THEN
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        v_step :=v_step||chr(13)|| 'User Exception Error()';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2024                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_housing_Allowance                            */
/* Description    :  House Allowance calculation                              */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2024/08/05    Kim Biho       Initial Release                               */
/******************************************************************************/
PROCEDURE calculation_housing_allw (p_employee_no                 IN VARCHAR2,
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2)

IS
      v_start_yyyymmdd       VARCHAR(10); 
      v_end_yyyymmdd         VARCHAR(10); 
      v_pay_step             VARCHAR(30); 
      v_err_buf              VARCHAR(4000);
      v_subsidiary_code      VARCHAR2(100);
      v_employee_number      emp_info.employee_number%TYPE:=NULL;
      v_marriage             emp_info.marriage%TYPE:=NULL;
      v_work_start_date      VARCHAR(10);
      v_work_end_date        VARCHAR(10);
      v_basis_date           VARCHAR(10);
      v_pay_month_first_day  VARCHAR(10);
      v_pay_month_last_day   VARCHAR(10);
      v_pay_plan_id          tb_pay_item_payment_plan_n.payroll_item_payment_plan_id%TYPE:=null;
      v_amount               tb_pay_payment_plan_detail_n.apply_target_value%TYPE:=null;
      v_amount_sum           tb_pay_payment_plan_detail_n.apply_target_value%TYPE:=0;
      v_base_amount          tb_pay_payment_plan_detail_n.apply_target_value%TYPE:=null;
      v_amount_by_day        tb_pay_payment_plan_detail_n.apply_target_value%TYPE:=null;
      v_month_of_day_count   NUMBER;
      v_count_day            NUMBER;
      v_input_value_id       NUMBER;
      v_rate_value           NUMBER;
      v_cnt_base_amount      NUMBER;
      v_cnt                  NUMBER := 0;
      
      v_apply_start_date     tb_pay_item_payment_plan_n.apply_start_date%TYPE:=null;
      v_apply_end_date       tb_pay_item_payment_plan_n.apply_end_date%TYPE:=null;
      
      v_retroactive_flag     tb_pay_calc_exec_n.retroactive_flag%TYPE := NULL;
      
      v_step                 lgcom_error_log.error_explanation_text%TYPE:=NULL;
      v_module_code          CONSTANT lgcom_error_log.module_code%TYPE:='LGVPAY';
      v_procedure_name       lgcom_error_log.program_id%TYPE:= NULL;

BEGIN
      v_procedure_name := 'calculation_housing_allow_incentive';
      v_pay_step := 'start check employee KSE';
      
      --if not KSE return;
      select count(*)
        into v_cnt
        from emp_info ei, emp_master em
       where ei.employee_number = em.employee_number
         and em.status in ('Active Assignment','Terminate Assignment','Suspend Assignment')
         and em.flsa_yn = 'N'
         and ei.nationality = 'XXHR_KR'
         and ei.employee_number = p_employee_no
      ;
      
      IF v_cnt <= 0 then
         RETURN;
      END IF;
      
      --if not KSE return;
      select ei.employee_number, ei.marriage
        into v_employee_number, v_marriage
        from emp_info ei, emp_master em
       where ei.employee_number = em.employee_number
         and em.status in ('Active Assignment','Terminate Assignment','Suspend Assignment')
         and em.flsa_yn = 'N'
         and ei.nationality = 'XXHR_KR'
         and ei.employee_number = p_employee_no
      ;
      
      v_pay_step := 'start date and end date get';
      
      --start and end date get      
      SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
            --,period.end_yyyymmdd
            ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                  THEN to_char(em.date_retire,'yyyymmdd')
                  ELSE period.end_yyyymmdd
             END
            ,period.subsidiary_code
      INTO   v_start_yyyymmdd
            ,v_end_yyyymmdd
            ,v_subsidiary_code
      FROM   tb_pay_calc_period_basis_n period
            ,emp_master em
            ,emp_assig  ass
      WHERE  period.payroll_calculation_period_id = p_period_id
        AND    em.employee_number                   = p_employee_no
        AND    ass.employee_number                  = em.employee_number
        AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
      ;
      
      IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
          RETURN;
      END IF;
      
      --Date of employment  of retirement : we need find first day, and last day calculation
      select to_char(DATE_HIRE_SUBSIDIARY,'YYYYMMDD'), NVL(to_char(DATE_RETIRE,'YYYYMMDD'),0)
        into v_work_start_date, v_work_end_date
        from emp_master
       where EMPLOYEE_NUMBER = p_employee_no
      ;
      
      --tax rate
      SELECT result_value
        INTO v_rate_value
        FROM tb_pay_calc_var_n a
            ,tb_pay_calc_var_value_n b
       WHERE a.Payroll_Calc_Variable_Id = b.Payroll_Calc_Variable_Id
         AND v_end_yyyymmdd between b.effective_start_yyyymmdd and b.effective_end_yyyymmdd
         AND a.PAYROLL_CALC_VARIABLE_NAME = 'HOUSING_ALLW_RATE'
      ;
      
      --base Amount check
      --v_base_amount := lgvpay_common_pkg.get_planned_item_value(p_employee_no, to_date(v_end_yyyymmdd,'YYYYMMDD'), 'HOUSING_ALLW' ,'BASE_AMOUNT',v_subsidiary_code);
      SELECT   
               count(ppdn.apply_target_value) as cnt
        INTO   v_cnt_base_amount
        FROM   tb_pay_item_payment_plan_n ipp
              ,tb_pay_payment_plan_detail_n ppdn
              ,tb_pay_item_detail_n pid
              ,tb_pay_payroll_item_m ppi
      WHERE    ppi.payroll_item_name              = 'HOUSING_ALLW' --HARDSHIP_ALLW
        AND    ppi.subsidiary_code                = 'LGDVN'
        AND    v_end_yyyymmdd   BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231')
        AND    ipp.employee_no                    = p_employee_no
        AND    SUBSTR(v_end_yyyymmdd,0,6)  BETWEEN to_char(ipp.apply_start_date,'YYYYMM') AND to_char(ipp.apply_end_date,'YYYYMM')
        AND    ipp.payroll_item_id                = ppi.payroll_item_id
        AND    ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
        AND    ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id
        AND    pid.additional_input_value         = 'BASE_AMOUNT'
      ;
      
      v_amount := 0;
      
      IF (v_cnt_base_amount > 0) THEN
        --base amount have data need calculation // apply_start_date to apply_end_date
        --(base_amount / full month day) * (apply_end_date - apply_start_date)
        --v_amount := v_base_amount;
        for ba in(
            SELECT   
                     nvl(ppdn.apply_target_value,0) as apply_target_value
                    ,ipp.apply_start_date
                    ,ipp.apply_end_date
                    ,(LAST_DAY(ipp.apply_start_date)-ipp.apply_start_date)+1 as month_day_cnt
              FROM   tb_pay_item_payment_plan_n ipp
                    ,tb_pay_payment_plan_detail_n ppdn
                    ,tb_pay_item_detail_n pid
                    ,tb_pay_payroll_item_m ppi
             WHERE   ppi.payroll_item_name              = 'HOUSING_ALLW'
               AND   ppi.subsidiary_code                = 'LGDVN'
               AND   v_end_yyyymmdd   BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231')
               AND   ipp.employee_no                    = p_employee_no
               AND   SUBSTR(v_end_yyyymmdd,0,6)  BETWEEN to_char(ipp.apply_start_date,'YYYYMM') AND to_char(ipp.apply_end_date,'YYYYMM')
               AND   ipp.payroll_item_id                = ppi.payroll_item_id
               AND   ppdn.payroll_item_payment_plan_id  = ipp.payroll_item_payment_plan_id
               AND   ppdn.payroll_item_detail_detail_id = pid.payroll_item_detail_detail_id
               AND   pid.additional_input_value         = 'BASE_AMOUNT'
        )
        LOOP
            --init amount by day
            v_amount_by_day :=0;
            
            select NVL(retroactive_flag,'N')
              into v_retroactive_flag
              from TB_PAY_CALC_EXEC_N
             where PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
            ;
            
            IF v_retroactive_flag = 'Y' THEN
              select  to_char(to_date(RETROACTIVE_PAY_START_YYYYMM||'01','YYYYMMDD'),'YYYYMMDD')
                     ,to_char(TRUNC(to_date(RETROACTIVE_PAY_START_YYYYMM||'01','YYYYMMDD'),'MM'),'YYYYMMDD')
                     ,to_char(LAST_DAY(to_date(RETROACTIVE_PAY_START_YYYYMM||'01','YYYYMMDD')),'YYYYMMDD')
                     ,EXTRACT(day FROM LAST_DAY(to_date(RETROACTIVE_PAY_START_YYYYMM||'01','YYYYMMDD')))
                into  v_basis_date
                     ,v_pay_month_first_day
                     ,v_pay_month_last_day
                     ,v_month_of_day_count
                from  TB_PAY_CALC_EXEC_N 
               where  PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
              ;
            ELSE
              select  to_char(BASIS_DATE,'YYYYMMDD')
                     ,to_char(TRUNC(BASIS_DATE,'MM'),'YYYYMMDD')
                     ,to_char(LAST_DAY(BASIS_DATE),'YYYYMMDD')
                     ,EXTRACT(DAY FROM LAST_DAY(BASIS_DATE))
                into  v_basis_date
                     ,v_pay_month_first_day
                     ,v_pay_month_last_day
                     ,v_month_of_day_count
                from  TB_PAY_CALC_EXEC_N 
               where  PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
              ;
            END IF;
            
            IF v_pay_month_first_day < to_char(ba.apply_start_date,'YYYYMMDD') THEN 
              v_pay_month_first_day := to_char(ba.apply_start_date,'YYYYMMDD'); 
            END IF;
            
            --??? ??? ?? ?? ?? ?? Exec_n Data? ?? ??? end date ?? ??? end date ??
            IF to_char(ba.apply_end_date,'YYYYMMDD') < v_pay_month_last_day THEN 
              v_pay_month_last_day := to_char(ba.apply_end_date,'YYYYMMDD'); 
            END IF;
            
            --init count day
            v_count_day := 0;
            
            select (to_date(v_pay_month_last_day,'YYYYMMDD')-to_date(v_pay_month_first_day,'YYYYMMDD'))+1
            into v_count_day
            from dual
            ;
            
            v_amount_by_day := ROUND(ba.apply_target_value / v_month_of_day_count,2);
            v_amount_sum := ROUND(v_amount_by_day * v_count_day,0);

            --calc result insert
            INSERT INTO tb_pay_detail_calc_t a
                (
                   payroll_calculation_exec_id
                  ,employee_no
                  ,payroll_item_id
                  ,basis_start_date
                  ,basis_end_date
                  ,payment_base_amount
                  ,ordinary_wages_base_amount
                  ,working_days
                  ,increase_and_decrease_rate
                  ,creation_date
                  ,creation_user_id
                )
            SELECT p_payroll_calculation_exec_id
                  ,p_employee_no
                  ,p_payroll_item_id
                  ,to_date(v_pay_month_first_day,'YYYYMMDD')
                  ,to_date(v_pay_month_last_day,'YYYYMMDD')
                  ,ba.apply_target_value
                  ,ba.apply_target_value
                  ,v_count_day
                  ,v_rate_value
                  ,SYSDATE
                  ,p_user_id
            FROM  dual;
            
            v_amount := v_amount + v_amount_sum;
            
        END LOOP;
        
        select PAYROLL_ITEM_DETAIL_DETAIL_ID
          into v_input_value_id
          from tb_pay_item_detail_n
         where PAYROLL_ITEM_ID = (select PAYROLL_ITEM_ID 
                                   from tb_pay_payroll_item_m
                                  where PAYROLL_ITEM_NAME = 'HOUSING_ALLW')
           and ADDITIONAL_INPUT_VALUE = 'PAY_VALUE'
        ;
        
      ELSE
        --basic amount setting
        SELECT   udtv.table_cell_value
          INTO   v_base_amount
          FROM   tb_pay_user_dfin_table_m udt
               , tb_pay_user_dfin_table_col_n udtc
               , tb_pay_user_dfin_table_row_n udtr
               , tb_pay_user_dfin_table_value_n udtv
          WHERE  udt.table_name            =  'HOUSING_ALLOWANCE'
          AND    udtc.table_seq_no         = udt.table_seq_no
          AND    udtc.user_column_name     = 'HOUSING_ALLOWANCE'
          AND    udtr.table_seq_no         = udt.table_seq_no
          AND    v_start_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
          AND    udtv.column_seq_no        = udtc.column_seq_no
          AND    udtv.row_no               = udtr.row_no
          AND    v_start_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
          AND    udtr.lower_limit_critical_value = v_marriage
        ;
        
        v_amount := v_base_amount;
        
        --v_pay_step := 'work start day, work end day check';
        select to_char(BASIS_DATE,'YYYYMMDD')
               ,to_char(TRUNC(BASIS_DATE,'MM'),'YYYYMMDD')
               ,to_char(LAST_DAY(BASIS_DATE),'YYYYMMDD')
               ,EXTRACT(DAY FROM LAST_DAY(BASIS_DATE))
          into  v_basis_date
               ,v_pay_month_first_day
               ,v_pay_month_last_day
               ,v_month_of_day_count
          from TB_PAY_CALC_EXEC_N 
         where PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
        ;
        
        --count day check and input
        v_count_day := v_month_of_day_count;
        
        --day by amount
        v_amount_by_day := v_base_amount / v_month_of_day_count; --day amount value
        
        --Calculation of new hires and retire employees
        --single 15,000,000 vnd / ?? , marriage 20,000,000 vnd / ??
        IF SUBSTR(v_work_start_date,1,6) = SUBSTR(v_basis_date,1,6) THEN
          --amount start to End of month
          select (to_date(v_pay_month_last_day,'YYYYMMDD')-to_date(v_work_start_date,'YYYYMMDD'))+1
            into v_count_day
            from dual
            ;
            
            --work start date change
            v_start_yyyymmdd := v_work_start_date;
            
            v_amount := ROUND(v_amount_by_day * v_count_day,0);
          
        ELSIF v_work_end_date <> '0' and SUBSTR(v_work_end_date,1,6) = SUBSTR(v_basis_date,1,6) THEN
          --amount start of month to end
            select (to_date(v_work_end_date,'YYYYMMDD')-to_date(v_pay_month_first_day,'YYYYMMDD'))+1
            into v_count_day
            from dual
            ;
            
            v_amount := ROUND(v_amount_by_day * v_count_day,0);
            
        END IF;
        
        --calc result insert
        INSERT INTO tb_pay_detail_calc_t a
            (
               payroll_calculation_exec_id
              ,employee_no
              ,payroll_item_id
              ,basis_start_date
              ,basis_end_date
              ,payment_base_amount
              ,ordinary_wages_base_amount
              ,working_days
              ,increase_and_decrease_rate
              ,creation_date
              ,creation_user_id
            )
        SELECT p_payroll_calculation_exec_id
              ,p_employee_no
              ,p_payroll_item_id
              ,to_date(v_start_yyyymmdd,'YYYYMMDD')
              ,CASE
                  WHEN v_work_end_date = '0' THEN to_date(v_end_yyyymmdd,'YYYYMMDD')
                  ELSE to_date(v_work_end_date,'YYYYMMDD')
               END
              ,v_base_amount
              ,v_base_amount
              ,v_count_day
              ,v_rate_value
              ,SYSDATE
              ,p_user_id
        FROM  dual;
        
        --v_pay_step := 'calc result insert';
        select PAYROLL_ITEM_DETAIL_DETAIL_ID
          into v_input_value_id
          from tb_pay_item_detail_n
         where PAYROLL_ITEM_ID = (select PAYROLL_ITEM_ID 
                                   from tb_pay_payroll_item_m
                                  where PAYROLL_ITEM_NAME = 'HOUSING_ALLW')
           and ADDITIONAL_INPUT_VALUE = 'PAY_VALUE'
        ;
      END IF;      

      v_pay_step := 'last';
      
      create_result(     p_payroll_calculation_exec_id   => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                  => v_amount,
                         p_user_id                       => p_user_id,
                         p_period_id                     => p_period_id)
      ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
       v_step :=v_pay_step||chr(13)|| 'User Exception Error()';
       lgcom_error_log_pkg.set_comment_text(v_step);
       lgcom_error_log_pkg.set_error_code(NULL);
       lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
       lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
    WHEN OTHERS THEN
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        v_step :=v_pay_step||chr(13)|| 'User Exception Error()';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);
                
END;

-- KHJ Start

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_std_ot                                       */
/* Description    :  Standard OT Calculate procedure                          */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 150OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2018/10/28    KwonHJ   3shift? ?? ?? ???? ???? ?? OT??    */
/* 2019/03/01    TaiDD-20190301    Add the nontax_amount    */
/******************************************************************************/
PROCEDURE calculation_std_ot( p_employee_no                 IN VARCHAR2,
                              p_period_id                   IN NUMBER,
                              p_payroll_calculation_exec_id IN NUMBER,
                              p_payroll_item_id             IN NUMBER,
                              p_run_type_name               IN VARCHAR2,
                              p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;


    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_std_ot( p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        /*----TaiDD-20190301-Start-----*/
                        --p_ot_count                    => v_out_param_rec(1)) ;
                        p_nontax_amount                 => v_out_param_rec(1),                 
                        p_ot_count                    => v_out_param_rec(2)) ;
                        /*----TaiDD-20190301-End-----*/

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id   => p_payroll_calculation_exec_id,
                       p_employee_no                   => p_employee_no,
                       p_payroll_item_id               => c.payroll_item_id,
                       p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                       p_rslt_detail_type_code         => v_result_code,
                       p_result_value                  => v_result,
                       p_user_id                       => p_user_id,
                       p_period_id                     => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_std_ot                                       */
/* Description    :  Standard OT Calculate procedure                          */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 150OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2018/10/28    KwonHJ   3shift? ?? ?? ???? ???? ?? OT??    */
/* 2019/03/01    TaiDD-20190301    Add the nontax_amount    */
/* 2019/07/28    TaiDD-20190728    Add the condition that employee must have at least 1 working/paid day in 32% and have total working time > 192(known as basic working hours)
/* 2022/02/15    HMT_20220215     Update total working time = 9.5 or working time = 0.             */
/* 2022/02/17    TaiDD-20220217   Add the Tax Rate
/******************************************************************************/
PROCEDURE calculation_std_ot( p_employee_no                 IN VARCHAR2,
                              p_period_id                   IN NUMBER,
                              p_payroll_calculation_exec_id IN NUMBER,
                              p_payroll_item_id             IN NUMBER,
                              p_run_type_name               IN VARCHAR2,
                              p_user_id                     IN VARCHAR2,
                              p_tax_amount                  OUT NUMBER,
                              p_nontax_amount               OUT NUMBER,  --TaiDD-20190301--
                              p_ot_count                    OUT NUMBER ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tax_rate               NUMBER := 0; --TaiDD-20220217
    
    v_pft_att_days           NUMBER := 0;
    v_pft_att_hours          NUMBER := 0;
    v_32_att_days            NUMBER := 0;
    
    v_work_hours             NUMBER := 0;
    v_ded_hours              NUMBER := 0;
    
    v_ot_hours               NUMBER := 0;
    v_ot_amount              NUMBER := 0;
    
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    -- ??? ??
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id;
    
    /*--------TaiDD-20190728-Start-------*/
    --This Allownace is only for employee who have at least 1 working/pad day assigned Shift Code Type of 32%  
    SELECT NVL(COUNT(*),0)
           INTO v_32_att_days
    FROM tb_att_result_n ar, tb_att_code_c cc
         WHERE ar.time_and_attendance_code = cc.time_and_attendance_code
         AND     (cc.paid_days > 0 OR cc.attendance_days > 0)
         AND     ar.subsidiary_code             = v_subsidiary_code               
         AND     ar.time_and_attendance_yyyymm  = v_yyyymm
         AND     ar.employee_no                 = p_employee_no
         AND     (ar.SHIFT_TYPE_CODE LIKE '32%' OR ar.SHIFT_TYPE_CODE LIKE '102%')-- sangnv - 20230816
         ;

    IF v_32_att_days < 1 THEN
         RETURN;
    END IF;   
    /*--------TaiDD-20190728-End-------*/
    
    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT150_RATE',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'STD_OT_TAX_RATE',v_end_yyyymmdd)) --TaiDD-20220217
    INTO   v_basis_working_hours
          ,v_rate
          ,v_tax_rate --TaiDD-20220217
    FROM   dual;
    
    -- ??? ?? ????
    BEGIN
        SELECT acn.perfect_attendance_days
              ,acn.perfect_attendance_days * 8
        INTO   v_pft_att_days
              ,v_pft_att_hours
        FROM   tb_att_close_n acn
        WHERE  acn.subsidiary_code                   = v_subsidiary_code
        AND    acn.time_and_attendance_yyyymm        = v_yyyymm;
    EXCEPTION
      WHEN OTHERS THEN
        v_pft_att_days  := 0;
        v_pft_att_hours := 0;
    END;
    
    -- ??? ????
    BEGIN
      /*------TaiDD-----Start----
        SELECT SUM(r.work_hours)
        INTO   v_work_hours
        FROM   tb_att_result_n r
        WHERE  r.subsidiary_code             = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm  = v_yyyymm
        AND    r.employee_no                 = p_employee_no;
        ------------------------*/
        SELECT 
               SUM( CASE
                          WHEN (c.paid_days > 0 OR c.attendance_days > 0) 
                            THEN lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours') -- b.work_hours  HMT_20220215 update
                          WHEN r.time_and_attendance_code = 'WH' THEN 0 --  HMT_20220215 add
                          ELSE r.work_hours
                          END
                      )
        INTO   v_work_hours
        FROM   tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b
        WHERE  r.time_and_attendance_code = c.time_and_attendance_code
        AND    r.shift_type_code = b.shift_type_code
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.subsidiary_code             = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm  = v_yyyymm
        AND    r.employee_no                 = p_employee_no;
    EXCEPTION
      WHEN OTHERS THEN
        v_work_hours  := 0;
    END;

    -- ??/??/?? ??
    BEGIN
        SELECT nvl(SUM(nvl(r.tardy_hours,0)) + SUM(nvl(r.going_out_hours,0)) + SUM(nvl(r.early_leave_hours,0)),0)
        INTO   v_ded_hours
        FROM   tb_att_result_n r
        WHERE  r.subsidiary_code             = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm  = v_yyyymm
        AND    r.employee_no                 = p_employee_no;
    EXCEPTION
      WHEN OTHERS THEN
        v_ded_hours  := 0;
    END;
    
    -- ???? OT ??
    /*--------TaiDD-20190728-Start-------*/
    --v_ot_hours := nvl(v_work_hours,0) - nvl(v_pft_att_hours,0) - nvl(v_ded_hours,0);
    
    --Change the formula, if employee have working hours > 192 (known as basic working hours) + deduction hours AND have at least 1 day paid or attendance as 32% Shift Code
    --> Then pay the extra as Over Extra Standard Hours    
    
    v_ot_hours := nvl(v_work_hours,0) - nvl(v_basis_working_hours,0) - nvl(v_ded_hours,0);
    /*--------TaiDD-20190728-End-------*/
    
    IF v_ot_hours > 0 THEN

      SELECT nvl(round(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                           ,p_employee_no
                                                           ,v_end_yyyymmdd
                                                            ) * v_ot_hours * v_rate/ v_basis_working_hours

                ),0)
        INTO   v_ot_amount
        FROM   DUAL;
    ELSE
        v_ot_hours  := 0;
        v_ot_amount := 0;
    END IF;

    /*--------TaiDD-20190301-Start-------*/
    --p_tax_amount       := nvl(round(v_ot_amount,0),0);
    --p_tax_amount       := ROUND(round(v_ot_amount,0)*(1/v_rate),0);
    p_tax_amount       := ROUND(round(v_ot_amount,0)*(1/v_tax_rate),0);--TaiDD-20220217
    p_nontax_amount    := v_ot_amount -nvl(p_tax_amount,0);
    /*--------TaiDD-20190301-End--------*/
    p_ot_count         := nvl(v_ot_hours,0);

EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_std_ot => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;---TaiDD-20190301
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;

-- KHJ Finish

PROCEDURE calculation_150ot( p_employee_no                 IN VARCHAR2,
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;


    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_150ot( p_employee_no                          => p_employee_no,
                                p_period_id                   => p_period_id,
                                p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                p_payroll_item_id             => p_payroll_item_id,
                                p_run_type_name               => p_run_type_name,
                                p_user_id                     => p_user_id,
                                p_tax_amount                  => v_out_param_rec(0),
                                p_nontax_amount               => v_out_param_rec(1),
                                p_ot_count                    => v_out_param_rec(2),
                                p_hc_count                    => v_out_param_rec(3),
                                p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                                p_hc_300h_count               => v_out_param_rec(5),
                                p_300h_tax_amount             => v_out_param_rec(6)) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_150ot                                        */
/* Description    :  150% OT Calculate procedure                              */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 150OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2018/10/30    KimTaehyun      32 Shift? ?? ????? ??? ??       */
/******************************************************************************/
PROCEDURE calculation_150ot( p_employee_no                 IN VARCHAR2,
                                p_period_id                   IN NUMBER,
                                p_payroll_calculation_exec_id IN NUMBER,
                                p_payroll_item_id             IN NUMBER,
                                p_run_type_name               IN VARCHAR2,
                                p_user_id                     IN VARCHAR2,
                                p_tax_amount                  OUT NUMBER,
                                p_nontax_amount               OUT NUMBER,
                                p_ot_count                    OUT NUMBER,
                                p_hc_count                    OUT NUMBER,
                                p_ot_300h_count               OUT NUMBER, --HMT_20210420
                                p_hc_300h_count               OUT NUMBER,
                                p_300h_tax_amount             OUT NUMBER  ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_add_tot_ot_amount      NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_add_ot_hours           NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                 VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT150_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 150 ot := Ordiary wage/192 * 150 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.weekday_overtime_hours * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_overtime_hours ,0)  <> 0
    ;
    
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_ot_over ,0)  <> 0;
    --HMT_20210420 End

    --< 20181030 KTH Start Add
    IF g_add_ot_time <> 0 THEN
        SELECT nvl(round(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                           ,p_employee_no
                                                           ,v_end_yyyymmdd
                                                            ) * g_add_ot_time * v_rate/ v_basis_working_hours

                ),0)
               , g_add_ot_time
        INTO   v_add_tot_ot_amount
             , v_add_ot_hours
        FROM   DUAL
        ;
    END IF;

    v_tot_ot_amount := v_tot_ot_amount + v_add_tot_ot_amount;
    v_ot_hours      := v_ot_hours + v_add_ot_hours;

    g_add_ot_time := 0;
    -->


    /* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */
   SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.weekday_overtime_hours * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_overtime_hours ,0)  <> 0
    --AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End

    --dbms_output.put_line('v_tot_ot_amount=>'||v_tot_ot_amount);

    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    p_tax_amount       := round(v_tot_amount*(1/v_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate),0); 
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0) - (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 Start


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_150ot => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_200ot                                        */
/* Description    :  200% OT Calculate procedure                              */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 200 OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_200ot( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_200ot( p_employee_no                          => p_employee_no,
                                p_period_id                   => p_period_id,
                                p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                p_payroll_item_id             => p_payroll_item_id,
                                p_run_type_name               => p_run_type_name,
                                p_user_id                     => p_user_id,
                                p_tax_amount                  => v_out_param_rec(0),
                                p_nontax_amount               => v_out_param_rec(1),
                                p_ot_count                    => v_out_param_rec(2),
                                p_hc_count                    => v_out_param_rec(3),
                                p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                                p_hc_300h_count               => v_out_param_rec(5),
                                p_300h_tax_amount             => v_out_param_rec(6) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_200ot                                        */
/* Description    :  200% OT Calculate procedure                              */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 200OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_200ot( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER   ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT200_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 150 ot := Ordiary wage/192 * 150 OT Time.

    SELECT nvl(round(SUM((lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.holiday_overtime_hours * v_rate)/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.holiday_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.holiday_overtime_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.holiday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.holiday_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.holiday_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End


    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.holiday_overtime_hours * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.holiday_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.holiday_overtime_hours ,0)  <> 0
    --AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.holiday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.holiday_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.holiday_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End


    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    p_tax_amount       := ROUND(round(v_tot_amount,0)*(1/v_rate),0)- round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours; 
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount; 
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_200ot => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_300ot                                        */
/* Description    :  300% OT Calculate procedure                              */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 300 OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_300ot( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_300ot(  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3),
                        p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                        p_hc_300h_count               => v_out_param_rec(5),
                        p_300h_tax_amount             => v_out_param_rec(6)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_300ot                                        */
/* Description    :  300% OT Calculate procedure                              */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 300OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2019/12/23    TaiDD       Add the Tax Rate - since 12/2019 Tax Dept recorgnize that the fomular used for 300OT and 390OT is not correct 
                                        This OT amount is all non-taxable because on PH day, employee already paid tax for that not attendance-paid day
                                        This Tax Rate can also be used for the special case when employee have total over 300 hours overtime per year, all OT amount will become taxable (no non-tax amount) 
                                        But this code not yet applied this special case because LGD not yet approve to applied       */
/******************************************************************************/
PROCEDURE calculation_300ot( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER   ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tax_rate                   NUMBER := 0; --TaiDD 20191223
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT300_RATE',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT300_TAX_RATE',v_end_yyyymmdd)) --TaiDD 20191223
    INTO   v_basis_working_hours
          ,v_rate
          ,v_tax_rate --TaiDD 20191223
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 300 ot := Ordiary wage/192 * 300 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_hours * arn.public_holiday_overtime_hours * v_rate

            )),0)
           ,nvl( SUM( arn.public_holiday_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.public_holiday_overtime_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.public_holiday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.public_holiday_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.public_holiday_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End


/* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_hours * arn.public_holiday_overtime_hours * v_rate

            )),0)
           ,nvl( SUM( arn.public_holiday_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.public_holiday_overtime_hours ,0)  <> 0
    --AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.public_holiday_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.public_holiday_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.public_holiday_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End

    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    --p_tax_amount       := round(v_tot_amount*(1/v_rate),0);
    --p_tax_amount       := round(v_tot_amount*(1/v_rate*v_tax_rate),0); --TaiDD 20191223 Add the Tax Rate 
    p_tax_amount       := round(v_tot_amount*(1/v_rate*v_tax_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate*v_tax_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_300ot => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_200nt                                        */
/* Description    :  200% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 200 Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_200nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_200nt(  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3),
                        p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                        p_hc_300h_count               => v_out_param_rec(5),
                        p_300h_tax_amount             => v_out_param_rec(6)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_200nt                                        */
/* Description    :  200% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 200Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_200nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER  ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT200_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 300 ot := Ordiary wage/192 * 300 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.weekday_night_overtime_hours * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_night_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_night_overtime_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_night_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_night_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End


    /* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        )* arn.weekday_night_overtime_hours * v_rate / v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_night_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_night_overtime_hours ,0)  <> 0
    --AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_night_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_night_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End

    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    --p_tax_amount       := round(v_tot_amount*(1/v_rate),0);
    p_tax_amount       := round(v_tot_amount*(1/v_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_200nt => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_210nt                                        */
/* Description    :  210% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 210 Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_210nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_210nt(  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3),
                        p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                        p_hc_300h_count               => v_out_param_rec(5),
                        p_300h_tax_amount             => v_out_param_rec(6)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_210nt                                        */
/* Description    :  210% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 210Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_210nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER  
 ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End

    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT210_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 300 ot := Ordiary wage/192 * 300 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.weekday_ot_af_night_work_hours * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_ot_af_night_work_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_ot_af_night_work_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_af_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_af_night_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_af_night_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End

    /* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.weekday_ot_af_night_work_hours * v_rate / v_basis_working_hours

            )),0)
           , nvl(SUM( arn.weekday_ot_af_night_work_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.weekday_ot_af_night_work_hours ,0)  <> 0
--    AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.weekday_af_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.weekday_af_night_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.weekday_af_night_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End


    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;


    --p_tax_amount       := round(v_tot_amount*(1/v_rate),0);
    p_tax_amount       := round(v_tot_amount*(1/v_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_210nt => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_270nt                                        */
/* Description    :  270% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 270 Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_270nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_270nt(  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3),
                        p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                        p_hc_300h_count               => v_out_param_rec(5),
                        p_300h_tax_amount             => v_out_param_rec(6)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_270nt                                        */
/* Description    :  270% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 270Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_270nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER   ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT270_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 300 ot := Ordiary wage/192 * 300 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.holiday_night_overtime_hours * v_rate / v_basis_working_hours

            )),0)
           , nvl(SUM( arn.holiday_night_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.holiday_night_overtime_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.holiday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.holiday_night_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.holiday_night_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End


/* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.holiday_night_overtime_hours * v_rate / v_basis_working_hours

            )),0)
           , nvl(SUM( arn.holiday_night_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.holiday_night_overtime_hours ,0)  <> 0
   -- AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.holiday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.holiday_night_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.holiday_night_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End


    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    --p_tax_amount       := round(v_tot_amount*(1/v_rate),0);
    p_tax_amount       := round(v_tot_amount*(1/v_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_270nt => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_390nt                                        */
/* Description    :  390% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 390 Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_390nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;


    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_390nt(  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3),
                        p_ot_300h_count               => v_out_param_rec(4), --HMT_20210420
                        p_hc_300h_count               => v_out_param_rec(5),
                        p_300h_tax_amount             => v_out_param_rec(6)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_390nt                                        */
/* Description    :  390% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 390Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2019/12/23    TaiDD       Add the Tax Rate - since 12/2019 Tax Dept recorgnize that the fomular used for 300OT and 390OT is not correct 
                                        This OT amount is all non-taxable because on PH day, employee already paid tax for that not attendance-paid day
                                        This Tax Rate can also be used for the special case when employee have total over 300 hours overtime per year, all OT amount will become taxable (no non-tax amount)
                                        But this code not yet applied this special case because LGD not yet approve to applied       */
/******************************************************************************/
PROCEDURE calculation_390nt( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER,
                             p_ot_300h_count               OUT NUMBER, --HMT_20210420
                             p_hc_300h_count               OUT NUMBER,
                             p_300h_tax_amount             OUT NUMBER   ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tax_rate                   NUMBER := 0; --TaiDD 20191223
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    --HMT_20210420 Start
    v_year_over_tot_ot_amount          NUMBER := 0;
    v_year_over_ot_hours               NUMBER := 0;
    v_year_over_tot_hc_amount          NUMBER := 0;
    v_year_over_hc_hours               NUMBER := 0;
    --HMT_20210420 End
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT390_RATE',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT390_TAX_RATE',v_end_yyyymmdd)) --TaiDD 20191223
    INTO   v_basis_working_hours
          ,v_rate
          ,v_tax_rate --TaiDD 20191223
    FROM   dual
    ;

    -- Ordiary wage : base salary + fixed allowance
    -- 390 ot := Ordiary wage/192 * 390 OT Time.

    SELECT NVL(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.public_holiday_night_ot_hours * v_rate / v_basis_working_hours

            )),0)
           , NVL(SUM( arn.public_holiday_night_ot_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.public_holiday_night_ot_hours ,0)  <> 0

    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.public_holiday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.public_holiday_night_ot_over),0)
    INTO   v_year_over_tot_ot_amount
         , v_year_over_ot_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.public_holiday_night_ot_over ,0)  <> 0
    ;
    --HMT_20210420 End

/* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */

    SELECT NVL(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.public_holiday_night_ot_hours * v_rate / v_basis_working_hours

            )),0)
           , NVL(SUM( arn.public_holiday_night_ot_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.public_holiday_night_ot_hours ,0)  <> 0
--    AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;
    --HMT_20210420 Start
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(ayo.time_and_attendance_date ,'yyyymmdd')
                                                        ) * ayo.public_holiday_night_ot_over * v_rate/ v_basis_working_hours

            )),0)
           , nvl(SUM( ayo.public_holiday_night_ot_over),0)
    INTO   v_year_over_tot_hc_amount
         , v_year_over_hc_hours
    FROM   NV_TB_ATT_YEAR_OT_OVER_RQ_V  ayo
    WHERE  ayo.time_and_attendance_yyyymm     = v_yyyymm
    AND    ayo.employee_no                    = p_employee_no
    AND    nvl(ayo.public_holiday_night_ot_over ,0)  <> 0
    AND    ayo.confirm_flag                   = 'Y';
    --HMT_20210420 End

    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    --HMT_20210420 Start
    --p_tax_amount       := round(v_tot_amount*(1/v_rate),0);
    --p_tax_amount       := round(v_tot_amount*(1/v_rate*v_tax_rate),0); --TaiDD 20191223 Add the Tax Rate 
    p_tax_amount       := round(v_tot_amount*(1/v_rate*v_tax_rate),0) - round((v_year_over_tot_ot_amount+v_year_over_tot_hc_amount)*(1/v_rate*v_tax_rate),0);
    p_nontax_amount    := v_tot_amount -nvl(p_tax_amount,0)- (v_year_over_tot_ot_amount+v_year_over_tot_hc_amount);
    p_ot_count         := v_ot_hours - v_year_over_ot_hours;
    p_hc_count         := v_hc_hours - v_year_over_hc_hours;
    p_ot_300h_count    := v_year_over_ot_hours;
    p_hc_300h_count    := v_year_over_hc_hours;
    p_300h_tax_amount  := v_year_over_tot_ot_amount + v_year_over_tot_hc_amount;
    --HMT_20210420 End


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_390nt => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_30nt                                        */
/* Description    :  30% Night OT Calculate procedure                        */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 30 Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_30nt ( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_30nt (  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_tax_amount                  => v_out_param_rec(0),
                        p_nontax_amount               => v_out_param_rec(1),
                        p_ot_count                    => v_out_param_rec(2),
                        p_hc_count                    => v_out_param_rec(3)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_30nt                                         */
/* Description    :  30% Night OT Calculate procedure                         */
/*                   based on Attendace Daily Result and ordinary wabe        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * 30Night OT Time/working days
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_30nt ( p_employee_no                 IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_tax_amount                  OUT NUMBER,
                             p_nontax_amount               OUT NUMBER,
                             p_ot_count                    OUT NUMBER,
                             p_hc_count                    OUT NUMBER ) IS


    v_yyyymm                 tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd           tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code        tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;
    v_tot_amount             NUMBER := 0;
    v_tot_hc_amount          NUMBER := 0;
    v_tot_ot_amount          NUMBER := 0;
    v_ot_hours               NUMBER := 0;
    v_hc_hours               NUMBER := 0;
    v_err_msg                VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'NT30_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;


    -- Ordiary wage : base salary + fixed allowance
    -- 300 ot := Ordiary wage/192 * 300 OT Time.

    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.normal_night_overtime_hours * v_rate / v_basis_working_hours

            )),0)
           ,nvl(SUM( arn.normal_night_overtime_hours),0)
    INTO   v_tot_ot_amount
         , v_ot_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.normal_night_overtime_hours ,0)  <> 0

    ;

 /* Helocall : ?? ?? ????? ???  OT ? ???? ???
       ??? ??? RETURN  ??. */
    SELECT nvl(round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) * arn.normal_night_overtime_hours * v_rate / v_basis_working_hours

            )),0)
           ,nvl(SUM( arn.normal_night_overtime_hours),0)
    INTO   v_tot_hc_amount
         , v_hc_hours
    FROM   tb_att_special_ot_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.normal_night_overtime_hours ,0)  <> 0
--    AND    arn.progress_status_code           = '40'
    AND    arn.confirm_flag                   = 'Y'
    ;


    v_tot_amount := v_tot_ot_amount +  v_tot_hc_amount ;

    /* All non taxable */
    p_tax_amount       := 0 ; --round(v_tot_amount*(1/v_rate),0);
    p_nontax_amount    := v_tot_amount;
    p_ot_count         := v_ot_hours;
    p_hc_count         := v_hc_hours;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_30nt => '||SQLERRM;
        p_tax_amount       := 0;
        p_nontax_amount    := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_tardy                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_tardy ( p_employee_no                IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_tardy (  p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_ded_amount                  => v_out_param_rec(0),
                        p_ot_count                    => v_out_param_rec(1)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_tardy                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/******************************************************************************/
PROCEDURE calculation_tardy ( p_employee_no                IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_ded_amount                  OUT NUMBER,
                             p_ot_count                    OUT NUMBER ) IS

    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????          
                       
    v_yyyymm              tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd        tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code     tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_days  NUMBER := 0;
    v_basis_working_hours NUMBER := 0;
    v_tot_amount          NUMBER := 0;
    v_hours               NUMBER := 0;
    v_err_msg             VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
    INTO   v_basis_working_hours
    FROM   dual
    ;

    /*-----Tai DD----Start
    SELECT acn.perfect_attendance_days
    INTO   v_basis_working_days
    FROM   tb_att_close_n acn
    WHERE  acn.subsidiary_code            = v_subsidiary_code
    AND    acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
    ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End

    -- Deduction Amount := ordinary wage / total working days * ( tardy hours/8)
    /*------TaiDD-----Start
    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_days * arn.tardy_hours/8

     */
      SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_total_time * arn.tardy_hours
                                                        
            ----------TaiDD-----------End 
            ))           
           , SUM( arn.tardy_hours)
    INTO   v_tot_amount
         , v_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.tardy_hours ,0)  <> 0
    ;

    p_ded_amount       := v_tot_amount*(-1); --??????? - ???
    p_ot_count         := v_hours;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_30nt => '||SQLERRM;
        p_ded_amount       := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_goout                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_goout (  p_employee_no                 IN VARCHAR2,
                               p_period_id                   IN NUMBER,
                               p_payroll_calculation_exec_id IN NUMBER,
                               p_payroll_item_id             IN NUMBER,
                               p_run_type_name               IN VARCHAR2,
                               p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_goout( p_employee_no                 => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_ded_amount                  => v_out_param_rec(0),
                        p_ot_count                    => v_out_param_rec(1)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_goout                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/******************************************************************************/
PROCEDURE calculation_goout ( p_employee_no                IN VARCHAR2,
                             p_period_id                   IN NUMBER,
                             p_payroll_calculation_exec_id IN NUMBER,
                             p_payroll_item_id             IN NUMBER,
                             p_run_type_name               IN VARCHAR2,
                             p_user_id                     IN VARCHAR2,
                             p_ded_amount                  OUT NUMBER,
                             p_ot_count                    OUT NUMBER ) IS

    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????                         

    v_yyyymm              tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd        tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code     tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_days  NUMBER := 0;
    v_basis_working_hours NUMBER := 0;
    v_tot_amount          NUMBER := 0;
    v_hours               NUMBER := 0;
    v_err_msg             VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
    INTO   v_basis_working_hours
    FROM   dual
    ;

     /*-----Tai DD----Start
    SELECT acn.perfect_attendance_days
    INTO   v_basis_working_days
    FROM   tb_att_close_n acn
    WHERE  acn.subsidiary_code            = v_subsidiary_code
    AND    acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
     ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End

    -- Deduction Amount := ordinary wage / total working days * ( tardy hours/8)
    
    /*------TaiDD-----Start
    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_days * arn.going_out_hours/8
            
            ------------*/
     SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_total_time * arn.going_out_hours
            -------TaiDD----------End                                               
            ))                    
           , SUM( arn.going_out_hours)
    INTO   v_tot_amount
         , v_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.going_out_hours ,0)  <> 0
    ;

    p_ded_amount       := v_tot_amount*(-1); --??????? - ??? ;
    p_ot_count         := v_hours;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_going_out_hours => '||SQLERRM;
        p_ded_amount       := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_early_leave                                  */
/* Description    :  Early Leave Deductions Calculate procedure               */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (Early Leave time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_early_leave (  p_employee_no                 IN VARCHAR2,
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_early_leave( p_employee_no                 => p_employee_no,
                             p_period_id                   => p_period_id,
                             p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                             p_payroll_item_id             => p_payroll_item_id,
                             p_run_type_name               => p_run_type_name,
                             p_user_id                     => p_user_id,
                             p_ded_amount                  => v_out_param_rec(0),
                             p_ot_count                    => v_out_param_rec(1)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_early_leave                                  */
/* Description    :  early_leave Deductions Calculate procedure               */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (early_leave time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/******************************************************************************/
PROCEDURE calculation_early_leave ( p_employee_no                 IN VARCHAR2,
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2,
                                    p_ded_amount                  OUT NUMBER,
                                    p_ot_count                    OUT NUMBER ) IS

    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????                                       

    v_yyyymm              tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd        tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code     tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_days  NUMBER := 0;
    v_basis_working_hours NUMBER := 0;
    v_tot_amount          NUMBER := 0;
    v_hours               NUMBER := 0;
    v_err_msg             VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
    INTO   v_basis_working_hours
    FROM   dual
    ;

    /*------------TaiDD------------Start
    SELECT acn.perfect_attendance_days
    INTO   v_basis_working_days
    FROM   tb_att_close_n acn
    WHERE  acn.subsidiary_code            = v_subsidiary_code
    AND    acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
      ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End


    -- Deduction Amount := ordinary wage / total working days * ( tardy hours/8)
    
    /*-----------TaiDD------Start
    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_days * arn.early_leave_hours/8

            
    */
     SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(arn.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_total_time * arn.early_leave_hours
             ))       
           , SUM( arn.early_leave_hours)
    INTO   v_tot_amount
         , v_hours
    FROM   tb_att_result_n  arn
    WHERE  arn.time_and_attendance_yyyymm     = v_yyyymm
    AND    arn.employee_no                    = p_employee_no
    AND    nvl(arn.early_leave_hours ,0)  <> 0
    ;

    p_ded_amount       := v_tot_amount*(-1); --??????? - ??? ;
    p_ot_count         := v_hours;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_early_leave => '||SQLERRM;
        p_ded_amount       := 0;
        p_ot_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_goout                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_unpaid_deduction (  p_employee_no                 IN VARCHAR2,
                                          p_period_id                   IN NUMBER,
                                          p_payroll_calculation_exec_id IN NUMBER,
                                          p_payroll_item_id             IN NUMBER,
                                          p_run_type_name               IN VARCHAR2,
                                          p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_unpaid_deduction( p_employee_no                 => p_employee_no,
                                  p_period_id                   => p_period_id,
                                  p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                                  p_payroll_item_id             => p_payroll_item_id,
                                  p_run_type_name               => p_run_type_name,
                                  p_user_id                     => p_user_id,
                                  p_ded_amount                  => v_out_param_rec(0),
                                  p_total_unpaid_days           => v_out_param_rec(1),
                                  p_absence_days         => v_out_param_rec(2),
                                  p_unpaid_leaves        => v_out_param_rec(3),
                                  p_unpaid_suspension    => v_out_param_rec(4),
                                  p_working_days         => v_out_param_rec(5) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_goout                                        */
/* Description    :  Tardy Deductions Calculate procedure                     */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28   SonSuyang         Initial Release                             */
/* 2018/10/01   KimTaehyun        Separation Retroactive Payroll              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/* 2022/02/13    HMT_20220213       Add the WH code in the count for Unpaid (IN ('NW') --> IN ('NW','WH'))            */
/******************************************************************************/
PROCEDURE calculation_unpaid_deduction ( p_employee_no                 IN VARCHAR2,
                                         p_period_id                   IN NUMBER,
                                         p_payroll_calculation_exec_id IN NUMBER,
                                         p_payroll_item_id             IN NUMBER,
                                         p_run_type_name               IN VARCHAR2,
                                         p_user_id                     IN VARCHAR2,
                                         p_ded_amount                  OUT NUMBER,
                                         p_total_unpaid_days           OUT NUMBER,
                                         p_absence_days                OUT number,
                                         p_unpaid_leaves               OUT NUMBER,
                                         p_unpaid_suspension           OUT NUMBER,
                                         p_working_days                OUT NUMBER ) IS
                                         
    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????            
                                  
    v_yyyymm              tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd        tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code     tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_days  NUMBER := 0;
    v_basis_working_hours NUMBER := 0;
    v_tot_amount          NUMBER := 0;
    v_total_working_days  NUMBER := 0;
    v_unpaid_leaves       NUMBER := 0;
    v_absence_days        NUMBER := 0;
    v_unpaid_suspension   NUMBER := 0;
    v_total_unpaid_days   NUMBER := 0;
    v_err_msg             VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN
    SELECT pcpb.payroll_calc_period_value
          ,pcpb.end_yyyymmdd
          ,pcpb.subsidiary_code
    INTO   v_yyyymm
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcpb
    WHERE  pcpb.payroll_calculation_period_id = p_period_id
    ;

    /*-----------TaiDD------------Start-----------
    SELECT acn.perfect_attendance_days
    INTO   v_basis_working_days
    FROM   tb_att_close_n acn
    WHERE  acn.subsidiary_code            = v_subsidiary_code
    AND    acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
    ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End
    
    -- Deduction Amount := ordinary wage / total working days



   /* SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(res.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_days

            ))
          ,SUM(CASE WHEN cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM' ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_leaves      -- Unpaid Leave
          ,SUM(CASE WHEN cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'AB'             ) THEN cod.unpaid_days ELSE 0 END) AS absence_days       -- Absence ?
          ,SUM(CASE WHEN cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'US'             ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_suspension  -- Unpaid Suspension ?

         ,COUNT(*)
    INTO   v_tot_amount
         , v_unpaid_leaves
         , v_absence_days
         , v_unpaid_suspension
         , v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
          ,tb_att_calendar_n cal
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    res.time_and_attendance_date   = cal.time_and_attendance_date
    AND    res.subsidiary_code            = cal.subsidiary_code
    AND    cal.holiday_flag = 'N'
    AND    cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB','US'  )
    ;*/


    /*--------------TaiDD----Start-----
    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(res.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_basis_working_days                                                                                                   
            ))
          ,SUM(CASE WHEN cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM' ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_leaves      -- Unpaid Leave
          ,SUM(CASE WHEN cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'AB'             ) THEN cod.unpaid_days ELSE 0 END) AS absence_days       -- Absence ?
          ,SUM(CASE WHEN (cal.holiday_flag = 'N' OR cal.time_and_attendance_code = 'PH')
                                            AND cod.time_and_attendance_code IN ( 'US'             ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_suspension  -- Unpaid Suspension ?

         ,COUNT(*)
    INTO   v_tot_amount
         , v_unpaid_leaves
         , v_absence_days
         , v_unpaid_suspension
         , v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
          ,tb_att_calendar_n cal
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    res.time_and_attendance_date   = cal.time_and_attendance_date
    AND    res.subsidiary_code            = cal.subsidiary_code
    AND    ((cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB' )) OR  -- 'UF', 'UL', 'UM', 'AB' ? ??? ???? ?? ??
            ((cal.holiday_flag = 'N' OR cal.time_and_attendance_code  = 'PH')        --US? ???? ???? ???? ????? ?? ???
                                    AND cod.time_and_attendance_code IN ( 'US'             ))
           )
    ;

    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(res.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_total_time * lgvatt_common_pkg.get_work_hours_by_att(v_subsidiary_code, res.time_and_attendance_date, res.shift_type_code)
     ))
          ,SUM(CASE WHEN lgvatt_common_pkg.get_holiday_flag(v_subsidiary_code, res.shift_type_code, res.time_and_attendance_date) = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM' ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_leaves      -- Unpaid Leave
          ,SUM(CASE WHEN lgvatt_common_pkg.get_holiday_flag(v_subsidiary_code, res.shift_type_code, res.time_and_attendance_date) = 'N' AND cod.time_and_attendance_code IN ( 'AB'             ) THEN cod.unpaid_days ELSE 0 END) AS absence_days       -- Absence ?
          ,SUM(CASE WHEN lgvatt_common_pkg.get_holiday_flag(v_subsidiary_code, res.shift_type_code, res.time_and_attendance_date) = 'N' AND cod.time_and_attendance_code IN ( 'US'             ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_suspension  -- Unpaid Suspension 
                                            
         ,COUNT(*)
    INTO   v_tot_amount
         , v_unpaid_leaves
         , v_absence_days
         , v_unpaid_suspension
         , v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    lgvatt_common_pkg.get_holiday_flag(v_subsidiary_code, res.shift_type_code, res.time_and_attendance_date) = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB', 'US' ) -- 'UF', 'UL', 'UM', 'AB' , 'US''? ??? ???? ?? ??
    ;
    */
    SELECT round(SUM(lgvpay_calculation_pkg.get_ordinary_wage(p_payroll_calculation_exec_id
                                                       ,p_employee_no
                                                       ,to_char(res.time_and_attendance_date ,'yyyymmdd')
                                                        ) / v_total_time * lgvpay_info_pkg.get_work_hours(v_subsidiary_code, res.employee_no, bb.time_and_attendance_date, 
                                                                                   DECODE(res.time_and_attendance_code,'WH','WH','PH','PH','NW'),  bb.shift_type_code, bb.work_hours, 'pay_perfect_hours') -- lgvatt_common_pkg.get_work_hours_by_att  HMT_20220213
    ))
          ,SUM(CASE WHEN bb.time_and_attendance_code IN ( 'NW','WH'    ) AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM' ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_leaves      -- Unpaid Leave HMT_20220213
          ,SUM(CASE WHEN bb.time_and_attendance_code IN ( 'NW','WH'      ) AND cod.time_and_attendance_code IN ( 'AB'             ) THEN cod.unpaid_days ELSE 0 END) AS absence_days       -- Absence ?  HMT_20220213
          ,SUM(CASE WHEN bb.time_and_attendance_code IN ( 'NW','WH', 'PH' ) AND cod.time_and_attendance_code IN ( 'US'             ) THEN cod.unpaid_days ELSE 0 END) AS unpaid_suspension  -- Unpaid Suspension HMT_20220213
                                            
         ,COUNT(*)
    INTO   v_tot_amount
         , v_unpaid_leaves
         , v_absence_days
         , v_unpaid_suspension
         , v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
          ,tb_att_base_bas_n bb
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    res.subsidiary_code            = bb.subsidiary_code
    AND    res.time_and_attendance_date = bb.time_and_attendance_date
    AND    res.shift_type_code          = bb.shift_type_code
    AND    ((bb.time_and_attendance_code IN ( 'NW','WH'    ) AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB' )) OR -- 'UF', 'UL', 'UM', 'AB' ? ??? ???? ?? ?? HMT_20220213
      (bb.time_and_attendance_code IN ( 'NW','WH' , 'PH' ) AND cod.time_and_attendance_code IN ( 'US'         ))) --HMT_20220213
    ;
       ---------------TaiDD------------End 

    SELECT COUNT(*)
    INTO   v_total_working_days
    FROM   tb_att_result_n  arn
          ,tb_att_code_c acc
    WHERE arn.employee_no                = p_employee_no
    AND   arn.time_and_attendance_yyyymm = v_yyyymm
    AND   arn.time_and_attendance_code   = acc.time_and_attendance_code
    AND   ( acc.paid_days  > 0 OR acc.attendance_days > 0);


    /* ????? 0?? ??/???? ??? ?????? ?? ??? ????. */
    IF v_total_working_days = 0  AND  v_total_unpaid_days > 0 THEN
        v_tot_amount := lgvpay_aggr_pkg.get_aggr_result(p_payroll_item_aggregate_name    => 'FIXED_ALLOWANCE'
                                                        ,p_aggregate_cycle_type_code     => 'RUN'
                                                        ,p_payroll_calculation_exec_id   => p_payroll_calculation_exec_id
                                                        ,p_employee_no                   => p_employee_no
                                                        --< 20181001 KTH Start Add
                                                        ,p_retropay_target_yyyymm        => v_yyyymm
                                                        -->
                                                         );
    END IF;

    p_ded_amount                   := v_tot_amount*(-1); --??????? - ??? ;
    p_total_unpaid_days            := v_total_unpaid_days;
    p_absence_days                 := v_absence_days;
    p_unpaid_leaves                := v_unpaid_leaves;
    p_unpaid_suspension            := v_unpaid_suspension;
    p_working_days                 := v_total_working_days;




EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_unpaid_deduction  => '||SQLERRM;
        p_ded_amount                   := 0;
        p_total_unpaid_days            := 0;
        p_absence_days                 := 0;
        p_unpaid_leaves                := 0;
        p_unpaid_suspension            := 0;
        p_working_days                 := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_annlal_leave                                 */
/* Description    :  Annual Leave Calculate procedure                          */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_annual_leave (  p_employee_no                 IN VARCHAR2,
                                      p_period_id                   IN NUMBER,
                                      p_payroll_calculation_exec_id IN NUMBER,
                                      p_payroll_item_id             IN NUMBER,
                                      p_run_type_name               IN VARCHAR2,
                                      p_user_id                     IN VARCHAR2 ) IS
    v_tax_amount    NUMBER;
    v_nontax_amount NUMBER;
    v_ot_count      NUMBER;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

    CURSOR c_cur IS
    SELECT   param.parameter_value
           , param.payroll_item_id
           , param.payroll_item_detail_detail_id
           , param.pay_calc_rslt_detail_type_code
    FROM     tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);

    v_retire_flag          VARCHAR2(1) := 'N';
    v_mm                   VARCHAR2(2) ;
    v_subsidiary_code      VARCHAR2(30);




BEGIN

    --dbms_output.put_line('annual_leave calc');

    --1) ?? ????
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          ,period.subsidiary_code
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;


   /* ???? ?? ???? 12?? ???
      ??? ???? ??? 12?? ??? return ??? */
    BEGIN
    SELECT 'Y'
    INTO  v_retire_flag
    FROM  dual
    WHERE EXISTS (    SELECT 1
                      FROM   emp_master em
                      WHERE  em.employee_number  = p_employee_no
                      AND    em.date_retire      is not NULL
                      AND    em.date_retire      <= to_date(v_end_yyyymmdd,'yyyymmdd')
                   )
    ;

    EXCEPTION
        WHEN OTHERS THEN
            v_retire_flag := 'N';
    END;

    --dbms_output.put_line('v_retire_flag=>'||v_retire_flag);


    IF v_retire_flag = 'N' THEN
        SELECT  substr(a.payroll_calc_period_value,5,2)
        INTO    v_mm
        FROM    tb_pay_calc_period_basis_n a
        WHERE   a.payroll_calculation_period_id = p_period_id
        ;


        /* 01??? ??? */
        IF v_mm <> lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'ANNUAL_LEAVE_BASE_MM',v_end_yyyymmdd ) THEN
            RETURN ;
        END IF;

    END IF;




    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;

    calculation_annual_leave( p_employee_no           => p_employee_no,
                        p_period_id                   => p_period_id,
                        p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                        p_payroll_item_id             => p_payroll_item_id,
                        p_run_type_name               => p_run_type_name,
                        p_user_id                     => p_user_id,
                        p_retire_flag                 => v_retire_flag,
                        p_ded_amount                  => v_out_param_rec(0),
                        p_an_count                    => v_out_param_rec(1)  ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

      --  dbms_output.put_line(v_result||' '||c.payroll_item_id||c.payroll_item_detail_detail_id );

        create_result(   p_payroll_calculation_exec_id       => p_payroll_calculation_exec_id,
                         p_employee_no                       => p_employee_no,
                         p_payroll_item_id                   => c.payroll_item_id,
                         p_payroll_item_detail_id            => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code             => v_result_code,
                         p_result_value                      => v_result,
                         p_user_id                           => p_user_id,
                         p_period_id                         => p_period_id)   ;



        v_count := v_count+1;

    END LOOP;


END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_annlal_leave                                 */
/* Description    :  Annal Leave Calculate procedure                          */
/*                   based on Attendace Daily Result and ordinary wage        */
/*                   this amount is calcuationed.                             */
/*                   Ordiary wage * (tardy time/8)
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2022/12/28    HMT_20221228 change BASIS_TOT_WK_HOURS --> BASIS_ANNU_WK_HOURS*/
/******************************************************************************/
PROCEDURE calculation_annual_leave ( p_employee_no                IN VARCHAR2,
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2,
                                     p_retire_flag                 IN VARCHAR2,
                                     p_ded_amount                  OUT NUMBER,
                                     p_an_count                    OUT NUMBER ) IS


    v_yyyymm                                   tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;
    v_end_yyyymmdd                             tb_pay_calc_period_basis_n.end_yyyymmdd%TYPE;
    v_subsidiary_code                          tb_pay_calc_period_basis_n.subsidiary_code%TYPE;
    v_basis_working_days                       NUMBER := 0;

    v_tot_amount_last_year                               NUMBER := 0;
    v_tot_amount_this_year                               NUMBER := 0;
    v_tot_amount_all                                     NUMBER := 0;

    v_leave_days_last_year               NUMBER := 0;
    v_leave_days_this_year               NUMBER := 0;
    v_leave_days_tot                     NUMBER := 0;


    v_err_msg                                  VARCHAR2(4000);
    v_basis_date                               DATE;
    v_setup_base                               VARCHAR2(100);
    v_base                                     VARCHAR2(100);
    v_base_mm                                  VARCHAR2(100);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;
    v_basis_working_hours                      NUMBER;
    v_mm                                       VARCHAR2(2) ;



BEGIN
    -- ????? ????
    SELECT a.subsidiary_code
          ,a.end_yyyymmdd
    INTO   v_subsidiary_code
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n a
    WHERE  a.payroll_calculation_period_id = p_period_id
    ;

    -- ???? ????????? ?? ??
    SELECT  substr(a.payroll_calc_period_value,5,2)
    INTO    v_mm
    FROM    tb_pay_calc_period_basis_n a
    WHERE   a.payroll_calculation_period_id = p_period_id
    ;

    --?? ?? ???? ??? ( 192?? )
     --HMT_20221228 change BASIS_TOT_WK_HOURS --> BASIS_ANNU_WK_HOURS
    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_ANNU_WK_HOURS',v_end_yyyymmdd))
    INTO   v_basis_working_hours
    FROM   dual
    ;




    /* ??? ???? ??? ??? ??
       ??? ???? ??? ??? ??? */
    IF v_mm = lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'ANNUAL_LEAVE_BASE_MM',v_end_yyyymmdd ) THEN

       /* ?? ??? ??? ???? ??? */
        v_setup_base := lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'ANNUAL_LEAVE_CALC_BASIS_MM',v_end_yyyymmdd );

        SELECT substr(v_setup_base, 1, instr(v_setup_base,'|',1)-1)
             , substr(v_setup_base, instr(v_setup_base,'|',1)+1)
        INTO  v_base , v_base_mm
        FROM  dual
        ;


        IF v_base = 'LAST' THEN

            SELECT to_date(b.end_yyyymmdd,'yyyymmdd')
                  ,b.payroll_calc_period_value
            INTO   v_basis_date
                  ,v_yyyymm
            FROM   tb_pay_calc_period_basis_n b
            WHERE  b.subsidiary_code = v_subsidiary_code
            AND    b.payroll_calc_period_value = (
                                                    SELECT to_char(to_number(substr(end_yyyymmdd,1,4))-1)||v_base_mm
                                                    FROM   tb_pay_calc_period_basis_n a
                                                    WHERE  a.payroll_calculation_period_id = p_period_id
                                                    )
            ;


        ELSE


            SELECT to_date(a.end_yyyymmdd,'yyyymmdd')
                  ,a.payroll_calc_period_value
            INTO   v_basis_date
                  ,v_yyyymm
            FROM   tb_pay_calc_period_basis_n a
            WHERE  a.payroll_calculation_period_id = p_period_id
            ;

        END IF;

        --??? 12? ??? ????? ???
        BEGIN
            SELECT annual_compensation_days
            INTO   v_leave_days_last_year
            FROM   tb_att_annual_leave_n
            WHERE  employee_no                = p_employee_no
            AND    time_and_attendance_yyyymm = v_yyyymm;
        EXCEPTION
            WHEN OTHERS THEN
                v_leave_days_last_year := 0;
        END;


        SELECT round(SUM(lgvpay_info_pkg.get_ordinary_wages_for_al(p_employee_no,to_char(v_basis_date,'yyyymmdd'))
                         / v_basis_working_hours *8* v_leave_days_last_year
                        ))
        INTO  v_tot_amount_last_year
        FROM dual
        ;

        --dbms_output.put_line('v_leave_days_last_year=>'||v_leave_days_last_year);
        --dbms_output.put_line('v_tot_amount_last_year=>'||v_tot_amount_last_year);


    ELSE
        p_ded_amount           := 0;
        p_an_count             := 0;
    END IF;

    IF p_retire_flag = 'Y' THEN

        SELECT em.date_retire
              ,a.payroll_calc_period_value
        INTO   v_basis_date
              ,v_yyyymm
        FROM   emp_master em
             , tb_pay_calc_period_basis_n a
        WHERE  employee_number                 = p_employee_no
        AND    a.payroll_calculation_period_id = p_period_id
        ;

        SELECT acn.perfect_attendance_days
        INTO   v_basis_working_days
        FROM   tb_att_close_n acn
        WHERE  acn.subsidiary_code            = v_subsidiary_code
        AND    acn.time_and_attendance_yyyymm = v_yyyymm
        ;

        BEGIN
            SELECT a.annual_compensation_days
            INTO   v_leave_days_this_year
            FROM   tb_att_annual_leave_n A
            WHERE  employee_no               = p_employee_no
            AND    time_and_attendance_yyyymm IN (
                                                    SELECT MAX(aaln.time_and_attendance_yyyymm)
                                                    FROM   tb_att_annual_leave_n  aaln
                                                    WHERE  aaln.employee_no = p_employee_no
                                                    )
                                                    ;
        EXCEPTION
            WHEN OTHERS THEN
                v_leave_days_this_year := 0;
        END;

        /* ???? ???? /192*8 ? ??? */

        SELECT round(SUM(lgvpay_info_pkg.get_ordinary_wages_for_al(p_employee_no,to_char(v_basis_date,'yyyymmdd'))
                         / v_basis_working_hours *8 * v_leave_days_this_year
                        ))
        INTO  v_tot_amount_this_year
        FROM dual
        ;

       /* DBMS_OUTPUT.put_line('v_basis_working_hours=>'||v_basis_working_days);
        DBMS_OUTPUT.put_line('v_leave_days_this_year=>'||v_leave_days_this_year);
        DBMS_OUTPUT.put_line('v_tot_amount_this_year=>'||v_tot_amount_this_year);*/


    END IF;


    v_tot_amount_all             := v_tot_amount_last_year + v_tot_amount_this_year;
    v_leave_days_tot             := v_leave_days_last_year + v_leave_days_this_year;


    p_ded_amount       := v_tot_amount_all; --??????? - ??? ;
    p_an_count         := v_leave_days_tot;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_anual_leave => '||SQLERRM;
        p_ded_amount       := 0;
        p_an_count         := 0;

        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_adj1                                         */
/* Description    :  Adjustment1 Allowance calculation                        */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_adj1( p_employee_no                 IN VARCHAR2,
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_subsidiary_code      VARCHAR2(30);

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

    v_procedure_name := 'calculation_adj1';


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          ,em.subsidiary_code
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;


    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, ymd, p_payroll_item_id, 'BASE_AMOUNT' ),0)base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;



    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );

    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation adjustment1 allowance error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment1 allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(adjustment1 error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_adj2                                         */
/* Description    :  Adjustment1 Allowance calculation                        */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_adj2( p_employee_no                 IN VARCHAR2,
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

    v_procedure_name := 'calculation_adj2';


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;



    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, ymd, p_payroll_item_id, 'BASE_AMOUNT' ),0)base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;


    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );

    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation adjustment allowance2 error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment allowance2 error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(adjustment2 error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;


PROCEDURE calculation_adj3( p_employee_no                 IN VARCHAR2,
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_pay_step             VARCHAR(30);
    v_grade_type           VARCHAR(30);
    v_calc_min_stat_date   DATE;
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

    v_procedure_name := 'calculation_adj3';


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;



    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, ymd, p_payroll_item_id, 'BASE_AMOUNT' ),0)base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;


    v_return := calculate_pay(p_employee_no                => p_employee_no
                            ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                            ,p_payroll_item_id             => p_payroll_item_id
                            ,p_period_id                   => p_period_id
                            ,p_run_type_name               => p_run_type_name
                            ,p_user_id                     => p_user_id
                            );

    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation adjustment allowance3 error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment allowance3 error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(adjustment allowance3 error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_pit                                         */
/* Description    :  PIT(Tax) Calculation                                     */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_pit( p_employee_no                 IN VARCHAR2,
                           p_period_id                   IN NUMBER,
                           p_payroll_calculation_exec_id IN NUMBER,
                           p_payroll_item_id             IN NUMBER,
                           p_run_type_name               IN VARCHAR2,
                           p_user_id                     IN VARCHAR2 ) IS

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code          = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result              VARCHAR2(1000);
    v_result_code         VARCHAR2(1000);
    v_pit_amount          NUMBER;
    v_dependant_deduction NUMBER;

    v_out_param_rec   out_param_res_type;
    v_count           NUMBER  :=0;
    v_err_buf         VARCHAR2(1000);



    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;
    END LOOP;


    calculation_pit( p_employee_no                => p_employee_no,
                    p_period_id                   => p_period_id,
                    p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                    p_payroll_item_id             => p_payroll_item_id,
                    p_run_type_name               => p_run_type_name,
                    p_user_id                     => p_user_id,
                    p_pit                         => v_out_param_rec(0),
                    p_dependant_deduction         => v_out_param_rec(1),
                    p_total_incom_for_tax         => v_out_param_rec(2),
                    p_exception_flag               =>v_out_param_rec(3) ) ;

    v_count := 0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;


        create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment allowance2 error ; ' ||SQLERRM);
        v_step := 'User Exception Error(PIT Main Error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);


END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_pit                                          */
/* Description    :  PIT(Tax) Calculation                                     */
/*                   ???? ??? ???? ????? ????             */
/*                   ? ??? ???? ?? ??? rate? ?? ???        */
/*                   ????.
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20   SonSuyang         Initial Release                             */
/* 2018/10/01   KimTaehyun        Separation Retroactive Payroll              */
/* 2025/07/04   HaMinhThuy        Add PIT 10%            HMT_20250704         */
/* 2025/09/01   HaMinhThuy        update PIT logic for under three month contract     HMT_20250901         */
/******************************************************************************/

 PROCEDURE calculation_pit(  p_employee_no                 IN VARCHAR2,
                            p_period_id                   IN NUMBER,
                            p_payroll_calculation_exec_id IN NUMBER,
                            p_payroll_item_id             IN NUMBER,
                            p_run_type_name               IN VARCHAR2,
                            p_user_id                     IN VARCHAR2,
                            p_pit                         OUT NUMBER,
                            p_dependant_deduction         OUT NUMBER,
                            p_total_incom_for_tax         OUT NUMBER,
                            p_exception_flag              OUT VARCHAR2 ) IS

    v_dependant_count       NUMBER := 0;
    v_end_yyyymmdd          VARCHAR2(10);
    v_subsidiary_code       VARCHAR2(10);
    v_taxable_earning       NUMBER;
    v_dependant_deduction   NUMBER := 0;
    v_total_income_for_tax  NUMBER := 0;

    v_subtrahend            NUMBER := 0;
    v_multiplier            NUMBER := 0;
    v_append                NUMBER := 0;
    v_pit                   NUMBER := 0;

    v_dept_ded_amount       NUMBER := 0;
    v_self_ded_amount       NUMBER := 0;
    v_pit_adjust_rate       NUMBER := 0;
    v_pit_10                NUMBER := 0; --HMT_20250704
    v_grade_code            VARCHAR2(10) := ''; --HMT_20250704

    v_err_buf               VARCHAR2(1000);
    v_basis_yyyymm          VARCHAR2(10);
    v_calculate_yn          VARCHAR2(1) := 'N';

    v_total_income_amount_1 NUMBER := 0;
    v_total_non_taxable1    NUMBER := 0;

    v_total_income_amount_2 NUMBER := 0;
    v_total_non_taxable2    NUMBER := 0;

    v_total_income_amount_3 NUMBER := 0;
    v_total_non_taxable3    NUMBER := 0;

    v_base_rate             NUMBER := 0;
    v_base_amount           NUMBER := 0;

    v_base_amount1          NUMBER := 0;
    v_base_amount2          NUMBER := 0;
    v_base_amount3          NUMBER := 0;
    
    v_total_incom_for_tax_1         NUMBER := 0;
    v_total_incom_for_tax_2         NUMBER := 0;
    v_total_incom_for_tax_3         NUMBER := 0;

    v_tax_amt1              NUMBER := 0;
    v_tax_amt2              NUMBER := 0;

    v_adding_up_taxation_flag      VARCHAR2(1);
    v_addup_taxation_start_yyyymm  VARCHAR2(10);
    v_taxable_earning_bf           NUMBER := 0;
    v_taxable_earning_cur          NUMBER := 0;
    v_pit_bf                       NUMBER := 0;
    v_pit_cur                      NUMBER := 0;
    
    --20240829@Kimbiho add new logic
    v_housing_allow_nontaxable     NUMBER := 0;    
    v_housing_allow_taxable        NUMBER := 0;
    v_payroll_item_name            VARCHAR2(1000);
    v_increase_and_decrease_rate   NUMBER := 0;
    
    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN

    --???? ?? ????? pit? ???? ????
    --?? ???? ????.
    -- ??????  emp_master.calculate_yn = Y ? ?? ??.

    --0) Getting Base yyyymmdd, Subsidiary Code
    SELECT pcp.end_yyyymmdd
          ,pcp.subsidiary_code
          ,pcp.payroll_calc_period_value
    INTO   v_end_yyyymmdd
          ,v_subsidiary_code
          ,v_basis_yyyymm
    FROM   tb_pay_calc_period_basis_n pcp
    WHERE  pcp.payroll_calculation_period_id = p_period_id
    ;

    /* ???? ??? ?? */
    SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'DEPENDANT_DEDUCTION_AMT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'SELF_DEDUCTION_AMT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'PIT_ADJUST_RATE',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_planned_item_value(p_employee_no, to_date(v_end_yyyymmdd,'YYYYMMDD'), 'PIT_10' ,'BASE_AMOUNT',v_subsidiary_code),0) --HMT_20250704
    INTO   v_dept_ded_amount
          ,v_self_ded_amount
          ,v_pit_adjust_rate
          ,v_pit_10
    FROM dual
    ;

    SELECT nvl(a.calculate_yn,'N'), a.grade
    INTO   v_calculate_yn, v_grade_code
    FROM   emp_master a
    WHERE  employee_number= p_employee_no
    ;

    p_exception_flag := v_calculate_yn;

    --HMT_20250704 Add PIT 10%
    IF (p_exception_flag = 'P' OR v_pit_10 > 0 OR v_grade_code = 'L33') AND p_run_type_name IN ('MTH', 'MTH_RS') THEN --HMT_20251101
      p_total_incom_for_tax := lgvpay_aggr_pkg.get_aggr_result('TOTAL_INCOME','RUN',p_payroll_calculation_exec_id,p_employee_no,v_basis_yyyymm);
      v_base_amount := lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'TAX_EXCEPTION_BASE_AMOUNT',v_end_yyyymmdd );
      IF nvl(p_total_incom_for_tax,0) >= nvl(v_base_amount,0) THEN
        p_pit               := round(p_total_incom_for_tax * 0.1, 0) ;
      ELSE
        p_pit               := 0;
      END IF;
      p_dependant_deduction := 0 ;
    
    UPDATE EMP_MASTER
       SET CALCULATE_YN = 'P'
     WHERE EMPLOYEE_NUMBER = P_EMPLOYEE_NO;
  
    ELSE
    --calculation flag ? y ?? ????? ????.
    -- ????? ???? ???.
    IF v_calculate_yn = 'Y' AND p_run_type_name IN ('MTH', 'MTH_RS') THEN--HMT_20251101
        -- 3???? 3 ?? ??? ????.
        -- 2018/03/12 : If employee has PI or PS or 13th Salary, then
        --              total income, tax, non taxalbe income has to be add all
        --              so changes to sum()
        BEGIN
            SELECT nvl(sum(prs.total_income_amount),0)
                  ,nvl(sum(prs.tax_free_sum_amount),0)
                  ,nvl(sum(prs.tax_amount),0)
            INTO   v_total_income_amount_1
                  ,v_total_non_taxable1
                  ,v_tax_amt1
            FROM   tb_pay_result_s    prs
                  ,tb_pay_calc_exec_n pce
            WHERE  prs.basis_yyyymm                IN to_char( add_months(TO_DATE(v_basis_yyyymm,'yyyymm'),-2),'yyyymm')
            AND    pce.payroll_calculation_exec_id = prs.payroll_calculation_exec_id
            AND    pce.confirm_flag = 'Y'
            AND    prs.employee_no = p_employee_no;
        EXCEPTION
            WHEN OTHERS THEN
                v_total_income_amount_1 := 0;
                v_total_non_taxable1    := 0;
        END;

        -- 2018/03/12 : If employee has PI or PS or 13th Salary, then
        --              total income, tax, non taxalbe income has to be add all
        --              so changes to sum()

        BEGIN
            SELECT nvl(sum(prs.total_income_amount),0)
                  ,nvl(sum(prs.tax_free_sum_amount),0)
                  ,nvl(sum(prs.tax_amount),0)
            INTO   v_total_income_amount_2
                  ,v_total_non_taxable2
                  ,v_tax_amt2
            FROM   tb_pay_result_s    prs
                  ,tb_pay_calc_exec_n pce
            WHERE  prs.basis_yyyymm                IN to_char ( add_months(TO_DATE(v_basis_yyyymm,'yyyymm'),-1),'yyyymm')
            AND    pce.payroll_calculation_exec_id = prs.payroll_calculation_exec_id
            AND    pce.confirm_flag = 'Y'
            AND    prs.employee_no = p_employee_no;
        EXCEPTION
            WHEN OTHERS THEN
                v_total_income_amount_2 := 0;
                v_total_non_taxable2    := 0;
        END;


        --< 20181001 KTH Start Add
        --v_total_income_amount_3 := lgvpay_aggr_pkg.get_aggr_result('TOTAL_INCOME','RUN',p_payroll_calculation_exec_id,p_employee_no);
        --v_total_non_taxable3    := lgvpay_aggr_pkg.get_aggr_result('NON_TAXALBE_EARNING','RUN',p_payroll_calculation_exec_id,p_employee_no);
        v_total_income_amount_3 := lgvpay_aggr_pkg.get_aggr_result('TOTAL_INCOME','RUN',p_payroll_calculation_exec_id,p_employee_no,v_basis_yyyymm);
        v_total_non_taxable3    := lgvpay_aggr_pkg.get_aggr_result('NON_TAXALBE_EARNING','RUN',p_payroll_calculation_exec_id,p_employee_no,v_basis_yyyymm);
        -->

        v_base_rate   := lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'TAX_EXCEPTION_BASE_RATE',v_end_yyyymmdd );
        v_base_amount := lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code, 'TAX_EXCEPTION_BASE_AMOUNT',v_end_yyyymmdd );


--   =ROUND((IF(O4>=2000000,($O4-$P4)*10%,0)+IF($Q4>=2000000,($Q4-$R4)*10%,0)+IF($S4>=2000000,($S4-$T4)*10%,0))/2,0)
        IF  nvl(v_total_income_amount_1,0) >= nvl(v_base_amount,0) THEN
            /*----Old formula----TaiDD---20181222
            v_base_amount1 :=  (nvl(v_total_income_amount_1,0)- nvl(v_total_non_taxable1,0))*v_base_rate ;
            -------New formula---*/
            --v_total_incom_for_tax_1 := nvl(v_total_income_amount_1,0)- nvl(v_total_non_taxable1,0); --HMT_20250901 old
            v_total_incom_for_tax_1 := nvl(v_total_income_amount_1,0); --HMT_20250901
            v_base_amount1 := v_total_incom_for_tax_1 * v_base_rate;
        ELSE
            v_base_amount1 := 0  ;
            ----Added TaiDD---20181222
            v_total_incom_for_tax_1 :=0;
        END IF;

        IF  nvl(v_total_income_amount_2,0) >= nvl(v_base_amount,0) THEN
             /*----Old formula----TaiDD---20181222
            v_base_amount2 :=  (nvl(v_total_income_amount_2,0)- nvl(v_total_non_taxable2,0))*v_base_rate ;
            -------New formula---*/
            --v_total_incom_for_tax_2 := nvl(v_total_income_amount_2,0)- nvl(v_total_non_taxable2,0); --HMT_20250901 old
            v_total_incom_for_tax_2 := nvl(v_total_income_amount_2,0); --HMT_20250901
            v_base_amount2 := v_total_incom_for_tax_2 * v_base_rate;
        ELSE
            v_base_amount2 := 0  ;
            ----Added TaiDD---20181222
            v_total_incom_for_tax_2 :=0;
        END IF;



        IF  nvl(v_total_income_amount_3,0) >= nvl(v_base_amount,0) THEN
            /*----Old formula----TaiDD---20181222
            v_base_amount3 :=  (nvl(v_total_income_amount_3,0)- nvl(v_total_non_taxable3,0))*v_base_rate ;
            -------New formula---*/
            --v_total_incom_for_tax_3 := nvl(v_total_income_amount_3,0)- nvl(v_total_non_taxable3,0); --HMT_20250901 old
            v_total_incom_for_tax_3 := nvl(v_total_income_amount_3,0); --New formula HMT_20250901 Do not subtract NON_TAXALBE_EARNING.
            v_base_amount3 := v_total_incom_for_tax_3 * v_base_rate;            
        ELSE
            v_base_amount3 := 0  ;
            ----Added TaiDD---20181222
            v_total_incom_for_tax_3 :=0;
        END IF;


        /*dbms_output.put_line(v_total_income_amount_1||' '||v_total_non_taxable1);
        dbms_output.put_line(v_total_income_amount_2||' '||v_total_non_taxable2);
        dbms_output.put_line(v_total_income_amount_3||' '||v_total_non_taxable3);


        dbms_output.put_line(v_base_amount1);
        dbms_output.put_line(v_base_amount2);
        dbms_output.put_line(v_base_amount3);      */


        /*-------Old formula-------
        v_pit :=round((v_base_amount1+v_base_amount2+v_base_amount3)/2) -(v_tax_amt2+v_tax_amt1) ;
        ----------New formula------*/
        v_pit :=round((v_base_amount1+v_base_amount2+v_base_amount3)*v_pit_adjust_rate) -(v_tax_amt2+v_tax_amt1) ;

    --    dbms_output.put_line(round((v_base_amount1+v_base_amount2+v_base_amount3)/2));



        p_pit                            := v_pit ;
        p_dependant_deduction            := 0 ;
        /*----Old formula----TaiDD---20181222
        p_total_incom_for_tax            := (nvl(v_total_income_amount_1,0)- nvl(v_total_non_taxable1,0));
        ----------New formula------*/
        p_total_incom_for_tax := v_total_incom_for_tax_1 + v_total_incom_for_tax_2 + v_total_incom_for_tax_3;
        --DBMS_OUTPUT.PUT_LINE('v_pit=>'||v_pit);




    ELSE

        SELECT NVL(a.adding_up_taxation_flag,'N')
              ,a.addup_taxation_start_yyyymm
        INTO   v_adding_up_taxation_flag
              ,v_addup_taxation_start_yyyymm
        FROM   tb_pay_calc_exec_n a
        WHERE  a.payroll_calculation_exec_id=  p_payroll_calculation_exec_id
        ;

        IF v_adding_up_taxation_flag = 'Y' THEN
            BEGIN
                SELECT nvl(SUM(nvl(ps.aggregate_taxation_amount,0)),0)
                INTO   v_taxable_earning_bf
                FROM   tb_pay_result_s ps
                      ,tb_pay_calc_exec_n b
                WHERE  ps.basis_yyyymm >= v_addup_taxation_start_yyyymm
                AND    ps.employee_no   = p_employee_no
                AND    b.payroll_calculation_exec_id = ps.payroll_calculation_exec_id
                AND    b.confirm_flag = 'Y'
                ;

            EXCEPTION
                WHEN OTHERS THEN
                    v_taxable_earning_bf := 0;
            END;

            BEGIN
                SELECT nvl(SUM(nvl(ps.tax_amount,0)),0)
                INTO   v_pit_bf
                FROM   tb_pay_result_s ps
                      ,tb_pay_calc_exec_n b
                WHERE  ps.basis_yyyymm >= v_addup_taxation_start_yyyymm
                AND    ps.employee_no   = p_employee_no
                AND    b.payroll_calculation_exec_id = ps.payroll_calculation_exec_id
                AND    b.confirm_flag = 'Y'
                ;
            EXCEPTION
                WHEN OTHERS THEN
                    v_pit_bf := 0;
            END;


        END IF;
        
        --20240829@Kimbiho add HousingAllowance logic
        select PAYROLL_ITEM_NAME 
          into v_payroll_item_name
          from tb_pay_payroll_item_m 
         where payroll_item_id = p_payroll_item_id
        ;
                
        IF  v_payroll_item_name = 'HOUSING_ALLW' THEN
            --20240829@KimBiho HousingAllowance logic input taxable  Taxable calculation            
            SELECT NVL(result_value,0)
              INTO v_increase_and_decrease_rate
              FROM tb_pay_calc_var_n a
                  ,tb_pay_calc_var_value_n b
             WHERE a.Payroll_Calc_Variable_Id = b.Payroll_Calc_Variable_Id
               AND v_end_yyyymmdd between b.effective_start_yyyymmdd and b.effective_end_yyyymmdd
               AND a.PAYROLL_CALC_VARIABLE_NAME = 'HOUSING_ALLW_RATE'
            ;
            
            IF v_increase_and_decrease_rate < 0 THEN v_increase_and_decrease_rate := 0;
            ELSIF v_increase_and_decrease_rate > 1 THEN v_increase_and_decrease_rate := 1;
            END IF;
              
            IF v_increase_and_decrease_rate = 0 THEN 
               v_housing_allow_nontaxable := 0;
            ELSE
               --PAY VALUE find
               v_housing_allow_taxable := NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                              ,p_employee_no => p_employee_no
                                                              ,p_payroll_item_name => 'HOUSING_ALLW'
                                                              ,p_detail_name => 'PAY_VALUE'
                                                              ,p_subsidiary_code =>v_subsidiary_code ),0);
               --BASE VALUE find
               IF v_housing_allow_taxable = 0 or v_housing_allow_taxable is null THEN
                 v_housing_allow_taxable := NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                              ,p_employee_no => p_employee_no
                                                              ,p_payroll_item_name => 'HOUSING_ALLW'
                                                              ,p_detail_name => 'BASE_AMOUNT'
                                                              ,p_subsidiary_code =>v_subsidiary_code ),0);
               END IF;
               
               
               v_housing_allow_nontaxable := (1 - v_increase_and_decrease_rate) * v_housing_allow_taxable;
            END IF;
        END IF;
        
        -- PIT Calculation Start
        --1) taxable earning select
        --< 20181001 KTH Start Add
        --v_taxable_earning_cur := NVL(lgvpay_aggr_pkg.get_aggr_result('TAXALBE_EARNING_FOR_TAX','RUN',p_payroll_calculation_exec_id,p_employee_no),0)
        v_taxable_earning_cur := NVL(lgvpay_aggr_pkg.get_aggr_result('TAXALBE_EARNING_FOR_TAX','RUN',p_payroll_calculation_exec_id,p_employee_no,v_basis_yyyymm),0)
                                 -v_housing_allow_nontaxable;
        -->
        /* 2024-08-27@KimBiho Housing allow change logic - no need this           
                           - NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                            ,p_employee_no => p_employee_no
                                                            ,p_payroll_item_name => 'HOUSING_ALLW'
                                                            ,p_detail_name => 'PAY_VALUE'
                                                            ,p_subsidiary_code =>v_subsidiary_code ),0)
                           + NVL(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id =>  p_payroll_calculation_exec_id
                                                            ,p_employee_no => p_employee_no
                                                            ,p_payroll_item_name => 'HOUSING_ALLW'
                                                            ,p_detail_name => 'ALLOW_FOR_TAX'
                                                            ,p_subsidiary_code =>v_subsidiary_code ),0);
       */

       /* DBMS_OUTPUT.put_line('v_taxable_earning_bf=<'||v_taxable_earning_bf);
        DBMS_OUTPUT.put_line('v_taxable_earning_cur=<'||v_taxable_earning_cur);

        DBMS_OUTPUT.put_line('v_tax_bf=<'||v_pit_bf);*/


       v_taxable_earning := v_taxable_earning_cur + v_taxable_earning_bf;

       -- DBMS_OUTPUT.PUT_LINE(v_taxable_earning);

        --2) famliy deduction check

        SELECT COUNT(*)
        INTO   v_dependant_count
        FROM   tb_pay_emp_family_n pef
              ,tb_pay_calc_period_basis_n pcpb
        WHERE  pef.employee_no                    = p_employee_no
        AND    pcpb.payroll_calculation_period_id = p_period_id
        --AND    nvl(pef.relation_start_date,to_date(pcpb.end_yyyymmdd,'yyyymmdd') ) < to_date(pcpb.end_yyyymmdd,'yyyymmdd')
        AND    pef.dependent_flag                 = 'Y'
        ;

        --dbms_output.put_line('v_dependant_count=>'||v_dependant_count);

       -- dbms_output.put_line('v_dependant_count=>'||v_dependant_count);
       -- dbms_output.put_line('v_dept_ded_amount=>'||v_dept_ded_amount);
       -- dbms_output.put_line('v_self_ded_amount=>'||v_self_ded_amount);


        /* Dependnant Count * Deduction Amount + Self Deduction Amount */
        /*  ???? ?? = ????? * ?? ??  + ?? ?? ?? */
        v_dependant_deduction := v_dependant_count*v_dept_ded_amount + v_self_ded_amount;


       --
/*      dbms_output.put_line(  'v_dependant_deduction=>'||v_dependant_deduction);
       dbms_output.put_line(  'v_taxable_earning=>'||v_taxable_earning);

       dbms_output.put_line('v_taxable_earning=>'||v_taxable_earning);*/

       -- Subtract Dependant Deduction
       -- ???? ?? = ? ?????? - ???? ?? ?? 0?? ??? 0?? ????.
       v_total_income_for_tax :=   greatest(v_taxable_earning  - v_dependant_deduction,0);


    --  dbms_output.put_line('v_total_income_for_tax=>'||v_total_income_for_tax);
        BEGIN
            SELECT   max(CASE WHEN a.user_column_name = 'SUBTRAHEND' THEN udtv.table_cell_value ELSE '0' END )  subtrahend
                   , max(CASE WHEN a.user_column_name = 'MULTIPLIER' THEN udtv.table_cell_value ELSE '0' END )  multiplier
                   , max(CASE WHEN a.user_column_name = 'APPEND' THEN udtv.table_cell_value ELSE '0' END )  append
            INTO    v_subtrahend
                  , v_multiplier
                  , v_append
            FROM (
                    SELECT  udt.table_seq_no
                          , udtc.column_seq_no
                          , user_column_name
                          , udtr.row_no
                          , lower_limit_critical_value
                          , upper_limit_critical_value
                    FROM   tb_pay_user_dfin_table_m udt
                         , tb_pay_user_dfin_table_col_n udtc
                         , tb_pay_user_dfin_table_row_n udtr
                    WHERE  udt.table_name     =  'PIT'
                    AND    udtc.table_seq_no  = udt.table_seq_no
                    AND    user_column_name   IN ( 'SUBTRAHEND','MULTIPLIER','APPEND')
                    AND    udtr.table_seq_no  = udt.table_seq_no
                    AND   v_end_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
                 ) a
                 , tb_pay_user_dfin_table_value_n udtv
            WHERE udtv.column_seq_no = a.column_seq_no
            AND   udtv.row_no        = a.row_no
            AND   v_total_income_for_tax BETWEEN to_number(a.lower_limit_critical_value) AND to_number(a.upper_limit_critical_value)
            AND   v_end_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
            GROUP BY a.lower_limit_critical_value
                   , a.upper_limit_critical_value
           ;


          v_pit_cur := round((( v_total_income_for_tax- v_subtrahend ) *v_multiplier + v_append)*v_pit_adjust_rate ) ;

          IF v_adding_up_taxation_flag = 'Y' THEN
              v_pit := v_pit_cur - v_pit_bf;
          ELSE
              v_pit := v_pit_cur;
          END IF;

          p_pit                            := v_pit ;
          p_dependant_deduction            := v_dependant_deduction ;
          p_total_incom_for_tax            := v_total_income_for_tax;

       --   dbms_output.put_line('p_total_incom_for_tax=>'||p_total_incom_for_tax);

        EXCEPTION
            WHEN OTHERS THEN
                p_pit                            := 0 ;
                p_dependant_deduction            := 0 ;
                p_total_incom_for_tax            := 0 ;
        END;
    END IF;
    END IF;



EXCEPTION
    WHEN OTHERS THEN
        p_pit                            := 0 ;
        p_dependant_deduction            := 0 ;
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment allowance2 error ; ' ||SQLERRM);
        v_step := 'User Exception Error(PIT error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_si                                           */
/* Description    :  Social Insurance Calculation                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_si( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) IS

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;
    END LOOP;


--dbms_output.put_line(lgvpay_info_pkg.get_ins_target_flag(p_employee_no, p_period_id));
     /* only for Employees who has satisfied with specific conditions, will be calcuated insurance amount */

    IF lgvpay_info_pkg.get_ins_target_flag(p_employee_no, p_period_id) = 'N' THEN
        RETURN;
    END IF;


    calculation_si( p_employee_no                 => p_employee_no,
                    p_period_id                   => p_period_id,
                    p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                    p_payroll_item_id             => p_payroll_item_id,
                    p_run_type_name               => p_run_type_name,
                    p_user_id                     => p_user_id,
                    p_si_employee                  => v_out_param_rec(0),
                    p_si_employer                  => v_out_param_rec(1) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id     => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


END;




PROCEDURE calculation_si( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_si_employee                 OUT NUMBER,
                          p_si_employer                 OUT NUMBER ) IS

    v_end_yyyymmdd          VARCHAR2(10);
    v_subsidiary_code       VARCHAR2(10);
    v_taxable_earning       NUMBER;
    v_err_buf               VARCHAR2(4000);

    v_si_multiplier_number     NUMBER := 0;
    v_si_multiplier_amount     NUMBER := 0;
    v_si_multiplier_rate_ee    NUMBER := 0;
    v_si_multiplier_rate_er    NUMBER := 0;

    v_si_ee                    NUMBER := 0;
    v_si_er                    NUMBER := 0;
    v_basis_yyyymmdd           VARCHAR2(10);
    v_retire_yyyymmdd          VARCHAR2(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN

    --0) Getting Base yyyymmdd, Subsidiary Code
    SELECT pcp.end_yyyymmdd
          ,pcp.subsidiary_code
    INTO   v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcp
    WHERE  pcp.payroll_calculation_period_id = p_period_id
    ;

    --???? ???? ????? 20?? ???? ?? ??? ?
    SELECT nvl(to_char(em.date_retire,'yyyymmdd'),'47121231')
    INTO   v_retire_yyyymmdd
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;


--dbms_output.put_line('v_basis_yyyymmdd=>'||v_basis_yyyymmdd);

    SELECT least(v_retire_yyyymmdd, substr(v_end_yyyymmdd,1,6)||lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'INS_BASIS_DAY',v_end_yyyymmdd))
    INTO   v_basis_yyyymmdd
    FROM   dual ;
    -- SI Calculation Start
    --1) total Earning base amount for SI select

    /*SELECT nvl(SUM(nvl(aggr_r.calculation_amount,0)),0)
    INTO   v_taxable_earning
    FROM   tb_pay_item_aggr_n aggr
          ,tb_pay_item_aggr_cycle_n cycle
          ,tb_pay_calc_aggr_result_n aggr_r
    WHERE  aggr.payroll_item_aggregate_name   = 'TOTAL_EARNING_FOR_SI'
    AND    cycle.payroll_item_aggregate_id    = aggr.payroll_item_aggregate_id
    AND    cycle.aggregate_cycle_type_code    = 'RUN'
    AND    aggr_r.payroll_item_aggregate_id   = aggr.payroll_item_aggregate_id
    AND    aggr_r.aggregate_cycle_type_code   = cycle.aggregate_cycle_type_code
    AND    aggr_r.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    aggr_r.employee_no                 = p_employee_no
    ;  */

    v_taxable_earning := lgvpay_info_pkg.get_ordinary_wages_for_ins(p_employee_no,v_basis_yyyymmdd);


    --dbms_output.put_line('v_taxable_earning=>'||v_taxable_earning);

    SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'SI_MULIPLIER_NUMBER',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'SI_MULIPLIER_AMOUNT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'SI_MULIPLIER_RATE_EE',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'SI_MULIPLIER_RATE_ER',v_end_yyyymmdd),0)
    INTO   v_si_multiplier_number
          ,v_si_multiplier_amount
          ,v_si_multiplier_rate_ee
          ,v_si_multiplier_rate_er
    FROM dual
    ;


/*??????+????? ??/??/??/????+ ?????? ??/??/??/????(absence days)< 14? ???? OFFER SALARY ? 20*1300000 ?? ??? ???
OFFER SALARY * 8%
??????+????? ??/??/??/????+ ?????? ??/??/??/????(absence days) < 14? ???? OFFER SALARY ?  20*1300000 ?? ??
20*1300000*8%*/


    IF v_taxable_earning <= v_si_multiplier_number* v_si_multiplier_amount THEN
       v_si_ee :=  ROUND(v_taxable_earning * v_si_multiplier_rate_ee);
       v_si_er :=  ROUND(v_taxable_earning * v_si_multiplier_rate_er);
    ELSE
       v_si_ee :=  ROUND(v_si_multiplier_number* v_si_multiplier_amount * v_si_multiplier_rate_ee);
       v_si_er :=  ROUND(v_si_multiplier_number* v_si_multiplier_amount * v_si_multiplier_rate_er);
    END IF;

    --dbms_output.put_line('v_si_ee=>'||v_si_ee);


    p_si_employee                := v_si_ee;
    p_si_employer                := v_si_er;



EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('pit calc err=>'||sqlerrm);
        v_err_buf := 'pit calc err =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_tu                                           */
/* Description    :  Trade Union Calculation                                  */
/*                   employee ??? 0 , enterprize ???
/*                   ENTERPRIZE CONTRIBUTE ? SI??? 0 ? ???
/*                   Offer Salary ? 1300000*20 ?? ??(>) 26000000*2%
/*
/*                   Employee Contribute? si??? 0? ??? offer Salary ?
/*                   1300000*20 ?? ??? ???( <= ) offer salary * 2%

/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_tu( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) IS

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_err_msg              VARCHAR2(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;

    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;
    END LOOP;


    calculation_tu( p_employee_no                 => p_employee_no,
                    p_period_id                   => p_period_id,
                    p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                    p_payroll_item_id             => p_payroll_item_id,
                    p_run_type_name               => p_run_type_name,
                    p_user_id                     => p_user_id,
                    p_tu_employee                  => v_out_param_rec(0),
                    p_tu_employer                  => v_out_param_rec(1) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id     => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_tu_calc => '||SQLERRM;
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_tu                                           */
/* Description    :  Trade Union Calculation                                  */
/*                   employee ??? 0 , enterprize ???
/*                   ENTERPRIZE CONTRIBUTE ? SI??? 0 ? ???
/*                   Offer Salary ? 1300000*20 ?? ??(>) 26000000*2%
/*
/*                   Employee Contribute? si??? 0? ??? offer Salary ?
/*                   1300000*20 ?? ??? ???( <= ) offer salary * 2%
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/11/16    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_tu( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_tu_employee                 OUT NUMBER,
                          p_tu_employer                 OUT NUMBER ) IS

    v_end_yyyymmdd          VARCHAR2(10);
    v_subsidiary_code       VARCHAR2(10);
    v_taxable_earning       NUMBER;

    v_tu_multiplier_number     NUMBER := 0;
    v_tu_multiplier_amount     NUMBER := 0;
    v_tu_multiplier_rate_ee    NUMBER := 0;
    v_tu_multiplier_rate_er    NUMBER := 0;

    v_tu_ee                    NUMBER := 0;
    v_tu_er                    NUMBER := 0;
    v_basis_yyyymmdd           VARCHAR2(10);
    v_err_msg                  VARCHAR2(4000);
    v_retire_yyyymmdd          VARCHAR2(30);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN
    --1) sI ??? ??? ?? ??? ????.
    IF nvl(lgvpay_info_pkg.get_run_result(p_payroll_calculation_exec_id,p_employee_no,'SI_EMPLOYER','PAY_VALUE',v_subsidiary_code),0) = 0 THEN
        RETURN ;
    END IF;
    --0) Getting Base yyyymmdd, Subsidiary Code
    SELECT pcp.end_yyyymmdd
          ,pcp.subsidiary_code
    INTO   v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcp
    WHERE  pcp.payroll_calculation_period_id = p_period_id
    ;

--dbms_output.put_line('v_basis_yyyymmdd=>'||v_basis_yyyymmdd);

    --???? ???? ????? 20?? ???? ?? ??? ?
    SELECT nvl(to_char(em.date_retire,'yyyymmdd'),'47121231')
    INTO   v_retire_yyyymmdd
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;


--dbms_output.put_line('v_basis_yyyymmdd=>'||v_basis_yyyymmdd);

    SELECT least(v_retire_yyyymmdd, substr(v_end_yyyymmdd,1,6)||lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'INS_BASIS_DAY',v_end_yyyymmdd))
    INTO   v_basis_yyyymmdd
    FROM   dual ;

    v_taxable_earning := lgvpay_info_pkg.get_ordinary_wages_for_ins(p_employee_no,v_basis_yyyymmdd);


    --dbms_output.put_line('v_taxable_earning=>'||v_taxable_earning);

    SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'TU_MULIPLIER_NUMBER',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'TU_MULIPLIER_AMOUNT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'TU_MULIPLIER_RATE_EE',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'TU_MULIPLIER_RATE_ER',v_end_yyyymmdd),0)
    INTO   v_tu_multiplier_number
          ,v_tu_multiplier_amount
          ,v_tu_multiplier_rate_ee
          ,v_tu_multiplier_rate_er
    FROM dual
    ;


    IF v_taxable_earning <= v_tu_multiplier_number* v_tu_multiplier_amount THEN
       v_tu_ee :=  ROUND(v_taxable_earning * v_tu_multiplier_rate_ee);
       v_tu_er :=  ROUND(v_taxable_earning * v_tu_multiplier_rate_er);
    ELSE
       v_tu_ee :=  ROUND(v_tu_multiplier_number* v_tu_multiplier_amount * v_tu_multiplier_rate_ee);
       v_tu_er :=  ROUND(v_tu_multiplier_number* v_tu_multiplier_amount * v_tu_multiplier_rate_er);
    END IF;

    p_tu_employee                := v_tu_ee;
    p_tu_employer                := v_tu_er;



EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error : calculation_tu_calc_detail => '||SQLERRM;
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_si                                           */
/* Description    :  Health Insurance Calculation                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_hi( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) IS

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;

    END LOOP;


     /* only for Employees who has satisfied with specific conditions, will be calcuated insurance amount */


    IF lgvpay_info_pkg.get_ins_target_flag(p_employee_no, p_period_id) = 'N' THEN

        RETURN;
    END IF;



    calculation_hi( p_employee_no                 => p_employee_no,
                    p_period_id                   => p_period_id,
                    p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                    p_payroll_item_id             => p_payroll_item_id,
                    p_run_type_name               => p_run_type_name,
                    p_user_id                     => p_user_id,
                    p_hi_employee                  => v_out_param_rec(0),
                    p_hi_employer                  => v_out_param_rec(1) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id     => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


END;




PROCEDURE calculation_hi( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_hi_employee                 OUT NUMBER,
                          p_hi_employer                 OUT NUMBER ) IS

    v_end_yyyymmdd             VARCHAR2(10);
    v_subsidiary_code          VARCHAR2(10);
    v_taxable_earning          NUMBER;
    v_err_buf                  VARCHAR2(4000);


    v_hi_multiplier_number     NUMBER := 0;
    v_hi_multiplier_amount     NUMBER := 0;
    v_hi_multiplier_rate_ee    NUMBER := 0;
    v_hi_multiplier_rate_er    NUMBER := 0;

    v_hi_ee                    NUMBER := 0;
    v_hi_er                    NUMBER := 0;

    v_basis_yyyymmdd           VARCHAR2(10);
    v_retire_yyyymmdd          VARCHAR2(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;



BEGIN

    --0) Getting Base yyyymmdd, Subsidiary Code
    SELECT pcp.end_yyyymmdd
          ,pcp.subsidiary_code
    INTO   v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcp
    WHERE  pcp.payroll_calculation_period_id = p_period_id
    ;





    -- SI Calculation Start
    --1) total Earning base amount for SI select

   /* SELECT nvl(SUM(nvl(aggr_r.calculation_amount,0)),0)
    INTO   v_taxable_earning
    FROM   tb_pay_item_aggr_n aggr
          ,tb_pay_item_aggr_cycle_n cycle
          ,tb_pay_calc_aggr_result_n aggr_r
    WHERE  aggr.payroll_item_aggregate_name   = 'TOTAL_EARNING_FOR_HI'
    AND    cycle.payroll_item_aggregate_id    = aggr.payroll_item_aggregate_id
    AND    cycle.aggregate_cycle_type_code    = 'RUN'
    AND    aggr_r.payroll_item_aggregate_id   = aggr.payroll_item_aggregate_id
    AND    aggr_r.aggregate_cycle_type_code   = cycle.aggregate_cycle_type_code
    AND    aggr_r.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    aggr_r.employee_no                 = p_employee_no
    ; */

    --???? ???? ????? 20?? ???? ?? ??? ?
    SELECT nvl(to_char(em.date_retire,'yyyymmdd'),'47121231')
    INTO   v_retire_yyyymmdd
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;


--dbms_output.put_line('v_basis_yyyymmdd=>'||v_basis_yyyymmdd);

    SELECT least(v_retire_yyyymmdd, substr(v_end_yyyymmdd,1,6)||lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'INS_BASIS_DAY',v_end_yyyymmdd))
    INTO   v_basis_yyyymmdd
    FROM   dual ;

    v_taxable_earning := lgvpay_info_pkg.get_ordinary_wages_for_ins(p_employee_no,v_basis_yyyymmdd);


/*
??????+????? ??/??/??/????+ ?????? ?? /?? /??/????< 14? ???? OFFER SALARY ? 20*1300000 ?? ??? ???
OFFER SALARY * 1.5%
??????+????? ??/??/??/????+ ?????? ?? /?? /??/???? < 14? ???? OFFER SALARY ?  20*1300000 ?? ??
20*1300000* 1.5%*/

    --dbms_output.put_line('v_taxable_earning=>'||v_taxable_earning);

    SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'HI_MULIPLIER_NUMBER',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'HI_MULIPLIER_AMOUNT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'HI_MULIPLIER_RATE_EE',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'HI_MULIPLIER_RATE_ER',v_end_yyyymmdd),0)
    INTO   v_hi_multiplier_number
          ,v_hi_multiplier_amount
          ,v_hi_multiplier_rate_ee
          ,v_hi_multiplier_rate_er
    FROM dual
    ;

/*

--dbms_output.put_line('v_hi_multiplier_number=>'||v_hi_multiplier_number);
DBMS_output.put_line('v_hi_multiplier_amount=>'||v_hi_multiplier_amount);
DBMS_output.put_line('v_hi_multiplier_rate_ee=>'||v_hi_multiplier_rate_ee);
DBMS_output.put_line('v_hi_multiplier_rate_er=>'||v_hi_multiplier_rate_er);
*/


    IF v_taxable_earning <= v_hi_multiplier_number* v_hi_multiplier_amount THEN
       v_hi_ee :=  ROUND(v_taxable_earning * v_hi_multiplier_rate_ee);
       v_hi_er :=  ROUND(v_taxable_earning * v_hi_multiplier_rate_er);
    ELSE
       v_hi_ee :=  ROUND(v_hi_multiplier_number* v_hi_multiplier_amount * v_hi_multiplier_rate_ee);
       v_hi_er :=  ROUND(v_hi_multiplier_number* v_hi_multiplier_amount * v_hi_multiplier_rate_er);

    END IF;


    p_hi_employee                := v_hi_ee;
    p_hi_employer                := v_hi_er;



EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('hi calc err=>'||sqlerrm);
        v_err_buf := 'hi calc err =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;




/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_ui                                           */
/* Description    :  Unemployment Insurance Calculation                       */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_ui( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2 ) IS

    CURSOR c_cur IS
    SELECT param.parameter_value
          , param.payroll_item_id
          , param.payroll_item_detail_detail_id
          , param.pay_calc_rslt_detail_type_code
    FROM    tb_pay_payroll_item_m item
           , tb_pay_calc_period_basis_n p
           , tb_pay_calc_formula_n ff
           , tb_pay_calc_formula_param_n param
    WHERE   item.payroll_item_id                  = p_payroll_item_id
    AND     p.payroll_calculation_period_id       = p_period_id
    AND     p.end_yyyymmdd                    BETWEEN item.start_yyyymmdd AND nvl(item.end_yyyymmdd,'47121231')
    AND     ff.payroll_calculation_formula_id     = item.payroll_calculation_formula_id
    AND     param.payroll_calculation_formula_id  = ff.payroll_calculation_formula_id
    AND     param.parameter_io_type_code = 'OUT'
    ORDER BY param.sort_order_no
    ;


    v_result               VARCHAR2(1000);
    v_result_code          VARCHAR2(1000);
    v_out_param_rec        out_param_res_type;
    v_count                NUMBER :=0;

    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;




BEGIN
    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;




    FOR c IN c_cur
    LOOP
        --Check whether there is a planned item in this period, if exists, don't calculate.
        IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), c.payroll_item_id) = 'Y' THEN
            RETURN ;
        END IF;


    END LOOP;



     /* only for Employees who has satisfied with specific conditions, will be calcuated insurance amount */



    IF lgvpay_info_pkg.get_ins_target_flag(p_employee_no, p_period_id) = 'N' THEN

        RETURN;
    END IF;




    calculation_ui( p_employee_no                 => p_employee_no,
                    p_period_id                   => p_period_id,
                    p_payroll_calculation_exec_id => p_payroll_calculation_exec_id,
                    p_payroll_item_id             => p_payroll_item_id,
                    p_run_type_name               => p_run_type_name,
                    p_user_id                     => p_user_id,
                    p_ui_employee                  => v_out_param_rec(0),
                    p_ui_employer                  => v_out_param_rec(1) ) ;

    v_count :=0;

    FOR c IN c_cur
    LOOP

        v_result      := v_out_param_rec(v_count);
        v_result_code := c.pay_calc_rslt_detail_type_code;

        create_result( p_payroll_calculation_exec_id     => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => c.payroll_item_id,
                         p_payroll_item_detail_id        => c.payroll_item_detail_detail_id  ,
                         p_rslt_detail_type_code         => v_result_code,
                         p_result_value                   => v_result,
                         p_user_id                        => p_user_id,
                         p_period_id                      => p_period_id)   ;



        v_count := v_count+1;
    END LOOP;


END;




PROCEDURE calculation_ui( p_employee_no                 IN VARCHAR2,
                          p_period_id                   IN NUMBER,
                          p_payroll_calculation_exec_id IN NUMBER,
                          p_payroll_item_id             IN NUMBER,
                          p_run_type_name               IN VARCHAR2,
                          p_user_id                     IN VARCHAR2,
                          p_ui_employee                 OUT NUMBER,
                          p_ui_employer                 OUT NUMBER ) IS

    v_end_yyyymmdd             VARCHAR2(10);
    v_subsidiary_code          VARCHAR2(10);
    v_taxable_earning          NUMBER;
    v_err_buf                  VARCHAR2(4000);

    v_ui_multiplier_number     NUMBER := 0;
    v_ui_multiplier_amount     NUMBER := 0;
    v_ui_multiplier_rate_ee    NUMBER := 0;
    v_ui_multiplier_rate_er    NUMBER := 0;

    v_ui_ee                    NUMBER := 0;
    v_ui_er                    NUMBER := 0;

    v_basis_yyyymmdd           VARCHAR2(10);
    v_retire_yyyymmdd          VARCHAR2(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN

    --0) Getting Base yyyymmdd, Subsidiary Code
    SELECT pcp.end_yyyymmdd
          ,pcp.subsidiary_code
    INTO   v_end_yyyymmdd
          ,v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n pcp
    WHERE  pcp.payroll_calculation_period_id = p_period_id
    ;




    -- SI Calculation Start
    --1) total Earning base amount for UI select

/*    SELECT nvl(SUM(nvl(aggr_r.calculation_amount,0)),0)
    INTO   v_taxable_earning
    FROM   tb_pay_item_aggr_n aggr
          ,tb_pay_item_aggr_cycle_n cycle
          ,tb_pay_calc_aggr_result_n aggr_r
    WHERE  aggr.payroll_item_aggregate_name   = 'TOTAL_EARNING_FOR_UI'
    AND    cycle.payroll_item_aggregate_id    = aggr.payroll_item_aggregate_id
    AND    cycle.aggregate_cycle_type_code    = 'RUN'
    AND    aggr_r.payroll_item_aggregate_id   = aggr.payroll_item_aggregate_id
    AND    aggr_r.aggregate_cycle_type_code   = cycle.aggregate_cycle_type_code
    AND    aggr_r.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    aggr_r.employee_no                 = p_employee_no
    ;  */

    --???? ???? ????? 20?? ???? ?? ??? ?
    SELECT nvl(to_char(em.date_retire,'yyyymmdd'),'47121231')
    INTO   v_retire_yyyymmdd
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;


--dbms_output.put_line('v_basis_yyyymmdd=>'||v_basis_yyyymmdd);

    SELECT least(v_retire_yyyymmdd, substr(v_end_yyyymmdd,1,6)||lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'INS_BASIS_DAY',v_end_yyyymmdd))
    INTO   v_basis_yyyymmdd
    FROM   dual ;

    v_taxable_earning := lgvpay_info_pkg.get_ordinary_wages_for_ins(p_employee_no,v_basis_yyyymmdd);


    --dbms_output.put_line('v_taxable_earning=>'||v_taxable_earning);


/*??????+????? ??/??/??/????+ ?????? ??/??/??/????< 14? ???? OFFER SALARY ? 20*3750000 ?? ??? ???
OFFER SALARY * 1%


??????+????? ??/??/??/????+ ?????? ??/??/??/???? < 14? ???? OFFER SALARY ?  20*3750000 ?? ??
20*3750000* 1%*/



    SELECT nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'UI_MULIPLIER_NUMBER',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'UI_MULIPLIER_AMOUNT',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'UI_MULIPLIER_RATE_EE',v_end_yyyymmdd),0),
           nvl(lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'UI_MULIPLIER_RATE_ER',v_end_yyyymmdd),0)
    INTO   v_ui_multiplier_number
          ,v_ui_multiplier_amount
          ,v_ui_multiplier_rate_ee
          ,v_ui_multiplier_rate_er
    FROM dual
    ;



    IF v_taxable_earning <= v_ui_multiplier_number* v_ui_multiplier_amount THEN
       v_ui_ee :=  ROUND(v_taxable_earning * v_ui_multiplier_rate_ee);
       v_ui_er :=  ROUND(v_taxable_earning * v_ui_multiplier_rate_er);
    ELSE
       v_ui_ee :=  ROUND(v_ui_multiplier_number* v_ui_multiplier_amount * v_ui_multiplier_rate_ee);
       v_ui_er :=  ROUND(v_ui_multiplier_number* v_ui_multiplier_amount * v_ui_multiplier_rate_er);

    END IF;

    p_ui_employee                := v_ui_ee;
    p_ui_employer                := v_ui_er;



EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('ui calc err=>'||sqlerrm);
        v_err_buf := 'ui calc err =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_housing_allw                                 */
/* Description    :  Housing Allowance Calucation                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20   SonSuyang         Initial Release                             */
/* 2018/10/01   KimTaehyun        Separation Retroactive Payroll              */
/******************************************************************************/
/*
PROCEDURE calculation_housing_allw( p_employee_no                 IN VARCHAR2,
                                    p_period_id                   IN NUMBER,
                                    p_payroll_calculation_exec_id IN NUMBER,
                                    p_payroll_item_id             IN NUMBER,
                                    p_run_type_name               IN VARCHAR2,
                                    p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_base_yyyymmdd        VARCHAR(10);
    v_subsidiary_code      VARCHAR2(30);
    v_return               NUMBER;
    v_input_value_id       NUMBER;

    v_calc_base_amount     NUMBER := 0;
    v_total_target_earning NUMBER := 0;
    v_rate                 NUMBER := 0;
    v_allw_for_tax         NUMBER := 0;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

     v_procedure_name := 'calculation_housing_allw';

     --????? ?? base amount? ?? ??? ??? ????
      --  ???? ?? ??? ????? ? ????? 15% ? ?????? ?? .


    --1) ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          , period.subsidiary_code
          --< 20181001 KTH Start Add
          , period.payroll_calc_period_value
          -->
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
          --< 20181001 KTH Start Add
          ,v_base_yyyymmdd
          -->
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;
--dbms_output.put_line('housing allwo ->  1');

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;

--dbms_output.put_line('housing allwo ->  2');

    INSERT INTO tb_pay_detail_calc_t a
                (payroll_calculation_exec_id
                ,employee_no
                ,payroll_item_id
                ,basis_start_date
                ,basis_end_date
                ,payment_base_amount
                ,ordinary_wages_base_amount
                ,increase_and_decrease_rate
                ,creation_date
                ,creation_user_id
                )
    SELECT p_payroll_calculation_exec_id
          , p_employee_no
          ,p_payroll_item_id
          ,min_ymd
          ,max_ymd
          ,base_value
          ,base_value
          ,1
          ,SYSDATE
          ,p_user_id
    FROM (
            SELECT ymd min_ymd
                  , nvl(LEAD(ymd) OVER(ORDER BY ymd) -1 ,to_date(v_end_yyyymmdd,'yyyymmdd')) max_ymd
                  , base_value
            FROM (
                   SELECT ymd, base_value, bef_value, CASE WHEN base_value -bef_value = 0 THEN 1 ELSE 2 END diff
                   FROM (
                           SELECT ymd, base_value, LAG(base_value, 1,0) over(ORDER BY ymd)  bef_value
                           FROM (
                                   SELECT  ymd
                                         , nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, ymd, p_payroll_item_id, 'BASE_AMOUNT' ),0)base_value
                                   FROM  ( SELECT to_date(v_start_yyyymmdd,'yyyymmdd') - 1 + ROWNUM ymd
                                           FROM DUAL CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd') - to_date(v_start_yyyymmdd,'yyyymmdd') + 1) days
                                         ,  emp_assig          ass
                                   WHERE ass.employee_number= p_employee_no
                                   AND   to_char(ymd,'yyyymmdd') BETWEEN to_char(ass.assignment_start_date,'yyyymmdd') AND ass.attribute1
                                 )
                         )
                   )
             WHERE  diff = 2
           )

    ;


    SELECT nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id, 'BASE_AMOUNT' ),0)
    INTO   v_calc_base_amount
    FROM   dual;


    v_calc_base_amount := calculate_pay(p_employee_no                => p_employee_no
                                       ,p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                                       ,p_payroll_item_id             => p_payroll_item_id
                                       ,p_period_id                   => p_period_id
                                       ,p_run_type_name               => p_run_type_name
                                       ,p_user_id                     => p_user_id
                                       );


    --dbms_output.put_line('housing allwo ->  v_calc_base_amount=>'||v_calc_base_amount);

   -- ??? ??? ?? ??? ???? ??? ????? ? ??- ?? ? ??? 15% ? ?????? ??.
   -- ??? ?? ??? ??? ????? ??? ?? return ??.


   --< 20181001 KTH Start Add
   --v_total_target_earning := lgvpay_aggr_pkg.get_aggr_result('TOTAL_EARNING','RUN',p_payroll_calculation_exec_id,p_employee_no)
   --                          - lgvpay_aggr_pkg.get_aggr_result('VOL_DEDUCTIONS','RUN',p_payroll_calculation_exec_id,p_employee_no)
   v_total_target_earning := lgvpay_aggr_pkg.get_aggr_result('TOTAL_EARNING','RUN',p_payroll_calculation_exec_id,p_employee_no,v_base_yyyymmdd)
                             - lgvpay_aggr_pkg.get_aggr_result('VOL_DEDUCTIONS','RUN',p_payroll_calculation_exec_id,p_employee_no,v_base_yyyymmdd)
   -->
                            -- + v_calc_base_amount

                             ;


   -- dbms_output.put_line('housing allwo ->  v_total_target_earning=>'||v_total_target_earning);

    SELECT lgvpay_common_pkg.get_calc_var_value( v_subsidiary_code,'HOUSING_ALLW_RATE',v_end_yyyymmdd)
    INTO   v_rate
    FROM   dual ;

    v_allw_for_tax := round( v_total_target_earning*v_rate);

    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;

    -- ?? BASE AMOUNT ???? ??? ??? ???? ??? ???? ??? ????
    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_calc_base_amount,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




    --2) ALLOW_FOR_TAX input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'ALLOW_FOR_TAX'
    ;

    --?? BASE AMOUNT ???? ??? ??? ???? ??? ???? ??? ???? 
    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_allw_for_tax,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation adjustment1 allowance error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation adjustment1 allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(adjustment1 error)';
        lgcom_error_log_pkg.set_comment_text(v_step);
        lgcom_error_log_pkg.set_error_code(NULL);
        lgcom_error_log_pkg.set_error_explanation_text(v_err_buf);
        lgcom_error_log_pkg.error_prc(v_module_code, v_procedure_name);

END;

*/


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_transport_allw                               */
/* Description    :  Transport Allowance Calcuation                           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/******************************************************************************/
PROCEDURE calculation_transport_allw( p_employee_no                 IN VARCHAR2,
                                      p_period_id                   IN NUMBER,
                                      p_payroll_calculation_exec_id IN NUMBER,
                                      p_payroll_item_id             IN NUMBER,
                                      p_run_type_name               IN VARCHAR2,
                                      p_user_id                     IN VARCHAR2 ) IS
                                      
    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????                                    
                                      
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_subsidiary_code      VARCHAR2(30);
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_yyyymm               tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;

    v_unpaid_days                  NUMBER := 0;
    v_paid_days                    NUMBER := 0;
    v_perfect_attendance_days      NUMBER := 0;
    v_basis_amount                 NUMBER := 0;
    v_calc_basis_amount            NUMBER := 0;
    v_deduction_amount             NUMBER := 0;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN

--dbms_output.put_line('============transport allowance=============>');



    /*-- Transport Allowance ? ?? 400000 ? ??? ???, ???,???? ???? ??
    -- ?? ?? ?? ?? ??? ??? ??? ??? ???? ????.
    -- ??) 1. ???? ? ???? : 23?
    --       2. ?? 1?
             3. ?? ?? ???? : 100000
             4. ???? : 400000

             ?? ? = 400000*22/23 - 100000 */

     v_procedure_name := 'calculation_transport_allw';


    --1) ???? ????

    SELECT period.start_yyyymmdd
          , period.end_yyyymmdd
          , period.subsidiary_code
          , period.payroll_calc_period_value
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
          ,v_yyyymm
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;


    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;


   --  ??? ?? + ????
    SELECT COUNT(*)
    INTO   v_paid_days
    FROM   tb_att_result_n  arn
         , tb_att_code_c acc
         , (
             SELECT to_date(v_start_yyyymmdd,'yyyymmdd')-1+ROWNUM ymd
             FROM  dual
             CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd')- to_date(v_start_yyyymmdd,'yyyymmdd')+1
           ) days
    WHERE arn.employee_no                 = p_employee_no
    AND   arn.time_and_attendance_yyyymm  = v_yyyymm
    AND   arn.time_and_attendance_date    = days.ymd
    AND   acc.subsidiary_code             =  v_subsidiary_code
    AND   acc.time_and_attendance_code = arn.time_and_attendance_code
   -- AND   ( acc.unpaid_days > 0 OR acc.time_and_attendance_code = 'NN')  -- ???? ????? ???? ? ???? ??.
    AND   ( acc.attendance_days > 0  OR acc.paid_days > 0)
    ;




    /*------TaiDD------Start
    --???? ? ????
    SELECT acn.perfect_attendance_days
    INTO   v_perfect_attendance_days
    FROM   tb_att_close_n acn
    WHERE  acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
    ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End

/*    IF (v_perfect_attendance_days-v_unpaid_days) = 0 THEN
        RETURN ;
    END IF;*/
    IF v_paid_days = 0 THEN
        return;
    END IF;

--dbms_output.put_line('v_working_days=>'||v_working_days);

--dbms_output.put_line('v_perfect_attendance_days=>'||v_perfect_attendance_days);



    SELECT nvl(lgvpay_common_pkg.get_calc_var_value( v_subsidiary_code,'TRANSPORT_ALLOWANCE',v_end_yyyymmdd),0)
    INTO   v_basis_amount
    FROM   dual ;

--    dbms_output.put_line('v_basis_amount=>'||v_basis_amount);


    --v_calc_basis_amount := round(v_basis_amount *(v_perfect_attendance_days - v_unpaid_days)/v_perfect_attendance_days      );
    /*----------TaiDD---------Start
    v_calc_basis_amount := round(v_basis_amount *(v_paid_days)/v_perfect_attendance_days      );
    */
    v_calc_basis_amount := round(v_basis_amount *(v_paid_days)/v_total_period);
    -------------TaiDD----------End
    
--    dbms_output.put_line('v_calc_basis_amount=>'||v_calc_basis_amount);
    --???? ????
    SELECT lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd') ,p_payroll_item_id,'DEDUCTION_AMOUNT')
    INTO   v_deduction_amount
    FROM   dual;

    /* ??? 0?? ??? 0?? ????. */

    v_return  := greatest(v_calc_basis_amount - nvl(v_deduction_amount,0),0)   ;


--dbms_output.put_line('v_return=>'||v_return);


    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation calculation_transport_allw error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation_transport allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(calculation_transport_allw error)';
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_buf );

END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_attendance_incentive                         */
/* Description    :  Attendance Incentive Calcuation                          */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/20    SonSuyang       Initial Release                              */
/* 2019/03/02    TaiDD      Add the PH code in the count for perfect working days            */
/******************************************************************************/
PROCEDURE calculation_att_incentive( p_employee_no                 IN VARCHAR2,
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 ) IS
                                     
    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????                                   
                                     
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_subsidiary_code      VARCHAR2(30);
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_yyyymm               tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;

    v_working_days                 NUMBER := 0;
    v_perfect_attendance_days      NUMBER := 0;
    v_basis_amount                 NUMBER := 0;
    v_calc_basis_amount            NUMBER := 0;
    v_deduction_amount             NUMBER := 0;
    v_goout_tardy_flag             VARCHAR2(1) := 'N';

    v_emp_cat             emp_master.assignment_category%TYPE;

    v_err_buf              VARCHAR(4000);
    v_chec_flag            VARCHAR2(10);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

--dbms_output.put_line('============Attendance Incentive=============>');


    /*-- Attendance Incentive ? ??? ??/??/??/????? ??? ?? ??? ??? ???? 200000 ????.*/

     v_procedure_name := 'calculation_attendance_incentive';


    --1) ???? / ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          , period.subsidiary_code
          , period.payroll_calc_period_value
          , em.assignment_category
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
          ,v_yyyymm
          ,v_emp_cat
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    -- ???? ???
    IF v_emp_cat <> 'LGD_LW' THEN
        RETURN;
    END IF;

    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;

    -- attendnace incentive? ?? ?????? ??
    -- ?? ??? ???? ??? 5? ???? ? ????
    -- ?? ??? ?? ??? attendance incentive ? ???? ??
    -- ?? ?? ???? ?? ?? ??? ??? ?? ??? ?????? ????
    -- attendance incentive ? ???
    -- ??? attendance incentive ??? attendnace_flag ?? ?? ????
    -- ??? ???? ?????

    v_chec_flag := lgvpay_common_pkg.get_planned_item_value(p_employee_no
                                                           , to_datE(v_end_yyyymmdd,'yyyymmdd')
                                                           ,p_payroll_item_id => p_payroll_item_id
                                                           ,p_item_detail_name => 'ATTENCANCE_FLAG');



    IF v_chec_flag = 'Y' THEN -->  Y? ???? ???? ????  v_goout_tardy_flag := 'N'??
        v_goout_tardy_flag := 'N';
    ELSIF v_chec_flag = 'N' THEN -->  Y? ???? ?? ???? ????  v_goout_tardy_flag := 'Y'??
        v_goout_tardy_flag := 'Y';
        v_return := 0;
        RETURN ;
    ELSE
        -- ??? ?? ???
        -- ???? ?? /??? ??? ??
        BEGIN
        SELECT 'Y'
        INTO   v_goout_tardy_flag
        FROM   dual
        WHERE EXISTS   (   SELECT 1
                            FROM   tb_att_result_n  arn
                            WHERE arn.employee_no                 = p_employee_no
                            AND   arn.time_and_attendance_yyyymm  = v_yyyymm
                            AND   ( arn.going_out_hours >0 OR arn.tardy_hours > 0 or  arn.early_leave_hours > 0 )
                         )
        ;
        EXCEPTION
            WHEN OTHERS THEN
                v_goout_tardy_flag := 'N';
        END;

       -- dbms_output.put_line('v_goout_tardy_flag=>'||v_goout_tardy_flag);

        IF v_goout_tardy_flag = 'Y' THEN
            v_return := 0;
            RETURN ;
        END IF;

    END IF;


   --  ??? ?? + ????
    /*SELECT COUNT(*)
    INTO   v_working_days
    FROM   tb_att_result_n  arn
         , tb_att_code_c acc
         , (
             SELECT to_date(v_start_yyyymmdd,'yyyymmdd')-1+ROWNUM ymd
             FROM  dual
             CONNECT BY LEVEL <= to_date(v_end_yyyymmdd,'yyyymmdd')- to_date(v_start_yyyymmdd,'yyyymmdd')+1
           ) days
    WHERE arn.employee_no                 = p_employee_no
    AND   arn.time_and_attendance_yyyymm  = v_yyyymm
    AND   arn.time_and_attendance_date    = days.ymd
    AND   acc.subsidiary_code             =  v_subsidiary_code
    AND   acc.time_and_attendance_code    = arn.time_and_attendance_code
    AND   acc.time_and_attendance_code    <> 'SP' -- ??? ????? ??
    AND   ( acc.paid_days > 0             OR acc.attendance_days > 0)  -- ???? ????? ???( ?????, ???? )
    ;*/



    SELECT NVL(SUM(NVL(ac.attendance_days, 0) + NVL(ac.paid_days, 0)),0)
    INTO   v_working_days
    FROM   tb_att_result_n ar
          ,tb_att_code_c   ac
    WHERE  ar.employee_no                = p_employee_no
    AND    ar.time_and_attendance_yyyymm = v_yyyymm
    AND    ar.subsidiary_code            = v_subsidiary_code
    AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
    AND    ar.subsidiary_code            = ac.subsidiary_code
    AND    ac.time_and_attendance_code   NOT IN ( 'PS', 'US' )  /* ???? */
    ;



    /*----------TaiDD---------Start
    --???? ? ????
    SELECT acn.perfect_attendance_days
    INTO   v_perfect_attendance_days
    FROM   tb_att_close_n acn
    WHERE  acn.time_and_attendance_yyyymm = v_yyyymm
    ;
    */
    ------Get the perfect hours-------
        /*---------TaiDD-20190302-----
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,0)) perfect_work_days,
               /*SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *
                   CASE
                     WHEN b.shift_type_code LIKE '3%' THEN
                       9.5
                     ELSE
                       8
                   END)*/
               --SUM(DECODE(b.time_and_attendance_code,'NW',1,0) *                   --TaiDD-20190302                                
               --NVL(b.work_hours,0)) perfect_work_hours                                      --TaiDD-20190302                                                    
        SELECT SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days,            
               SUM(lgvpay_info_pkg.get_work_hours(v_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
                                  b.shift_type_code, b.work_hours, 'pay_perfect_hours')) --HMT_20210323
               --DECODE(SUBSTR(b.shift_type_code,1,1),'3',9.5,8)) perfect_work_hours  --HMT_20210323
        ----------------End-20190302--------*/
        INTO   v_total_period,
               v_total_time
        FROM   tb_att_result_n r,
               tb_att_base_bas_n b
        WHERE  r.time_and_attendance_yyyymm = b.time_and_attendance_yyyymm
        AND    r.time_and_attendance_date = b.time_and_attendance_date
        AND    r.shift_type_code = b.shift_type_code
        AND    r.employee_no = p_employee_no
        AND    r.subsidiary_code = v_subsidiary_code
        AND    r.time_and_attendance_yyyymm = v_yyyymm;
      ----------TaiDD------End
    
--dbms_output.put_line('v_working_days=>'||v_working_days);

--dbms_output.put_line('v_perfect_attendance_days=>'||v_perfect_attendance_days);



    SELECT nvl(lgvpay_common_pkg.get_calc_var_value( v_subsidiary_code,'ATTENDANCE_INCENTIVE',v_end_yyyymmdd),0)
    INTO   v_basis_amount
    FROM   dual ;

    -- ??? ????? ? ????? ??? ????? ?? ?? ?? ???
    /*----------TaiDD---------Start
    IF v_working_days = v_perfect_attendance_days THEN
    */
    IF v_working_days = v_total_period THEN
    ------------TaiDD----------End
        v_return := v_basis_amount;
    ELSE
        v_return := 0;
    END IF;

    --dbms_output.put_line('v_return=>'||v_return);


    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation calculation_att_incentive error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation_att_incentive allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(calculation_att_incentive error)';
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_buf );

END;



/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : create_result                                            */
/* Description     : Insert tb_pay_calc_result_n                              */
/*                                                                            */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/* 2018/09/14    KimTaehyun      Retroactive Payroll Calculate                */
/******************************************************************************/
   PROCEDURE create_result( p_payroll_calculation_exec_id    IN NUMBER,
                         p_employee_no                    IN VARCHAR2,
                         p_payroll_item_id                IN NUMBER,
                         p_payroll_item_detail_id         IN NUMBER  ,
                         p_rslt_detail_type_code          IN VARCHAR2,
                         p_result_value                   IN VARCHAR2,
                         p_user_id                        IN VARCHAR2,
                         p_period_id                      IN NUMBER) IS

    v_subsidiary_code           VARCHAR2(100);
    v_err_buf                   VARCHAR2(4000);

    v_module_code CONSTANT      lgcom_error_log.module_code%TYPE                          := 'LGVPAY';
    v_program_id  CONSTANT      lgcom_error_log.program_id%TYPE                           := '';
    v_step                      lgcom_error_log.error_explanation_text%TYPE               := NULL;
    v_procedure_name            lgcom_error_log.program_id%TYPE                           := NULL;
    v_retroactive_flag          tb_pay_calc_exec_n.retroactive_flag%TYPE                  := NULL;
    v_payroll_calc_period_value tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE := NULL;

BEGIN
    -- dbms_output.put_line('create-result=>'||'p_payroll_item_id=.'||p_payroll_item_id||'start=.'|| to_char(SYSDATE,'yyyymmdd hh24:mi:ss'));

    --< 20180914 KTH Start Add
    -- Seperation Actual or Retroactive
    SELECT NVL(a.retroactive_flag,'N')
    INTO   v_retroactive_flag
    FROM   tb_pay_calc_exec_n a
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    ;
    -->

    IF v_retroactive_flag = 'N' THEN

        INSERT INTO tb_pay_calc_result_n
        (payroll_calculation_result_id
          ,payroll_calculation_exec_id
          ,employee_no
          ,payroll_item_id
          ,payroll_item_detail_detail_id
          ,pay_calc_rslt_detail_type_code
          ,result_value
          ,creation_date
          ,creation_user_id
          )
        SELECT sq_tb_pay_calc_result_n.nextval
              ,p_payroll_calculation_exec_id
              ,p_employee_no
              ,p_payroll_item_id
              ,p_payroll_item_detail_id
              ,p_rslt_detail_type_code
              ,p_result_value
              ,SYSDATE
              ,p_user_id
        FROM dual ;

    --< 20180914 KTH Start Add
    --Retroactive Payroll Calculate
    ELSE

        SELECT pcpb.payroll_calc_period_value
        INTO   v_payroll_calc_period_value
        FROM   tb_pay_calc_period_basis_n pcpb
        WHERE  pcpb.payroll_calculation_period_id = p_period_id;

        INSERT INTO tb_retro_pay_calc_result_n
        (retroactive_pay_calc_result_id
          ,payroll_calculation_exec_id
          ,employee_no
          ,payroll_item_id
          ,payroll_item_detail_detail_id
          ,pay_calc_rslt_detail_type_code
          ,result_value
          ,retroactive_pay_target_yyyymm
          ,creation_date
          ,creation_user_id
          )
        SELECT sq_tb_retro_pay_calc_result_n.nextval
              ,p_payroll_calculation_exec_id
              ,p_employee_no
              ,p_payroll_item_id
              ,p_payroll_item_detail_id
              ,p_rslt_detail_type_code
              ,p_result_value
              ,v_payroll_calc_period_value
              ,SYSDATE
              ,p_user_id
        FROM dual ;

    END IF;
    -->

    SELECT p.subsidiary_code
    INTO   v_subsidiary_code
    FROM   tb_pay_calc_period_basis_n p
    WHERE  p.payroll_calculation_period_id = p_period_id
    ;

    --???? ??

    lgvpay_aggr_pkg.calculation_aggr(p_period_id                    => p_period_id
                                    ,p_subsidiary_code              => v_subsidiary_code
                                    ,p_payroll_calculation_exec_id  => p_payroll_calculation_exec_id
                                    ,p_employee_no                  => p_employee_no
                                    ,p_user_id                      => p_user_id
                                    ,p_payroll_item_id              => p_payroll_item_id);

    COMMIT;

    -- dbms_output.put_line('create-result=>'||'p_payroll_item_id=.'||p_payroll_item_id||'end=.'|| to_char(SYSDATE,'yyyymmdd hh24:mi:ss'));

EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line(  'create_result error  : '||SQLERRM );
        v_err_buf := 'create_result err =>'||substr(SQLERRM,1,1000);
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no,v_err_buf  );

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_ordinary_wage                                        */
/* Description    :  sum of Base salary + Fixed Allowance on specific days    */
/*                   OT Allowance is calcuated by this result                 */
/*                   on specific days, sum of Fixed flag = 'Y' item results   */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/28    SonSuyang       Initial Release                              */
/******************************************************************************/
FUNCTION get_ordinary_wage(p_payroll_calculation_exec_id    IN NUMBER,
                           p_employee_no                    IN VARCHAR2,
                           p_basis_yyyymmdd                 IN VARCHAR2 ) RETURN NUMBER IS
    v_err_msg VARCHAR2(4000);
    v_return  NUMBER :=0;
BEGIN
    SELECT SUM( NVL( pdct.ordinary_wages_base_amount,pdct.payment_base_amount))
    INTO   v_return
    FROM   tb_pay_detail_calc_t pdct
    WHERE  pdct.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    AND    pdct.employee_no                = p_employee_no
    AND    pdct.payroll_item_id            IN ( SELECT ppi.payroll_item_id
                                                FROM   tb_pay_payroll_item_m ppi
                                                      ,tb_pay_calc_mthd_n    pcm
                                                WHERE  pcm.payroll_item_id          = ppi.payroll_item_id
                                                AND    pcm.payroll_calc_method_code = 'FIXED_FLAG'
                                                AND    pcm.payroll_apply_flag       = 'Y'
                                                AND    p_basis_yyyymmdd             BETWEEN ppi.start_yyyymmdd AND nvl(ppi.end_yyyymmdd,'47121231'))
    AND  to_date(p_basis_yyyymmdd ,'yyyymmdd') BETWEEN pdct.basis_start_date AND pdct.basis_end_date
    ;

    RETURN v_return;
EXCEPTION
    WHEN OTHERS THEN
        v_return := 0;
        v_err_msg := 'Error : get_ordinary_wage => '||SQLERRM;
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_msg );
        RETURN v_return;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_mens_allowance                               */
/* Description    :  only for women( not pregnant), they have to receive 1.5 hr allownace
/*                  ( base salary + fixed  )/192 *1.5
/*                    basis date : end of month  or retirement date
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018/04/02    SonSuyang       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_mens_allowance( p_employee_no                 IN VARCHAR2,
                                     p_period_id                   IN NUMBER,
                                     p_payroll_calculation_exec_id IN NUMBER,
                                     p_payroll_item_id             IN NUMBER,
                                     p_run_type_name               IN VARCHAR2,
                                     p_user_id                     IN VARCHAR2 ) IS
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_subsidiary_code      VARCHAR2(30);
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_yyyymm               tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;

    v_ordinary_wage        NUMBER := 0;

    v_gender               emp_master.gender%TYPE;

    v_err_buf              VARCHAR(4000);
    v_calc_rate            NUMBER;

    v_basis_working_hours    NUMBER := 0;
    v_rate                   NUMBER := 0;

    v_total_unpaid_days      NUMBER := 0;
    v_total_working_days     NUMBER := 0;


    v_period_start_yyyymmdd  VARCHAR2(30);
    v_period_end_yyyymmdd    VARCHAR2(30);
    v_retire_date            DATE;

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;

BEGIN

     v_procedure_name := 'calculation_mens_allowance';


    --1) ???? / ???? ????

    SELECT greatest(period.start_yyyymmdd , to_char(em.date_hire_subsidiary,'YYYYMMDD'))
          --,period.end_yyyymmdd
          ,CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
                THEN to_char(em.date_retire,'yyyymmdd')
                ELSE period.end_yyyymmdd
           END
          , period.subsidiary_code
          , period.payroll_calc_period_value
          , em.gender
          , period.start_yyyymmdd
          , period.end_yyyymmdd
          , em.date_retire
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
          ,v_yyyymm
          ,v_gender
          ,v_period_start_yyyymmdd
          ,v_period_end_yyyymmdd
          ,v_retire_date
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;



    SELECT to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'BASIS_TOT_WK_HOURS',v_end_yyyymmdd))
          ,to_number( lgvpay_common_pkg.get_calc_var_value(v_subsidiary_code,'OT150_RATE',v_end_yyyymmdd))
    INTO   v_basis_working_hours
          ,v_rate
    FROM   dual
    ;

    /*-----------------TaiDD-------------Start--------------
    SELECT COUNT(*)
    INTO  v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
          ,tb_att_calendar_n cal
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    res.time_and_attendance_date   = cal.time_and_attendance_date
    AND    res.subsidiary_code            = cal.subsidiary_code
    AND    ((cal.holiday_flag = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB' )) OR  -- 'UF', 'UL', 'UM', 'AB' ? ??? ???? ?? ??
            ((cal.holiday_flag = 'N' OR cal.time_and_attendance_code  = 'PH')        --US? ???? ???? ???? ????? ?? ???
                                    AND cod.time_and_attendance_code IN ( 'US'             ))
           )
    */       
    SELECT COUNT(*)
    INTO  v_total_unpaid_days
    FROM   tb_att_result_n   res
          ,tb_att_code_c     cod
    WHERE  res.employee_no                = p_employee_no
    AND    res.time_and_attendance_yyyymm = v_yyyymm
    AND    res.subsidiary_code            = cod.subsidiary_code
    AND    res.time_and_attendance_code   = cod.time_and_attendance_code
    AND    lgvatt_common_pkg.get_holiday_flag(v_subsidiary_code, res.shift_type_code, res.time_and_attendance_date) = 'N' AND cod.time_and_attendance_code IN ( 'UF', 'UL', 'UM', 'AB', 'US' )  -- 'UF', 'UL', 'UM', 'AB', 'US''? ??? ???? ?? ??
              
    ;
    ---------------------TaiDD---------------End
    
    SELECT COUNT(*)
    INTO   v_total_working_days
    FROM   tb_att_result_n  arn
          ,tb_att_code_c acc
    WHERE arn.employee_no                = p_employee_no
    AND   arn.time_and_attendance_yyyymm = v_yyyymm
    AND   arn.time_and_attendance_code   = acc.time_and_attendance_code
    AND   ( acc.paid_days  > 0 OR acc.attendance_days > 0);


    /* If working days = 0 and Unpaid days is not 0 then return 0 */
    IF v_total_working_days = 0  AND  v_total_unpaid_days > 0 THEN
        RETURN;
    END IF;


    -- ONLY FOR WOMEN
    IF v_gender <> 'F' THEN
        RETURN;
    END IF;


    -- if employee is retired in this month, she doesn't receive This ALlowance.
    IF v_retire_date IS NOT NULL AND v_retire_date BETWEEN to_date(v_period_start_yyyymmdd,'yyyymmdd') AND to_date(v_period_end_yyyymmdd,'yyyymmdd') THEN
        RETURN;
    END IF;


    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;



    --IF Women Employe is Pregnant, she must not recevie this allowance
    -- at this time, you have to upload to 'N'
    v_calc_rate := lgvpay_common_pkg.get_planned_item_value(p_employee_no
                                                           , to_datE(v_end_yyyymmdd,'yyyymmdd')
                                                           ,p_payroll_item_id => p_payroll_item_id
                                                           ,p_item_detail_name => 'CALCULATION_RATE');



    IF v_calc_rate = 0 THEN -->  "0" means that she is pregnant, so she doesn't have to recieve this amount
        v_return := 0;
        RETURN ;
    ELSE
        -- ordinary_wage/192*1.5
        v_ordinary_wage := get_ordinary_wage(p_payroll_calculation_exec_id => p_payroll_calculation_exec_id
                                           , p_employee_no                => p_employee_no
                                           , p_basis_yyyymmdd             => v_end_yyyymmdd );


        v_return  := round(v_ordinary_wage/v_basis_working_hours*nvl(v_calc_rate,v_rate));
    END IF;




    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation calculation_att_incentive error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation_att_incentive allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(calculation_mens_allowance error)';
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_buf );

END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2025                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : calculation_child_incentive                               */
/* Description    :  Child Incentive Calcuation                           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description      */
/*                ---------------------------------------------------------   */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date         In Charge         Description                                 */
/* ------------ -------- -------------------------------                      */
/* 2025/05/13    ThuyHM       Initial Release                              */
/******************************************************************************/
PROCEDURE calculation_child_incentive( p_employee_no                 IN VARCHAR2,
                                      p_period_id                   IN NUMBER,
                                      p_payroll_calculation_exec_id IN NUMBER,
                                      p_payroll_item_id             IN NUMBER,
                                      p_run_type_name               IN VARCHAR2,
                                      p_user_id                     IN VARCHAR2 ) IS
                                      
    v_total_period     NUMBER; --?????  
    v_total_time       NUMBER; --?????                                    
                                      
    v_start_yyyymmdd       VARCHAR(10);
    v_end_yyyymmdd         VARCHAR(10);
    v_subsidiary_code      VARCHAR2(30);
    v_return               NUMBER;
    v_input_value_id       NUMBER;
    v_yyyymm               tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;

    v_pay_value                    NUMBER := 0;
    v_basis_amount                 NUMBER := 0;
    v_calc_basis_amount            NUMBER := 0;
    v_child_count                  NUMBER := 0;

    v_err_buf              VARCHAR(4000);

    v_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    v_program_id  CONSTANT lgcom_error_log.program_id%TYPE  := '';
    v_step lgcom_error_log.error_explanation_text%TYPE      := NULL;
    v_procedure_name       lgcom_error_log.program_id%TYPE  := NULL;


BEGIN

--dbms_output.put_line('============transport allowance=============>');


     v_procedure_name := 'calculation_child_incentive';


    --1) ???? ????

    SELECT period.start_yyyymmdd
          , period.end_yyyymmdd
          , period.subsidiary_code
          , period.payroll_calc_period_value
    INTO   v_start_yyyymmdd
          ,v_end_yyyymmdd
          ,v_subsidiary_code
          ,v_yyyymm
    FROM   tb_pay_calc_period_basis_n period
          ,emp_master em
          ,emp_assig  ass
    WHERE  period.payroll_calculation_period_id = p_period_id
    AND    em.employee_number                   = p_employee_no
    AND    ass.employee_number                  = em.employee_number
    AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
    ;


    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(v_end_yyyymmdd,'yyyymmdd'), p_payroll_item_id) = 'Y' THEN
        RETURN ;
    END IF;

    --Check Child Incentive basic
    SELECT nvl(lgvpay_common_pkg.get_calc_var_value( v_subsidiary_code,'CHILD_INCENTIVE_BASE',v_end_yyyymmdd),0)
    INTO   v_basis_amount
    FROM   dual ;

--    dbms_output.put_line('v_basis_amount=>'||v_basis_amount);

    --???? ????
    SELECT lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd') ,p_payroll_item_id,'CHILD_COUNT')
           ,lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(v_end_yyyymmdd,'yyyymmdd') ,p_payroll_item_id,'PAY_VALUE')
    INTO   v_child_count, v_pay_value
    FROM   dual;

    /* ??? 0?? ??? 0?? ????. */
    if v_child_count > 0 then 
       v_return  := greatest((v_basis_amount * v_child_count),0);
    else 
      v_return := v_pay_value;
    end if;


--dbms_output.put_line('v_return=>'||v_return);


    --1) pay value input value ????
    SELECT a.payroll_item_detail_detail_id
    INTO   v_input_value_id
    FROM   tb_pay_item_detail_n a
    WHERE  a.payroll_item_id        = p_payroll_item_id
    AND    a.additional_input_value = 'PAY_VALUE'
    ;


    create_result( p_payroll_calculation_exec_id         => p_payroll_calculation_exec_id,
                         p_employee_no                   => p_employee_no,
                         p_payroll_item_id               => p_payroll_item_id,
                         p_payroll_item_detail_id        => v_input_value_id  ,
                         p_rslt_detail_type_code         => 'A',
                         p_result_value                   => v_return,
                         p_user_id                        => p_user_id,
                         p_period_id                     => p_period_id)   ;




EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line('calculation calculation_transport_allw error ; ' ||SQLERRM);
        v_err_buf := 'Employee_No : '|| p_employee_no || chr(13) || SQLERRM;
        --dbms_output.put_line('calculation_transport allwance error ; ' ||SQLERRM);
        v_step :=v_step||chr(13)|| 'User Exception Error(calculation_transport_allw error)';
        lgvpay_log_pkg.set_log_msg_payroll_result( p_payroll_calculation_exec_id, p_employee_no, v_err_buf );

END;


end lgvpay_calculation_pkg;
/
