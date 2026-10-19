/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00036Service.java
 * @Desc    : 급여항목별 개인조회, 수정 (OS 직원 : Grade L34) - Payroll Item By OS Item
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    bakderia    최초 프로그램 작성
 *  1. 1    2026. 10. 11.    thuyhm6     LGVPAY00004 복사, Grade L34 직원만 조회/처리
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00036.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpay00036.service.LGVPAY00036Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 05. 오후 15:44:32
 * @Version
 */
public interface LGVPAY00036Service {
	/**
	 * Desc : 개인별 급여항목을 조회한다.
	 * @Method Name : retrieveItemTotalUploadList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveIndividualPayItemList(LGCOMData param);
	
	 /**
     * Desc : 엑셀 다운로드 전 count
     * @Method Name : retrieveDownloadCount
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveDownloadCount(LGCOMData param);
    
	/**
     * Desc : 개인별 급여항목을 저장한다.
     * @Method Name : saveIndividualPayItem
     * @param  param
     * @throws Exception
     */
	public void saveIndividualPayItem(LGCOMData param);
	
	/**
     * Desc : 개인별 급여항목을 전체 삭제한다.
     * @Method Name : retrieveStartEndDate
     * @param  param
     * @throws Exception
     */
	public void saveAllIndividualPayItem(LGCOMData param);
	
	/**
     * Desc : 엑셀업로드.
     * @Method Name : createCalEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createIndividualPayItemUpload(LGCOMData param);

}
