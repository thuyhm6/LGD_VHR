/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00203Service.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	    DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0   2016.08.22.      CYJ      최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.lgutlc.lgutlc00310.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00310.service.LGUTLC00310Service.java
 * </PRE>
 *
 * @Author    CYJ
 * @Date	  2016. 8. 22. 오전 9:50:46
 * @Version   
 */
public interface LGUTLC00310Service {
    
    /**
     * Desc :  나의 결재요청 목록을 조회한다.
     * @Method Name : retrieveRequestList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRequestList(LGCOMData param);

}
