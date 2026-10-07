package com.lgd.lgvhr.lgvatt.lgvatt00000.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00000.service.LGVATT00000Service;

@Service(value="LGVATT00000Service")
public class LGVATT00000ServiceImpl implements LGVATT00000Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00000ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeUserInterface(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeUserInterface
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeUserInterface(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return new LGCOMData();
	}

}
