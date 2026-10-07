/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0010Service.java
 * @Desc    : Payroll Run Execution
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 18.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0010.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0010.service.LGVPAYP0010Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 18.
 * @Version   
 *
 */
public interface LGVPAYP0010Service {
    
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
    public boolean validateInsertPayrollCalculationExec(LGCOMData param);
    
    /**
     * Desc : 급여 실행정보를 등록한다. 
     * @Method Name : insertPayrollCalculationExec
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData insertPayrollCalculationExec(LGCOMData param);
    
}
