/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0011Service.java
 * @Desc    : Payment Master by Employee-Band History
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 21.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0011.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0011.service.LGVPAYP0011Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 21.
 * @Version   
 *
 */
public interface LGVPAYP0011Service {
    
    /**
     * Desc : Band 이력을 조회한다.
     * @Method Name : retrieveBandList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveBandList(LGCOMData param);
    
}
