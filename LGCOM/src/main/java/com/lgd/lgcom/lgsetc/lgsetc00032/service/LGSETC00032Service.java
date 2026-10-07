/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00060Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00032.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00060.service.LGSETC00060Service.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 5. 23. 오전 9:00:58
 * @Version
 */
public interface LGSETC00032Service {
	/**
	 * Desc : inventory organization id 목록을 조회한다.
	 * @Method Name : retrieveInvOrgIdList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveInvOrgIdList(LGCOMData param);	
	
	/**
     * Desc : Company Name을 조회한다.
     * @Method Name : retrieveCompanyName
     * @param  param
     * @return String
     * @throws Exception
     */
    public LGCOMData retrieveCompanyName(LGCOMData param);
}
