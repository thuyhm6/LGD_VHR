CREATE OR REPLACE PACKAGE VHR_MGR.lgvpay_upload_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : [PJT0015428]17_베트남법인 표준 급여 ,근태 시스템 구축 프로젝트
    /* Module       : LGVPAY
    /* Program Name : lgvpay_upload_pkg.pls
    /* Reference by :
    /* Description  : Excel Upload 처리 모음
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-11-16   Jaehyun Kim    1.0      initialize
    /* 2022-06-01   HaMinhTHuy     20.     Send pay slip by email             HMT_20220601
    /******************************************************************************/
    --급여항목 업로드
    PROCEDURE entry_payroll_item_by_item(p_errcode             OUT VARCHAR2
                                        ,p_errbuf              OUT VARCHAR2
                                        ,p_session_id          IN NUMBER
                                        ,p_payroll_item_id     IN NUMBER
                                        ,p_calc_period_id      IN NUMBER
                                        ,p_application_user_id IN NUMBER
                                        );
    --급여대상자 업로드
    PROCEDURE upload_payroll_employee(p_errcode             OUT VARCHAR2
                                     ,p_errbuf              OUT VARCHAR2
                                     ,p_session_id          IN NUMBER
                                     ,p_payroll_calc_set_id IN NUMBER
                                     ,p_application_user_id IN NUMBER
                                     );
     --HMT_20220601 Start                                
    PROCEDURE upload_payroll_employee_email(p_errcode              OUT VARCHAR2
                                                             ,p_errbuf                 OUT VARCHAR2
                                                             ,p_session_id            IN NUMBER
                                                             ,p_pay_month           IN VARCHAR2
                                                             ,p_application_user_id IN NUMBER
                                                             );
                                                             
     PROCEDURE update_payroll_employee_email(p_errcode              OUT VARCHAR2
                                                             ,p_errbuf                 OUT VARCHAR2
                                                             ,p_calset_id             IN NUMBER
                                                             ,p_flag                    IN VARCHAR2
                                                             ,p_error                   IN VARCHAR2
                                                             ,p_type                   IN VARCHAR2
                                                             ,p_pay_month           IN VARCHAR2
                                                             ,p_employee_no         IN VARCHAR2
                                                             ,p_application_user_id IN VARCHAR2
                                                             );
     --HMT_20220601 End                                
    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVPAY';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;

    g_system_code CONSTANT lgcom_code_type_code_c.system_code%TYPE := 'LGVHR';

END lgvpay_upload_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvpay_upload_pkg AS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : entry_payroll_item_by_item                                */
/* Description    : 급여항목 업로드                                           */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                p_errcode                OUT     VARCHAR2   오류 코드
/*                p_errbuf                 OUT     VARCHAR2   오류 내용
/*                p_session_id             IN      NUMBER     Session Id : 엑셀 업로드용
/*                p_payroll_item_id        IN      NUMBER     급여항목 Id
/*                p_calc_period_id         IN      NUMBER     급여기산기간 Id
/*                p_application_user_id    IN      NUMBER     사용자 Id
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/15  Jaehyun Kim  Initial Release                                   */
/* 2021/07/19  HMT_20210719 If apply_end_date >= import of end_date, apply_end_date =  end_date -1*/
/******************************************************************************/
PROCEDURE entry_payroll_item_by_item(p_errcode             OUT VARCHAR2
                                    ,p_errbuf              OUT VARCHAR2
                                    ,p_session_id          IN NUMBER
                                    ,p_payroll_item_id     IN NUMBER
                                    ,p_calc_period_id      IN NUMBER
                                    ,p_application_user_id IN NUMBER
                                    )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAYC0003';
    v_user_id         number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    v_system_end_date date := lgvhr_common_pkg.end_of_time;
    v_date_format     varchar2(10) := 'DD/MM/YYYY';
    
    v_fix_cnt         number := 5;    --고정된 Attribute칼럼의 개수
    v_item_detail_cnt number;         --급여항목 세부항목 개수
    v_rec_count       number := 0;    --upload 건수
    v_err_count       number := 0;    --오류 건수
    v_attribute       varchar2(4000); --Attribute칼럼의 Data
    v_multiple_flag   varchar2(1);    --급여항목의 mulitiple 가능 여부
    v_recurring_flag  varchar2(1);    --급여항목의 recurring 여부
    v_calc_start_date date;           --급여기산시작일자
    v_calc_end_date   date;           --급여기산종료일자
    
    v_start_date      date;           --시작일자
    v_end_date        date;           --종료일자
    v_plan_id         number;         --시퀀스(급여항목지급계획아이디)
    v_chk_cnt         number;         --검증용
    v_error_msg       varchar2(4000); --검증오류 메세지
    v_sql             clob;           --동적쿼리
        
    v_exception       exception;

    cursor cur_excel
    is
        select li.seq_no
              ,trim(li.attribute1) employee_no       --Employee No
              ,trim(li.attribute2) employee_name     --Employee Name
              ,trim(li.attribute3) org_name          --Organization name
              ,trim(li.attribute4) apply_start_date  --Start Date(dd/mm/yyyy)
              ,trim(li.attribute5) apply_end_date    --End Date(dd/mm/yyyy)
        from   lgcom_import_n li
        where  li.session_id = p_session_id
        and    li.seq_no > 1   
        order by li.seq_no  --처리 순서를 정하기 위해
    ;
    
    function get_attribute_data(p_session_id in number
                               ,p_seq_no     in number
                               ,p_pos        in number
                               )
    return varchar2
    is
        v_sql    varchar2(4000);
        v_return varchar2(4000);
    begin
        v_sql := ' select trim(li.attribute' || p_pos || ')'
              || ' from   lgcom_import_n li'
              || ' where  li.session_id = ' || p_session_id
              || ' and    li.seq_no = ' || p_seq_no;
                  
        execute immediate v_sql into v_return;
        return v_return;
    exception
        when others then
            return ' '; --오류와 null을 구분하기 위해
    end;
BEGIN
    if p_application_user_id is not null
    then
        v_user_id := p_application_user_id;
    end if;
    
    g_step := 'Get Upload Data Count';
    --Upload Data 개수
    select count(*)
    into   v_chk_cnt
    from   lgcom_import_n li
    where  li.session_id = p_session_id
    ;
    
    if v_chk_cnt < 2
    then
        p_errbuf := 'No Upload Data Found';
        raise v_exception;
    end if;    
    
    g_step := 'Get Pay Item Detail Count';
    --세부항목개수
    select count(*)
    into   v_item_detail_cnt
    from   tb_pay_item_detail_n pid
    where  pid.payroll_item_id = p_payroll_item_id
    ;
    
    if v_item_detail_cnt = 0
    then
        p_errbuf := 'Not Pay Item Detail';
        raise v_exception;
    end if;
    
    g_step := 'Get Pay Item Info : Multiple Flag';
    select nvl(max(pcm.payroll_apply_flag), 'N')
    into   v_multiple_flag
    from   tb_pay_calc_mthd_n pcm
    where  pcm.payroll_calc_method_code = 'MULTIPLE_FLAG'
    and    pcm.payroll_item_id          = p_payroll_item_id
    ;           
    
    g_step := 'Get Pay Item Info : Recurring Flag';
    select nvl(max(pcm.payroll_apply_flag), 'N')
    into   v_recurring_flag
    from   tb_pay_calc_mthd_n pcm
    where  pcm.payroll_calc_method_code = 'RECURRING_FLAG'
    and    pcm.payroll_item_id          = p_payroll_item_id
    ;  
    
    g_step := 'Payroll Item Detail Count Check';
    --세부항목개수 체크(title로 체크)
    --세부항목개수의 위치에 title 있는지 체크(해당위치 not null 해당위치 + 1 null)
    v_attribute := get_attribute_data(p_session_id, 1, (v_fix_cnt + v_item_detail_cnt));
   
    if v_attribute = ' ' --함수 오류
    then
        p_errbuf := 'get_attribute_data Function Error';
        raise v_exception;
    elsif v_attribute is null
    then
        p_errbuf := 'Upload Data Error : Item Detail Count';
        raise v_exception;
    end if;
    
    v_attribute := get_attribute_data(p_session_id, 1, (v_fix_cnt + v_item_detail_cnt + 1));
    
    if v_attribute = ' ' --함수 오류
    then
        p_errbuf := 'get_attribute_data Function Error';
        raise v_exception;
    elsif v_attribute is not null
    then
        p_errbuf := 'Upload Data Error : Item Detail Count';
        raise v_exception;
    end if;
     
    g_step := 'Get Pay Calc Period';
    --급여기산일자 가져오기
    select to_date(a.start_yyyymmdd, 'YYYYMMDD')
          ,to_date(a.end_yyyymmdd, 'YYYYMMDD')
    into   v_calc_start_date
          ,v_calc_end_date
    from   tb_pay_calc_period_basis_n a
    where  a.payroll_calculation_period_id = p_calc_period_id
    ;
    
    for rec IN cur_excel
    loop
        begin
            v_rec_count  := v_rec_count + 1;
            v_error_msg  := null;
            v_start_date := null;
            v_end_date   := null;
            
            g_step := 'Upload Data Check : Employee No';
            begin
                select greatest(em.date_hire_subsidiary, v_calc_start_date)
                into   v_start_date
                from   emp_master em
                where  em.employee_number = rec.employee_no
                and    em.date_hire_subsidiary <= v_calc_end_date
                and    nvl(em.date_retire, v_system_end_date) >= v_calc_start_date
                ;
            exception
                when others then
                    v_error_msg := 'Employee No - ' || sqlerrm;
            end;
            
            if v_error_msg is null
            then
                g_step := 'Upload Data Check : Start Date';
                --적용시작일자는 급여기산기간
                if rec.apply_start_date is null
                then
                    v_error_msg := v_error_msg || ' Please input Apply Start Date.';                 
                elsif lgcom_excel_pkg.is_date(rec.apply_start_date, v_date_format) = 'Y'
                then
                    if to_date(rec.apply_start_date, v_date_format) < v_calc_start_date 
                      or to_date(rec.apply_start_date, v_date_format) > v_calc_end_date
                    then
                        v_error_msg := v_error_msg || ' Apply Start Date must be in the middle of Payroll Period';
                    end if;
                else
                    v_error_msg := v_error_msg || ' ' || 'Apply Start Date format is not ' || v_date_format || ' or Change the excel file cell format to Text';
                end if;
                
                g_step := 'Upload Data Check : End Date';
                --적용종료일자는 Recurring 이면 null 아니면 급여기산종료일
                if lgcom_excel_pkg.is_date(rec.apply_end_date, v_date_format) = 'Y'
                then
                    if v_recurring_flag = 'Y'
                      and rec.apply_end_date NOT IN ( '31/12/4712' ,'')
                    then
                        v_error_msg := v_error_msg || ' This item is "Recurring". So Apply End date has to be "31/12/4712" or "Empty"';
                    elsif v_recurring_flag = 'N'
                      and (rec.apply_end_date is null
                          or to_date(rec.apply_end_date, v_date_format) != v_calc_end_date
                          )
                    then
                        v_error_msg := v_error_msg || 'This item is "Non-Recurring" , Apply Start date has to be same with Payroll End Date.';
                    end if;
                else
                    v_error_msg := v_error_msg || ' ' || 'Apply End Date format is not ' || v_date_format || ' or Change the excel file cell format to Text';
                end if;
                                
                --적용일자가 정상일때 중복체크
                if v_error_msg is null
                then
                    v_start_date := greatest(v_start_date, to_date(rec.apply_start_date, v_date_format));
                    v_end_date   := nvl(to_date(rec.apply_end_date, v_date_format), v_system_end_date);
                        
                    g_step := 'Upload Data Check : Multiple Item';
                    if v_multiple_flag = 'N'
                    then  
                        
                        select count(*)
                        into   v_chk_cnt
                        from   tb_pay_item_payment_plan_n ppp
                        where  ppp.payroll_item_id = p_payroll_item_id
                        and    ppp.employee_no     = rec.employee_no
                        and    ppp.apply_start_date <= v_end_date
                        and    ppp.apply_end_date >= v_start_date
                        ;
                            
                        if v_chk_cnt > 0 
                        then
                          --HMT_20210719 Start
                            --v_error_msg := v_error_msg || 'The Apply Period is duplicated.';
                          for rec_u in ( select ppp.payroll_item_payment_plan_id, ppp.employee_no, ppp.payroll_item_id, ppp.apply_end_date
                                          from   tb_pay_item_payment_plan_n ppp
                                          where  ppp.payroll_item_id = p_payroll_item_id
                                          and    ppp.employee_no     = rec.employee_no
                                          and    ppp.apply_start_date <= v_end_date
                                          and    ppp.apply_end_date >= v_start_date
                                       )
                          loop 
                            v_plan_id := sq_tb_pay_item_payment_plan_n.nextval;
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
                                  ,rec_u.payroll_item_id
                                  ,rec_u.employee_no    --employee_no
                                  ,v_end_date + 1       --apply_start_date
                                  ,rec_u.apply_end_date         --apply_end_date
                                  ,'N'       --retroactive_flag
                                  ,sysdate   --creation_date
                                  ,v_user_id --creation_user_id
                                  );
                                  
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
                                       ,ppp.payroll_item_detail_detail_id
                                       ,ppp.apply_target_value
                                       ,sysdate
                                       ,v_user_id
                                       ,sysdate
                                       ,v_user_id
                                 from   tb_pay_payment_plan_detail_n ppp
                                  where ppp.payroll_item_payment_plan_id = rec_u.payroll_item_payment_plan_id;
        
                            UPDATE tb_pay_item_payment_plan_n
                              SET     apply_end_date = v_start_date - 1 
                              WHERE   employee_no = rec_u.employee_no 
                              AND     payroll_item_payment_plan_id = rec_u.payroll_item_payment_plan_id  
                              AND     payroll_item_id = rec_u.payroll_item_id;
                          end loop;    
                          --HMT_20210719 End 
                        end if;
                        
                        --upload data 중복 체크
                        select count(*)
                        into   v_chk_cnt
                        from   lgcom_import_n li
                        where  li.session_id = p_session_id
                        and    li.seq_no > 1
                        and    trim(li.attribute1) = rec.employee_no
                        ;
                        
                        if v_chk_cnt > 1 
                        then
                            v_error_msg := v_error_msg || ' Upload Data 중복입니다.';
                        end if; 
    
                    end if;
                end if;
                
                for rec_d in (select pid.pay_calc_rslt_detail_type_code         data_type
                                    ,pid.additional_input_value                 data_name
                                    ,count(*) over (order by pid.sort_order_no) order_cnt
                              from   tb_pay_item_detail_n pid
                              where  pid.payroll_item_id = p_payroll_item_id
                              order by pid.sort_order_no
                             )
                loop
                    if rec_d.data_type in ('A', 'N', 'D')
                    then
                        v_attribute := get_attribute_data(p_session_id, rec.seq_no, v_fix_cnt + rec_d.order_cnt);
                        
                        if rec_d.data_type in ('A', 'N')  --숫자
                          and lgcom_excel_pkg.is_number(v_attribute) = 0
                        then
                            v_error_msg := v_error_msg || ' ' || rec_d.data_name || 'format is not Number';
                        elsif rec_d.data_type = 'D'       --date : dd/mm/yyyy 
                          and lgcom_excel_pkg.is_date(v_attribute, v_date_format) = 'N'
                        then
                            v_error_msg := v_error_msg || ' ' || rec_d.data_name || 'formt is not  ' || v_date_format ;
                        end if;
                    end if;
                end loop;
            end if;  
            
        exception
            when others then
                v_error_msg := 'Upload Data Check Error : ' || sqlerrm;                
        end;
        
        g_step := 'Upload Data Check : Check Error Update';
        
      --  dbms_output.put_line(v_error_msg);
        if v_error_msg is not null
        then
            if v_err_count = 0
            then
                rollback;
            end if;
            
            v_err_count := v_err_count + 1;
                
            update lgcom_import_n li
            set    li.attribute199 = 'Y'
                  ,li.attribute200 = case when lengthb(v_error_msg) > 150
                                          then substrb(v_error_msg, 1, 145)||'.....'
                                          else v_error_msg
                                     end
            where  li.session_id = p_session_id
            and    li.seq_no     = rec.seq_no
            ;
        end if;
        
        --저장
        if v_err_count = 0
        then
            g_step := 'Upload Data Save : Payment Plan';
            v_plan_id := sq_tb_pay_item_payment_plan_n.nextval;
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
                  ,p_payroll_item_id
                  ,rec.employee_no    --employee_no
                  ,v_start_date       --apply_start_date
                  ,v_end_date         --apply_end_date
                  ,'N'       --retroactive_flag
                  ,sysdate   --creation_date
                  ,v_user_id --creation_user_id
                  )
            ;
            
            g_step := 'Upload Data Save : Payment Plan Detail';
            v_sql := ' insert into tb_pay_payment_plan_detail_n'
                  || '       (payroll_item_pay_pln_detail_id'
                  || '       ,payroll_item_payment_plan_id'
                  || '       ,payroll_item_detail_detail_id'
                  || '       ,apply_target_value'
                  || '       ,creation_date'
                  || '       ,creation_user_id'
                  || '       ,last_update_date'
                  || '       ,last_update_user_id'
                  || '       )'
                  || ' select sq_tb_pay_pay_plan_detail_n.nextval'
                  || '       ,ppp.payroll_item_payment_plan_id'
                  || '       ,pid.payroll_item_detail_detail_id'
                  || '       ,trim(dat.data_value)'
                  || '       ,sysdate'
                  || '       ,' || v_user_id
                  || '       ,sysdate'
                  || '       ,' || v_user_id
                  || ' from   tb_pay_item_payment_plan_n ppp'
                  || '       ,tb_pay_item_detail_n       pid'
                  || '       ,('
            ;
            
            for rec_i in (select pid.payroll_item_detail_detail_id
                                ,count(*) over (order by pid.sort_order_no) order_cnt
                          from   tb_pay_item_detail_n pid
                          where  pid.payroll_item_id = p_payroll_item_id
                          order by pid.sort_order_no
                         )
            loop
                v_sql := v_sql
                      || ' select ' || rec_i.payroll_item_detail_detail_id || ' detail_id' 
                      || '       ,trim(li.attribute1) employee_no'
                      || '       ,trim(li.attribute' || (v_fix_cnt + rec_i.order_cnt) || ') data_value'
                      || ' from   lgcom_import_n li'
                      || ' where  li.session_id = ' || p_session_id
                      || ' and    li.seq_no =' || rec.seq_no
                      || ' union'
                ;
            end loop;  
            
            --마지막 union 처리하기 위해
            v_sql := v_sql
                  || ' select null'
                  || '       ,null'
                  || '       ,null'
                  || ' from   dual'
            ;
                  
            v_sql := v_sql
                  || '       ) dat'
                  || ' where  ppp.payroll_item_id = pid.payroll_item_id'
                  || ' and    ppp.payroll_item_payment_plan_id = ' || v_plan_id
                  || ' and    ppp.employee_no     = dat.employee_no'
                  || ' and    pid.payroll_item_detail_detail_id = dat.detail_id'
            ;  
                  
            --dbms_output.put_line(v_sql);
            execute immediate v_sql;
        end if;
    end loop;
    
    --오류 체크
    if v_err_count > 0
    then
        p_errcode := -2000;
        p_errbuf  := 'Total : ' || v_rec_count || ' Error : ' || v_err_count;
    end if;
    
    commit;
    
EXCEPTION
    WHEN OTHERS THEN
        rollback;
        p_errcode := sqlcode;
        p_errbuf  := substr(nvl(p_errbuf,sqlerrm), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END entry_payroll_item_by_item;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : upload_payroll_employee                                   */
/* Description    : 급여대상자 업로드(추가만)                                 */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                p_errcode                OUT     VARCHAR2   오류 코드
/*                p_errbuf                 OUT     VARCHAR2   오류 내용
/*                p_session_id             IN      NUMBER     Session Id : 엑셀 업로드용
/*                p_payroll_calc_set_id    IN      NUMBER     급여대상자 Set Id
/*                p_application_user_id    IN      NUMBER     사용자 Id
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/20  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE upload_payroll_employee(p_errcode             OUT VARCHAR2
                                 ,p_errbuf              OUT VARCHAR2
                                 ,p_session_id          IN NUMBER
                                 ,p_payroll_calc_set_id IN NUMBER
                                 ,p_application_user_id IN NUMBER
                                 )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAYC0015';
    v_user_id         number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_rec_count       number := 0;    --upload 건수
    v_err_count       number := 0;    --오류 건수
    v_chk_cnt         number;         --검증용
    v_error_msg       varchar2(4000); --검증오류 메세지
        
    v_exception       exception;

    cursor cur_excel
    is
        select li.seq_no
              ,trim(li.attribute1) employee_no       --Employee No
              ,trim(li.attribute2) employee_name     --Employee Name
              ,trim(li.attribute3) grade_name        -- 'Grade'
              ,trim(li.attribute4) Title             --  'Title'              
              ,trim(li.attribute5) org_name          --Organization name
              ,trim(li.attribute6) cateogry           --'Category'
              ,trim(li.attribute7) work_type          --  'Work Type'              
              ,trim(li.attribute8) start_date        --HIRE_DATE(dd/mm/yyyy)
              ,trim(li.attribute9) end_date          --RESIGNATION_DATE(dd/mm/yyyy)
        from   lgcom_import_n li
        where  li.session_id = p_session_id
        and    li.seq_no > 1   
        and    not exists (select 'Y' --기존등록된 인원은 제외
                           from   tb_pay_calc_set_target_per_n stp
                           where  stp.payroll_calculation_set_id = p_payroll_calc_set_id
                           and    stp.employee_no = trim(li.attribute1)
                          )
        order by li.seq_no  --처리 순서를 정하기 위해
    ;
    
BEGIN
    if p_application_user_id is not null
    then
        v_user_id := p_application_user_id;
    end if;
    
    g_step := 'Get Upload Data Count';
    --Upload Data 개수
    select count(*)
    into   v_rec_count
    from   lgcom_import_n li
    where  li.session_id = p_session_id
    ;
    
    if v_rec_count < 2
    then
        p_errbuf := 'No Upload Data Found';
        raise v_exception;
    end if;    
    
    for rec IN cur_excel
    loop
        --v_rec_count  := v_rec_count + 1;
        v_error_msg  := null;
            
        g_step := 'Upload Data Check : Employee No';
        begin
            select 1
            into   v_chk_cnt
            from   emp_master em
            where  em.employee_number = rec.employee_no
            ;
        exception
            when others then
                v_error_msg := 'Check Employee No';
        end;
        
        g_step := 'Upload Data Check : Check Error Update';
        if v_error_msg is not null
        then
            if v_err_count = 0
            then
                rollback;
            end if;
            
            v_err_count := v_err_count + 1;
                
            update lgcom_import_n li
            set    li.attribute199 = 'Y'
                  ,li.attribute200 = case when lengthb(v_error_msg) > 150
                                          then substrb(v_error_msg, 1, 145)||'.....'
                                          else v_error_msg
                                     end
            where  li.session_id = p_session_id
            and    li.seq_no     = rec.seq_no
            ;
        end if;
        
        --저장
        if v_err_count = 0
        then
            g_step := 'Upload Data Save : Target Person';
            insert into tb_pay_calc_set_target_per_n 
                  (payroll_calculation_set_id
                  ,employee_no
                  ,creation_date
                  ,creation_user_id
                  )
            values(p_payroll_calc_set_id
                  ,rec.employee_no    --employee_no
                  ,sysdate   --creation_date
                  ,v_user_id --creation_user_id
                  )
            ;
        end if;
    end loop;
    
    --오류 체크
    if v_err_count > 0
    then
        p_errcode := -2000;
        p_errbuf  := 'Total : ' || (v_rec_count - 1) || ' Error : ' || v_err_count;
    end if;
    
    commit;
    
EXCEPTION
    WHEN OTHERS THEN
        rollback;
        p_errcode := sqlcode;
        p_errbuf  := substr(nvl(p_errbuf,sqlerrm), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END upload_payroll_employee;

--HMT_20220601 Start
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2022                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : upload_payroll_employee_email                                   */
/* Description    : Upload employee's email outside                                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                p_errcode                OUT     VARCHAR2   오류 코드
/*                p_errbuf                 OUT     VARCHAR2   오류 내용
/*                p_session_id             IN      NUMBER     Session Id : 엑셀 업로드용
/*                p_application_user_id    IN      NUMBER     사용자 Id
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date           In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2022-06-01  HaMinhThuy     Initial Release                                   */
/******************************************************************************/
PROCEDURE upload_payroll_employee_email(p_errcode               OUT VARCHAR2
                                                         ,p_errbuf                  OUT VARCHAR2
                                                         ,p_session_id             IN NUMBER
                                                         ,p_pay_month           IN VARCHAR2
                                                         ,p_application_user_id IN NUMBER
                                                         )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAY00025';
    v_user_id         number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_rec_count       number := 0;    --upload 건수
    v_err_count       number := 0;    --오류 건수
    v_chk_cnt         number;         --검증용
    v_error_msg       varchar2(4000); --검증오류 메세지
        
    v_exception       exception;

    cursor cur_excel_not_exists
    is
        select li.seq_no
              ,trim(li.attribute1) employee_no
              ,trim(li.attribute2) employee_name_local
              ,trim(li.attribute3) employee_name
              ,trim(li.attribute4) email_outside
              ,trim(li.attribute5) remark
              ,trim(li.attribute6) organization_name
              ,trim(li.attribute7) person_type
              ,trim(li.attribute8) status
              ,trim(li.attribute9) grade_code
              ,trim(li.attribute10) grade_title_name
              ,trim(li.attribute11) emp_category_name
              ,trim(li.attribute12) datehire_subsidiary
              ,trim(li.attribute13) date_retire
              ,trim(li.attribute14) supervisor
              ,trim(li.attribute15) supervisor_name
              ,trim(li.attribute16) supervisor_org_name
              ,trim(li.attribute17) mobile_phone
              ,trim(li.attribute18) shift_type_name
              ,trim(li.attribute19) payroll_calculation_exec_id
              ,trim(li.attribute20) send_error
        from   lgcom_import_n li
        where  li.session_id = p_session_id
        and    li.seq_no > 1   
        and    not exists (select 'Y' --기존등록된 인원은 제외
                           from   tb_pay_slip_send_n stp
                         where   stp.payment_yyyymm = p_pay_month  
                            and   stp.employee_no = trim(li.attribute1)
                          )
        order by li.seq_no  --처리 순서를 정하기 위해
    ;
    
    cursor cur_excel_exists
    is
        select li.seq_no
              ,trim(li.attribute1) employee_no
              ,trim(li.attribute2) employee_name_local
              ,trim(li.attribute3) employee_name
              ,trim(li.attribute4) email_outside
              ,trim(li.attribute5) remark
              ,trim(li.attribute6) organization_name
              ,trim(li.attribute7) person_type
              ,trim(li.attribute8) status
              ,trim(li.attribute9) grade_code
              ,trim(li.attribute10) grade_title_name
              ,trim(li.attribute11) emp_category_name
              ,trim(li.attribute12) datehire_subsidiary
              ,trim(li.attribute13) date_retire
              ,trim(li.attribute14) supervisor
              ,trim(li.attribute15) supervisor_name
              ,trim(li.attribute16) supervisor_org_name
              ,trim(li.attribute17) mobile_phone
              ,trim(li.attribute18) shift_type_name
              ,trim(li.attribute19) payroll_calculation_exec_id
              ,trim(li.attribute20) send_error
         from   lgcom_import_n li
        where  li.session_id = p_session_id
        and    li.seq_no > 1   
        and    exists (select 'Y' --기존등록된 인원은 제외
                           from   tb_pay_slip_send_n stp
                         where stp.payment_yyyymm = p_pay_month  
                         and    stp.employee_no = trim(li.attribute1)
                          )
        order by li.seq_no  --처리 순서를 정하기 위해
    ;
    
BEGIN
    if p_application_user_id is not null
    then
        v_user_id := p_application_user_id;
    end if;
    
    g_step := 'Get Upload Data Count';
    --Upload Data 개수
    select count(*)
    into   v_rec_count
    from   lgcom_import_n li
    where  li.session_id = p_session_id
    ;
    
    if v_rec_count < 2
    then
        p_errbuf := 'No Upload Data Found';
        raise v_exception;
    end if;    
    
    for rec IN cur_excel_not_exists
    loop
        --v_rec_count  := v_rec_count + 1;
        v_error_msg  := null;
            
        g_step := 'Upload Data Check : Employee No';
        begin
            select 1
            into   v_chk_cnt
            from   emp_master em
            where  em.employee_number = rec.employee_no
            ;
        exception
            when others then
                v_error_msg := 'Check Employee No';
        end;
        
        g_step := 'Upload Data Check : Email outside valid';
        begin
            select 1
            into   v_chk_cnt
            from   dual 
            where  regexp_like  (rec.email_outside ,'^\w+(\.\w+)*+@\w+(\.\w+)+$');
        exception
            when others then
                v_error_msg := 'Check Email outside valid';
        end;
        
        g_step := 'Upload Data Check : Check Error Update';
        if v_error_msg is not null
        then
            if v_err_count = 0
            then
                rollback;
            end if;
            
            v_err_count := v_err_count + 1;
                
            update lgcom_import_n li
            set    li.attribute199 = 'Y'
                  ,li.attribute200 = case when lengthb(v_error_msg) > 150
                                          then substrb(v_error_msg, 1, 145)||'.....'
                                          else v_error_msg
                                     end
            where  li.session_id = p_session_id
            and    li.seq_no     = rec.seq_no
            ;
        end if;
        
        --저장
        if v_err_count = 0
        then
            g_step := 'Upload Data Save : Target Person';
            insert into tb_pay_slip_send_n 
                  (payment_yyyymm
                  , employee_no
                  ,user_email_addr
                  ,remark_text
                  ,creation_date
                  ,creation_user_id
                  )
            values(p_pay_month
                  ,rec.employee_no    --employee_no
                  ,rec.email_outside
                  ,rec.remark
                  ,sysdate   --creation_date
                  ,v_user_id --creation_user_id
                  )
            ;
        end if;
    end loop;
    
    for rec IN cur_excel_exists
    loop
        --v_rec_count  := v_rec_count + 1;
        v_error_msg  := null;
        
        g_step := 'Upload Data Check : Email outside valid';
        begin
            select 1
            into   v_chk_cnt
            from   dual 
            where  regexp_like  (rec.email_outside ,'^\w+(\.\w+)*+@\w+(\.\w+)+$');
        exception
            when others then
                v_error_msg := 'Check Email outside valid';
        end;
        
        g_step := 'Upload Data Check : Check Error Update';
        if v_error_msg is not null
        then
            if v_err_count = 0
            then
                rollback;
            end if;
            
            v_err_count := v_err_count + 1;
                
            update lgcom_import_n li
            set    li.attribute199 = 'Y'
                  ,li.attribute200 = case when lengthb(v_error_msg) > 150
                                          then substrb(v_error_msg, 1, 145)||'.....'
                                          else v_error_msg
                                     end
            where  li.session_id = p_session_id
            and    li.seq_no     = rec.seq_no
            ;
        end if;
        --저장
        if v_err_count = 0
        then
            g_step := 'Upload Data Save : Target Person';
           update tb_pay_slip_send_n set              
                  (user_email_addr
                  ,remark_text
                  ,creation_date
                  ,creation_user_id
                  )
             = (select rec.email_outside
                  ,rec.remark
                  ,sysdate   --creation_date
                  ,v_user_id --creation_user_id
                  from dual)
              where employee_no = rec.employee_no
              and    payment_yyyymm = p_pay_month
            ;
        end if;
    end loop;
    
    --오류 체크
    if v_err_count > 0
    then
        p_errcode := -2000;
        p_errbuf  := 'Total : ' || (v_rec_count - 1) || ' Error : ' || v_err_count;
    end if;
    
    commit;
    
EXCEPTION
    WHEN OTHERS THEN
        rollback;
        p_errcode := sqlcode;
        p_errbuf  := substr(nvl(p_errbuf,sqlerrm), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END upload_payroll_employee_email;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2022                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : update_payroll_employee_email                                   */
/* Description    : update employee's email outside                                */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*                p_errcode                OUT     VARCHAR2   오류 코드
/*                p_errbuf                 OUT     VARCHAR2   오류 내용
/*                p_session_id             IN      NUMBER     Session Id : 엑셀 업로드용
/*                p_application_user_id    IN      NUMBER     사용자 Id
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date           In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2022-06-01  HaMinhThuy     Initial Release                                   */
/******************************************************************************/
PROCEDURE update_payroll_employee_email(p_errcode              OUT VARCHAR2
                                                             ,p_errbuf                 OUT VARCHAR2
                                                             ,p_calset_id             IN NUMBER
                                                             ,p_flag                    IN VARCHAR2
                                                             ,p_error                   IN VARCHAR2
                                                             ,p_type                   IN VARCHAR2
                                                             ,p_pay_month           IN VARCHAR2
                                                             ,p_employee_no         IN VARCHAR2
                                                             ,p_application_user_id IN VARCHAR2
                                                             )
IS
    v_program_id      lgcom_error_log.program_id%TYPE := 'LGVPAY00026';
    v_user_id         number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_rec_count       number := 0;    --upload 건수
    v_err_count       number := 0;    --오류 건수
    v_chk_cnt         number;         --검증용
    v_error_msg       varchar2(4000); --검증오류 메세지
        
    v_exception       exception;
    
BEGIN
   if p_application_user_id is not null
    then
        v_user_id := p_application_user_id;
    end if;
    
    if p_type = 'SEND' 
    then
      UPDATE /*LGVPAY00026.updateEmailEmpSendError*/
               tb_pay_slip_send_n 
        SET  payroll_calculation_exec_id     = p_calset_id             
             , transfer_flag                          = p_flag
             , mail_send_error_content          = p_error
             , last_update_user_id                = v_user_id            		/* 최종수정사용자아이디 */
             , last_update_date                    = sysdate                 							/* 최종수정일자 */
    WHERE  employee_no                          = p_employee_no
       AND   payment_yyyymm                   = p_pay_month;
         
      elsif p_type = 'CREATE' then
        UPDATE /*LGVPAY00026.updateEmailEmpSendError*/
               tb_pay_slip_send_n 
        SET  payroll_calculation_exec_id   = p_calset_id             
             , slip_creation_flag               = p_flag
             , error_message_content        = p_error
             , last_update_user_id             = v_user_id            		/* 최종수정사용자아이디 */
             , last_update_date                = sysdate                 							/* 최종수정일자 */
    WHERE  employee_no                      = p_employee_no
       AND   payment_yyyymm               = p_pay_month;
    end if;
    
    commit;
    
EXCEPTION
    WHEN OTHERS THEN
        rollback;
        p_errcode := sqlcode;
        p_errbuf  := substr(nvl(p_errbuf,sqlerrm), 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END update_payroll_employee_email;
--HMT_20220601 End 

END lgvpay_upload_pkg;
/
