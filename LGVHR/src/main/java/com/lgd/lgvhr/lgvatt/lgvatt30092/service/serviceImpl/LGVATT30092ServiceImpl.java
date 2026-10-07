/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt30092Service.java
 * @Desc    : Weekly Summary
 *
 * Copyright ⓒ 2023 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2023. 03. 07.  Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt30092.service.serviceImpl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30092.service.LGVATT30092Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30092.controller.LGVATT30092Controller.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 03. 07. 04:27 PM
 * @Version
 */
@Service(value="LGVATT30092Service")
public class LGVATT30092ServiceImpl implements LGVATT30092Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30092ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
    /**
     * Desc : select Weekly Att Summary List.
     * @Method Name : getWeeklyAttSummaryList
     * @param  param LGCOMData
     * @throws 
     */
	@Override
	public List<LGCOMData> getWeeklyAttSummaryList(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
		param.set("employeeNo", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("employeeNo"));
		
		LGCOMData orgData = new LGCOMData();
		orgData = this.commonDao.select("LGVATT30092.getOrgId", param);
		param.set("orgType", orgData.get("orgType").toString());
		param.set("organizationId", orgData.get("organizationId").toString());
		
		return this.commonDao.selectList("LGVATT30092.getWeeklySummaryList", param);
	}
	
	@Override
	public LGCOMData todayWeeklyFromTo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT30092.todayWeeklyFromTo",param);
	} 
}
