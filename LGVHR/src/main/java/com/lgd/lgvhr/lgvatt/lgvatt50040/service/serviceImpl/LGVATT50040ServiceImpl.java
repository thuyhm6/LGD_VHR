/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50040Service.java
 * @Desc    : Setup OT level
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
package com.lgd.lgvhr.lgvatt.lgvatt50040.service.serviceImpl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50040.service.LGVATT50040Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50040.controller.LGVATT50040Controller.java
 * </PRE>
 *
 * @Author    HMS
 * @Date      2021. 03. 17. 11:06 AM
 * @Version
 */
@Service(value="LGVATT50040Service")
public class LGVATT50040ServiceImpl implements LGVATT50040Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50040ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOtLevel(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50040.retrieveOtLevel",param);
	}
	
	/**
	 * Desc : Search code type.
	 * @Method Name : retrieveCodeType
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeType(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50040.retrieveCodeType",param);
	}
	
	/**
     * Desc : Save overtime level manage.
     * @Method Name : saveOtLevelManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveOtLevelManage(LGCOMData param) {
		LOGGER.debug("saveOtLevelManage param = " + param);

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
			
			this.commonDao.update("LGVATT50040.deleteOtLevel",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50040.updateOtLevel",uItem);
		}
		//Insert
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			iItem.put("timeAndAttendanceYyyymm", parameter.getString("timeAndAttendanceYyyymm"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50040.insertOtLevel",iItem);
		}
			
	}
	

}
