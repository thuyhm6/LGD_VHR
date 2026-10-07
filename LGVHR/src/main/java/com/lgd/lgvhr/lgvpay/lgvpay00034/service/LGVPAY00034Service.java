package com.lgd.lgvhr.lgvpay.lgvpay00034.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
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
 * 	1. 0	2026.07.01     HMT_20260701  Retrieve Annual Leave Sumary Employee List    
 *------------------------------------------------------------------------------
 */
public interface LGVPAY00034Service {
	/**
	 * Desc : Retrieve AL Summary Emp List.
	 * @Method Name : retrieveAlSummaryEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAlSummaryEmpList(LGCOMData param);
    
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);
    /**
     * Desc : 급여대상자 Set에 있는 퇴직자의 연차를 계산하여 보정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : 
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public void caculateAnnualLeave(LGCOMData param) throws LGCOMException;
    
    public List<LGCOMData> createExcelExportData(LGCOMData param);

}
