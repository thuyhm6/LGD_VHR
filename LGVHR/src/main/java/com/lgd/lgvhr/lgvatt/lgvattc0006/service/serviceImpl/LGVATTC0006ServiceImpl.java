package com.lgd.lgvhr.lgvatt.lgvattc0006.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0006.service.LGVATTC0006Service;

@Service(value="LGVATTC0006Service")
public class LGVATTC0006ServiceImpl implements LGVATTC0006Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0006ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeCreateAttAnnualLeave(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeCreateAttAnnualLeave
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeCreateAttAnnualLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0006.executeCreateAttAnnualLeave", param );		
		return ldata;
	}
	
	
	

}
