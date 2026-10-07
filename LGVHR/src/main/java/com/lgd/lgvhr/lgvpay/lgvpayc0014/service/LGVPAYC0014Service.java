/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0014Service.java
 * @Desc    : Retroactive Payroll Run ( 소급 급여 실행하기 위한 프로그램, 사번 구간을 넘김)
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2018.10.10  이형준      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayc0014.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * Desc :  Retroactive Payroll 을 사번구간을 넣어서 Run 하는 프로그램 
 * @Author    이형준
 * @Date      2018. 10. 10. 오전 9:00:58
 * @Version
 */
public interface LGVPAYC0014Service {
	/**
	 * Desc : Retroactive Payroll 을 사번구간을 넣어서 Run 하는 프로그램
	 * @Method Name : executeRetroactivePayrollRun
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	
	
	public LGCOMData executeRetroactivePayrollRun(LGCOMData param);

}
