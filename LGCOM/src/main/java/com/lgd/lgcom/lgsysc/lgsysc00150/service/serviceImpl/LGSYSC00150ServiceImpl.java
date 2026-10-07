/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00150ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 26.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00150.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.CommonService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00150.service.LGSYSC00150Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00150.service.serviceImpl.LGSYSC00150ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 26. 오전 8:14:58
 * @Version
 */
@Service("LGSYSC00150Service")
public class LGSYSC00150ServiceImpl implements LGSYSC00150Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00150ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    @Autowired
    EhCacheCacheManager cacheManager;

    @Autowired
    CommonService commonService;

	/**
	 * Desc : Program Service 목록을 조회한다.
	 * @Method Name : retrieveProgramServiceList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveProgramServiceList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00150.retrieveProgramServiceList",param);
	}

	/**
	 * Desc : Program Service 의 중복을 체크한다.
	 * @Method Name : retrieveCheckDuplicateProgramServiceId
	 * @param  param
	 * @return boolean
	 */
	public boolean retrieveCheckDuplicateProgramServiceId(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData map = this.commonDao.select("LGSYSC00150.retrieveCheckDuplicateProgramServiceId",param);
		if(map.getInt("cnt") > 0) {
			return true;
		}
		return false;
	}

	/**
	 * Desc : Program Service 목록을 저장한다.
	 * @Method Name : saveProgramServiceList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void saveProgramServiceList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 삭제건 저장 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( dList ) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00150.deleteProgramServiceList",item);
		}
		
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( cList ) ) {
			/* Check duplicate */
			LGCOMData map = this.commonDao.select("LGSYSC00150.retrieveCheckDuplicateProgramServiceId",item);
			if(map.getInt("cnt") > 0) {
				throw new LGCOMException("error.duplicateValue");
			}
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00150.insertProgramServiceList",item);
		}
		
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( uList ) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00150.updateProgramServiceList",item);
		}
		
		//2-3. Service Cache Remove All & Put All
		CacheUtils.removeCacheAllValue(cacheManager, LGCOMConstants.SERVICE_CACHE);
		List<LGCOMData> serviceList = (List<LGCOMData>)commonService.retrieveServiceList();
		
		for(LGCOMData service : LGCOMUtils.emptyIfNull( serviceList ) ) {
			CacheUtils.setCacheValue(cacheManager, LGCOMConstants.SERVICE_CACHE, service.getString("progServId"), "Y");
		}
		
		CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.SERVICE_CACHE);
	}

	/**
	 * Desc : Program Service Role 목록을 조회한다.
	 * @Method Name : retrieveProgramServiceRoleList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveProgramServiceRoleList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00150.retrieveProgramServiceRoleList",param);
	}

	/**
	 * Desc : Program Service Role 목록을 저장한다.
	 * @Method Name : saveProgramServiceRoleList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void saveProgramServiceRoleList(LGCOMData param) {
		LOGGER.debug("param = " + param);
        /* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		/* 삭제건 저장 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( dList ) ) {
			this.commonDao.update("LGSYSC00150.deleteProgramServiceRoleList",item);
		}
		
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		for( LGCOMData item : LGCOMUtils.emptyIfNull( cList ) ) {
			item.put("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00150.insertProgramServiceRoleList",item);
		}
	}
}
