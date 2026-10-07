/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40010Service.java
 * @Desc    : 일근태 계획/실적 결재
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 30.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt40010.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT40010.service.LGVATT40010Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 30. 오후 8:17:00
 * @Version
 *
 */
public interface LGVATT40010Service {

	/**
	 * Desc : 결재화면에서 필요한 초기정보를 조회한다.
	 * @Method Name : retrieveRequestContent
	 * @param  param
	 * @return LGCOMData
	 */
    public LGCOMData retrieveInitData(LGCOMData param);

	/**
	 * Desc : 사무직 일근태 결재화면에서 검색조건으로 사용할 계획근태 일수를 조회한다.
	 * @Method Name : retrievePlanDateList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrievePlanDateList(LGCOMData param);
		
	/**
	 * Desc : 일근태(계획/실적)결재 목록 조회한다.
	 * @Method Name : retrieveDailyAttendanceApprovalList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceApprovalList(LGCOMData param);
	
	/**
	 * Desc : 일근태(계획/실적) 비요청자 목록 조회한다.
	 * @Method Name : retrieveDailyAttendanceUnRequestorList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceUnRequestorList(LGCOMData param);

	/**
	 * Desc : 결재 가능한 시간인지 여부를 조회한다.
	 * @Method Name : retrieveApprovalEnableTimeCheck
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveApprovalEnableTimeCheck(LGCOMData param);

	/**
	 * Desc : 일근태(계획/실적)을 승인한다.
	 * @Method Name : saveApproval
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData saveApproval(LGCOMData param);
	
	/**
	 * Desc : 일근태(계획/실적)을 반려한다.
	 * @Method Name : saveReject
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData saveReject(LGCOMData param);
	
	/**
	 * Desc : 2018.03.12 [베트남 급여근태 고도화] Let's에서 호출된 경우 팝업 호출가능한 상태인지 판단한다.
	 * @Method Name : retireveDirectOpenData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retireveDirectOpenData(LGCOMData param);
}
