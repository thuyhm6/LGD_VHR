/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVCOM00020Service.java
 * @Desc    : 
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	    DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	  1.0	2017. 11. 13.  	 LHJ  	  최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvcom.lgvcom00020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00020.service.LGVCOM00020Service.java
 * </PRE>
 *
 * @Author    LHJ
 * @Date	  2017. 11. 13. 오전 9:32:46
 * @Version   
 */
public interface LGVCOM00020Service {
    
    /**
     * Desc : 나의 결재 승인 목록을 조회한다.
     * @Method Name : retrieveApprovalList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveApprovalList(LGCOMData param);

}
