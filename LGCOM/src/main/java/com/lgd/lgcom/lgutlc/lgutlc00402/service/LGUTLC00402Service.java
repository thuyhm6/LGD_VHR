/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00401Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 5.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00402.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00401.service.LGUTLC00401Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 5. 오후 1:39:25
 * @Version
 */
public interface LGUTLC00402Service {
	 
	 public LGCOMData retrieveCacheItems(LGCOMData param);
	 
	 public void saveCacheItems(LGCOMData param);
}
