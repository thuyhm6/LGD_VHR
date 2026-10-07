/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0017Service.java
 * @Desc    : Payroll Item Detail List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 12.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0017.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0017.service.LGVPAYP0017Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 12.
 * @Version   
 *
 */
public interface LGVPAYP0017Service {
    
    /**
     * Desc : Payroll Item Detail List 를 조회한다.
     * @Method Name : retrievePayrollItemDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemDetailList(LGCOMData param);
    
}
