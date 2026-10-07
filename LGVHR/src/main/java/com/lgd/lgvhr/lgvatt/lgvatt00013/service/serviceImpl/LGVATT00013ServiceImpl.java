/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt00013Service.java
 * @Desc    : OS KPI Standard
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2021. 03. 17.    HMS    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00013.service.serviceImpl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00013.service.LGVATT00013Service;


@Service(value="LGVATT00013Service")
public class LGVATT00013ServiceImpl implements LGVATT00013Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00013ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveOsKpiStandard
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOsKpiStandard(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00013.retrieveOsKpiStandard",param);
	}

	/**
     * Desc : Save OS KPI Standard.
     * @Method Name : saveOsKpiStandardManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveOsKpiStandard(LGCOMData param) {
		LOGGER.debug("saveOsKpiStandard param = " + param);

		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		//Delete
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			dItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT00013.deleteOsKpiStandard",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT00013.updateOsKpiStandard",uItem);
		}
		//Insert
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			iItem.put("timeAndAttendanceYyyymm", parameter.getString("timeAndAttendanceYyyymm"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT00013.insertOsKpiStandard",iItem);
		}
			
	}
	

}
