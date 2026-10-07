/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40011ServiceImpl.java
 * @Desc    : 일근태 실적 수정 팝업 (결재권자)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0  2018.01.03.   LHJ    	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt40011.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt40011.service.LGVATT40011Service;

import com.lgd.lgvhr.lgvcom.lgvcommail.service.serviceImpl.LGVCOMMAILServiceImpl;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT40011.service.LGVATT40011ServiceImpl.java
 * </PRE>
 * 
 * @author     LHJ
 * @Date	   2018.01.03.
 * @Version
 *
 */
@Service("LGVATT40011Service")
public class LGVATT40011ServiceImpl extends LGVCOMMAILServiceImpl implements LGVATT40011Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT40011ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 결재화면에서 필요한 초기정보를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 * @return List<LGCOMData>
	 */
    public List<LGCOMData> retrieveInitData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40011.retrieveInitData", param);
    }
    
    /**
	 * Desc : 결재화면에서 필요한 초기정보를 조회한다.
	 * @Method Name : retrieveNonRequestorData
	 * @param  param
	 * @return List<LGCOMData>
	 */
    public List<LGCOMData> retrieveNonRequestorData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40011.retrieveNonRequestorData", param);
    }
    
    /**
	 * Desc : 실적 수정사항을 업데이트한다.
	 * @Method Name : updateAttendanceResult
	 * @param  param
	 * @return void
	 */
    @SuppressWarnings("unchecked")
    @Transactional(propagation=Propagation.REQUIRED)
    public void updateAttendanceResult(LGCOMData param) {
    	LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
    	LOGGER.debug("param = " + param);
    	
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approvalList");
		
        LOGGER.debug("approvalList = " + approvalList);
    	
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
        	item.put( "LGVHR_PROJECT_SESSION", param.get("LGVHR_PROJECT_SESSION") );
            item.put( LGCOMConstants.HTTP_SESSION_KEY, userSession );

        	item.put( "sessionAppUserId", userSession.get("applicationUserId") );
        	
        	this.commonDao.update("LGVATT40011.updateAttendanceResult", item);
        	item.set("resultType", "RESULT");
        	item.set("attendanceDate", item.get("attendanceYyyymmddResult"));
        	item.set("languageCode", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
        	
        	saveAnualLeaveNValidate(item, "RESULT");
        	
        	this.commonDao.select("LGVATTCOMM.applyAttModifiedAlert", item);
        }
    }
    
    /**
	 * Desc : 승인
	 * @Method Name : saveApproval
	 * @param  param
	 * @return void
	 */
    @SuppressWarnings("unchecked")
    @Transactional(propagation=Propagation.REQUIRED)
    public void saveApproval(LGCOMData param) {
    	LOGGER.debug("param = " + param);
    	LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
    	LGCOMData infoData = (LGCOMData)param.get("infoData");
    	
    	/* 결재할 실적 건 */
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approvalList");
		
		//결재건 없는 경우 오류 처리
        if ( NullUtil.isNull(approvalList) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.nodata"));
        }
        
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
        	
            item.put("LGVHR_PROJECT_SESSION", param.get("LGVHR_PROJECT_SESSION"));
            item.put(LGCOMConstants.HTTP_SESSION_KEY, userSession);

        	item.put( "sessionAppUserId", userSession.get("applicationUserId") );
        	item.put( "approvalCommand", "APPROVAL" );
        	item.put( "comment", infoData.get("comment") );//결재의견 셋팅
        	item.put( "infoData", infoData );//건별 결재 가능여부 체크하기 위해 사용함.
        	
        	item.set("requestMasterId", item.get("requestMasterIdResult"));
        	item.set("requestCode", item.get("requestCodeResult"));

        	//실적근태 요청서번호가 있는 경우만 처리 /* 실적근태 결재 */
        	if ( NullUtil.notNone(item.getString("requestMasterId")) ) {
        		
        		// 실적테이블 저장 및 잔여연차 체크 start
        		this.commonDao.update("LGVATT40011.updateAttendanceResult", item);
            	item.set("resultType", "RESULT");
            	item.set("attendanceDate", item.get("attendanceYyyymmddResult"));
            	item.set("languageCode", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
            	
            	saveAnualLeaveNValidate(item, "RESULT");
            	// 실적테이블 저장 및 잔여연차 체크 end
    	        
        		LGCOMData resultData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", item);
                
                if ( !NullUtil.isNull(resultData) ) {
                	if ( !"Y".equals(resultData.get("approverFlag")) ) {
                		throw new LGCOMException(messageSourceAccessor.getMessage("note.att.noApprover"));//결재자가 아닙니다.
                	} else if ( !"Y".equals(resultData.get("approvalEnableFlag")) ) {
                		throw new LGCOMException(messageSourceAccessor.getMessage("note.att.notInProgressStatus"));//결재가능한 상태가 아닙니다. 결재문서의 진행상태를 확인해주세요.
                	}
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
    			
		        //실적근태 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendanceResultApprovalInfo",item);
        	}
        	
        }
    }
    
    public LGCOMData saveAnualLeaveNValidate(LGCOMData param, String planResultCode) {
        LGCOMData result = new LGCOMData();
        
		//실적 입력한 근태코드가 휴가(AL:Annual Leave, HL:Halfday Leave)인 경우만 체크
		if ( "RESULT".equals(planResultCode) && 
				( "AL".equals(param.getString("attendanceCode")) || "AL".equals(param.getString("originAttendanceCode")) || 
				  "HL".equals(param.getString("attendanceCode")) || "HL".equals(param.getString("originAttendanceCode")) || 
				  "HL_FN".equals(param.getString("attendanceCode")) || "HL_FN".equals(param.getString("originAttendanceCode")) || 
				  "HL_SN".equals(param.getString("attendanceCode")) || "HL_SN".equals(param.getString("originAttendanceCode")) ) 
			) {

			//잔여휴가 체크 및 연차 처리
	        result.set( "sessionAppUserId",   param.get("applicationUserId"));
	        result.set( "attType",            "MODIFY");
	        result.set( "subsidiaryCode",     ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
	        result.set( "employeeNo",         param.get("employeeNo"));
	        result.set( "languageCode",       ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("languageCode"));
	        result.set( "attendanceYyyymmdd", "");//null인 경우 sysdate로 처리됨
	        result.set( "newInputResultAttCode", param.getString("attendanceCode"));
	        result.set( "newInputPlanAttCode", "");
	        
	        this.commonDao.update("LGVATTCOMM.retrieveValidateAnualLeave", result);
	        
	        if ( !"0".equals( result.getString("retCode")) ) {//연차체크 후 부적합인 경우
	        	throw new LGCOMException( messageSourceAccessor.getMessage(result.getString("errorMessage")) );
	        }
		}
		
        return result;
	}
}
