/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00090Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 5. 31.  	rlaclskfk  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00090.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00090.service.LGSYSC00090Service.java
 * </PRE>
 *
 * @Author    rlaclskfk
 * @Date	   2016. 5. 31. 오전 9:53:50
 * @Version
 */
public interface LGSYSC00090Service {
	/**
	 * Desc :  Role 목록을 조회한다.
	 * @Method Name : retrieveRoleList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRoleList(LGCOMData param);

	/**
	 * Desc :  Role 목록을 저장한다.
	 * @Method Name : saveRoleList
	 * @param  param
	 * @throws Exception
	 */
	public void saveRoleList(LGCOMData param);

	/**
	 * Desc :  Role Code 중복체크 한다.
	 * @Method Name : retrieveRoleCode
	 * @param  param
	 * @throws Exception
	 */
	public boolean retrieveRoleCode(LGCOMData param);

	/**
	 * Desc :  선택된 Role을 물리적으로 삭제한다.
	 * @Method Name : deleteRoleCodePhysical
	 * @param  param
	 * @throws Exception
	 */
	public void deleteRoleCodePhysical(LGCOMData param);
}
