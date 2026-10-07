/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00035Service.java
 * @Desc    : Payroll Run (Outsourcing - MTH_OS)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2026. 09. 24.   ThuyHM    	LGVPAY00008 기반 LGVPAY00035 생성 (MTH_OS 전용)
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00035.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00035.service.LGVPAY00035Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.LGVPAY00035.service.serviceImpl.LGVPAY00035ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 12.
 * @Version
 */
@Service("LGVPAY00035Service")
public class LGVPAY00035ServiceImpl implements LGVPAY00035Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00035ServiceImpl.class);

	/** LGVPAY00035 화면에서 처리하는 급여유형 (Outsourcing 월급여) */
	static final String PAYROLL_TYPE_CODE = "MTH_OS";

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

    /**
     * Desc : Payroll Run 리스트 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunList(LGCOMData param) {
    	//LGVPAY00035 화면은 MTH_OS 급여유형만 처리
    	param.set( "payrollTypeCode", PAYROLL_TYPE_CODE );
    	return this.commonDao.selectList("LGVPAY00035.retrievePayrollRunList", param);
    }

    /**
     * Desc : Payroll Run별 대상자 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunEmpList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunEmpList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAY00035.retrievePayrollRunEmpList", param);
    }
    
    /**
     * Desc : payroll run rollback 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id 필수값 체크
     * 
     * @Method Name : validateUpdatePayrollRunRollback
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdatePayrollRunRollback(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 실행건을 롤백한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id 필수값 체크
     * - 롤백 프로시저 호출
     * 
     * @Method Name : updatePayrollRunRollback
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updatePayrollRunRollback(LGCOMData param) {
		
    	if ( validateUpdatePayrollRunRollback(param) ) {//값 체크 정상인 경우 처리
    		//급여 롤백 실행
    		this.commonDao.select("LGVPAY00035.updatePayrollRunRollback", param);
    	}
    	return param;
    }
    
	/**
     * Desc : Retroactive payroll run rollback 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id 필수값 체크
     * 
     * @Method Name : validateUpdateRetroactivePayrollRunRollback
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdateRetroactivePayrollRunRollback(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 소급 급여 실행건을 롤백한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id 필수값 체크
     * - 롤백 프로시저 호출
     * 
     * @Method Name : updateRetroactivePayrollRunRollback
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateRetroactivePayrollRunRollback(LGCOMData param) {
		
    	if ( validateUpdateRetroactivePayrollRunRollback(param) ) {//값 체크 정상인 경우 처리
    		//급여 롤백 실행
    		this.commonDao.select("LGVPAY00035.updateRetroactivePayrollRunRollback", param);
    	}
    	return param;
    }
	
    /**
     * Desc : payroll run 건별 retry 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id, employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdatePayrollRunRetry
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdatePayrollRunRetry(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("employeeNo")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.employeeNo"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 실행된 특정 건을 재실행한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id, employeeNo 필수값 체크
     * - 재실행 프로시저 호출
     * 
     * @Method Name : updatePayrollRunRetry
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updatePayrollRunRetry(LGCOMData param) {
		
    	if ( validateUpdatePayrollRunRetry(param) ) {//값 체크 정상인 경우 처리
    		//급여 건별 재실행
    		this.commonDao.select("LGVPAY00035.updatePayrollRunRetry", param);
    	}
    	return param;
    }
	
    /**
     * Desc : Retroactive payroll run 건별 retry 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id, employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdateRetroactivePayrollRunRetry
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdateRetroactivePayrollRunRetry(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("employeeNo")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.employeeNo"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 소급 급여 실행된 특정 건을 재실행한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id, employeeNo 필수값 체크
     * - 재실행 프로시저 호출
     * 
     * @Method Name : updateRetroactivePayrollRunRetry
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateRetroactivePayrollRunRetry(LGCOMData param) {
		
    	if ( validateUpdatePayrollRunRetry(param) ) {//값 체크 정상인 경우 처리
    		//급여 건별 재실행
    		this.commonDao.select("LGVPAY00035.updateRetroactivePayrollRunRetry", param);
    	}
    	return param;
    }
    
    /**
     * Desc : payroll run 건별 rollback 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id, employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdatePayrollRunRollbackEmployee
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdatePayrollRunRollbackEmployee(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("employeeNo")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.employeeNo"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 실행된 특정 건을 롤백한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id, employeeNo 필수값 체크
     * - 롤백 프로시저 호출
     * 
     * @Method Name : updatePayrollRunRollbackEmployee
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updatePayrollRunRollbackEmployee(LGCOMData param) {
		
    	if ( validateUpdatePayrollRunRollbackEmployee(param) ) {//값 체크 정상인 경우 처리
    		//급여 건별 롤백
    		this.commonDao.select("LGVPAY00035.updatePayrollRunRollback", param);
    	}
    	return param;
    }
	

    
    /**
     * Desc : retroactive payroll run 건별 rollback 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalcuilationExecId, calculation_set_id, employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdateRetroactivePayrollRunRollbackEmployee
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdateRetroactivePayrollRunRollbackEmployee(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.executionId"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("calculationSetId")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.calculationSet"), "")));
            	
    		} else if ( NullUtil.isNone(param.getString("employeeNo")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.employeeNo"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 소급 급여 실행된 특정 건을 롤백한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id, employeeNo 필수값 체크
     * - 롤백 프로시저 호출
     * 
     * @Method Name : updateRetroactivePayrollRunRollbackEmployee
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateRetroactivePayrollRunRollbackEmployee(LGCOMData param) {
		
    	if ( validateUpdateRetroactivePayrollRunRollbackEmployee(param) ) {//값 체크 정상인 경우 처리
    		//급여 건별 롤백
    		this.commonDao.select("LGVPAY00035.updateRetroactivePayrollRunRollback", param);
    	}
    	return param;
    }

    /**
     * Desc : 확정된 급여 실행ID조회
     * 
     * @Method Name : validateUpdatePayrollRunRollbackEmployee
     * @param param
     * @return String
     * @throws Exception
     */
    public String retrievePayrollCalculationExecConfirmData(LGCOMData param) {
    	LGCOMData result = this.commonDao.select("LGVPAY00035.retrievePayrollCalculationExecConfirmData", param);
    	
    	if ( NullUtil.isNull(result) ) {
    		return null;
    	} else {
    		return result.getString("payrollCalculationExecId");
    	}
    }
    
    /**
     * Desc : 급여실행 건 확정 전 체크(동일한 payMonth, payType, calculationSetId에 대해 한 건만 확정 가능함)
     * - 급여담당자 권한이 있는지 체크
     * - 급여 실행 확정된 payroll_calculation_exec_id 조회
     *   - NULL : 확정 가능
     *   - 전달된 파라메터와 동일 : 확정 불가능. 해당 건은 이미 확정되었음
     *   - 전달된 파라메터와 다름 : 확정 불가능. 다른 건이 확정되었음
     * 
     * @Method Name : validateUpdatePayrollRunRollbackEmployee
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateConfirmPayrollCalculationExec(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		String payrollCalculationExecId = this.retrievePayrollCalculationExecConfirmData(param);
    		
    		if ( NullUtil.isNone(payrollCalculationExecId) ) {
    			validateFlag = true;
    			
    		} else if ( payrollCalculationExecId.equals(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
    			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.alreadyConfirmExecId"));//해당 건은 이미 확정되었습니다.
    			
    		} else if ( !payrollCalculationExecId.equals(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
    			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.confirmAnotherExecId", StringUtil.split(payrollCalculationExecId, "")));//이미 확정된 건이 존재합니다.(Execution ID={0}
    			
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여실행 건을 확정처리한다.
     * - 확정 가능한지 체크
     * - confirm_flag = Y 변경
     * 
     * @Method Name : updateConfirmPayrollCalculationExec
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateConfirmPayrollCalculationExec(LGCOMData param) {
		
    	if ( validateConfirmPayrollCalculationExec(param) ) {//값 체크 정상인 경우 처리
    		param.set( "confirmFlag", "Y" );
    		//급여 실행 건 확정
    		this.commonDao.select("LGVPAY00035.updateConfirmPayrollCalculationExec", param);
    	}
    	return param;
    }
    
    /**
     * Desc : 급여실행 건 확정취소 전 체크
     * - 급여담당자 권한이 있는지 체크
     * - 급여 실행 확정된 payroll_calculation_exec_id 조회
     *   - NULL : 확정취소 불가능
     *   - 전달된 파라메터와 동일 : 확정취소 가능. 해당 건은 이미 확정되었음
     *   - 전달된 파라메터와 다름 : 확정취소 불가능. 다른 건이 확정되었음
     * 
     * @Method Name : validateCancelConfirmPayrollCalculationExec
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateCancelConfirmPayrollCalculationExec(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		String payrollCalculationExecId = this.retrievePayrollCalculationExecConfirmData(param);
    		
    		if ( NullUtil.isNone(payrollCalculationExecId) || !payrollCalculationExecId.equals(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = false;
    			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.notConfirmExecId"));//확정된 건만 취소할 수 있습니다.
    			
    		} else if ( payrollCalculationExecId.equals(param.getString("payrollCalculationExecId")) ) {
    			validateFlag = true;
    			
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여실행 건을 확정취소 처리한다.
     * - 확정 취소 가능한지 체크
     * - confirm_flag = N 변경
     * 
     * @Method Name : updateCanceleConfirmPayrollCalculationExec
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updateCanceleConfirmPayrollCalculationExec(LGCOMData param) {
		
    	if ( validateCancelConfirmPayrollCalculationExec(param) ) {//값 체크 정상인 경우 처리
    		param.set( "confirmFlag", "N" );
    		//급여 실행 건 확정
    		this.commonDao.select("LGVPAY00035.updateConfirmPayrollCalculationExec", param);
    	}
    	return param;
    }
	
}