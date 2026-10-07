/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00110Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE          AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 11. csseo       최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00110.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00110.service.LGUTLC00110Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date      2016. 10. 11. 오후 3:40:08
 * @Version
 */
public interface LGUTLC00110Service {
	/**
	 * Desc : Master 조회
	 * @Method Name : retrieveMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveKeywordLogList(LGCOMData param);
}
