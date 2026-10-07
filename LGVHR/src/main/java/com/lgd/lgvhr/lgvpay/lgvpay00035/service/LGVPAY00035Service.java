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
 * 	1. 0	2017. 12. 12.  	limsujin  	최초 프로그램 작성                                     
 * 	1. 1	2026. 09. 24.  	          	LGVPAY00008 기반 LGVPAY00035 생성 (MTH_OS 전용)
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00035.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.LGVPAY00035.service.LGVPAY00035Service.java
 * </PRE>
 * 
 * @author      ThuyHM
 * @Date	   2026. 09. 12.
 * @Version   
 *
 */
public interface LGVPAY00035Service {
    
    /**
     * Desc : Payroll Run 리스트 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunList(LGCOMData param);
    
    /**
     * Desc : Payroll Run 별 대상자 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunEmpList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunEmpList(LGCOMData param);
    
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
    public boolean validateUpdatePayrollRunRollback(LGCOMData param);
    
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
    public LGCOMData updatePayrollRunRollback(LGCOMData param);
    
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
    public boolean validateUpdateRetroactivePayrollRunRollback(LGCOMData param);
    
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
    public LGCOMData updateRetroactivePayrollRunRollback(LGCOMData param);
    
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
    public boolean validateUpdatePayrollRunRetry(LGCOMData param);
    
    /**
     * Desc : 급여 실행된 특정 건을 재실행한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id 필수값 체크
     * - 재실행 프로시저 호출
     * 
     * @Method Name : updatePayrollRunRetry
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData updatePayrollRunRetry(LGCOMData param);
    
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
    public boolean validateUpdateRetroactivePayrollRunRetry(LGCOMData param);
    
    /**
     * Desc : 소급 급여 실행된 특정 건을 재실행한다. 
     * - 급여담당자 권한이 있는지 체크
     * - payrollCalculationExecId, calculation_set_id 필수값 체크
     * - 재실행 프로시저 호출
     * 
     * @Method Name : updateRetroactivePayrollRunRetry
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData updateRetroactivePayrollRunRetry(LGCOMData param);
    
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
    public boolean validateUpdatePayrollRunRollbackEmployee(LGCOMData param);

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
    public LGCOMData updatePayrollRunRollbackEmployee(LGCOMData param);
    
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
    public boolean validateUpdateRetroactivePayrollRunRollbackEmployee(LGCOMData param);

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
    public LGCOMData updateRetroactivePayrollRunRollbackEmployee(LGCOMData param);

    /**
     * Desc : 확정된 급여 실행ID조회
     * 
     * @Method Name : validateUpdatePayrollRunRollbackEmployee
     * @param param
     * @return String
     * @throws Exception
     */
    public String retrievePayrollCalculationExecConfirmData(LGCOMData param);
    
    /**
     * Desc : 급여실행 건 확정 전 체크
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
    public boolean validateConfirmPayrollCalculationExec(LGCOMData param);
    
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
    public LGCOMData updateConfirmPayrollCalculationExec(LGCOMData param);
    
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
    public boolean validateCancelConfirmPayrollCalculationExec(LGCOMData param);
    
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
    public LGCOMData updateCanceleConfirmPayrollCalculationExec(LGCOMData param);
    
}
