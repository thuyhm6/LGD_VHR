/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00401ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 5.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00402.service.serviceImpl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00402.service.LGUTLC00402Service;

import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00401.service.serviceImpl.LGUTLC00401ServiceImpl.java
 * </PRE>
 *
 * @Author forain
 * @Date 2016. 10. 5. 오후 1:39:20
 * @Version
 */
@Service("LGUTLC00402Service")
public class LGUTLC00402ServiceImpl implements LGUTLC00402Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00402ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/*** Cache 데이터 목록을 조회하는 서비스 ***/
	public LGCOMData retrieveCacheItems(LGCOMData param) {
		LGCOMData result = new LGCOMData();
		CacheManager cacheManager = CacheManager.create();
		Cache cache = null;
		
		if( param.get("target") != null  ) {
			cache = cacheManager.getCache( param.getString("target") );
			
			List items = new ArrayList();
			result.set( param.getString("target") , items);
			
			List<String> keys = cache.getKeys();
			for (String key : LGCOMUtils.emptyIfNull(keys)) {
				if (cache.get(key).getObjectValue() instanceof LGCOMData) {
					items.add(cache.get(key).getObjectValue());
				} else {
					LGCOMData value = new LGCOMData();
					value.set("key", key);
					value.set("value", cache.get(key).getObjectValue());
					items.add(value);
				}
			}
		} else {
			String[] cacheNames = cacheManager.getCacheNames();

			if (cacheNames != null) {
				for (String name : cacheNames) {
					List items = new ArrayList();
					result.set(name, items);

					cache = cacheManager.getCache(name);
					List<String> keys = cache.getKeys();

					for (String key : LGCOMUtils.emptyIfNull(keys)) {
						if (cache.get(key).getObjectValue() instanceof LGCOMData) {
							items.add(cache.get(key).getObjectValue());
						} else {
							LGCOMData value = new LGCOMData();
							value.set("key", key);
							value.set("value", cache.get(key).getObjectValue());
							items.add(value);
						}
					}
				}
			}
		}
	
		return result;
	}

	/*** Cache 데이터를 저장하는 서비스 ***/
	public void saveCacheItems(LGCOMData param) {
		// cacheManger 설정
		CacheManager cacheManager = CacheManager.create();
		Map<String, Object> wrapper = (Map<String, Object>) param.get("rawJsonData");
		
LOGGER.debug( "AAAAAAAAAAAA" + wrapper.toString() );		
		
		for( String cacheName : LGCOMUtils.emptyIfNull( wrapper.keySet() )  ) {
			
			LOGGER.debug( "AAAAAAAAAAAA cacheName : " + cacheName );					
			
			Cache cache = cacheManager.getCache(cacheName);
			
			List<LGCOMData> list = (List<LGCOMData>) wrapper.get(cacheName);	
			
			for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ){
				String key = (String)item.get( "key" );
				LGCOMData value = (LGCOMData) item.get("value");
				Element element = new Element( key, value );
				cache.put( element );
LOGGER.debug("pushCacheEnd :" + cache.getSize() );				
			}
		}
	}
}