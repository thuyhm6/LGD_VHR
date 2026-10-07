/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0006Service.java
 * @Desc    : Payroll Item Detail List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 05.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0006.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0006.service.LGVPAYP0006Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 05.
 * @Version   
 *
 */
public interface LGVPAYP0006Service {
    
    /**
     * Desc : Payroll Item Detail List 를 조회한다.
     * @Method Name : retrievePayrollItemDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemDetailList(LGCOMData param);

    /**
     * Desc : Payroll Item Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 급여항목 수정/삭제 가능여부가 'Y'인지 체크. Y인 경우만 등록, 수정, 삭제 가능함.
     * - 저장할 Detail 항목이 PAY_VALUE인지 체크. PAY_VALUE는 등록, 수정, 삭제 불가능함.
     * - 항목명 중복 체크
     * - 정렬순서번호 중복 체크
     * - 10건 초과인지 체크
     * 
     * @Method Name : validateSaveDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveDetail(LGCOMData param);

    /**
     * Desc : 급여 항목 Detail 등록/수정/삭제한다.
     * - 저장 전 체크
     * - 삭제 건 처리
     *   - Detail 항목 삭제
     * - 등록 건 처리
     *   - Detail 항목 등록
     * - 수정 건 처리
     *   - Detail 항목 수정
     * 
     * @Method Name : saveDetail
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData saveDetail(LGCOMData param);
    
}
