package com.lgd.lgvhr.lgvatt.lgvattc0011.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0011.service.LGVATTC0011Service;

@Service(value="LGVATTC0011Service")
public class LGVATTC0011ServiceImpl implements LGVATTC0011Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0011ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeApplyIdCardIfData(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeApplyIdCardIfData
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeApplyIdCardIfData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0011.executeApplyIdCardIfData", param );		
		return ldata;
	}
	
	
	

}
