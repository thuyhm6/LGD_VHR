package com.lgd.lgvhr.lgvatt.lgvatt30050.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30050.service.LGVATT30050Service;

@Service(value="LGVATT30050Service")
public class LGVATT30050ServiceImpl implements LGVATT30050Service{
	
protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30050ServiceImpl.class);
	
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
	public List<LGCOMData> retrieveMonthlyEmpLevelList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT30050.retrieveMonthlyEmpLevelList", param);
	}

}
