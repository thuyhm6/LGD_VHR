package com.lgd.lgvhr.lgvatt.lgvatt20030.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * @author HMS
 * OT Level New&Detail
 *
 */
public interface LGVATT20030Service {

	/**
	 * 
	 * @param param
	 * @return LGCOMData
	 * @throws LGCOMException
	 */
	public LGCOMData retrieveInitData(LGCOMData param) throws LGCOMException;
	
	/**
	 * 특별 연장 근무 신청내역 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveOtLevelRequest(LGCOMData param) throws LGCOMException;	
	
	
	/**
	 * 사번으로 근태 담당자 조직 조회 서비스
	 * @param param
	 * @return LGCOMData
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveAttContractOrg(LGCOMData param) throws LGCOMException;
	
	/**
	 * 근태 담당자가 속한 조직의 기능직 인원 조회
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
	public LGCOMData retrieveOtLevelInfo(LGCOMData param) throws LGCOMException;
	
	
	/**
	 * 특별연장근무신청 저장
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public void saveOtLevelRequest(LGCOMData param) throws LGCOMException;
	
	
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
}
