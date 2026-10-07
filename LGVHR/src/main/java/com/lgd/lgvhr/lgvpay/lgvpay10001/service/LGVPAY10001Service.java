/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY10001Service.java
 * @Desc    : Global Value
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 9. 27.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpay10001.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay10001.service.LGVPAY10001Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 9. 27. 오후 3:20:43
 * @Version   
 *
 */
public interface LGVPAY10001Service {
    
    /**
     * Desc : Global Value 목록을 조회한다. 
     * @Method Name : retrieveGlobalValueList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveGlobalValueList(LGCOMData param);
    
    /**
     * Desc : Global Value 값 중복여부를 조회한다.
     * @Method Name : retrieveGlobalValue
     * @param param
     * @return
     */
    public boolean retrieveGlobalValueDupChk(LGCOMData param);

    /**
     * Desc : Global Value 를 저장한다.
     * @Method Name : saveGlobalValueList
     * @param param
     */
    public void saveGlobalValueList(LGCOMData param);
    
    /**
     * Desc : Global Value 이력 목록을 조회한다. 
     * @Method Name : retrieveGlobalValueHistoryList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveGlobalValueHistoryList(LGCOMData param);
    
    /**
     * Desc : Global Value History 저장 전 체크 
     * @Method Name : validateSaveGlobalValueHistoryList
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveGlobalValueHistoryList(LGCOMData param);

    /**
     * Desc : Global Value 이력를 저장한다.
     * @Method Name : saveGlobalValueHistoryList
     * @param param
     */
    public void saveGlobalValueHistoryList(LGCOMData param);
    
}
