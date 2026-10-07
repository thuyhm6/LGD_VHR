/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20020Service.java
 * @Desc    : 사무직 일근태 수정요청서
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 03.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT20020.service.LGVATT20020Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 11. 13. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATT20020Service {
	
	/**
	 * Desc : 화면에서 최초 정보를 표시하기 위한 데이터를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 * @return LGCOMData
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
	 * Desc : 특정일자의 실적근태를 조회한다.
	 * @Method Name : retrieveAttendanceResultData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceResultData(LGCOMData param);

	/**
	 * Desc : 근태실적 수정요청서를 상신한다.
	 * @Method Name : insertModifyAttendanceApprovalRequest
	 * @param  LGCOMData
	 */
	public LGCOMData insertModifyAttendanceApprovalRequest(LGCOMData param);
	
	/**
	 * Desc : 사무직 수정요청서 요청내용 조회한다. 
	 * @Method Name : retrieveResultUpdateReqList
	 * @param  List<LGCOMData>
	 */
	public List<LGCOMData> retrieveResultUpdateReqList(LGCOMData param);
	
	/**
	 * Desc : 사무직 수정요청서를 승인 또는 반려한다. 
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  LGCOMData
	 */
	public LGCOMData saveRequestApprovalOrReject(LGCOMData param);
	

}
