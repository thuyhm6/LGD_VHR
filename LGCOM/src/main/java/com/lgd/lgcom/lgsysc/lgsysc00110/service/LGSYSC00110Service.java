/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00110Service.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 6. 03.  	김치민  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.lgsysc.lgsysc00110.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00110.service.LGSYSC00110Service.java
 * </PRE>
 *
 * @Author    김치민
 * @Date	   2016. 6. 03. 오전 9:53:50
 * @Version   
 */
public interface LGSYSC00110Service {
    /**
     * Desc :  Role 목록을 조회한다.
     * @Method Name : retrieveRoleList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRoleMenuList(LGCOMData param);

    /**
     * Desc :  Role 목록을 저장한다.
     * @Method Name : saveRoleList
     * @param  param
     * @throws Exception
     */
	public void saveRoleMenuList(LGCOMData param);
}
