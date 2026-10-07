package com.lgd.lgvhr.lgvatt.lgvatt00012.service.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00012.service.LGVATT00012Service;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT00012ServiceImpl.java
 * @Desc    : Create Request for OS KPI
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2026.04.01  HMT_20260401    Writing the first program
 *------------------------------------------------------------------------------
 */
@Service("LGVATT00012Service")
public class LGVATT00012ServiceImpl implements LGVATT00012Service{
	
static final LGCOMLogger logger = LGCOMLoggerFactory.getLogger(LGVATT00012ServiceImpl.class);
	
	@Autowired
	private CommonDao commonDao;
	
	@Override
	public List<LGCOMData> retrieveOsKPIRequestList(LGCOMData param) throws LGCOMException {
		
		logger.debug("retrieveSpecialOtRequestList parameter : {} ", param);
		param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		param.set(LGCOMConstants.HTTP_SESSION_KEY, (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY));
		
		return commonDao.selectList("LGVATT00012.retrieveOsKPIRequestList", param);
	}
}
