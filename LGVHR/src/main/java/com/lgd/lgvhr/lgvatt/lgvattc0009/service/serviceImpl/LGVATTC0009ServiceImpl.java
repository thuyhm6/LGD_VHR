package com.lgd.lgvhr.lgvatt.lgvattc0009.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0009.service.LGVATTC0009Service;

@Service(value="LGVATTC0009Service")
public class LGVATTC0009ServiceImpl implements LGVATTC0009Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0009ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeApplyNotApprovedAttReq(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeApplyNotApprovedAttReq
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeApplyNotApprovedAttReq(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0009.executeApplyNotApprovedAttReq", param );		
		return ldata;
	}
	
	
	

}
