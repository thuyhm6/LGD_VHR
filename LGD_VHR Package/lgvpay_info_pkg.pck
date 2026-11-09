CREATE OR REPLACE PACKAGE VHR_MGR.lgvpay_info_pkg IS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : pay_info_pkg                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/* 2021/03/23 HMT_20210323      Add get_type_work_hours function*/
/******************************************************************************/
FUNCTION get_base_pay( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     )  RETURN NUMBER ;
FUNCTION get_position_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER ;   
FUNCTION get_job_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER;

FUNCTION get_adj_os( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     )  RETURN NUMBER ;
                     
FUNCTION get_kpi_os( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     )  RETURN NUMBER ;
                     
FUNCTION get_service_fee( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                      ,p_payroll_calculation_exec_id IN NUMBER
                      ,p_payroll_item_id IN NUMBER
                      ,p_period_id  IN NUMBER
                     )  RETURN NUMBER ;
                     
FUNCTION get_entrance_bonus( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                      , v_end_yyyymmdd       IN DATE
                     )  RETURN NUMBER ;
                     
FUNCTION get_13th( p_employee_no        IN VARCHAR2
                      , p_effective_yyyymmdd IN VARCHAR2
                      , p_subsidiary_code    IN VARCHAR2
                      , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     )  RETURN NUMBER ; 

FUNCTION get_encour_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER;
FUNCTION get_hardship_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER;                  



FUNCTION get_ins_target_flag( p_employee_no IN VARCHAR2 
                             , p_period_id  IN NUMBER ) RETURN VARCHAR2;  
                             
FUNCTION get_qualification_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2,p_subsidiary_code IN VARCHAR2) RETURN NUMBER;                             

FUNCTION get_ordinary_wages_for_ins( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER; 

FUNCTION get_ordinary_wages_for_al( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER; 

FUNCTION get_ordinary_wages( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2,p_base_salry_type IN VARCHAR2) RETURN NUMBER;

FUNCTION get_run_result(p_payroll_calculation_exec_id IN NUMBER
                       ,p_employee_no                 IN VARCHAR2
                       ,p_payroll_item_name           IN VARCHAR2
                       ,p_detail_name                 IN VARCHAR2
                       ,p_subsidiary_code             in VARCHAR2  ) RETURN NUMBER ;   
                       
--HMT_20210323
FUNCTION get_type_work_hours (p_subsidiary_code       IN VARCHAR2
                             ,p_atendance_date        IN DATE
                             ,p_atendance_code        IN VARCHAR2
                             ,p_shift_type_code       IN VARCHAR2
                             ,p_work_hours            IN NUMBER
                             ,p_type                  IN VARCHAR2) RETURN NUMBER;    
                             
--HMT_20220130
FUNCTION get_work_hours (p_subsidiary_code       IN VARCHAR2
                        ,p_employee_no           IN VARCHAR2
                        ,p_atendance_date        IN DATE
                        ,p_atendance_code        IN VARCHAR2
                        ,p_shift_type_code       IN VARCHAR2
                        ,p_work_hours            IN NUMBER
                        ,p_type                  IN VARCHAR2) RETURN NUMBER;                                             

end lgvpay_info_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvpay_info_pkg IS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : pay_info_pkg                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                  Basic Package with Functions Related in Payroll           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_base_pay                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's Base pay                
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
FUNCTION get_base_pay( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     ) RETURN NUMBER IS
  v_return     NUMBER ;
  v_grade_type VARCHAR2(100);
  v_pay_step   VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date       
    SELECT asg.grade
         , pay_step.competency_grade_point_code
    INTO   v_grade_type
          ,v_pay_step 
    FROM   emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    p_effective_yyyymmdd  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'BASE_SALARY' ,'BASE_AMOUNT',p_subsidiary_code ),0);
    
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
     
        
        -- ??? ??? ???? ?? ?? ?? 
        SELECT /*+ LEADING(B) */ TO_NUMBER(D.TABLE_CELL_VALUE) 
        INTO   v_return
        FROM   tb_pay_user_dfin_table_m a
             , tb_pay_user_dfin_table_col_n b
             , tb_pay_user_dfin_table_row_n c
             , tb_pay_user_dfin_table_value_n d
        WHERE a.table_name    = 'PAY_STEP'
        AND   b.table_seq_no  =  a.table_seq_no  
        AND   c.table_seq_no  = b.table_seq_no
        AND   d.row_no        = c.row_no
        AND   d.column_seq_no = b.column_seq_no
        AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
        AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
        AND   b.user_column_name            =  v_grade_type
        AND   c.lower_limit_critical_value  = NVL(v_pay_step, '99')
        ;
    
    END IF;
    
    
    --parameter ? ??? ??? ?????? ????.
    BEGIN
        SELECT 'Y'
        INTO   v_probation_flag
        FROM   emp_master em
        WHERE  em.employee_number = p_employee_no
        AND    p_effective_yyyymmdd BETWEEN to_char(em.probation_start_date,'yyyymmdd') AND to_char(em.probation_end_date,'yyyymmdd');
   EXCEPTION
       WHEN OTHERS THEN
           v_probation_flag := 'N';
   END;
   
    IF p_flag = 'A' THEN   -- PROBATION ??? ???? ??(????? ??)
        IF v_probation_flag = 'Y' THEN 
            SELECT lgvpay_common_pkg.get_calc_var_value(p_subsidiary_code, 'PROBATION_RATE',p_effective_yyyymmdd)
            INTO   v_probation_rate
            FROM   dual;
            
        ELSE
            v_probation_rate := 1;
        END IF;
    ELSE --PROBATION????? ?? ?? RETURN ( ??? ?? ) 
        v_probation_rate := 1;
    END IF;
    
    --dbms_output.put_line('v_probation_rate=>'||v_probation_rate);
    
    RETURN round(v_return * v_probation_rate);
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_position_allowance                                   */
/* Description    :  Gettig Position Allowance By Employee and Date           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
FUNCTION get_position_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
  v_return     NUMBER ;
  v_position   emp_assig.position%TYPE;
  v_subsidiary_code VARCHAR2(30);
  
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date
    SELECT asg.position
          ,asg.subsidiary_code
    INTO   v_position
         , v_subsidiary_code
    FROM   emp_assig asg
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    ;
    
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'POSITION_ALLW' ,'BASE_AMOUNT' ,v_subsidiary_code),0);
    --dbms_output.put_line(v_position);    
    
    IF v_return = 0 THEN 
    
    -- ??? ??? ???? ?? ?? ?? 
    BEGIN
    SELECT to_number(d.table_cell_value)
    INTO   v_return
    FROM   tb_pay_user_dfin_table_m a
         , tb_pay_user_dfin_table_col_n b
         , tb_pay_user_dfin_table_row_n c
         , tb_pay_user_dfin_table_value_n d
    WHERE a.table_name    = 'POSITION_ALLOWANCE'
    AND   b.table_seq_no  =  a.table_seq_no  
    AND   b.user_column_name = 'POSITION_ALLOWANCE'
    AND   c.table_seq_no  = b.table_seq_no
    AND   d.row_no        = c.row_no
    AND   d.column_seq_no = b.column_seq_no
    AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
    AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
    AND   c.lower_limit_critical_value  =  v_position
    ;
    EXCEPTION
        WHEN OTHERS THEN
            v_return := 0;
    END;
    
    END IF;
        
    RETURN round(v_return);
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_job_allowance                                        */
/* Description    :  Gettig Job Allowance By Employee and Date                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/* 2019/10/28            TaiDD - Add the condition to select the IC contract type based on the date, 
                                 normally the IC contract type doesn't have the contract end date so but the NVL. 
                                 Use between because incase the emp have IC in the past then resign and after that come back to work so have new PC, FC, SC, IC records*/
/******************************************************************************/
FUNCTION get_job_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
  
  v_job_group           emp_assig.job_group%TYPE;
  v_job_detail          emp_assig.job_detail%TYPE;
  v_grade_title         emp_assig.grade_title%TYPE;
  v_return_value        NUMBER := 0;
  v_contract_type_code  tb_pay_emp_contract_n.contract_type_code%TYPE;
  v_subsidiary_code     VARCHAR2(100);
  
BEGIN 
    -- job Allowance Depends on Job Information and Contract Information
    -- Then as the rule of job allowance, sometimes we have to job group and job detail
    -- sometimes job gruop and contracts..
    -- so, i made a logic for serveal cases ?? 
    
    
    
    -- Select Job Group and Job Detail With Employee Number and Assignment Date
    SELECT asg.job_group
          ,asg.job_detail
          ,ccc.common_code_name
          ,asg.subsidiary_code
    INTO   v_job_group
         , v_job_detail
         , v_grade_title
         , v_subsidiary_code
    FROM   emp_assig asg
         , lgcom_common_code_multi_lang_c ccc
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    ccc.code_type_code = 'IF_VIETNAM_GRADE_TITLE'
    AND    ccc.common_code = asg.grade_title
    AND    ccc.language_code = 'en'
    ;
      
    
    v_return_value := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'JOB_ALLW' ,'BASE_AMOUNT' ,v_subsidiary_code),0);
    
    IF v_return_value =0 THEN 
    
    -- Select Contract info
    --1) check Indefinite-term Contract
    --   Employee has Indefinite-term Contract then we don't have to check other contract informations.
    -- 
    BEGIN
        SELECT contract_type_code
        INTO   v_contract_type_code
        FROM   tb_pay_emp_contract_n ecn
        WHERE  ecn.employee_no        = p_employee_no
        AND    ecn.contract_type_code = 'IC'
        AND    TO_DATE(p_effective_yyyymmdd,'yyyymmdd') BETWEEN ecn.contract_period_start_date AND NVL(ecn.contract_period_end_date, TO_DATE('99991231', 'yyyymmdd'))--TaiDD - 20191028 - add the condition to search based on the date
        ;    
    EXCEPTION
        WHEN OTHERS THEN
           v_contract_type_code := '';
    END;
    
      

    
    --2) if employee doesn't have Indefinite-term Contract, then check others contracts
    
    IF v_contract_type_code IS NULL THEN
        BEGIN
            SELECT ecn.contract_type_code
            INTO   v_contract_type_code
            FROM   tb_pay_emp_contract_n ecn
            WHERE  ecn.employee_no = p_employee_no
            AND    TO_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN ecn.contract_period_start_date AND ecn.contract_period_end_date
            ;
        EXCEPTION
            WHEN OTHERS THEN
                v_contract_type_code := '';
        END;
                    
    END IF;   
    
    --dbms_output.put_line('v_grade_title=>'||v_grade_title);   
    --dbms_output.put_line('v_job_detail=>'||v_job_detail);         
    --dbms_output.put_line('v_contract_type_code=>'||v_contract_type_code);
    
    -- First, select the data that matched with all information 
    BEGIN
        SELECT table_cell_value
        INTO   v_return_value
        FROM  ( 
                SELECT substr(data_table.data_value,1,seperator1-1 ) grade_title
                    ,  nvl(substr(data_table.data_value,seperator1+1, seperator2 - seperator1 -1 ),'xx') job_detail
                    ,  nvl(substr(data_table.data_value,seperator2+1, LENGTHB(data_value) - seperator2 ),'xx') contract_type_code
                    ,  table_cell_value
                FROM  ( 
                SELECT udtr.lower_limit_critical_value data_value 
                     , INSTR(udtr.lower_limit_critical_value,'|',1)  seperator1
                     , INSTR(udtr.lower_limit_critical_value,'^',1)  seperator2
                     , udtv.table_cell_value
                FROM   tb_pay_user_dfin_table_m udt
                     , tb_pay_user_dfin_table_col_n udtc
                     , tb_pay_user_dfin_table_row_n udtr
                     , tb_pay_user_dfin_table_value_n udtv
                WHERE  udt.table_name            =  'JOB_ALLOWANCE'
                AND    udtc.table_seq_no         = udt.table_seq_no
                AND    udtc.user_column_name     = 'JOB_ALLOWANCE'
                AND    udtr.table_seq_no         = udt.table_seq_no
                AND    p_effective_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
                AND    udtv.column_seq_no        = udtc.column_seq_no
                AND    udtv.row_no               = udtr.row_no
                AND    p_effective_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
                ) data_table
             )
        WHERE grade_title  = v_grade_title
        AND   job_detail   = v_job_detail
        AND   contract_type_code = v_contract_type_code
        ;
    
    EXCEPTION
        WHEN NO_DATA_FOUND  THEN
           -- dbms_output.put_line(SQLERRM);
            v_return_value := -9999; 
        WHEN  OTHERS THEN  
           -- dbms_output.put_line(SQLERRM);
            v_return_value := 0; 
            RETURN v_return_value;
    END;
    
    -- Second, select the data that matched with only grade title 
    IF v_return_value = -9999 THEN 
    BEGIN
        SELECT table_cell_value
        INTO   v_return_value
        FROM  ( 
                SELECT substr(data_table.data_value,1,seperator1-1 ) grade_title
                    ,  nvl(substr(data_table.data_value,seperator1+1, seperator2 - seperator1 -1 ),'xx') job_detail
                    ,  nvl(substr(data_table.data_value,seperator2+1, LENGTHB(data_value) - seperator2 ),'xx') contract_type_code
                    ,  table_cell_value
                FROM  ( 
                SELECT udtr.lower_limit_critical_value data_value 
                     , INSTR(udtr.lower_limit_critical_value,'|',1)  seperator1
                     , INSTR(udtr.lower_limit_critical_value,'^',1)  seperator2
                     , udtv.table_cell_value
                FROM   tb_pay_user_dfin_table_m udt
                     , tb_pay_user_dfin_table_col_n udtc
                     , tb_pay_user_dfin_table_row_n udtr
                     , tb_pay_user_dfin_table_value_n udtv
                WHERE  udt.table_name            =  'JOB_ALLOWANCE'
                AND    udtc.table_seq_no         = udt.table_seq_no
                AND    udtc.user_column_name     = 'JOB_ALLOWANCE'
                AND    udtr.table_seq_no         = udt.table_seq_no
                AND    p_effective_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
                AND    udtv.column_seq_no        = udtc.column_seq_no
                AND    udtv.row_no               = udtr.row_no
                AND    p_effective_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
                ) data_table
             )
        WHERE grade_title  = v_grade_title        
        ;
    
    EXCEPTION
        WHEN TOO_MANY_ROWS  THEN
           -- dbms_output.put_line(SQLERRM);
            v_return_value := -9999; 
        WHEN  OTHERS THEN  
           -- dbms_output.put_line(SQLERRM);
            v_return_value := 0; 
            RETURN v_return_value;
    END;
    
    end IF;
    
    -- As the last, select the data that matched with only grade title  and contract type
    IF v_return_value = -9999 THEN 
    BEGIN
        SELECT table_cell_value
        INTO   v_return_value
        FROM  ( 
                SELECT substr(data_table.data_value,1,seperator1-1 ) grade_title
                    ,  nvl(substr(data_table.data_value,seperator1+1, seperator2 - seperator1 -1 ),'xx') job_detail
                    ,  nvl(substr(data_table.data_value,seperator2+1, LENGTHB(data_value) - seperator2 ),'xx') contract_type_code
                    ,  table_cell_value
                FROM  ( 
                SELECT udtr.lower_limit_critical_value data_value 
                     , INSTR(udtr.lower_limit_critical_value,'|',1)  seperator1
                     , INSTR(udtr.lower_limit_critical_value,'^',1)  seperator2
                     , udtv.table_cell_value
                FROM   tb_pay_user_dfin_table_m udt
                     , tb_pay_user_dfin_table_col_n udtc
                     , tb_pay_user_dfin_table_row_n udtr
                     , tb_pay_user_dfin_table_value_n udtv
                WHERE  udt.table_name            =  'JOB_ALLOWANCE'
                AND    udtc.table_seq_no         = udt.table_seq_no
                AND    udtc.user_column_name     = 'JOB_ALLOWANCE'
                AND    udtr.table_seq_no         = udt.table_seq_no
                AND    p_effective_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
                AND    udtv.column_seq_no        = udtc.column_seq_no
                AND    udtv.row_no               = udtr.row_no
                AND    p_effective_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
                ) data_table
             )
        WHERE grade_title  = v_grade_title
        AND   job_detail = 'xx'
        AND   contract_type_code = nvl(v_contract_type_code,contract_type_code)
        ;
    
    EXCEPTION
        WHEN OTHERS  THEN
          --  dbms_output.put_line(SQLERRM);
            v_return_value := 0;  
    END;
    
    END IF;
    
    END IF;
    
    RETURN round(v_return_value);
    
    
EXCEPTION
    WHEN OTHERS THEN 
     --   dbms_output.put_line('p_employee_no =>'||p_employee_no||SQLERRM);
        v_return_value := 0;
        RETURN v_return_value;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : pay_info_pkg                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                  Basic Package with Functions Related in Payroll           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_adj_os                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's get_adj_os              
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2025/11/02            Initial Release                                      */
/******************************************************************************/
FUNCTION get_adj_os( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     ) RETURN NUMBER IS
  v_return     NUMBER ;
  v_grade_type VARCHAR2(100);
  v_pay_step   VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  v_date_hire         DATE;
  
  v_date_retire         Date;
  v_date_ss             VARCHAR2(8);
  
BEGIN 
  
    select em.date_retire into v_date_retire from emp_master em where em.employee_number = p_employee_no;
    IF v_date_retire IS NOT NULL
       AND v_date_retire <= TO_DATE(p_effective_yyyymmdd,'YYYYMMDD')
    THEN
       v_date_ss := To_char(v_date_retire, 'YYYYMMDD');
    ELSE
       v_date_ss := p_effective_yyyymmdd;
    END IF;
    
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date       
    SELECT em.DATE_HIRE_SUBSIDIARY, asg.grade
    INTO   v_date_hire, v_grade_type
    FROM    emp_master em
          , emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    em.employee_number = asg.employee_number
    AND    to_date(v_date_ss,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    v_date_ss  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(v_date_ss,'YYYYMMDD'), 'OS_ADJUSTMENT' ,'BASE_AMOUNT',p_subsidiary_code ),0);
    
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
     
        
        -- ??? ??? ???? ?? ?? ?? 
        SELECT /*+ LEADING(B) */ TO_NUMBER(D.TABLE_CELL_VALUE) 
        INTO   v_return
        FROM   tb_pay_user_dfin_table_m a
             , tb_pay_user_dfin_table_col_n b
             , tb_pay_user_dfin_table_row_n c
             , tb_pay_user_dfin_table_value_n d
        WHERE a.table_name    = 'OS_ADJUSTMENT'
        AND   b.table_seq_no  =  a.table_seq_no  
        AND   c.table_seq_no  = b.table_seq_no
        AND   d.row_no        = c.row_no
        AND   d.column_seq_no = b.column_seq_no
        AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
        AND   TRUNC(to_date(p_effective_yyyymmdd,'yyyymmdd')) BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
        AND   b.user_column_name            =  'OS_ADJUSTMENT'
        AND   TO_NUMBER(c.lower_limit_critical_value)<= (to_date(v_date_ss,'YYYYMMDD') - v_date_hire + 1)
        AND   TO_NUMBER(c.UPPER_LIMIT_CRITICAL_VALUE)>= (to_date(v_date_ss,'YYYYMMDD') - v_date_hire + 1)
        ;
    
    END IF;
    
    
    --parameter ? ??? ??? ?????? ????.
    BEGIN
        SELECT 'Y'
        INTO   v_probation_flag
        FROM   emp_master em
        WHERE  em.employee_number = p_employee_no
        AND    p_effective_yyyymmdd BETWEEN to_char(em.probation_start_date,'yyyymmdd') AND to_char(em.probation_end_date,'yyyymmdd');
   EXCEPTION
       WHEN OTHERS THEN
           v_probation_flag := 'N';
   END;
   
    IF p_flag = 'A' THEN   -- PROBATION ??? ???? ??(????? ??)
        IF v_probation_flag = 'Y' THEN 
            SELECT lgvpay_common_pkg.get_calc_var_value(p_subsidiary_code, 'PROBATION_RATE',p_effective_yyyymmdd)
            INTO   v_probation_rate
            FROM   dual;
            
        ELSE
            v_probation_rate := 1;
        END IF;
    ELSE --PROBATION????? ?? ?? RETURN ( ??? ?? ) 
        v_probation_rate := 1;
    END IF;
    
    --dbms_output.put_line('v_probation_rate=>'||v_probation_rate);
    
    if (v_grade_type <> 'L34') then
       RETURN round(v_return * v_probation_rate);
    else
       RETURN round(v_return);
    end if;
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : pay_info_pkg                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                  Basic Package with Functions Related in Payroll           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_kpi_os                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's Base pay                
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2025/11/04            Initial Release                                      */
/******************************************************************************/
FUNCTION get_kpi_os( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     ) RETURN NUMBER IS
  v_return     NUMBER ;
  v_grade_type VARCHAR2(100);
  v_pay_step   VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date       
    SELECT asg.grade
         , pay_step.competency_grade_point_code
    INTO   v_grade_type
          ,v_pay_step 
    FROM   emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    p_effective_yyyymmdd  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_kpi_os_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'OS_KPI' ,'RATE',p_subsidiary_code ),0);
    
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
        -- ??? ??? ???? ?? ?? ?? 
        SELECT kpi.kpi_rate + kpi_b.kpi_bonus
        INTO   v_return
        FROM
        TB_ATT_EMP_IDCARD_M car
        ,tb_pay_kpi_os kpi
        ,tb_pay_kpi_bonus_os kpi_b
        where car.employee_no = p_employee_no
        and car.vendor_code = kpi.vendor_code
        and car.team = kpi.team
        and kpi.vendor_code = kpi_b.vendor_code
        and kpi.month = TO_CHAR(to_date(p_effective_yyyymmdd,'yyyymmdd'), 'yyyymm')
        and kpi.month = kpi_b.month
        and kpi.status = 40;
    END IF;
    
    RETURN v_return;
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : get_service_fee                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                  Basic Package with Functions Related in Payroll           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_service_fee                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's Base pay                
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2025/11/04            Initial Release                                      */
/******************************************************************************/
FUNCTION get_service_fee( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     ,p_payroll_calculation_exec_id IN NUMBER
                     ,p_payroll_item_id IN NUMBER
                     ,p_period_id IN NUMBER
                     ) RETURN NUMBER IS
  v_return            NUMBER ;
  v_grade_type        VARCHAR2(100);
  v_pay_step          VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  v_kpi               NUMBER := 0;
  v_can_set_id        NUMBER := 0;
  v_perfect_work_days      NUMBER := 0;
  v_perfect_work_hours     NUMBER := 0;
  v_actual_hours           NUMBER := 0;
  v_total_amount_item      NUMBER := 0;
  v_end_month              VARCHAR2(10);
  v_base_salary            NUMBER := 0;
  v_deducOur               NUMBER := 0;
  v_yyyymm                 VARCHAR(10);
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date       
    SELECT asg.grade
         , pay_step.competency_grade_point_code
    INTO   v_grade_type
          ,v_pay_step 
    FROM   emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    p_effective_yyyymmdd  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'OS_SERVICE_FEE' ,'BASE_AMOUNT',p_subsidiary_code ),0);
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
        -- ??? ??? ???? ?? ?? ?? 
       --SELECT kpi.kpi_rate + kpi_b.kpi_bonus
       --INTO   v_kpi
       --FROM
       --TB_ATT_EMP_IDCARD_M car
       --,tb_pay_kpi_os kpi
       --,tb_pay_kpi_bonus_os kpi_b
       --where car.employee_no = p_employee_no
       --and car.vendor_code = kpi.vendor_code
       --and car.team = kpi.team
       --and kpi.vendor_code = kpi_b.vendor_code
       --and kpi.month = TO_CHAR(to_date(p_effective_yyyymmdd,'yyyymmdd'), 'yyyymm')
       --and kpi.month = kpi_b.month
       --and kpi.status = 40;
       
       begin
         select RESULT_VALUE  
         INTO   v_kpi
         from tb_pay_calc_result_n 
         where PAYROLL_ITEM_ID = (select PAYROLL_ITEM_ID from tb_pay_payroll_item_m where PAYROLL_ITEM_NAME  = 'OS_KPI')
         and PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
         and EMPLOYEE_NO  = p_employee_no;
         EXCEPTION
      WHEN OTHERS THEN 
          v_kpi := 0;
      END;
       -- l?y canset d? l?y gi? công chu?n
       SELECT /* LGVPAY00008.retrievePayrollRunList */
             pce.payroll_calculation_set_id
        INTO v_can_set_id
        FROM   tb_pay_calc_period_basis_n     pcpb
             , tb_pay_calc_exec_n             pce
             , lgcom_common_code_multi_lang_c cccm
             , tb_pay_calc_emp_exec_n         pcee
             , tb_pay_calc_set_n              pacs

        WHERE  pcpb.payroll_calc_period_value      = TO_CHAR(to_date(p_effective_yyyymmdd,'yyyymmdd'), 'yyyymm')
        AND    pcpb.Subsidiary_Code                = p_subsidiary_code
        AND    pce.basis_date BETWEEN to_date(pcpb.start_yyyymmdd,'yyyymmdd') AND to_date(pcpb.end_yyyymmdd,'yyyymmdd')
        AND     pce.payroll_calculation_exec_id      = p_payroll_calculation_exec_id
        AND    pce.payroll_type_code               = 'MTH'
        AND    cccm.code_type_code                 = 'LGVHR_PAY_RUN_TYPE'
        AND    pce.payroll_type_code               = cccm.common_code
        AND    cccm.language_code                  = 'en'
        AND    pcee.payroll_calculation_exec_id(+) = pce.payroll_calculation_exec_id
        AND    pacs.payroll_calculation_set_id     = pce.payroll_calculation_set_id

        GROUP BY pce.payroll_calculation_exec_id
               , pce.payroll_calculation_set_id
               , pacs.payroll_calculation_set_name
               , TO_CHAR(TO_DATE(pcpb.payroll_calc_period_value,'yyyymm'),'mm/yyyy')
               , pce.payroll_type_code
               , cccm.common_code_name
               , TO_CHAR(pce.basis_date,'dd/mm/yyyy')
               , NVL(pce.confirm_flag, 'N')
               , NVL(pce.retroactive_flag, 'N')
               , TO_CHAR(TO_DATE(pce.retroactive_pay_start_yyyymm,'yyyymm'),'mm/yyyy')
               , TO_CHAR(TO_DATE(pce.retroactive_payroll_end_yyyymm,'yyyymm'),'mm/yyyy')
               , pce.creation_user_id
               , pce.adding_up_taxation_flag
               , TO_CHAR(TO_DATE(pce.addup_taxation_start_yyyymm,'yyyymm'),'mm/yyyy')
        ORDER BY 1 DESC;
    
    
    -- l?y S? gi? th?c t?  (perfect_work_hourrs) /s? gi? tiêu chu?n(actual_hour)
    
    SELECT
       SUM(DECODE(b.time_and_attendance_code,'NW',1,'PH',1,0)) perfect_work_days 
      
      ,SUM(lgvpay_info_pkg.get_work_hours('LGDVN', r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
      b.shift_type_code, b.work_hours, 'pay_perfect_hours')) as perfect_work_hours
      
      ,SUM( CASE
      WHEN (c.paid_days > 0 OR c.attendance_days > 0) THEN lgvpay_info_pkg.get_work_hours(p_subsidiary_code, r.employee_no, b.time_and_attendance_date, DECODE(r.time_and_attendance_code,'WH','WH','PH','PH','NW'), 
      b.shift_type_code, b.work_hours, 'pay_perfect_hours')
      END
      ) ACTUAL_HOURS
      
      INTO 
      v_perfect_work_days
      ,v_perfect_work_hours
      ,v_actual_hours
      
      FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
      WHERE r.time_and_attendance_code = c.time_and_attendance_code
      AND r.shift_type_code = b.shift_type_code
      AND r.time_and_attendance_date = b.time_and_attendance_date
      --AND em.grade = 'L34'
      AND r.time_and_attendance_yyyymm = TO_CHAR(to_date(p_effective_yyyymmdd,'yyyymmdd'), 'yyyymm')
      --and TO_CHAR(r.time_and_attendance_date , 'DD') between 01 and 06
      AND em.employee_number = r.employee_no
      AND em.employee_number IN (
      select employee_no from vhr_mgr.tb_pay_calc_set_target_per_n where PAYROLL_CALCULATION_SET_ID = v_can_set_id
      )
      and employee_no = p_employee_no
    GROUP BY r.employee_no, em.assignment_category, r.time_and_attendance_yyyymm;
    
    -- l?y các lo?i luong fix d? c?ng l?i
    
    
       --SELECT CASE WHEN em.date_retire BETWEEN TO_date(period.start_yyyymmdd, 'yyyymmdd')  AND TO_date(period.end_yyyymmdd, 'yyyymmdd')
       --            THEN to_char(em.date_retire,'yyyymmdd')
       --            ELSE period.end_yyyymmdd
       --       END
       --INTO   v_end_month
       --FROM   tb_pay_calc_period_basis_n period
       --      ,emp_master em
       --      ,emp_assig  ass
       --WHERE  period.payroll_calculation_period_id = p_period_id
       --AND    em.employee_number                   = p_employee_no
       --AND    ass.employee_number                  = em.employee_number
       --AND    least(nvl(em.date_retire,to_date(period.end_yyyymmdd,'yyyymmdd')) , to_date(period.end_yyyymmdd,'yyyymmdd')) BETWEEN ass.assignment_start_date AND to_date(ass.attribute1,'yyyymmdd')
       --;
    
   SELECT TO_CHAR(LAST_DAY(TO_DATE(p_effective_yyyymmdd, 'YYYYMMDD')), 'YYYYMMDD') AS v_end_month
   into v_end_month
   FROM dual;
    
   --select to_number(RESULT_VALUE) into v_base_salary from tb_pay_calc_result_n where PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id and PAYROLL_ITEM_ID = 5 and EMPLOYEE_NO = p_employee_no;
   
   select TO_CHAR(LAST_DAY(TO_DATE(p_effective_yyyymmdd, 'YYYYMMDD')), 'YYYYMM') into v_yyyymm from dual; 
   BEGIN
          SELECT 
          nvl(SUM(nvl(r.tardy_hours,0)) + SUM(nvl(r.going_out_hours,0)) + SUM(nvl(r.early_leave_hours,0)),0)
          into v_deducOur
          FROM tb_att_result_n r, tb_att_code_c c, tb_att_base_bas_n b, emp_master em
          WHERE r.time_and_attendance_code = c.time_and_attendance_code
          AND r.shift_type_code = b.shift_type_code
          AND r.time_and_attendance_date = b.time_and_attendance_date
          AND r.time_and_attendance_yyyymm = v_yyyymm
          AND em.employee_number = r.employee_no
          and employee_no = p_employee_no
          GROUP BY r.employee_no, em.assignment_category, r.time_and_attendance_yyyymm;
   EXCEPTION
    WHEN OTHERS THEN 
        v_deducOur := 0;
    END;
    v_total_amount_item := nvl(lgvpay_info_pkg.get_base_pay( p_employee_no ,v_end_month ,p_subsidiary_code  , 'A') ,0)
                     +nvl(lgvpay_info_pkg.get_position_allowance( p_employee_no , v_end_month ) ,0)
                     +nvl(lgvpay_info_pkg.get_job_allowance( p_employee_no, v_end_month ) ,0)
                     --+nvl(lgvpay_info_pkg.get_special_allowance( p_employee_no, p_effective_yyyymmdd ) ,0)
                     --+nvl(lgvpay_info_pkg.get_qualification_allowance( p_employee_no , p_effective_yyyymmdd,v_subsidiary_code ) ,0)
                     --+nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE1','BASE_AMOUNT',v_subsidiary_code ) ,0) 
                     --+nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE2','BASE_AMOUNT',v_subsidiary_code ) ,0)
                     --+nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE3','BASE_AMOUNT',v_subsidiary_code ) ,0)
                     +nvl(lgvpay_info_pkg.get_adj_os( p_employee_no   , v_end_month , p_subsidiary_code  , 'A' ) ,0); -- ADD get_adj_os
    
    
   --select SUM(RESULT_VALUE)  
   --   INTO   v_total_amount_item
   --   from tb_pay_calc_result_n 
   --   where PAYROLL_CALCULATION_EXEC_ID = p_payroll_calculation_exec_id
   --   and EMPLOYEE_NO  = p_employee_no
   --   and PAYROLL_ITEM_ID in 
   --   (
   --      SELECT  a.payroll_item_id
   --        FROM    tb_pay_payroll_item_m      a
   --              , tb_pay_calc_formula_n      b
   --              , tb_pay_calc_period_basis_n c
   --              , tb_pay_calc_mthd_n         d
   --              , lgcom_common_code_c cc
   --        WHERE   b.payroll_calculation_formula_id = a.payroll_calculation_formula_id
   --        AND     d.payroll_calc_method_code = cc.common_code
   --        AND     c.payroll_calculation_period_id  = p_period_id
   --        AND    c.end_yyyymmdd                    BETWEEN a.start_yyyymmdd AND nvl(a.end_yyyymmdd,'47121231')
   --        AND    d.payroll_item_id                 = a.payroll_item_id
   --        AND    d.payroll_calc_method_code        ='FIXED_FLAG'
   --        AND    d.payroll_apply_flag              = 'Y'
   --        AND    EXISTS  ( SELECT 1
   --                     FROM  tb_pay_payroll_item_use_n piu
   --                     WHERE piu.payroll_item_id   = a.payroll_item_id
   --                     AND   c.end_yyyymmdd      BETWEEN piu.effective_start_yyyymmdd AND piu.effective_end_yyyymmdd
   --                     AND   piu.payroll_type_code = 'MTH') 
   --   );
       
       v_return := (v_actual_hours - v_deducOur) / v_perfect_work_hours * v_total_amount_item * v_kpi / 100;
    END IF;
    
    RETURN v_return;
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Filename       : pay_info_pkg.pck                                          */
/* Program ID     :                                                           */
/* Pakage Name    : get_entrance_bonus                                              */
/* Description    : ???? ?? function ? ??? package                  */
/*                  Basic Package with Functions Related in Payroll           */
/*                                                                            */
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_entrance_bonus                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's Base pay                
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2025/11/05            Initial Release                                      */
/******************************************************************************/
FUNCTION get_entrance_bonus( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     , v_end_yyyymmdd       IN DATE
                     ) RETURN NUMBER IS
  v_return            NUMBER ;
  v_grade_type        VARCHAR2(100);
  v_pay_step          VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  v_date_hire_subsidiary          DATE;
  v_days                          NUMBER;
  v_day_of_month                  NUMBER;
  v_temp                          NUMBER := 0;
  v_gender                        VARCHAR2(30);
  
  v_seq                           NUMBER := 0;
  v_seq_m_1                       NUMBER := 0;
  v_prev_month                    DATE;
  v_days_prev                     NUMBER;
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date       
    SELECT asg.grade
         , pay_step.competency_grade_point_code
    INTO   v_grade_type
          ,v_pay_step 
    FROM   emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    p_effective_yyyymmdd  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'OS_ENTRANCE_BONUS' ,'BASE_AMOUNT',p_subsidiary_code ),0);
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
    
        IF lgvpay_common_pkg.get_chcek_entrance_bonus(p_employee_no, 'OS_ENTRANCE_BONUS_PROGRAM_TIME', 'DATE_HIRE_SUBSIDIARY') = 'Y' THEN
           
    --SELECT /* LGVPAY10001.retrieveGlobalValueHistoryList */
    --          cvn.payroll_calc_variable_id     /* ????????? */
    --        , cvh.effective_start_yyyymmdd  /* ?????? */
    --        , cvh.effective_end_yyyymmdd  /* ?????? */
    --        , cvh.result_value  /* ????? */
    --        , cvh.effective_start_yyyymmdd AS ori_effective_start_yyyymmdd /* ??????(???) */
    --   FROM   tb_pay_calc_var_n cvn
    --        , tb_pay_calc_var_value_n cvh
    --        , emp_master em
    --   WHERE  cvn.subsidiary_code = 'LGDVN'  /* ?????? */
    --   AND    cvn.PAYROLL_CALC_VARIABLE_NAME = 'ENTRANCE_BONUS_PROGRAM_TIME'
    --   AND    cvn.payroll_calc_variable_id = cvh.payroll_calc_variable_id
    --   AND    cvh.result_value = 'DATE_HIRE_SUBSIDIARY'
    --   AND    em.date_hire_subsidiary between TO_DATE(cvh.effective_start_yyyymmdd, 'YYYYMMDD') and TO_DATE(cvh.effective_end_yyyymmdd, 'YYYYMMDD')
    --   AND    em.employee_number = 'VH000027'
    
    -- v_end_yyyymmdd
     select em.date_hire_subsidiary,
            em.gender
     into v_date_hire_subsidiary, v_gender
     from emp_master em 
     where employee_number = p_employee_no;
    
    v_days := (v_end_yyyymmdd - v_date_hire_subsidiary) + 1;
    v_prev_month := LAST_DAY(ADD_MONTHS(v_end_yyyymmdd, -1));
    v_days_prev := (v_prev_month - v_date_hire_subsidiary) + 1;
    
    BEGIN
      IF v_gender = 'M' Then
        SELECT TO_NUMBER(c.sort_order_no)
        INTO   v_seq
        FROM   tb_pay_user_dfin_table_m a
             , tb_pay_user_dfin_table_col_n b
             , tb_pay_user_dfin_table_row_n c
             , tb_pay_user_dfin_table_value_n d
        WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
        AND   b.table_seq_no  =  a.table_seq_no  
        AND   c.table_seq_no  = b.table_seq_no
        AND   d.row_no        = c.row_no
        AND   d.column_seq_no = b.column_seq_no
        AND   v_end_yyyymmdd BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
        AND   v_end_yyyymmdd BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
        AND  b.user_column_name = 'MALE'
        AND   TO_NUMBER(c.lower_limit_critical_value)  <= v_days
        AND   TO_NUMBER(c.UPPER_LIMIT_CRITICAL_VALUE)  >= v_days
        AND ROWNUM = 1
        ;
      ELSE
        SELECT TO_NUMBER(c.sort_order_no)
        INTO   v_seq
        FROM   tb_pay_user_dfin_table_m a
             , tb_pay_user_dfin_table_col_n b
             , tb_pay_user_dfin_table_row_n c
             , tb_pay_user_dfin_table_value_n d
        WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
        AND   b.table_seq_no  =  a.table_seq_no  
        AND   c.table_seq_no  = b.table_seq_no
        AND   d.row_no        = c.row_no
        AND   d.column_seq_no = b.column_seq_no
        AND   v_end_yyyymmdd BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
        AND   v_end_yyyymmdd BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
        AND  b.user_column_name = 'FEMALE'
        AND   TO_NUMBER(c.lower_limit_critical_value)  <= v_days
        AND   TO_NUMBER(c.UPPER_LIMIT_CRITICAL_VALUE)  >= v_days
        AND ROWNUM = 1
        ;
      END IF;
      
        EXCEPTION
      WHEN OTHERS THEN 
          v_seq := 0;
      END;
      
      BEGIN
        IF v_gender = 'M' Then
          SELECT TO_NUMBER(c.sort_order_no)
          INTO   v_seq_m_1
          FROM   tb_pay_user_dfin_table_m a
               , tb_pay_user_dfin_table_col_n b
               , tb_pay_user_dfin_table_row_n c
               , tb_pay_user_dfin_table_value_n d
          WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
          AND   b.table_seq_no  =  a.table_seq_no  
          AND   c.table_seq_no  = b.table_seq_no
          AND   d.row_no        = c.row_no
          AND   d.column_seq_no = b.column_seq_no
          AND   v_prev_month BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
          AND   v_prev_month BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
          AND  b.user_column_name = 'MALE'
          AND   TO_NUMBER(c.lower_limit_critical_value)  <= v_days_prev
          AND   TO_NUMBER(c.UPPER_LIMIT_CRITICAL_VALUE)  >= v_days_prev
          ;
        ELSE
          SELECT TO_NUMBER(c.sort_order_no)
          INTO   v_seq_m_1
          FROM   tb_pay_user_dfin_table_m a
               , tb_pay_user_dfin_table_col_n b
               , tb_pay_user_dfin_table_row_n c
               , tb_pay_user_dfin_table_value_n d
          WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
          AND   b.table_seq_no  =  a.table_seq_no  
          AND   c.table_seq_no  = b.table_seq_no
          AND   d.row_no        = c.row_no
          AND   d.column_seq_no = b.column_seq_no
          AND   v_prev_month BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
          AND   v_prev_month BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
          AND  b.user_column_name = 'FEMALE'
          AND   TO_NUMBER(c.lower_limit_critical_value)  <= v_days_prev
          AND   TO_NUMBER(c.UPPER_LIMIT_CRITICAL_VALUE)  >= v_days_prev
          ;
        END IF;
        
          EXCEPTION
        WHEN OTHERS THEN 
            v_seq_m_1 := 0;
      END;
      
      BEGIN
        
      IF v_gender = 'M' Then
          SELECT NVL(SUM(TO_NUMBER(D.TABLE_CELL_VALUE)), 0)
          INTO   v_return
          FROM   tb_pay_user_dfin_table_m a
               , tb_pay_user_dfin_table_col_n b
               , tb_pay_user_dfin_table_row_n c
               , tb_pay_user_dfin_table_value_n d
          WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
          AND   b.table_seq_no  =  a.table_seq_no  
          AND   c.table_seq_no  = b.table_seq_no
          AND   d.row_no        = c.row_no
          AND   d.column_seq_no = b.column_seq_no
          AND   v_end_yyyymmdd BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
          AND   v_end_yyyymmdd BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
          AND  b.user_column_name = 'MALE'
          AND   TO_NUMBER(c.sort_order_no)  > v_seq_m_1
          AND   TO_NUMBER(c.sort_order_no)  <= v_seq
          ;
        ELSE
         SELECT NVL(SUM(TO_NUMBER(D.TABLE_CELL_VALUE)), 0)
         INTO   v_return
          FROM   tb_pay_user_dfin_table_m a
               , tb_pay_user_dfin_table_col_n b
               , tb_pay_user_dfin_table_row_n c
               , tb_pay_user_dfin_table_value_n d
          WHERE a.table_name    = 'OS_ENTRANCE_BONUS'
          AND   b.table_seq_no  =  a.table_seq_no  
          AND   c.table_seq_no  = b.table_seq_no
          AND   d.row_no        = c.row_no
          AND   d.column_seq_no = b.column_seq_no
          AND   v_end_yyyymmdd BETWEEN TO_date(d.effective_start_yyyymmdd,'yyyymmdd') AND to_date(d.effective_end_yyyymmdd,'yyyymmdd')
          AND   v_end_yyyymmdd BETWEEN TO_date(c.effective_start_yyyymmdd,'yyyymmdd') AND to_date(c.effective_end_yyyymmdd,'yyyymmdd')
          AND  b.user_column_name = 'FEMALE'
          AND   TO_NUMBER(c.sort_order_no)  > v_seq_m_1
          AND   TO_NUMBER(c.sort_order_no)  <= v_seq
          ;
        END IF;
        EXCEPTION
      WHEN OTHERS THEN 
          v_return := 0;
      END;
      ----
      END IF;
    END IF;
    
    RETURN v_return;
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_13th                                             */
/* Description    : ??? ??? ???? Function                           */
/*                  Calculation of Employee's 13th               
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2025/11/14            Initial Release                                      */
/******************************************************************************/
FUNCTION get_13th( p_employee_no        IN VARCHAR2
                     , p_effective_yyyymmdd IN VARCHAR2
                     , p_subsidiary_code    IN VARCHAR2
                     , p_flag               IN VARCHAR2 DEFAULT NULL  --flag : 'A' PROBATION ??, B: REGUALR ? ??? 
                     ) RETURN NUMBER IS
  v_return     NUMBER ;
  v_grade_type VARCHAR2(100);
  v_pay_step   VARCHAR2(100);
  v_probation_flag    VARCHAR2(1);
  v_probation_rate    NUMBER := 1;
  
  v_check             NUMBER:= 0;
  v_base_sum          NUMBER:= 0;
  v_min_salary        NUMBER:= 0;
  v_days_of_year      NUMBER:= 0;
  v_days_sub          NUMBER:= 0;
  v_total_residual_days        NUMBER;
  v_date_end                   DATE;
  v_days_retire        NUMBER := 0;
  v_date_start                   DATE;
  
BEGIN 
    -- ??? ?????? grade ? pay step ????
    -- Select Grade and Pay Step With Employee Number and Assignment Date      
    v_date_end := to_date(p_effective_yyyymmdd,'YYYYMMDD');
     
    SELECT asg.grade
         , pay_step.competency_grade_point_code
    INTO   v_grade_type
          ,v_pay_step 
    FROM   emp_assig asg
          ,tb_pay_emp_grade_point_n pay_step
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    AND    pay_step.employee_no(+) = asg.employee_number
    AND    p_effective_yyyymmdd  BETWEEN pay_step.start_yyyymmdd(+) AND nvl(pay_step.end_yyyymmdd(+),'471212131')
    ;
    
    
    v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), '13TH_SALARY' ,'BASE_AMOUNT',p_subsidiary_code ),0);
    
    
 --   dbms_output.put_line('v_return1111=>'||v_return);
    
    
    IF v_return = 0 THEN
      -- check ngay nghi viec < ngay cuoi cung trong nam thi khong tinh thang 13
      SELECT
       CASE 
         WHEN em.date_retire IS NOT NULL 
          AND em.date_retire < ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), -1) - 1
         THEN 1
         ELSE 0
        END AS v_check
        into v_check
        FROM emp_master em
        where em.employee_number = p_employee_no;
        
        IF v_check = 1 THEN 
          RETURN v_return;
        END IF;
        
      -- lay tien luong co ban thang cuoi cung trong nam
        SELECT DISTINCT NVL(b.result_value,0) INTO v_base_sum FROM
          tb_pay_calc_exec_n a
          , tb_pay_calc_result_n b
          , tb_pay_payroll_item_m c
          where 
          a.PAYROLL_CALCULATION_EXEC_ID = b.PAYROLL_CALCULATION_EXEC_ID
          and b.payroll_item_id = c.payroll_item_id
          and a.confirm_flag = 'Y'
          and c.payroll_item_name = 'BASE_SALARY'
          AND EXTRACT(YEAR FROM BASIS_DATE) =
            EXTRACT(YEAR FROM ADD_MONTHS(v_date_end, -12))
          AND EXTRACT(MONTH FROM BASIS_DATE) = 12
          and b.EMPLOYEE_NO = p_employee_no;
          
          -- ngay trong nam
          SELECT 
              (ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), 0) 
            - ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), -12)) 
            into v_days_of_year
          FROM dual;
            
          -- lay so tien toi thieu
           SELECT NVL(result_value, 0)
           into v_min_salary
            FROM tb_pay_calc_var_n a
                ,tb_pay_calc_var_value_n b
           WHERE a.Payroll_Calc_Variable_Id = b.Payroll_Calc_Variable_Id
             AND TO_CHAR(TRUNC(v_date_end, 'YYYY') - 1, 'YYYYMMDD') between b.effective_start_yyyymmdd and b.effective_end_yyyymmdd
             AND a.PAYROLL_CALC_VARIABLE_NAME = 'OS_MINIMUM_13TH';
         
         -- tinh ngay nghi phep
         SELECT NVL(MAX(DECODE(time_and_attendance_yyyymm, TO_CHAR(TRUNC(v_date_end, 'YYYY') - 1, 'YYYYMM'),
          NVL(residual_annual_leave_days, 0) 
         + NVL(annual_compensation_days, 0), 0)), 0)
                   into v_total_residual_days
             FROM   tb_att_annual_leave_n
             WHERE  subsidiary_code = 'LGDVN'
             AND    time_and_attendance_yyyymm BETWEEN SUBSTR(TO_CHAR(TRUNC(v_date_end, 'YYYY') - 1, 'YYYYMM'), 1, 4) || '01' 
             AND TO_CHAR(TRUNC(v_date_end, 'YYYY') - 1, 'YYYYMM')
             AND    employee_no = p_employee_no
             GROUP BY employee_no;
         
         SELECT em.date_hire_subsidiary - ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), -12) 
          AS v_days_retire
          into v_days_retire
          FROM emp_master em
          where em.employee_number = p_employee_no;
        
         IF v_total_residual_days <= 0 THEN
            -- v_days_sub   
           select count(*) 
           into v_days_sub
           from tb_att_result_n 
           where employee_no =  p_employee_no
           and time_and_attendance_date >= ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), -12)
           AND time_and_attendance_date <  TRUNC(v_date_end, 'YYYY') and TIME_AND_ATTENDANCE_CODE in ('AB');
         ELSE
           select count(*) 
           into v_days_sub
           from tb_att_result_n 
           where employee_no =  p_employee_no
           and time_and_attendance_date >= ADD_MONTHS(TRUNC(v_date_end, 'YYYY'), -12)
           AND time_and_attendance_date <  TRUNC(v_date_end, 'YYYY') - 1 and TIME_AND_ATTENDANCE_CODE IN ('AB','UL','UM','UF','US'); 
         END IF;
         IF v_days_retire < 0 THEN
           v_return := v_base_sum / v_days_of_year * (v_days_of_year - v_days_sub);
         ELSE
           v_return := v_base_sum / v_days_of_year * (v_days_of_year - v_days_sub - v_days_retire);
         END IF;
         
         IF v_return > 0 THEN
           IF v_return <= v_min_salary THEN
              v_return := v_min_salary;
           END IF;
         ELSE
           v_return := 0;
         END IF;
    END IF;
 
    --dbms_output.put_line('v_probation_rate=>'||v_probation_rate);
    
    RETURN v_return;
    
    
EXCEPTION
    WHEN OTHERS THEN 
        v_return := 0;
        RETURN v_return;
END;


/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_encour_allowance                                     */
/* Description    :  Gettig Encouragement allowance By Employee and Date      */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2023/08/02            Initial Release                                      */
/******************************************************************************/
FUNCTION get_encour_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
  
  v_grade           emp_assig.grade%TYPE;
  v_return_value        NUMBER := 0;
  v_subsidiary_code     VARCHAR2(100);
  
BEGIN 
    
    -- Select Grade With Employee Number and Assignment Date
    SELECT asg.grade
    INTO   v_grade
    FROM   emp_assig asg
    WHERE  asg.employee_number = p_employee_no
    AND    to_date(p_effective_yyyymmdd,'yyyymmdd') BETWEEN asg.assignment_start_date AND to_date(asg.attribute1,'yyyymmdd')
    ;
      
    
    v_return_value := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'ENCOURAGEMENT_INCENTIVE' ,'BASE_AMOUNT' ,v_subsidiary_code),0);
    
    IF v_return_value =0 THEN 
    
    -- select value of item with assignment date
    BEGIN
        SELECT udtv.table_cell_value
        INTO   v_return_value
        FROM   tb_pay_user_dfin_table_m udt
             , tb_pay_user_dfin_table_col_n udtc
             , tb_pay_user_dfin_table_row_n udtr
             , tb_pay_user_dfin_table_value_n udtv
        WHERE  udt.table_name            =  'ENCOURAGEMENT_INCENTIVE'
        AND    udtc.table_seq_no         = udt.table_seq_no
        AND    udtc.user_column_name     = 'ENCOURAGEMENT_INCENTIVE'
        AND    udtr.table_seq_no         = udt.table_seq_no
        AND    p_effective_yyyymmdd BETWEEN udtr.effective_start_yyyymmdd AND udtr.effective_end_yyyymmdd
        AND    udtv.column_seq_no        = udtc.column_seq_no
        AND    udtv.row_no               = udtr.row_no
        AND    p_effective_yyyymmdd BETWEEN udtv.effective_start_yyyymmdd AND udtv.effective_end_yyyymmdd
        AND udtr.lower_limit_critical_value = v_grade;
    EXCEPTION
        WHEN OTHERS THEN
           v_return_value := 0;
    END;

    END IF;
    
    RETURN round(v_return_value);
    
    
EXCEPTION
    WHEN OTHERS THEN 
     --   dbms_output.put_line('p_employee_no =>'||p_employee_no||SQLERRM);
        v_return_value := 0;
        RETURN v_return_value;
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_hardship_allowance                                     */
/* Description    :  Gettig Hardship allowance By Employee and Date      */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2024/08/22            Initial Release                                      */
/******************************************************************************/
FUNCTION get_hardship_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
  v_return_value        NUMBER := 0;
  
BEGIN 
    --GET BASE VALUE
    v_return_value := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'HARDSHIP_ALLW' ,'BASE_VALUE' ,'LGDVN'),0);
    
    IF v_return_value =0 THEN 
    
    -- select value of item with assignment date
    BEGIN
      SELECT  pcvv.result_value
          INTO    v_return_value
          FROM    tb_pay_calc_var_n pcv
                 ,tb_pay_calc_var_value_n pcvv
          WHERE   pcv.subsidiary_code            = 'LGDVN'
          AND     pcv.payroll_calc_variable_name = 'HARDSHIP_ALLOWANCE'
          AND     pcvv.payroll_calc_variable_id  = pcv.payroll_calc_variable_id
          AND     p_effective_yyyymmdd BETWEEN pcvv.effective_start_yyyymmdd  AND pcvv.effective_end_yyyymmdd
          ;
    EXCEPTION
        WHEN OTHERS THEN
           v_return_value := 0;
    END;

    END IF;
    
    RETURN round(v_return_value);
    
    
EXCEPTION
    WHEN OTHERS THEN 
     --   dbms_output.put_line('p_employee_no =>'||p_employee_no||SQLERRM);
        v_return_value := 0;
        RETURN v_return_value;
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_ins_target_flag                                      */
/* Description    :  check if this employee is insuarance Target or not       */
/*                   Target Employee conditions        
/*                   1) if employee's Probation finishs in this month, 
/*                      The Employee who has probation End date before 15th of this month
/*                   2) in attendance , unpaid days have to be under 14days    
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no         in     varchar2   Employee Number
/*                   p_period_id           in     varchar2   Payroll period id 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/17    Sonsuyang        Initial Release                             */
/******************************************************************************/
FUNCTION get_ins_target_flag( p_employee_no IN VARCHAR2 
                             , p_period_id  IN NUMBER ) RETURN VARCHAR2 IS

    v_return                      VARCHAR2(10); 
    v_yyyymm                      tb_pay_calc_period_basis_n.payroll_calc_period_value%TYPE;     
    v_not_ins_days                NUMBER := 0;  
    v_probation_start_yyyymmdd    VARCHAR2(20);                  
    v_probation_end_yyyymmdd      VARCHAR2(20);
    v_unpaid_days                 NUMBER := 0;
    v_out_days                    NUMBER := 0;
BEGIN
  
    SELECT cpb.payroll_calc_period_value
    INTO   v_yyyymm
    FROM  tb_pay_calc_period_basis_n cpb
    WHERE cpb.payroll_calculation_period_id =   p_period_id
    ;
    
    
   --   Check Contribution Start YYYYMM   
   --   Contribution Start MM ? emp_master ? ????? ?? ???? ??
   
    SELECT  'Y'
    INTO   v_return
    FROM   emp_master  em
    WHERE  em.employee_number                = p_employee_no
    AND    em.apply_start_ins_yyyymm        <= v_yyyymm
    ;
    
    
   
   
    BEGIN
        SELECT to_char(em.probation_start_date,'yyyymmdd')
              ,to_char(em.probation_end_date,'yyyymmdd') 
        INTO   v_probation_start_yyyymmdd
             , v_probation_end_yyyymmdd            
        FROM   emp_master em
             , tb_pay_calc_period_basis_n cpb
        WHERE  em.employee_number                = p_employee_no 
        AND    cpb.payroll_calculation_period_id = p_period_id
        AND    cpb.start_yyyymmdd  BETWEEN to_char(em.probation_start_date,'yyyymmdd') AND to_char(em.probation_end_date,'yyyymmdd')
        ;
    EXCEPTION
        WHEN OTHERS THEN 
            v_probation_start_yyyymmdd := NULL;
            v_probation_end_yyyymmdd   := NULL;
    END;
            
   
   
   
   
   -- ???? ???? + ?? + ?? ? ????? 14? ???? ??? ??
   -- 
   BEGIN
   SELECT COUNT(*)
   INTO   v_unpaid_days
   FROM ( 
           SELECT arn.time_and_attendance_date
           FROM  ( 
                    SELECT TRUNC(TO_date(v_probation_start_yyyymmdd,'yyyymmdd'))-1 + ROWNUM ymd
                    FROM  dual
                   CONNECT BY LEVEL <= TRUNC(TO_date(v_probation_end_yyyymmdd,'yyyymmdd')) - TRUNC(TO_date(v_probation_start_yyyymmdd,'yyyymmdd')) + 1
                  ) probation_mm
                 , tb_att_result_n arn                 
                 , tb_att_base_bas_n bas
                 , tb_att_code_c     acc
           WHERE arn.employee_no = p_employee_no
           AND   arn.time_and_attendance_yyyymm =v_yyyymm
           AND   arn.time_and_attendance_date = probation_mm.ymd
           AND   ( v_probation_start_yyyymmdd IS NOT NULL AND v_probation_end_yyyymmdd IS NOT NULL)
           AND   arn.time_and_attendance_date = probation_mm.ymd
           AND   bas.time_and_attendance_yyyymm  = arn.time_and_attendance_yyyymm
           AND   bas.shift_type_code             = arn.shift_type_code
           AND   acc.time_and_attendance_code    = bas.time_and_attendance_code
           AND   ( acc.attendance_days > 0 OR acc.unpaid_days > 0 OR acc.paid_days > 0)
           AND   probation_mm.ymd                        = bas.time_and_attendance_date
           UNION 
           SELECT  attedance_date
           FROM ( 
                    SELECT CAST(DECODE(ab.time_and_attendance_code, 'WH', NULL, DECODE(ar.time_and_attendance_code, 'NN', ar.time_and_attendance_date, DECODE(ac.unpaid_days, 0, NULL, ar.time_and_attendance_date))) AS DATE) attedance_date
                    FROM   tb_att_result_n   ar,
                           tb_att_base_bas_n ab,
                           tb_att_code_c     ac
                    WHERE  ar.time_and_attendance_yyyymm = v_yyyymm
                    AND    ar.employee_no                = p_employee_no
                    AND    ar.subsidiary_code            = ab.subsidiary_code
                    AND    ar.time_and_attendance_date   = ab.time_and_attendance_date
                    AND    ar.shift_type_code            = ab.shift_type_code
                    AND    ar.time_and_attendance_code   = ac.time_and_attendance_code
                    AND    ar.subsidiary_code            = ac.subsidiary_code
                    )
          WHERE attedance_date IS NOT NULL        -- ?? , ????? unpaid days >0 , NN : ???? ( ??, ???)   
       )

    ;
    EXCEPTION
        WHEN OTHERS THEN
            v_unpaid_days := 0;
    END;
    
    --??/?????? 
    BEGIN
        SELECT NVL(SUM(NVL(arn.tardy_hours,0) + NVL(arn.going_out_hours,0))/8,0)
        INTO   v_out_days
        FROM  tb_att_result_n arn
        WHERE arn.employee_no = p_employee_no
        AND   arn.time_and_attendance_yyyymm =v_yyyymm
        AND   ( nvl(tardy_hours,0) <> 0 OR nvl(going_out_hours ,0) <> 0)
        ;
    EXCEPTION
        WHEN OTHERS THEN 
            v_out_days := 0;
    END;
    
    
    
    
    v_not_ins_days := v_unpaid_days + v_out_days;
    
    
    --dbms_output.put_line('v_not_ins_days=>'||v_not_ins_days);
    
    IF v_not_ins_days >=14 THEN
        v_return := 'N';
    END IF;
   
   RETURN v_return;


EXCEPTION
    WHEN OTHERS THEN 
        RETURN 'N';

END; 

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_job_allowance                                        */
/* Description    :  Gettig Job Allowance By Employee and Date                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/09/28            Initial Release                                      */
/******************************************************************************/
FUNCTION get_qualification_allowance( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2,p_subsidiary_code IN VARCHAR2 ) RETURN NUMBER IS
    v_value  NUMBER := 0;
    v_return NUMBER := 0; 

    
/* Cursor
       Each employee can have more than 1 Certifications
       So, We Calculate by cursor
    */
    /* ??? ??? TOPIK ?  ??? ??? ?? ??? ???? ??? ?????.
        ??? TOPIK ? ???? ?? ??? ?? ??? ???? ?? ??? ????.
        code table?? code_data1_value ? ???? ??? ??? ?? code_data2_value ? ???? ??? ??
        ??? ?? ??? ?? ?? ??? ????.
        
        
        TOPIK has 3 grades, Each grades has different amount
        Then Each Grades is different Qualficiation type id
        So in Code Table , i defined to attribute
        
        code_data1_value: Qualification parent type
        code_data2_value : Grade order
        
    */

    CURSOR c_cur  IS    
    SELECT pca.qualification_type_id, pca.qlfc_acquisition_yyyymmdd
    FROM   lgcom_common_code_c ccc1
          ,tb_pay_emp_certification_acq_n pca
    WHERE  ccc1.code_type_code = 'LGVPAY_QUALIFICATION_TYPE_CODE'
    AND   (nvl(ccc1.code_data1_value, ccc1.common_code),  nvl(ccc1.code_data2_value,'x') ) IN (
                                                                                                SELECT nvl(ccc.code_data1_value, ccc.common_code), MAX(nvl(ccc.code_data2_value,'x'))
                                                                                                FROM   tb_pay_emp_certification_acq_n a
                                                                                                       ,lgcom_common_code_c ccc 
                                                                                                WHERE  a.employee_no = p_employee_no
                                                                                                AND    ccc.code_type_code = 'LGVPAY_QUALIFICATION_TYPE_CODE'
                                                                                                AND    ccc.common_code = to_char(a.qualification_type_id)
                                                                                                AND    a.qlfc_acquisition_yyyymmdd <=p_effective_yyyymmdd
                                                                                                GROUP BY nvl(ccc.code_data1_value, ccc.common_code)
                                                                                                )
    AND  pca.employee_no           = p_employee_no
    AND  pca.qlfc_acquisition_yyyymmdd <=  p_effective_yyyymmdd
    AND  pca.qualification_type_id = to_number( ccc1.common_code )

    ;

    
    
BEGIN
        ---TaiDD---20211214---Test the function to add the Base Amount calulation to Qualification Allowance
     v_return := nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no, to_date(p_effective_yyyymmdd,'YYYYMMDD'), 'QUALIFICATION_ALLW' ,'BASE_AMOUNT',p_subsidiary_code ),0);  
      
    IF v_return = 0 THEN
    
    --Check whether there is a planned item in this period, if exists, don't calculate.
    IF lgvpay_common_pkg.get_chcek_planned_item(p_employee_no, to_datE(p_effective_yyyymmdd,'yyyymmdd'), 'QUALIFICATION_ALLW',p_subsidiary_code) = 'Y' THEN
        v_return := lgvpay_common_pkg.get_planned_item_value(p_employee_no, to_date(p_effective_yyyymmdd,'yyyymmdd'), 'QUALIFICATION_ALLW','PAY_VALUE',p_subsidiary_code) ;
    END IF;
    
    FOR c IN c_cur
    LOOP  
        SELECT d.table_cell_value base_value
        INTO   v_value
        FROM   tb_pay_user_dfin_table_m a
             , tb_pay_user_dfin_table_col_n b
             , tb_pay_user_dfin_table_row_n c
             , tb_pay_user_dfin_table_value_n d
        WHERE a.table_name       = 'QUALIFICATION_ALLOWANCE'
        AND   b.table_seq_no     =  a.table_seq_no  
        AND   c.table_seq_no     = b.table_seq_no
        AND   d.row_no           = c.row_no
        AND   d.column_seq_no    = b.column_seq_no
        AND   b.user_column_name = 'QUALIFICATION_ALLOWANCE'
        AND   p_effective_yyyymmdd BETWEEN d.effective_start_yyyymmdd AND d.effective_end_yyyymmdd
        AND   p_effective_yyyymmdd BETWEEN c.effective_start_yyyymmdd AND c.effective_end_yyyymmdd
        AND   c.lower_limit_critical_value = to_char(c.qualification_type_id)
        GROUP BY d.table_cell_value
        
        ;
        v_return := v_return  + v_value;
    END LOOP;
    END IF;
    RETURN v_return;

EXCEPTION
    WHEN OTHERS THEN 
          RETURN 0;
END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_ordinary_wages_for_al                                */
/* Description    :  ???? ?? ??? ?? ???? ? ????           */
/*                   ??? ??? ?? ??? ???? ???????        */
/*                   funcion? ??? ?? ???, ?? ?? ? ?? ???   */
/*                   function? ?????                    
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/18            Initial Release                                      */
/******************************************************************************/
FUNCTION get_ordinary_wages_for_al( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
    v_return NUMBER := 0;
BEGIN  
    SELECT get_ordinary_wages(p_employee_no, p_effective_yyyymmdd, 'B')
    INTO   v_return 
    FROM   dual;
    
    RETURN v_return;
    
EXCEPTION
    WHEN OTHERS THEN
    v_return := 0;
    RETURN   v_return;    
END;
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_ordinary_wages_for_ins                                */
/* Description    :  ??? ??? ?? ???? ???
/*                   ???? ???? ??????? ???? 100%? ?? ??
/*                   ????(20?) ??? ????? ????.            
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_effective_yyyymmdd in     varchar2   effective_yyyymmdd 
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/18            Initial Release                                      */
/******************************************************************************/
FUNCTION get_ordinary_wages_for_ins( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2) RETURN NUMBER IS
    v_subsidiary_code VARCHAR2(100);
    v_return          NUMBER := 0;
BEGIN
    SELECT em.subsidiary_code
    INTO   v_subsidiary_code
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;
    
    
    v_return := get_ordinary_wages(p_employee_no, p_effective_yyyymmdd, 'B');
               
    RETURN v_return;               
                    
END; 


FUNCTION get_ordinary_wages( p_employee_no IN VARCHAR2, p_effective_yyyymmdd IN VARCHAR2,p_base_salry_type IN VARCHAR2) RETURN NUMBER IS
    v_subsidiary_code VARCHAR2(100);
    v_return          NUMBER := 0;
BEGIN
    SELECT em.subsidiary_code
    INTO   v_subsidiary_code
    FROM   emp_master em
    WHERE  employee_number = p_employee_no
    ;
    
    
    v_return := nvl(lgvpay_info_pkg.get_base_pay( p_employee_no   , p_effective_yyyymmdd , v_subsidiary_code  , p_base_salry_type ) ,0)
               +nvl(lgvpay_info_pkg.get_position_allowance( p_employee_no , p_effective_yyyymmdd ) ,0)
               +nvl(lgvpay_info_pkg.get_job_allowance( p_employee_no, p_effective_yyyymmdd ) ,0)
               +nvl(lgvpay_info_pkg.get_qualification_allowance( p_employee_no , p_effective_yyyymmdd,v_subsidiary_code ) ,0)
               +nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE1','BASE_AMOUNT',v_subsidiary_code ) ,0) 
               +nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE2','BASE_AMOUNT',v_subsidiary_code ) ,0)
               +nvl(lgvpay_common_pkg.get_planned_item_value( p_employee_no , to_date(p_effective_yyyymmdd,'yyyymmdd') , 'ADJ_ALLOWANCE3','BASE_AMOUNT',v_subsidiary_code ) ,0);
               
    RETURN v_return;    
  

END; 
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_run_result                                           */
/* Description    :  ????? ?? ?? ???? FUNCTION?          
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                   p_payroll_calculation_exec_id IN NUMBER ?? ID
/*                   p_employee_no        in     varchar2   Employee Number
/*                   p_payroll_item_name  in     varchar2   Payroll_item_name 
/*                   p_detail_name        in     varchr2    Detail Name
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/18                   Initial Release                               */
/* 2018/10/01   KimTaehyun      Separation Retroactive Payroll                */
/******************************************************************************/
FUNCTION get_run_result(p_payroll_calculation_exec_id IN NUMBER
                       ,p_employee_no                 IN VARCHAR2
                       ,p_payroll_item_name           IN VARCHAR2
                       ,p_detail_name                 IN VARCHAR2
                       ,p_subsidiary_code             in VARCHAR2 ) RETURN NUMBER IS

    v_result_value              VARCHAR2(100);
    v_retroactive_flag          tb_pay_calc_exec_n.retroactive_flag%TYPE := NULL; 
BEGIN
  
    --< 20181001 KTH Start Add
    -- Seperation Actual or Retroactive
    SELECT NVL(a.retroactive_flag,'N')
    INTO   v_retroactive_flag
    FROM   tb_pay_calc_exec_n a
    WHERE  a.payroll_calculation_exec_id = p_payroll_calculation_exec_id
    ;
    -->
    
    IF v_retroactive_flag = 'N' THEN
  
        /* ????? ?? sum, ??? max?? ????. */
        SELECT CASE WHEN pid.pay_calc_rslt_detail_type_code IN ('A','N') THEN TO_CHAR(sum(NVL(pcrn.result_value,0)))
               ELSE
                   MAX(pcrn.result_value)
               END
        INTO   v_result_value
        FROM   tb_pay_calc_result_n  pcrn
              ,tb_pay_payroll_item_m ppi
              ,tb_pay_item_detail_n  pid
        WHERE pcrn.payroll_calculation_exec_id = p_payroll_calculation_exec_id
        AND   pcrn.employee_no                 = p_employee_no
        AND   ppi.payroll_item_name            = p_payroll_item_name
        AND   ppi.subsidiary_code              = p_subsidiary_code
        AND   pcrn.payroll_item_id             = ppi.payroll_item_id
        AND   pid.payroll_item_id              = ppi.payroll_item_id
        AND   pid.additional_input_value       = p_detail_name
        AND   pcrn.payroll_item_detail_detail_id    = pid.payroll_item_detail_detail_id
        GROUP BY pid.pay_calc_rslt_detail_type_code
        ;
        
    --< 20180914 KTH Start Add
    --Retroactive Payroll Calculate
    ELSE
    
        /* ????? ?? sum, ??? max?? ????. */
        SELECT CASE WHEN pid.pay_calc_rslt_detail_type_code IN ('A','N') THEN TO_CHAR(sum(NVL(rpcr.result_value,0)))
               ELSE
                   MAX(rpcr.result_value)
               END
        INTO   v_result_value
        FROM   tb_retro_pay_calc_result_n  rpcr
              ,tb_pay_payroll_item_m ppi
              ,tb_pay_item_detail_n  pid
        WHERE rpcr.payroll_calculation_exec_id = p_payroll_calculation_exec_id
        AND   rpcr.employee_no                 = p_employee_no
        AND   ppi.payroll_item_name            = p_payroll_item_name
        AND   ppi.subsidiary_code              = p_subsidiary_code
        AND   rpcr.payroll_item_id             = ppi.payroll_item_id
        AND   pid.payroll_item_id              = ppi.payroll_item_id
        AND   pid.additional_input_value       = p_detail_name
        AND   rpcr.payroll_item_detail_detail_id    = pid.payroll_item_detail_detail_id
        GROUP BY pid.pay_calc_rslt_detail_type_code
        ;
    
    END IF;
    -->
    
    
    RETURN v_result_value;
EXCEPTION
    WHEN OTHERS THEN 
        v_result_value := '';
        RETURN v_result_value;
  
END;                          
                             
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_type_work_hours                                      */
/* Description    :   get work hours function                                 */
/* Date           In Charge         Description                               */
/* ------------ -------- -------------------------------                      */
/* 2021/03/23     HMT_20210323      Get work hours function                               */
/******************************************************************************/
FUNCTION get_type_work_hours(p_subsidiary_code           IN VARCHAR2
                            ,p_atendance_date            IN DATE
                       	    ,p_atendance_code            IN VARCHAR2
                            ,p_shift_type_code           IN VARCHAR2
                            ,p_work_hours                IN NUMBER
                            ,p_type                      IN VARCHAR2 ) RETURN NUMBER IS

    v_return     NUMBER := 0;
BEGIN
  
    IF p_type = 'perfect_work_hours' THEN
      IF p_atendance_code = 'WH' THEN 
        v_return := 0;    
      ELSE
        IF p_shift_type_code LIKE '3%' THEN  v_return := 9.5;
        ELSIF p_atendance_code LIKE '102%' THEN --2S10G add_20230719@KimBiho
              v_return := 8;  
        ELSE v_return := p_work_hours;
           IF TO_NUMBER(TO_CHAR(p_atendance_date, 'D')) IN ('2','3','4','5') 
             AND p_atendance_date >= TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD')
           THEN  v_return := 9; END IF;
           BEGIN
               select NVL(tb.public_hours, 8) into v_return
               from tb_att_holiday_info_n tb
               where tb.subsidiary_code = p_subsidiary_code
                 and tb.holiday_date = p_atendance_date;
               EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  v_return := v_return;
           END;  
        END IF;
      END IF;
    END IF;
    
    RETURN v_return;
 
END;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name    : get_type_work_hours                                      */
/* Description    :   get work hours function                                 */
/* Date           In Charge         Description                               */
/* ------------ -------- -------------------------------                      */
/* 2022/01/30     HMT_20220130      Get work hours function                               */
/******************************************************************************/
FUNCTION get_work_hours(p_subsidiary_code           IN VARCHAR2
                       ,p_employee_no               IN VARCHAR2
                       ,p_atendance_date            IN DATE
                       ,p_atendance_code            IN VARCHAR2
                       ,p_shift_type_code           IN VARCHAR2
                       ,p_work_hours                IN NUMBER
                       ,p_type                      IN VARCHAR2 ) RETURN NUMBER IS

    v_return                  NUMBER := 0;
    
BEGIN
    
    IF p_type = 'pay_perfect_hours' THEN
      IF p_atendance_code = 'WH' THEN v_return := 0;
        ELSE
        IF p_shift_type_code LIKE '3%' THEN 
             IF  p_work_hours <> 0 THEN v_return := 9.5; END IF; 
        ELSIF p_shift_type_code like '102%' THEN --2S10G Add_20230719@KimBiho
          IF p_work_hours <> 0 THEN v_return := 8; END IF;          
        ELSE v_return := p_work_hours;
             IF TO_NUMBER(TO_CHAR(p_atendance_date, 'D')) IN ('2','3','4','5') 
               AND p_atendance_date >= TO_DATE(lgvhr_common_pkg.decode_lookup('LGVHR_ATT_COMMON_CODE','ALL_SATURDAY_OFF_START_DATE','A1',''),'YYYYMMDD')
               THEN  v_return := 9;
             ELSIF TO_CHAR(p_atendance_date,'YYYY-MM-DD') = '2024-05-04' THEN v_return := 9; --Additional logic due to special cases 240606@KimBiho 
             END IF;
               BEGIN
               select NVL(tb.public_hours, 8) into v_return
               from tb_att_holiday_info_n tb
               where tb.subsidiary_code = p_subsidiary_code
                 and tb.holiday_date = p_atendance_date;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_return := v_return;
               END;  
        END IF;
      END IF;
      IF p_atendance_code <> 'WH' THEN
        BEGIN
        select get_type_work_hours(p_subsidiary_code, s.working_day, p_atendance_code,p_shift_type_code, 8, 'perfect_work_hours') into v_return
          from tb_att_swap_holiday_request_n s
         where s.employee_no = p_employee_no
           AND s.weekly_holiday = p_atendance_date
           AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
           AND NOT EXISTS (select 1
                                  from tb_att_swap_holiday_request_n s1
                                 where s1.employee_no = p_employee_no
                                  AND s1.working_day = p_atendance_date
                                  AND s1.weekly_holiday = s.working_day
                                   AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
           AND s.request_seq_no = (select max(ss.request_seq_no)
                                    from tb_att_swap_holiday_request_n ss
                                   where ss.employee_no = p_employee_no
                                     AND ss.weekly_holiday = p_atendance_date
                                     AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_return := v_return;
        END;  
      END IF;
      
      IF v_return > 0 THEN
        BEGIN
        select 0 into v_return
          from tb_att_swap_holiday_request_n s
         where s.employee_no = p_employee_no
           AND s.working_day = p_atendance_date
           AND (s.PROGRESS_STATUS_CODE = '40' OR s.CONFIRM_FLAG = 'Y')
           AND NOT EXISTS (select 1
                                  from tb_att_swap_holiday_request_n s1
                                 where s1.employee_no = p_employee_no
                                  AND s1.weekly_holiday = p_atendance_date
                                  AND s1.working_day = s.weekly_holiday
                                   AND (s1.PROGRESS_STATUS_CODE = '40' OR s1.CONFIRM_FLAG = 'Y'))
          AND s.request_seq_no = (select max(ss.request_seq_no)
                                from tb_att_swap_holiday_request_n ss
                               where ss.employee_no = p_employee_no
                                 AND ss.working_day = p_atendance_date
                                 AND (ss.PROGRESS_STATUS_CODE = '40' OR ss.CONFIRM_FLAG = 'Y'));
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_return := v_return;
        END;  
      END IF;
      
    END IF;
    
    RETURN v_return;
 
END;

end lgvpay_info_pkg;
/
