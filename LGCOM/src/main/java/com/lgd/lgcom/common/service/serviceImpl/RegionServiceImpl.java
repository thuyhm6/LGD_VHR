/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : RegionServiceImpl.java
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
package com.lgd.lgcom.common.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.RegionService;
import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.RegionServiceImpl.java
 * </PRE>
 *
 * @Author    soncs
 * @Date      2016. 8. 19. 오전 8:55:01
 * @Version
 */
@Service("regionService")
public class RegionServiceImpl implements RegionService {
    static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(RegionServiceImpl.class);

    @Resource(name="userService")
    private UserService userService;

    @Resource(name="userSessionService")
    private UserSessionService userSessionService;

    @Resource(name="commonDao")
    CommonDao commonDao;

    /**
	 * Desc : ssoId로 사용자 정보, Region 목록, Operation Unit 목록을 조회한다.
	 * @Method Name : retrieveRegionInitData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRegionInitData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		/* SSO ID로 LGCOM USER에서 초기 사용자 정보를 조회한다. */
		LGCOMData userData = this.commonDao.select("Region.retrieveInitUserData",param);
		result.set("userData",userData);
		/* SSO ID로 Region 목록을 조회한다. */
		List<LGCOMData> regionList = this.commonDao.selectList("Region.retrieveUserRegionList",param);
		result.set("regionList",regionList);
		/* SSO ID로 OU 목록을 조회한다. */
		List<LGCOMData> orgUnitList = this.commonDao.selectList("Region.retrieveUserOrganizationUnitList",param);
		result.set("orgUnitList",orgUnitList);
		return result;
	}

	/**
	 * Desc : 선택된 Region 과 Operation Unit 정보를 저장한다.
	 * @Method Name : saveSelectedRegionAndOrgUnit
	 * @param  param
	 */
	public void saveSelectedRegionAndOrgUnit(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 주어진 정보를 사용자 정보에 저장한다. */
		this.commonDao.update("Region.updateSelectedRegionData",param);
		this.commonDao.update("Region.updateSelectedOrgUnitData",param);
		/* 저장된 정보를 기준으로 세션을 생성한다. */
		this.createSSOUserSession(param);
	}

	/**
	 * Desc : Region & OU 선택결과로 선정된 application user id로 사용자 세션을 생성한다.
	 * @Method Name : createSSOUserSession
	 * @param  param
	 */
	public void createSSOUserSession(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 선정된 Application User Id로 사용자 정보 조회 */
		LGCOMData userSession = (LGCOMData)userService.retrieveUserInfo(param);
		/* 사용자 Role 목록 조회 */
		userSession.set("roleList", userService.retrieveUserRoleList(userSession));
		/* 사용자 세션 생성 */
		HttpServletRequest request = LGCOMUtils.getRequest();
		userSessionService.setSession(request, userSession);
	}
}
