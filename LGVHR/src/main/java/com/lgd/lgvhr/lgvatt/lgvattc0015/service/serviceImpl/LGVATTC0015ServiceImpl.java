package com.lgd.lgvhr.lgvatt.lgvattc0015.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0015.service.LGVATTC0015Service;
/**
 * @author HMT_20210426
 * Automatically changes to Unpaid leave
 *
 */
@Service(value="LGVATTC0015Service")
public class LGVATTC0015ServiceImpl implements LGVATTC0015Service, CommonBatchService {
protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0015ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeUpdateAttResultWithoutInOut(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeUpdateAttResultWithoutInOut
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeUpdateAttResultWithoutInOut(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0015.executeUpdateAttResultWithoutInOut", param );		
		return ldata;
	}

}
