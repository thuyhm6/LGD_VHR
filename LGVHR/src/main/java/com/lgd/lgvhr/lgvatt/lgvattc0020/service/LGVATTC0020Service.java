package com.lgd.lgvhr.lgvatt.lgvattc0020.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTC0020Service.java
 * @Desc    : Calculate Employee Attendance Automatic
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2025.11.11  HMT_20251111    Daily Calculate Employee Attendance
 *------------------------------------------------------------------------------
 */
public interface LGVATTC0020Service {
	
	public LGCOMData executeCalculateEmployeeAttendance(LGCOMData param);

}
