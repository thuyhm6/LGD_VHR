/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt00100Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    H.W.JANG    PIC 조회 및 등록 록직
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00100.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt00100.service.LGVATT00100Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
public interface LGVATT00100Service {
	/**
	 * Desc : 근태담당자 목록을 조회한다.
	 * @Method Name : retrieveOrgContactList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOrgContactList(LGCOMData param);
	
	/**
	 * Desc : 근태담당자로 지정 가능한 인원을 조회한다.
	 * @Method Name : retrieveOrgContactSelectList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveOrgContactCheck(LGCOMData param);
	
	
	/**
     * Desc : 추가되고 삭제된 인원에 대해 저장한다.
     * @Method Name : saveContactList
     * @param  param
     * @throws Exception
     */
    public void saveContactList(LGCOMData param);	
    public void insertOrgForPic(LGCOMData param);
    public void deletePermission(LGCOMData param);
	
}
