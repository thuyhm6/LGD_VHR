/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0000Service.java
 * @Desc    : 급여 Batch Service 등록 
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
package com.lgd.lgvhr.lgvpay.lgvpayc0000.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00200.service.LGUTLC00200Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 07. 14. 오후 1:39:58
 * @Version
 */
public interface LGVPAYC0000Service {
	/**
	 * Desc : Summary 목록을 조회한다.
	 * @Method Name : sendExecuteRequest
	 * @param  param
	 * @return PagingList<?>
	 * @throws Exception
	 */
	public void sendExecuteRequest(LGCOMData param);
   
	
}
