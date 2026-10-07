/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00140Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 26.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00150.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00150.service.LGSYSC00140Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 26. 오전 8:14:58
 * @Version
 */
public interface LGSYSC00150Service {
	/**
	 * Desc : Program Service 목록을 조회한다.
	 * @Method Name : retrieveProgramServiceList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveProgramServiceList(LGCOMData param);

	/**
	 * Desc : Program Service 의 중복을 체크한다.
	 * @Method Name : retrieveCheckDuplicateProgramServiceId
	 * @param  param
	 * @return boolean
	 */
	public boolean retrieveCheckDuplicateProgramServiceId(LGCOMData param);

	/**
	 * Desc : Program Service 목록을 저장한다.
	 * @Method Name : saveProgramServiceList
	 * @param  param
	 */
	public void saveProgramServiceList(LGCOMData param);

	/**
	 * Desc : Program Service Role 목록을 조회한다.
	 * @Method Name : retrieveProgramServiceRoleList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveProgramServiceRoleList(LGCOMData param);

	/**
	 * Desc : Program Service Role 목록을 저장한다.
	 * @Method Name : saveProgramServiceRoleList
	 * @param  param
	 */
	public void saveProgramServiceRoleList(LGCOMData param);
}
