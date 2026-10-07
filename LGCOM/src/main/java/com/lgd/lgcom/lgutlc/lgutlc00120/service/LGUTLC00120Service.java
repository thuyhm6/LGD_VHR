/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00120Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 10. 27.  	forain  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00120.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00120.service.LGUTLC00120Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 27. 오전 9:03:08
 * @Version
 */
public interface LGUTLC00120Service {
	/**
	 * Desc : Menu Tree 목록 조회
	 * @Method Name : retrieveMenuTreeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMenuTreeList(LGCOMData param);

	/**
	 * Desc : Menu에 구성된 Manual 정보 조회
	 * @Method Name : retrieveMenuManualData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveMenuManualData(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : Manual 정보 저장
	 * @Method Name : saveManualData
	 * @param  param
	 * @return LGCOMData
	 */
	public void saveManualData(LGCOMData param);

	/**
	 * Desc : Manual 정보 삭제
	 * @Method Name : deleteManualData
	 * @param  param
	 * @return LGCOMData
	 */
	public void deleteManualData(LGCOMData param);

	/**
	 * Desc : Manual 첨부파일 삭제
	 * @Method Name : deleteManualAttachFile
	 * @param  param
	 * @return LGCOMData
	 */
	public void deleteManualAttachFile(LGCOMData param);

	/**
	 * Desc : Manual 정보 조회
	 * @Method Name : retrieveMenuManualViewData
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMenuManualViewData(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : Manual 편집 모드로 이동
	 * @Method Name : retrieveManualModify
	 * @param  param
	 */
	public void retrieveManualModify(LGCOMData param);
}
