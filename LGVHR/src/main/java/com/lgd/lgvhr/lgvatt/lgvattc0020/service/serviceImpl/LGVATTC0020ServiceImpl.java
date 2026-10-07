package com.lgd.lgvhr.lgvatt.lgvattc0020.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0020.service.LGVATTC0020Service;
import com.lgd.lgvhr.lgvatt.lgvattc0020.service.serviceImpl.LGVATTC0020ServiceImpl;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTC0019ServiceImpl.java
 * @Desc    : Calculate Employee Attendance Automatic
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2025.11.11  HMT_20251111    Daily Calculate Employee Attendance
 *------------------------------------------------------------------------------
 */
@Service(value="LGVATTC0020Service")
public class LGVATTC0020ServiceImpl implements LGVATTC0020Service, CommonBatchService{
protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0020ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeCalculateEmployeeAttendance(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeCreateEmployeeOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeCalculateEmployeeAttendance(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVATTC0020.executeCalculateEmployeeAttendance", param );		
		
		return ldata;
	}
}
