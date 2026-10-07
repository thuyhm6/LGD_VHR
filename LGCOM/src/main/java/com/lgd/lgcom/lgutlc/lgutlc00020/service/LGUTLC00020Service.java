/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00020Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 8.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00020.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00020.service.LGUTLC00020Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 8. 오후 4:35:58
 * @Version
 */
public interface LGUTLC00020Service {
	/**
	 * Desc : 디버깅 목록을 조회한다.
	 * @Method Name : retrieveDebuggingList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveDebuggingList(LGCOMData param);
	
    /**
     * Desc : 디버깅 정보를 저장한다.
     * @Method Name : saveDebuggingList
     * @param  param
     * @throws Exception
     */
    public void saveDebuggingList(LGCOMData param);
    
    /**
     * Desc : 디버깅 중복체크를 한다.
     * @Method Name : retrieveDebuggingList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveDebugScopeNameChk(LGCOMData param);

}
