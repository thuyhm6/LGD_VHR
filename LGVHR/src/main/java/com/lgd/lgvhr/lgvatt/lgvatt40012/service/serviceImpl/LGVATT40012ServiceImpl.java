/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40012Service.java
 * @Desc    : 사무직 일근태 조회하면 ( 팀장 하위 전체 )
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0  2018.01.18.   LHJ    	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt40012.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt40012.service.LGVATT40012Service;

import com.lgd.lgvhr.lgvcom.lgvcommail.service.serviceImpl.LGVCOMMAILServiceImpl;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt40012.service.serviceImpl.LGVATT40012ServiceImpl.java
 * </PRE>
 * 
 * @author     LHJ
 * @Date	   2018.01.18.
 * @Version
 *
 */
@Service("LGVATT40012Service")
public class LGVATT40012ServiceImpl extends LGVCOMMAILServiceImpl implements LGVATT40012Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT40012ServiceImpl.class);

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
    public List<LGCOMData> retrieveAttendanceData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT40012.retrieveAttendanceData", param);
    }
    
    /**
	 * Desc : 세션유저의 하위 조직리스트를 조회한다.
	 * @Method Name : retrieveUnderOrgList
	 * @param  param
	 * @return LGCOMData
	 */
    public LGCOMData retrieveSearchFormDataList(LGCOMData param) {
    	LOGGER.debug("param = " + param);
    	LGCOMData resultList = new LGCOMData();
    	
    	// 세션사용자 하위조직 리스트
    	resultList.set("underOrgList", this.commonDao.selectList("LGVATT40012.retrieveUnderOrgList", param));
    	
		return resultList;
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

        	//실적근태 요청서번호가 있는 경우만 처리 /* 실적근태 결재 */
        	if ( NullUtil.notNone(item.getString("requestMasterId")) ) {
    	        
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
    
    /**
	 * Desc : 반려
	 * @Method Name : saveReject
	 * @param  param
	 * @return void
	 */
    @SuppressWarnings("unchecked")
    @Transactional(propagation=Propagation.REQUIRED)
    public void saveReject(LGCOMData param) {
    	LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
    	LGCOMData infoData = (LGCOMData)param.get("infoData");
    	
    	/* 결재할 실적 건 */
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approvalList");
		
		//결재건 없는 경우 오류 처리
        if ( NullUtil.isNull(approvalList) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.nodata"));
        }
        
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
        	
        	item.put( "LGVHR_PROJECT_SESSION", param.get("LGVHR_PROJECT_SESSION") );
            item.put( LGCOMConstants.HTTP_SESSION_KEY, userSession );

        	item.put( "sessionAppUserId", userSession.get("applicationUserId") );
        	item.put( "approvalCommand", "REJECT" );
        	item.put( "comment", infoData.get("comment") );//결재의견 셋팅
        	item.put( "infoData", infoData );//건별 결재 가능여부 체크하기 위해 사용함.
    		
        	//실적근태 요청서번호가 있는 경우만 처리
        	if ( NullUtil.notNone(item.getString("requestMasterId")) ) {
	            /* 실적근태 결재 */

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
        		
    			//실적근태 '반려' 결재상태 반영
		        this.commonDao.update("LGVATT40010.updateAttendanceResultApprovalInfo",item);
		        
		        //실적근태 '반려' 후처리
		        //공통결재 결재상태 조회
		        LGCOMData statusData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", item);
		        if ( !NullUtil.isNull(statusData) && "Y".equals( statusData.getString("rejectedFlag") ) ) {//최종 반려인 경우
		        	item.set( "attendanceYyyymmdd", item.get("attendanceYyyymmddResult") );//실적근태일자
		        	item.set( "approvalType", statusData.get("approvalType") );
		        	item.set( "resultPlanType", "RESULT" );//계획(PLAN)/실적(RESULT)구분
		        	//'반려' 후처리 프로시저 호출
		        	this.commonDao.update("LGVATTCOMM.updateProcessAfterApproval", item);
		    		if( !"0".equals(item.getString("retCode")) ) {//0:성공, 그외:실패
		    			throw new LGCOMException( item.getString("errorMessage") );
		    		}
		        }
        	}
        	
        	//2018.03.10: 반려 시 기본근태로 변경 한 후 연차 처리 하기 위해 위치 변경
	        saveAnualLeaveNValidate(item, "RESULT");
        	
    		//반려메일발송(계획, 실적 내용 동일하게 구성했으므로 한번만 보내기.)
        	LGCOMData result = new LGCOMData();
    		LGCOMData mailParamData = new LGCOMData();
    		
    		//메일 발송에 필요한 내용 구성
    		mailParamData = this.commonDao.select("LGVATT40010.retrieveMailContent", param);
    		if ( !NullUtil.isNull(mailParamData) && NullUtil.notNone(mailParamData.getString("mailCode")) ) {		
    			result = insertSendMail(mailParamData);
    	
    			if ( NullUtil.isNull(result)) {
    				LOGGER.debug("mail insert error!!!!!");
    			} else if ( !"S".equals(result.getString("errorCode")) ) {
    				LOGGER.debug(NullUtil.nvl(result.get("errorMessage"), ""));
    			}
    		}
        	
        }
    }
    
    public LGCOMData saveAnualLeaveNValidate(LGCOMData param, String planResultCode) {
        LGCOMData result = new LGCOMData();
        
		//실적 입력한 근태코드가 휴가(AL:Annual Leave, HL : Half Day Leave)인 경우만 체크
		if ( "RESULT".equals(planResultCode) && 
				( "AL".equals(param.getString("timeAndAttendanceCode")) ||
				  "HL".equals(param.getString("timeAndAttendanceCode")) ||
				  "HL_FN".equals(param.getString("timeAndAttendanceCode")) ||
				  "HL_SN".equals(param.getString("timeAndAttendanceCode")) ) 
			) {

			//잔여휴가 체크 및 연차 처리
	        result.set( "sessionAppUserId",   param.get("sessionAppUserId"));
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
}
