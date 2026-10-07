package com.lgd.lgvhr.lgvatt.lgvatt00020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00020.service.LGVATT00020Service;

@Service(value="LGVATT00020Service")
public class LGVATT00020ServiceImpl implements LGVATT00020Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : 
	 * @Method Name : retrieveAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveAttList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00020.retrieveAttList",param);
	}
}
