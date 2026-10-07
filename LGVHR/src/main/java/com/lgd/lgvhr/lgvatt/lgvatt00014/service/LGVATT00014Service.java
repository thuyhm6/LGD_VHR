/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt00013Service.java
 * @Desc    : Bonus KPI for OS
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
package com.lgd.lgvhr.lgvatt.lgvatt00014.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT00014Service {
	/**
	 * Desc : Search Bonus KPI for OS.
	 * @Method Name : retrieveBonusKpiForOs
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBonusKpiForOs(LGCOMData param);
	
	/**
	 * Desc : Save Bonus KPI for OS.
	 * @Method Name : saveBonusKpiForOs
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */

    public void saveBonusKpiForOs(LGCOMData param);

}
