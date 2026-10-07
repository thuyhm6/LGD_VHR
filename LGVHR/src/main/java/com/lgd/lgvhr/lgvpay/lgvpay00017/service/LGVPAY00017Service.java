/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00017Service.java
 * @Desc    : User Defined Table/Column
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
package com.lgd.lgvhr.lgvpay.lgvpay00017.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00017.service.LGVPAY00017Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2018. 01. 29.
 * @Version   
 *
 */
public interface LGVPAY00017Service {
    
    /**
     * Desc : User Defined Table 목록을 조회한다. 
     * @Method Name : retrieveUserDefineTableList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineTableList(LGCOMData param);
    
    /**
     * Desc : User Defined Table 정보를 조회한다. 
     * @Method Name : retrieveUserDefineTableData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveUserDefineTableData(LGCOMData param);

    /**
     * Desc : User Defined Table 저장 전 체크 
     * 
     * @Method Name : validateSaveUserDefineTable
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSaveUserDefineTable(LGCOMData param);

    /**
     * Desc : User Defined Table을 저장한다.
	 *   
     * @Method Name : saveUserDefineTableList
     * @param param
     */
    public LGCOMData saveUserDefineTableList(LGCOMData param);
    
    /**
     * Desc : User Defined Column 목록을 조회한다. 
     * @Method Name : retrieveUserDefineColumnList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineColumnList(LGCOMData param);

    /**
     * Desc : User Defined Column 저장 전 체크 
     * 
     * @Method Name : validateSaveUserDefineColumn
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUserDefineColumn(LGCOMData param);

    /**
     * Desc : User Defined Column 저장한다.
	 * 
     * @Method Name : saveUserDefineColumnList
     * @param param
     */
    public void saveUserDefineColumnList(LGCOMData param);
    
}
