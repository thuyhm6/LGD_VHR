/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00300Service.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	    DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	  1.0	2016.08.22.  	 CYJ  	  최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.lgutlc.lgutlc00300.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00300.service.LGUTLC00300Service.java
 * </PRE>
 *
 * @Author    CYJ
 * @Date	  2016. 8. 22. 오전 9:50:46
 * @Version   
 */
public interface LGUTLC00300Service {
    
    /**
     * Desc : 나의 결재 승인 목록을 조회한다.
     * @Method Name : retrieveApprovalList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveApprovalList(LGCOMData param);

}
