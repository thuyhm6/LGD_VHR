/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00210ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 18.    jhlee    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00210.service.serviceImpl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00210.service.LGSYSC00210Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00210.controller.LGSYS00210Controller.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGSYSC00210Service")
public class LGSYSC00210ServiceImpl implements LGSYSC00210Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00210ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Value("downloadURL_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String downloadURL = null;

	/**
	 * Desc : 사용자의 메뉴 목록을 조회한다.
	 * @Method Name : retrieveUsetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
    public List<LGCOMData> retrieveMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		String menuUseFlag = (String)( (Map<String, Object>)param.get("USER_SESSION") ).get("menuUseFlag");
		List<LGCOMData> list;
		/* N : 시스템기본메뉴만 이용, Y : 사용자 메뉴가 있는지 먼저 확인하여 그 개수에 의존하여 판단 */
		if ("N".equals(menuUseFlag)) {
			list = this.commonDao.selectList("LGSYSC00210.retrieveMenuListByRole", param);  //자신의시스템에 주어진 메뉴
		} else {
			list = this.commonDao.selectList("LGSYSC00210.retrieveMenuList", param); // 나의 메뉴
			if (list == null || list.size() == 0) {
				list = this.commonDao.selectList("LGSYSC00210.retrieveMenuListByRole", param);
			}
		}
		return list;
	}

	public List<LGCOMData> retrieveMenuInfo(LGCOMData param) {
		return this.commonDao.selectList("LGSYSC00210.retrieveMenuInfo",param);
	}

	public  List<LGCOMData>  retrieveWidgetNumbers(LGCOMData param) {
		return this.commonDao.selectList("LGSYSC00210.retrieveWidgetNumbers",param);
	}

	public List<LGCOMData>  retrieveWidgetSystemList(LGCOMData param) {
		return this.commonDao.selectList("LGSYSC00210.retrieveWidgetSystemList",param);
	}

	public List<LGCOMData>  retrieveSystemContactUserList(LGCOMData param) {
		return this.commonDao.selectList("LGSYSC00210.retrieveSystemContactUserList",param);
	}

	@SuppressWarnings("unchecked")
	public void updateUserThemeCode(LGCOMData param) {
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
		HttpSession session = request.getSession(false);
		LGCOMData userSession = (LGCOMData)session.getAttribute(LGCOMConstants.HTTP_SESSION_KEY);
		userSession.set("screenDesignThemeId", param.get("themeCode") );

		this.commonDao.update("LGSYSC00210.updateUserThemeCode",param);
	}

	/**
	 * Desc : 사용자의 메뉴 목록을 조회한다.
	 * @Method Name : retrieveUsetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public void insertUserPopupHistory(LGCOMData param) {
		List<LGCOMData> check = this.commonDao.selectList("LGSYSC00210.selectUserPopupHistory",param);
		
		if( check != null ) {
			this.commonDao.update("LGSYSC00210.deleteUserPopupHistory",param);
		}
		
		this.commonDao.update("LGSYSC00210.insertUserPopupHistory",param);
	}

	public void deleteUserPopupHistory(LGCOMData param) {
		this.commonDao.update("LGSYSC00210.deleteUserPopupHistory",param);
	}

	@Override
	public List<LGCOMData> selectAttachmentListByFileGroupId(LGCOMData param) {
		param.set("downloadURL",LGCOMUtils.getValueFromProjectProperties(downloadURL));
		LOGGER.debug("param = " + param);
		
		return this.commonDao.selectList("LGSYSC00210.selectAttachmentListByFileGroupId",param);
	}

	/**
	 *
	 * @param inParam
	 * @return
	 * @see com.lgd.lgcom.common.service.CommonService#insertAttachFileInfo(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public void deleteAttachFileInfo( LGCOMData param ) {
		if( "HRM".equals( param.get("moduleCode") ) ) {
			commonDao.delete("LGSYSC00210.deleteAttachFileInfoHRM", param);
		} else {
			commonDao.delete("LGSYSC00210.deleteAttachFileInfo", param);
		}
	}

	/**
	 *
	 * @param inParam
	 * @return
	 * @see com.lgd.lgcom.common.service.CommonService#updateAttachFileInfo(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void updateAttachFileInfo( LGCOMData inParam ) {
		List<LGCOMData> list = (List<LGCOMData>)inParam.get("data");
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			item.set( LGCOMConstants.HTTP_SESSION_KEY, inParam.get( LGCOMConstants.HTTP_SESSION_KEY ) );
			commonDao.delete("LGSYSC00210.updateAttachFileInfo", item);
		}
	}

	/**
	 *
	 * @param inParam
	 * @return
	 * @see com.lgd.lgcom.common.service.CommonService#insertAttachFileInfo(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public void deleteAttachFilesByFileGroupId( LGCOMData inParam ) {
		commonDao.delete("LGSYSC00210.deleteAttachFilesByFileGroupId", inParam);
	}

	public List<LGCOMData> retrieveExcelUploadErrorCount (LGCOMData param) {
		if(LGCOMConstants.EXCEL_UPLOAD_USE_LGCOMTEMP.equals(param.getString("uploadType"))) {
			return commonDao.selectList("LGSYSC00210.selectExcelUploadErrorCountForLgcom", param);
		} else {
			return commonDao.selectList("LGSYSC00210.selectExcelUploadErrorCount", param);
		}
	}

	public List<LGCOMData> retrieveExcelUploadErrorList(LGCOMData param) {
		String[] valueList = new String[(int) Math.round(param.getDouble("columnCount"))];
		for (int inx = 0; inx < valueList.length; inx++) {
			valueList[inx] = "A";
		}
		param.set("valueList", valueList);
		LOGGER.debug(param);
		if (LGCOMConstants.EXCEL_UPLOAD_USE_LGCOMTEMP.equals(param.getString("uploadType"))) {
			return commonDao.selectList("LGSYSC00210.selectExcelUploadErrorListForLgcom", param);
		} else {
			return commonDao.selectList("LGSYSC00210.selectExcelUploadErrorList", param);
		}
	}

	@Override
	public LGCOMData createExcelExportData(LGCOMData param) {
		int sessionId = LGCOMUtils.getRandomNumber();
		param.set("exportSsessionId", sessionId);

		String [] valueList = new String[ (int)Math.round( param.getDouble("columnCount") ) ];
		for( int inx = 0 ; inx < valueList.length ; inx++ ) {
			valueList[inx] = "A";
		}
		param.set("valueList", valueList);

		int resultCnt = 0;

		if(LGCOMConstants.EXCEL_UPLOAD_USE_LGCOMTEMP.equals(param.getString("uploadType"))) {
			this.commonDao.insert("LGSYSC00210.createExcelDownloadDataForLgcom",param);
		} else {
			this.commonDao.insert("LGSYSC00210.createExcelDownloadData",param);
		}

		LGCOMData result = new LGCOMData();
		result.set("resultCnt", resultCnt);
		result.set("sessionId", sessionId);
		result.set("uploadType", sessionId);
		return result;
	}

	/**
	 * Desc :  Intro 차트를 위한 데이타 조회
	 * @Method Name : retrieveChartWidgetNumbers
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveChartWidgetNumbers(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00210.retrieveChartWidgetNumbers", param);
	}
}
