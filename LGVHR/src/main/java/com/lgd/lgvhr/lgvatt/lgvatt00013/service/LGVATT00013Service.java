/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt00013Service.java
 * @Desc    : OS KPI Standard
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2026. 04. 01.    HMS    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00013.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT00013Service {
	/**
	 * Desc : Search OS KPI Standard.
	 * @Method Name : retrieveOsKpiStandard
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOsKpiStandard(LGCOMData param);
	
	/**
	 * Desc : Save OS KPI Standard.
	 * @Method Name : saveOsKpiStandardManage
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */

    public void saveOsKpiStandard(LGCOMData param);
}
