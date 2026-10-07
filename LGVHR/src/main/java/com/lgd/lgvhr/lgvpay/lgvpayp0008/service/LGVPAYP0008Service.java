/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0008Service.java
 * @Desc    : Payroll Item Use List
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
package com.lgd.lgvhr.lgvpay.lgvpayp0008.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0008.service.LGVPAYP0008Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 11.
 * @Version   
 *
 */
public interface LGVPAYP0008Service {
    
    /**
     * Desc : Payroll Item Use List 를 조회한다.
     * @Method Name : retrievePayrollItemUseList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemUseList(LGCOMData param);

    /**
     * Desc : Payroll Item Use 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 급여항목 수정/삭제 가능여부에 따른 체크
     *   - 삭제 : N인 경우 삭제 불가. Y인 경우만 삭제 가능.
     *   - 수정 : 체크 안함. Y인 경우 수정 가능. N인 경우 effective_end_yyyymmdd만 수정 가능.
     *   - 등록 : 체크 안함. 항상 등록 가능.
     * - 항목의 유효기간 중복 체크
     * 
     * @Method Name : validateSaveUse
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUse(LGCOMData param);

    /**
     * Desc : 급여 항목 Use 등록/수정/삭제한다.
     * - 저장 전 체크
     * - 삭제 건 처리
     *   - Use 항목 삭제
     * - 등록 건 처리
     *   - Use 항목 등록
     * - 수정 건 처리
     *   - Use 항목 수정
     * 
     * @Method Name : saveUse
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData saveUse(LGCOMData param);
    
}
