/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTCOMMService.java
 * @Desc    : 근태 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvattcommon.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTCOMMService.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 18. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATTCOMMService {
	
	/**
	 * Desc : 근태유형 목록을 조회한다.
	 * @Method Name : retrieveAttendanceTypeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceTypeList(LGCOMData param);
	
	/**
	 * Desc : 근태코드 목록을 조회한다.
	 * @Method Name : retrieveAttendanceCodeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceCodeList(LGCOMData param);

	/**
	 * Desc : 근태유형, 근태코드 목록을 조회한다.
	 * @Method Name : retrieveAttendanceCodeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public LGCOMData retrieveAttendanceTypeNCodeList(LGCOMData param);

	/**
	 * Desc : 출근시간을 조회한다.
	 * @Method Name : retrieveWorkStartTimeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveWorkStartTimeList(LGCOMData param);
	
	/**
	 * Desc : 주어진 조건에 따라 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployee
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveEmployee(LGCOMData param);

	/**
	 * Desc : 근무일, 교대유형, Day/Night구분, 석식여부, 근무시작시간, 입력한 OT에 따라 지급비율이 다른 OT를 자동 계산한다.
	 * @Method Name : processCalculateOT
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData processCalculateOT(LGCOMData param);
	
	/**
	 * Desc : 요청서 작성 시 필요한 기본정보를 조회한다.(재량권 번호, 요청서번호)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param);

	/**
	 * Desc : 재량권 정보를 조회한다.
	 * @Method Name : retrieveARMInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveARMInfo(LGCOMData param);
	
	/**
	 * Desc : 승인 정보를 조회한다.
	 * @Method Name : retrieveApproverList
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveApproverList(LGCOMData param);
	
	/**
	 * 근대관리 월간 리포트 생성(Excel)
	 * @param param
	 * @return
	 * @author kikimans
	 */
	public List<LGCOMData> createExcelMonthReport(LGCOMData param);

	/**
	 * Desc : 전달된 파라메터의 OT값과 Total OT로 계산한 OT값이 동일한지 비교
	 * @Method Name : retrieveCompareOT
	 * @param  param
	 * @return String
	 */
	public String retrieveCompareOT(LGCOMData param);
	
	/**
	 * Desc : 전체 조직 리스트를 벨류셋형식으로 가져온다.
	 * @Method Name : retrieveAllOrgList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAllOrgList(LGCOMData param);

;}
