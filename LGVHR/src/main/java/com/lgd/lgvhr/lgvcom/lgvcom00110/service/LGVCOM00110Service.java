/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGVCOM00110Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2023 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2023. 3. 2.    Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcom00110.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00110.service.LGVCOM00110Service.java
 * </PRE>
 *
 * @Author    Kim biho
 * @Date      2023. 3. 2. 오전 8:40:01
 * @Version
 */
public interface LGVCOM00110Service {
	/**
	 * Desc : Popup에서 주어진 조건에 따라 사용자 목록을 조회한다.
	 * @Method Name : basicUserPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> basicUserPopupList(LGCOMData param);
}
