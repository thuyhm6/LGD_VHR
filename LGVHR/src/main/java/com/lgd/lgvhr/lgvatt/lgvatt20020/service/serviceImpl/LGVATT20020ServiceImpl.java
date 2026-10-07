/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20020ServiceImpl.java
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
package com.lgd.lgvhr.lgvatt.lgvatt20020.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt20020.service.LGVATT20020Service;
import com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT20020.service.serviceImpl.LGVATT20020ServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 11. 03. 오후 3:48:12
 * @Version
 */
@Service("LGVATT20020Service")
public class LGVATT20020ServiceImpl implements LGVATT20020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
    @Resource(name="LGVATTCOMMService")
    private LGVATTCOMMService lgvattcomm;

	/**
	 * Desc : 화면에서 최초 정보를 표시하기 위한 데이터를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveInitData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		LGCOMData result = new LGCOMData();
		//요청서구분코드로 요청구분코드 조회
		LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
		if ( !NullUtil.isNull(reqDocBaseInfo) ) {
			param.set( "requestCode", reqDocBaseInfo.get("requestCode"));
		}
		result.set( "reqDocBaseInfo", reqDocBaseInfo );
		result.set( "approvalMasterData", this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param) );
		
		return result;
	}
	
	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		return this.commonDao.select("LGVATT20020.retrieveRequestDocBaseInfo", param);
	}

	/**
	 * Desc : 특정일자의 실적근태를 조회한다.
	 * @Method Name : retrieveAttendanceResultData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceResultData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		
		result.put( "checkData", this.commonDao.select("LGVATT20020.retrieveModifyDateCheck", param) );
		result.put( "resultData", this.commonDao.select("LGVATT20020.retrieveAttendanceResultData", param) );
		
		return result;
	}

	/**
	 * Desc : 근태실적 수정요청서를 상신한다.
	 * @Method Name : insertModifyAttendanceApprovalRequest
	 * @param  LGCOMData
	 */
    @SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public LGCOMData insertModifyAttendanceApprovalRequest(LGCOMData param) {
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
        LGCOMData result = new LGCOMData();
        boolean anualLeaveCheckFlag = false;//연차체크 해야할지 여부

        /*
         * 수정요청서 결재요청
         * - 화면에서 전달된 요청코드와 결재화면(사무직 수정요청서)의 요청코드가 동일한지 체크
         * - 공통결재테이블에 등록할 결재요청ID 시퀀스를 조회한다. (수정요청서에 요청코드를 저장해야하므로, 선조회한다.)
         * - 결재요청에 필요한 정보를 조회한다. (수정요청서에 요청코드를 저장해야하므로, 선조회한다.)
         * - 수정요청서의 근태일자가 요청 가능한지 여부를 체크한다.
         * - 수정요청서를 저장한다.
		 * - 공통결재 마스터 테이블을 저장한다.
		 * - 재량권 결재자가 결재자 리스트에 있는지 체크
         * - 공통결재 결재자별 상태 테이블에 결재자를 저장한다.
         * - 결재요청 공통결재 프로시저를 호출한다.
         * - 수정요청서의 진행상태, 결재요청아이디, 요청코드를 수정한다.
         * - 잔여휴가 체크
         */
        LGCOMData masterData = (LGCOMData)param.get("master");
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
			
	        LGCOMData requestMasterIdData = new LGCOMData();//결재요청ID 시퀀스 조회
	        LGCOMData approvalMasterData = new LGCOMData();// 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회
	        
	        /* 계획근태 데이터 저장 후 공통 결재 테이블 등록 및 계획근태 데이터 후처리 start */
	        // 결재요청아이디 시퀀스 조회
	        requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
	
	        if ( NullUtil.isNull(requestMasterIdData) ) {//요청아이디 정보가 없는 경우
	        	LOGGER.error("error occured retrieve reqeust_master_id Data !!!!");
	        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
	        	
	        } else if ( NullUtil.isNone(requestMasterIdData.getString("requestMasterId")) ) {//조회한 요청아이디가 없는 경우 오류 처리
	        	LOGGER.error("error occured retrieve reqeust_master_id!!!!");
	        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
	        	
	        } else {
		        //재량권 결재자가 결재자에 포함되어 있는지 체크
		        if ( retrieveValidateARMApprovalList(param, reqDocBaseInfo) ) {
		        	
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
			        
			        LOGGER.debug("requestMasterIdData===>" + requestMasterIdData);
			        LOGGER.debug("approvalMasterData===>" + approvalMasterData);
			        
			        if ( NullUtil.isNull(approvalMasterData) ) {//결재요청하기 위한 요청기본정보 데이터가 없는 경우
			        	LOGGER.error("error occured retrieve approvalMasterData!!!!");
			        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata"));
			        	
			        } else {
				        /* 수정요청건 저장 */
				        List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
				        LOGGER.debug("modifyList ==>" + modifyList);
				        for ( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
				        	item.put( "LGVHR_PROJECT_SESSION", projectSession );
				            item.put( LGCOMConstants.HTTP_SESSION_KEY, userSession );
				            item.put( "approvalMasterData", approvalMasterData );
				            
					        //결재요청 가능한 상태인지 체크
					        String errorMsg = retrieveValidateRequest(item);
					        if ( NullUtil.notNone(errorMsg) ) {
					        	throw new LGCOMException(errorMsg);
					        }
				            
				            //수정요청서 저장
				            this.commonDao.insert("LGVATT20020.insertResultUpdateReqDetailList", item);
				
				            //OLD or NEW 근태코드가 연차(AL,HL)인 경우 마지막에 연차 체크 및 반영 호출
				            // 2018.02.28 : 반일휴가 추가 로 HL 조건 추가 
				            if ( anualLeaveCheckFlag == false && 
				            		( "AL".equals(item.getString("attendanceCode")) || 
				            		  "HL".equals(item.getString("attendanceCode")) || 
				            		  "HL_FN".equals(item.getString("attendanceCode")) || 
				            		  "HL_SN".equals(item.getString("attendanceCode")) ) ) {
				            	anualLeaveCheckFlag = true;
				            }
				        }
				                
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
				        List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");
				        LOGGER.debug("approvalList=>" + approvalList);
				        for( LGCOMData approvalItem : LGCOMUtils.emptyIfNull(approvalList) ) {    	      
				        	approvalItem.put("sessionAppUserId",userSession.get("applicationUserId"));
				        	
				        	approvalItem.put("approvalActionCode", "APPROVAL");
				        	approvalItem.put("requestMasterId", approvalMasterData.get("requestMasterId"));
				        	approvalItem.put("requestCode", approvalMasterData.get("requestCode"));
				        	approvalItem.put("ouId",approvalMasterData.get("ouId"));
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
				        
				        //결재요청
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
						
						//수정요청서에 공통결재요청아이디, 요청코드, 결재상태 반영
						this.commonDao.update("LGVATT20020.updateResultUpdateReqApprovalInfo", approvalMasterData);
						        
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
				        if ( anualLeaveCheckFlag ) {//수정요청서 OLD or NEW에 연차(AL), 반일휴가(HL)이 있는 경우 잔여휴가 체크 및 연차반영하기 위해 마지막에 한번 호출함.
				    		LGCOMData employeeData = this.commonDao.select("LGVATTCOMM.retrieveEmployee", param);//고용범주 조회하기 위한 조회
					        LGCOMData tempData = new LGCOMData();
					        tempData.put( LGCOMConstants.HTTP_SESSION_KEY, userSession);
					        tempData.put( "LGVHR_PROJECT_SESSION",  projectSession);
					        tempData.set( "attType", "UPD_REQ");
					        tempData.set( "employeeNo", projectSession.get("employeeNo"));
					        tempData.set( "requestNo", approvalMasterData.getString("requestNo"));
					        tempData.set( "empCat", employeeData.getString("employmentCategoryCode"));
					        saveAnualLeaveNValidate(tempData);
				        }
			        }//end - if ( NullUtil.isNull(approvalMasterData) ) {
		        }//end - if ( retrieveValidateARMApprovalList(param, reqDocBaseInfo) ) {
	        }//end - if ( NullUtil.isNull(requestMasterIdData) ) {
		}
        return result;
    }
    
	/**
	 * Desc : 수정요청 작성한 건별 결재요청 가능 여부 체크
	 * - 수정요청 작성한 근태일이 근태마감일 전인지 체크
	 * - 전달된 파라메터의 OT값과 Total OT로 계산한 OT값이 동일한지 비교
	 * 
	 * @Method Name : retrieveValidateRequest
	 * @param data
	 */
	private String retrieveValidateRequest(LGCOMData param) {
		LGCOMData resultData = new LGCOMData();
        LOGGER.debug("param ===>" + param);
        /*
         * 수정요청 가능한 날짜, 시간인지 체크
         * [PARAMETER]
         * - subsidiaryCode : 로그인 사용자 법인코드
         * - yyyymmdd : 계획근태일자. FORMAT - DDMMYYYY
         */
        LGCOMData tempData = new LGCOMData();
        tempData.set( "subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
        tempData.set( "yyyymmdd", param.getString("attendanceYyyymmdd"));
        resultData = this.commonDao.select("LGVATT20020.retrieveRequestEnableTimeCheck", tempData);
        
        if ( NullUtil.isNull(resultData) || !"Y".equals(NullUtil.nvl(resultData.getString("requestEnableFlag"), "")) ) {
        	return messageSourceAccessor.getMessage("note.att.attendanceYyyymmClose");//이미 마감되었습니다.
        	
        } else if ( "NEW".equals(param.getString("dataOldNewTypeCode")) ) {//수정 건인 경우 체크
        	//전달된 파라메터의 OT값과 Total OT로 계산한 OT값이 동일한지 비교
        	return lgvattcomm.retrieveCompareOT(param);
        	
        }
        return null;
	}
	
	/**
	 * Desc : 사무직 수정요청서 요청내용 조회한다. 
	 * @Method Name : retrieveResultUpdateReqList
	 * @param  List<LGCOMData>
	 */
	public List<LGCOMData> retrieveResultUpdateReqList(LGCOMData param) {
		return this.commonDao.selectList("LGVATT20020.retrieveResultUpdateReqList", param);
	}

	/**
	 * Desc : 사무직 수정요청서를 승인 또는 반려한다. 
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  LGCOMData
	 */
	@Transactional(propagation=Propagation.REQUIRED)
	public LGCOMData saveRequestApprovalOrReject(LGCOMData param) {
		LGCOMData result = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
        
        /*
         * 수정요청서 승인 또는 반려 처리
         * - 요청서아이디, 요청서코드, 승인/반려구분코드 유무 체크
         * - - 화면에서 전달된 요청코드와 결재화면(사무직 수정요청서)의 요청코드가 동일한지 체크
         * - 결재자인지 체크, 결재 가능한 상태인지 체크
         * - 통합결재 연동여부, 메일발송여부 조회
         * - 공통 결재 프로시저 호출 하여 승인 또는 반려 처리
         * - 수정요청서에 결재 상태 반영
         * - 승인완료인 경우 수정요청서 내용을 근태실적 테이블에 반영하는 프로시저 호출
         * - 승인완료인 경우 수정요청서에 연차(AL), 반일휴가(HL)이 있으면, 잔여연차 체크 및 휴가 사용 반영 프로시저 호출 
         */
        
        //요청서 아이디 또는 요청서 코드 또는 결재/반려 구분코드가 없는 경우 오류 리턴
        if ( NullUtil.isNone(param.getString("requestMasterId")) || NullUtil.isNone(param.getString("requestCode")) 
        		|| NullUtil.isNone(param.getString("approvalCommand"))
        		|| (!"APPROVAL".equals(param.getString("approvalCommand")) && !"REJECT".equals(param.getString("approvalCommand"))) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("error.CheckRequestNo."));//승인요청번호를 확인하세요.
        }
        
		//요청서구분코드로 요청구분코드 조회
		LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
		
		//화면에서 전달된 요청코드와 결재화면의 요청코드가 동일한지 체크
		if ( NullUtil.isNull(reqDocBaseInfo) 
				|| NullUtil.isNull(param.getString("requestCode"))
				|| (NullUtil.notNone(reqDocBaseInfo.getString("requestCode")) && !param.getString("requestCode").equals(reqDocBaseInfo.getString("requestCode"))) ) {
        	LOGGER.error("requestCode is different!!!!(PARAM:"+NullUtil.nvl(param.getString("requestCode"), "")+", ORI:"+NullUtil.nvl(reqDocBaseInfo.getString("requestCode"), "")+")");
        	//해당 작업을 위한 권한이 없습니다.
	        throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
	        
		} else {
        
	        //결재자인지, 결재가능한 상태인지 체크
	        String errorMsg = retrieveValidateApproval(param);
	        if ( NullUtil.notNone(errorMsg) ) {
	        	throw new LGCOMException(errorMsg);
	        }
	        
	        /* 파라메터:requestCode, 통합결재연동여부(portal_flag)와 메일발송여부(mail_flag) 조회하기 위함 */
	        LGCOMData approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
	
	        param.set("portalFlag", approvalMasterData.get("portalFlag"));
	        param.set("mailFlag", approvalMasterData.get("mailFlag"));
	    	param.set("sessionAppUserId", userSession.get("applicationUserId"));
	    	//공통 결재 프로시저 호출
	    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
			if( !"OK".equals( param.getString("retCode") ) ) {
				throw new LGCOMException( param.getString("errorMessage") );
			}
	
			/*
			 * 수정요청서에 결재상태 반영
			 * [PARAMETER]
			 * - USER_SESSION.applicationUserId : 로그인 사용자 lgcom_user_m.application_user_id
			 * - requestMasterId : 요청마스터아이디. lgcom_approval_request_n.request_master_id
			 * - requestCode     : 요청코드. 통합결재 업무코드. lgcom_approval_request_n.request_code
			 */
			this.commonDao.update("LGVATT20020.updateResultUpdateReqApprovalStatusInfo", param);
			
			//수정요청서 승인완료 후처리
	        //공통결재 결재상태 조회
	        LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
	        LOGGER.debug("statusData====>" + statusData);
			if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("approvedFlag")) ) {//최종 승인완료인 경우
				/*
				 * 승인 완료 후처리 프로시저 호출
				 * [IN PARAMETER]
				 * - p_user_id : 실적 반영 시 WHO COLUMN 에 입력될 사용자 아이디. 로그인 사용자 USER_SESSION.applicationUserId
				 * - p_subsidiary_code : 법인코드. LGVHR_PROJECT_SESSION.subsidiaryCode
				 * - p_approval_request_id : 요청서 아이디.
				 * - p_approval_type : 결재유형. APPROVED : 결재완료, REJECT : 반려
				 */
				this.commonDao.select("LGVATTCOMM.applyAttModifyRequest", param);
	    		if( !"0".equals(param.getString("retCode")) ) {//0:성공, 그외:실패
	    			throw new LGCOMException( param.getString("errorMessage") );
	    		}
			}
			
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
			if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("approvedFlag")) ) {//최종 승인완료인 경우
				LGCOMData anualLeaveData = this.commonDao.select("LGVATT20020.retrieveAnualLeaveUseFlag", approvalMasterData);
				//승인인 경우 수정요청서 OLD or NEW에 연차(AL), 반일휴가(HL)이 있으면 잔여휴가 체크 및 연차반영하기 위해 마지막에 한번 호출함.
		        if ( "APPROVAL".equals(param.getString("approvalCommand")) && !NullUtil.isNull(anualLeaveData) && "Y".equals(anualLeaveData.getString("anualLeaveUseFlag")) ) {
		        	anualLeaveData.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);
		    		LGCOMData employeeData = this.commonDao.select("LGVATTCOMM.retrieveEmployee", anualLeaveData);//고용범주 조회하기 위한 조회
			        LGCOMData tempData = new LGCOMData();
			        tempData.put( LGCOMConstants.HTTP_SESSION_KEY, userSession);
			        tempData.put( "LGVHR_PROJECT_SESSION",  projectSession);
			        tempData.set( "attType", "UPD_APPR");
			        tempData.set( "employeeNo", anualLeaveData.get("employeeNo"));
			        tempData.set( "requestNo", approvalMasterData.getString("requestNo"));
			        tempData.set( "empCat", employeeData.getString("employmentCategoryCode"));
			        saveAnualLeaveNValidate(tempData);
		        }
			}
			
			result.set( "errorCode", "S");//성공인 경우
		}
		return result;
	}
	
	/**
	 * Desc : 결재 가능한지 여부 체크
	 * - 결재자인지, 결재 가능한 상태인지 체크
	 * - 결재가능 시간인지 체크
	 * @Method Name : retrieveValidateApproval
	 * @param param.requestMasterId    : 요청서아이디. 요청서아이디 + 요청서코드 : unique
	 *             .requestCode        : 요청서코드.
	 *             .approverEmployeeNo : 결재자 사번. 특정 결재자에 대해 체크하는 경우 값 입력.
	 *                                   값이 없는 경우 세션 사번(LGVHR_PROJECT_SESSION.employeeNo)으로 체크
	 * @return String : 오류메세지
	 */
	private String retrieveValidateApproval(LGCOMData param) {

        LOGGER.debug("param ===>" + param);
        /* 결재 상태 조회
         * [PARAMETER]
         * - requestMasterId    : 요청서아이디. 요청서아이디 + 요청서코드 : unique
         * - requestCode        : 요청서코드.
         * - approverEmployeeNo : 결재자 사번. 특정 결재자에 대해 체크하는 경우 값 입력.
         *                        값이 없는 경우 세션 사번(LGVHR_PROJECT_SESSION.employeeNo)으로 체크
         */
        LGCOMData resultData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
        
        if ( !NullUtil.isNull(resultData) ) {
        	if ( !"Y".equals(resultData.get("approverFlag")) ) {
        		return messageSourceAccessor.getMessage("note.att.noApprover");//결재자가 아닙니다.
        		
        	} else if ( !"Y".equals(resultData.get("approvalEnableFlag")) ) {
        		return messageSourceAccessor.getMessage("note.att.notInProgressStatus");//결재가능한 상태가 아닙니다. 결재문서의 진행상태를 확인해주세요.
        		
        	}
        }

        /*
         * 수정요청한 근태일자에 대해 모두 결재가능한 경우만 정상, 결재 불가능한 근태일자가 있는 경우 오류
         * [PARAMETER]
         * - requestMasterId : 결재요청아이디
         * - requestCode : 요청코드
         */
        resultData = this.commonDao.select("LGVATT20020.retrieveApprovalEnableTimeCheck", param);
        
        if ( NullUtil.isNull(resultData) || !"Y".equals(NullUtil.nvl(resultData.getString("approvalEnableFlag"), "")) ) {
        	return messageSourceAccessor.getMessage("note.att.attendanceYyyymmClose");//이미 마감되었습니다.
        }
        
        return null;
	}

	/**
	 * Desc : 잔여휴가 체크 및 연차 처리
	 * 
	 * - 일근태입력/결재 : 근태코드 = 'AL','HL' 일때만 호출
	 * - 수정요청서 요청/결재 : NEW 근태코드 = 'AL','HL' 일때만 호출
	 * - 장기계획근태 : 근태코드 = 'AL' , 'HL' 일때만 호출
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
     * -- OW/LW 일근태반려:사람별, 실적에 대해서 loop안에서 처리
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
        
		//잔여휴가 체크 및 연차 처리
        result.set( "sessionAppUserId",   ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
        result.set( "attType",            param.get("attType"));
        result.set( "subsidiaryCode",     ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
        result.set( "employeeNo",         param.get("employeeNo"));
        result.set( "languageCode",       ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
        result.set( "attendanceYyyymmdd", "");//null인 경우 sysdate로 처리됨
        result.set( "requestNo",          param.get("requestNo"));
        result.set( "empCat",             param.get("empCat"));
        result.set( "newInputResultAttCode", "");
        result.set( "newInputPlanAttCode", "");
        
        this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", result);
        
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
			reqDocBaseInfo.set( "ARM_PARAM", param.get("LGVHR_PROJECT_SESSION"));
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
}
