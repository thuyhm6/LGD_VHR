/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00007Service.java
 * @Desc    : Payroll Activity Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 28.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00007.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00007.service.LGVPAY00007Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00007.service.serviceImpl.LGVPAY00007ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 28.
 * @Version
 */
@Service("LGVPAY00007Service")
public class LGVPAY00007ServiceImpl implements LGVPAY00007Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00007ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

    /**
     * Desc : 급여작업 Activity를 조회한다.
     * @Method Name : retrievePayrollActivityList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollActivityList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAY00007.retrievePayrollActivityList", param);
    }

    /**
     * Desc : 급여작업 특정 Activity를 조회한다.
     * @Method Name : retrievePayrollActivityData
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public LGCOMData retrievePayrollActivityData(LGCOMData param) {
    	param.set( "srchProcessNo", NullUtil.nvl(param.get("srchProcessNo"), param.getString("processNo")) );
    	return this.commonDao.select("LGVPAY00007.retrievePayrollActivityList", param);
    }

    /**
     * Desc : 급여작업 Activity 유무 조회한다.
     * @Method Name : retrievePayProcsPerfmResultExistsFlag
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrievePayProcsPerfmResultExistsFlag(LGCOMData param) {
    	LGCOMData result = this.commonDao.select("LGVPAY00007.retrievePayProcsPerfmResultExistsFlag", param);
    	
    	if ( !NullUtil.isNull(result) && "Y".equals(result.getString("existsFlag")) ) {
    		return true;
    	}
    	return false;
    }
    
    /**
     * Desc : transaction 전 체크
     * 
     * - 급여작업 Activity 저장 전 체크
     *   - 급여담당자 권한이 있는지 체크
     * - 급여대상자 생성 전 체크
     *   - 급여담당자 권한이 있는지 체크
     * - 급여 전표 인터페이스 데이터 생성 전 체크
     *   - 급여담당자 권한이 있는지 체크
     * 
     * @Method Name : validateSavePayrollActivity
     * @param param
     * @return boolean
     * @throws Exception
     */
    private boolean validateParameter(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여작업 Activity 저장한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터 없는 경우 insert
     *   - 데이터 있는 경우 update 
     * 
     * @Method Name : savePayrollActivity
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData savePayrollActivity(LGCOMData param) {
        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
		
    	if ( validateParameter(param) ) {//값 체크 정상인 경우 처리
            for( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.getList("list")) ) {
            	
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollCalcPeriodValue", param.get("payrollCalcPeriodValue") );
            	item.set( "payrollTypeCode", param.get("payrollTypeCode") );
            	item.set( "calculationSetId", param.get("calculationSetId") );
            	
            	if ( this.retrievePayProcsPerfmResultExistsFlag(item) ) {//데이터가 있는 경우 수정
            		this.commonDao.update("LGVPAY00007.updatePayProcsPerfmResult",item);
            		
            	} else {//데이터가 없는 경우 등록
            		this.commonDao.update("LGVPAY00007.insertPayProcsPerfmResult",item);
            	}
            }
    	}
    	return param;
    }
    
    /**
     * Desc : 대상사 생성 전 체크
     * 
     * - 급여담당자 권한이 있는지 체크
     * - Calculation Set 자동 생성여부가 Y 인지 체크(자동 생성인 경우만 대상자 생성 가능함)
     * 
     * @Method Name : validateCreatePayrollTargetEmployee
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateCreatePayrollTargetEmployee(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    	} else {

    		LGCOMData activityData = this.retrievePayrollActivityData(param);
    		if ( !NullUtil.isNull(activityData) ) {
    			if ( !"Y".equals(activityData.getString("runBtnDisplayFlag")) ) {
    				//해당 Calculation Set은 대상자를 자동생성할 수 없습니다.
    	    		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.calcSetCannotCreatePerson", new Object[]{activityData.getString("payrollCalculationSetName")}));
    			}
        	}
    		validateFlag = true;
    	}
    	return validateFlag;
    }

    /**
     * Desc : 급여대상자를 생성한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터가 없는 경우 insert
     * - 급여대상자 생성 프로시저 호출
     * 
     * @Method Name : createPayrollTargetEmployee
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData createPayrollTargetEmployee(LGCOMData param) {
		
    	if ( validateCreatePayrollTargetEmployee(param) ) {//값 체크 정상인 경우 처리
    		if ( !this.retrievePayProcsPerfmResultExistsFlag(param) ) {//데이터가 없는 경우 등록
        		this.commonDao.update("LGVPAY00007.insertPayProcsPerfmResult",param);
        	}
    		
    		//급여 대상자 생성
    		this.commonDao.select("LGVPAY00007.createPayrollTargetEmployee", param);
    	}
    	return param;
    }
    
    /**
     * Desc : 급여 전표 데이터를 생성한다.
     * - 급여담당자 권한이 있는지 체크
     * - 급여작업 Activity 데이터가 있는지 확인
     *   - 데이터가 없는 경우 insert
     * - 급여 전표 데이터 생성 프로시저 호출
     * 
     * @Method Name : insertPayInvoiceIF
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData insertPayInvoiceIF(LGCOMData param) {
		
    	if ( validateParameter(param) ) {//값 체크 정상인 경우 처리
    		if ( !this.retrievePayProcsPerfmResultExistsFlag(param) ) {//데이터가 없는 경우 등록
        		this.commonDao.update("LGVPAY00007.insertPayProcsPerfmResult",param);
        	}
    		
    		LGCOMData secondApprovedFg = this.commonDao.select("LGVPAY00007.retrieveSecondApprovedFlag", param);
    		
    		if( !"Y".equals(secondApprovedFg.get("secondApprovedFlag")) ) {
    			param.set("errcode", "-9000");
    			param.set("errbuf", messageSourceAccessor.getMessage("note.pay.checkSecondApproved"));
    			return param;
    		}
    		
    		//급여 대상자 생성
    		this.commonDao.select("LGVPAY00007.insertPayInvoiceIF", param);
    	}
    	return param;
    }
}
