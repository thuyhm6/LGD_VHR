package com.lgd.lgvhr.lgvatt.lgvattc0017.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0017.service.LGVATTC0017Service;

@Service(value="LGVATTC0017Service")
public class LGVATTC0017ServiceImpl implements LGVATTC0017Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0017ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		// TODO Auto-generated method stub
		return executeDailyAttReportCreate(param);
	}

	@Override
	public LGCOMData executeDailyAttReportCreate(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0017.executeDailyAttReportCreate", param );		
		return ldata;
	}
	
	
}
