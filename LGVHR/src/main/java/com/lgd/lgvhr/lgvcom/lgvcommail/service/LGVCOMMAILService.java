/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVCOMMAILService.java
 * @Desc    : LGVHR 메일 발송 공통
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 08.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcommail.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVCOMMAIL.service.LGVCOMMAILService.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 11. 08. 오후 10:45:00
 * @Version
 *
 */
public interface LGVCOMMAILService {

	/**
	 * Desc : 메일 발송하도록 LGCOM_MAIL_INFO 테이블에 적재하는 처리를 한다.
	 * @Method Name : insertSendMail
	 * @param  param
	 * @return LGCOMData
	 */
    public LGCOMData insertSendMail(LGCOMData param);
}
