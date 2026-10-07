package com.lgd.lgcom.common.listener;

import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.NullUtil;

public class EhcacheLoadForBatchListener implements ServletContextListener {

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		ServletContext ctx = sce.getServletContext();
		WebApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(ctx);
		WebApplicationContext springContext = WebApplicationContextUtils.getWebApplicationContext(ctx);
		
		if (!NullUtil.isNull(springContext)) {
			loadServiceCache(context);
		}
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		ServletContext ctx = sce.getServletContext();
		WebApplicationContext springContext = WebApplicationContextUtils.getWebApplicationContext(ctx);
		if (!NullUtil.isNull(springContext)) {
			EhCacheCacheManager cacheManager = (EhCacheCacheManager)springContext.getBean("cacheManager");
			CacheUtils.removeCacheAllValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE );
		}
	}
	
	public void loadServiceCache( WebApplicationContext context) {
		EhCacheCacheManager cacheManager = (EhCacheCacheManager)context.getBean("cacheManager");
		BatchService service = (BatchService)context.getBean("batchService");
		
		List<LGCOMData> serviceList = service.retrieveBatchScheduleList();
		for (LGCOMData item : LGCOMUtils.emptyIfNull( serviceList ) ) {
			CacheUtils.setCacheValue(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE, item.getString("batchId"), item );
		}
		
		CacheUtils.printCacheStatics(cacheManager, LGCOMConstants.BATCH_SCHEDULE_CACHE);
	}
}
