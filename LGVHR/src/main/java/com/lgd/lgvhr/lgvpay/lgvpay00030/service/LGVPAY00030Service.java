package com.lgd.lgvhr.lgvpay.lgvpay00030.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00030Service.java
 * @Desc    : Retrieve Other Income Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.10.10     HMT_20251010  Retrieve Other Income Employee List    
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00030Service {
	/**
	 * Desc : Retrieve Other Income Emp List.
	 * @Method Name : retrieveOtherIncomeEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOtherIncomeEmpList(LGCOMData param);
	
	/**
     * Desc : Save Other Income Emp.
     * @Method Name : saveOtherIncomeEmp
     * @param  param
     * @throws Exception
     */
    public void saveOtherIncomeEmp(LGCOMData param);
    
    /**
     * Desc : Create Other Income Emp Upload.
     * @Method Name : createOtherIncomeEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createOtherIncomeEmpUpload(LGCOMData param);
    
    /**
     * Desc : Delete All OtherIncome In Month.
     * @Method Name : deleteAllOtherIncomeInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllOtherIncomeInMonth(LGCOMData param);
    
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);
}
