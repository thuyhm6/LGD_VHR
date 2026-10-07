/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt00023Service.java
 * @Desc    : Setup OT level
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2021. 03. 17.    HMS    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00023.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt00023.service.LGVATT00023Service.java
 * </PRE>
 *
 * @Author    HMS
 * @Date      2021. 03. 17. 11:06 AM
 * @Version
 */

public interface LGVATT00023Service {
	/**
	 * Desc : Search Vendor Infomation.
	 * @Method Name : retrieveVendorInfomation
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveVendorInfomation(LGCOMData param);
	
	/**
	 * Desc : Save Vendor Infomation.
	 * @Method Name : saveVendorInfomationManage
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */

    public void saveVendorInfomation(LGCOMData param);
}
