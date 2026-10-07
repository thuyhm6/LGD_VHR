package com.lgd.lgvhr.lgvatt.lgvatt30020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30020.service.LGVATT30020Service;

@Service(value="LGVATT30020Service")
public class LGVATT30020ServiceImpl implements LGVATT30020Service{
	
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30020ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : retrieveYearOtTotalList
	 * @Method Name : retrieveYearOtTotalList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveYearOtTotalList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT30020.retrieveYearOtTotalList", param);
	}

}
