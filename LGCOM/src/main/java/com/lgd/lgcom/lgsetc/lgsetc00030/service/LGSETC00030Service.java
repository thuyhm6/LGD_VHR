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
package com.lgd.lgcom.lgsetc.lgsetc00030.service;

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
public interface LGSETC00030Service {
	/**
	 * Desc : Code Value 목록을 조회한다.
	 * @Method Name : retrieveCodeValueList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeValueList(LGCOMData param);

	/**
     * Desc : Code의 다국어 목록을 조회한다.
     * @Method Name : retrieveCodeLangList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCodeLangList(LGCOMData param);
    
    /**
     * Desc : combo 박스의 목록을 조회한다.
     * @Method Name : retrieveGridComboList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveGridComboList(LGCOMData param);
    
    /**
     * Desc : Company Id 목록을 조회한다.
     * @Method Name : retrieveCompanyIdList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCompanyIdList(LGCOMData param);
    
    /**
     * Desc : Oraganization Id 목록을 조회한다.
     * @Method Name : retrieveOrgIdList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveOrgIdList(LGCOMData param);
    
    /**
     * Desc : Code Value의 중복체크를 한다.
     * @Method Name : retrieveCodeValDupChk
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public boolean retrieveCodeValDupChk(LGCOMData param);
    
    /**
     * Desc : Code Value Multi Language의 중복체크를 한다.
     * @Method Name : retrieveLangCodeDupChk
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public boolean retrieveLangCodeDupChk(LGCOMData param);
    
    /**
     * Desc : Code Value 정보을 저장한다.
     * @Method Name : saveCodeValueList
     * @param  param
     * @throws Exception
     */
    public void saveCodeValueList(LGCOMData param);	
    
    /**
     * Desc : Code Value 다국어 정보을 저장한다.
     * @Method Name : saveCodeLangList
     * @param  param
     * @throws Exception
     */
    public void saveCodeLangList(LGCOMData param);
}
