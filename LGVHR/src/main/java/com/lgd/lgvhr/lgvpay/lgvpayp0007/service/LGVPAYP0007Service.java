/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0007Service.java
 * @Desc    : Payroll Item Property List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 11.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0007.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0007.service.LGVPAYP0007Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 11.
 * @Version   
 *
 */
public interface LGVPAYP0007Service {
    
    /**
     * Desc : Payroll Item Proeprty List 를 조회한다.
     * @Method Name : retrievePayrollItemPropertyList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemPropertyList(LGCOMData param);

    /**
     * Desc : Payroll Item Property 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 급여항목 수정/삭제 가능여부가 'Y'인지 체크. Y인 경우만 수정 가능함.
     * 
     * @Method Name : validateSaveProperty
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveProperty(LGCOMData param);

    /**
     * Desc : 급여 항목 Property 수정한다.
     * - 저장 전 체크
     * - 수정 건 처리
     *   - Detail 항목 수정
     * 
     * @Method Name : saveProperty
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData saveProperty(LGCOMData param);
    
}
