/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00060Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00010.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00060.service.LGSETC00060Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 5. 23. 오전 9:00:58
 * @Version
 */
public interface LGSETC00010Service {
	/**
	 * Desc : Code Type 목록을 조회한다.
	 * @Method Name : retrieveCodeTypeList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeTypeList(LGCOMData param);

	/**
     * Desc : Code Type에 대한 role목록을 조회한다.
     * @Method Name : retrieveCodeTypeRoleList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCodeTypeRoleList(LGCOMData param);
    
    /**
     * Desc :  Code Type Code 중복체크 한다.
     * @Method Name : retrieveCodeTypeCode
     * @param  param
     * @throws Exception
     */
    public boolean retrieveCodeTypeCode(LGCOMData param);
    
    /**
     * Desc :  Role Code By CodeTypeCode 중복체크 한다.
     * @Method Name : retrieveRoleByCodeTypeCode
     * @param  param
     * @throws Exception
     */
    public boolean retrieveRoleByCodeTypeCode(LGCOMData param);
    
    /**
     * Desc : Code Type 정보을 저장한다.
     * @Method Name : saveCodeTypeList
     * @param  param
     * @throws Exception
     */
    public void saveCodeTypeList(LGCOMData param);	
    
    /**
     * Desc : Code Type에 대한 role목록을 저장한다.
     * @Method Name : saveCodeTypeRoleList
     * @param  param
     * @throws Exception
     */
    public void saveCodeTypeRoleList(LGCOMData param);
}
