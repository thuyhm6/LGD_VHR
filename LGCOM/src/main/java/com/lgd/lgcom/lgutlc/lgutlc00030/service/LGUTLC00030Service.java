/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00030Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 27.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00030.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00030.service.LGUTLC00030Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 27. 오후 4:35:58
 * @Version
 */
public interface LGUTLC00030Service {
	/**
	 * Desc : 게시판 관리 목록을 조회한다.
	 * @Method Name : retrieveProgramList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBulletinBoardList(LGCOMData param);

	/**
	 * Desc : 게시판 관리 목록을 저장한다.
	 * @Method Name : saveProgramList
	 * @param  param
	 * @throws Exception
	 */
	public void saveBulletinBoardList(LGCOMData param);
}
