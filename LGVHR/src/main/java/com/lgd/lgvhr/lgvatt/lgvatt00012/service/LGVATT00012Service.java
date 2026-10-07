package com.lgd.lgvhr.lgvatt.lgvatt00012.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT00012Service.java
 * @Desc    : Create Request for OS KPI
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2026.04.01  HMT_20260401    Writing the first program
 *------------------------------------------------------------------------------
 */
public interface LGVATT00012Service {
	/**
	 * retrieve OS KPI Request List
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveOsKPIRequestList(LGCOMData param) throws LGCOMException;
}
