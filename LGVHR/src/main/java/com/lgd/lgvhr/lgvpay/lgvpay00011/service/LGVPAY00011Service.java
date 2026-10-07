/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00011Service.java
 * @Desc    : 명세서 오픈일 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 21.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00011.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpay00011.service.LGVPAY00011Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 21. 오후 18:24:05
 * @Version
 */
public interface LGVPAY00011Service {
	/**
	 * Desc : 명세서 오픈일을 조회한다.
	 * @Method Name : retrievePaySlipOpenDateMngList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaySlipOpenDateMngList(LGCOMData param);
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : savePaySlipOpenDateMng
     * @param  param
     * @throws Exception
     */
    public void savePaySlipOpenDateMng(LGCOMData param);
}
