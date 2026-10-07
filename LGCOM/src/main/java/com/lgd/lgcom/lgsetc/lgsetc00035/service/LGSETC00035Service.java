/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00035Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 21.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00035.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00035.service.LGSETC00035Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 21. 오전 9:00:58
 * @Version
 */
public interface LGSETC00035Service {
	/**
	 * Desc : Value Set 목록을 조회한다.
	 * @Method Name : retrieveCodeValSetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeValSetList(LGCOMData param);

    /**
     * Desc : Value Set 정보을 저장한다.
     * @Method Name : saveCodeValSetList
     * @param  param
     * @throws Exception
     */
    public void saveCodeValSetList(LGCOMData param);
    
    /**
     * Desc : Value Set 중복체크를 한다.
     * @Method Name : retrieveValueSetIdChk
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveValueSetIdChk(LGCOMData param);
}
