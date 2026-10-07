/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVINFC0010Service.java
 * @Desc    : 사용자 기본권한 설정 Batch 프로그램
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
package com.lgd.lgvhr.lgvinf.lgvinfc0010.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvinf.lgvinfc0010.service.LGVINFC0010Service.java
 * </PRE>
 *
 * @Author    SonSuyang
 * @Date      
 * @Version
 */
public interface LGVINFC0010Service {

	/**
	 * Desc : 사용자 기본권한 설정
	 * @Method Name : executeUserRoleInterface
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeUserRoleInterface(LGCOMData param);
}
