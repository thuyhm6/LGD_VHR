/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00210Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.  jhlee    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00190.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00210.service.LGSYSC00180Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
public interface LGSYSC00190Service {
	/**
	 * Desc : 전체 시스템 메뉴 목록을 인출한다.
	 * @Method Name : retrieveMenuList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMenuList(LGCOMData param);
	
    /**
     * Desc : 프로그램 목록을 인출한다.
     * @Method Name : retrieveProgramList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveProgramList( LGCOMData param);	
    
    /**
     * Desc : 프로그램 항목의 정보를 수정한다. ( update 와 insert 가 함께 수행되므로 주의 ) 
     * @Method Name : updateProgramList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public void updateMenuList( LGCOMData param);     
	

}
