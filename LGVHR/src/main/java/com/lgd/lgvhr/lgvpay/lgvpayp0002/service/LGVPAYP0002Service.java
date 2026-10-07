/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0002Service.java
 * @Desc    : Payroll Run Execution List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 7.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0002.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0002.service.LGVPAYP0002Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 7. 오후 4:10:01
 * @Version   
 *
 */
public interface LGVPAYP0002Service {
    
    /**
     * Desc : Execution List 를 조회한다.
     * @Method Name : retrieveExecutionList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveExecutionList(LGCOMData param);
    
    /**
     * Desc : payrollCalculationExecId 로 payMonth, payType 조회
     * @Method Name : retrievePayrollCalculationExecIdData
     * @param param
     * @return boolean
     * @throws Exception
     */
    public LGCOMData retrievePayrollCalculationExecIdData(LGCOMData param);
    
}
