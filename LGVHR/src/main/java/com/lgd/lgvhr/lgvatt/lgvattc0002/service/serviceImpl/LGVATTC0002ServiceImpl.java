package com.lgd.lgvhr.lgvatt.lgvattc0002.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0002.service.LGVATTC0002Service;

@Service(value="LGVATTC0002Service")
public class LGVATTC0002ServiceImpl implements LGVATTC0002Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0002ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeCreateAttClose(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeCreateAttClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeCreateAttClose(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0002.executeCreateAttClose", param );		
		return ldata;
	}
	
	
	

}
