/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0020Service.java
 * @Desc    : Request Payroll Confirm
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	  1.0	2018.11.05. lhj  		최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0020.service.LGVPAYP0020Service.java
 * </PRE>
 * 
 * @author     lhj
 * @Date	   2018. 11. 05.
 * @Version   
 *
 */
public interface LGVPAYP0020Service {
    
    /**
     * Desc : 확정요청할 급여 Summary 정보 조회 전 체크
     * - 급여담당자 권한이 있는지 체크
     * - calculation_set_id, payrollTypeCode, payrollCalcPeriodValue, calculation_execution_id 필수값 체크
     * 
     * @Method Name : validateRetrievePayrollSumamry
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateRetrievePayrollSumamry(LGCOMData param);
    
    /**
     * Desc : 급여지급확정을 요청한다. 
     * @Method Name : insertRequestPayrollConfirm
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public void insertRequestPayrollConfirm(LGCOMData param);
    
    /**
	 * Desc : 급여지급확정요청서 승인/반려
	 * @Method Name : insertApproveOrReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
    public void insertApproveOrReject(LGCOMData param);
    
    /**
     * Desc : 확정요청할 Payroll Summary를 조회한다. 
     * @Method Name : retrievePayrollSummary
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollSummary(LGCOMData param);
    
    /**
     * Desc : 결재할 Payroll Summary를 조회한다. 
     * @Method Name : retrieveRequestContent
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRequestContent(LGCOMData param);
    
}
