package com.lgd.lgvhr.lgvpay.lgvpayc00001.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayc00001.service.LGVPAYC00001Service;

@Service(value="LGVPAYC00001Service")
public class LGVPAYC00001ServiceImpl implements LGVPAYC00001Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYC00001ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executePayrollRun(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeUserInterface
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executePayrollRun(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVPAYC00001.executePayrollRun", param );		
		return ldata;
	}
	
	
	

}
