CREATE OR REPLACE PACKAGE VHR_MGR.lgvinf_if_pay_batch_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : [PJT0015428]17_베트남법인 표준 급여 ,근태 시스템 구축 프로젝트
    /* Module       : LGVINF
    /* Program Name : lgvinf_if_pay_batch_pkg.pls
    /* Reference by :
    /* Description  : Payroll I/F 관련 모음(ERP)
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2018-03-07   Son Suyang      1.0      initialize
    /******************************************************************************/
    --과표추가 인터페이스
    PROCEDURE main_assess_add(p_errcode             OUT VARCHAR2
                             ,p_errbuf              OUT VARCHAR2
                             ,p_application_user_id IN NUMBER
                             );

    
    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVINF';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;
    
    g_system_code CONSTANT lgcom_code_type_code_c.system_code%TYPE := 'LGVHR';
    g_application_key CONSTANT varchar2(36) := '931B639F-3834-43A6-AB95-19285D31EB98'; --기존에 사용되어 있어서...    
    

END lgvinf_if_pay_batch_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvinf_if_pay_batch_pkg AS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_assess_add                                           */
/* Description    : 과표추가 정보 I/F                                         */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2018-03-07   Son Suyang      1.0      initialize
/******************************************************************************/
PROCEDURE main_assess_add(p_errcode              OUT VARCHAR2
                          ,p_errbuf              OUT VARCHAR2
                          ,p_application_user_id IN  NUMBER
                          )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0011';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    v_system_end_date date := lgvhr_common_pkg.end_of_time;
    
    v_plan_id                       number ; 
    v_payroll_item_id               number             := null;
    v_payroll_item_detail_id        number             := null;
    v_hire_date                     date               := null;
    v_retire_date                   date               := null;
    v_apply_start_date              date               := null;
    v_apply_end_date                date               := null;
    v_start_date                    date               := null;
    v_end_date                      date               := null;
    
    cursor cur_vi
    is
        -- 인터페이스 테이블에는 여러개의 과표추가가 들어올수 있어서 이중에 code에 등록된 것만 처리함 
        select eai_seq_id
              ,data_interface_type_code
              ,eai_interface_date
              ,application_transfer_flag
              ,application_transfer_date
              ,business_group_id
              ,subsidiary_id
              ,subsidiary_name
              ,employee_no
              ,execution_yyyymm
              ,assessment_type_code
              ,assessment_add_amount
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,last_update_date       
        from   tb_intf_assess_add_r_p_i         xlc
        where  xlc.application_transfer_flag = 'N'
       -- and    xlc.employee_no = 'VH002680'
        and    xlc.assessment_type_code IN ( select a.common_code
                                             from   lgcom_common_code_c a
                                             where a.code_type_code = 'LGVHR_PAY_INTF_TYPE_CODE'
                                             and   a.use_flag ='Y')  
        order by xlc.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    for rec IN cur_vi
    loop
        begin
            g_step := 'main_assess_add : Data Create';
            
            -- 입사일자 가져옴
            select em.date_hire_subsidiary, nvl(em.date_retire,v_system_end_date)
            into   v_hire_date, v_retire_date
            from   emp_master em
            where  employee_number = rec.employee_no
            ;
            
            
            -- 급여적용기간 가져오기 
            -- 인터페이스 테이블의 execution_yyyymm 는 중국기준으로 데이터가 만들어져서
            -- 20~19일 기준으로 월을 생성해서 ERP에서 넘겨줌
            -- 그래서 , 데이터가 생성되는 일자 last_update_date 를 기준으로 베트남에는 적용함
            -- 즉, last_update_date 가 2017-12-21 이면 2017-12 월 급여에 반영하고 2018-01-01 이면 2018-01 급여에 반영함 
            -- 베트남은 매월 1~5일사이에 EAI 데이터를 가져올거라서 전월 데이터는 전월에 당월 데이터는 당월에 반영함 
            
            select to_date(ppc.start_yyyymmdd,'yyyymmdd'), to_date(ppc.end_yyyymmdd,'yyyymmdd')
            into   v_apply_start_date, v_apply_end_date
            from   tb_pay_calc_period_basis_n ppc
            where  ppc.subsidiary_code = 'LGDVN'
            and    to_char(rec.last_update_date,'yyyymmdd') between ppc.start_yyyymmdd and ppc.end_yyyymmdd
            ;
            
            
            v_payroll_item_id               := null;
            v_payroll_item_detail_id        := null;
            
            -- 급여항목의 id와 detail id 가져오기 
            select ppi.payroll_item_id
                 , pdi.payroll_item_detail_detail_id
            into   v_payroll_item_id
                 , v_payroll_item_detail_id
            from lgcom_common_code_c ccc
                ,tb_pay_payroll_item_m ppi
                ,tb_pay_item_detail_n  pdi
            where ccc.code_type_code      = 'LGVHR_PAY_INTF_TYPE_CODE'
            and   ccc.use_flag            = 'Y'
            and   ccc.common_code         = rec.assessment_type_code
            and   ppi.subsidiary_code     = 'LGDVN'
            and   ppi.payroll_item_name   = ccc.code_data1_value
            and   pdi.payroll_item_id     = ppi.payroll_item_id
            and   pdi.additional_input_value = 'PAY_VALUE';



            v_start_date := greatest(v_apply_start_date,v_hire_date);
            v_end_date   := v_apply_end_date;
            
            v_plan_id := sq_tb_pay_item_payment_plan_n.nextval;
            
            g_step := 'main_assess_add : Table insert ';
            
            
            insert into tb_pay_item_payment_plan_n 
                  (payroll_item_payment_plan_id
                  ,payroll_item_id
                  ,employee_no
                  ,apply_start_date
                  ,apply_end_date
                  ,retroactive_flag
                  ,creation_date
                  ,creation_user_id
                  )
            values(v_plan_id          --payroll_item_payment_plan_id
                  ,v_payroll_item_id
                  ,rec.employee_no    --employee_no
                  ,v_start_date       --apply_start_date
                  ,v_end_date         --apply_end_date
                  ,'N'       --retroactive_flag
                  ,sysdate   --creation_date
                  ,v_user_id --creation_user_id
                  )
            ;
            
            
            
            insert into tb_pay_payment_plan_detail_n
                  (payroll_item_pay_pln_detail_id
                    ,payroll_item_payment_plan_id
                    ,payroll_item_detail_detail_id
                    ,apply_target_value
                    ,creation_date
                    ,creation_user_id
                    ,last_update_date
                    ,last_update_user_id
                    )
            select sq_tb_pay_pay_plan_detail_n.nextval
                  ,v_plan_id
                  ,v_payroll_item_detail_id
                  ,rec.assessment_add_amount
                  ,sysdate
                  ,v_user_id
                  ,sysdate
                  ,v_user_id
            from  dual;  
            
            --i/f 결과 처리(정상)
            update tb_intf_assess_add_r_p_i         xlc
            set    xlc.application_transfer_flag = 'Y'
                  ,xlc.application_transfer_date = sysdate
            where  xlc.eai_seq_id = rec.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
     --   commit;
    end loop;
    
EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_assess_add)';
        p_errcode := sqlcode;
        p_errbuf  := substr(sqlerrm, 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_assess_add;



END lgvinf_if_pay_batch_pkg;
/
