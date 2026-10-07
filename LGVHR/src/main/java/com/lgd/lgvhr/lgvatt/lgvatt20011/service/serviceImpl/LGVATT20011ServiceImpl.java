/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20011ServiceImpl.java
 * @Desc    : 일근태 계획/실적 저장 및 승인요청
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
package com.lgd.lgvhr.lgvatt.lgvatt20011.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt20011.service.LGVATT20011Service;
import com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTCOMMService;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20011.service.serviceImpl.LGVATT20011ServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 10. 19. 오후 3:48:12
 * @Version
 */
@Service("LGVATT20011Service")
public class LGVATT20011ServiceImpl implements LGVATT20011Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20011ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
    @Resource(name="LGVATTCOMMService")
    private LGVATTCOMMService lgvattcomm;

	/**
	 * Desc : 화면에 필요한 기본정보를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 */
	public LGCOMData retrieveInitData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		result.set( "baseInfo", this.commonDao.select("LGVATT20011.retrieveBaseInfo", param) );
		result.set( "employeeData", this.commonDao.select("LGVATTCOMM.retrieveEmployee", param) );
		result.set( "reqDocBaseInfo", this.commonDao.select("LGVATT20011.retrieveRequestDocBaseInfo", param) );
		result.set( "planList", this.commonDao.selectList("LGVATT20011.retrieveDailyAttendancePlanList", param) );
		result.set( "resultList", this.commonDao.selectList("LGVATT20011.retrieveDailyAttendanceResultList",param) );
		return result;
	}
	
	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		return this.commonDao.select("LGVATT20011.retrieveRequestDocBaseInfo", param);
	}

	/**
	 * Desc : 근태입력 마감시간 조회
	 * @Method Name : retrieveBaseInfo
	 * @param  param
	 */
	public LGCOMData retrieveBaseInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT20011.retrieveBaseInfo", param);
	}
	
	/**
	 * Desc : 일근태 계획을 조회한다.
	 * @Method Name : retrieveDailyAttendancePlanList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendancePlanList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20011.retrieveDailyAttendancePlanList",param);
	}

	/**
	 * Desc : 일근태 계획을 저장한다.
	 * @Method Name : saveDailyAttendancePlanList
	 * @param  param
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void saveDailyAttendancePlanList(LGCOMData param) {		
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
        LOGGER.debug("param = " + param);
        
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
        LOGGER.debug(uList);
        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
            item.put("LGVHR_PROJECT_SESSION", projectSession);
            item.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);
            this.commonDao.update("LGVPAY10001.updateAttendancePlan",item);
        }
	}

	/**
	 * Desc : 일근태 실적을 조회한다.
	 * @Method Name : retrieveDailyAttendanceResultList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceResultList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20011.retrieveDailyAttendanceResultList",param);
	}
	
	/**
	 * Desc : 일근태 계획과 실적 건별로 결재요청한다.
	 * - 화면에서 전달된 사번과 세션 사번이 동일한지 체크
	 * - 일근태 요청 가능시간인지 체크
	 * - 화면에서 전달된 요청코드와 결재화면(사무직 일근태 결재요청)의 요청코드가 동일한지 체크
	 * - 결재자 정보에 재량권 결재자가 있는지 체크
	 * - 이미 요청된 건인지 체크
	 * - 계획근태일 별 계획 근태 등록
	 * - 계획근태 요청정보 저장하기 위해 공통 결재정보 입력 메서드 호출(insertCommonApprovalRequest)
	 *   - 공통 결재 마스터 등록
	 *   - 공통 결재자 등록
	 *   - 공통 결재요청 프로시저 호출
	 * - 계획근태 테이블에 요청서아이디, 요청코드, 진행상태 반영
	 * - 계획근태에 연차(AL,HL)근태 등록했는지 여부 체크. 마지막에 잔여연차 체크 및 연차 반영하기 위한 체크임.
	 * - 이미 요청된 건인지 체크
	 * - 실적근태일 별 실적 근태 등록
	 * - 실적근태 요청정보 저장하기 위해 공통 결재정보 입력 메서드 호출(insertCommonApprovalRequest)
	 *   - 공통 결재 마스터 등록
	 *   - 공통 결재자 등록
	 *   - 공통 결재요청 프로시저 호출
	 * - 실적근태 테이블에 요청서아이디, 요청코드, 진행상태 반영
	 * - 실적근태에 연차(AL,HL)근태 등록했는지 여부 체크. 마지막에 잔여연차 체크 및 연차 반영하기 위한 체크임.
	 * @Method Name : insertDailyAttendanceApprovalRequest
	 * @param  LGCOMData
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public LGCOMData insertDailyAttendanceApprovalRequest(LGCOMData param) {
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
        LGCOMData resultData = new LGCOMData();
        boolean anualLeaveCheckFlag = false;//연차체크 해야할지 여부
        LOGGER.debug("param = " + param);
                
        LGCOMData masterData = (LGCOMData)param.get("master");

        //전달된 사번과 세션 사번이 다른 경우 저장 불가능 체크
        LGCOMData validEmployeeData = this.commonDao.select("LGVATT20011.retrieveValidateRequestEmployee", param);
        if ( !NullUtil.isNull(validEmployeeData) && "N".equals(validEmployeeData.getString("requestEnableFlag")) ) {
        	//해당 작업을 위한 권한이 없습니다.
	        throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
        }
        
        //일근태 입력 가능시간인지 체크
        LGCOMData baseInfo = this.commonDao.select("LGVATT20011.retrieveBaseInfo", param);
        if ( !NullUtil.isNull(baseInfo) && !"Y".equals(NullUtil.nvl(baseInfo.getString("inputEnableTimeFlag"), "")) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.att.dailyAttendanceInputTime", StringUtil.split(baseInfo.getString("inputEndTime"), "")));
        }
        
		//요청서구분코드로 요청구분코드 조회
		LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
		
		if ( NullUtil.isNull(reqDocBaseInfo) 
				|| NullUtil.isNull(masterData)
				|| NullUtil.isNull(masterData.getString("requestCode"))
				|| (NullUtil.notNone(reqDocBaseInfo.getString("requestCode")) && !masterData.getString("requestCode").equals(reqDocBaseInfo.getString("requestCode"))) ) {
        	LOGGER.error("requestCode is different!!!!(PARAM:"+NullUtil.nvl(masterData.getString("requestCode"), "")+", ORI:"+NullUtil.nvl(reqDocBaseInfo.getString("requestCode"), "")+")");
        	//해당 작업을 위한 권한이 없습니다.
	        throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
	        
		} else {
			//화면에서 전달된 값을 사용하지 않고, 조회한 값을 요청코드로 재 셋팅한다.
			masterData.set("requestCode", reqDocBaseInfo.get("requestCode"));
			
	        //재량권 결재자가 결재자에 포함되어 있는지 체크
	        if ( retrieveValidateARMApprovalList(param, reqDocBaseInfo) ) {
        
		        LGCOMData approvalMasterData = new LGCOMData();// 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회
		        List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");//결재자 리스트
		        
		        /* 계획수정건 저장 */
				List<LGCOMData> planList = (List<LGCOMData>)param.get("planList");
		        for( LGCOMData item : LGCOMUtils.emptyIfNull(planList) ) {
		            item.put("LGVHR_PROJECT_SESSION", projectSession);
		            item.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);
		            item.put("employeeNo", masterData.getString("employeeNo"));
		            
		        	//기요청건인지 체크
		        	if ( !retrieveValidateRequestFlag(item, "PLAN") ) {
			        	//계획근태 저장
			            this.commonDao.update("LGVATT20011.updateAttendancePlan",item);
			
			            /* 계획근태 데이터 저장 후 공통 결재 테이블 등록 및 계획근태 데이터 후처리 start */
			            //공통 결재정보 입력 메서드 호출
			            approvalMasterData = insertCommonApprovalRequest(item, masterData, approvalList);
			            if ( "OK".equals(approvalMasterData.getString("retCode")) ) {//공통 결재 처리 정상 인 경우 업무 테이블에 진행상태 반영
					        item.put("approvalMasterData", approvalMasterData);
					        //계획근태에 결재요청아이디, 진행상태 반영
					        this.commonDao.update("LGVATT20011.updateAttendancePlanApprovalInfo",item);
			            }
			            
			            //근태코드가 연차(AL,HL)인 경우 마지막에 연차 체크 및 반영 호출
			            // 2018.02.28 : 반일휴가제 도입으로 반일휴가 로직 추가 
			            if ( anualLeaveCheckFlag == false && 
			            		( "AL".equals(item.getString("attendanceCode")) || 
			            		  "HL".equals(item.getString("attendanceCode")) || 
			            		  "HL_FN".equals(item.getString("attendanceCode")) || 
			            		  "HL_SN".equals(item.getString("attendanceCode")) ) ) {
			            	LOGGER.debug("계획 연차!!");
			            	anualLeaveCheckFlag = true;
			            }
			            /* 계획근태 데이터 저장 후 공통 결재 테이블 등록 및 계획근태 데이터 후처리 end */
		        	}
		        }
		        
		        LOGGER.debug("계획 연차 여부 체크 : " + anualLeaveCheckFlag);
		        
		        /* 실적입력,수정건 저장 */
		        List<LGCOMData> resultList = (List<LGCOMData>)param.get("resultList");
		        for( LGCOMData item : LGCOMUtils.emptyIfNull(resultList) ) {
		            item.put("LGVHR_PROJECT_SESSION", projectSession);
		            item.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);
		            item.put("employeeNo", masterData.getString("employeeNo"));
		            
		        	//기요청건인지 체크
		        	if ( !retrieveValidateRequestFlag(item, "RESULT") ) {
			        	/* 입력, 수정 구분 */
			        	LGCOMData existsData = this.commonDao.select("LGVATT20011.retrieveResultExistsFlag", item);
			            if ( "N".equals(existsData.getString("existsFlag")) ) {//신규
			                this.commonDao.insert("LGVATT20011.insertAttendanceResult",item);
			            } else {//수정
			                this.commonDao.update("LGVATT20011.updateAttendanceResult",item);
			            }
			            
			            /* 실적근태 데이터 저장 후 공통 결재 테이블 등록 및 실적근태 데이터 후처리 start */
			            //공통 결재정보 입력 메서드 호출
			            approvalMasterData = insertCommonApprovalRequest(item, masterData, approvalList);
			            if ( "OK".equals(approvalMasterData.getString("retCode")) ) {//공통 결재 처리 정상 인 경우 업무 테이블에 진행상태 반영
					        item.put("approvalMasterData", approvalMasterData);
			   		        //실적근태에 결재요청아이디, 진행상태 반영
			                this.commonDao.update("LGVATT20011.updateAttendanceResultApprovalInfo",item);
			            }
			            
			            //근태코드가 연차(AL)인 경우 마지막에 연차 체크 및 반영 호출
			            // 2018.02.28 : 반일휴가제 도입으로 반일휴가 로직 추가 
			            
			            if ( anualLeaveCheckFlag == false && 
			            		( "AL".equals(item.getString("attendanceCode")) || 
			            		  "HL".equals(item.getString("attendanceCode")) || 
			            		  "HL_FN".equals(item.getString("attendanceCode")) || 
			            		  "HL_SN".equals(item.getString("attendanceCode")) ) ) {
			            	LOGGER.debug("실적 연차!");
			            	anualLeaveCheckFlag = true;
			            }
			            /* 실적근태 데이터 저장 후 공통 결재 테이블 등록 및 실적근태 데이터 후처리 end */
		        	}
		        }
		
		        LOGGER.debug("계획/실적 연차 여부 체크 : " + anualLeaveCheckFlag);
		
		        /*
		         * 잔여휴가 체크 및 연차반영
		         * [IN PARAMETER]
		         * - sessionAppUserId   : [필수] 로그인 사용자 application_user_id. who 컬럼 저장시 사용
		         * - attType            : [필수] 체크유형코드. INPUT:근태입력, APPROVAL:근태결재, UPD_REQ:수정요청서 요청, UPD_APPR:수정요청서 결재, LT_TA_REQ:장기근태계획 요청, LT_TA_APPR:장기근태계획 결재
		         * - subsidiaryCode     : [필수] 법인코드
		         * - employeeNo         : [필수] 근태 대상자 사번
		         * - languageCode       : [선택] 언어코드
		         * - attendanceYyyymmdd : [선택] 계획근태일자. DDMMYYYY. 수정요청서인 경우 파라메터 셋팅 필요 없음.
		         * [OUT PARAMETER]
		         * - retCode      : 오류 코드. 0:정상, 그외:오류
		         * - errorMessage : 오류 메세지코드.
		         */
		        if ( anualLeaveCheckFlag ) {//입력한 계획 및 실적근태에 연차(AL,HL)이 있는 경우 잔여휴가 체크 및 연차반영하기 위해 마지막에 한번 호출함.
			        LGCOMData tempData = new LGCOMData();
			        tempData.put( LGCOMConstants.HTTP_SESSION_KEY, userSession);
			        tempData.put( "LGVHR_PROJECT_SESSION",  projectSession);
			        tempData.put( "newInputResultAttCode", resultList.get(0).getString("attendanceCode"));
			        tempData.put( "newInputPlanAttCode", planList.get(0).getString("attendanceCode"));
			        tempData.put( "employeeNo", masterData.getString("employeeNo"));
			        tempData.put( "isPicUser", masterData.getString("isPicUser"));
			        saveAnualLeaveNValidate(tempData);
		        }
	        }//end - if ( retrieveValidateARMApprovalList(param, reqDocBaseInfo) ) {
		}//end - if ( NullUtil.isNull(reqDocBaseInfo) || NullUtil.isNull(masterData)
        return resultData;
	}
	
	/**
	 * Desc : 공통 결재 요청 처리
	 * - 결재요청아이디 시퀀스 조회
	 * - 결재요청아이디로 요청번호 생성 및 시스템코드, 모듈코드, 요청제목 등 조회
	 * - 공통 결재 마스터 등록
	 * - 공통 결재 결재자 등록
	 * - 공통 결재요청 프로시저 호출
	 * 
	 * @Method Name : insertCommonApprovalRequest
	 * @param  item : 계획 또는 실적 일자별 데이터
	 * @param  masterData : 요청자 정보
	 * @param  approvalList : 결재자 리스트
	 */
	private LGCOMData insertCommonApprovalRequest(LGCOMData item, LGCOMData masterData, List<LGCOMData> approvalList) {
		LGCOMData requestMasterIdData = new LGCOMData();//결재요청아이디 시퀀스 조회
        LGCOMData approvalMasterData = new LGCOMData();// 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회
        LGCOMData userSession = item.getData(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = item.getData("LGVHR_PROJECT_SESSION");
		
        // 결재요청아이디 시퀀스 조회
        requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
        
        if ( NullUtil.isNull(requestMasterIdData) ) {//요청아이디 정보가 없는 경우
        	LOGGER.error("error occured retrieve reqeust_master_id Data !!!!");
        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
        	
        } else if ( NullUtil.isNone(requestMasterIdData.getString("requestMasterId")) ) {//조회한 요청아이디가 없는 경우 오류 처리
        	LOGGER.error("error occured retrieve reqeust_master_id!!!!");
        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
        	
        } else {
	        requestMasterIdData.set( "LGVHR_PROJECT_SESSION", projectSession );
	        requestMasterIdData.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        requestMasterIdData.set( "master", masterData );
	        
	        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회
	         * [IN PARAMETER]
	         * - requestMasterId           : 요청서 일련번호. 정보 조회시마다 생성되지 않도록, 사용자가 조회한 시퀀스 값으로 셋팅함. 
	         * - USER_SESSION.defaultOrgId : 세션의 OU_ID
	         * - requestorId               : 요청자 application_user_id. 대리입력을 제외하고는 USER_SESSION.applicationUserId
	         * - approvalMenuId            : 결재요청하는 화면 프로그램 ID
	         * - requestCode               : 요청서 코드
	         * - master.approvalMenuId     : 결재요청하는 화면 프로그램 ID(master 객체에 값이 있는 경우 사용됨)
	         * - master.requestCode        : 요청서 코드(master 객체에 값이 있는 경우 사용됨)
	         * - USER_SESSION.languageCode : 세션의 언어코드
	         */
	        
	        requestMasterIdData.set( "requestorId", userSession.get("applicationUserId"));//본인 신청이므로 세션 사용자아이디 셋팅
	        approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", requestMasterIdData);
	        
	        if ( NullUtil.isNull(approvalMasterData) ) {//결재요청하기 위한 요청기본정보 데이터가 없는 경우
	        	LOGGER.error("error occured retrieve approvalMasterData!!!!");
	        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata"));
	        	
	        } else {// 데이터가 없는 경우 처리하지 않음
		        /* 공통 결재마스터 테이블 등록
		         * [IN PARAMETER]
		         *  : LGVATTCOMM.retreiveRequestBasicInfo 를 조회하여 생성된 데이터 셋으로 처리 함.
		         * - requestMasterId : 요청서 일련번호. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - requestCode     : 요청서 코드. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - ouId            : Operating Unit Id. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - requestNo       : 결재화면에서 보여줄 요청서번호. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - systemCode      : 시스템코드. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - moduleCode      : 모듈코드. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - requestTitle    : 요청서 제목. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - commentContent  : 요청의견. 현재는 requestTitle 과 동일함. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - requestorDepartmentCode : 요청자 부서코드. 현재는 NULL
		         * - requestorId     : 요청자 application_user_id. 요청기본정보에서 조회된 결과셋에 있는 값
		         * - attachFileId    : 첨부파일 아이디. 현재는 NULL
		         * [OUT PARAMETER]
		         * - retCode         : 오류코드. OK - 정상, 그외 - 오류
		         * - errorMessage    : 오류메세지. 
		         */
		        this.commonDao.select("LGVATTCOMM.insertApprovalMaster", approvalMasterData);
	            
				if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
					throw new LGCOMException( approvalMasterData.getString("errorMessage") );
				}
		        
		        /* 공통 결재상태 테이블에 결재자 등록 */
		        for( LGCOMData approvalItem : LGCOMUtils.emptyIfNull(approvalList) ) {    	      
		        	approvalItem.put("sessionAppUserId",   userSession.get("applicationUserId"));
		        	approvalItem.put("approvalActionCode", "APPROVAL");
		        	approvalItem.put("requestMasterId",    approvalMasterData.get("requestMasterId"));
		        	approvalItem.put("requestCode",        approvalMasterData.get("requestCode"));
		        	approvalItem.put("ouId",               approvalMasterData.get("ouId"));

		        	/*
		        	 * 공통 결재상태 테이블 등록. 결재자별 등록됨.
		        	 * [IN PARAMETER]
		        	 * - requestMasterId : 요청서 일련번호. 요청기본정보 결과셋 값을 재 셋팅.
		        	 * - requestCode     : 요청서 코드. 요청기본정보 결과셋 값을 재 셋팅.
		        	 * - ouId            : Operating Unit Id. 요청기본정보 결과셋 값을 재 셋팅.
		        	 * - employeeNo      : 결재자 사번. 화면에서 전달된 결재자 사번.
		        	 * - approvalActionCode : 결재자 유형. REQUEST - 요청자(1차 결재자 등록시 자동 입력됨), APPROVAL - 결재자, REFERENCE - 참조자, FORWARD - 전달
		        	 * - positionName    : 결재자 직책명
		        	 * - settlementDeleteFlag : 재량권 결재자 여부. Y-재량권 결재자, N-직접등록한 결재자.
		        	 * - sessionAppUserId : application_user_id. Who column 에서 사용. 1차결재자 등록인 경우 자동 등록되는 요청자 정보로도 사용됨.
		        	 * [OUT PARAMETER]
		        	 * - retCode         : 오류코드. OK - 정상, 그외 - 오류
		        	 * - errorMessage    : 오류메세지. 
		        	 */
		            this.commonDao.select("LGVATTCOMM.insertApprovalLine",approvalItem);
		            
					if( !"OK".equals( approvalItem.getString("retCode") ) ) {
						throw new LGCOMException( approvalItem.getString("errorMessage") );
					}
		        }
		        
	        	approvalMasterData.set("sessionAppUserId",userSession.get("applicationUserId"));
	        	approvalMasterData.set("approvalCommand", "REQUEST");
    	        /* 공통 결재요청 프로시저 호출
    	         * [IN PARAMETER]
    	         *  : LGVATTCOMM.retreiveRequestBasicInfo 를 조회하여 생성된 데이터 셋으로 처리 함.
    	         * - approvalCommand  : 요청유형. REQUEST - 결재요청, APPROVAL - 승인, REJECT - 반려
    	         * - requestMasterId  : 요청서 일련번호. 요청기본정보에서 조회된 결과셋에 있는 값
    	         * - requestCode      : 요청서 코드. 요청기본정보에서 조회된 결과셋에 있는 값
	        	 * - sessionAppUserId : 처리자 application_user_id. 요청-요청자, 결재-결재자
    	         * - comment          : 결재의견
    	         * - portalFlag       : 통합결재 연동여부. Y-연동, N-연동안함. 요청기본정보에서 조회된 결과셋에 있는 값
    	         * - mailFlag         : 통합결재 메일발송여부. Y-통합결재 메일 발송, N-메일발송안함. 요청기본정보에서 조회된 결과셋에 있는 값
    	         * [OUT PARAMETER]
    	         * - retCode         : 오류코드. OK - 정상, 그외 - 오류
    	         * - errorMessage    : 오류메세지. 
    	         */
	        	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", approvalMasterData);
				if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
					throw new LGCOMException( approvalMasterData.getString("errorMessage") );
				}
	        }
        }
        return approvalMasterData;
	}

	/**
	 * Desc : 잔여휴가 체크 및 연차 처리
	 * 
	 * - 일근태입력/결재 : 근태코드 = 'AL','HL' 일때만 호출
	 * - 수정요청서 요청/결재 : NEW 근태코드 = 'AL','HL' 일때만 호출
	 * - 장기계획근태 : 근태코드 = 'AL','HL' 일때만 호출
	 * 
     * [IN PARAMETER]
     * - sessionAppUserId   : [필수] 로그인 사용자 application_user_id. who 컬럼 저장시 사용
     * - attType            : [필수] 체크유형코드. INPUT:근태입력, APPROVAL:근태결재(일근태는 반려 시 연차 처리되어야 하므로 사용 안함), REJECT:근태반려, UPD_REQ:수정요청서 요청, UPD_APPR:수정요청서 결재, LT_TA_REQ:장기근태계획 요청, LT_TA_APPR:장기근태계획 결재
     * - subsidiaryCode     : [필수] 법인코드
     * - employeeNo         : [필수] 근태 대상자 사번. LIne Worker 수정요청서일때 NULL
     * - languageCode       : [선택] 언어코드
     * - attendanceYyyymmdd : [선택] 계획근태일자. DDMMYYYY. Plan 기준의 (오늘)일자
     * - requestNo          : [선택] Line Worker 수정요청서 번호
     * - empCat             : [선택] 사무직 요청인 경우 LGD_OW 넘김
     * [OUT PARAMETER]
     * - retCode      : 오류 코드. 0:정상, 그외:오류
     * - errorMessage : 오류 메세지코드.
     * [사용예제]
     * -- OW/LW 일근태입력:승인요청 후 한번만 처리
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'INPUT', 'LGDVN', 'VH123456', 'en', NULL, NULL, 'LGD_OW');
     * 
     * -- OW/LW 일근태반려:사람별, 실적에 대해서 loop에서 처리
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'REJECT', 'LGDVN', 'VH123456', 'en', NULL, NULL);
     * 
     * -- OW 수정요청서 요청:승인요청 후 한번만 처리
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'UPD_REQ', 'LGDVN', 'VH123456', 'en', NULL,'LGVHR-ATT-10004-1320', 'LGD_OW');
     * 
     * -- OW 수정요청서 결재:결재 처리 후 한번만 호출
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'UPD_APPR', 'LGDVN', 'VH123456', 'en', NULL, 'LGVHR-ATT-10004-1320', 'LGD_OW');
     * 
     * -- LW 수정요청서 요청
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'UPD_REQ', 'LGDVN', NULL, 'en', NULL, 'LGVHR-ATT-10003-1319');
     * 
     * -- LW 수정요청서 결재
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'UPD_APPR', 'LGDVN', NULL, 'en', NULL, 'LGVHR-ATT-10003-1319');
     * 
     * -- OW/LW 장기근태계획 요청
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'LT_TA_REQ', 'LGDVN', 'VH123456', 'en', NULL, NULL);
     * 
     * -- OW/LW 장기근태계획 결재
     * valid_att_annual_leave_proc (retCode, retMsg, '12345', 'LT_TA_APPR', 'LGDVN', 'VH123456', 'en', NULL, NULL);
	 * 
	 * @Method Name : saveAnualLeaveNValidate
	 * @param  param
	 */
	public LGCOMData saveAnualLeaveNValidate(LGCOMData param) {
        LGCOMData result = new LGCOMData();
        
		//입력한 근태코드이 휴가(AL:Annual Leave, HL: Half Day Leave)인 경우만 체크
        // 잔여휴가 체크 및 연차 처리
        result.set( "sessionAppUserId",   ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
        result.set( "attType",            "INPUT");
        result.set( "subsidiaryCode",     ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));               
        // PIC이고, 본인신청이 아닌 대리신청인 경우
        if("Y".equals(param.getString("isPicUser")) && !((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("employeeNo").equals(param.getString("employeeNo"))) {
        	result.set( "employeeNo",     param.getString("employeeNo"));
        } else {
            result.set( "employeeNo",     ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("employeeNo"));
        }
        result.set( "languageCode",       ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
        result.set( "attendanceYyyymmdd", "");//null인 경우 sysdate로 처리됨
        result.set( "empCat",             ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("employmentCategoryCode"));//로그인 사용자의 일근태 승인 요청이므로 프로젝트 세션에 있는 고용범주를 셋팅한다.
        result.set( "newInputResultAttCode", param.getString("newInputResultAttCode"));
        result.set( "newInputPlanAttCode", param.getString("newInputPlanAttCode"));

        this.commonDao.update("LGVATTCOMM.retrieveValidateAnualLeave", result);
        
        if ( !"0".equals( result.getString("retCode")) ) {//연차체크 후 부적합인 경우
        	throw new LGCOMException( messageSourceAccessor.getMessage(result.getString("errorMessage")) );
        }
        return result;
	}

	/**
	 * Desc : 재량권의 결재자가 화면에서 전달된 결재자에 있는지 확인한다.
	 * 체크로직
	 * - 재량권번호로 재량권 재조회
	 * - 재량권 결재자 건수와 재량권 결재자가 결재자 목록에 있는 건수와 동일한지 비교.
	 *   - 동일한 경우 : 결재자 정상
	 *   - 동일하지 않은 경우 : 결재자 오류
	 * @Method Name : retrieveValidateARMApprovalList
	 * @param  param
	 * @return LGCOMData
	 */
	@SuppressWarnings("unchecked")
	private boolean retrieveValidateARMApprovalList(LGCOMData param, LGCOMData reqDocBaseInfo) {
		boolean checkFlag = false;
		int cnt = 0;
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");
		if ( !NullUtil.isNull(reqDocBaseInfo) && NullUtil.notNone(reqDocBaseInfo.getString("armNo")) && !NullUtil.isNull(approvalList) && approvalList.size() > 0 ) {
			// 대리 신청의 경우 때문에 재량권 체크 또한 피신청자 기준 employeeNo
			if ( !((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("employeeNo").equals(((LGCOMData)param.get("master")).getString("employeeNo")) &&
					"Y".equals(((LGCOMData)param.get("master")).getString("isPicUser")) ) {
				param.set("employeeNo", ((LGCOMData)param.get("master")).getString("employeeNo"));
				reqDocBaseInfo.set( "ARM_PARAM", this.commonDao.select("LGVATTCOMM.retrieveEmployee", param));
			} else {
				reqDocBaseInfo.set( "ARM_PARAM", param.get("LGVHR_PROJECT_SESSION"));
			}
			List<LGCOMData> armList = this.commonDao.selectList("LGVATTCOMM.retrieveARMInfo", reqDocBaseInfo);
			
			for ( LGCOMData armData : LGCOMUtils.emptyIfNull(armList) ) {
				for ( LGCOMData approvalData : LGCOMUtils.emptyIfNull(approvalList) ) {
					if ( NullUtil.notNone(armData.getString("employeeNo")) && armData.getString("employeeNo").equals(approvalData.getString("employeeNo")) ) {
						cnt++;
						break;
					}
				}
			}
			
			//재량권 결재자 건수와 재량권 결재자가 포함된 건수가 동일하면 정상으로 본다.
			if ( cnt == armList.size() ) {
				checkFlag = true;
			} else {
				throw new LGCOMException(messageSourceAccessor.getMessage("note.att.noApprover"));//결재자가 아닙니다.
			}
			
		} else if ( !NullUtil.isNull(reqDocBaseInfo) && NullUtil.isNone(reqDocBaseInfo.getString("armNo")) ) {//재량권 사용하지 않는 경우
			checkFlag = true;
		}
		return checkFlag;
	}
	
	/**
	 * 계획근태 또는 실적근태가 결재요청되었는지 체크
	 * - 계획근태
	 *   - 해당 일자의 계획근태가 이미 결재요청되었는지 체크
	 * - 실적근태
	 *   - 해당 일자의 실적근태가 이미 결재요청되었는지 체크
	 *   - 실적근태 전달된 파라메터의 OT값과 Total OT로 게산한 OT값이 동일한지 비교 
	 * 
	 * @Method Name : retrieveValidateRequestFlag
	 * @param item
	 * @param planResultCode : PLAN-계획, RESULT-실적
	 * @return
	 */
	private boolean retrieveValidateRequestFlag(LGCOMData item, String planResultCode) {
		boolean requestFlag = false;
		LGCOMData flagData = new LGCOMData();
		
		if ( NullUtil.notNone(planResultCode) && !NullUtil.isNull(item) ) {
			if ( "PLAN".equals(planResultCode) ) {//계획인 경우
				flagData = this.commonDao.select("LGVATT20011.retrieveAttendancePlanRequestFlag", item);
			} else if ( "RESULT".equals(planResultCode) ) {//실적인 경우
				flagData = this.commonDao.select("LGVATT20011.retrieveAttendanceResultRequestFlag", item);
			}

			if ( NullUtil.isNull(flagData) ) {
				LOGGER.error("requestFlag Data is Null!");
				throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
				
			} else if ( "Y".equals(flagData.getString("requestFlag")) ) {//이미 요청된 경우
				requestFlag = true;
				LOGGER.error("requestFlag is 'Y'");
				throw new LGCOMException ( messageSourceAccessor.getMessage("note.att.alreadyRequest") );
				
			} else if ( "RESULT".equals(planResultCode) ) {//실적인 경우
				
	        	//전달된 파라메터의 OT값과 Total OT로 계산한 OT값이 동일한지 비교
	        	String errorMessage = lgvattcomm.retrieveCompareOT(item);
	        	if ( NullUtil.notNone(errorMessage) ) {
					throw new LGCOMException ( errorMessage );
	        	}
			}
			 
		}
		return requestFlag;
	}
}
