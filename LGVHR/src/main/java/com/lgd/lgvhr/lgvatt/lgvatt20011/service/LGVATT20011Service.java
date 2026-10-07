/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20011Service.java
 * @Desc    : 일근태 계획 및 실적 등록 및 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 19.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20011.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20011.service.LGVATT20011Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 19. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATT20011Service {
	
	/**
	 * Desc : 화면에 필요한 기본정보를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 */
	public LGCOMData retrieveInitData(LGCOMData param);
	
	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param);
	
	/**
	 * Desc : 근태입력 마감시간 조회
	 * @Method Name : retrieveBaseInfo
	 * @param  param
	 */
	public LGCOMData retrieveBaseInfo(LGCOMData param);
	
	/**
	 * Desc : 일근태 계획을 조회한다.
	 * @Method Name : retrieveDailyAttendancePlanList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendancePlanList(LGCOMData param);
	
	/**
	 * Desc : 일근태 계획을 저장한다.
	 * @Method Name : saveDailyAttendancePlanList
	 * @param  param
	 */
	public void saveDailyAttendancePlanList(LGCOMData param);
	
	/**
	 * Desc : 일근태 실적을 조회한다.
	 * @Method Name : retrieveDailyAttendanceResultList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceResultList(LGCOMData param);

	/**
	 * Desc : 일근태 계획 및 실적을 결재요청한다.
	 * @Method Name : insertDailyAttendanceApprovalRequest
	 * @param  param
	 */
	public LGCOMData insertDailyAttendanceApprovalRequest(LGCOMData param);

}
