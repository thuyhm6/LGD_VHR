package com.lgd.lgvhr.lgvpay.lgvpay00032.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00032Service.java
 * @Desc    : Paid Leave Payment Calculation (PL_SW / PL_PLP)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List
 * 	1. 1	2026.10.26     HMT           Rebuild : calculation by rate setup (LGVPAY00033)
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00032Service {
	/**
	 * Desc : 월 계산결과 조회 (사번 / PL 코드 / Tier)
	 * @Method Name : retrievePaidLeaveHours
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveHours(LGCOMData param);

	/**
	 * Desc : 일별 상세 조회
	 * @Method Name : retrievePaidLeaveDaily
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveDaily(LGCOMData param);

	/**
	 * Desc : Paid Leave 지급액 계산
	 * @Method Name : saveCalculatePaidLeave
	 * @param  param
	 * @throws Exception
	 */
	public void saveCalculatePaidLeave(LGCOMData param);

	/**
	 * Desc : 엑셀 다운로드
	 * @Method Name : createExcelExportData
	 * @param  param
	 * @throws Exception
	 */
	public List<LGCOMData> createExcelExportData(LGCOMData param);
}
