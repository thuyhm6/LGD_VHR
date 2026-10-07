/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt20450Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20450.service;

import java.io.IOException;
import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.framework.model.LGCOMMap;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt20450.service.lgvatt20450Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
public interface LGVATT20450Service {
	/**
	 * Desc : 장기근태 등록 목록을 조회한다.
	 * @Method Name : retrieveMutiplanList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMutiplanList(LGCOMData param);

	/**
     * Desc : Attendance List
     * @Method Name : retrieveAttendanceList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public List<LGCOMData> retrieveAttendanceList(LGCOMData param);
	
	/**
     * Desc : Attendance Detail List
     * @Method Name : retrieveAttendanceDetailList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public List<LGCOMData> retrieveAttendanceDetailList(LGCOMData param);
	
	/**
     * Desc : Attendance Detail Message
     * @Method Name : retrieveAttendanceDetailList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public LGCOMData retrieveAttendanceDetailMessage(LGCOMData param);
	
    /**
     * Desc : 장기근태 정보을 저장한다.
     * @Method Name : saveMutipleLongPlan
     * @param  param
     * @throws Exception
     */
    public LGCOMData saveMutipleLongPlan(LGCOMData param);
    
    /**
     * Desc : 기등록된 일정여부를 조회한다.
     * @Method Name : saveMutipleLongPlan
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrievePlanChk(LGCOMData param);
    
    /**
	 * Desc : work 일수를 조회한다.
	 * @Method Name : retrieveWorkDay
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveWorkDay(LGCOMData param);
	
    /**
     * Desc : 계획시작일에 대한 계획종료일을 조회한다.
     * @Method Name : retrieveTodate
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveTodate(LGCOMData param);
    
    /**
     * Desc : 유효성체크
     * @Method Name : checkInputData
     * @param  param
     * @throws IOException 
     * @throws Exception
     */
    public LGCOMData checkInputData(LGCOMData mdata) throws IOException;
    
    /**
     * Desc : 부서 하위 직원 목록을 조회한다.
     * @Method Name : retrieveLowerEmpolyeeList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public List<LGCOMData> retrieveLowerEmpolyeeList(LGCOMData param);

	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param);
}
