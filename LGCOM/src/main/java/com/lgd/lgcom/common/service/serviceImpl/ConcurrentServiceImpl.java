/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SampleServiceImpl.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 25.  	jhpark23  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import java.util.Iterator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.ConcurrentService;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.model.LGCOMData;

import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;
import net.sf.ehcache.Status;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.ApprovalServiceImpl.java
 * </PRE>
 *
 * @Author jhpark23
 * @Date 2016. 8. 25. 오전 11:56:51
 * @Version
 */
@Service("concurrentService")
public class ConcurrentServiceImpl implements ConcurrentService {
	@Autowired
	private CommonDao commonDao;
	
	@SuppressWarnings("unchecked")
    public void updateRequestAsRead(LGCOMData param){
		List<LGCOMData> requestIdList = (List<LGCOMData>)param.get("requestIdList");		
		if( requestIdList != null ) {
			for( LGCOMData item : LGCOMUtils.emptyIfNull(requestIdList ) ) {
				commonDao.delete("concurrent.concurrentconcurrentconcurrent", item);		
			}
		} else {
			commonDao.delete("concurrent.concurrentconcurrentconcurrent", param);	
		}
	}	
	
    public List<LGCOMData> retrieveUnReadRequestList(LGCOMData param) {
        return commonDao.selectList("concurrent.retrieveUnReadNotification",param);
    }	
    
    public List<LGCOMData> retrieveCachedRequestList(LGCOMData param) {
       List<LGCOMData> list = commonDao.selectList("concurrent.retrieveUnReadNotificationCandidates",param);
    	for( LGCOMData item : LGCOMUtils.emptyIfNull(list) ) {
    		item.set(LGCOMConstants.HTTP_SESSION_KEY, param.get(LGCOMConstants.HTTP_SESSION_KEY) );
    		commonDao.update("concurrent.updateBatchPopupAlarmFlag", item);
    	}
    	
		return list;
    }
}
