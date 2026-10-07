package com.lgd.lgvhr.lgvatt.lgvattc0007.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0007.service.LGVATTC0007Service;

@Service(value="LGVATTC0007Service")
public class LGVATTC0007ServiceImpl implements LGVATTC0007Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0007ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeApplyAttFrAsg(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeApplyAttFrAsg
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeApplyAttFrAsg(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0007.executeApplyAttFrAsg", param );		
		return ldata;
	}
	
	
	

}
