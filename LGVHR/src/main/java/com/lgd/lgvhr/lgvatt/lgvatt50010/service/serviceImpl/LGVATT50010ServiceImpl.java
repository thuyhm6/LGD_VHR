/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT50010Service.java
 * @Desc    : 근태마감일 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50010.service.LGVATT50010Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50010.controller.LGVATT50010Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT50010Service")
public class LGVATT50010ServiceImpl implements LGVATT50010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 근태마감일을 조회한다.
	 * @Method Name : retrieveAttendanceClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceClose(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50010.retrieveAttendanceClose",param);
	}
	
	/**
	 * Desc : 근태년월을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymmNEmployeeList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymm(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		
		//현재근태년월
		result.set("currentYyyymmData", this.commonDao.select("LGVATTCOMM.retrieveCurrentYyyymm", param));
		//근태년월 리스트
		result.set("yyyymmList", this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceYyyymmList",param));

		return result;
	}
	
	/**
     * Desc : 근태마감일을 저장한다.
     * @Method Name : saveAttendanceClose
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveAttendanceClose(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		String[] attendanceYyyymmSplit = null;
		String[] periodCloseDateVal = null;
		String[] periodFromDateSplit = null;
		String[] periodToDateSplit = null;
		String[] periodCloseDateSplit = null;
		String periodCloseDate = "";
		
		if(insertList != null && insertList.size() > 0) {
			 LGCOMData item = insertList.get(0);
			 item.set("applicationUserId", userSession.getString("applicationUserId"));
			 item.set("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			 
			 //근태년월은 YYYYMM 형태로 넣어줌
			 if(item.getString("timeAndAttendanceYyyymm").length() != 0 && item.getString("timeAndAttendanceYyyymm") != null) {
				 
				 periodCloseDateVal = item.getString("periodCloseDate").split(" ");
				 periodCloseDateSplit = periodCloseDateVal[0].split("/");
				 periodCloseDate = periodCloseDateSplit[2]+periodCloseDateSplit[1]+periodCloseDateSplit[0]+periodCloseDateVal[1].replaceAll(":", "");
				 
				 attendanceYyyymmSplit = item.getString("timeAndAttendanceYyyymm").split("/");
				 item.set("timeAndAttendanceYyyymm", attendanceYyyymmSplit[1]+attendanceYyyymmSplit[0]);
				 item.set("periodCloseDate", periodCloseDate);
				 
				 periodFromDateSplit = item.getString("periodFromDate").split("/");
				 item.set("periodFromDate", periodFromDateSplit[2]+periodFromDateSplit[1]+periodFromDateSplit[0]);
				 periodToDateSplit = item.getString("periodToDate").split("/");
				 item.set("periodToDate", periodToDateSplit[2]+periodToDateSplit[1]+periodToDateSplit[0]);
			 }
			 
			 this.commonDao.update("LGVATT50010.mergeAttendanceClose", item);
		 }
		
		if(updateList != null && updateList.size() > 0) {
			 LGCOMData item = updateList.get(0);
			 item.set("applicationUserId", userSession.getString("applicationUserId"));
			 item.set("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			 
			 //근태년월은 YYYYMM 형태로 넣어줌
			 if(item.getString("timeAndAttendanceYyyymm").length() != 0 && item.getString("timeAndAttendanceYyyymm") != null) {
				 periodCloseDateVal = item.getString("periodCloseDate").split(" ");
				 periodCloseDateSplit = periodCloseDateVal[0].split("/");
				 periodCloseDate = periodCloseDateSplit[2]+periodCloseDateSplit[1]+periodCloseDateSplit[0]+periodCloseDateVal[1].replaceAll(":", "");
				 
				 LOGGER.debug("periodCloseDate  = " + periodCloseDate);
				 
				 attendanceYyyymmSplit = item.getString("timeAndAttendanceYyyymm").split("/");
				 item.set("timeAndAttendanceYyyymm", attendanceYyyymmSplit[1]+attendanceYyyymmSplit[0]);
				 item.set("periodCloseDate", periodCloseDate);
				 
				 periodFromDateSplit = item.getString("periodFromDate").split("/");
				 item.set("periodFromDate", periodFromDateSplit[2]+periodFromDateSplit[1]+periodFromDateSplit[0]);
				 periodToDateSplit = item.getString("periodToDate").split("/");
				 item.set("periodToDate", periodToDateSplit[2]+periodToDateSplit[1]+periodToDateSplit[0]);
			 }
			 
			 this.commonDao.update("LGVATT50010.mergeAttendanceClose", item);
		 }
	}
    /**
     * Desc : 근태마감일을 승인한다.
     * @Method Name : saveConfirmAttendanceClose
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveConfirmAttendanceClose(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		String[] attendanceYyyymmSplit = null;
		String timeAndAttendanceYyyymm = param.getString("timeAndAttendanceYyyymm");
		if(timeAndAttendanceYyyymm.length() > 0) {
			attendanceYyyymmSplit = timeAndAttendanceYyyymm.split("/");
			param.set("timeAndAttendanceYyyymm", attendanceYyyymmSplit[1]+attendanceYyyymmSplit[0]);
		}
		
		this.commonDao.update("LGVATT50010.saveConfirmAttendanceClose", param);
	}
}
