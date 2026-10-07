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
package com.lgd.lgvhr.lgvpay.lgvpay00001.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00001.service.LGVPAY00001Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 4. 오전 10:46:01
 * @Version   
 *
 */
public interface LGVPAY00001Service {
    
    /**
     * Desc : 급여명세서 데이터를 조회한다. 
     * @Method Name : retrievePaySlipData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePaySlipData(LGCOMData param);
    
    /**
     * Desc : 급여담당자가 급여명세서 데이터를 조회한다. 
     * @Method Name : retrieveMasterPaySlipData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveMasterPaySlipData(LGCOMData param);

    /**
     * Desc : Pay Type 리스트를 조회한다.
     * @Method Name : retrievePaySlipPayTypeList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePaySlipPayTypeList(LGCOMData param);

    /**
     * Desc : payrollCalculationExecId 조회한다.(임직원용)
     * @Method Name : retrievePayrollCalcExecIdData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePayrollCalcExecIdData(LGCOMData param);

    /**
     * Desc : 조회할 수 있는 payrollCalculationExecId인지 검증한다.
     * @Method Name : retrieveValidatePayrollCalcExecId
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrieveValidatePayrollCalcExecId(LGCOMData param);
    
    /**
     * Desc : 급여담당자가 조회할 수 있는 payrollCalculationExecId인지 검증한다.
     * @Method Name : retrieveValidateMasterPayrollCalcExecId
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean retrieveValidateMasterPayrollCalcExecId(LGCOMData param);
    
    /**
     * 급여담당자 권한이 있는지 여부 조회
     * 
     * @param param
     * @return boolean
     */
    public boolean retrievePayMasterAuthFlag(LGCOMData param);
    
}
