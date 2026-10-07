/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt30090Service.java
 * @Desc    : Daily Summary
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
package com.lgd.lgvhr.lgvatt.lgvatt30090.service.serviceImpl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30090.service.LGVATT30090Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30090.controller.LGVATT30090Controller.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 03. 07. 04:27 PM
 * @Version
 */
@Service(value="LGVATT30090Service")
public class LGVATT30090ServiceImpl implements LGVATT30090Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30090ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
    /**
     * Desc : select Daily Att Summary List.
     * @Method Name : getDailyAttSummaryList
     * @param  param LGCOMData
     * @throws 
     */
	@Override
	public List<LGCOMData> getDailyAttSummaryList(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
		param.set("employeeNo", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("employeeNo"));
		
		LGCOMData orgData = new LGCOMData();
		orgData = this.commonDao.select("LGVATT30090.getOrgId", param);
		param.set("orgType", orgData.get("orgType").toString());
		param.set("organizationId", orgData.get("organizationId").toString());
		
		return this.commonDao.selectList("LGVATT30090.getDailySummaryList", param);
	}
}
