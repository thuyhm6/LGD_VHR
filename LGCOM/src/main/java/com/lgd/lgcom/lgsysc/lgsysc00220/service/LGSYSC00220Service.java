/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00220Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.  jhlee    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00220.service;

import java.sql.SQLException;
import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00220.service.LGSYSC00220Service.java
 * </PRE>
 *
 * @Author    jhlee
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
public interface LGSYSC00220Service {
	/**
	 * Desc : 사용자의 Role에 기반한 사용가능한 모든 메뉴 목록을 조회한다.
	 * @Method Name : retrieveUsetListByRole
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMenuListByRole(LGCOMData param);

	/**
	 * Desc : 사용자 메뉴 목록을 인출한다.
	 * @Method Name : retrieveUserMenuList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveUserMenuList(LGCOMData param);

	/**
	 * Desc : 사용자 메뉴 목록 저장한다.
	 * @Method Name : insertUserMenuList
	 * @param  param
	 * @return void
	 */
	public void insertUserMenuList(LGCOMData param);

	/**
	 * Desc : 사용자 메뉴의 Top 메뉴의 순서를 재정렬한다.
	 * @Method Name : updateUserTopMenuOrder
	 * @param  param
	 * @return void
	 */
	public void updateUserTopMenuOrder(LGCOMData param);

	/**
	 * Desc : 사용자 메뉴 목록 삭제한다.
	 * @Method Name : insertUserMenuList
	 * @param  param
	 * @return void
	 */
	public void deleteUserMenuList(LGCOMData param);

	/**
	 * Desc : Export Excel Sample
	 * @Method Name : exportExcel
	 * @param param
	 * @return
	 * @throws SQLException
	 */
	public LGCOMData exportExcel(LGCOMData param) throws SQLException;

	/**
	 * Desc : My Menu에서 사용하는 Role 기반 시스템 및 메뉴 목록 조회
	 * @Method Name : retrieveMyMenuListByRole
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMyMenuListByRole(LGCOMData param);

	/**
	 * Desc : My Menu 사용자 메뉴 목록을 인출한다.
	 * @Method Name : retrieveMyMenuUserMenuList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMyMenuUserMenuList(LGCOMData param);
}
