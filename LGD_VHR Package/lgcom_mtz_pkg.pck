create or replace package vhr_mgr.lgcom_mtz_pkg is

    /*******************************************************************************
    * PACKAGE      :  lgcom_mtz_pkg
    * DESCRIPTIONS :  Query Local Datetime/Date by Legal Entity (GL Module)
    *                                           or Operating Unit (Other Module)
    * PARAMETERS   :  None
    ********************************************************************************
    * DATE         AUTHOR         DESCRIPTION
    *------------------------------------------------------------------------------
    * 2017-09-11   Kimhansik      Initial Release 
    *******************************************************************************/
    
    FUNCTION get_local_date_by_user(p_application_user_id IN NUMBER) RETURN DATE;
    
    FUNCTION get_local_date_by_timezonecode(p_timezone_code IN VARCHAR2) RETURN DATE;
    
    FUNCTION get_local_date_by_timezoneid(p_timezone_id IN NUMBER) RETURN DATE;
    
    FUNCTION get_local_date_by_subsidiary(p_subsidiary_id IN NUMBER) RETURN DATE;
    
    FUNCTION get_local_date_by_ou_id(p_ou_id IN NUMBER) RETURN DATE;
    
end lgcom_mtz_pkg;
/
create or replace package body vhr_mgr.lgcom_mtz_pkg is

    /*******************************************************************************
    * PACKAGE      :  lgcom_mtz_pkg
    * DESCRIPTIONS :  Query Local Datetime/Date by Legal Entity (GL Module)
    *                                           or Operating Unit (Other Module)
    * PARAMETERS   :  None
    ********************************************************************************
    * DATE         AUTHOR         DESCRIPTION
    *------------------------------------------------------------------------------
    * 2017-09-11   Kimhansik      Initial Release 
    *******************************************************************************/

    g_pre_user_id          NUMBER;                --Pre User_id
    g_pre_user_tz_cd       VARCHAR2(100) := NULL; --Pre User의 TimeZone Code
    g_pre_tzid_tz_id       NUMBER        := NULL; --timezoneid의 pre timezone id
    g_pre_tzid_tz_cd       VARCHAR2(100) := NULL; --timezoneid의 pre timezone code
    g_pre_subsi_id         NUMBER        := NULL; --subsidiary의 pre subsidiary_id
    g_pre_subsi_tz_cd      VARCHAR2(100) := NULL; --subsidiary의 pre timezone code
    g_pre_ou_id            NUMBER        := NULL; --Ou의 pre ou_id
    g_pre_ou_tz_cd         VARCHAR2(100) := NULL; --ou의 pre Timezone Code
    
    
    FUNCTION get_local_date_by_user(p_application_user_id IN NUMBER) RETURN DATE IS
        /******************************************************************************/
        /* Module       : LGCOM
        /* Program Name : lgcom_mtz_pkg.get_local_date_by_user_id
        /* Description  : Parameter로 받은 Application_user_id에 해당하는 TimeZone Return
        /* Reference by : lgcom_mtz_pkg
        /* Program History
        /*------------------------------------------------------------------------------
        /*   Date     In Charge          Description
        /*------------------------------------------------------------------------------
        /*  2017-09-11   Kimhansik      Initial Release 
        /******************************************************************************/
      
        v_timezone_code  VARCHAR2(100);
        v_local_date     DATE;
        
        v_application_user_id NUMBER;
    BEGIN
        
        --한 Session에서 동일 OU로 재호출 하였을 경우는 이전에 저장한 Global변수 값을 사용함
        if p_application_user_id = g_pre_user_id then
            v_timezone_code := g_pre_user_tz_cd;
        else
            v_application_user_id := p_application_user_id;
            BEGIN
                SELECT lcc.code_data1_value timezone_code
                INTO   v_timezone_code
                FROM   lgcom_user_m_v      lum
                      ,lgcom_common_code_c lcc
                WHERE  lum.application_user_id = v_application_user_id
                AND    lum.timezone_type_code = lcc.common_code
                AND    lcc.code_type_code = 'LGCOM_TIMEZONE_TYPE_CODE';
            EXCEPTION
                WHEN OTHERS THEN
                    v_timezone_code := 'Asia/Seoul';
            END;
            
            --한 Session에서 재호출 하였을 경우에 Global변수 값에 넣어 재사용하기 위함
            g_pre_user_id    := v_application_user_id;
            g_pre_user_tz_cd := v_timezone_code;
        end if;
        
        v_local_date := get_local_date_by_timezonecode(v_timezone_code);
        
        return nvl(v_local_date,sysdate);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(NULL);
    END;
    
    FUNCTION get_local_date_by_timezonecode(p_timezone_code IN VARCHAR2) RETURN DATE IS
        /******************************************************************************/
        /* Module       : LGCOM
        /* Program Name : lgcom_mtz_pkg.get_local_date_by_user_id
        /* Description  : Parameter로 받은 Application_user_id에 해당하는 TimeZone Return
        /* Reference by : lgcom_mtz_pkg
        /* Program History
        /*------------------------------------------------------------------------------
        /*   Date     In Charge          Description
        /*------------------------------------------------------------------------------
        /*  2017-09-11   Kimhansik      Initial Release 
        /******************************************************************************/
        
        v_local_date    date;
    BEGIN
              
        BEGIN
            SELECT sys_extract_utc(current_timestamp) +
                   to_number(SUBSTR(tz_offset(p_timezone_code), 1, 3)) / 24
            INTO   v_local_date
            FROM   dual;
        EXCEPTION
            WHEN OTHERS THEN
                v_local_date := sysdate;
        END;
        
        RETURN nvl(v_local_date,SYSDATE);
            
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(NULL);
    END;
    
    FUNCTION get_local_date_by_TimeZoneId(p_timezone_id IN NUMBER) RETURN DATE IS
        /******************************************************************************/
        /* Module       : LGCOM
        /* Program Name : lgcom_mtz_pkg.get_local_date_by_user_id
        /* Description  : Parameter로 받은 Application_user_id에 해당하는 TimeZone Return
        /* Reference by : lgcom_mtz_pkg
        /* Program History
        /*------------------------------------------------------------------------------
        /*   Date     In Charge          Description
        /*------------------------------------------------------------------------------
        /*  2017-09-11   Kimhansik      Initial Release 
        /******************************************************************************/
        
        v_timezone_code  VARCHAR2(100);
        v_local_date     DATE;
        
        v_timezone_id    NUMBER;
        
    BEGIN
        --한 Session에서 동일 OU로 재호출 하였을 경우는 이전에 저장한 Global변수 값을 사용함
        if p_timezone_id = g_pre_tzid_tz_id then
            v_timezone_code := g_pre_tzid_tz_cd;
        else
          
            v_timezone_id := p_timezone_id;
            
            BEGIN
                SELECT t.code_data1_value
                INTO   v_timezone_code
                FROM   lgcom_common_code_c t
                WHERE  t.code_type_code = 'LGCOM_TIMEZONE_TYPE_CODE'
                AND    t.common_code = v_timezone_id;
            EXCEPTION
                WHEN OTHERS THEN
                    v_timezone_code := 'Asia/Seoul';
            END;
        
            --한 Session에서 재호출 하였을 경우에 Global변수 값에 넣어 재사용하기 위함
            g_pre_tzid_tz_id    := v_timezone_id;
            g_pre_tzid_tz_cd    := v_timezone_code;
            
        end if;

        v_local_date := get_local_date_by_timezonecode(v_timezone_code);
        
        return nvl(v_local_date,sysdate);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(NULL);
    END;
    
    FUNCTION get_local_date_by_subsidiary(p_subsidiary_id IN NUMBER) RETURN DATE IS
        /******************************************************************************/
        /* Module       : LGCOM
        /* Program Name : lgcom_mtz_pkg.get_local_date_by_user_id
        /* Description  : Parameter로 받은 Application_user_id에 해당하는 TimeZone Return
        /* Reference by : lgcom_mtz_pkg
        /* Program History
        /*------------------------------------------------------------------------------
        /*   Date     In Charge          Description
        /*------------------------------------------------------------------------------
        /*  2017-09-11   Kimhansik      Initial Release 
        /******************************************************************************/
      
        v_timezone_code  VARCHAR2(100);
        v_local_date     DATE;
        
        v_subsidiary_id  NUMBER;
        
    BEGIN
        --한 Session에서 동일 OU로 재호출 하였을 경우는 이전에 저장한 Global변수 값을 사용함
        if p_subsidiary_id = g_pre_subsi_id then
            v_timezone_code := g_pre_subsi_tz_cd;
        else          
            v_subsidiary_id := p_subsidiary_id;
            
            BEGIN
            
                SELECT rgn.code_data5_value
                INTO   v_timezone_code
                FROM   lgcom_common_code_c lcc
                      ,lgcom_common_code_c rgn
                WHERE  lcc.code_type_code   = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                AND    lcc.common_code      = v_subsidiary_id
                AND    lcc.code_data1_value = rgn.common_code
                AND    rgn.code_type_code   = 'LGCOM_TIMEZONE_DEFAULT_COMPANY';
            EXCEPTION
                WHEN OTHERS THEN
                    v_timezone_code := 'Asia/Seoul';
            END;
        
            --한 Session에서 재호출 하였을 경우에 Global변수 값에 넣어 재사용하기 위함
            g_pre_subsi_id     := v_subsidiary_id;
            g_pre_subsi_tz_cd  := v_timezone_code;
            
        end if;

        
        v_local_date := get_local_date_by_timezonecode(v_timezone_code);
        
        return nvl(v_local_date,sysdate);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(NULL);
    END;
    
    FUNCTION get_local_date_by_ou_id(p_ou_id IN NUMBER) RETURN DATE IS
        /******************************************************************************/
        /* Module       : LGCOM
        /* Program Name : lgcom_mtz_pkg.get_local_date_by_user_id
        /* Description  : Parameter로 받은 Application_user_id에 해당하는 TimeZone Return
        /* Reference by : lgcom_mtz_pkg
        /* Program History
        /*------------------------------------------------------------------------------
        /*   Date     In Charge          Description
        /*------------------------------------------------------------------------------
        /*  2017-09-11   Kimhansik      Initial Release 
        /******************************************************************************/
      
        v_timezone_code  VARCHAR2(100);
        v_local_date     DATE;
        
        v_ou_id          NUMBER;

    BEGIN
        --한 Session에서 동일 OU로 재호출 하였을 경우는 이전에 저장한 Global변수 값을 사용함
        if p_ou_id = g_pre_ou_id then
            v_timezone_code := g_pre_ou_tz_cd;
        else          
            v_ou_id := p_ou_id;
            
            BEGIN
                select rgn.code_data5_value
                INTO   v_timezone_code
                from   lgcom_company_v lcv,
                       lgcom_common_code_c lcc,
                       lgcom_common_code_c rgn
                where  lcv.organization_id = v_ou_id
                and    lcv.business_group_id = lcc.code_data2_value
                and    lcc.code_type_code = 'LGCOM_SUBSIDIARY_TYPE_CODE'
                and    lcc.code_data1_value = rgn.common_code--region_code
                and    rgn.code_type_code = 'LGCOM_TIMEZONE_DEFAULT_COMPANY'
                and    rownum = 1;

            EXCEPTION
                WHEN OTHERS THEN
                    v_timezone_code := 'Asia/Seoul';
            END;
        
            --한 Session에서 재호출 하였을 경우에 Global변수 값에 넣어 재사용하기 위함
            g_pre_ou_id     := p_ou_id;
            g_pre_ou_tz_cd  := v_timezone_code;
            
        end if;

        v_local_date := get_local_date_by_timezonecode(v_timezone_code);
        
        return nvl(v_local_date,sysdate);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN(NULL);
    END;
    
    
end lgcom_mtz_pkg;
/
