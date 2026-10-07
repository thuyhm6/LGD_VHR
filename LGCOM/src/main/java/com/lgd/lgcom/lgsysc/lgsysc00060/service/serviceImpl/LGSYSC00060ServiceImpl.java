/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00060ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 18.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00060.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00060.service.LGSYSC00060Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00060.service.serviceImpl.LGSYSC00060ServiceImpl.java
 * </PRE>
 *
 * @Author csseo
 * @Date 2016. 5. 23. 오후 5:04:58
 * @Version
 */
@Service("LGSYSC00060Service")
public class LGSYSC00060ServiceImpl implements LGSYSC00060Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00060ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 사용자 목록을 조회한다.
	 * 
	 * @Method Name : retrieveUsetList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00030.retrieveUserList", param);
	}

	/**
	 * Desc : 사용자 Role 목록을 조회한다.
	 * 
	 * @Method Name : retrieveUserRoleList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserRoleList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00060.retrieveUserRoleList", param);
	}

	/**
	 * Desc : 사용자 Role 목록을 저장한다.
	 * 
	 * @Method Name : saveUserRoleList
	 * @param param
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	public void saveUserRoleList(LGCOMData param) {
		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");
		LOGGER.debug("param = " + param);
		/* 등록건 */
		List<LGCOMData> cList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00060.mergeUserRoleInfo", item);
		}

		/* 수정건 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
			item.set("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00060.mergeUserRoleInfo", item);
		}
	}
}
