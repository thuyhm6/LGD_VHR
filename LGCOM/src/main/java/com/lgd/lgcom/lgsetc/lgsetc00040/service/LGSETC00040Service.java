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
package com.lgd.lgcom.lgsetc.lgsetc00040.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00060.service.LGSETC00060Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 5. 23. 오전 9:00:58
 * @Version
 */
public interface LGSETC00040Service {
	/**
	 * Desc : 팝업의 Code Type 목록을 조회한다.
	 * @Method Name : retrieveCodeTypePopupList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeTypePopupList(LGCOMData param);
}
