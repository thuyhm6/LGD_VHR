package com.lgd.lgvhr.lgvatt.lgvattc0008.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0008.service.LGVATTC0008Service;

@Service(value="LGVATTC0008Service")
public class LGVATTC0008ServiceImpl implements LGVATTC0008Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0008ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeApplyAttResultFrPlan(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeApplyAttResultFrPlan
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeApplyAttResultFrPlan(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0008.executeApplyAttResultFrPlan", param );		
		return ldata;
	}
	
	
	

}
