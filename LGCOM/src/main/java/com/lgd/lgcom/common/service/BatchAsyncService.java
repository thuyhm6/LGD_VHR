/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : BatchAsyncService.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 12. 16.   PCW      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service;

import com.lgd.lgcom.framework.model.LGCOMData;

public interface BatchAsyncService {
	public void executeBatchAsync(LGCOMData param);
	public void executeBatchAsyncXmx(LGCOMData param);
}
