CREATE OR REPLACE PACKAGE VHR_MGR.lgvpay_calculation_set_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : [PJT0015428]17_베트남법인 표준 급여 ,근태 시스템 구축 프로젝트
    /* Module       : LGVPAY
    /* Program Name : lgvpay_calculation_set_pkg.pls
    /* Reference by :
    /* Description  : 급여 대상자 관련 모음
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-11-21   Jaehyun Kim    1.0      initialize
    /******************************************************************************/
    --급여대상자 생성
    PROCEDURE creation_target_employee(p_errcode             OUT VARCHAR2
                                      ,p_errbuf              OUT VARCHAR2
                                      ,p_create_cnt          OUT NUMBER
                                      ,p_yyyymm              IN VARCHAR2
                                      ,p_subsidiary_code     IN VARCHAR2
                                      ,p_payroll_type_code   IN VARCHAR2
                                      ,p_retire_flag         IN VARCHAR2
                                      ,p_application_user_id IN NUMBER
                                      );

    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

    g_system_code CONSTANT lgcom_code_type_code_c.system_code%TYPE := 'LGVHR';

END lgvpay_calculation_set_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvpay_calculation_set_pkg AS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : creation_target_employee                                  */
/* Description    : 급여대상자 생성                                           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                p_errcode                OUT     VARCHAR2   오류 코드
/*                p_errbuf                 OUT     VARCHAR2   오류 내용
/*                p_create_cnt             OUT     NUMBER     대상자 생성 건수
/*                p_yyyymm                 IN      VARCHAR2   년월
/*                p_subsidiary_code        IN      VARCHAR2   법인코드
/*                p_payroll_type_code      IN      VARCHAR2   급여/상여유형
/*                p_retire_flag            IN      VARCHAR2   퇴직자포함 여부
/*                p_application_user_id    IN      NUMBER     사용자 Id
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/21  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE creation_target_employee(p_errcode             OUT VARCHAR2
                                  ,p_errbuf              OUT VARCHAR2
                                  ,p_create_cnt          OUT NUMBER
                                  ,p_yyyymm              IN VARCHAR2
                                  ,p_subsidiary_code     IN VARCHAR2
                                  ,p_payroll_type_code   IN VARCHAR2
                                  ,p_retire_flag         IN VARCHAR2
                                  ,p_application_user_id IN NUMBER
                                  )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAYC0014';
    v_user_id         number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용

    v_chk_cnt         number;         --검증용
    
    v_calc_set_id     number;
    v_calc_set_name   varchar2(240);

    v_exception       exception;

BEGIN
    if p_application_user_id is not null
    then
        v_user_id := p_application_user_id;
    end if;

    g_step := 'Get Set Name';
    --대상자 세트명 : p_yyyymm||' '||PAYROLL_TYPE_CODE 의 Description - 예)201711 Monthly Payroll
    begin
        select substr(p_yyyymm,5,2)||'/'||substr(p_yyyymm,1,4) || ' ' || substrb(a.common_code_name, 1, 233)
       -- select p_yyyymm|| ' ' || substrb(a.common_code_name, 1, 233)
        into   v_calc_set_name
        from   lgcom_common_code_multi_lang_c a
        where  a.code_type_code = 'LGVHR_PAY_RUN_TYPE'
        and    a.common_code    = p_payroll_type_code --'MTH'
        and    a.language_code  ='en'
        ;
    exception
        when others then
            p_errbuf := 'Set Name Create Error : Common Code(LGVHR_PAY_RUN_TYPE)';
            raise v_exception;
    end;

    --대상자 세트 생성
    g_step := 'Set Name Check : 생성 가능여부';
    if v_chk_cnt > 0
    then
        p_errbuf := '생성 불가능한 대상자 세트 입니다.';
        raise v_exception;
    end if;    
    
    g_step := 'Set Name Check : 생성여부';
    select count(*)
          ,max(pcs.payroll_calculation_set_id)
    into   v_chk_cnt
          ,v_calc_set_id
    from   tb_pay_calc_set_n pcs
    where  pcs.subsidiary_code              = p_subsidiary_code       
    and    pcs.payroll_calculation_set_name = v_calc_set_name
    ;
    
    if v_chk_cnt = 0
    then
        g_step := 'Set Name Insert';
        v_calc_set_id := sq_tb_pay_calc_set_n.nextval;
        
        insert into tb_pay_calc_set_n
              (payroll_calculation_set_id
              ,payroll_calculation_set_name
              ,subsidiary_code
              ,resignation_flag
              ,payroll_type_code
              ,creation_date
              ,creation_user_id
              ,last_update_date
              ,last_update_user_id
              )
        values(v_calc_set_id
              ,v_calc_set_name
              ,p_subsidiary_code
              ,p_retire_flag
              ,p_payroll_type_code
              ,sysdate
              ,v_user_id
              ,sysdate
              ,v_user_id
              )
        ;
    else
        g_step := 'Set Name Update';
        update tb_pay_calc_set_n pcs
        set    pcs.resignation_flag    = p_retire_flag
              ,pcs.last_update_date    = sysdate
              ,pcs.last_update_user_id = v_user_id
        where  pcs.subsidiary_code              = p_subsidiary_code       
        and    pcs.payroll_calculation_set_name = v_calc_set_name
        --and    pcs.payroll_calculation_set_id   = v_calc_set_id
        ;
    end if;
    
    --대상자 생성
    --기존 data 삭제
    g_step := 'Set Target Person Delete';
    delete 
    from   tb_pay_calc_set_target_per_n pct
    where  pct.payroll_calculation_set_id = v_calc_set_id
    ;
    
    g_step := 'Set Target Person Create';
    insert into tb_pay_calc_set_target_per_n
          (payroll_calculation_set_id
          ,employee_no
          ,creation_date
          ,creation_user_id
          )
    select v_calc_set_id
          ,em.employee_number
          ,sysdate
          ,v_user_id
    from   emp_master em
          ,tb_pay_calc_period_basis_n cpb
    where  cpb.subsidiary_code           = p_subsidiary_code
    and    cpb.payroll_calc_period_value = p_yyyymm
    and    cpb.subsidiary_code           = em.subsidiary_code
    and    em.fse_yn                     = 'N' --FSE 제외
    and    em.flsa_yn                    = 'N' --단기파견자 제외       
    and    em.date_hire_subsidiary       <= to_date(cpb.end_yyyymmdd, 'YYYYMMDD')
    and    nvl(em.date_retire, lgvhr_common_pkg.end_of_time) >= case when p_retire_flag = 'Y'
                                                                     then to_date(cpb.start_yyyymmdd, 'YYYYMMDD') 
                                                                     when p_retire_flag = 'N'
                                                                     then to_date(cpb.end_yyyymmdd, 'YYYYMMDD') + 1
                                                                     else null
                                                                end 
    ;
    
    --처리건수
    p_create_cnt := sql%rowcount;
     
    commit;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        p_errcode := sqlcode;
        p_errbuf  := substr(nvl(p_errbuf, sqlerrm), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END creation_target_employee;

END lgvpay_calculation_set_pkg;
/
