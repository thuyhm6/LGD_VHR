CREATE OR REPLACE PACKAGE VHR_MGR.lgvinf_if_batch_pkg AS
    /******************************************************************************/
    /*                  Copyright (c) 2016 LG CNS Inc.
    /*                           All rights reserved.
    /******************************************************************************/
    /* Project      : [PJT0015428]17_베트남법인 표준 급여 ,근태 시스템 구축 프로젝트
    /* Module       : LGVINF
    /* Program Name : lgvinf_if_batch_pkg.pls
    /* Reference by :
    /* Description  : I/F 관련 모음(ERP)
    /* Program History
    /*------------------------------------------------------------------------------
    /*   Date       In Charge      Version  Description
    /*------------------------------------------------------------------------------
    /* 2017-10-24   Jaehyun Kim    1.0      initialize
    /******************************************************************************/
    --코드 정보 I/F
    PROCEDURE main_code(p_errcode             OUT VARCHAR2
                       ,p_errbuf              OUT VARCHAR2
                       ,p_application_user_id IN NUMBER
                       );

    --조직 정보 I/F
    PROCEDURE main_org(p_errcode             OUT VARCHAR2
                      ,p_errbuf              OUT VARCHAR2
                      ,p_application_user_id IN NUMBER
                      );

    --인원 정보 I/F
    PROCEDURE main_per(p_errcode             OUT VARCHAR2
                      ,p_errbuf              OUT VARCHAR2
                      ,p_application_user_id IN NUMBER
                      );

    --인사마스터 정보 I/F
    PROCEDURE main_emp(p_errcode             OUT VARCHAR2
                      ,p_errbuf              OUT VARCHAR2
                      ,p_application_user_id IN NUMBER
                      );

    -- 결재자 정보 반영(재량권기준)
    PROCEDURE main_emp_approver(p_errcode             OUT VARCHAR2
                               ,p_errbuf              OUT VARCHAR2
                               ,p_application_user_id IN NUMBER
                               );
                               
    --발령 정보 I/F
    PROCEDURE main_asg(p_errcode             OUT VARCHAR2
                      ,p_errbuf              OUT VARCHAR2
                      ,p_application_user_id IN NUMBER
                      );
    
    --가족 정보 I/F
    PROCEDURE main_family(p_errcode             OUT VARCHAR2
                         ,p_errbuf              OUT VARCHAR2
                         ,p_application_user_id IN NUMBER
                         );
    
    --자격 정보 I/F
    PROCEDURE main_qualification(p_errcode             OUT VARCHAR2
                                ,p_errbuf              OUT VARCHAR2
                                ,p_application_user_id IN NUMBER
                                );
                                         
    --계약 정보 I/F
    PROCEDURE main_contract(p_errcode             OUT VARCHAR2
                           ,p_errbuf              OUT VARCHAR2
                           ,p_application_user_id IN NUMBER
                           );
    
    --급호 정보 I/F
    PROCEDURE main_grade_point(p_errcode             OUT VARCHAR2
                              ,p_errbuf              OUT VARCHAR2
                              ,p_application_user_id IN NUMBER
                              );
    
    --권한 처리
    PROCEDURE user_role_proc(p_errcode             OUT VARCHAR2
                            ,p_errbuf              OUT VARCHAR2
                            ,p_application_user_id IN NUMBER   --처리자
                            ); 
    
    --My Menu 처리
    PROCEDURE my_menu_proc(p_errcode             OUT VARCHAR2
                          ,p_errbuf              OUT VARCHAR2
                          ,p_application_user_id IN NUMBER   --처리자
                          );  
   
    -- error log기록을 위해서 global변수 선언.
    g_module_code CONSTANT lgcom_error_log.module_code%TYPE := 'LGVINF';
    g_step lgcom_error_log.error_explanation_text%TYPE := NULL;
    
    g_system_code CONSTANT lgcom_code_type_code_c.system_code%TYPE := 'LGVHR';
    g_application_key CONSTANT varchar2(36) := '931B639F-3834-43A6-AB95-19285D31EB98'; --기존에 사용되어 있어서...    
    

END lgvinf_if_batch_pkg;
/
CREATE OR REPLACE PACKAGE BODY VHR_MGR.lgvinf_if_batch_pkg AS
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_code                                                 */
/* Description    : 코드 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/24  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_code(p_errcode             OUT VARCHAR2
                   ,p_errbuf              OUT VARCHAR2
                   ,p_application_user_id IN NUMBER
                   )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0001';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_type_exist_flag varchar2(1); --code type이 존재하는지 여부
    v_code_exist_flag varchar2(1); --code가 존재하는지 여부
    
    cursor cur_code
    is
        select xlc.eai_seq_id
              ,xlc.code_type
              ,xlc.code
              ,xlc.code_name
              ,xlc.enabled_flag
              ,xlc.start_date_active
              ,xlc.end_date_active            
        from   xvh_lst_code_if         xlc
        where  xlc.application_transfer_flag = 'N'
        order by xlc.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    for rec_code IN cur_code
    loop
        begin
            g_step := 'main_code : Code Type Create';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_type_exist_flag
            from   lgcom_code_type_code_c  lct
            where  lct.code_type_code = rec_code.code_type
            ;
            
            --code type 생성만 한다
            if v_type_exist_flag = 'N'  --존재하지 않으면
            then
                insert into lgcom_code_type_code_c
                      (code_type_code
                      ,system_code
                      ,module_code
                      ,code_type_code_desc
                      ,control_level_code
                      ,access_level_code
                      ,use_flag
                      ,created_by
                      ,creation_date
                      ,last_updated_by
                      ,last_update_date
                      )
                values(rec_code.code_type  --code_type_code
                      ,g_system_code       --system_code
                      ,g_module_code       --module_code
                      ,rec_code.code_type  --code_type_code_desc
                      ,'SITE'              --control_level_code
                      ,'S'                 --access_level_code
                      ,'Y'                 --use_flag
                      ,v_user_id           --created_by
                      ,SYSDATE             --creation_date
                      ,v_user_id           --last_updated_by
                      ,SYSDATE             --last_update_date
                      )
                ;
            end if;
            
            g_step := 'main_code : Code Insert/Update';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_code_exist_flag
            from   lgcom_common_code_c     lcc
            where  lcc.code_type_code = rec_code.code_type
            and    lcc.common_code    = rec_code.code
            ;
        
            --code 처리(추가/수정)
            if v_code_exist_flag = 'N'
            then
                --추가
                insert into lgcom_common_code_c
                      (common_code
                      ,code_type_code
                      ,company_id
                      ,inventory_organization_id
                      ,common_code_desc
                      ,parent_common_code
                      ,parent_code_type_code
                      ,use_flag
                      ,apply_start_date
                      ,apply_end_date
                      ,sort_order_no
                      ,code_data1_value
                      ,code_data2_value
                      ,code_data3_value
                      ,code_data4_value
                      ,code_data5_value
                      ,created_by
                      ,creation_date
                      ,last_updated_by
                      ,last_update_date
                      )
                values(rec_code.code         --common_code
                      ,rec_code.code_type    --code_type_code
                      ,0                     --company_id
                      ,0                     --inventory_organization_id
                      ,rec_code.code_name    --common_code_desc
                      ,null                  --parent_common_code
                      ,null                  --parent_code_type_code
                      ,rec_code.enabled_flag --use_flag
                      ,rec_code.start_date_active --apply_start_date
                      ,rec_code.end_date_active   --apply_end_date
                      ,null                  --sort_order_no
                      ,null                  --code_data1_value
                      ,null                  --code_data2_value
                      ,null                  --code_data3_value
                      ,null                  --code_data4_value
                      ,null                  --code_data5_value
                      ,v_user_id             --created_by
                      ,SYSDATE               --creation_date
                      ,v_user_id             --last_updated_by
                      ,SYSDATE               --last_update_date
                      )
                ;
            else
                --수정
                update lgcom_common_code_c lcc
                set    lcc.common_code_desc = rec_code.code_name
                      ,lcc.use_flag         = rec_code.enabled_flag
                      ,lcc.apply_start_date = rec_code.start_date_active
                      ,lcc.apply_end_date   = rec_code.end_date_active
                      ,lcc.last_updated_by  = v_user_id
                      ,lcc.last_update_date = sysdate
                where  lcc.code_type_code   = rec_code.code_type
                and    lcc.common_code      = rec_code.code
                ;
            end if;
            
            g_step := 'main_code : Code Multi Lang Insert/Update';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            --multi lang 처리(추가/수정) : 현재 유효한 언어코드만 처리하게
            --먼저 없는 언어 코드 생성하고 그후 전체 언어코드에 대해 수정실행
            insert into lgcom_common_code_multi_lang_c
                  (code_type_code
                  ,common_code
                  ,company_id
                  ,inventory_organization_id
                  ,language_code
                  ,common_code_name
                  ,created_by
                  ,creation_date
                  ,last_updated_by
                  ,last_update_date
                  )
            select rec_code.code_type  --code_type_code
                  ,rec_code.code       --common_code
                  ,0                   --company_id
                  ,0                   --inventory_organization_id
                  ,lcc.common_code     --language_code
                  ,rec_code.code_name  --common_code_name
                  ,v_user_id           --created_by
                  ,SYSDATE             --creation_date
                  ,v_user_id           --last_updated_by
                  ,SYSDATE             --last_update_date
            from   lgcom_common_code_c lcc
            where  lcc.code_type_code = 'LGCOM_LANGUAGE_CODE'
            and    lcc.use_flag       = 'Y'
            and    trunc(sysdate)     between lcc.apply_start_date
                                      and     nvl(lcc.apply_end_date, trunc(sysdate))      
            and    not exists (select 'Y'  --존재하지 않는 언어 코드
                               from   lgcom_common_code_multi_lang_c lml
                               where  lml.code_type_code = rec_code.code_type
                               and    lml.common_code    = rec_code.code
                               and    lml.language_code  = lcc.common_code
                              ) 
            ;      
                
            --수정
            update lgcom_common_code_multi_lang_c lcl
            set    lcl.common_code_name = rec_code.code_name
                  ,lcl.last_updated_by  = v_user_id
                  ,lcl.last_update_date = sysdate
            where  lcl.code_type_code   = rec_code.code_type
            and    lcl.common_code      = rec_code.code
            and    exists (select 'Y'  --현재 유효한 언어코드 만
                           from   lgcom_common_code_c lcc
                           where  lcc.code_type_code = 'LGCOM_LANGUAGE_CODE'
                           and    lcc.use_flag       = 'Y'
                           and    trunc(sysdate)     between lcc.apply_start_date
                                                     and     nvl(lcc.apply_end_date, trunc(sysdate))
                          )
            ;
            
            --i/f 결과 처리(정상)
            update xvh_lst_code_if         xlc
            set    xlc.application_transfer_flag = 'Y'
                  ,xlc.application_transfer_date = sysdate
            where  xlc.eai_seq_id = rec_code.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec_code.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;
    
EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_code)';
        p_errcode := sqlcode;
        p_errbuf  := substr(sqlerrm, 1, 2000);
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_code;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_org                                                  */
/* Description    : 조직 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/24  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_org(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0002';
    --v_user_id    number := -1; -- create_by, last_updated_by 에 이용
    
    v_org_exist_flag  varchar2(1); --조직이 존재하는지 여부
    
    cursor cur_org
    is
        select xoi.eai_seq_id
              ,xoi.subsidiary_code
              ,xoi.organization_id
              ,xoi.header
              ,xoi.org_name_eng
              ,xoi.org_name_local
              ,xoi.org_start_date
              ,xoi.org_end_date
              ,xoi.org_type
              ,xoi.parent_org_id
              ,xoi.parent_org_name
              ,xoi.org_manager_number
              ,xoi.mission
              ,xoi.role
              ,xoi.acc_div_code
              ,xoi.acc_org_code
              ,xoi.acc_org_use_yn
              ,xoi.acc_org_type
              ,xoi.acc_org_dirtly_style
              ,xoi.acc_org_exp_type
              ,xoi.acc_fa_exp_type
              ,xoi.location_name
              ,xoi.address_country
              ,xoi.address_city
              ,xoi.address_line
              ,xoi.address_postal
              ,xoi.attribute1
              ,xoi.attribute2
              ,xoi.attribute3
              ,xoi.attribute4
              ,xoi.attribute5
              ,xoi.attribute6
              ,xoi.attribute7
              ,xoi.attribute8
              ,xoi.attribute9
              ,xoi.attribute10  
              ,xoi.last_update_date         
        from   xvh_oganization_if xoi
        where  xoi.application_transfer_flag = 'N'
        order by xoi.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    /*
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    */
    
    for rec_org IN cur_org
    loop
        begin
            g_step := 'main_org : Organization I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_org_exist_flag
            from   org_master om
            where  om.application_key = g_application_key
            and    om.subsidiary_code = rec_org.subsidiary_code
            and    om.organization_id = rec_org.organization_id
            ;
            
            --조직 생성/수정
            if v_org_exist_flag = 'N'  --존재하지 않으면
            then
                insert into org_master
                      (application_key
                      ,subsidiary_code
                      ,organization_id
                      ,header
                      ,org_name_eng
                      ,org_name_local
                      ,org_start_date
                      ,org_end_date
                      ,org_type
                      ,parent_org_id
                      ,parent_org_name
                      ,org_manager_number
                      ,mission
                      ,role
                      ,acc_div_code
                      ,acc_org_code
                      ,acc_org_use_yn
                      ,acc_org_type
                      ,acc_org_dirtly_style
                      ,acc_org_exp_type
                      ,acc_fa_exp_type
                      ,location_name
                      ,address_country
                      ,address_city
                      ,address_line
                      ,address_postal
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
                      ,version_id
                      )
                values(g_application_key    --application_key
                      ,rec_org.subsidiary_code
                      ,rec_org.organization_id
                      ,rec_org.header
                      ,rec_org.org_name_eng
                      ,rec_org.org_name_local
                      ,rec_org.org_start_date
                      ,rec_org.org_end_date
                      ,rec_org.org_type
                      ,rec_org.parent_org_id
                      ,rec_org.parent_org_name
                      ,rec_org.org_manager_number
                      ,rec_org.mission
                      ,rec_org.role
                      ,rec_org.acc_div_code
                      ,rec_org.acc_org_code
                      ,rec_org.acc_org_use_yn
                      ,rec_org.acc_org_type
                      ,rec_org.acc_org_dirtly_style
                      ,rec_org.acc_org_exp_type
                      ,rec_org.acc_fa_exp_type
                      ,rec_org.location_name
                      ,rec_org.address_country
                      ,rec_org.address_city
                      ,rec_org.address_line
                      ,rec_org.address_postal
                      ,rec_org.attribute1
                      ,rec_org.attribute2
                      ,rec_org.attribute3
                      ,rec_org.attribute4
                      ,rec_org.attribute5
                      ,rec_org.attribute6
                      ,rec_org.attribute7
                      ,rec_org.attribute8
                      ,rec_org.attribute9
                      ,rec_org.attribute10
                      ,rec_org.last_update_date
                      ,rec_org.eai_seq_id --version_id
                      )
                ;
            else
                update org_master om
                set    header               = rec_org.header                                     
                      ,org_name_eng         = rec_org.org_name_eng        
                      ,org_name_local       = rec_org.org_name_local      
                      ,org_start_date       = rec_org.org_start_date      
                      ,org_end_date         = rec_org.org_end_date        
                      ,org_type             = rec_org.org_type            
                      ,parent_org_id        = rec_org.parent_org_id       
                      ,parent_org_name      = rec_org.parent_org_name     
                      ,org_manager_number   = rec_org.org_manager_number  
                      ,mission              = rec_org.mission             
                      ,role                 = rec_org.role                
                      ,acc_div_code         = rec_org.acc_div_code        
                      ,acc_org_code         = rec_org.acc_org_code        
                      ,acc_org_use_yn       = rec_org.acc_org_use_yn      
                      ,acc_org_type         = rec_org.acc_org_type        
                      ,acc_org_dirtly_style = rec_org.acc_org_dirtly_style
                      ,acc_org_exp_type     = rec_org.acc_org_exp_type    
                      ,acc_fa_exp_type      = rec_org.acc_fa_exp_type     
                      ,location_name        = rec_org.location_name       
                      ,address_country      = rec_org.address_country     
                      ,address_city         = rec_org.address_city        
                      ,address_line         = rec_org.address_line        
                      ,address_postal       = rec_org.address_postal      
                      ,attribute1           = rec_org.attribute1          
                      ,attribute2           = rec_org.attribute2          
                      ,attribute3           = rec_org.attribute3          
                      ,attribute4           = rec_org.attribute4          
                      ,attribute5           = rec_org.attribute5          
                      ,attribute6           = rec_org.attribute6          
                      ,attribute7           = rec_org.attribute7          
                      ,attribute8           = rec_org.attribute8          
                      ,attribute9           = rec_org.attribute9          
                      ,attribute10          = rec_org.attribute10         
                      ,last_update_date     = rec_org.last_update_date    
                      ,version_id           = rec_org.eai_seq_id
                where  om.application_key = g_application_key
                and    om.subsidiary_code = rec_org.subsidiary_code
                and    om.organization_id = rec_org.organization_id
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update xvh_oganization_if xoi
            set    xoi.application_transfer_flag = 'Y'
                  ,xoi.application_transfer_date = sysdate
            where  xoi.eai_seq_id = rec_org.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec_org.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_org)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_org;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_per                                                  */
/* Description    : 인원 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/24  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_per(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0003';
    --v_user_id    number := -1; -- create_by, last_updated_by 에 이용
    
    v_per_exist_flag  varchar2(1); --인원이 존재하는지 여부
    
    cursor cur_per
    is
        select xei.eai_seq_id
              ,xei.last_update_date
              ,xei.subsidiary_code
              ,xei.employee_number
              ,xei.header
              ,xei.social_security_id
              ,xei.birthday
              ,xei.marriage
              ,xei.father_name
              ,xei.mother_last_name
              ,xei.nationality
              ,xei.dossier
              ,xei.partymember_yn
              ,xei.ethnic
              ,xei.weddingdate
              ,xei.hukou
              ,xei.religion
              ,xei.born_address_country
              ,xei.born_address_city
              ,xei.born_address_line
              ,xei.born_address_postal
              ,xei.current_address_country
              ,xei.current_address_city
              ,xei.current_address_line
              ,xei.current_address_postal
              ,xei.idcard_number
              ,xei.idcard_issue_date
              ,xei.passport
              ,xei.passport_issue_date
              ,xei.passport_issue_country
              ,xei.passport_expire_date
              ,xei.home_tel
              ,xei.office_tel
              ,xei.mobile_number
              ,xei.tax_department
              ,xei.tax_number
              ,xei.workpermit_id
              ,xei.workpermit_issue_date
              ,xei.workpermit_expire_date
              ,xei.vehicle
              ,xei.obligation_yn
              ,xei.color
              ,xei.us_citizen_yn
              ,xei.attribute1
              ,xei.attribute2
              ,xei.attribute3
              ,xei.attribute4
              ,xei.attribute5
              ,xei.attribute6
              ,xei.attribute7
              ,xei.attribute8
              ,xei.attribute9
              ,xei.attribute10
              ,xei.attribute11
              ,xei.attribute12
              ,xei.attribute13
              ,xei.attribute14
              ,xei.attribute15
              ,xei.attribute16
              ,xei.attribute17
              ,xei.attribute18
              ,xei.attribute19
              ,xei.attribute20
        from   xvh_emp_info_if xei
        where  xei.application_transfer_flag = 'N'
        order by xei.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    /*
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    */
    
    for rec_per IN cur_per
    loop
        begin
            g_step := 'main_per : Person Info I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_per_exist_flag
            from   emp_info ei
            where  ei.application_key = g_application_key
            and    ei.subsidiary_code = rec_per.subsidiary_code
            and    ei.employee_number = rec_per.employee_number
            ;
            
            --인원정보 생성/수정/삭제
            if rec_per.header = 'D'
            then
                delete 
                from   emp_info ei
                where  ei.application_key = g_application_key
                and    ei.subsidiary_code = rec_per.subsidiary_code
                and    ei.employee_number = rec_per.employee_number
                ;
            
            elsif v_per_exist_flag = 'N'  --존재하지 않으면
            then
                insert into emp_info
                      (application_key
                      ,subsidiary_code
                      ,employee_number
                      ,social_security_id
                      ,birthday
                      ,marriage
                      ,father_name
                      ,mother_last_name
                      ,nationality
                      ,dossier
                      ,partymember_yn
                      ,ethnic
                      ,weddingdate
                      ,hukou
                      ,religion
                      ,born_address_country
                      ,born_address_city
                      ,born_address_line
                      ,born_address_postal
                      ,current_address_country
                      ,current_address_city
                      ,current_address_line
                      ,current_address_postal
                      ,idcard_number
                      ,idcard_issue_date
                      ,passport
                      ,passport_issue_date
                      ,passport_issue_country
                      ,passport_expire_date
                      ,home_tel
                      ,office_tel
                      ,mobile_number
                      ,tax_department
                      ,tax_number
                      ,workpermit_id
                      ,workpermit_issue_date
                      ,workpermit_expire_date
                      ,vehicle
                      ,obligation_yn
                      ,color
                      ,us_citizen_yn
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
                      ,attribute11
                      ,attribute12
                      ,attribute13
                      ,attribute14
                      ,attribute15
                      ,attribute16
                      ,attribute17
                      ,attribute18
                      ,attribute19
                      ,attribute20
                      ,last_update_date
                      ,version
                      )
                values(g_application_key    --application_key
                      ,rec_per.subsidiary_code
                      ,rec_per.employee_number
                      ,rec_per.social_security_id
                      ,rec_per.birthday
                      ,rec_per.marriage
                      ,rec_per.father_name
                      ,rec_per.mother_last_name
                      ,rec_per.nationality
                      ,rec_per.dossier
                      ,rec_per.partymember_yn
                      ,rec_per.ethnic
                      ,rec_per.weddingdate
                      ,rec_per.hukou
                      ,rec_per.religion
                      ,rec_per.born_address_country
                      ,rec_per.born_address_city
                      ,rec_per.born_address_line
                      ,rec_per.born_address_postal
                      ,rec_per.current_address_country
                      ,rec_per.current_address_city
                      ,rec_per.current_address_line
                      ,rec_per.current_address_postal
                      ,rec_per.idcard_number
                      ,rec_per.idcard_issue_date
                      ,rec_per.passport
                      ,rec_per.passport_issue_date
                      ,rec_per.passport_issue_country
                      ,rec_per.passport_expire_date
                      ,rec_per.home_tel
                      ,rec_per.office_tel
                      ,rec_per.mobile_number
                      ,rec_per.tax_department
                      ,rec_per.tax_number
                      ,rec_per.workpermit_id
                      ,rec_per.workpermit_issue_date
                      ,rec_per.workpermit_expire_date
                      ,rec_per.vehicle
                      ,rec_per.obligation_yn
                      ,rec_per.color
                      ,rec_per.us_citizen_yn
                      ,rec_per.attribute1
                      ,rec_per.attribute2
                      ,rec_per.attribute3
                      ,rec_per.attribute4
                      ,rec_per.attribute5
                      ,rec_per.attribute6
                      ,rec_per.attribute7
                      ,rec_per.attribute8
                      ,rec_per.attribute9
                      ,rec_per.attribute10
                      ,rec_per.attribute11
                      ,rec_per.attribute12
                      ,rec_per.attribute13
                      ,rec_per.attribute14
                      ,rec_per.attribute15
                      ,rec_per.attribute16
                      ,rec_per.attribute17
                      ,rec_per.attribute18
                      ,rec_per.attribute19
                      ,rec_per.attribute20
                      ,rec_per.last_update_date
                      ,rec_per.eai_seq_id --version_id
                      )
                ;
            else
                update emp_info ei
                set    social_security_id      = rec_per.social_security_id     
                      ,birthday                = rec_per.birthday               
                      ,marriage                = rec_per.marriage               
                      ,father_name             = rec_per.father_name            
                      ,mother_last_name        = rec_per.mother_last_name       
                      ,nationality             = rec_per.nationality            
                      ,dossier                 = rec_per.dossier                
                      ,partymember_yn          = rec_per.partymember_yn         
                      ,ethnic                  = rec_per.ethnic                 
                      ,weddingdate             = rec_per.weddingdate            
                      ,hukou                   = rec_per.hukou                  
                      ,religion                = rec_per.religion               
                      ,born_address_country    = rec_per.born_address_country   
                      ,born_address_city       = rec_per.born_address_city      
                      ,born_address_line       = rec_per.born_address_line      
                      ,born_address_postal     = rec_per.born_address_postal    
                      ,current_address_country = rec_per.current_address_country
                      ,current_address_city    = rec_per.current_address_city   
                      ,current_address_line    = rec_per.current_address_line   
                      ,current_address_postal  = rec_per.current_address_postal 
                      ,idcard_number           = rec_per.idcard_number          
                      ,idcard_issue_date       = rec_per.idcard_issue_date      
                      ,passport                = rec_per.passport               
                      ,passport_issue_date     = rec_per.passport_issue_date    
                      ,passport_issue_country  = rec_per.passport_issue_country 
                      ,passport_expire_date    = rec_per.passport_expire_date   
                      ,home_tel                = rec_per.home_tel               
                      ,office_tel              = rec_per.office_tel             
                      ,mobile_number           = rec_per.mobile_number          
                      ,tax_department          = rec_per.tax_department         
                      ,tax_number              = rec_per.tax_number             
                      ,workpermit_id           = rec_per.workpermit_id          
                      ,workpermit_issue_date   = rec_per.workpermit_issue_date  
                      ,workpermit_expire_date  = rec_per.workpermit_expire_date 
                      ,vehicle                 = rec_per.vehicle                
                      ,obligation_yn           = rec_per.obligation_yn          
                      ,color                   = rec_per.color                  
                      ,us_citizen_yn           = rec_per.us_citizen_yn          
                      ,attribute1              = rec_per.attribute1             
                      ,attribute2              = rec_per.attribute2             
                      ,attribute3              = rec_per.attribute3             
                      ,attribute4              = rec_per.attribute4             
                      ,attribute5              = rec_per.attribute5             
                      ,attribute6              = rec_per.attribute6             
                      ,attribute7              = rec_per.attribute7             
                      ,attribute8              = rec_per.attribute8             
                      ,attribute9              = rec_per.attribute9             
                      ,attribute10             = rec_per.attribute10            
                      ,attribute11             = rec_per.attribute11            
                      ,attribute12             = rec_per.attribute12            
                      ,attribute13             = rec_per.attribute13            
                      ,attribute14             = rec_per.attribute14            
                      ,attribute15             = rec_per.attribute15            
                      ,attribute16             = rec_per.attribute16            
                      ,attribute17             = rec_per.attribute17            
                      ,attribute18             = rec_per.attribute18            
                      ,attribute19             = rec_per.attribute19            
                      ,attribute20             = rec_per.attribute20            
                      ,last_update_date        = rec_per.last_update_date       
                      ,version                 = rec_per.eai_seq_id             
                where  ei.application_key = g_application_key
                and    ei.subsidiary_code = rec_per.subsidiary_code
                and    ei.employee_number = rec_per.employee_number
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update xvh_emp_info_if xoi
            set    xoi.application_transfer_flag = 'Y'
                  ,xoi.application_transfer_date = sysdate
            where  xoi.eai_seq_id = rec_per.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec_per.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;
EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_per)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_per;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_emp                                                  */
/* Description    : 인사마스터 정보 I/F                                       */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/24  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_emp(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0004';
    --v_user_id    number := -1; -- create_by, last_updated_by 에 이용
    
    v_emp_exist_flag  varchar2(1); --인사마스터가 존재하는지 여부
    
    cursor cur_emp
    is
        select xem.eai_seq_id
              ,xem.subsidiary_code
              ,xem.employee_number
              ,xem.header
              ,xem.status
              ,xem.lastname_eng
              ,xem.middlename_eng
              ,xem.firstname_eng
              ,xem.firstname_eng || ' ' || xem.middlename_eng || ' ' || xem.lastname_eng full_name_english 
              ,xem.lastname_local
              ,xem.middlename_local
              ,xem.firstname_local
              ,xem.firstname_local || ' ' || xem.middlename_local || ' ' || xem.lastname_local full_name_local
              ,xem.organization_id
              ,xem.org_name_eng
              ,xem.org_name_local
              ,xem.location_name
              ,xem.acc_div_code
              ,xem.acc_org_code
              ,xem.person_type
              ,xem.grade_type
              ,xem.grade
              ,xem.grade_title
              ,xem.grade_seniority
              ,xem.title_seniority
              ,xem.job_family
              ,xem.job_group
              ,xem.job_detail
              ,xem.position
              ,xem.pay_grade
              ,xem.pay_step
              ,xem.payment_type
              ,xem.pay_structure
              ,xem.salary_annual
              ,xem.base_salary_month
              ,xem.variable_salary_month
              ,xem.base_pay
              ,xem.currency
              ,xem.bank_code
              ,xem.bank_name
              ,xem.branch_bank_name
              ,xem.account_number
              ,xem.expense_bank_code
              ,xem.expense_bank_name
              ,xem.branch_expense_bank_name
              ,xem.expense_account_number
              ,xem.flsa_yn
              ,xem.gender
              ,xem.email    
              ,xem.supervisor
              ,xem.fse_yn
              ,xem.assignment_category
              ,xem.labour_union_flag
              ,xem.probation_start_date
              ,xem.probation_end_date
              ,xem.probation_pay_rate
              ,xem.date_hire_subsidiary
              ,xem.date_hire_lge
              ,xem.date_retire
              ,xem.date_absesce_leave
              ,xem.date_reinstatement
              ,xem.contract_flag
              ,xem.attribute1
              ,xem.attribute2
              ,xem.attribute3
              ,xem.attribute4
              ,xem.attribute5
              ,xem.attribute6
              ,xem.attribute7
              ,xem.attribute8
              ,xem.attribute9
              ,xem.attribute10
              ,xem.attribute11
              ,xem.attribute12
              ,xem.attribute13
              ,xem.attribute14
              ,xem.attribute15
              ,xem.attribute16
              ,xem.attribute17
              ,xem.attribute18
              ,xem.attribute19
              ,xem.attribute20
              ,xem.transfer_date
              ,xem.transfer_flag
              ,xem.transfer_status
              ,xem.sys_date
              ,xem.last_update_date 
        from   xvh_emp_master_if xem
        where  xem.application_transfer_flag = 'N'
        order by xem.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    /*
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    */
    
    for rec_emp IN cur_emp
    loop
        begin
            g_step := 'main_emp : Employee Master I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_emp_exist_flag
            from   emp_master em
            where  em.application_key = g_application_key
            and    em.subsidiary_code = rec_emp.subsidiary_code
            and    em.employee_number = rec_emp.employee_number
            ;
            
            --인사마스터정보 생성/수정/삭제
            if rec_emp.header = 'D'
            then
                delete 
                from   emp_master em
                where  em.application_key = g_application_key
                and    em.subsidiary_code = rec_emp.subsidiary_code
                and    em.employee_number = rec_emp.employee_number
                ;
            
            elsif v_emp_exist_flag = 'N'  --존재하지 않으면
            then
                insert into emp_master
                      (application_key
                      ,subsidiary_code
                      ,employee_number
                      ,status
                      ,lastname_eng
                      ,middlename_eng
                      ,firstname_eng
                      ,full_name_english
                      ,lastname_local
                      ,middlename_local
                      ,firstname_local
                      ,full_name_local
                      ,organization_id
                      ,org_name_eng
                      ,org_name_local
                      ,location_name
                      ,acc_div_code
                      ,acc_org_code
                      ,person_type
                      ,grade_type
                      ,grade
                      ,grade_title
                      ,grade_seniority
                      ,title_seniority
                      ,job_family
                      ,job_group
                      ,job_detail
                      ,position
                      ,pay_grade
                      ,pay_step
                      ,payment_type
                      ,pay_structure
                      ,salary_annual
                      ,base_salary_month
                      ,variable_salary_month
                      ,base_pay
                      ,currency
                      ,bank_code
                      ,bank_name
                      ,branch_bank_name
                      ,account_number
                      ,expense_bank_code
                      ,expense_bank_name
                      ,branch_expense_bank_name
                      ,expense_account_number
                      ,flsa_yn
                      ,gender
                      ,email
                      ,supervisor
                      ,fse_yn
                      ,assignment_category
                      ,labour_union_flag
                      ,probation_start_date
                      ,probation_end_date
                      ,probation_pay_rate
                      ,date_hire_subsidiary
                      ,date_hire_lge
                      ,date_retire
                      ,date_absesce_leave
                      ,date_reinstatement
                      ,contract_flag
                      ,last_update_date
                      --,insurance_yn
                      --,supervisor_yn
                      --,sectionleader_yn
                      --,teamleader_yn
                      --,unitleader_yn
                      --,worker_yn
                      --,calculate_yn
                      ,version
                      --,attribute1  -- 2017.12.28 박귀희 근태결재 재량권기준의 1차 결재자
                      --,attribute2  -- 2017.12.28 박귀희 근태결재 재량권기준의 2차 결재자
                      ,attribute3
                      --,attribute4  -- 2018.01.10 박귀희 근태결재 재량권기준의 1차 위임자
                      --,attribute5  -- 2018.01.10 박귀희 근태결재 재량권기준의 2차 위임자
                      ,attribute6
                      ,attribute7
                      ,attribute8
                      ,attribute9
                      ,attribute10
                      ,apply_start_ins_yyyymm
                      )
                values(g_application_key    --application_key
                      ,rec_emp.subsidiary_code
                      ,rec_emp.employee_number
                      ,rec_emp.status
                      ,rec_emp.lastname_eng
                      ,rec_emp.middlename_eng
                      ,rec_emp.firstname_eng
                      ,rec_emp.full_name_english
                      ,rec_emp.lastname_local
                      ,rec_emp.middlename_local
                      ,rec_emp.firstname_local
                      ,rec_emp.full_name_local
                      ,rec_emp.organization_id
                      ,rec_emp.org_name_eng
                      ,rec_emp.org_name_local
                      ,rec_emp.location_name
                      ,rec_emp.acc_div_code
                      ,rec_emp.acc_org_code
                      ,rec_emp.person_type
                      ,rec_emp.grade_type
                      ,rec_emp.grade
                      ,rec_emp.grade_title
                      ,rec_emp.grade_seniority
                      ,rec_emp.title_seniority
                      ,rec_emp.job_family
                      ,rec_emp.job_group
                      ,rec_emp.job_detail
                      ,rec_emp.position
                      ,rec_emp.pay_grade
                      ,rec_emp.pay_step
                      ,rec_emp.payment_type
                      ,rec_emp.pay_structure
                      ,rec_emp.salary_annual
                      ,rec_emp.base_salary_month
                      ,rec_emp.variable_salary_month
                      ,rec_emp.base_pay
                      ,rec_emp.currency
                      ,rec_emp.bank_code
                      ,rec_emp.bank_name
                      ,rec_emp.branch_bank_name
                      ,rec_emp.account_number
                      ,rec_emp.expense_bank_code
                      ,rec_emp.expense_bank_name
                      ,rec_emp.branch_expense_bank_name
                      ,rec_emp.expense_account_number
                      ,rec_emp.flsa_yn
                      ,rec_emp.gender
                      ,rec_emp.email
                      ,rec_emp.supervisor
                      ,rec_emp.fse_yn
                      ,rec_emp.assignment_category
                      ,rec_emp.labour_union_flag
                      ,rec_emp.probation_start_date
                      ,rec_emp.probation_end_date
                      ,rec_emp.probation_pay_rate
                      ,rec_emp.date_hire_subsidiary
                      ,rec_emp.date_hire_lge
                      ,rec_emp.date_retire
                      ,rec_emp.date_absesce_leave
                      ,rec_emp.date_reinstatement
                      ,rec_emp.contract_flag
                      ,rec_emp.last_update_date
                      --,rec_emp.insurance_yn
                      --,rec_emp.supervisor_yn
                      --,rec_emp.sectionleader_yn
                      --,rec_emp.teamleader_yn
                      --,rec_emp.unitleader_yn
                      --,rec_emp.worker_yn
                      --,rec_emp.calculate_yn
                      ,rec_emp.eai_seq_id
                      --,rec_emp.attribute1  -- 2017.12.28 박귀희 근태결재 재량권기준의 1차 결재자
                      --,rec_emp.attribute2  -- 2017.12.28 박귀희 근태결재 재량권기준의 2차 결재자
                      ,rec_emp.attribute3
                      --,rec_emp.attribute4  -- 2018.01.10 박귀희 근태결재 재량권기준의 1차 위임자
                      --,rec_emp.attribute5  -- 2018.01.10 박귀희 근태결재 재량권기준의 2차 위임자
                      ,rec_emp.attribute6
                      ,rec_emp.attribute7
                      ,rec_emp.attribute8
                      ,rec_emp.attribute9
                      ,rec_emp.attribute10
                      ,rec_emp.attribute20 --apply_start_ins_yyyymm
                      )
                ;
            else
                update emp_master em
                set    subsidiary_code          = rec_emp.subsidiary_code                                
                      ,employee_number          = rec_emp.employee_number         
                      ,status                   = rec_emp.status                  
                      ,lastname_eng             = rec_emp.lastname_eng            
                      ,middlename_eng           = rec_emp.middlename_eng          
                      ,firstname_eng            = rec_emp.firstname_eng           
                      ,full_name_english        = rec_emp.full_name_english       
                      ,lastname_local           = rec_emp.lastname_local          
                      ,middlename_local         = rec_emp.middlename_local        
                      ,firstname_local          = rec_emp.firstname_local         
                      ,full_name_local          = rec_emp.full_name_local         
                      ,organization_id          = rec_emp.organization_id         
                      ,org_name_eng             = rec_emp.org_name_eng            
                      ,org_name_local           = rec_emp.org_name_local          
                      ,location_name            = rec_emp.location_name           
                      ,acc_div_code             = rec_emp.acc_div_code            
                      ,acc_org_code             = rec_emp.acc_org_code            
                      ,person_type              = rec_emp.person_type             
                      ,grade_type               = rec_emp.grade_type              
                      ,grade                    = rec_emp.grade                   
                      ,grade_title              = rec_emp.grade_title             
                      ,grade_seniority          = rec_emp.grade_seniority         
                      ,title_seniority          = rec_emp.title_seniority         
                      ,job_family               = rec_emp.job_family              
                      ,job_group                = rec_emp.job_group               
                      ,job_detail               = rec_emp.job_detail              
                      ,position                 = rec_emp.position                
                      ,pay_grade                = rec_emp.pay_grade               
                      ,pay_step                 = rec_emp.pay_step                
                      ,payment_type             = rec_emp.payment_type            
                      ,pay_structure            = rec_emp.pay_structure           
                      ,salary_annual            = rec_emp.salary_annual           
                      ,base_salary_month        = rec_emp.base_salary_month       
                      ,variable_salary_month    = rec_emp.variable_salary_month   
                      ,base_pay                 = rec_emp.base_pay                
                      ,currency                 = rec_emp.currency                
                      ,bank_code                = rec_emp.bank_code               
                      ,bank_name                = rec_emp.bank_name               
                      ,branch_bank_name         = rec_emp.branch_bank_name        
                      ,account_number           = rec_emp.account_number          
                      ,expense_bank_code        = rec_emp.expense_bank_code       
                      ,expense_bank_name        = rec_emp.expense_bank_name       
                      ,branch_expense_bank_name = rec_emp.branch_expense_bank_name
                      ,expense_account_number   = rec_emp.expense_account_number  
                      ,flsa_yn                  = rec_emp.flsa_yn                 
                      ,gender                   = rec_emp.gender                  
                      ,email                    = rec_emp.email                   
                      ,supervisor               = rec_emp.supervisor              
                      ,fse_yn                   = rec_emp.fse_yn                  
                      ,assignment_category      = rec_emp.assignment_category     
                      ,labour_union_flag        = rec_emp.labour_union_flag       
                      ,probation_start_date     = rec_emp.probation_start_date    
                      ,probation_end_date       = rec_emp.probation_end_date      
                      ,probation_pay_rate       = rec_emp.probation_pay_rate      
                      ,date_hire_subsidiary     = rec_emp.date_hire_subsidiary    
                      ,date_hire_lge            = rec_emp.date_hire_lge           
                      ,date_retire              = rec_emp.date_retire             
                      ,date_absesce_leave       = rec_emp.date_absesce_leave      
                      ,date_reinstatement       = rec_emp.date_reinstatement      
                      ,contract_flag            = rec_emp.contract_flag           
                      ,last_update_date         = rec_emp.last_update_date        
                      --,insurance_yn             = rec_emp.insurance_yn            
                      --,supervisor_yn            = rec_emp.supervisor_yn           
                      --,sectionleader_yn         = rec_emp.sectionleader_yn        
                      --,teamleader_yn            = rec_emp.teamleader_yn           
                      --,unitleader_yn            = rec_emp.unitleader_yn           
                      --,worker_yn                = rec_emp.worker_yn               
                      --,calculate_yn             = rec_emp.calculate_yn            
                      ,version                  = rec_emp.eai_seq_id              
                      --,attribute1               = rec_emp.attribute1  -- 2017.12.28 박귀희 근태결재 재량권기준의 1차 결재자
                      --,attribute2               = rec_emp.attribute2  -- 2017.12.28 박귀희 근태결재 재량권기준의 2차 결재자
                      ,attribute3               = rec_emp.attribute3              
                      --,attribute4               = rec_emp.attribute4  -- 2018.01.10 박귀희 근태결재 재량권기준의 1차 위임자
                      --,attribute5               = rec_emp.attribute5  -- 2018.01.10 박귀희 근태결재 재량권기준의 1차 위임자
                      ,attribute6               = rec_emp.attribute6              
                      ,attribute7               = rec_emp.attribute7              
                      ,attribute8               = rec_emp.attribute8              
                      ,attribute9               = rec_emp.attribute9              
                      ,attribute10              = rec_emp.attribute10  
                      ,apply_start_ins_yyyymm   = rec_emp.attribute20                        
                where  em.application_key = g_application_key
                and    em.subsidiary_code = rec_emp.subsidiary_code
                and    em.employee_number = rec_emp.employee_number
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update xvh_emp_master_if xem
            set    xem.application_transfer_flag = 'Y'
                  ,xem.application_transfer_date = sysdate
            where  xem.eai_seq_id = rec_emp.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec_emp.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;


    -- 2017.12.28 박귀희 : 재량권 기준 결재자 정보 반영 호출    
    main_emp_approver(p_errcode, p_errbuf, p_application_user_id);
                               
EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_emp)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_emp;




/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_emp_approver                                         */
/* Description    : 인사마스터 결재자 정보(재량권기준)                        */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/12/28          Initial Release                                   */
/******************************************************************************/
PROCEDURE main_emp_approver(p_errcode             OUT VARCHAR2
                           ,p_errbuf              OUT VARCHAR2
                           ,p_application_user_id IN NUMBER
                           )
IS
    v_program_id                    lgcom_error_log.program_id%TYPE := 'LGVINFC0004';  -- main_emp 에서 호출

    v_arm_no                        VARCHAR2(30)     := lgvhr_common_pkg.decode_lookup('LGVCOM_APPROVAL_REQUEST_CODE', 'ATT0003', 'A1');
    v_org_id                        NUMBER           := lgvhr_common_pkg.get_subsidiary_id_func( lgvhr_common_pkg.get_subsidiary_code_func );

    TYPE approverArr                IS VARRAY(2) OF VARCHAR2(30);
    v_approver                      approverArr;
    v_mandator                      approverArr;
    
    v_approver_seq                  NUMBER;

BEGIN

    -- 결재자 최대수(2) 만큼
    v_approver := approverArr ( '', '' );
    v_mandator := approverArr ( '', '' );

    FOR per IN (
                SELECT subsidiary_code            AS subsidiary_code
                      ,assignment_category        AS assignment_category
                      ,organization_id            AS organization_id
                      ,NVL(position, 'NONE')      AS position_code
                      ,NVL(supervisor, 'NONE')    AS supervisor
                      ,MIN(employee_number)       AS employee_no
                      ,COUNT(*)                   AS person_cnt
                FROM   emp_master
                WHERE  subsidiary_code       = lgvhr_common_pkg.get_subsidiary_code_func
                AND    (date_retire IS NULL OR date_retire >= TRUNC(SYSDATE))  -- 퇴직자 제외
                AND    assignment_category  IS NOT NULL  -- 발령범주 없으면 제외(발령오류)
                GROUP BY subsidiary_code,
                         assignment_category, 
                         organization_id, 
                         NVL(position, 'NONE'), 
                         NVL(supervisor, 'NONE')  -- 정확성을 위해서
               )
    LOOP
        v_approver(1) := NULL;
        v_approver(2) := NULL;
        
        v_mandator(1) := NULL;
        v_mandator(2) := NULL;

        v_approver_seq := 0;
        FOR apr IN (SELECT *
                    FROM   TABLE(lgcom_bizweb_approval_pkg.call_arm_info(p_arm_no               => v_arm_no
                                                                        ,p_org_id               => v_org_id
                                                                        ,p_emp_no               => per.employee_no
                                                                        ,p_additional_type_code => NULL
                                                                        ,p_additional_code      => NULL
                                                                        ,p_rule1_type           => 'XXAUTT_EMP_CATEGORY_TYPE'
                                                                        ,p_rule1_code           => per.assignment_category  -- LGD_OW / LGD_LW
                                                                        ,p_rule2_type           => NULL
                                                                        ,p_rule2_code           => NULL
                                                                        ,p_range_code           => 'POSITION'
                                                                        ,p_uom_code             => ' '
                                                                        ,p_range_value          => 0
                                                                        ))
                   )
        LOOP
            v_approver_seq := v_approver_seq + 1;
            v_approver(v_approver_seq) := apr.p_user_no;  -- 결재자 사번
            v_mandator(v_approver_seq) := apr.p_mandator_employee_no;  -- 위임자 사번
        END LOOP;

        -- 결재자정보 반영
        UPDATE emp_master
        SET    attribute1 = v_approver(1),
               attribute2 = v_approver(2),
               attribute4 = v_mandator(1),
               attribute5 = v_mandator(2)
        WHERE  subsidiary_code            = per.subsidiary_code
        AND    (date_retire IS NULL OR date_retire >= TRUNC(SYSDATE))
        AND    assignment_category       IS NOT NULL        
        AND    assignment_category     = per.assignment_category
        AND    organization_id         = per.organization_id
        AND    NVL(position, 'NONE')   = per.position_code
        AND    NVL(supervisor, 'NONE') = per.supervisor
        ;
        
        COMMIT;
        
    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    g_step    := 'Other Exception Error(main_emp_approver)';
    p_errcode := SQLCODE;
    p_errbuf  := SQLERRM;
    lgcom_error_log_pkg.set_comment_text(g_step);
    lgcom_error_log_pkg.set_error_code(p_errcode);
    lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
    lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
    
END main_emp_approver;




/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_asg                                                  */
/* Description    : 발령 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/10/24  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_asg(p_errcode             OUT VARCHAR2
                  ,p_errbuf              OUT VARCHAR2
                  ,p_application_user_id IN NUMBER
                  )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0005';
    --v_user_id    number := -1; -- create_by, last_updated_by 에 이용
    
    v_asg_exist_flag  varchar2(1); --발령이 존재하는지 여부
    
    cursor cur_asg
    is
        select xea.eai_seq_id
              ,xea.subsidiary_code
              ,xea.employee_number
              ,xea.assignment_start_date
              ,xea.assignment_id
              ,xea.header
              ,xea.assignment_type_1st
              ,xea.assignment_type_2nd
              ,xea.assignment_reason
              ,xea.organization_id
              ,xea.org_name_eng
              ,xea.org_name_local
              ,xea.location_name
              ,xea.acc_div_code
              ,xea.acc_org_code
              ,xea.grade_type
              ,xea.grade
              ,xea.grade_title
              ,xea.grade_seniority
              ,xea.title_seniority
              ,xea.job_family
              ,xea.job_group
              ,xea.job_detail
              ,xea.position
              ,xea.supervisor
              ,xea.fse_yn
              ,xea.assignment_category
              ,xea.pay_grade
              ,xea.pay_step
              ,xea.pay_structure
              ,xea.salary_annual
              ,xea.base_salary_month
              ,xea.variable_salary_month
              ,xea.base_pay
              ,xea.attribute1
              ,xea.attribute2
              ,xea.attribute3
              ,xea.attribute4
              ,xea.attribute5
              ,xea.attribute6
              ,xea.attribute7
              ,xea.attribute8
              ,xea.attribute9
              ,xea.attribute10
              ,xea.attribute11
              ,xea.attribute12
              ,xea.attribute13
              ,xea.attribute14
              ,xea.attribute15
              ,xea.attribute16
              ,xea.attribute17
              ,xea.attribute18
              ,xea.attribute19
              ,xea.attribute20
              ,xea.transfer_date
              ,xea.transfer_flag
              ,xea.transfer_status
              ,xea.sys_date
              ,xea.last_update_date
        from   xvh_emp_assig_if xea
        where  xea.application_transfer_flag = 'N'
        order by decode(xea.header, 'D', 1, 2), xea.eai_seq_id  --처리 순서를 정하기 위해(20171226:삭제건 먼저 처리하게)
    ;

BEGIN
    /*
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    */
    
    for rec_asg IN cur_asg
    loop
        begin
            g_step := 'main_asg : Assignment I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_asg_exist_flag
            from   emp_assig ea
            where  ea.application_key = g_application_key
            and    ea.subsidiary_code = rec_asg.subsidiary_code
            and    ea.employee_number = rec_asg.employee_number
            and    ea.assignment_start_date = rec_asg.assignment_start_date
            ;
            
            --발령정보 생성/수정/삭제
            if rec_asg.header = 'D'
            then
                delete 
                from   emp_assig ea
                where  ea.application_key = g_application_key
                and    ea.subsidiary_code = rec_asg.subsidiary_code
                and    ea.employee_number = rec_asg.employee_number
                and    ea.assignment_start_date = rec_asg.assignment_start_date
                ;
            
            elsif v_asg_exist_flag = 'N'  --존재하지 않으면
            then
                insert into emp_assig
                      (application_key
                      ,subsidiary_code
                      ,employee_number
                      ,assignment_start_date
                      ,assignment_id
                      ,assignment_type_1st
                      ,assignment_type_2nd
                      ,assignment_reason
                      ,organization_id
                      ,org_name_eng
                      ,org_name_local
                      ,location_name
                      ,acc_div_code
                      ,acc_org_code
                      ,grade_type
                      ,grade
                      ,grade_title
                      ,grade_seniority
                      ,title_seniority
                      ,job_family
                      ,job_group
                      ,job_detail
                      ,position
                      ,supervisor
                      ,fse_yn
                      ,assignment_category
                      ,pay_grade
                      ,pay_step
                      ,pay_structure
                      ,salary_annual
                      ,base_salary_month
                      ,variable_salary_month
                      ,base_pay
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
                      ,attribute11
                      ,attribute12
                      ,attribute13
                      ,attribute14
                      ,attribute15
                      ,attribute16
                      ,attribute17
                      ,attribute18
                      ,attribute19
                      ,attribute20
                      ,last_update_date
                      ,version
                      )
                values(g_application_key    --application_key
                      ,rec_asg.subsidiary_code
                      ,rec_asg.employee_number
                      ,rec_asg.assignment_start_date
                      ,rec_asg.assignment_id
                      ,rec_asg.assignment_type_1st
                      ,rec_asg.assignment_type_2nd
                      ,rec_asg.assignment_reason
                      ,rec_asg.organization_id
                      ,rec_asg.org_name_eng
                      ,rec_asg.org_name_local
                      ,rec_asg.location_name
                      ,rec_asg.acc_div_code
                      ,rec_asg.acc_org_code
                      ,rec_asg.grade_type
                      ,rec_asg.grade
                      ,rec_asg.grade_title
                      ,rec_asg.grade_seniority
                      ,rec_asg.title_seniority
                      ,rec_asg.job_family
                      ,rec_asg.job_group
                      ,rec_asg.job_detail
                      ,rec_asg.position
                      ,rec_asg.supervisor
                      ,rec_asg.fse_yn
                      ,rec_asg.assignment_category
                      ,rec_asg.pay_grade
                      ,rec_asg.pay_step
                      ,rec_asg.pay_structure
                      ,rec_asg.salary_annual
                      ,rec_asg.base_salary_month
                      ,rec_asg.variable_salary_month
                      ,rec_asg.base_pay
                      ,rec_asg.attribute1
                      ,rec_asg.attribute2
                      ,rec_asg.attribute3
                      ,rec_asg.attribute4
                      ,rec_asg.attribute5
                      ,rec_asg.attribute6
                      ,rec_asg.attribute7
                      ,rec_asg.attribute8
                      ,rec_asg.attribute9
                      ,rec_asg.attribute10
                      ,rec_asg.attribute11
                      ,rec_asg.attribute12
                      ,rec_asg.attribute13
                      ,rec_asg.attribute14
                      ,rec_asg.attribute15
                      ,rec_asg.attribute16
                      ,rec_asg.attribute17
                      ,rec_asg.attribute18
                      ,rec_asg.attribute19
                      ,rec_asg.attribute20
                      ,rec_asg.last_update_date
                      ,rec_asg.eai_seq_id --version_id
                      )
                ;
            else
                update emp_assig ea
                set    subsidiary_code       = rec_asg.subsidiary_code   
                      ,employee_number       = rec_asg.employee_number      
                      ,assignment_start_date = rec_asg.assignment_start_date
                      ,assignment_id         = rec_asg.assignment_id        
                      ,assignment_type_1st   = rec_asg.assignment_type_1st  
                      ,assignment_type_2nd   = rec_asg.assignment_type_2nd  
                      ,assignment_reason     = rec_asg.assignment_reason    
                      ,organization_id       = rec_asg.organization_id      
                      ,org_name_eng          = rec_asg.org_name_eng         
                      ,org_name_local        = rec_asg.org_name_local       
                      ,location_name         = rec_asg.location_name        
                      ,acc_div_code          = rec_asg.acc_div_code         
                      ,acc_org_code          = rec_asg.acc_org_code         
                      ,grade_type            = rec_asg.grade_type           
                      ,grade                 = rec_asg.grade                
                      ,grade_title           = rec_asg.grade_title          
                      ,grade_seniority       = rec_asg.grade_seniority      
                      ,title_seniority       = rec_asg.title_seniority      
                      ,job_family            = rec_asg.job_family           
                      ,job_group             = rec_asg.job_group            
                      ,job_detail            = rec_asg.job_detail           
                      ,position              = rec_asg.position             
                      ,supervisor            = rec_asg.supervisor           
                      ,fse_yn                = rec_asg.fse_yn               
                      ,assignment_category   = rec_asg.assignment_category  
                      ,pay_grade             = rec_asg.pay_grade            
                      ,pay_step              = rec_asg.pay_step             
                      ,pay_structure         = rec_asg.pay_structure        
                      ,salary_annual         = rec_asg.salary_annual        
                      ,base_salary_month     = rec_asg.base_salary_month    
                      ,variable_salary_month = rec_asg.variable_salary_month
                      ,base_pay              = rec_asg.base_pay             
                      ,attribute1            = rec_asg.attribute1           
                      ,attribute2            = rec_asg.attribute2           
                      ,attribute3            = rec_asg.attribute3           
                      ,attribute4            = rec_asg.attribute4           
                      ,attribute5            = rec_asg.attribute5           
                      ,attribute6            = rec_asg.attribute6           
                      ,attribute7            = rec_asg.attribute7           
                      ,attribute8            = rec_asg.attribute8           
                      ,attribute9            = rec_asg.attribute9           
                      ,attribute10           = rec_asg.attribute10          
                      ,attribute11           = rec_asg.attribute11          
                      ,attribute12           = rec_asg.attribute12          
                      ,attribute13           = rec_asg.attribute13          
                      ,attribute14           = rec_asg.attribute14          
                      ,attribute15           = rec_asg.attribute15          
                      ,attribute16           = rec_asg.attribute16          
                      ,attribute17           = rec_asg.attribute17          
                      ,attribute18           = rec_asg.attribute18          
                      ,attribute19           = rec_asg.attribute19          
                      ,attribute20           = rec_asg.attribute20          
                      ,last_update_date      = rec_asg.last_update_date     
                      ,version               = rec_asg.eai_seq_id                     
                where  ea.application_key = g_application_key
                and    ea.subsidiary_code = rec_asg.subsidiary_code
                and    ea.employee_number = rec_asg.employee_number
                and    ea.assignment_start_date = rec_asg.assignment_start_date
                ;     
            end if;
            
            --ERP에서 발령종료일이 2개월 전 정보는 보내지 않는데
            --2개월이전 신규 발령을 생성하면 신규 발령 이전 발령의 발령종료일이 변경되지 않는다.(201712월 open 시점에 발령을 정리하면서 발생)
            --위 같은경우 발령일자가 중복이 발생하므로 중복제거하기 위해 이전 발령의 발령종료일을 수정한다.
            update emp_assig ea
            set    ea.attribute1  = to_char(rec_asg.assignment_start_date -1, 'YYYYMMDD')
                  ,ea.attribute20 = '발령일자 중복 보정작업'
            where  ea.application_key = g_application_key
            and    ea.subsidiary_code = rec_asg.subsidiary_code
            and    ea.employee_number = rec_asg.employee_number
            and    rec_asg.assignment_start_date between ea.assignment_start_date and to_date(ea.attribute1, 'YYYYMMDD')
            and    ea.assignment_start_date != rec_asg.assignment_start_date
            ;   
            
            --i/f 결과 처리(정상)
            update xvh_emp_assig_if xea
            set    xea.application_transfer_flag = 'Y'
                  ,xea.application_transfer_date = sysdate
            where  xea.eai_seq_id = rec_asg.eai_seq_id
            ;
            
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('eai_seq_id : ' || rec_asg.eai_seq_id || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_asg)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_asg;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_family                                               */
/* Description    : 가족 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_family(p_errcode             OUT VARCHAR2
                     ,p_errbuf              OUT VARCHAR2
                     ,p_application_user_id IN NUMBER
                     )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0006';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_exist_flag  varchar2(1); --가족정보가 존재하는지 여부
    
    cursor cur_family
    is
        select tfr.eai_seq_id
              ,tfr.data_interface_type_code
              ,tfr.eai_interface_date
              ,tfr.application_transfer_flag
              ,tfr.application_transfer_date
              ,tfr.employee_no
              ,tfr.family_person_id
              ,tfr.relation_code
              ,tfr.relation_desc
              ,tfr.family_name
              ,tfr.marital_status_code
              ,tfr.dependent_flag
              ,tfr.relation_start_date
              ,tfr.subsidiary_code
        from   tb_intf_family_data_r_p_i tfr
        where  tfr.application_transfer_flag = 'N'
        order by tfr.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    for rec IN cur_family
    loop
        begin
            g_step := 'main_family : Family Info I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_exist_flag
            from   tb_pay_emp_family_n tpf
            where  tpf.employee_no      = rec.employee_no
            and    tpf.family_person_id = rec.family_person_id
            ;
            
            --가족정보 생성/수정/삭제
            if rec.data_interface_type_code = 'D'
            then
                delete 
                from   tb_pay_emp_family_n tpf
                where  tpf.employee_no      = rec.employee_no
                and    tpf.family_person_id = rec.family_person_id
                ;
            
            elsif v_exist_flag = 'N'  --존재하지 않으면
            then
                insert into tb_pay_emp_family_n
                      (employee_no
                      ,family_person_id
                      ,relation_code
                      ,relation_desc
                      ,family_name
                      ,marital_status_code
                      ,dependent_flag
                      ,relation_start_date
                      ,creation_date
                      ,creation_user_id
                      ,last_update_date
                      ,last_updated_by_id
                      )
                values(rec.employee_no
                      ,rec.family_person_id
                      ,rec.relation_code
                      ,rec.relation_desc
                      ,rec.family_name
                      ,rec.marital_status_code
                      ,rec.dependent_flag
                      ,rec.relation_start_date
                      ,sysdate
                      ,v_user_id
                      ,sysdate
                      ,v_user_id
                      )
                ;
            else
                update tb_pay_emp_family_n tpf
                set    relation_code       = rec.relation_code
                      ,relation_desc       = rec.relation_desc
                      ,family_name         = rec.family_name
                      ,marital_status_code = rec.marital_status_code
                      ,dependent_flag      = rec.dependent_flag
                      ,relation_start_date = rec.relation_start_date
                      ,last_update_date    = sysdate
                      ,last_updated_by_id  = v_user_id                
                where  tpf.employee_no      = rec.employee_no
                and    tpf.family_person_id = rec.family_person_id
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update tb_intf_family_data_r_p_i tfr
            set    tfr.application_transfer_flag = 'Y'
                  ,tfr.application_transfer_date = sysdate
            where  tfr.eai_seq_id = rec.eai_seq_id
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
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_family)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_family;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_qualification                                        */
/* Description    : 자격 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_qualification(p_errcode             OUT VARCHAR2
                            ,p_errbuf              OUT VARCHAR2
                            ,p_application_user_id IN NUMBER
                            )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0007';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_exist_flag  varchar2(1); --자격정보가 존재하는지 여부
    
    cursor cur_qualification
    is
        select tqr.eai_seq_id
              ,tqr.data_interface_type_code
              ,tqr.eai_interface_date
              ,tqr.application_transfer_flag
              ,tqr.application_transfer_date
              ,tqr.subsidiary_name 
              ,tqr.employee_no
              ,tqr.qualification_type_id
              ,tqr.certificate_grade_code
              ,to_char(tqr.acquisition_date, 'YYYYMMDD') acquisition_date
              ,tqr.qualification_no
              ,tqr.awarding_body_name
              ,tqr.last_update_date
              ,tqr.creation_date
        from   tb_intf_qualification_r_p_i tqr
        where  tqr.application_transfer_flag = 'N'
        order by tqr.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    for rec IN cur_qualification
    loop
        begin
            g_step := 'main_qualification : Qualification I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_exist_flag
            from   tb_pay_emp_certification_acq_n tpc
            where  tpc.employee_no           = rec.employee_no
            and    tpc.qualification_type_id = rec.qualification_type_id
            ;
            
            --자격정보 생성/수정/삭제
            if rec.data_interface_type_code = 'D'
            then
                delete 
                from   tb_pay_emp_certification_acq_n tpc
                where  tpc.employee_no           = rec.employee_no
                and    tpc.qualification_type_id = rec.qualification_type_id
                ;
            
            elsif v_exist_flag = 'N'  --존재하지 않으면
            then
                insert into tb_pay_emp_certification_acq_n
                      (employee_no
                      ,qualification_type_id
                      ,qlfc_acquisition_yyyymmdd
                      ,certificate_grade_code
                      ,qualification_no
                      ,awarding_body_name
                      ,creation_date
                      ,creation_user_id
                      ,last_update_date
                      ,last_update_user_id
                      )
                values(rec.employee_no
                      ,rec.qualification_type_id
                      ,rec.acquisition_date
                      ,rec.certificate_grade_code
                      ,rec.qualification_no
                      ,rec.awarding_body_name
                      ,sysdate
                      ,v_user_id
                      ,sysdate
                      ,v_user_id
                      )
                ;
            else
                update tb_pay_emp_certification_acq_n tpc
                set    qlfc_acquisition_yyyymmdd = rec.acquisition_date
                      ,certificate_grade_code    = rec.certificate_grade_code
                      ,qualification_no          = rec.qualification_no
                      ,awarding_body_name        = rec.awarding_body_name
                      ,last_update_date          = sysdate
                      ,last_update_user_id       = v_user_id                
                where  tpc.employee_no           = rec.employee_no
                and    tpc.qualification_type_id = rec.qualification_type_id
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update tb_intf_qualification_r_p_i tqr
            set    tqr.application_transfer_flag = 'Y'
                  ,tqr.application_transfer_date = sysdate
            where  tqr.eai_seq_id = rec.eai_seq_id
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
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_qualification)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_qualification;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_contract                                             */
/* Description    : 계약 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09  Jaehyun Kim  Initial Release                                   */
/******************************************************************************/
PROCEDURE main_contract(p_errcode             OUT VARCHAR2
                       ,p_errbuf              OUT VARCHAR2
                       ,p_application_user_id IN NUMBER
                       )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0008';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_exist_flag  varchar2(1); --계약정보가 존재하는지 여부
    
    cursor cur_contract
    is
        select tcr.eai_seq_id
              ,tcr.data_interface_type_code
              ,tcr.eai_interface_date
              ,tcr.application_transfer_flag
              ,tcr.application_transfer_date
              ,tcr.employee_no
              ,tcr.contract_type_code
              ,tcr.subsidiary_code
              ,tcr.contract_period_start_date
              ,tcr.contract_period_end_date
              ,tcr.extension_flag
        from   tb_intf_contract_info_r_p_i tcr
        where  tcr.application_transfer_flag = 'N'
        order by tcr.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
        
    for rec IN cur_contract
    loop
        begin
            g_step := 'main_contract : Contract I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_exist_flag
            from   tb_pay_emp_contract_n tpc
            where  tpc.employee_no        = rec.employee_no
            and    tpc.contract_type_code = rec.contract_type_code
            ;
            
            --계약정보 생성/수정/삭제
            if rec.data_interface_type_code = 'D'
            then
                delete 
                from   tb_pay_emp_contract_n tpc
                where  tpc.employee_no        = rec.employee_no
                and    tpc.contract_type_code = rec.contract_type_code
                ;
            
            elsif v_exist_flag = 'N'  --존재하지 않으면
            then
                insert into tb_pay_emp_contract_n
                      (employee_no
                      ,contract_type_code
                      ,subsidiary_code
                      ,contract_period_start_date
                      ,contract_period_end_date
                      ,extension_flag
                      ,creation_date
                      ,creation_user_id
                      ,last_update_date
                      ,last_update_user_id
                      )
                values(rec.employee_no
                      ,rec.contract_type_code
                      ,rec.subsidiary_code
                      ,rec.contract_period_start_date
                      ,rec.contract_period_end_date
                      ,rec.extension_flag
                      ,sysdate
                      ,v_user_id
                      ,sysdate
                      ,v_user_id
                      )
                ;
            else
                update tb_pay_emp_contract_n tpc
                set    contract_period_start_date = rec.contract_period_start_date
                      ,contract_period_end_date   = rec.contract_period_end_date
                      ,extension_flag             = rec.extension_flag  
                where  tpc.employee_no        = rec.employee_no
                and    tpc.contract_type_code = rec.contract_type_code
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update tb_intf_contract_info_r_p_i tcr
            set    tcr.application_transfer_flag = 'Y'
                  ,tcr.application_transfer_date = sysdate
            where  tcr.eai_seq_id = rec.eai_seq_id
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
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_contract)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_contract;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : main_grade_point                                          */
/* Description    : 급호 정보 I/F                                             */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/09  Jaehyun Kim  Initial Release                                   */
/* 2018/01/02  Son suyang   end date 가 업데이트 안되서 수정함                */
/******************************************************************************/
PROCEDURE main_grade_point(p_errcode             OUT VARCHAR2
                          ,p_errbuf              OUT VARCHAR2
                          ,p_application_user_id IN NUMBER
                          )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0008';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    v_exist_flag  varchar2(1); --급호정보가 존재하는지 여부
    
    cursor cur_grade_point
    is
        select tgr.eai_seq_id
              ,tgr.data_interface_type_code
              ,tgr.eai_interface_date
              ,tgr.application_transfer_flag
              ,tgr.application_transfer_date
              ,tgr.subsidiary_code
              ,tgr.employee_no
              ,tgr.grade_type_name
              ,tgr.grade_point_value
              ,tgr.start_yyyymmdd
              ,tgr.end_yyyymmdd
        from   tb_intf_grade_point_r_p_i tgr
        where  tgr.application_transfer_flag = 'N'
        order by tgr.eai_seq_id  --처리 순서를 정하기 위해
    ;

BEGIN
    
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    for rec IN cur_grade_point
    loop
        begin
            g_step := 'main_grade_point : Grade Point I/F';
            
            --header의 I/U로 판단하지 않고 테이블에 있는지 체크
            select case when count(*) = 0
                        then 'N'
                        else 'Y'
                   end
            into   v_exist_flag
            from   tb_pay_emp_grade_point_n tpg
            where  tpg.employee_no    = rec.employee_no
            and    tpg.start_yyyymmdd = rec.start_yyyymmdd
            ;
            
            --급호정보 생성/수정/삭제
            if rec.data_interface_type_code = 'D'
            then
                delete 
                from   tb_pay_emp_grade_point_n tpg
                where  tpg.employee_no    = rec.employee_no
                and    tpg.start_yyyymmdd = rec.start_yyyymmdd
                ;
            
            elsif v_exist_flag = 'N'  --존재하지 않으면
            then
                insert into tb_pay_emp_grade_point_n
                      (employee_no
                      ,grade_title_code
                      ,competency_grade_point_code
                      ,start_yyyymmdd
                      ,subsidiary_code
                      ,end_yyyymmdd
                      ,creation_date
                      ,creation_user_id
                      ,last_update_date
                      ,last_updated_by_id
                      )
                values(rec.employee_no
                      ,rec.grade_type_name
                      ,rec.grade_point_value
                      ,rec.start_yyyymmdd
                      ,rec.subsidiary_code
                      ,rec.end_yyyymmdd
                      ,sysdate
                      ,v_user_id
                      ,sysdate
                      ,v_user_id
                      )
                ;
            ELSE
                /* 종료일자 가 반영안되는 부분 수정함 */
                update tb_pay_emp_grade_point_n tpg
                set    tpg.grade_title_code             = rec.grade_type_name
                      ,tpg.competency_grade_point_code  = rec.grade_point_value
                      ,tpg.end_yyyymmdd                 = rec.end_yyyymmdd
                      ,tpg.last_update_date   = sysdate
                      ,tpg.last_updated_by_id = v_user_id                 
                where  tpg.employee_no    = rec.employee_no
                and    tpg.start_yyyymmdd = rec.start_yyyymmdd
                ;     
            end if;
            
            --i/f 결과 처리(정상)
            update tb_intf_grade_point_r_p_i tgr
            set    tgr.application_transfer_flag = 'Y'
                  ,tgr.application_transfer_date = sysdate
            where  tgr.eai_seq_id = rec.eai_seq_id
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
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(main_grade_point)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END main_grade_point;

/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : user_role_proc                                            */
/* Description    : 권한 설정                                                 */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/01  Jaehyun Kim  Initial Release                                   */
/* 2021/05/12  윤덕기  Tunning RRV0296913 2021-04-19                                   */
/******************************************************************************/
PROCEDURE user_role_proc(p_errcode             OUT VARCHAR2
                        ,p_errbuf              OUT VARCHAR2
                        ,p_application_user_id IN NUMBER   --처리자
                        )
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0010';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    --권한설정할 인원정보(모든인원의 권한별)
    CURSOR cur_user
    IS
        SELECT em.employee_number
              ,lu.application_user_id
              ,em.date_retire --퇴직일자
              ,em.assignment_category 
              ,ome.org_manager_flag
              ,lcc.common_code as role_code 
              ,CASE WHEN (((lcc.common_code = 'VN_OFFICE_WORK_USER' AND em.assignment_category = 'LGD_OW' AND em.fse_yn = 'N'
                           ) --사무직중 FSE 제외
                           
                           OR (lcc.common_code = 'VN_UNIT_LEADER_USER' AND em.assignment_category != 'LGD_OW' AND (ome.org_manager_flag = 'Y' OR em.position IS NOT NULL)
                              ) --기능직 조직책임자 or Position 있는인원

                           OR (lcc.common_code = 'VN_ORG_MANAGER' AND em.assignment_category = 'LGD_OW' AND (ome.org_manager_flag = 'Y' OR em.position IS NOT NULL)
                                                                  AND (em.fse_yn = 'N' OR (em.fse_yn = 'Y' AND em.position IS NOT NULL))
                              ) --사무직 조직책임자(Position 있는인원 포함)중 FSE 제외
                              
                           OR (lcc.common_code = 'VN_LINE_WORK_PIC_USER' AND pic.pic_flag = 'Y'
                              ) --PIC 등록인원
                              
                           OR (lcc.common_code = 'VN_ATT_FSE_USER' AND em.fse_yn = 'Y' AND em.position IS NOT NULL
                              ) --Position이 있는 FSE 인원
                              
                           OR (lcc.common_code = 'VN_COMMON_USER' AND (em.assignment_category = 'LGD_OW' OR (em.assignment_category != 'LGD_OW' AND (ome.org_manager_flag = 'Y' OR em.position IS NOT NULL)) OR pic.pic_flag = 'Y')
                              )
                              
                           OR (lcc.common_code = 'VN_PAY_EMPLOYEE_USER' AND em.fse_yn = 'N'
                              ) --전체중 FSE 제외
                              
                           OR (lgvhr_common_pkg.decode_lookup('LGVHR_EXCEPT_' || lcc.common_code, em.employee_number) = em.employee_number
                              ) --예외자 : 2018.01.10 박귀희 : 권한 예외자 등록 필요할때 처리 => 권한해지시에는 룩업에서 삭제하여야 함
                              
                           OR (((lcc.common_code = 'VN_ORG_MANAGER' AND em.assignment_category = 'LGD_OW')
                                OR
                                (lcc.common_code = 'VN_UNIT_LEADER_USER' AND em.assignment_category = 'LGD_LW')
                               ) AND EXISTS (SELECT 'Y'
                                             FROM   emp_master s
                                             WHERE  ((    em.employee_number = s.attribute1 
                                                      AND s.attribute4      IS NOT NULL      -- 1차 위임을 받았거나
                                                      AND EXISTS (SELECT 'Y' 
                                                                  FROM   org_master 
                                                                  WHERE  org_manager_number = s.attribute4
                                                                  AND    TRUNC(SYSDATE) BETWEEN org_start_date AND NVL(org_end_date, TRUNC(SYSDATE))
                                                                 )
                                                     )
                                       /*-----Start of tunning RRV0296913 2021-04-19 윤덕기-----*/
                                                     --OR
                                                     --(    em.employee_number = s.attribute2
                                                     -- AND s.attribute5      IS NOT NULL      -- 2차 위임을 받았거나
                                                     -- AND EXISTS (SELECT 'Y' 
                                                     --             FROM   org_master 
                                                     --             WHERE  org_manager_number = s.attribute5
                                                     --             AND    TRUNC(SYSDATE) BETWEEN org_start_date AND NVL(org_end_date, TRUNC(SYSDATE))
                                                     --            )
                                                     --) 
                                                    )
                                             AND    s.date_retire IS NULL
                                       UNION ALL
                                             SELECT 'Y'
                                             FROM   emp_master s
                                             WHERE  ((    em.employee_number = s.attribute2
                                                      AND s.attribute5      IS NOT NULL      -- 2차 위임을 받았거나
                                                      AND EXISTS (SELECT 'Y' 
                                                                  FROM   org_master 
                                                                  WHERE  org_manager_number = s.attribute5
                                                                  AND    TRUNC(SYSDATE) BETWEEN org_start_date AND NVL(org_end_date, TRUNC(SYSDATE))
                                                                 )
                                                     )
                                                    )
                                             AND    s.date_retire IS NULL
                                       /*-----End of tunning RRV0296913 2021-04-19 윤덕기-----*/             
                                            )
                              ) -- 2018.01.31 : 박귀희 : 조책아니지만 조책위임받았으면, 해당 권한 추가해 줌. 위임종료되면 권한 없어짐

                          ) --신규권한 추가시 여기에 조건을 추가해야함.(common code : LGVHR_COMMON_ROLE_CODE 등록)

                          AND TRUNC(SYSDATE) BETWEEN lcc.apply_start_date AND NVL(lcc.apply_end_date, TRUNC(SYSDATE)) --유효한 권한
                         )
                    THEN 'I'
                    ELSE 'D'
               END AS role_flag  
              ,lu.apply_end_date  
              ,lcc.apply_end_date role_end_date                       
        FROM   emp_master          em
              ,lgcom_common_code_c lcc
              ,lgcom_user_m        lu 
              ,(SELECT org_manager_number AS org_manager_number
                      ,'Y'                AS org_manager_flag
                FROM   org_master
                WHERE  TRUNC(SYSDATE) BETWEEN org_start_date AND NVL(org_end_date, TRUNC(SYSDATE))
                GROUP BY org_manager_number
               ) ome 
              ,(SELECT time_attend_contact_user_id AS employee_no
                      ,'Y'                         AS pic_flag
                FROM   tb_att_contract_n
                WHERE  TRUNC(SYSDATE) BETWEEN effective_start_date AND NVL(effective_end_date, TRUNC(SYSDATE))
                GROUP BY time_attend_contact_user_id
               ) pic
        WHERE  lcc.code_type_code = 'LGVHR_COMMON_ROLE_CODE'
        AND    em.employee_number = lu.user_name
        AND    em.employee_number = ome.org_manager_number(+)
        AND    em.employee_number = pic.employee_no(+)
        AND    em.flsa_yn         = 'N'  --단기파견자 제외
        AND    lcc.use_flag       = 'Y'  --use_flag N 은 자동권한설정을 사용안한다는 의미이고 종료일자(apply_end_date)는 자동권한설정은 사용하지만 권한을 종료처리한다는 의미
        --and    nvl(lu.apply_end_date, lgvhr_common_pkg.end_of_time)  < trunc(sysdate) - 5  --대상자 제한 : 유저종료(퇴직)일자 이후 5일간 체크(퇴직일자가 늦게 if 될수 있으므로)
    ;
    
    v_user_role_flag   varchar2(1); --권한설정여부
    v_apply_start_date date;        --권한시작일자
    v_apply_end_date   date;        --권한종료일자

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    --권한 삭제(유저정보 or 인사마스터에 없는 인원에 대하여) : 자동설정권한만
    delete lgcom_user_role_n t
    where  (t.application_user_id, t.role_code) in
             (select lur.application_user_id
                    ,lur.role_code
              from   lgcom_user_role_n lur
                    ,lgcom_common_code_c lcc
              where  lcc.code_type_code = 'LGVHR_COMMON_ROLE_CODE'
              and    lcc.common_code = lur.role_code  
              and    not exists (select 'Y' --유저정보 or 인사마스터에 없으면
                                 from   lgcom_user_m um
                                       ,emp_master   em
                                 where  um.user_name = em.employee_number
                                 and    um.application_user_id = lur.application_user_id
                                )
             )
    ;
    --권한삭제(유저정보가 없는 전체 권한에 대하여)
    delete lgcom_user_role_n t
    where  not exists (select 'Y' --유저정보가 없으면
                       from   lgcom_user_m um
                       where  um.application_user_id = t.application_user_id
                      )
    ;
    commit;
    
    for rec_user IN cur_user
    loop
        begin
            g_step := 'User Role Set';
            
            --기존 설정된 권한 구하기
            select decode(count(*), 0, 'N', 'Y')
                  ,max(lur.apply_start_date)
                  ,max(lur.apply_end_date)
            into   v_user_role_flag
                  ,v_apply_start_date
                  ,v_apply_end_date
            from   lgcom_user_role_n lur
            where  lur.application_user_id = rec_user.application_user_id
            and    lur.role_code           = rec_user.role_code
            ;
            
            if nvl(rec_user.apply_end_date, trunc(sysdate)) < trunc(sysdate)  --유저종료일(기본적으로 퇴직일자)
            then
                if v_user_role_flag = 'Y' --기존에 권한이 있으면
                then
                    --권한시작일자 상관없이 권한종료일자를 유저종료일로 변경
                    if nvl(v_apply_end_date, trunc(sysdate)) > rec_user.apply_end_date
                    then
                        update lgcom_user_role_n lur
                        set    lur.apply_end_date   = rec_user.apply_end_date
                              ,lur.last_updated_by  = v_user_id
                              ,lur.last_update_date = sysdate
                              ,lur.approver_opinion_desc = v_program_id || ' : User End'
                        where  lur.application_user_id = rec_user.application_user_id
                        and    lur.role_code           = rec_user.role_code
                        ;
                    end if;
                end if; 
                
            elsif rec_user.role_flag = 'I' --추가해야 할 권한이면
            then
                if v_user_role_flag = 'Y' --기존에 권한이 있으면
                then
                    if trunc(sysdate) between v_apply_start_date and nvl(v_apply_end_date, trunc(sysdate))
                    then
                        null; --현재 유효하면 처리안함
                    else --유효하지 않으면 유효하게 변경(현재 ~ )
                        update lgcom_user_role_n lur
                        set    lur.apply_start_date = trunc(sysdate) 
                              ,lur.apply_end_date   = null
                              ,lur.last_updated_by  = v_user_id
                              ,lur.last_update_date = sysdate
                              ,lur.approver_opinion_desc = v_program_id || ' : End -> Use'
                        where  lur.application_user_id = rec_user.application_user_id
                        and    lur.role_code           = rec_user.role_code
                        ;
                    end if;
                    
                else                      -- 없으면
                    --권한 추가
                    insert into lgcom_user_role_n 
                          (application_user_id
                          ,role_code
                          ,apply_start_date
                          ,apply_end_date
                          ,created_by
                          ,creation_date
                          ,last_updated_by
                          ,last_update_date
                          ,approver_opinion_desc
                          )
                    values(rec_user.application_user_id
                          ,rec_user.role_code
                          ,trunc(sysdate)
                          ,null --rec_user.apply_end_date
                          ,v_user_id
                          ,sysdate
                          ,v_user_id
                          ,sysdate
                          ,v_program_id || ' : Create'
                          )
                    ;

                end if;
            
            elsif rec_user.role_flag = 'D' --삭제해야 할 권한이면(종료처리)
            then    
                if v_user_role_flag = 'Y' --기존에 권한이 있으면
                then
                    if trunc(sysdate) between v_apply_start_date and nvl(v_apply_end_date, trunc(sysdate))
                    then
                        --유효하면 유효하지 않게 변경(종료일자를 어제일자로 )
                        update lgcom_user_role_n lur
                        set    lur.apply_end_date   = trunc(sysdate - 1)
                              ,lur.last_updated_by  = v_user_id
                              ,lur.last_update_date = sysdate
                              ,lur.approver_opinion_desc = v_program_id || ' : Use -> End'
                        where  lur.application_user_id = rec_user.application_user_id
                        and    lur.role_code           = rec_user.role_code
                        ;
                    else 
                        null; --현재 유효않하면 처리안함
                    end if;
                end if;
            end if;
            commit;
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('employee_number : ' || rec_user.employee_number || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(user_role_proc)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END user_role_proc;         
     
/******************************************************************************/
/*                 (c) Copyright LG CNS Inc. 2017                             */
/*                      All rights reserved.                                  */
/******************************************************************************/
/*                                                                            */
/* Program Name   : my_menu_proc                                              */
/* Description    : My Menu 설정                                              */
/*                                                                            */
/* Parameter       :  Name                in/out   type      description
/*                ---------------------------------------------------------
/*
/*
/******************************************************************************/
/* Modification Log                                                           */
/*                                                                            */
/* Date       In Charge         Description                                   */
/* ------------ -------- -------------------------------                      */
/* 2017/11/01  Jaehyun Kim  Initial Release                                   */
/*                            우선 개발 했지만 사용은 안함. 문제점 기존 my menu에서 사용안하는 menu를 제거해서 사용했을 경우 권한에 따른 menu를 추가하여 제거해놓은 menu가 다시 추가되는경우가 발생한다.
/******************************************************************************/
PROCEDURE my_menu_proc(p_errcode             OUT VARCHAR2
                      ,p_errbuf              OUT VARCHAR2
                      ,p_application_user_id IN NUMBER   --처리자
                      )   
IS
    v_program_id lgcom_error_log.program_id%TYPE := 'LGVINFC0011';
    v_user_id    number := lgvhr_common_pkg.sys_user_id; -- create_by, last_updated_by 에 이용
    
    --권한설정할 인원정보(모든인원의 권한별)
    cursor cur_user
    is
        select em.employee_number
              ,lu.application_user_id
              ,em.date_retire --퇴직일자
              ,em.assignment_category 
              ,lu.apply_end_date                       
        from   emp_master          em
              ,lgcom_user_m        lu 
        where  em.employee_number = lu.user_name
        and    exists (select 'Y' --My Menu 정보 있으면
                       from   lgcom_full_system_favor_hier_n lfh
                       where  lfh.application_user_id = lu.application_user_id
                      )
    ;
    
    v_system_flag   varchar2(1); --Menu 설정여부  
    v_system_sort   number;       

BEGIN
    if p_application_user_id is not null 
    then
        v_user_id := p_application_user_id;
    end if;
    
    --My Menu 삭제(유저정보 or 인사마스터에 없는 인원에 대하여)
    delete lgcom_full_system_favor_hier_n lfh
    where  not exists (select 'Y' --유저정보 or 인사마스터에 없으면
                       from   lgcom_user_m um
                             ,emp_master   em
                       where  um.user_name = em.employee_number
                       and    um.application_user_id = lfh.application_user_id
                      )
    ;
    
    for rec_user IN cur_user
    loop
        begin
            g_step := 'My Menu Set';
            
            for rec_menu in (select lrm.menu_id
                                   ,max(lr.system_code) system_code
                                   ,max(decode(lur.role_code, null, 'N', 'Y')) role_flag    --권한 메뉴 여부
                                   ,max(decode(lfh.menu_id, null, 'N', 'Y'))   my_menu_flag --My Menu 여부
                                   ,max(lm.sort_order_no) sort_order_no
                                   ,decode(max(decode(lur.role_code, null, 'N', 'Y')), 'N', 'D', 'I') process_flag --권한에 있으면 추가 없으면 삭제
                             from   lgcom_common_code_c lcc
                                   ,lgcom_role_m        lr
                                   ,lgcom_role_menu_n   lrm
                                   ,lgcom_user_role_n   lur
                                   ,lgcom_full_system_favor_hier_n lfh
                                   ,lgcom_menu_m        lm
                             where  lcc.code_type_code = 'LGVHR_COMMON_ROLE_CODE'
                             and    lcc.common_code    = lrm.role_code
                             and    lrm.role_code      = lr.role_code
                             and    lrm.menu_id        = lm.menu_id
                             and    lcc.common_code    = lur.role_code(+)
                             and    lur.application_user_id(+) = rec_user.application_user_id
                             and    trunc(sysdate) between lur.apply_start_date(+) and nvl(lur.apply_end_date(+), trunc(sysdate))
                             and    lfh.application_user_id(+) = rec_user.application_user_id
                             and    lrm.menu_id = lfh.menu_id(+)
                             group by lrm.menu_id
                             having max(decode(lur.role_code, null, 'N', 'Y')) != max(decode(lfh.menu_id, null, 'N', 'Y'))  --권한 메뉴와 My Menu 가 다른 경우 처리
                            )
            loop
                if rec_menu.process_flag = 'I'
                then
                    insert into lgcom_full_system_favor_hier_n
                          (application_user_id
                          ,menu_id
                          ,high_menu_id
                          ,sort_order_no
                          ,created_by
                          ,creation_date
                          ,last_updated_by
                          ,last_update_date
                          )
                    values(rec_user.application_user_id
                          ,rec_menu.menu_id
                          ,null
                          ,rec_menu.sort_order_no
                          ,v_user_id
                          ,sysdate
                          ,v_user_id
                          ,sysdate
                          )
                    ;

                elsif rec_menu.process_flag = 'D'
                then
                    --다른권한 menu로 등록되어 있지 않으면 삭제
                    delete lgcom_full_system_favor_hier_n
                    where  application_user_id = rec_user.application_user_id
                    and    menu_id             = rec_menu.menu_id
                    and    not exists (select 'Y'
                                       from   lgcom_role_menu_n   lrm
                                             ,lgcom_user_role_n   lur                                             
                                       where  lur.role_code       not in (select lcc.common_code
                                                                         from   lgcom_common_code_c lcc
                                                                         where  lcc.code_type_code = 'LGVHR_COMMON_ROLE_CODE'
                                                                        )
                                       and    lur.role_code       = lrm.role_code
                                       and    lur.application_user_id = rec_user.application_user_id
                                       and    lrm.menu_id         = rec_menu.menu_id
                                      )
                    
                    
                    ;
                end if; 
                
                --system_code 를 my menu에서 설정
                select decode(count(*), 0, 'N', 'Y')
                      ,(select nvl(max(t.sort_order_no), 0) + 1
                        from   lgcom_full_system_favor_hier_n t
                        where  t.application_user_id = lfh.application_user_id
                       )
                into   v_system_flag
                      ,v_system_sort
                from   lgcom_full_system_favor_hier_n lfh
                where  lfh.application_user_id = rec_user.application_user_id
                and    lfh.menu_id             = rec_menu.system_code
                ;
                
                if v_system_flag = 'N'
                then
                    insert into lgcom_full_system_favor_hier_n
                          (application_user_id
                          ,menu_id
                          ,high_menu_id
                          ,sort_order_no
                          ,created_by
                          ,creation_date
                          ,last_updated_by
                          ,last_update_date
                          )
                    values(rec_user.application_user_id
                          ,rec_menu.system_code
                          ,null
                          ,rec_menu.sort_order_no
                          ,v_user_id
                          ,sysdate
                          ,v_user_id
                          ,sysdate
                          )
                    ;
                end if;
                
            end loop; 
        exception    
            when others then
                rollback;
                p_errcode := sqlcode;
                p_errbuf  := substr('employee_number : ' || rec_user.employee_number || ' - ' ||sqlerrm, 1, 2000);
                lgcom_error_log_pkg.set_comment_text(g_step);
                lgcom_error_log_pkg.set_error_code(p_errcode);
                lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
                lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
        end;
        
        commit;
    end loop;

EXCEPTION
    WHEN OTHERS THEN
        g_step := 'Other Exception Error(my_menu_proc)';
        p_errcode := sqlcode;
        p_errbuf  := sqlerrm;
        lgcom_error_log_pkg.set_comment_text(g_step);
        lgcom_error_log_pkg.set_error_code(p_errcode);
        lgcom_error_log_pkg.set_error_explanation_text(p_errbuf);
        lgcom_error_log_pkg.error_prc(g_module_code, v_program_id);
END my_menu_proc;

END lgvinf_if_batch_pkg;
/
