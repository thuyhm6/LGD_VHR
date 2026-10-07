/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt30093Service.java
 * @Desc    : Daily ATT Summary
 *
 * Copyright ⓒ 2023 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2023. 03. 07.  Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt30093.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt30093.service.LGVATT30093Service.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 03. 07. 04:23 PM
 * @Version
 */
public interface LGVATT30093Service {
    /**
	 * Desc : search Monthly information.
	 * @Method Name : Monthly View
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws 
	 */
    public List<LGCOMData> getMonthlyAttSummaryList(LGCOMData param);
}
