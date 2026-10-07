/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00023ServiceImpl.java
 * @Desc    : Annual Leave Adj. for Retiree
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 03. 14.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00023.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00023.service.LGVPAY00023Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00023.service.serviceImpl.LGVPAY00023ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 03. 14.
 * @Version
 */
@Service("LGVPAY00023Service")
public class LGVPAY00023ServiceImpl implements LGVPAY00023Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00023ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    /**
     * Desc : 확정된 급여실적이 있는지 조회한다.
     * @Method Name : retrieveConfirmExistsData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveConfirmExistsData(LGCOMData param) {
    	return commonDao.select("LGVPAY00023.retrieveConfirmExistsData", param);
    }

    /**
     * Desc : 급여 대상자 중 퇴직자의 연차 정보 조회한다. 
     * @Method Name : retrieveRetireeAnnualLeaveList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRetireeAnnualLeaveList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAY00023.retrieveRetireeAnnualLeaveList", param);
    }
    
    /**
     * Desc : 퇴직자 연차 계산 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcPeriodValue, calculation_set_id 필수값 체크
     * - 확정된 급여실적이 있는지 체크
     * 
     * @Method Name : validateSaveCalculateAnnualLeave
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveCalculateAnnualLeave(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 

    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		
    		if ( NullUtil.isNone(param.getString("payrollCalcPeriodValue")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.payMonth"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		}  else {
        		
        		//확정된 급여실적 여부 조회
        		LGCOMData existsData = retrieveConfirmExistsData(param);

        		//확정건이 있는 경우
        		if ( !NullUtil.isNull(existsData) && "Y".equals(existsData.getString("confirmExistsFlag")) ) {
            		validateFlag = false;
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.notChangeConfirmData"));
        		}
    		}
    		validateFlag = true;
    	}
    	LOGGER.debug("validateFlag="+validateFlag);
    	return validateFlag;
    }
    
    /**
     * Desc : 급여대상자 Set에 있는 퇴직자의 연차를 계산하여 보정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : saveCalculateAnnualLeave
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveCalculateAnnualLeave(LGCOMData param) {
		LOGGER.debug("saveCalculateAnnualLeave.param====>" + param);
		
    	if ( validateSaveCalculateAnnualLeave(param) ) {//값 체크 정상인 경우 처리
    		//퇴직자 연차 계산 및 보정
    		this.commonDao.select("LGVPAY00023.saveCalculateAnnualLeave", param);
    	}
    	return param;
    }
    
    /**
     * Desc : 퇴직자 보상년차 수정 체크 
     * - 급여담당자 권한이 있는지 체크
     * - employeeNo, 근태년월 필수값 체크
     * - 확정된 급여실적이 있는지 체크
     * 
     * @Method Name : validateUpdateAnnualLeave
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdateAnnualLeave(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		
    		//확정된 급여실적 여부 조회
    		LGCOMData existsData = retrieveConfirmExistsData(param);
    		
    		//확정건이 있는 경우
    		if ( !NullUtil.isNull(existsData) && "Y".equals(existsData.getString("confirmExistsFlag")) ) {
        		validateFlag = false;
    			throw new LGCOMException(messageSourceAccessor.getMessage("error.notChangeConfirmData"));
    			
    		} else { 
            
	            //신규건 또는 수정건 체크
		        for ( LGCOMData item : LGCOMUtils.emptyIfNull(param.getList(LGCOMConstants.STATUS_UPDATE)) ) {
		        	//필수값 체크
	    			if ( NullUtil.isNone(item.getString("employeeNo")) ) {
	    				validateFlag = false;
	    				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.employeeNo")}));
	    				
	    			} else if ( NullUtil.isNone(item.getString("timeAndAttendanceYyyymm")) ) {
	    				validateFlag = false;
	    				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.payMonth")}));
	    				
	    			}
		        }
    		}
        	validateFlag = true;
    	}

    	return validateFlag;
    }
    
    /**
     * Desc : 퇴직자 보상년차를 수정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : updateAnnualLeave
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateAnnualLeave(LGCOMData param) {
		LOGGER.debug("updateAnnualLeave.param====>" + param);
		
    	if ( validateUpdateAnnualLeave(param) ) {//값 체크 정상인 경우 처리

            //신규건 또는 수정건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull(param.getList(LGCOMConstants.STATUS_UPDATE)) ) {
	            item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
	            item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
	            
	    		//퇴직자 보상년차 수정
	    		this.commonDao.select("LGVPAY00023.updateAnnualLeave", item);
	        }
    	}
    	return param;
    }
}
