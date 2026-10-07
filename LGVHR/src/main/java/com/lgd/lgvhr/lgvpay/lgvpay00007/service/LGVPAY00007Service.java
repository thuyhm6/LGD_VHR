/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00007Service.java
 * @Desc    : Payroll Activity Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 28.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00007.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00007.service.LGVPAY00007Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 28.
 * @Version   
 *
 */
public interface LGVPAY00007Service {
    
    /**
     * Desc : 급여작업 Activity를 조회한다.
     * @Method Name : retrievePayrollActivityList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollActivityList(LGCOMData param);

    /**
     * Desc : 급여작업 특정 Activity를 조회한다.
     * @Method Name : retrievePayrollActivityData
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public LGCOMData retrievePayrollActivityData(LGCOMData param);
    
    /**
     * Desc : 급여작업 Activity 유무 조회한다.
     * @Method Name : retrievePayProcsPerfmResultExistsFlag
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrievePayProcsPerfmResultExistsFlag(LGCOMData param);

    /**
     * Desc : 급여작업 Activity 저장한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터 없는 경우 insert
     *   - 데이터 있는 경우 update 
     * 
     * @Method Name : savePayrollActivity
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData savePayrollActivity(LGCOMData param);
    
    /**
     * Desc : 대상사 생성 전 체크
     * 
     * - 급여담당자 권한이 있는지 체크
     * - Calculation Set 자동 생성여부가 Y 인지 체크(자동 생성인 경우만 대상자 생성 가능함)
     * 
     * @Method Name : validateCreatePayrollTargetEmployee
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateCreatePayrollTargetEmployee(LGCOMData param);

    /**
     * Desc : 급여대상자를 생성한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터가 없는 경우 insert
     * - 급여대상자 생성 프로시저 호출
     * 
     * @Method Name : createPayrollTargetEmployee
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData createPayrollTargetEmployee(LGCOMData param);

    /**
     * Desc : 급여 전표 데이터를 생성한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터가 없는 경우 insert
     * - 급여 전표 데이터 생성 프로시저 호출
     * 
     * @Method Name : insertPayInvoiceIF
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData insertPayInvoiceIF(LGCOMData param);
}
