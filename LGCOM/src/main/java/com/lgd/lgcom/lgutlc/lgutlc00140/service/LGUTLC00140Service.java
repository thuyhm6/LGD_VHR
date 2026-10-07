/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00140Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 5.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00140.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00401.service.LGUTLC00140Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 5. 오후 1:39:25
 * @Version
 */
public interface LGUTLC00140Service {
	/**
	 * Desc : Concurrent 수행내역 조회
	 * @Method Name : retrieveConcurrentViewerList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveConcurrentViewerList(LGCOMData param);

	/**
	 * Desc : Concurrent 수행내역 로그 조회
	 * @Method Name : retrieveConcurrentLogContent
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveConcurrentLogContent(LGCOMData param);
}
