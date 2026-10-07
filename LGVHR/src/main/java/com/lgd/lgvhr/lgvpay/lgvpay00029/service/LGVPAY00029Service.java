/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00029Service.java
 * @Desc    : Calculate Severance Allowance
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE           AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.10.10     HMT_20251010  Calculate Severance Allowance                
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00029.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00029.service.LGVPAY00029Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2025. 10. 01.
 * @Version   
 *
 */
public interface LGVPAY00029Service {
	/**
	 * Desc : Retrieve Severance Allowance List.
	 * @Method Name : retrieveSeveranceAllowanceList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveSeveranceAllowanceList(LGCOMData param);
	
	/**
     * Desc : Save Severance Allowance.
     * @Method Name : saveSeveranceAllowance
     * @param  param
     * @throws Exception
     */
    public void saveSeveranceAllowance(LGCOMData param);
    
    /**
     * Desc : retrieve RegSeverance Allowance Chk.
     * @Method Name : retrieveRegSeveranceAllowanceChk
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRegSeveranceAllowanceChk(LGCOMData param);
    
    /**
     * Desc : Create Severance Allowance Upload.
     * @Method Name : createSeveranceAllowanceUpload
     * @param  param
     * @throws Exception
     */
    public void createSeveranceAllowanceUpload(LGCOMData param);
    
    /**
     * Desc : Delete All Severance Allowance In Month.
     * @Method Name : deleteAllSeveranceAllowanceInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllSeveranceAllowanceInMonth(LGCOMData param);
    
    /**
     * Desc : Apply All Severance Allowance In Month.
     * @Method Name : applyAllSeveranceAllowanceInMonth
     * @param  param
     * @throws Exception
     */
    public void applyAllSeveranceAllowanceInMonth(LGCOMData param);
    
    /**
     * Desc : Calculate Severance Allowance In Month.
     * @Method Name : saveCalculateSeveranceAllowance
     * @param  param
     * @throws Exception
     */
    public void saveCalculateSeveranceAllowance(LGCOMData param);
    
    /**
     * Desc : .
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);
    
}
