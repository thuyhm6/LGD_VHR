package com.lgd.lgvhr.lgvpay.lgvpay00033.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00033.service.LGVPAY00033Service;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00031Service.java
 * @Desc    : Retrieve Paid Leave Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List    
 *------------------------------------------------------------------------------
 */
@Service(value="LGVPAY00033Service")
public class LGVPAY00033ServiceImpl implements LGVPAY00033Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00033ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Retrieve Perfect Actual.
	 * @Method Name : retrievePerfectActual
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePerfectActual(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00033.retrievePerfectActual",param);
	}
}
