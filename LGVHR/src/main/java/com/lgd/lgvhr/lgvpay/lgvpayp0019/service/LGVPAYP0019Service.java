/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0019Service.java
 * @Desc    : Retroactive Payroll Run Execution
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	  1.0	2018.10.08. lhj  		최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0019.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0019.service.LGVPAYP0019Service.java
 * </PRE>
 * 
 * @author     lhj
 * @Date	   2018. 10. 08.
 * @Version   
 *
 */
public interface LGVPAYP0019Service {
    
    /**
     * Desc : 급여 실행정보를 등록한다. 
     * - 급여담당자 권한이 있는지 체크
     * - calculation_set_id, payrollTypeCode, payrollCalcPeriodValue 필수값 체크
     * 
     * @Method Name : insertValidatePayrollCalculationExec
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateInsertRetroactivePayrollCalculationExec(LGCOMData param);
    
    /**
     * Desc : 급여 실행정보를 등록한다. 
     * @Method Name : insertPayrollCalculationExec
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData insertRetroactivePayrollCalculationExec(LGCOMData param);
    
}
