/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0009Service.java
 * @Desc    : Payroll Run Execution List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 12.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0009.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0009.service.LGVPAYP0009Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 12.
 * @Version   
 *
 */
public interface LGVPAYP0009Service {
    
    /**
     * Desc : Payroll Run Error List 를 조회한다.
     * @Method Name : retrieveRunErrorList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRunErrorList(LGCOMData param);
    
}
