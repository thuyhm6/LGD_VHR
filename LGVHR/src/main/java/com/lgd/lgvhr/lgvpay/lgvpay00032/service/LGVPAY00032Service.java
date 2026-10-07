package com.lgd.lgvhr.lgvpay.lgvpay00032.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00032Service.java
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
public interface LGVPAY00032Service {
	/**
	 * Desc : Retrieve Paid Leave Hours.
	 * @Method Name : retrievePaidLeaveEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveHours(LGCOMData param);

}
