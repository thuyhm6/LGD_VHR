/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYCOMMService.java
 * @Desc    : 급여 공통 
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 13.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpaycomm.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 12. 13.
 * @Version   
 *
 */
public interface LGVPAYCOMMService {
	
	/**
	 * Desc : 주어진 조건에 따라 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployee
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveEmployee(LGCOMData param);
    
    /**
     * 급여담당자 권한이 있는지 여부 조회
     * 
     * @param param
     * @return boolean
     */
    public boolean retrievePayMasterAuthFlag(LGCOMData param);
    
    /**
     * 급여 시스템담당자 권한이 있는지 여부 조회
     * 
     * @param param.employeeNo
     * @return boolean
     */
    public boolean retrievePaySystemMasterAuthFlag(LGCOMData param);
    
}
