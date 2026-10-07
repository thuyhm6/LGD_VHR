/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20441Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20441.service.serviceImpl;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
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
import com.lgd.lgvhr.lgvatt.lgvatt20441.service.LGVATT20441Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20441.controller.LGVATT20441Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT20441Service")
public class LGVATT20441ServiceImpl implements LGVATT20441Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20441ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Value Set 목록을 조회한다.
	 * @Method Name : retrieveMutiplanList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveMutiplanDetail(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		LGCOMData result = new LGCOMData();
		result = (LGCOMData) this.commonDao.select("LGVATT20441.retrieveMutiplanDetail",param);
		
		return result;
	}
	
	/**
	 * Desc : 장기근태 결제요청을 승인 또는 반려 처리한다.
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveRequestApprovalOrReject(LGCOMData param) {
    	LOGGER.debug("param = " + param);
    	
    	LGCOMData result = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        
        SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    	Date currentTime = new Date();
    	String mTime = mSimpleDateFormat.format(currentTime);
    	result.set("errorCode", "");
    	
        //요청서 아이디 또는 요청서 코드 또는 결재/반려 구분코드가 없는 경우 오류 리턴
        if ( NullUtil.isNone(param.getString("requestMasterId")) || NullUtil.isNone(param.getString("requestCode")) 
        		|| NullUtil.isNone(param.getString("approvalCommand"))
        		|| (!"APPROVAL".equals(param.getString("approvalCommand")) && !"REJECT".equals(param.getString("approvalCommand"))) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("error.CheckRequestNo."));//승인요청번호를 확인하세요.
        	
        	/*result.set("errorCode", "N");
        	result.set("errorMsg", messageSourceAccessor.getMessage("error.CheckRequestNo."));
        	return result;*/
        }
        
        //결재자인지, 결재가능한 상태인지 체크
        String errorMsg = retrieveValidateApprovalStatus(param);
        if(errorMsg.length() != 0 && errorMsg != null) {
        	//throw new LGCOMException(errorMsg);
        	
        	result.set("errorCode", "N");
        	result.set("errorMsg", messageSourceAccessor.getMessage("error.CheckRequestNo."));
        	return result;
        }
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
        
        param.set("sessionAppUserId", userSession.get("applicationUserId"));
        param.set("portalFlag", approvalData.get("portalFlag"));
        param.set("mailFlag", approvalData.get("mailFlag"));
        
        //휴가사용 여부 체크 프로시저 호출 - 결제승인인 경우에만
        if("APPROVAL".equals(param.getString("approvalCommand"))) {
        	errorMsg = retrieveAnnualLeave(param);
        	if(errorMsg.length() != 0 && errorMsg != null) {
				throw new LGCOMException(messageSourceAccessor.getMessage(errorMsg));
			}
        }
        
    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
    	
    	if( !"OK".equals(  param.getString("retCode") ) ) {
			throw new LGCOMException(  param.getString("errorMessage") );
		}
    	
    	/*****************************************************************************
         ********************** 최종승인일 경우 근태계획 등록 ************************
         *****************************************************************************/
        
    	//공통결재 결재상태 조회
        /*LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
		if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("approvedFlag")) ) {
			param.put("planningId", 		param.get("planningId"));
			param.put("approvalCommand", "");
	        
	        //근태계획에 insert 처리
	        this.commonDao.select("LGVATT20450.insertPlanApproval", param);
	        
	        if( !"0".equals(param.getString("retCode")) ) {//0:성공, 그외:실패
				throw new LGCOMException( param.getString("errorMessage") );
			}
		}*/
		//장기근태 테이블에 결제상태 반영
		this.commonDao.update("LGVATT20441.updateApporvalStatus", param);
				
		if(result.get("errorCode").equals("")) {
			result.set("errorCode", "S");
		}
		return result;
    }
    
    /**
	 * 결재 상태를 확인한다.
	 * @Method Name : retrieveValidateApprovalStatus
	 * @param param.requestMasterId    : 요청서아이디. 요청서아이디 + 요청서코드 : unique
	 *             .requestCode        : 요청서코드.
	 *             .approverEmployeeNo : 결재자 사번. 특정 결재자에 대해 체크하는 경우 값 입력.
	 *                                   값이 없는 경우 세션 사번(LGVHR_PROJECT_SESSION.employeeNo)으로 체크
	 * @return String : 오류메세지
	 */
	private String retrieveValidateApprovalStatus(LGCOMData param) {
        String errorMsg = "";
        
        //결재 상태 조회
        LOGGER.debug("param ===>" + param);
        LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
        
        if ( !NullUtil.isNull(statusData) ) {
        	if ( !"Y".equals(statusData.get("approverFlag")) ) {
        		//errorMsg = messageSourceAccessor.getMessage("note.att.noApprover");//결재자가 아닙니다.
        		errorMsg = "note.att.noApprover";
        	} else if ( !"Y".equals(statusData.get("approvalEnableFlag")) ) {
        		errorMsg = messageSourceAccessor.getMessage("note.att.notInProgressStatus");//결재가능한 상태가 아닙니다. 결재문서의 진행상태를 확인해주세요.
        		errorMsg = "note.att.notInProgressStatus";
        	}
        }
        return errorMsg;
	}
	
	/**
	 * Desc : 결제담당자 또는 자신이 결제취소
	 * @Method Name : saveSelfReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	@Override
	public LGCOMData saveSelfReject(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		String applicationUserId = "";
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
        
        applicationUserId = (String) userSession.get("applicationUserId");
        //결제담당자가 selfReject시 사용자ID 셋팅 --28733
        if(!userSession.get("applicationUserId").equals(applicationUserId)){
        	applicationUserId = (String) param.get("applicationUserId");
        }
        
        param.set("sessionAppUserId", applicationUserId);
        param.set("portalFlag", approvalData.get("portalFlag"));
        param.set("mailFlag", approvalData.get("mailFlag"));

    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
    	
    	if( !"OK".equals(  param.getString("retCode") ) ) {
			throw new LGCOMException(  param.getString("errorMessage") );
		}
    	
    	this.commonDao.update("LGVATT20441.updateRequestProgress", param);
    	
    	result.set( "errorCode", "S");//성공인 경우
		return result;
	}
	/**
	 * 잔여휴가를 확인한다.
	 * @Method Name : retrieveAnnualLeave
	 * @param param.sessionAppUserId   : 사용자아이디 application_usr_id
	 *             .attType        	   : 결제요청일때 장기근태 코드(LT_TA_REQ)
	 *             .subsidiaryCode 	   : 결재자 요청자 법인코드
	 *             .employeeNo         : 사번
	 *             .languageCode       : 사용자 언어코드
	 *             .attendanceYyyymmdd : 오늘날짜
	 * @return String : 오류메세지
	 */
	private String retrieveAnnualLeave(LGCOMData param) {

    	LGCOMData employeeInfo = new LGCOMData();
    	LGCOMData annualLeaveInput = new LGCOMData();
		SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    	Date currentTime = new Date();
    	String mTime = mSimpleDateFormat.format(currentTime);
		String errorMsg = "";
		
		employeeInfo = this.commonDao.select("LGVATTCOMM.retrieveEmployee", param);
    	
    	//결제요청자 정보 담기
        annualLeaveInput.set("sessionAppUserId", employeeInfo.getString("applicationUserId"));
        annualLeaveInput.set("attType", "LT_TA_APPR"); //결제승인일때
        annualLeaveInput.set("subsidiaryCode", employeeInfo.getString("subsidiaryCode"));
        annualLeaveInput.set("employeeNo", employeeInfo.getString("employeeNo"));
        annualLeaveInput.set("languageCode", employeeInfo.getString("languageCode"));
        annualLeaveInput.set("attendanceYyyymmdd", mTime);
        annualLeaveInput.set("requestNo", param.getString("planningId"));
        annualLeaveInput.set( "newInputResultAttCode", "");
        annualLeaveInput.set( "newInputPlanAttCode", "");

        this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", annualLeaveInput); 
        
        //잔여연차가 부족할 경우
        if(!"0".equals(annualLeaveInput.getString("retCode"))) {
        	errorMsg = annualLeaveInput.getString("errorMessage");
		}
        
        return errorMsg;
	}
}
