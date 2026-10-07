/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00080Service.java
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
package com.lgd.lgcom.lgsysc.lgsysc00080.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00080.service.LGSYSC00080Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 11:22:58
 * @Version
 */
public interface LGSYSC00080Service {
	/**
	 * Desc : 사용자가 등록한 화면의 Condition 목록을 조회한다.
	 * @Method Name : retrieveConditionList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveConditionList(LGCOMData param);

	/**
	 * Desc : 사용자가 등록한 화면의 Condition 목록을 삭제한다.
	 * @Method Name : deleteConditionList
	 * @param  param
	 * @throws Exception
	 */
	public void deleteConditionList(LGCOMData param);
}
