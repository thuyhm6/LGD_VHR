/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00040ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00050.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00050.service.LGSYSC00050Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00050.service.serviceImpl.LGSYSC00050ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 10:30:01
 * @Version
 */
@Service("LGSYSC00050Service")
public class LGSYSC00050ServiceImpl implements LGSYSC00050Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00050ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Autowired
	UserSessionService userSessionService;

	@Autowired
	UserService userService;

	/**
	 * Desc : My Infomation 정보를 조회한다.
	 * @Method Name : retrieveMyPageData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveMyInfomationData(LGCOMData param) {
		param.set("USER_SESSION", param.get("USER_SESSION"));
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGSYSC00050.retrieveMyInfomationData",param);
	}

	/**
	 * Desc : My Infomation 정보를 저장한다.
	 * @Method Name : updateMyInfomationData
	 * @param  param
	 * @throws Exception
	 */
    public void updateMyInfomationData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.update("LGSYSC00050.updateMyInfomationData",param);
		/* Default Region Use Flag 가 변경되었을 경우 메일주소로 해당 사용자의 Default Region Use Flag를 동시에 변경한다. */
		this.commonDao.update("LGSYSC00050.updateMyInfomationRegionUseData",param);
		/* 세션정보 변경 */
		HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
		// 수정된 정보를 재조회한다.
		
		LGCOMData userParam = new LGCOMData();
		userParam.set("applicationUserId",param.getInt("applicationUserId"));
		LOGGER.debug("userParam = " + userParam);
		LGCOMData userSession = this.userService.retrieveUserInfo(userParam);
		this.userSessionService.setSession(request,userSession);
	}

	/**
	 * Desc : My Authority 목록을 조회한다.
	 * @Method Name : retrieveMyAuthorityList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMyAuthorityList(LGCOMData param) {
		param.set("USER_SESSION", param.get("USER_SESSION"));
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00050.retrieveMyAuthorityList",param);
	}
}
