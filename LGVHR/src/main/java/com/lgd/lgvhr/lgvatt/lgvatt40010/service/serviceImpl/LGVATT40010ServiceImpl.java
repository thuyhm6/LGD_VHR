/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40010ServiceImpl.java
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
package com.lgd.lgvhr.lgvatt.lgvatt40010.service.serviceImpl;

import java.util.Iterator;
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
import com.lgd.lgvhr.lgvatt.lgvatt40010.service.LGVATT40010Service;
import com.lgd.lgvhr.lgvcom.lgvcommail.service.serviceImpl.LGVCOMMAILServiceImpl;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT40010.service.serviceImpl.LGVATT40010ServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 10. 30. 오후 2:42:00
 * @Version
 */
@Service("LGVATT40010Service")
public class LGVATT40010ServiceImpl extends LGVCOMMAILServiceImpl implements LGVATT40010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT40010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 결재화면에서 필요한 초기정보를 조회한다.
	 * @Method Name : retrieveRequestContent
	 * @param  param
	 * @return LGCOMData
	 */
    public LGCOMData retrieveInitData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		result.set( "planDateList", this.commonDao.selectList("LGVATT40010.retrievePlanDateList", param));//검색조건에서 사용할 계획일자 리스트
		
		return result;
    }

	/**
	 * Desc : 사무직 일근태 결재화면에서 검색조건으로 사용할 계획근태 일수를 조회한다.
	 * @Method Name : retrievePlanDateList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrievePlanDateList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40010.retrievePlanDateList", param);
	}
	
	/**
	 * Desc : 일근태(계획/실적)결재 목록 조회한다.
	 * @Method Name : retrieveDailyAttendanceApprovalList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceApprovalList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40010.retrieveDailyAttendanceApprovalList",param);
	}
	
	/**
	 * Desc : 일근태(계획/실적) 비요청자 목록 조회한다.
	 * @Method Name : retrieveDailyAttendanceUnRequestorList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDailyAttendanceUnRequestorList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40010.retrieveDailyAttendanceUnRequestorList",param);
	}

	/**
	 * Desc : 결재 가능한 시간인지 여부를 조회한다.
	 * @Method Name : retrieveApprovalEnableTimeCheck
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveApprovalEnableTimeCheck(LGCOMData param) {
		LOGGER.debug(this.getClass().getName()+ "param = " + param);
		/**
		 * [PARAMETER]
		 * - subsidiaryCode : 사용자 법인코드
		 * - YYYYMMDD : 결재 가능한 날짜인지 판단하기 위한 날짜. DDMMYYYY 형식 
		 */
		return this.commonDao.select("LGVATT40010.retrieveApprovalEnableTimeCheck", param);
	}
	
	/**
	 * Desc : 일근태(계획/실적)을 승인한다.(화면 호출용)
	 * @Method Name : saveApproval
	 * @param  param
	 * @return List<LGCOMData>
	 */
    @SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public LGCOMData saveApproval(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData infoData = (LGCOMData)param.get("infoData");
		
		/* 처리로직
		 * - 결재건 유무 체크
		 * - 결재건 loop 시작
		 *   - 계획근태 요청서번호가 있고, 결재 가능 시간인 경우 결재 처리(saveApprovalProcess)
		 *   - 실적근태 요청서번호가 있고, 결재 가능 시간인 경우 결재 처리(saveApprovalProcess)
		 * - 결재건 loop 끝
		 */
		
		/* 결재할 실적 건 */
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approvalList");
        LOGGER.debug("approvalList = " + approvalList);
        
        //결재건 없는 경우 오류 처리
        if ( NullUtil.isNull(approvalList) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.nodata"));
        }
        
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
        	//Toolip 에 대한 XSS 처리
        	//replaceXssFilter(item);
        	
            item.put("LGVHR_PROJECT_SESSION", param.get("LGVHR_PROJECT_SESSION"));
            item.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);

        	item.put( "sessionAppUserId", userSession.get("applicationUserId") );
        	item.put( "approvalCommand", "APPROVAL" );
        	item.put( "comment", infoData.get("comment") );//결재의견 셋팅
        	item.put( "infoData", infoData );//건별 결재 가능여부 체크하기 위해 사용함.
            
        	//계획근태 요청서번호가 있는 경우만 처리
        	if ( NullUtil.notNone(item.getString("requestMasterIdPlan")) && "Y".equals(item.getString("waitFlagPlan")) ) {
	            /* 계획근태 결재자 재조정. 계획과 실적이 무조건 세트인 경우는 조정이 필요했지만, 각각 결재 가능하기 떄문에 조정 필요 없음. */
	            //updatePlanApproverLine(item);
	            /* 계획근태 결재 */
        		saveApprovalProcess(item, "PLAN");
        	}

        	//실적근태 요청서번호가 있는 경우만 처리
        	if ( NullUtil.notNone(item.getString("requestMasterIdResult")) && "Y".equals(item.getString("waitFlagResult")) ) {
	            /* 실적근태 결재 */
        		saveApprovalProcess(item, "RESULT");
        	}
        }
		return result;
	}
	
	/**
	 * Desc : 일근태(계획/실적)을 반려한다.(화면 호출용)
	 * @Method Name : saveReject
	 * @param  param
	 * @return List<LGCOMData>
	 */
	@Transactional(propagation=Propagation.REQUIRED)
	public LGCOMData saveReject(LGCOMData param) {
		LOGGER.debug(this.getClass().getName()+ " param = " + param);
		LGCOMData result = new LGCOMData();
		LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData infoData = (LGCOMData)param.get("infoData");
		boolean mailSendFlag = false;//반려메일 발송여부

		/* 처리로직
		 * - 결재건 유무 체크
		 * - 결재건 loop 시작
		 *   - 계획근태 요청서번호가 있고, 결재 가능 시간인 경우 반려 처리(saveRejectProcess)
		 *   - 실적근태 요청서번호가 있고, 결재 가능 시간인 경우 반려 처리(saveRejectProcess)
		 *   - 계획근태 반려 처리되었거나, 실적근태 반려처리된 경우 요청자에게 반려메일 발송
		 * - 결재건 loop 시작
		 */
		
		LOGGER.debug("infoData==>" + infoData);
		
		/* 반려할 실적 건 */
        @SuppressWarnings("unchecked")
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approvalList");
        LOGGER.debug("approvalList = " + approvalList);
        
        //결재건 없는 경우 오류 처리
        if ( NullUtil.isNull(approvalList) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.nodata"));
        }
        
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
        	//Toolip 에 대한 XSS 처리
        	//replaceXssFilter(item);
        	
            item.put( "LGVHR_PROJECT_SESSION", param.get("LGVHR_PROJECT_SESSION") );
            item.put( LGCOMConstants.HTTP_SESSION_KEY, userSession );

        	item.put( "sessionAppUserId", userSession.get("applicationUserId") );
        	item.put( "approvalCommand", "REJECT" );
        	item.put( "comment", infoData.get("comment") );//결재의견 셋팅
        	item.put( "infoData", infoData );//건별 결재 가능여부 체크하기 위해 사용함.
    		mailSendFlag = false;//초기화
            
        	//계획근태 요청서번호가 있는 경우만 처리
        	if ( NullUtil.notNone(item.getString("requestMasterIdPlan")) && "Y".equals(item.getString("waitFlagPlan")) ) {
	            /* 계획근태 결재자 재조정 */
	            //updatePlanApproverLine(item);
        		LOGGER.debug("saveReject(PLAN)==>" + item);
	            /* 계획근태 결재 */
        		saveRejectProcess(item, "PLAN");
        		mailSendFlag = true;
        	}

        	//실적근태 요청서번호가 있는 경우만 처리
        	if ( NullUtil.notNone(item.getString("requestMasterIdResult")) && "Y".equals(item.getString("waitFlagResult")) ) {
	            /* 실적근태 결재 */
        		LOGGER.debug("saveReject(RESULT)==>" + item);
        		saveRejectProcess(item, "RESULT");
        		mailSendFlag = true;
        	}
        	
    		//반려메일발송(계획, 실적 내용 동일하게 구성했으므로 한번만 보내기.)
        	if ( mailSendFlag ) {//메일발송여부가 true 인 경우만 처리
        		insertMailInfo(item);
        	}
        }
		return result;
	}

	/**
	 * Desc : 계획/실적 근태 결재
	 *        결재 시 saveApproval()에서 호출되어 사용됨.(내부 처리용)
	 * @Method Name : saveApprovalProcess
	 * @param  item
	 */
	private void saveApprovalProcess(LGCOMData item, String planResultCode) {
		/* 승인 로직
		 * - 결재자 여부 확인, 결재 가능한 상태여부 확인
		 * - 계획근태 
		 *   - 계획근태 공통 결재 테이블에 결재상태 반영
		 *   - 계획근태 테이블에 결재상태 반영
		 * - 실적근태
		 *   - 실적근태 공통 결재 테이블에 결재상태 반영
		 *   - 실적근태 테이블에 결재상태 반영
		 */
		if ( "PLAN".equals(planResultCode) || "RESULT".equals(planResultCode) ) {
			if ( "PLAN".equals(planResultCode) ) {
				item.set("requestMasterId", item.get("requestMasterIdPlan"));
				item.set("requestCode", item.get("requestCodePlan"));
			} else {
				item.set("requestMasterId", item.get("requestMasterIdResult"));
				item.set("requestCode", item.get("requestCodeResult"));
			}
			
	        //결재자인지, 결재가능한 상태인지 체크
	        String errorMsg = retrieveValidateApproval(item, planResultCode);
	        if ( NullUtil.notNone(errorMsg) ) {
	        	throw new LGCOMException(errorMsg);
	        }
	        
	        /* 파라메터:requestCode, 통합결재연동여부(portal_flag)와 메일발송여부(mail_flag) 조회하기 위함 */
	        LGCOMData approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", item);
	        
	        item.set("portalFlag", approvalMasterData.get("portalFlag"));
	        item.set("mailFlag", approvalMasterData.get("mailFlag"));
	    	//공통 결재 프로시저 호출
	    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", item);
			if( !"OK".equals( item.getString("retCode") ) ) {
				throw new LGCOMException( item.getString("errorMessage") );
			}
			
			if ( "PLAN".equals(planResultCode) ) {
		        //계획근태 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendancePlanApprovalInfo",item);
			} else {
		        //실적근태 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendanceResultApprovalInfo",item);
			}
		}
	}

	/**
	 * Desc : 계획/실적 근태 반려
	 *        반려시 saveReject()에서 호출되어 사용됨.(내부 처리용)
	 * @Method Name : saveRejectProcess
	 * @param  item
	 */
	private void saveRejectProcess(LGCOMData item, String planResultCode) {
		/* 반려 로직
		 * - 결재자 여부 확인, 결재 가능한 상태여부 확인
		 * - 연차 반영 호출(잔여 휴가 체크 및 연차 처리 같이 처리됨)
		 * - 계획근태 
		 *   - 계획근태 공통 결재 테이블에 결재상태 반영
		 *   - 계획근태 테이블에 결재상태 반영
		 *   - 계획근태 후처리(기본근태로 변경)
		 *   - 요청자에게 반려메일 발송
		 * - 실적근태
		 *   - 실적근태 공통 결재 테이블에 결재상태 반영
		 *   - 실적근태 테이블에 결재상태 반영
		 *   - 실적근태 후처리(결재완료인 계획이 있는 경우 계획근태로,
		 *                     결재완료인 장기근태가 있는 경우 장기근태로,
		 *                     그외 기본근태로 변경)
		 *   - 요청자에게 반려메일 발송
		 */
		if ( "PLAN".equals(planResultCode) || "RESULT".equals(planResultCode) ) {//계획(PLAN) 또는 실적(RESULT) 구분값이 있는 경우만 처리
			if ( "PLAN".equals(planResultCode) ) {
				item.set("requestMasterId", item.get("requestMasterIdPlan"));
				item.set("requestCode", item.get("requestCodePlan"));
			} else {
				item.set("requestMasterId", item.get("requestMasterIdResult"));
				item.set("requestCode", item.get("requestCodeResult"));
			}

	        //결재자인지, 결재가능한 상태인지 체크
	        String errorMsg = retrieveValidateApproval(item, planResultCode);
	        if ( NullUtil.notNone(errorMsg) ) {
	        	throw new LGCOMException(errorMsg);
	        }
			
	        /* 파라메터:requestCode, 통합결재연동여부(portal_flag)와 메일발송여부(mail_flag) 조회하기 위함 */
	        LGCOMData approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", item);
	        
	        item.set("portalFlag", approvalMasterData.get("portalFlag"));//통합결재 연동여부
	        item.set("mailFlag", approvalMasterData.get("mailFlag"));//통합결재 메일발송 여부
	    	//공통 결재 프로시저 호출
	    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", item);
			if( !"OK".equals( item.getString("retCode") ) ) {
				throw new LGCOMException( item.getString("errorMessage") );
			}
			
			if ( "PLAN".equals(planResultCode) ) {
		        //계획근태 '반려' 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendancePlanApprovalInfo",item);
		        
		        //계획근태 '반려' 후처리
		        //공통결재 결재상태 조회
		        LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", item);
		        if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("rejectedFlag") ) ) {//최종 반려인 경우
		        	item.set( "attendanceYyyymmdd", item.get("attendanceYyyymmddPlan") );//계획근태일자
		        	item.set( "approvalType", statusData.get("approvalType") );
		        	item.set( "resultPlanType", planResultCode );//계획(PLAN)/실적(RESULT)구분
		        	//'반려' 후처리 프로시저 호출
		        	this.commonDao.update("LGVATTCOMM.updateProcessAfterApproval", item);
		    		if( item.getInt("retCode") != 0 ) {//0:성공, 그외:실패
		    			throw new LGCOMException( item.getString("errorMessage") );
		    		}
		        }
		        
			} else {
		        //실적근태 '반려' 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendanceResultApprovalInfo",item);
		        
		        //실적근태 '반려' 후처리
		        //공통결재 결재상태 조회
		        LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", item);
		        if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("rejectedFlag") ) ) {//최종 반려인 경우
		        	item.set( "attendanceYyyymmdd", item.get("attendanceYyyymmddResult") );//실적근태일자
		        	item.set( "approvalType", statusData.get("approvalType") );
		        	item.set( "resultPlanType", planResultCode );//계획(PLAN)/실적(RESULT)구분
		        	//'반려' 후처리 프로시저 호출
		        	this.commonDao.update("LGVATTCOMM.updateProcessAfterApproval", item);
		    		if( !"0".equals(item.getString("retCode")) ) {//0:성공, 그외:실패
		    			throw new LGCOMException( item.getString("errorMessage") );
		    		}
		        }
			}
            
            /*
             * 잔여휴가 체크 및 연차 처리
             * [IN PARAMETER]
             * - sessionAppUserId   : [필수] 로그인 사용자 application_user_id. who 컬럼 저장시 사용
             * - attType            : [필수] 체크유형코드. INPUT:근태입력, APPROVAL:근태결재, UPD_REQ:수정요청서 요청, UPD_APPR:수정요청서 결재, LT_TA_REQ:장기근태계획 요청, LT_TA_APPR:장기근태계획 결재
             * - subsidiaryCode     : [필수] 법인코드
             * - employeeNo         : [필수] 근태 대상자 사번
             * - languageCode       : [선택] 언어코드
             * [OUT PARAMETER]
             * - retCode      : 오류 코드. 0:정상, 그외:오류
             * - errorMessage : 오류 메세지코드.
             */
            saveAnualLeaveNValidate(item, planResultCode);
		}
	}

	/**
	 * Desc : 실적근태와 계획근태의 결재자가 다른 경우 계획근태 결재자 삭제 후 실적근태 결재자로 등록한다.
	 *        => 계획 또는 실적만 있는 경우도 결재할 수 있도록 하기 때문에 결재자 재조정 기능은 사용하지 않는다.
	 *        결재 또는 반려 처리 시 호출된다.(내부 처리용)
	 * @Method Name : updatePlanApproverLine
	 * @param  param
	 */
	public void updatePlanApproverLine(LGCOMData item) {
		/*
		 * 실적근태의 결재자와 계획근태의 결재자가 다르고, 계획근태 결재상태가 결재요청(20)인 경우
		 * 계획근태의 결재자를 삭제하고, 실적근태의 결재자와 동일하게 등록한다.
		 * 1차 결재일때 한번만 처리한다.
		 * 처리사유 : 계획근태 결재요청일과 실적근태의 결재요청일이 다르기 때문에, 결재자가 다를 수 있으므로 실적근태의 결재자 기준으로 맞추는 작업을 하기 위함.
		 *            결재자를 실적근태와 동일하게 맞춘 후 결재처리 하고, 최종결재인 경우 계획근태 테이블에 결재상태를 update 하도록 함.
		 *            장기근태와 계획근태를 구분하여 어떤 근태를 반영할지를 판단하기 위함.
		 */
		// 실적결재자와 계획결재자가 동일한지 체크
		LGCOMData approverEqData = this.commonDao.select("LGVATT40010.retrievePlanApproverSameCheck", item);
		// 실적결재자와 계획결재자가 다른 경우 계획결재자 삭제하고, 실적결재자로 재 등록
		if ( approverEqData != null && approverEqData.isEmpty() 
				&& !"Y".equals(approverEqData.getString("approverSameFlag")) && "Y".equals(approverEqData.getString("approvalWaitFlag")) ) {
			
			item.set("requestMasterId", item.get("requestMasterIdPlan"));
			item.set("requestCode", item.get("requestCodePlan"));
			//계획결재자 삭제
        	this.commonDao.select("LGVATTCOMM.deleteApprovalLine", item);
			if( !"OK".equals( item.getString("retCode") ) ) {
				throw new LGCOMException( item.getString("errorMessage") );
			}
			
			//실적결재자 조회
			List<LGCOMData> resultApproverList = this.commonDao.selectList("LGVATT40010.retrieveResultApproverList", item);
			
			//실적결재자를 계획결재자에 등록
			for ( LGCOMData approverData : LGCOMUtils.emptyIfNull(resultApproverList) ) {
				this.commonDao.select("LGVATTCOMMON.insertApprovalLine", approverData);
				if( !"OK".equals( approverData.getString("retCode") ) ) {
					throw new LGCOMException( approverData.getString("errorMessage") );
				}
			}
		}		
	}
	
	/**
	 * XSS 처리
	 * @param item
	 */
	@SuppressWarnings("unchecked")
	public void replaceXssFilter(LGCOMData item) {

        Iterator<String> it = item.keySet().iterator();
        while( it.hasNext() ){
        	String key = it.next();
        	String value = item.getString(key);
    		//tooltip에 <기호가 있으므로 XSS 처리
        	if ( key.toLowerCase().indexOf("tooltip") > -1 ) {
        		item.set( key, LGCOMUtils.xssFilter(value) );
        	}
        }
	}
	
	/**
	 * Desc : 결재 가능한 상태인지 결재 전 체크
	 * - 로그인 사용자가 결재자인지 체크
	 * - 로그인 사용자가 결재가능한 상태인지 체크
	 * - 계획 또는 실적 근태일자가 결재가능한 날짜, 시간인지 체크
	 * 
	 * @Method Name : validateApproval
	 * @param data
	 */
	private String retrieveValidateApproval(LGCOMData param, String planResultCode) {
        //결재 상태 조회
        LOGGER.debug(this.getClass().getName()+ "param ===>" + param);
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
         * 결재 가능한 날짜, 시간인지 조회
         * [PARAMETER]
         * - subsidiaryCode : 로그인 사용자 법인코드
         * - yyyymmdd : 계획근태일자. FORMAT - DDMMYYYY
         * - planResultType : 계획, 실적 구분코드. PLAN - 계획, RESULT - 실적
         * - attendanceYyyymmddPlan : 결재할 계획근태일자. FORMAT - DDMMYYYY
         * - attendanceYyyymmddResult : 결재할 실적근태일자. FORMAT - DDMMYYYY
         */
        LGCOMData tempData = new LGCOMData();
        if ( !NullUtil.isNull(resultData) ) resultData.clear();
        tempData.set( "subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
        tempData.set( "yyyymmdd", ((LGCOMData)param.get("infoData")).getString("planYyyymmdd"));
        tempData.set( "planResultType", planResultCode);
        tempData.set( "attendanceYyyymmddPlan",  param.getString("attendanceYyyymmddPlan"));
        tempData.set( "attendanceYyyymmddResult",  param.getString("attendanceYyyymmddResult"));
        resultData = this.commonDao.select("LGVATT40010.retrieveApprovalEnableFlagData", tempData);

        if ( NullUtil.isNull(resultData) || !"Y".equals(NullUtil.nvl(resultData.getString("approvalEnableFlag"), "")) ) {
        	LGCOMData checkData = retrieveApprovalEnableTimeCheck(tempData);
        	return messageSourceAccessor.getMessage("note.att.dailyAttendanceApprovalTime", StringUtil.split(checkData.getString("approvalEndTime"), ""));//일근태는 {0}까지 결재 가능합니다.
        }
        return null;
	}
	
	/**
	 * Desc : 계획/실적 반려 시 일근태 등록자에게 반려 메일 발송하도록 LGCOM_MAIL_INFO 테이블에 적재하는 처리를 한다.
	 * @Method Name : insertMailInfo
	 * @param param
	 * @return
	 */
	private void insertMailInfo(LGCOMData param) {
		LGCOMData result = new LGCOMData();
		LGCOMData mailParamData = new LGCOMData();
		/*
    	 * 메일발송 시 필요한 파라메터
    	 * [IN PARAMETER]
		 * - sessionAppUserId : 생성자, 최종수정자 컬럼에 입력될 로그인 사용자의 lgcom_user_m.application_user_id
		 * - subsidiaryCode : 법인코드.
		 * - mailCode : 메일 템플릿 코드. code_type_code='LGVHR_MAIL_TEMPLATE_LIST'
		 * - receiptInfo : 수신자메일 : 사원번호 가능(1명만),  이메일 여러명 가능(콤마 구분)
		 * - languageCode : 언어코드. 디폴트 en
		 * - mailMappData : 템플릿에 등록된 메일 내용 및 제목을 치환할 JSON 데이터셋. 생략: 매핑데이타
		 * - senderInfo : 생략: 송신자메일: 생락시 디폴트(hrsys@lgdisplay.com), 사원번호 가능(1명만),  이메일 여러명 가능(콤마 구분)
		 * - ccInfo : 생략: 참조자메일
		 */
		//메일 발송에 필요한 내용 구성
		mailParamData = this.commonDao.select("LGVATT40010.retrieveMailContent", param);
		LOGGER.debug("mail retrieve param=======>" + mailParamData);
		if ( !NullUtil.isNull(mailParamData) && NullUtil.notNone(mailParamData.getString("mailCode")) ) {		
			result = insertSendMail(mailParamData);
			LOGGER.debug("mail insert param=======>" + mailParamData);
			LOGGER.debug("mail insert result=======>" + result);
	
			if ( NullUtil.isNull(result)) {
				LOGGER.debug("mail insert error!!!!!");
			} else if ( !"S".equals(result.getString("errorCode")) ) {
				LOGGER.debug(NullUtil.nvl(result.get("errorMessage"), ""));
			}
		}
	}

	/**
	 * Desc : 잔여휴가 체크 및 연차 처리
	 * 
	 * - 일근태입력/결재 : 근태코드 = 'AL','HL' 일때만 호출
	 * - 수정요청서 요청/결재 : NEW 근태코드 = 'AL' ,'HL'일때만 호출
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
	public LGCOMData saveAnualLeaveNValidate(LGCOMData param, String planResultCode) {
        LGCOMData result = new LGCOMData();
        
		//실적 입력한 근태코드가 휴가(AL:Annual Leave, HL : Half Day Leave)인 경우만 체크
        //2018.02.28 : 반일휴가 추가 
		if ( "RESULT".equals(planResultCode) && 
				( "AL".equals(param.getString("attendanceCodeResult")) || 
				  "HL".equals(param.getString("attendanceCodeResult")) || 
				  "HL_FN".equals(param.getString("attendanceCodeResult")) || 
				  "HL_SN".equals(param.getString("attendanceCodeResult")) ) ) {

			//잔여휴가 체크 및 연차 처리
	        result.set( "sessionAppUserId",   ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
	        result.set( "attType",            "REJECT");
	        result.set( "subsidiaryCode",     ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
	        result.set( "employeeNo",         param.get("employeeNo"));
	        result.set( "languageCode",       ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
	        result.set( "attendanceYyyymmdd", "");//null인 경우 sysdate로 처리됨
	        result.set( "newInputResultAttCode", "");
	        result.set( "newInputPlanAttCode", "");
	        
	        this.commonDao.update("LGVATTCOMM.retrieveValidateAnualLeave", result);
	        
	        if ( !"0".equals( result.getString("retCode")) ) {//연차체크 후 부적합인 경우
	        	throw new LGCOMException( messageSourceAccessor.getMessage(result.getString("errorMessage")) );
	        }
		}
        return result;
	}
	
	/**
	 * Desc : 2018.03.12 [베트남 급여근태 고도화] Let's에서 호출된 경우 팝업 호출가능한 상태인지 판단한다.
	 * @Method Name : retireveDirectOpenData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retireveDirectOpenData(LGCOMData param) {
		return this.commonDao.select("LGVATT40010.retireveDirectOpenData", param);
	}
}
