/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00130Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 11. 15.  	forain  최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00130.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00130.service.LGUTLC00130Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date      2016. 11. 15. 오후 12:54:58
 * @Version
 */
public interface LGUTLC00130Service {
	/**
	 * Desc : Mail Template Master 목록 조회
	 * @Method Name : retrieveMailTemplateMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateMasterList(LGCOMData param);

	/**
	 * Desc : Mail Template Master 목록 저장
	 * @Method Name : saveMailTemplateMasterList
	 * @param  param
	 */
	public void saveMailTemplateMasterList(LGCOMData param);

	/**
	 * Desc : Mail Template Contents 상세 조회
	 * @Method Name : retrieveMailTemplateContentsData
	 * @param  param
	 * @return LGCOMData
	 * @throws IOException
	 * @throws SQLException
	 */
	public LGCOMData retrieveMailTemplateContentsData(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : Mail Template Contents 저장
	 * @Method Name : saveMailTemplateContentsData
	 * @param  param
	 */
	public void saveMailTemplateContentsData(LGCOMData param);

	/**
	 * Desc : Mail Template Contents 삭제
	 * @Method Name : deleteMailTemplateContentsData
	 * @param  param
	 */
	public void deleteMailTemplateContentsData(LGCOMData param);

	/**
	 * Desc : Mail Template Contents 첨부파일 삭제
	 * @Method Name : deleteMailTemplateContentsAttachFile
	 * @param  param
	 */
	public void deleteMailTemplateContentsAttachFile(LGCOMData param);

	/**
	 * Desc : Mail Template Text 수신자 목록 조회
	 * @Method Name : retrieveMailTemplateTextRecipientList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateTextRecipientList(LGCOMData param);

	/**
	 * Desc : Mail Template Text 수신자 목록 저장
	 * @Method Name : saveMailTemplateTextRecipientList
	 * @param  param
	 */
	public void saveMailTemplateTextRecipientList(LGCOMData param);

	/**
	 * Desc : Mail Template SQL 수신자 목록 조회
	 * @Method Name : retrieveMailTemplateSqlRecipientList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateSqlRecipientList(LGCOMData param);

	/**
	 * Desc : Mail Template SQL 수신자 목록 저장
	 * @Method Name : saveMailTemplateSqlRecipientData
	 * @param  param
	 */
	public void saveMailTemplateSqlRecipientData(LGCOMData param);

	/**
	 * Desc : Mail Template SQL 수신자 목록 삭제
	 * @Method Name : deleteMailTemplateSqlRecipientData
	 * @param  param
	 */
	public void deleteMailTemplateSqlRecipientData(LGCOMData param);
}
