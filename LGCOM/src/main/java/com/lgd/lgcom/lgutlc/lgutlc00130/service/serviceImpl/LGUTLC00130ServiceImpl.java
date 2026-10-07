/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00130ServiceImpl.java
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
package com.lgd.lgcom.lgutlc.lgutlc00130.service.serviceImpl;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00130.service.LGUTLC00130Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00130.service.serviceImpl.LGUTLC00130ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date      2016. 11. 15. 오후 12:54:58
 * @Version
 */
@Service("LGUTLC00130Service")
public class LGUTLC00130ServiceImpl implements LGUTLC00130Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00130ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Mail Template Master 목록 조회
	 * @Method Name : retrieveMailTemplateMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateMasterList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00130.retrieveMailTemplateMasterList", param);
	}

	/**
	 * Desc : Mail Template Master 목록 저장
	 * @Method Name : saveMailTemplateMasterList
	 * @param  param
	 */
	public void saveMailTemplateMasterList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 사용자 세션 정보 */
		LGCOMData userSession =(LGCOMData)param.get("USER_SESSION");
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00130.insertMailTemplateMasterData",item);
		}
		
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00130.updateMailTemplateMasterData",item);
		}
	}

	/**
	 * Desc : Mail Template Contents 상세 조회
	 * @Method Name : retrieveMailTemplateContentsData
	 * @param  param
	 * @return LGCOMData
	 * @throws IOException
	 * @throws SQLException
	 */
	public LGCOMData retrieveMailTemplateContentsData(LGCOMData param) throws SQLException, IOException {
		LOGGER.debug("param = " + param);
		/* Template Content 조회 */
		LGCOMData item = this.commonDao.select("LGUTLC00130.retrieveMailTemplateContentsData", param);
		if(item != null) {
			/* CLOB 변환 */
			Object obj = item.get("mailDetailContent");
			if(obj != null) {
				if(obj instanceof java.sql.Clob) {
					String content = LGCOMUtils.clobToString((java.sql.Clob)obj);
					// Executable Img 처리
					content = LGCOMUtils.removeExecutableImgTag(content);
					// XSS 처리
					content = LGCOMUtils.xssFilter(content);
					item.set("mailDetailContent",content);
				}
			}
		}
		return item;
	}

	/**
	 * Desc : Mail Template Contents 저장
	 * @Method Name : saveMailTemplateContentsData
	 * @param  param
	 */
	public void saveMailTemplateContentsData(LGCOMData param) {
		/* Editor의 내용을 Base64로 인코딩해서 오므로 다시 디코딩한다. */
		param.set("mailDetailContent",LGCOMUtils.decodeString(param.getString("mailDetailContent")));
		LOGGER.debug("param = " + param);
		this.commonDao.update("LGUTLC00130.saveMailTemplateContentsData", param);
	}

	/**
	 * Desc : Mail Template Contents 삭제
	 * @Method Name : deleteMailTemplateContentsData
	 * @param  param
	 */
	public void deleteMailTemplateContentsData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.delete("LGUTLC00130.deleteMailTemplateContentsData", param);
	}

	/**
	 * Desc : Mail Template Contents 첨부파일 삭제
	 * @Method Name : deleteMailTemplateContentsAttachFile
	 * @param  param
	 */
	public void deleteMailTemplateContentsAttachFile(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.delete("LGSYSC00210.deleteAttachFileInfo",param);
		this.commonDao.delete("LGUTLC00130.deleteMailTemplateContentsAttachFile", param);
	}

	/**
	 * Desc : Mail Template Text 수신자 목록 조회
	 * @Method Name : retrieveMailTemplateTextRecipientList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateTextRecipientList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00130.retrieveMailTemplateTextRecipientList", param);
	}

	/**
	 * Desc : Mail Template Text 수신자 목록 저장
	 * @Method Name : saveMailTemplateTextRecipientList
	 * @param  param
	 */
	public void saveMailTemplateTextRecipientList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 사용자 세션 정보 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 삭제건 처리 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.delete("LGUTLC00130.deleteMailTemplateTextRecipientData",item);
		}
		
		/* 등록건 처리 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00130.insertMailTemplateTextRecipientData",item);
		}
		
		/* 수정건 처리 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00130.updateMailTemplateTextRecipientData",item);
		}
	}

	/**
	 * Desc : Mail Template SQL 수신자 목록 조회
	 * @Method Name : retrieveMailTemplateSqlRecipientList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMailTemplateSqlRecipientList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		List<LGCOMData> list = this.commonDao.selectList("LGUTLC00130.retrieveMailTemplateSqlRecipientList", param);
		for( LGCOMData item: LGCOMUtils.emptyIfNull(list) ) {
			this.generateRecipientQuery(item);
		}
		return list;
	}

	/**
	 * Desc : Mail Template SQL 수신자 목록 저장
	 * @Method Name : saveMailTemplateSqlRecipientData
	 * @param  param
	 */
	public void saveMailTemplateSqlRecipientData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.update("LGUTLC00130.saveMailTemplateSqlRecipientData", param);
	}

	/**
	 * Desc : Mail Template SQL 수신자 목록 삭제
	 * @Method Name : deleteMailTemplateSqlRecipientData
	 * @param  param
	 */
	public void deleteMailTemplateSqlRecipientData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.delete("LGUTLC00130.deleteMailTemplateSqlRecipientData", param);
	}

	/**
	 * Desc : Recipient 조회 Query를 생성한다.
	 * @Method Name : generateRecipientQuery
	 * @param data
	 */
	private void generateRecipientQuery(LGCOMData data) {
		LOGGER.debug("data = " + data);
		StringBuffer buffer = new StringBuffer();
		// SELECT 절
		buffer.append("SELECT ").append(NullUtil.nvl(data.getString("sqlText"),"")).append("\n");
		// FROM 절
		String fromSqlText = NullUtil.nvl(data.getString("fromSqlText"),"").trim();
		if(fromSqlText.toLowerCase().startsWith("from")) {
			buffer.append("  ").append(fromSqlText).append("\n");
		} else {
			buffer.append("  FROM ").append(fromSqlText).append("\n");
		}
		// WHERE 절
		String whereSqlText = NullUtil.nvl(data.getString("whereSqlText"),"").trim();
		if(!NullUtil.isNone(whereSqlText)) {
			if(whereSqlText.toLowerCase().startsWith("where")) {
				buffer.append(" ").append(whereSqlText).append("\n");
			} else {
				buffer.append(" WHERE ").append(whereSqlText).append("\n");
			}
		}
		// ORDER BY/GROUP BY 절
		String ruleSqlText = NullUtil.nvl(data.getString("ruleSqlText"),"").trim();
		if(!NullUtil.isNone(ruleSqlText)) {
			buffer.append(" ").append(ruleSqlText).append("\n");
		}
		LOGGER.debug("buffer = " + buffer.toString());
		data.set("genQuery",buffer.toString());
	}
}
