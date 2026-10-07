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
package com.lgd.lgvhr.lgvcom.lgvcom00120.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00120.service.LGVCOM00120Service.java
 * </PRE>
 *
 * @Author    Kim biho
 * @Date      2023. 3. 2. 오전 8:40:01
 * @Version
 */
public interface LGVCOM00120Service {	
	/**
	 * Desc : Popup에서 주어진 조건에 따라 파트 섹션 목록을 조회한다.
	 *        서비스 생성이 불필요한 클래스만 늘려 해당 클래스에 같이 추가함
	 * @Method Name : basicPartPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> basicPartPopupList(LGCOMData param);
}
