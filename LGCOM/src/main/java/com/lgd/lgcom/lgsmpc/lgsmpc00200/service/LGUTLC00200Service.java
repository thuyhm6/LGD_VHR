/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00200Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 07. 14.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsmpc.lgsmpc00200.service;

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
public interface LGUTLC00200Service {
	/**
	 * Desc : Summary 목록을 조회한다.
	 * @Method Name : sendExecuteRequest
	 * @param  param
	 * @return PagingList<?>
	 * @throws Exception
	 */
	public void sendExecuteRequest(LGCOMData param);
	
	public LGCOMData sendMailTest(LGCOMData param);
	
   
	
}
