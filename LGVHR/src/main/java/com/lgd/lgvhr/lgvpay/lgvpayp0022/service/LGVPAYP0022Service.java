/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0022Service.java
 * @Desc    : Payroll Item List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 04.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0022.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0022.service.LGVPAYP0022Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 04.
 * @Version   
 *
 */
public interface LGVPAYP0022Service {
    
    /**
     * Desc : Payroll Item List 를 조회한다.
     * @Method Name : retrievePayrollItemList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemList(LGCOMData param);
    
}
