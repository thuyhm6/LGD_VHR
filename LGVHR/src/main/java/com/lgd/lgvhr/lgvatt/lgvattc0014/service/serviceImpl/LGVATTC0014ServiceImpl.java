package com.lgd.lgvhr.lgvatt.lgvattc0014.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0014.service.LGVATTC0014Service;

@Service(value="LGVATTC0014Service")
public class LGVATTC0014ServiceImpl implements LGVATTC0014Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0014ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeCreateEmployeeOtLevel(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeCreateEmployeeOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeCreateEmployeeOtLevel(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0014.executeCreateEmployeeOtLevel", param );		
		return ldata;
	}

}
