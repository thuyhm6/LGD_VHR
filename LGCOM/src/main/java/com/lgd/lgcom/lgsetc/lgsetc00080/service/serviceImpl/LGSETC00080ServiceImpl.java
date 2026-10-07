/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00080ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 4.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00080.service.serviceImpl;

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
import com.lgd.lgcom.lgsetc.lgsetc00080.service.LGSETC00080Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00080.service.serviceImpl.LGSETC00080ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 4. 오전 8:41:12
 * @Version
 */
@Service("LGSETC00080Service")
public class LGSETC00080ServiceImpl implements LGSETC00080Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00080ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Autowired
	EhCacheCacheManager cacheManager;
	
	@Autowired
	CommonService commonService;
	/**
	 *
	 * Desc : 주어진 조건에 따라 Profile Master 목록을 조회한다.
	 * @Method Name : retrieveProfileMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveProfileMasterList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00080.retrieveProfileMasterList",param);
	}

	/**
	 *
	 * Desc : 화면에서 입력된 Profile Master 목록을 저장한다.
	 * @Method Name : saveProfileMasterList
	 * @param param
	 */
	public void saveProfileMasterList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 삭제건 저장 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		if(dList != null && dList.size() > 0) {
			for(int a=0; a < dList.size(); a++) {
				LGCOMData item = dList.get(a);
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId",userSession.getInt("applicationUserId"));
				this.commonDao.delete("LGSETC00080.deleteProfileMaster",item);
			}
		}
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		if(cList != null && cList.size() > 0) {
			for(int b=0; b < cList.size(); b++) {
				LGCOMData item = cList.get(b);
				/* Check duplicate */
				LGCOMData map = this.commonDao.select("LGSETC00080.retrieveCheckProfileName",item);
				if(map.getInt("cnt") > 0) {
					throw new LGCOMException("error.duplicateValue");
				}
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId", userSession.getString("applicationUserId") );
				this.commonDao.update("LGSETC00080.insertProfileMaster",item);
			}
		}
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		if(uList != null && uList.size() > 0) {
			for(int c=0; c < uList.size(); c++) {
				LGCOMData item = uList.get(c);
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId",userSession.getInt("applicationUserId"));
				this.commonDao.update("LGSETC00080.updateProfileMaster",item);
			}
		}
		
		loadProfileCache();
	}

	/**
	 *
	 * Desc : 선택된 Profile Master에 따라 Profile 상세목록을 조회한다.
	 * @Method Name : retrieveProfileSetupList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveProfileSetupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00080.retrieveProfileSetupList",param);
	}

	/**
	 *
	 * Desc : Profile 상세내용 목록을 저장한다.
	 * @Method Name : saveProfileSetupList
	 * @param param
	 */
	public void saveProfileSetupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* 삭제건 저장 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		if(dList != null && dList.size() > 0) {
			for(int a=0; a < dList.size(); a++) {
				LGCOMData item = dList.get(a);
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId",userSession.getInt("applicationUserId"));
				this.commonDao.delete("LGSETC00080.deleteProfileSetup",item);
			}
		}
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		if(cList != null && cList.size() > 0) {
			for(int b=0; b < cList.size(); b++) {
				LGCOMData item = cList.get(b);
				/* Check duplicate */
				LGCOMData map = this.commonDao.select("LGSETC00080.retrieveCheckProfileSetup",item);
				if(map.getInt("cnt") > 0) {
					throw new LGCOMException("error.duplicateValue");
				}
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId",userSession.getInt("applicationUserId"));
				this.commonDao.update("LGSETC00080.insertProfileSetup",item);
			}
		}
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		if(uList != null && uList.size() > 0) {
			for(int c=0; c < uList.size(); c++) {
				LGCOMData item = uList.get(c);
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId",userSession.getInt("applicationUserId"));
				this.commonDao.update("LGSETC00080.updateProfileSetup",item);
			}
		}
		
		loadProfileCache();
	}

	/**
	 *
	 * Desc : Profile 내용을 관리자 권한으로 삭제한다.
	 * @Method Name : deleteProfileForce
	 * @param param
	 */
	public void deleteProfileForce(LGCOMData param) {
		// Profile Setup 삭제
		this.commonDao.delete("LGSETC00080.deleteProfileSetupProfileId",param);
		// Profile Master 삭제
		this.commonDao.delete("LGSETC00080.deleteProfileMaster",param);
	}
	
	private void loadProfileCache() {
		List<LGCOMData> profileList = commonService.retrieveProfileList();

		String currentCacheName = "";
		StringBuilder key = new StringBuilder();
		for (LGCOMData profile : LGCOMUtils.emptyIfNull(profileList) ) {

			key = new StringBuilder();

			if(!profile.getString("profileApplyTgClassCode").equals(currentCacheName)){
				currentCacheName = profile.getString("profileApplyTgClassCode");
			}
			if(currentCacheName.equals("SITE")) {
				key.append(profile.getString("profileName")).append("|");
				key.append(profile.getString("applyTargetValue"));
				CacheUtils.setCacheValue(cacheManager, LGCOMConstants.PROFILE_CACHE_SITE, key.toString(), profile.getString("profileOptionValue"));
			}
			if(currentCacheName.equals("SYSTEM")) {
				key.append(profile.getString("profileName")).append("|");
				key.append(profile.getString("applyTargetValue"));
				CacheUtils.setCacheValue(cacheManager, LGCOMConstants.PROFILE_CACHE_SYSTEM, key.toString(), profile.getString("profileOptionValue"));
			}
			if(currentCacheName.equals("USER")) {
				key.append(profile.getString("profileName")).append("|");
				key.append(profile.getString("applyTargetValue"));
				CacheUtils.setCacheValue(cacheManager, LGCOMConstants.PROFILE_CACHE_USER, key.toString(), profile.getString("profileOptionValue"));
			}
		}
		CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.PROFILE_CACHE_SITE);
		CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.PROFILE_CACHE_SYSTEM);
		CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.PROFILE_CACHE_USER);
	}
	
}
