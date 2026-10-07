/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00030ServiceImpl.java
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
package com.lgd.lgcom.lgsysc.lgsysc00030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00030.service.LGSYSC00030Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00030.service.serviceImpl.LGSYSC00030ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
@Service("LGSYSC00030Service")
public class LGSYSC00030ServiceImpl implements LGSYSC00030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Autowired
	private BatchService batchService;

	/**
	 * Desc : 사용자 목록을 조회한다.
	 * @Method Name : retrieveUsetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00030.retrieveUserList",param);
	}

	/**
	 * Desc : 사용자 목록을 저장한다.
	 * @Method Name : saveUserList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void saveUserList(LGCOMData param) {
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		LOGGER.debug("param = " + param);
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( uList ) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00030.updateUserInfo",item);
			/* Default Region Use Flag 변경시 메일주소로 동일 사용자의 Default Region Use Flag 를 모두 변경한다. */
			if(!((String)item.get("regionUseFlag")).equals((String)item.get("originRegionUseFlag"))) {
			    this.commonDao.update("LGSYSC00030.updateUserDefaultRegionUseFlag",item);
			}
		}
	}
	
	
	public void executeUserImport(LGCOMData param) {
		LOGGER.debug("sendExecuteRequest LGCOMData param : "  + param );
		LGCOMData result = batchService.executeBatch( param );
		LOGGER.debug("sendExecuteRequest : "  + result );
	}
}
