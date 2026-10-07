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
package com.lgd.lgvhr.lgvcom.lgvcom00100.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00040.service.LGSYSC00040Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 10:30:01
 * @Version
 */
public interface LGVCOM00100Service {
	/**
	 * Desc : Popup에서 주어진 조건에 따라 사용자 목록을 조회한다.
	 * @Method Name : retrieveUserPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserPopupList(LGCOMData param);
}
