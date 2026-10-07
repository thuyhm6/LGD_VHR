/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpayp0001Service.java
 * @Desc    : 급여대상자 SET 조회
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
package com.lgd.lgvhr.lgvpay.lgvpayp0001.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpayp0001.service.LGVPAYP0001Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 05. 오후 15:44:32
 * @Version
 */
public interface LGVPAYP0001Service {
	/**
	 * Desc : 급여대상자 SET 을 조회한다.
	 * @Method Name : retrieveAttendanceClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalculationSetList(LGCOMData param);


}
