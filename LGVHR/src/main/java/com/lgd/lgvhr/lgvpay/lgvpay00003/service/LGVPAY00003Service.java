/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00003Service.java
 * @Desc    : 개인별 급여항목 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 11.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00003.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpay00003.service.LGVPAY00003Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 11. 오후 16:50:05
 * @Version
 */
public interface LGVPAY00003Service {
	/**
	 * Desc : 개인별 급여항목을 조회한다.
	 * @Method Name : retrievePayRollItemEntByEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePayRollItemEntByEmpList(LGCOMData param);
	
	/**
     * Desc : 개인별 급여항목을 저장한다.
     * @Method Name : savePayrollItem
     * @param  param
     * @throws Exception
     */
    public void savePayrollItem(LGCOMData param);
    
    /**
     * Desc : 기등록된 급여대상 SET을 조회한다.
     * @Method Name : retrieveRegCalEmpChk
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRegCalEmpChk(LGCOMData param);
    
    /**
     * Desc : 행추가된 Detail 정보를 조회한다.
     * @Method Name : retreiveDetailValue
     * @param  param
     * @throws Exception
     */
    public LGCOMData retreiveDetailValue(LGCOMData param);
    
    /**
     * Desc : MULIPLE_FLAG를 조회한다.
     * @Method Name : retreiveMutiFlagCheck
     * @param  param
     * @throws Exception
     */
    public LGCOMData retreiveMutiFlagCheck(LGCOMData param);
    
    /**
     * Desc : applyDate를 조회한다.
     * @Method Name : retrieveApplyDate
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveApplyDate(LGCOMData param);
    
    /**
     * Desc : PayrollApplyFlag를 조회한다.
     * @Method Name : retrievePayrollApplyFlag
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrievePayrollApplyFlag(LGCOMData param);
    
    /**
     * Desc : 급여년월에 퇴직자인지 여부 조회한다.
     * @Method Name : retrieveRetireData
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRetireData(LGCOMData param);

}
