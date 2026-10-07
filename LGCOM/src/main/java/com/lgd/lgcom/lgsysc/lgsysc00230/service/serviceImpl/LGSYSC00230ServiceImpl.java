/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00230ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 8. 26.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00230.service.serviceImpl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00230.service.LGSYSC00230Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00230.service.serviceImpl.LGSYSC00230ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 26. 오후 1:46:58
 * @Version
 */
@Service(value="LGSYSC00230Service")
public class LGSYSC00230ServiceImpl implements LGSYSC00230Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00230ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Super User 목록 조회
	 * @Method Name : retrieveResponsibilitySuperUserList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveReponsibilitySuperUserList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00230.retrieveReponsibilitySuperUserList",param);
	}

	/**
	 *
	 * Desc : Responsibility Super User 목록 저장
	 * @Method Name : saveResponsibilitySuperUserList
	 * @param  param
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
    public void saveResponsibilitySuperUserList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 등록건 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00230.updateResponsibilitySuperUserList",item);
		}
		
		
		/* 수정건 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00230.updateResponsibilitySuperUserList",item);
		}

		
		if(cList != null && cList.size() > 0) {
			for(int a=0; a < cList.size(); a++) {
				LGCOMData item = (LGCOMData)cList.get(a);
				/* 세션 사용자 정보 세팅 */
				item.put("sessionUserId",userSession.getString("applicationUserId"));
				this.commonDao.update("LGSYSC00230.updateResponsibilitySuperUserList",item);
			}
		}
		if(uList != null && uList.size() > 0) {
			for(int b=0; b < uList.size(); b++) {
				LGCOMData item = (LGCOMData)uList.get(b);
				/* 세션 사용자 정보 세팅 */
				item.put("sessionUserId",userSession.getString("applicationUserId"));
				this.commonDao.update("LGSYSC00230.updateResponsibilitySuperUserList",item);
			}
		}
	}

	/**
	 * Desc : Responsibility 별 Super User 조회
	 * @Method Name : retrieveResponsibilitySuperUserAddress
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveResponsibilitySuperUserAddress(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGSYSC00230.retrieveRespSuperUserMailAddr",param);
	}
	
	/**
	 * Desc : Responsibility 별 Super User 목록 조회
	 * @Method Name : retrieveResponsibilitySuperUserDetailList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveResponsibilitySuperUserDetailList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00230.retrieveResponsibilitySuperUserDetailList",param);
	}

	/**
	 *
	 * Desc : Responsibility Super User 대상자들에게 메일 발송
	 * @Method Name : saveResponsibilitySuperUserSendMailList
	 * @param  param
	 */
	public void saveResponsibilitySuperUserSendMailList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 사용자 세션 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 권한소유자 목록 조회 */
		List<LGCOMData> respAuthList = this.commonDao.selectList("LGSYSC00230.retrieveResponsibilitySuperUserDetailList",param);
		/* 메일 내용 생성 */
		StringBuffer buffer = new StringBuffer();
		buffer.append("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">").append("\n");
		buffer.append("\t").append("<tr>").append("\n");
		buffer.append("\t\t").append("<td>").append("\n");
		buffer.append("\t\t\t").append("<table border=\"2\" cellpadding=\"3\" cellspacing=\"0\" style=\"border-collapse:collapse;\">").append("\n");
		buffer.append("\t\t\t\t").append("<tr style=\"height:24px;\">").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">Role Name</td>").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">Start Date</td>").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">End Date</td>").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">User Name</td>").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">Description</td>").append("\n");
		buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;font-weight:bold;color:#336699;vertical-align:middle;\">E-mail Address</td>").append("\n");
		buffer.append("\t\t\t\t").append("<tr>").append("\n");
		// 대상자 작성
		for(int i=0; i < respAuthList.size(); i++) {
			LGCOMData item = (LGCOMData)respAuthList.get(i);
			buffer.append("\t\t\t\t").append("<tr style=\"height:24px;\">").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("repName"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("userStart"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("userEnd"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("userName"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("description"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t\t").append("<td style=\"font-size:9pt;vertical-align:middle;\">").append(NullUtil.nvl(item.getString("emailAddress"),"")).append("</td>").append("\n");
			buffer.append("\t\t\t\t").append("<tr>").append("\n");
		}
		buffer.append("\t\t\t").append("</table>").append("\n");
		buffer.append("\t\t").append("</td>").append("\n");
		buffer.append("\t").append("</tr>").append("\n");
		buffer.append("</table>");

		/*Super User 메일 주소 조회*/
		LGCOMData suMailAddr = retrieveResponsibilitySuperUserAddress(param);		
		
		/* 메일을 전송한다. */
		LGCOMData mailData = new LGCOMData();
		
		
		mailData.set("systemCode","LGCOM");
		mailData.set("moduleCode","LGSYSC");
		mailData.set("senderEmailAddr","\"Web Common Framework\"<wcfw@lgdisplay.com>");
		
		if ((Boolean)param.get("testMode")){
			mailData.set("receiptEmailAddr", "\"Test\"<"+(String)param.get("testMailAddr")+">");
		}else{
			mailData.set("receiptEmailAddr","\""+suMailAddr.getString("name")+"\" <"+suMailAddr.getString("emailAddress")+">");
		}		
		mailData.set("ccEmailAddr","");
		mailData.set("typeCode","T");
		mailData.set("subjectContent","User list ("+suMailAddr.getString("responsibilityName") +")");
		mailData.set("mailClobData","");
		mailData.set("mailClobContent", buffer.toString());
		mailData.set("fileName","");
		mailData.set("statusCode","N");
		mailData.set("errorReasonDesc","");
		mailData.set("mailId","");
		mailData.set("languageCode","");
        mailData.set("USER_SESSION", userSession);
	
		LOGGER.debug("before mailData = " + mailData);

		// 메일 전송
		this.commonDao.insert("LGSYSC00230.insertRespSuperUserMail", mailData);
		

		// 메일전송여부 수정
		this.commonDao.update("LGSYSC00230.updateMailSendFlag",param);
	}
}
