/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00010ServiceImpl.java
 * @Desc    : Payment Master by Employee
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 21.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00010.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00010.service.LGVPAY00010Service.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 21.
 * @Version
 */
public interface LGVPAY00010Service {
	
	/**
	 * Desc : payment master 정보를 조회한다.
	 * @Method Name : retrievePaymentMasterData
	 * @param  LGCOMData param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrievePaymentMasterData(LGCOMData param);
    
    /**
     * Desc : payment master 저장 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdatePaymentBasicData
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdatePaymentBasicData(LGCOMData param);
    
    /**
     * Desc : payment master 저장 
     * - 급여담당자 권한이 있는지 체크
     * - employeeNo 필수값 체크
     * - 값 수정
     * 
     * @Method Name : updatePaymentBasicData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData updatePaymentBasicData(LGCOMData param);
   
}
