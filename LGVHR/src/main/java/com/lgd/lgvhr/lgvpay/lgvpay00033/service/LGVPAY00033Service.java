package com.lgd.lgvhr.lgvpay.lgvpay00033.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00033Service.java
 * @Desc    : Paid Leave Payment Rate Setup (PL_SW / PL_PLP)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Perfect Actual
 * 	1. 1	2026.10.26     HMT           Rebuild : payment rate setup / payroll item mapping
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00033Service {
	/**
	 * Desc : 지급률 조회
	 * @Method Name : retrievePlRateList
	 */
	public List<LGCOMData> retrievePlRateList(LGCOMData param);

	/**
	 * Desc : 지급률 저장
	 * @Method Name : savePlRate
	 */
	public void savePlRate(LGCOMData param);

	/**
	 * Desc : 급여항목 매핑 조회
	 * @Method Name : retrievePlItemMapList
	 */
	public List<LGCOMData> retrievePlItemMapList(LGCOMData param);

	/**
	 * Desc : 급여항목 매핑 저장
	 * @Method Name : savePlItemMap
	 */
	public void savePlItemMap(LGCOMData param);

	/**
	 * Desc : 급여항목 콤보
	 * @Method Name : retrievePayrollItemList
	 */
	public List<LGCOMData> retrievePayrollItemList(LGCOMData param);
}
