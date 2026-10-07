/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0020ServiceImpl.java
 * @Desc    : Request Payroll Confirm
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	  1.0	2018.11.05. lhj  		최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0020.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.lgvpayp0020.service.LGVPAYP0020Service;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.LGVPAYP0020.service.serviceImpl.LGVPAYP0020ServiceImpl.java
 * </PRE>
 *
 * @Author    lhj
 * @Date      2018. 11. 05.
 * @Version
 */
@Service("LGVPAYP0020Service")
public class LGVPAYP0020ServiceImpl implements LGVPAYP0020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    /**
     * Desc : 확정요청할 급여 Summary 정보 조회 전 체크
     * - 급여담당자 권한이 있는지 체크
     * - calculation_set_id, payrollTypeCode, payrollCalcPeriodValue, calculation_execution_id 필수값 체크
     * 
     * @Method Name : validateRetrievePayrollSumamry
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateRetrievePayrollSumamry(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalcPeriodValue")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.payMonthShort"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("payrollTypeCode")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.payType"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여지급확정을 요청한다.
     * @Method Name : insertRequestPayrollConfirm
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public void insertRequestPayrollConfirm(LGCOMData param) {
		LOGGER.debug("param = " + param);
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
    	    		
    	if ( validateRetrievePayrollSumamry(param) ) {//값 체크 정상인 경우 처리
            // 결재요청아이디 시퀀스 조회
            LGCOMData requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
            
            requestMasterIdData.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );//요청정보 조회하면서 세션정보 일부 셋팅함.
            requestMasterIdData.set( projectSessionName, projectSession );
            requestMasterIdData.set( "approvalMenuId", "M_LGVPAY_1050" );
            requestMasterIdData.set( "systemCode", systemCode );
            requestMasterIdData.set("requestorId", userSession.get("applicationUserId"));
            
            /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
            LGCOMData approvalMasterData = new LGCOMData();
            approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", requestMasterIdData);
            
            // 데이터가 없는 경우 처리하지 않음
            if ( approvalMasterData != null && !approvalMasterData.isEmpty() ) {

            	approvalMasterData.set("screenParam", param);
            	approvalMasterData.set("commentContent", approvalMasterData.get("commentContent") + " - Pay Month : " + param.getString("payrollCalcPeriodValue"));
            	this.commonDao.update("LGVPAYP0020.updateRequestInfoPayCalcExec", approvalMasterData);
            	
    	        /* 공통 결재마스터 테이블 등록 */
    	        this.commonDao.select("LGVATTCOMM.insertApprovalMaster", approvalMasterData);
                
    			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
    				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
    			}
    	        
    	        /* 공통 결재상태 테이블에 결재자 등록 */
    			List<LGCOMData> approvalList = getApproverList();
    	        LOGGER.debug("approvalList=>" + approvalList);
    	        for( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
    	            /* 사용자 세션정보 셋팅 */
    	            item.put("sessionAppUserId", userSession.get("applicationUserId"));
    	            item.put("settlementDeleteFlag", "N");
    	            item.put("approvalActionCode", "APPROVAL");
    	            item.put("requestMasterId", approvalMasterData.get("requestMasterId"));
    	            item.put("requestCode", approvalMasterData.get("requestCode"));
    	            item.put("ouId", approvalMasterData.get("ouId"));
    	            this.commonDao.select("LGVATTCOMM.insertApprovalLine",item);
    	            
    				if( !"OK".equals( item.getString("retCode") ) ) {
    					throw new LGCOMException( item.getString("errorMessage") );
    				}
    	        }
    	        
    	        /* 결재요청 */
            	approvalMasterData.set("approvalCommand", "REQUEST");
            	approvalMasterData.set("sessionAppUserId",userSession.get("applicationUserId"));
            	
            	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", approvalMasterData);
            	
    			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
    				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
    			}
            }
    	}
    	
    }
    
    /**
	 * Desc : 급여지급확정요청서 승인/반려
	 * @Method Name : insertApproveOrReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
    @Override
    @Transactional(propagation=Propagation.REQUIRED)
    public void insertApproveOrReject(LGCOMData param) {
    	LOGGER.debug("param = " + param);
    	
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
        
        param.set("sessionAppUserId", userSession.get("applicationUserId"));
        param.set("portalFlag", approvalData.get("portalFlag"));
        param.set("mailFlag", approvalData.get("mailFlag"));
        
    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
    	
    	if( !"OK".equals(  param.getString("retCode") ) ) {
			throw new LGCOMException(  param.getString("errorMessage") );
		}
    }
	
	/**
     * Desc : 확정요청할 Payroll Summary를 조회한다. 
     * @Method Name : retrievePayrollSummary
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollSummary(LGCOMData param) {
    	LOGGER.debug("param===>" + param);
    	
    	if(!validateRetrievePayrollSumamry(param)) return null;
        
    	return this.commonDao.selectList("LGVPAYP0020.retrievePayrollSummary", param);
    }
	
	/**
     * Desc : 결재할 Payroll Summary를 조회한다. 
     * @Method Name : retrieveRequestContent
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRequestContent(LGCOMData param) {
    	LOGGER.debug("param===>" + param);
        LGCOMData calcExecInfo = this.commonDao.select("LGVPAYP0020.retrieveCalcExecId", param);
    	
        LOGGER.debug("calcExecInfo===>" + calcExecInfo);
    	return this.commonDao.selectList("LGVPAYP0020.retrievePayrollSummary", calcExecInfo);
    }
    
    /**
     * Desc : 급여지급확정요청서의 결재라인을 조회한다. 
     * @Method Name : getApproverList
     * @param 
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> getApproverList() {
    	return this.commonDao.selectList("LGVPAYP0020.getApproverList");
    }
}
