/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00210Service.java
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
package com.lgd.lgcom.lgsysc.lgsysc00070.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00210.service.LGSYSC00210Service.java
 * </PRE>
 *
 * @Author csseo
 * @Date 2016. 5. 18. 오전 9:00:58
 * @Version
 */
public interface LGSYSC00070Service {
	/**
	 * Desc : 즐겨찾기 목록을 조회한다.
	 * 
	 * @Method Name : retrieveFavoriteList
	 * @param param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveFavoriteList(LGCOMData param);

	/**
	 * Desc : 즐겨찾기 항목을 삭제한다.
	 * 
	 * @Method Name : deleteFavoriteItem
	 * @param param
	 */
	public void deleteFavoriteItem(LGCOMData param);

	/**
	 * Desc : 즐겨찾기 항목을 추가한다.
	 * 
	 * @Method Name : insertFavoriteItem
	 * @param param
	 */
	public void insertFavoriteItem(LGCOMData param);

	/**
	 * Desc : 즐겨찾기 화면 표시순서를 갱신한다.
	 * 
	 * @Method Name : updateFavoriteSortOrder
	 * @param param
	 */
	public void updateFavoriteSortOrder(LGCOMData param);

	/**
	 * Desc :
	 * 
	 * @Method Name : retrieveTop10ListForMain
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrieveTop10ListForMain(LGCOMData param);
}
