/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00015Service.java
 * @Desc    : Aggregate Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 18.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00015.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00015.service.LGVPAY00015Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 18.
 * @Version   
 *
 */
public interface LGVPAY00015Service {
    
    /**
     * Desc : Aggregate 목록을 조회한다. 
     * @Method Name : retrieveAggregateList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveAggregateList(LGCOMData param);
    
    /**
     * Desc : Aggregate 정보를 조회한다. 
     * @Method Name : retrieveAggregateData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveAggregateData(LGCOMData param);

    /**
     * Desc : Aggregate 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목에 이미 등록된 Aggregate인지 체크
     * - aggregate 중복 체크
     * 
     * @Method Name : validateSaveAggregate
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveAggregate(LGCOMData param);

    /**
     * Desc : Aggregate 를 저장한다.
	 * - 값 유효성 체크
	 * - 등록건 처리
	 * - 수정건 처리
	 * - 삭제건 처리
	 *   - Aggregate 삭제
	 *   - Aggregate 에 등록된 Detail 전체 삭제
	 *   
     * @Method Name : saveAggregateList
     * @param param
     */
    public LGCOMData saveAggregateList(LGCOMData param);
    
    /**
     * Desc : Aggregate Detail 목록을 조회한다. 
     * @Method Name : retrieveAggregateDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveAggregateDetailList(LGCOMData param);

    /**
     * Desc : Aggregate Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목에 이미 등록된 Aggregate인지 체크
     * - 정렬순서 중복 체크
     * - 파라메터명 중복 체크
     * - OUT 파라메터인 경우 PayrollItemName, PayrollItemDetailName 필수 체크
     * 
     * @Method Name : validateSaveAggregateDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveAggregateDetail(LGCOMData param);

    /**
     * Desc : Aggregate Detail 저장한다.
	 * - 값 유효성 체크
	 * - 등록건 처리
	 * - 수정건 처리
	 * - 삭제건 처리
	 * 
     * @Method Name : saveAggregateDetailList
     * @param param
     */
    public void saveAggregateDetailList(LGCOMData param);
    
}
