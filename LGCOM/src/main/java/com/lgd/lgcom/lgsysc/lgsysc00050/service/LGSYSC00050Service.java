/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00040Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00050.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00050.service.LGSYSC00050Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 10:30:01
 * @Version
 */
public interface LGSYSC00050Service {
	/**
	 * Desc : My Infomation 정보를 조회한다.
	 * @Method Name : retrieveMyPageData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveMyInfomationData(LGCOMData param);

	/**
	 * Desc : My Infomation 정보를 저장한다.
	 * @Method Name : updateMyInfomationData
	 * @param  param
	 * @throws Exception
	 */
	public void updateMyInfomationData(LGCOMData param);

	/**
	 * Desc : My Authority 목록을 조회한다.
	 * @Method Name : retrieveMyAuthorityList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMyAuthorityList(LGCOMData param);
}
