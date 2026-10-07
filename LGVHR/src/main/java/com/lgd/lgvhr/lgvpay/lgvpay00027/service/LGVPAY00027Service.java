/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00027Service.java
 * @Desc    : Payroll Item List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 04.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00027.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00027.service.LGVPAY00027Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 04.
 * @Version   
 *
 */
public interface LGVPAY00027Service {
    
    /**
     * Desc : Payroll Item List 를 조회한다.
     * @Method Name : retrievePayrollItemList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveAllowanceMappingList(LGCOMData param);
    
    /**
     * Desc : 급여 항목을 등록/수정/삭제한다.
     * - 급여 시스템 담당자 권한 보유여부 체크
     * - 급여항목 삭제건 처리.(급여항목 중복 체크 시 화면에서 삭제한 건은 제외하고 체크하기 위해 가장 먼저 수행함)
     * - 급여항목 등록건 처리
     *   - 급여항목명 중복 체크
     *   - 급여항목 시퀀스 조회
     *   - 급여항목 신규등록
     *   - 급여항목 Detail 등록. PAY_VALUE 있는 class_code인 경우 PAY_VALUE 기본값 등록
     *   - 급여항목 Property 등록. 일괄 N으로 등록하고 사용자가 수정하도록 함.
     * - 급여항목 수정건 처리
     *   - 급여항목 수정
     *   - 급여항목 Detail에 PAY_VALUE 등록 및 삭제
     *     - PAY_VALUE 있는 class_code인 경우 Detail 에 없으면 등록, 있는 경우 변경하지 않음.
     *     - PAY_VALUE 없는 class_code인 경우 Detail 에 있으면 삭제, 없는 경우 추가하지 않음.
     * 
     * @Method Name : savePayrollItem
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData saveAllowanceMapping(LGCOMData param);
     
    
}
