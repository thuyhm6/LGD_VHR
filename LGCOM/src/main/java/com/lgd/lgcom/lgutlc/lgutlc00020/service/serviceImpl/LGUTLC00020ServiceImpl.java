/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00020ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 8.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00020.service.LGUTLC00020Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00020.service.serviceImpl.LGUTLC00020ServiceImpl.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 8. 오후 4:35:58
 * @Version
 */
@Service("LGUTLC00020Service")
public class LGUTLC00020ServiceImpl implements LGUTLC00020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Autowired
	private EhCacheCacheManager cacheManager;
	  

	/**
	 * Desc : 디버깅 목록을 조회한다.
	 * @Method Name : retrieveDebuggingList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveDebuggingList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00020.retrieveDebuggingList",param);
	}
	
  /**
   * Desc : 디버깅 정보를 저장한다.
   * @Method Name : saveUserRoleList
   * @param  param
   * @throws Exception
   */

  @SuppressWarnings({ "unchecked", "rawtypes" })
  public void saveDebuggingList(LGCOMData param){
	  LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
      LOGGER.debug("param = " + param);
      
      /* 등록건 저장 */
      List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
      for( LGCOMData item : LGCOMUtils.emptyIfNull( cList ) ) {
          /* Duplecate check */
    	  LGCOMData map = this.commonDao.select("LGUTLC00020.retrieveDebugScopeNameChk",item);
          if(map.getInt("cnt") > 0) {
              throw new LGCOMException("error.duplicateValue");
          }
          
          /* 세션 사용자 정보 세팅 */
          item.put("sessionUserId", userSession.getString("applicationUserId"));
          this.commonDao.update("LGUTLC00020.insertDebuggingList",item);
          CacheUtils.setCacheValue(cacheManager, LGCOMConstants.DEBUG_CACHE, item.get("debugScopeId").toString(), "Y");
      }
      
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00020.updateDebuggingList", item);

			if (item.get("useFlag") == "Y") {
				CacheUtils.setCacheValue(cacheManager, LGCOMConstants.DEBUG_CACHE, item.get("debugScopeId").toString(),
						"Y");
			} else {
				CacheUtils.removeCacheValue(cacheManager, LGCOMConstants.DEBUG_CACHE,
						item.get("debugScopeId").toString());
			}
		}
		
      /* 삭제건 저장 */
      List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
      for (LGCOMData item : LGCOMUtils.emptyIfNull(dList)) {
          /* 세션 사용자 정보 세팅 */
          item.put("sessionUserId", userSession.getString("applicationUserId"));
          this.commonDao.update("LGUTLC00020.deleteDebugging",item);
      }
  }
  
  /**
   * Desc : 디버깅 중복체크를 한다.
   * @Method Name : retrieveDebuggingList
   * @param  param
   * @return List<?>
   * @throws Exception
   */
  public List<LGCOMData> retrieveDebugScopeNameChk(LGCOMData param) {
      LOGGER.debug("param = " + param);
      return this.commonDao.selectList("LGUTLC00020.retrieveDebugScopeNameChk",param);
  }
}
