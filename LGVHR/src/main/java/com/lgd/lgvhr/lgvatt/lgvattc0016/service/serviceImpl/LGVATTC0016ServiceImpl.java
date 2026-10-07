package com.lgd.lgvhr.lgvatt.lgvattc0016.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0016.service.LGVATTC0016Service;
/**
 * @author HMT_20210426
 * Automatically changes to Unpaid leave
 *
 */
@Service(value="LGVATTC0016Service")
public class LGVATTC0016ServiceImpl implements LGVATTC0016Service, CommonBatchService {
protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0016ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeOutingCount(param);
	}

	/**
	 * Desc : LGD gate in/out information daily report data
	 * @Method Name : executeDailyIDCardATTInfo
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeOutingCount(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0016.executeOutingCount", param );		
		return ldata;
	}
}
