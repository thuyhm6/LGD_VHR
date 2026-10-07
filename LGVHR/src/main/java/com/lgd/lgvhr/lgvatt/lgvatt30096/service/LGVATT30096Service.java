package com.lgd.lgvhr.lgvatt.lgvatt30096.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT30096Service.java
 * @Desc    : Create Request For Flexible Working
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2026.01.01  HMT_20260101    Writing the first program
 *------------------------------------------------------------------------------
 */
public interface LGVATT30096Service {
	/**
	 * retrieve Flexible Working Request List
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveFlexibleWorkingRequestList(LGCOMData param) throws LGCOMException;
}
