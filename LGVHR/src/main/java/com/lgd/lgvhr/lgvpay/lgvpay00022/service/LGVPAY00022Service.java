/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00022Service.java
 * @Desc    : Print PaySlip
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 03. 14.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00022.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00022.service.LGVPAY00022Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 03. 14.
 * @Version   
 *
 */
public interface LGVPAY00022Service {
    
    /**
     * Desc : 확정된 Payroll Run 리스트 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunList(LGCOMData param);
    
}
