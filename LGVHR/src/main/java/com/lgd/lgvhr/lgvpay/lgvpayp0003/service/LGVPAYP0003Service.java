/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpayp0003Service.java
 * @Desc    : Payroll Item 조회 팝업
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 12.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0003.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpayp0001.service.LGVPAYP0001Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 12. 오후 16:33:32
 * @Version
 */
public interface LGVPAYP0003Service {
	/**
	 * Desc : Payroll Item를 조회한다.
	 * @Method Name : retrievePayrollItemList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePayrollItemList(LGCOMData param);


}
