/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0013Service.java
 * @Desc    : Payment Master by Employee-Contract Info
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
package com.lgd.lgvhr.lgvpay.lgvpayp0013.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0013.service.LGVPAYP0013Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 21.
 * @Version   
 *
 */
public interface LGVPAYP0013Service {
    
    /**
     * Desc : Contract Info를 조회한다.
     * @Method Name : retrieveContractList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveContractList(LGCOMData param);
    
}
