/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00019Service.java
 * @Desc    : User Defined Table Value
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 02. 01.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00019.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00019.service.LGVPAY00019Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 02. 01.
 * @Version   
 *
 */
public interface LGVPAY00019Service {
    
    /**
     * Desc : User Defined Table Value 목록을 조회한다. 
     * @Method Name : retrieveUserDefineTableValueList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineTableValueList(LGCOMData param);

    /**
     * Desc : User Defined Table Value 저장 전 체크 
     * 
     * @Method Name : validateSaveUserDefineTableValue
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveUserDefineTableValue(LGCOMData param);

    /**
     * Desc : User Defined Table Value 를 저장한다.
	 *   
     * @Method Name : saveUserDefineTableValueList
     * @param param
     */
    public LGCOMData saveUserDefineTableValueList(LGCOMData param);
    
}
