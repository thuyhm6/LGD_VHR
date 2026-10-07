/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50040Service.java
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
package com.lgd.lgvhr.lgvatt.lgvatt50040.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50040.service.LGVATT50040Service.java
 * </PRE>
 *
 * @Author    HMS
 * @Date      2021. 03. 17. 11:06 AM
 * @Version
 */

public interface LGVATT50040Service {
	/**
	 * Desc : Search overtime level.
	 * @Method Name : retrieveOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOtLevel(LGCOMData param);
	
	/**
	 * Desc : Search code type.
	 * @Method Name : retrieveHolidayNameList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeType(LGCOMData param);
	
	/**
	 * Desc : Save overtime level manage.
	 * @Method Name : saveOtLevelManage
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */

    public void saveOtLevelManage(LGCOMData param);
}
