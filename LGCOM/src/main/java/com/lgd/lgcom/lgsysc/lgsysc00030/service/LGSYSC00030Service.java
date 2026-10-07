/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYS00030Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 18.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00030.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00030.service.LGSYSC00030Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
public interface LGSYSC00030Service {
	/**
	 * Desc : 사용자 목록을 조회한다.
	 * @Method Name : retrieveUserList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<?> retrieveUserList(LGCOMData param);

	/**
	 * Desc : 사용자 목록을 저장한다.
	 * @Method Name : saveUserList
	 * @param  param
	 * @throws Exception
	 */
	public void saveUserList(LGCOMData param);
	
	public void executeUserImport(LGCOMData param);
}
