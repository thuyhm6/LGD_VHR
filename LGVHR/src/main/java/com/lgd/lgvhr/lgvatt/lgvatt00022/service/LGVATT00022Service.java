package com.lgd.lgvhr.lgvatt.lgvatt00022.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT00022Service.java
 * @Desc    : Create Request for OS KPI
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2026.04.01  HMT_20260401    Writing the first program
 *------------------------------------------------------------------------------
 */
public interface LGVATT00022Service {
	
	/**
	 * Search for information to enter in the common master - LGCOM_APPROVAL_REQUEST_CODE.
	 * @param param
	 * @return LGCOMData
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveInitData(LGCOMData param) throws LGCOMException;
	
	/**
	 * retrieve OS KPI
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveOsKPI(LGCOMData param) throws LGCOMException;	
	
	public LGCOMData retrieveVendorList(LGCOMData param);
	
	
	/**
	 * Attendance manager organization search service using employee number
	 * @param param
	 * @return LGCOMData
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveAttContractOrg(LGCOMData param) throws LGCOMException;
	
	/**
	 * Search for functional personnel in the organization to which the attendance manager belongs
	 * @param param
	 * @return LGCOMData
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveAttContractOrgLineWorkerList(LGCOMData param) throws LGCOMException;
	
	/**
	 * shift_type 과 nightFlag 가져오기
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveKpiOsStandard(LGCOMData param) throws LGCOMException;
	
	
	/**
	 * save OS KPI
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public void saveOsKPI(LGCOMData param) throws LGCOMException;
	
	
	/**
	 * 있는 데이터 헤더 정보 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveHeaderInfo(LGCOMData param) throws LGCOMException ;
	
	/**
	 * 통합 결재 요청 처리
	 * @param param
	 * @throws LGCOMException
	 */
	public void saveApprovalRequest(LGCOMData param) throws LGCOMException ;
	
	/**
	 * 통합 결재 처리
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public void saveRequestApprovalOrReject(LGCOMData param) throws LGCOMException;
	
	/** 사번으로 이름 가져오기
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveEmployeeName(LGCOMData param) throws LGCOMException;
	
	/**
	 * 조직으로 사번 가져오기
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveEmployeeNo(LGCOMData param) throws LGCOMException;
	
	/**
	 * 공통결재 승인완료 또는 반려 여부 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveApprovalStatus(LGCOMData param) throws LGCOMException;
	
	/**
	 * 중복 데이터 유무 체크
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveDupData(LGCOMData param) throws LGCOMException;

	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param);
	
	/**
	 * retrieveARMInfoWithHRLead
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveARMInfoWithHRLead(LGCOMData param) throws LGCOMException;
}
