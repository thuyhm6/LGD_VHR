/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00205Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 5. 10.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00205.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00205.service.LGUTLC00205Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2017. 5. 10. 오후 4:35:58
 * @Version
 */ 
public interface LGUTLC00205Service {
	/**
	* Desc : Custom Query를 받아 수행하고 결과를 반환한다.
	* @Method Name : saveExecuteCustomQuery
	* @param  param
	* @return LGCOMData
	* @throws Exception
	*/
	public LGCOMData saveExecuteCustomQuery(LGCOMData param);
}
