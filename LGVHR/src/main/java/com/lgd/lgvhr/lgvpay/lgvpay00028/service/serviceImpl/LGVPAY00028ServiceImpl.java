/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00028Service.java
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
package com.lgd.lgvhr.lgvpay.lgvpay00028.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00028.service.LGVPAY00028Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.lgvpayp0002.service.LGVPAYP0002Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00028.service.serviceImpl.LGVPAY00028ServiceImpl.java
 * </PRE>
 *
 * @Author    Sangnv
 * @Date      2024. 16. 4
 * @Version
 */
@Service("LGVPAY00028Service")
public class LGVPAY00028ServiceImpl implements LGVPAY00028Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00028ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAYP0002Service")
    private LGVPAYP0002Service lgvpayp0002;

    /**
     * @Method Name : retrievePaySlipData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePaySlipData(LGCOMData param) {
        LOGGER.debug(this.getClass().getName() + ".retrievePaySlipData().param = " + param);
        LGCOMData result = new LGCOMData();
        result.set( "payrollInforList", this.commonDao.selectList("LGVPAY00028.retrievePayrollInfoData", param));
        result.set( "totalSalaryInfor", this.commonDao.selectList("LGVPAY00028.retrieveTotalSalaryInfoData", param));
        result.set( "totalBankInforList", this.commonDao.selectList("LGVPAY00028.retrieveTotalBankInfoData", param));
        return result;
    }

    /**
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
		    	LGCOMData result = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
		    	if ( !NullUtil.isNull(result) && param.getString("payrollCalculationExecId").equals(result.getString("payrollCalculationExecId")) ) {
		    		validateFlag = true;
		    	}
    	}
    	return validateFlag;
    }
    
}
