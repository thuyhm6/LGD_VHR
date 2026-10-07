/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVINFC0004Service.java
 * @Desc    : 인사마스터정보 I/F 수신 Batch 프로그램
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2017.11.13  김재현      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvinf.lgvinfc0004.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvinf.lgvinfc0004.service.LGVINFC0004Service.java
 * </PRE>
 *
 * @Author    SonSuyang
 * @Date      
 * @Version
 */
public interface LGVINFC0004Service {

	/**
	 * Desc : 인사마스터정보 인터페이스 (ERP -> VHR)
	 * @Method Name : executeUserInterface
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeEmpMasterInterface(LGCOMData param);
}
