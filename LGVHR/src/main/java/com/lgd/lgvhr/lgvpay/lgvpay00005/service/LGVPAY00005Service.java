/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00005Service.java
 * @Desc    : 급여대상자 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00005.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpay00005.service.LGVPAY00005Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 05. 오후 15:44:32
 * @Version
 */
public interface LGVPAY00005Service {
	/**
	 * Desc : 급여대상자를 조회한다.
	 * @Method Name : retrieveCalSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalSetEmpList(LGCOMData param);
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveCalSetEmp
     * @param  param
     * @throws Exception
     */
    public void saveCalSetEmp(LGCOMData param);
    
    /**
     * Desc : 기등록된 급여대상 SET을 조회한다.
     * @Method Name : retrieveRegCalEmpChk
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRegCalEmpChk(LGCOMData param);
    
    /**
     * Desc : 엑셀업로드.
     * @Method Name : createCalEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createCalEmpUpload(LGCOMData param);
    
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);

}
