/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00140ServiceImpl.java
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
package com.lgd.lgcom.lgsysc.lgsysc00140.service.serviceImpl;

import java.util.List;
import java.util.UUID;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchAsyncService;
import com.lgd.lgcom.common.util.DataFileUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00140.service.LGSYSC00140Service;

import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00140.service.serviceImpl.LGSYSC00140ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 26. 오전 8:14:58
 * @Version
 */
@Service("LGSYSC00140Service")
public class LGSYSC00140ServiceImpl implements LGSYSC00140Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00140ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    //@Autowired
    //private EhCacheCacheManager cacheManager;
    
    @Autowired
    BatchAsyncService batchAsyncService;

	/**
	 * Desc : Program 목록을 조회한다.
	 * @Method Name : retrieveProgramList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveProgramList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00140.retrieveProgramList",param);
	}

	/**
	 * Desc : Program ID로 중복 체크를 한다.
	 * @Method Name : retrieveCheckDuplicatedProgramId
	 * @param  param
	 * @throws Exception
	 */
	public boolean retrieveCheckDuplicatedProgramId(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData map = this.commonDao.select("LGSYSC00140.retrieveCheckDuplicatedProgramId",param);
		if(map.getInt("cnt") > 0) {
			return true;
		}
		return false;
	}

	/**
	 * Desc : Program 목록을 저장한다.
	 * @Method Name : saveProgramList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void saveProgramList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Session 정보 얻기 */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		/* 삭제건 저장 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00140.deleteProgramList",item);
		}
		
		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
			/* Check duplicate */
			LGCOMData map = this.commonDao.select("LGSYSC00140.retrieveCheckDuplicatedProgramId",item);
			if(map.getInt("cnt") > 0) {
				throw new LGCOMException("error.duplicateValue");
			}
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00140.insertProgramList",item);
		}
		
		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId",userSession.getString("applicationUserId"));
			this.commonDao.update("LGSYSC00140.updateProgramList",item);
		}
	}

	@Override
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGSYSC00140.createExcelDownloadData",param);
        
        List<LGCOMData> list = LGCOMData.createList();
        
        try {
        	LGCOMData result = new LGCOMData();
            result.set("resultCnt", resultCnt);
            result.set("sessionId", sessionId);
            result.set("sheetName", "프로그램 리스트" );
            list.add(result);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
        
        return list;
    }

	@Override
	public void createProgramInfoFromUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
		this.commonDao.select("LGSYSC00140.createProgramInfoFromUpload",param);
	}

    public List<LGCOMData> retrieveCache(LGCOMData param) {
        CacheManager cacheManager = CacheManager.create();
        Cache cache = cacheManager.getCache("syncCacheTest");
        
        String str = "";
        
        try {
            str = (String)cache.get("pcw").getObjectValue();
        } catch(Exception e) {
            str = "NO VALUE";
        }
        LOGGER.debug("pcw => " + str);
        
        LGCOMData map = new LGCOMData();
        map.set("pcw", str);
        
        List<LGCOMData> list = LGCOMData.createList();
        list.add(map);
        
        return list;
    }

    public void saveCache(LGCOMData param) {
        CacheManager cacheManager = CacheManager.create();
        Cache cache = cacheManager.getCache("syncCacheTest");
        String uuid = UUID.randomUUID().toString();
        Element element = new Element("pcw", uuid);
        cache.put(element);
        
        LOGGER.debug("Cache saved => " + uuid);
    }

    public void removeCache(LGCOMData param) {
        CacheManager cacheManager = CacheManager.create();
        Cache cache = cacheManager.getCache("syncCacheTest");
        cache.remove("pcw");
        
        LOGGER.debug("Cache Removed");
    }

    public void execBatch(LGCOMData param) {
        batchAsyncService.executeBatchAsync(param);
        
        LOGGER.debug("Batch Executed");
    }
    
	/**
	 * Desc : Program 목록을 조회한다.
	 * @Method Name : retrieveProgramListForReport
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveProgramListForReport(LGCOMData param) {
	    LOGGER.debug("param = " + param);
	    List<LGCOMData> list = this.commonDao.selectList("LGSYSC00140.retrieveProgramList",param);
	   
	    DataFileUtils dataFile = new DataFileUtils();
	    dataFile.addData( "programList", list );
	    
	    return dataFile.getFileInfo();
	}
}
