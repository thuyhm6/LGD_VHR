/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00014Service.java
 * @Desc    : Formula Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 11.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00014.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00014.service.LGVPAY00014Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 11.
 * @Version   
 *
 */
public interface LGVPAY00014Service {
    
    /**
     * Desc : Formula 목록을 조회한다. 
     * @Method Name : retrieveFormulaList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveFormulaList(LGCOMData param);
    
    /**
     * Desc : Formula 정보를 조회한다. 
     * @Method Name : retrieveFormulaData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveFormulaData(LGCOMData param);

    /**
     * Desc : Formula 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목에 이미 등록된 Formula인지 체크
     * - formual program명 중복 체크
     * 
     * @Method Name : validateSaveFormula
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveFormula(LGCOMData param);

    /**
     * Desc : Formula 를 저장한다.
	 * - 값 유효성 체크
	 * - 등록건 처리
	 * - 수정건 처리
	 * - 삭제건 처리
	 *   - Formula 삭제
	 *   - Formula 에 등록된 Detail 전체 삭제
	 *   
     * @Method Name : saveFormulaList
     * @param param
     */
    public LGCOMData saveFormulaList(LGCOMData param);
    
    /**
     * Desc : Formula Detail 목록을 조회한다. 
     * @Method Name : retrieveFormulaDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveFormulaDetailList(LGCOMData param);

    /**
     * Desc : Formula Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목에 이미 등록된 Formula인지 체크
     * - 정렬순서 중복 체크
     * - 파라메터명 중복 체크
     * - OUT 파라메터인 경우 PayrollItemName, PayrollItemDetailName 필수 체크
     * 
     * @Method Name : validateSaveFormulaDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveFormulaDetail(LGCOMData param);

    /**
     * Desc : Formula Detail 저장한다.
	 * - 값 유효성 체크
	 * - 등록건 처리
	 * - 수정건 처리
	 * - 삭제건 처리
	 * 
     * @Method Name : saveFormulaDetailList
     * @param param
     */
    public void saveFormulaDetailList(LGCOMData param);
    
}
