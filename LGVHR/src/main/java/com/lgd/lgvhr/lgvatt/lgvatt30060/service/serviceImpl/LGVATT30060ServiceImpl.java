package com.lgd.lgvhr.lgvatt.lgvatt30060.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30060.service.LGVATT30060Service;

@Service(value="LGVATT30060Service")
public class LGVATT30060ServiceImpl implements LGVATT30060Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30060ServiceImpl.class);
	
	/*@Resource(name="tnxManager")
    protected CompositeDataSourceTransactionManager tnxManager;*/

	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : retrieveMonthlyAttList
	 * @Method Name : retrieveMonthlyAttList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveMonthlyAttList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT30060.retrieveMonthlyAttList", param);
	}
}
