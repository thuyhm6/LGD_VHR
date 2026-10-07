/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00009ServiceImpl.java
 * @Desc    : Payment Master All Employee
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 26.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00009.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00009.service.LGVPAY00009Service.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 26.
 * @Version
 */
public interface LGVPAY00009Service {
	
	/**
	 * Desc : 임직원 급여관련 정보를 조회한다.
	 * @Method Name : retrievePaymentMasterList
	 * @param  LGCOMData param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaymentMasterList(LGCOMData param);
}
