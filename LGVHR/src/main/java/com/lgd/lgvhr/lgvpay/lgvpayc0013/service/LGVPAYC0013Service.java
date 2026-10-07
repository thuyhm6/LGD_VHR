/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0013Service.java
 * @Desc    : Payroll Run ( 급여 실행하기 위한 프로그램, 사번 구간을 넘김)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2017.11.21  손수양      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayc0013.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * Desc :  Payroll 을 사번구간을 넣어서 Run 하는 프로그램 
 * @Author    손수양
 * @Date      2017. 11. 21. 오전 9:00:58
 * @Version
 */
public interface LGVPAYC0013Service {
	/**
	 * Desc : Payroll 을 사번구간을 넣어서 Run 하는 프로그램
	 * @Method Name : executePayrollRun
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	
	
	public LGCOMData executePayrollRun(LGCOMData param);

}
