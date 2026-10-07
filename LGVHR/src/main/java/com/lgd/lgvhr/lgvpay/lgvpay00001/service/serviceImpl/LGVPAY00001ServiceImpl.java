/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00001Service.java
 * @Desc    : Pay Slip
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 4.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00001.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00001.service.LGVPAY00001Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.lgvpayp0002.service.LGVPAYP0002Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00001.service.serviceImpl.LGVPAY00001ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 4. 오전 10:46:01
 * @Version
 */
@Service("LGVPAY00001Service")
public class LGVPAY00001ServiceImpl implements LGVPAY00001Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00001ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAYP0002Service")
    private LGVPAYP0002Service lgvpayp0002;

    /**
     * Desc : 급여명세서 데이터를 조회한다.(임직원용)
     * - 세션 사번의 급여명세서 조회
     *  
     * @Method Name : retrievePaySlipData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePaySlipData(LGCOMData param) {
        LOGGER.debug(this.getClass().getName() + ".retrievePaySlipData().param = " + param);
        LGCOMData result = new LGCOMData();
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");

   		param.set( "employeeNo", projectSession.getString("employeeNo"));
	    	
    	if ( NullUtil.isNone(param.getString("payrollCalculationExecId")) ) {//전달된 값이 없는 경우
	   		LGCOMData tempData = this.retrievePayrollCalcExecIdData(param);
	    		
	   		if ( !NullUtil.isNull(tempData) ) {
	   			param.set( "payrollCalculationExecId", tempData.get("code") );
	   			
	   		}
	   		
	   		
	   		
	   	}

        if ( !retrieveValidatePayrollCalcExecId(param) ) {
        	//권한이 없습니다.
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
        	
        } else {
        	
        	//payrollCalculationExecId만 있고, payMonth 또는 payType이 없는 경우 조회하여 셋팅한다.
        	if ( NullUtil.notNone(param.getString("payrollCalculationExecId"))
        			&& (NullUtil.isNone(param.getString("payMonth")) || NullUtil.isNone(param.getString("payType")) ) ) {
        		LGCOMData tempData = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
        		if ( !NullUtil.isNull(tempData) ) {
	    			param.set( "payMonth", tempData.get("payMonthName") );
	    			param.set( "payType", tempData.get("payTypeName") );
        		}
        	}
        	
        	
        	//검색조건 기본값
        	result.set( "searchData", param);
        	//personal info
        	result.set( "employeeData", this.commonDao.select("LGVPAY00001.retrieveEmployeeData", param));
        	//contract salary info
        	result.set( "contractSalaryData", this.commonDao.select("LGVPAY00001.retrieveContractSalaryData", param));
        	//salary detail info
        	result.set( "salaryDetailData", this.commonDao.select("LGVPAY00001.retrieveSalaryDetailData", param));
        	
        	param.set( "incomeDeductionCode", "INCOME");
        	param.set( "incomeDeductionTimeCode", "TIME_N");
        	//income(시간 없는 항목) 상세 리스트
        	result.set( "incomeTimeNList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
        	
        	param.set( "incomeDeductionCode", "INCOME");
        	param.set( "incomeDeductionTimeCode", "TIME_Y");
        	//income(시간 있는 항목) 상세 리스트
        	result.set( "incomeTimeYList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
        	
        	param.set( "incomeDeductionCode", "DEDUCTION");
        	param.set( "incomeDeductionTimeCode", "");
        	//deduction 상세 리스트
        	result.set( "deductionList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
        	
        	//etc - adjustment 리스트
        	result.set( "adjustmentList", this.commonDao.selectList("LGVPAY00001.retrieveAdjustmentList", param));
        	//HMT_20251010 Other Income Input List
        	result.set( "otherIncomeInputList", this.commonDao.selectList("LGVPAY00001.retrieveOtherIncomeInputList", param));
        }
        return result;
    }

    /**
     * Desc : 급여담당자가 급여명세서 데이터를 조회한다.(급여담당자용)
     * - authGroup 여부에 따라 급여담당자 권한이 있는지 여부 체크.
     *   - authGroup = 'MASTER'
     *     - 급여 마스터 권한이 있는지 체크
     *     - 파라메터로 전달된 사번의 급여명세서 조회
     *  
     * @Method Name : retrievePaySlipData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveMasterPaySlipData(LGCOMData param) {
        LOGGER.debug(this.getClass().getName() + ".retrievePaySlipData().param = " + param);
        LGCOMData result = new LGCOMData();
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");

        if ( !retrievePayMasterAuthFlag(param) ) {
        	LOGGER.debug("권한 없음!");
        	//권한이 없습니다.
        	throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
        	
        } else {
	    	//급여담당자 권한인 경우 전달된 사번으로 조회
    		LOGGER.debug("급여담당자!");
    		param.set( "employeeNo", NullUtil.nvl(param.getString("employeeNo"), projectSession.getString("employeeNo")));
	    	
	    	if ( NullUtil.isNone(param.getString("payrollCalculationExecId"))
	    			&& NullUtil.notNone(param.getString("employeeNo"))
	    			&& param.getString("employeeNo").equals(projectSession.getString("employeeNo")) ) {//전달된 값이 없고, 본인 데이터 조회인 경우
	    		//임직원 기준으로 payrollCalculationExecId 조회
	    		LGCOMData tempData = this.retrievePayrollCalcExecIdData(param);
	    		
	    		if ( !NullUtil.isNull(tempData) ) {
	    			param.set( "payrollCalculationExecId", tempData.get("code") );
	    			param.set( "payMonth", tempData.get("payMonth") );
	    			param.set( "payType", tempData.get("payType") );
	    		}
	    	}
	    	
	        if ( !retrieveValidateMasterPayrollCalcExecId(param) ) {
	        	LOGGER.debug("execId 조회 불가능!");
	        	//권한이 없습니다.
	        	throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
	        	
	        } else {
	        	//payrollCalculationExecId만 있고, payMonth 또는 payType이 없는 경우 조회하여 셋팅한다.
	        	if ( NullUtil.notNone(param.getString("payrollCalculationExecId"))
	        			&& (NullUtil.isNone(param.getString("payMonth")) || NullUtil.isNone(param.getString("payType")) ) ) {
	        		LGCOMData tempData = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
	        		if ( !NullUtil.isNull(tempData) ) {
		    			param.set( "payMonth", tempData.get("payMonthName") );
		    			param.set( "payType", tempData.get("payTypeName") );
	        		}
	        	}
	        	
	        	LOGGER.debug("실 데이터 조회!");
	        	//검색조건 기본값
	        	result.set( "searchData", param);
	        	//personal info
	        	result.set( "employeeData", this.commonDao.select("LGVPAY00001.retrieveEmployeeData", param));
	        	//contract salary info
	        	result.set( "contractSalaryData", this.commonDao.select("LGVPAY00001.retrieveContractSalaryData", param));
	        	//salary detail info
	        	result.set( "salaryDetailData", this.commonDao.select("LGVPAY00001.retrieveSalaryDetailData", param));
	        	
	        	param.set( "incomeDeductionCode", "INCOME");
	        	param.set( "incomeDeductionTimeCode", "TIME_N");
	        	//income(시간 없는 항목) 상세 리스트
	        	result.set( "incomeTimeNList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
	        	
	        	param.set( "incomeDeductionCode", "INCOME");
	        	param.set( "incomeDeductionTimeCode", "TIME_Y");
	        	//income(시간 있는 항목) 상세 리스트
	        	result.set( "incomeTimeYList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
	        	
	        	param.set( "incomeDeductionCode", "DEDUCTION");
	        	param.set( "incomeDeductionTimeCode", "");
	        	//deduction 상세 리스트
	        	result.set( "deductionList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryDetailList", param));
	        	
	        	//Etc - Adjustment 리스트
	        	result.set( "adjustmentList", this.commonDao.selectList("LGVPAY00001.retrieveAdjustmentList", param));
	        	//Calculation Detail 리스트
	        	result.set( "calculationDetailList", this.commonDao.selectList("LGVPAY00001.retrieveCalculationDetailList", param));
	        	//Contibution/PIT 리스트
	        	result.set( "contributionPitList", this.commonDao.selectList("LGVPAY00001.retrieveContributionPitList", param));
	        	//Salary Change Info 리스트
	        	result.set( "salaryChangeInfoList", this.commonDao.selectList("LGVPAY00001.retrieveSalaryChangeInfoList", param));
	        	//Retroactive Payroll Detail 리스트
	        	result.set( "retroPayDetailList", this.commonDao.selectList("LGVPAY00001.retrieveRetroPayDetailList", param));
	        	//Other Income Input List
	        	result.set( "otherIncomeInputList", this.commonDao.selectList("LGVPAY00001.retrieveOtherIncomeInputList", param));
	        }
        }
        return result;
    }

    /**
     * Desc : 임직원용 급여명세서의 Pay Type 리스트를 조회한다.
     * @Method Name : retrievePaySlipPayTypeList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePaySlipPayTypeList(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrievePayTypeList().param=>" + param);
    	
    	param.set( "employeeNo", NullUtil.nvl(param.getString("employeeNo"), param.getData("LGVHR_PROJECT_SESSION").getString("employeeNo")));
    	param.set( "languageCode", param.getData(LGCOMConstants.HTTP_SESSION_KEY).get("languageCode"));
    	param.set( "valueSetId", "LGVPAY_PAYSLIP_PAY_TYPE_LIST" );
    	
    	return this.commonDao.executeValueSetQuery(param);
    }

    /**
     * Desc : payrollCalculationExecId 조회한다.(임직원 용)
     * @Method Name : retrievePayrollCalcExecIdData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePayrollCalcExecIdData(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrievePayrollCalcExecIdData().param=>" + param);
    	LGCOMData result = new LGCOMData();
    	
    	List<LGCOMData> payTypeList = retrievePaySlipPayTypeList(param);
    	if ( !NullUtil.isNull(payTypeList) && payTypeList.size() > 0 ) {
    		result = payTypeList.get(0);
    	}
    	return result;
    }

    /**
     * Desc : 조회할 수 있는 payrollCalculationExecId인지 검증한다.
     * @Method Name : retrieveValidatePayrollCalcExecId
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrieveValidatePayrollCalcExecId(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrieveValidatePayrollCalcExecId().param=>" + param);
    	boolean validateFlag = false;
    	
    	if ( NullUtil.notNone(param.getString("payrollCalculationExecId")) ) {
	    	List<LGCOMData> payTypeList = retrievePaySlipPayTypeList(param);
	    	for ( LGCOMData item : LGCOMUtils.emptyIfNull(payTypeList) ) {
	    		if ( param.getString("payrollCalculationExecId").equals(item.getString("code")) ) {
	    			return true;
	    		}
	    	}
    	} else {
    		validateFlag = true;
    	}
    	return validateFlag;
    }

    /**
     * Desc : 급여담당자가 조회할 수 있는 payrollCalculationExecId인지 검증한다.
     * @Method Name : retrieveValidateMasterPayrollCalcExecId
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrieveValidateMasterPayrollCalcExecId(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrieveValidateMasterPayrollCalcExecId().param=>" + param);
    	boolean validateFlag = false;
    	
    	if ( NullUtil.notNone(param.getString("payrollCalculationExecId")) ) {
            if ( !retrievePayMasterAuthFlag(param) ) {
            	//권한이 없습니다.
            	throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
            	
            } else {
		    	LGCOMData result = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
		    	if ( !NullUtil.isNull(result) && param.getString("payrollCalculationExecId").equals(result.getString("payrollCalculationExecId")) ) {
		    		validateFlag = true;
		    	}
            }
    	}
    	return validateFlag;
    }
    
    /**
     * 급여담당자 권한이 있는지 여부 조회
     * 
     * @param param
     * @return boolean
     */
    public boolean retrievePayMasterAuthFlag(LGCOMData param) {
    	//authGroup
    	boolean validateFlag = false;
    	
    	if ( NullUtil.notNone(param.getString("authGroup")) ) {//권한그룹이 있는 경우
    		//권한코드에 급여담당자 권한코드가 있는지 확인
    		validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param);
    	}
    	return validateFlag;
    }
    
}
