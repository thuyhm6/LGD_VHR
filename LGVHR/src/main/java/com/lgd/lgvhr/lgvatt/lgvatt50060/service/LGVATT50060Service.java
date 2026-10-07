/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50060Service.java
 * @Desc    : Setup Employee Unpaid Leave Warning
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2025.11.11  HMT_20251111    Employee Unpaid Leave Warning
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50060.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50060.service.LGVATT50040Service.java
 * </PRE>
 *
 * @Author    HMT
 * @Date      2025. 11. 11. 11:06 AM
 * @Version
 */

public interface LGVATT50060Service {
	/**
	 * Desc : Search Employee Unpaid Leave Warning.
	 * @Method Name : retrieveEmpULWarning
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveEmpULWarning(LGCOMData param);
	
	public void cancelSendEmail(LGCOMData param);
	
	public void sendEmail(LGCOMData param);
	
	public void saveEmpUlWarning(LGCOMData param);
	
}
