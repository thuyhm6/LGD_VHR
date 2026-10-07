/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50020Service.java
 * @Desc    : 공휴일 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 23.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50020.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50020.service.LGVATT50020Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 23. 오전 9:00:58
 * @Version
 */
public interface LGVATT50020Service {
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveHoliday
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHoliday(LGCOMData param);
	
	/**
	 * Desc : Holiday attendance를 조회한다.
	 * @Method Name : retrieveHolidayAttendance
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHolidayAttendance(LGCOMData param);
	
	/**
	 * Desc : 공휴일의 휴일명을 조회한다.
	 * @Method Name : retrieveHolidayNameList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveHolidayNameList(LGCOMData param);
	
	/**
     * Desc : 공휴일을 저장한다.
     * @Method Name : saveHolidayManage
     * @param  param
     * @throws Exception
     */
    public void saveHolidayManage(LGCOMData param);
    
    /**
     * Desc : Calculate Attendance.
     * @Method Name : calculateAttendance
     * @param  param
     * @throws Exception
     */
    public void calculateAttendance(LGCOMData param);

}
