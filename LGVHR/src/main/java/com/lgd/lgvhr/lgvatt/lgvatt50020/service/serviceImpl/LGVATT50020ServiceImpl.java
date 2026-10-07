/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT50020Service.java
 * @Desc    : 공휴일 관리
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
package com.lgd.lgvhr.lgvatt.lgvatt50020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50020.service.LGVATT50020Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50020.controller.LGVATT50020Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 23. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT50020Service")
public class LGVATT50020ServiceImpl implements LGVATT50020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveAttendanceClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHoliday(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50020.retrieveHoliday",param);
	}
	
	/**
	 * Desc : 공휴일의 휴일명을 조회한다.
	 * @Method Name : retrieveHolidayNameList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHolidayNameList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50020.retrieveHolidayNameList",param);
	}
	
	/**
	 * Desc : Holiday attendance를 조회한다.
	 * @Method Name : retrieveHolidayAttendance
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHolidayAttendance(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50020.retrieveHolidayAttendance",param);
	}
	
	/**
     * Desc : 휴일을 저장한다.
     * @Method Name : saveHolidayManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveHolidayManage(LGCOMData param) {
		LOGGER.debug("saveHolidayManage param = " + param);

		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			String[] holidaySplit = dItem.getString("holidayDate").split("/");
			String holidayDate = holidaySplit[2]+holidaySplit[1]+holidaySplit[0];
			
			dItem.put("holidayDate", holidayDate);
			dItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			dItem.put("timeAndAttendanceYyyy", parameter.getString("timeAndAttendanceYyyy"));
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50020.deleteHoliday",dItem);
		}
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			String[] holidaySplit = uItem.getString("holidayDate").split("/");
			String holidayDate = holidaySplit[2]+holidaySplit[1]+holidaySplit[0];
			
			uItem.put("holidayDate", holidayDate);
			uItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			uItem.put("timeAndAttendanceYyyy", parameter.getString("timeAndAttendanceYyyy"));
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50020.updateHoliday",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			String[] holidaySplit = iItem.getString("holidayDate").split("/");
			String holidayDate = holidaySplit[2]+holidaySplit[1]+holidaySplit[0];
			
			iItem.put("holidayDate", holidayDate);
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			iItem.put("timeAndAttendanceYyyy", parameter.getString("timeAndAttendanceYyyy"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50020.insertHoliday",iItem);
		}
			
	}
    
    /**
     * Desc : Calculate Attendance.
     * @Method Name : calculateAttendance
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
    public void calculateAttendance(LGCOMData param) {
        LOGGER.debug("param = " + param);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
		
   		LOGGER.debug("modifyList = " + modifyList);
    	
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
        	String[] holidaySplit = item.getString("holidayDate").split("/");
			String holidayDate = holidaySplit[2]+holidaySplit[1]+holidaySplit[0];
			String timeAndAttendanceCode = item.getString("timeAndAttendanceCode");
			if (timeAndAttendanceCode.equals("PH")) {
				item.put("publicHolidayCode", "PH");
			}if (timeAndAttendanceCode.equals("WH")) {
				item.put("weeklyHolidayCode", "WH");
			}
			item.put("holidayDate", holidayDate);
			item.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			item.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50020.updateAttBase", item );	
			this.commonDao.update("LGVATT50020.updateAttPlan", item );
			this.commonDao.update("LGVATT50020.updateAttResult", item );
        }
	}
}
