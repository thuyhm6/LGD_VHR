/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20010Service.java
 * @Desc    : 사무직 월 근태 캘린더
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 17.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20010.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20010.service.LGVATT20010Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 17. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATT20010Service {
	
	/**
	 * Desc : 조직리스트를 조회한다. 조직책임자는 조직책임자 하위부서 리스트, 부서원은 소속부서
	 * @Method Name : retrieveOrgList
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveOrgList(LGCOMData param);
	
	/**
	 * Desc : 근태년월 목록과 부서원 목록을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymmNEmployeeList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymmNEmployeeList(LGCOMData param);
	
	/**
	 * Desc : 근태년월에 따른 근태일자 목록을 조회한다.
	 * @Method Name : retrieveAttendanceDateList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceDateList(LGCOMData param);
	
	/**
	 * Desc : 근태년월의 개인 일별 계획/실적 근태, 근태Summary, 휴가Summary를 조회한다.
	 * @Method Name : retrieveAttendancePlanNResultList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendancePlanNResultList(LGCOMData param);
	
	/**
	 * Desc : 해당 사번에 대한 조회권한이 있는지 체크한다.
	 * @Method Name : retrieveEmployeeEnableFlag
	 * @param  param
	 * @return LGCOMData
	 */
	public boolean retrieveEmployeeEnableFlag(LGCOMData param);
	
	/**
	 * Desc : 2018.03.12 [베트남 급여근태 고도화] Let's에서 호출된 경우 팝업 호출가능한 상태인지 판단한다.
	 * @Method Name : retireveDirectOpenData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retireveDirectOpenData(LGCOMData param);

}
