package com.lgd.lgvhr.lgvpay.lgvpay00031.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00031Service.java
 * @Desc    : Retrieve Paid Leave Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2026.12.01     HMT_20251201  Retrieve Paid Leave Employee List    
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00031Service {
	/**
	 * Desc : Retrieve Paid Leave Emp List.
	 * @Method Name : retrievePaidLeaveEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveEmpList(LGCOMData param);
	
	/**
     * Desc : Save Paid Leave Emp.
     * @Method Name : savePaidLeaveEmp
     * @param  param
     * @throws Exception
     */
    public void savePaidLeaveEmp(LGCOMData param);
    
    /**
     * Desc : Create Paid Leave Emp Upload.
     * @Method Name : createPaidLeaveEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createPaidLeaveEmpUpload(LGCOMData param);
    
    /**
     * Desc : Delete All PaidLeave In Month.
     * @Method Name : deleteAllPaidLeaveInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllPaidLeaveInMonth(LGCOMData param);
    
    /**
     * Desc : Calculate Attendance Paid Leave.
     * @Method Name : saveCalculateAttendancePL
     * @param  param
     * @throws Exception
     */
    public void saveCalculateAttendancePL(LGCOMData param);
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);
}
