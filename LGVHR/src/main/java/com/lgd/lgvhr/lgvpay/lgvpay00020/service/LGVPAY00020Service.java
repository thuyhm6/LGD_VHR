/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00020Service.java
 * @Desc    : User Defined Table Value Summary
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 02. 02.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00020.service.LGVPAY00020Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 02. 02.
 * @Version   
 *
 */
public interface LGVPAY00020Service {
    
    /**
     * Desc : User Defined Table Value Summary 목록을 조회한다. 
     * @Method Name : retrieveUserDefineTableValueSummaryList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineTableValueSummaryList(LGCOMData param);
    
}
