/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0010Service.java
 * @Desc    : Payroll Run Execution
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 18.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0010.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.lgvpayp0010.service.LGVPAYP0010Service;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.LGVPAYP0010.service.serviceImpl.LGVPAYP0010ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 18.
 * @Version
 */
@Service("LGVPAYP0010Service")
public class LGVPAYP0010ServiceImpl implements LGVPAYP0010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    /**
     * Desc : 급여 실행정보를 등록 전 값 체크 
     * - 급여담당자 권한이 있는지 체크
     * - calculation_set_id, payrollTypeCode, payrollCalcPeriodValue 필수값 체크
     * 
     * @Method Name : validateInsertPayrollCalculationExec
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateInsertPayrollCalculationExec(LGCOMData param) {
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
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 실행정보를 등록한다. 
     * - 급여담당자 권한이 있는지 체크
     * - calculation_set_id, payTypeCode, payMonth 필수값 체크
     * - payrollCalculationExecId seq 조회
     * - tb_pay_calc_exec_n 테이블 insert
     * - payroll run 그룹 개수, 그룹당 인원수 조회
     * - payroll run 그룹 개수별 사번구간 조회
     * 
     * @Method Name : insertPayrollCalculationExec
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData insertPayrollCalculationExec(LGCOMData param) {
    	LGCOMData result = new LGCOMData();
    	    		
    	if ( validateInsertPayrollCalculationExec(param) ) {//값 체크 정상인 경우 처리
    		//payrollCalculationExecId seq 조회
    		LGCOMData seqData = this.commonDao.select("LGVPAYP0010.retrievePayrollCalculationExecId");
    		if ( !NullUtil.isNull(seqData) ) {
	    		param.set( "payrollCalculationExecId", seqData.get("payrollCalculationExecId") );
	    		
	    		//tb_pay_calc_exec_n 테이블 insert
	    		this.commonDao.insert("LGVPAYP0010.insertPayCalcExec", param);
	    		    		
	    		//payroll run 그룹 개수별 사번구간 조회
	    		result.set( "payrollRunSectionList", this.commonDao.selectList("LGVPAYP0010.retrievePayrollRunSectionList", param));
    		}
    	}
    	return result;
    }
}
