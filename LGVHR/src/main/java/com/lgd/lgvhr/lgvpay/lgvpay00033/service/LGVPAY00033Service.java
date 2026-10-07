package com.lgd.lgvhr.lgvpay.lgvpay00033.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00033Service.java
 * @Desc    : Retrieve Paid Leave Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List    
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00033Service {
	/**
	 * Desc : Retrieve Perfect Actual.
	 * @Method Name : retrievePerfectActual
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePerfectActual(LGCOMData param);
}
