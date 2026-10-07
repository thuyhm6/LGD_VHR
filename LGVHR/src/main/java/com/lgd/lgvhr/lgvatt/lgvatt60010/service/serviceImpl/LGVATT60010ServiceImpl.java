package com.lgd.lgvhr.lgvatt.lgvatt60010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt60010.service.LGVATT60010Service;

@Service(value="LGVATT60010Service")
public class LGVATT60010ServiceImpl implements LGVATT60010Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT60010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 

	/**
	 * Desc : 
	 * @Method Name : retrieveWeekAttSummary
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveWeekAttSummary(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT60010.retrieveWeekAttSummary",param);
	}
	
	/**
	 * Desc : 
	 * @Method Name : retrieveWeekDateFromTo
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveWeekDateFromTo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT60010.retrieveWeekDateFromTo",param);
	}
	/**
	 * Desc : 
	 * @Method Name : retrieveOrgList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveOrgList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT60010.retrieveOrgList",param);
	}
	
	
}
