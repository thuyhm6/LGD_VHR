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
package com.lgd.lgcom.lgsetc.lgsetc00060.service;

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
public interface LGSETC00060Service {
	/**
	 * Desc : 메세지 목록을 조회한다.
	 * @Method Name : retrieveMsgList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMsgList(LGCOMData param);

    /**
     * Desc : 메세지 정보을 저장한다.
     * @Method Name : saveMsgList
     * @param  param
     * @throws Exception
     */
    public void saveMsgList(LGCOMData param);
    
    /**
     * Desc : 메세지ID 목록을 조회한다.
     * @Method Name : retrieveMessageList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveMsgIdList(LGCOMData param);
    
    /**
     * Desc : 메세지ID 중복체크를 한다.
     * @Method Name : retrieveMessageIdChk
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveMessageIdChk(LGCOMData param);
}
