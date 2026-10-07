/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00023Service.java
 * @Desc    : Annual Leave Adj. for Retiree
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 03. 14.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00023.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00023.service.LGVPAY00023Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 03. 14.
 * @Version   
 *
 */
public interface LGVPAY00023Service {
    
    /**
     * Desc : 확정된 급여실적이 있는지 조회한다.
     * @Method Name : retrieveConfirmExistsData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveConfirmExistsData(LGCOMData param);
    
    /**
     * Desc : 급여 대상자 중 퇴직자의 연차 정보 조회한다. 
     * @Method Name : retrieveRetireeAnnualLeaveList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRetireeAnnualLeaveList(LGCOMData param);
    
    /**
     * Desc : 퇴직자 연차 계산 전 체크
     * 
     * @Method Name : validateSaveCalculateAnnualLeave
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveCalculateAnnualLeave(LGCOMData param);
    
    /**
     * Desc : 급여대상자 Set에 있는 퇴직자의 연차를 계산하여 보정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : saveCalculateAnnualLeave
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData saveCalculateAnnualLeave(LGCOMData param);
    
    /**
     * Desc : 퇴직자 보상년차 수정 체크
     * 
     * @Method Name : validateUpdateAnnualLeave
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdateAnnualLeave(LGCOMData param);
    
    /**
     * Desc : 퇴직자 보상년차를 수정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : updateAnnualLeave
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData updateAnnualLeave(LGCOMData param);
    
}
