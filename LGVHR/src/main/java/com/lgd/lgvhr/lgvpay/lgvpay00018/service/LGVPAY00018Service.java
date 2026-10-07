/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00018Service.java
 * @Desc    : User Defined Table Row
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 29.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay00018.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00018.service.LGVPAY00018Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 29.
 * @Version   
 *
 */
public interface LGVPAY00018Service {
    
    /**
     * Desc : User Defined Table Row 목록을 조회한다. 
     * @Method Name : retrieveUserDefineTableRowList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineTableRowList(LGCOMData param);

    /**
     * Desc : User Defined Table Row 저장 전 체크 
     * 
     * @Method Name : validateSaveUserDefineTableRow
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveUserDefineTableRow(LGCOMData param);

    /**
     * Desc : User Defined Table Row 를 저장한다.
	 *   
     * @Method Name : saveUserDefineTableRowList
     * @param param
     */
    public LGCOMData saveUserDefineTableRowList(LGCOMData param);
    
}
