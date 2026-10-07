/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00060Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00060.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00060.service.LGSYSC00060Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 23. 오후 5:04:58
 * @Version
 */
public interface LGSYSC00060Service {
	/**
	 * Desc : 사용자 목록을 조회한다.
	 * @Method Name : retrieveUserList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserList(LGCOMData param);

	/**
	 * Desc : 사용자 Role 목록을 조회한다.
	 * @Method Name : retrieveUserRoleList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserRoleList(LGCOMData param);

	/**
	 * Desc : 사용자 Role 목록을 저장한다.
	 * @Method Name : saveUserRoleList
	 * @param  param
	 * @throws Exception
	 */
	public void saveUserRoleList(LGCOMData param);
}
