/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00210ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 07. 14.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00210.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00210.service.LGUTLC00220Service;

import ch.qos.logback.classic.Logger;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00210.service.lgutlc00210Service.java
 * </PRE>
 *
 * @Author    jhlee
 * @Date      2016. 09. 18. 오후 1:39:58
 * @Version
 */
@Service("LGUTLC00220Service")
public class LGUTLC00220ServiceImpl implements LGUTLC00220Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00220ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Autowired 
	EhCacheCacheManager cacheManager;
	
	@Autowired
	BatchService batchService;

	/**
	 * Desc : Batch Sechedule 목록을 조회한다.
	 * @Method Name : retrieveBatchScheduleList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveBatchScheduleList(LGCOMData param) {
		return commonDao.selectList("LGUTLC00220.retrieveBatchScheduleList", param );
    }
	
	/**
	 * Desc : Batch ID 가져온다
	 * @Method Name : retrieveBatchScheduleList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveNewBatchId(LGCOMData param) {
		return commonDao.select("LGUTLC00220.retrieveNewBatchId", param );
    }	
	/**
	 * Desc : Batch Sechedule 목록을 저장 한다.
	 * @Method Name : saveBatchScheduleList
	 * @param  param
	 * @return void
	 */
	@SuppressWarnings("unchecked")
	public void saveBatchScheduleList(LGCOMData param) {
		List<LGCOMData> list = LGCOMData.createList();
				
		
		List<LGCOMData> insert = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		for( LGCOMData item : LGCOMUtils.emptyIfNull( insert) ) {
			item.set( LGCOMConstants.HTTP_SESSION_KEY, param.get( LGCOMConstants.HTTP_SESSION_KEY ) );
			item.set("_type_", LGCOMConstants.STATUS_INSERT);
			
			LGCOMData data = new LGCOMData();
			data = retrieveNewBatchId(param);
			item.set("batchId", data.getString("batchId"));
			
			list.add(item);
			commonDao.insert("LGUTLC00220.insertBatchScheduleList", item );
		}
		
		List<LGCOMData> update = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull( update) ) {
			item.set( LGCOMConstants.HTTP_SESSION_KEY, param.get( LGCOMConstants.HTTP_SESSION_KEY ) );
			item.set("_type_", LGCOMConstants.STATUS_UPDATE);
			list.add(item);
			commonDao.insert("LGUTLC00220.updateBatchScheduleList", item );
		}
		
		List<LGCOMData> delete = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull( delete) ) {
			item.set("_type_", LGCOMConstants.STATUS_DELETE);
			list.add(item);
			commonDao.insert("LGUTLC00220.deleteBatchScheduleList", item );
		}
		
		CacheUtils.removeCacheAllValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE);
		List<LGCOMData> serviceList = batchService.retrieveBatchScheduleList();
		for (LGCOMData item : LGCOMUtils.emptyIfNull( serviceList ) ) {
			CacheUtils.setCacheValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE, item.getString("batchId"), item );
		}
		
		/*
  "requestStartDate": "2017-01-01 14:00:00",
  "systemCode": "LGCOM",
  "batchId": 1,
  "holdFlag": "N",
  "runningCount": 1,
  "targetCount": 2,
  "submitInterval": 1,
  "batchName" : "batchName"
  "programId": "LGBATC00020",
  "submitIntervalUnitCode": "MINUTE",
  "submitIntervalTypeCode": "START",
  "jobWorkingFlag": "Y",
  "runAloneFlag": "N",
  "argumentText": "{}",
  "requestUserId": 452878
		 * 
		
		
		//화면에서 들어온 모든 건에 대해서 다음과 같은 처리를 수행한다. 
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list) ) {
			switch( item.getString("_type_") ){
			case LGCOMConstants.STATUS_INSERT: 
				item.set("targetCount", 0);
				item.set("runningCount", 0);
				item.set("jobWorkingFlag", "N");
				item.remove("_type_");				
				item.remove("USER_SESSION");
				
				item.set("requestUserId", item.get("requesterId"));
			    item.remove("requesterId");
			    item.remove("requesterName");
			    item.remove("requesterFullName");
			    item.remove("useFlag");
			    item.remove("requestEndDate");
			    item.remove("programName");
				
				LOGGER.debug("item" + item);
				CacheUtils.setCacheValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE, item.getString("batchId"), item );
				
				CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE);
				break;
			case LGCOMConstants.STATUS_UPDATE: 
				LOGGER.debug("item" + item);
			    LGCOMData element = CacheUtils.getCacheValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE, item.getString("batchId"));
			    element.set("submitIntervalUnitCode", item.getString("submitIntervalUnitCode") );
			    element.set("submitIntervalTypeCode", item.getString("submitIntervalTypeCode") );
			    element.set("requestUserId", item.getString("requesterId"));
			    element.set("systemCode", item.getString("systemCode"));
			    element.set("moduleCode", item.getString("moduleCode"));
			    element.set("programId", item.getString("programId"));
			    element.set("batchName", item.getString("batchName"));
			    element.set("requestStartDate", item.getString("requestStartDate"));
			    element.set("holdFlag", item.getString("holdFlag"));
			    element.set("argumentText", item.getString("argumentText"));  	
			    element.set("runAloneFlag", item.getString("runAloneFlag"));  
			    element.set("submitInterval", item.getLong("submitInterval"));   
			    
			    long newTargetCount = 0L;
			    if( "MINUTE".equals( item.getString("submitIntervalTypeCode") ) ){
			    	newTargetCount = 60L;
			    } else if( "HOUR".equals( item.getString("submitIntervalTypeCode") ) ){
			    	newTargetCount = 3600L;
			    } else if( "DAY".equals( item.getString("submitIntervalTypeCode") ) ){
			    	newTargetCount = 86400L;
			    }
			    
			    newTargetCount = newTargetCount * item.getLong("submitInterval") / 30;
			    element.set("targetCount", newTargetCount );
			    
			    //지금까지 누적된 카운트와 비교
			    if( newTargetCount <= element.getLong("runningCount") ) {
			    	 element.set("runningCount", 0 );   // 현재 누적 카운트가 새 카운트 보다 큰 경우는 이 다음 Turn 에서 트리거 되도록 조치한다.
			    }
			    CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE);
				break;
			case LGCOMConstants.STATUS_DELETE: 
				LOGGER.debug("item" + item);
				CacheUtils.removeCacheValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE, item.getString("batchId") );
				CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE);
				break;
			}
		}
		
		 */
    }
}
