/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00030ServiceImpl.java
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
package com.lgd.lgcom.lgutlc.lgutlc00030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00030.service.LGUTLC00030Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00030.service.serviceImpl.LGUTLC00030ServiceImpl.java
 * </PRE>
 *
 * @Author csseo
 * @Date 2016. 5. 27. 오후 4:35:58
 * @Version
 */
@Service("LGUTLC00030Service")
public class LGUTLC00030ServiceImpl implements LGUTLC00030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00030ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 게시판 관리 목록을 조회한다.
	 * 
	 * @Method Name : retrieveProgramList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBulletinBoardList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00030.retrieveBulletinBoardList", param);
	}

	/**
	 * Desc : 게시판 관리 목록을 저장한다.
	 * 
	 * @Method Name : saveProgramList
	 * @param param
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	public void saveBulletinBoardList(LGCOMData param) {
		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");

		LOGGER.debug("param = " + param);
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00030.insertBulletinBoardList", item);
		}

		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00030.updateBulletinBoardList", item);
		}
	}
}
