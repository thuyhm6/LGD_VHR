/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00050Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 9.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00050.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00050.service.LGUTLC00050Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 6. 9. 오후 1:39:58
 * @Version
 */
public interface LGUTLC00050Service {
	/**
	 * Desc : 게시판 아이디를 받아서 게시판 목록을 조회한다.
	 * @Method Name : retrieveBoardList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBoardList(LGCOMData param);

	/**
	 * Desc : 게시판 정보를 저장한다.
	 * @Method Name : saveBoardData
	 * @param  param
	 * @throws IOException
	 * @throws SQLException
	 */
	public void saveBoardData(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : 게시판 정보를 삭제한다.
	 * @Method Name : deleteBoardData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData deleteBoardData(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : 게시판 쓰기 페이지로 이동하기 위한 Dummy Service
	 * @Method Name : retrieveBoardWriteForm
	 * @param  param
	 */
	public void retrieveBoardWriteForm(LGCOMData param);

	/**
	 * Desc : 게시판 Super User에 의해 작성자가 아님에도 무조건 삭제한다.
	 * @Method Name : deletePhysicalBoardData
	 * @param  param
	 * @throws IOException
	 * @throws SQLException
	 */
	public LGCOMData deletePhysicalBoardData(LGCOMData param) throws SQLException, IOException;
}
