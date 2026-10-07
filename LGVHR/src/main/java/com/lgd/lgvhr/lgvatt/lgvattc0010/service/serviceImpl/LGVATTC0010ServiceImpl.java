package com.lgd.lgvhr.lgvatt.lgvattc0010.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0010.service.LGVATTC0010Service;

@Service(value="LGVATTC0010Service")
public class LGVATTC0010ServiceImpl implements LGVATTC0010Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeSendApproverLWAttInfo(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeSendApproverLWAttInfo
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeSendApproverLWAttInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0010.executeSendApproverLWAttInfo", param );		
		return ldata;
	}
	
	
	

}
