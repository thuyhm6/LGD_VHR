/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTCOMMService.java
 * @Desc    : 조직 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    H.W.JANG    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvattp0001.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTCOMMService.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 18. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATTP0001Service {
	
	/**
	 * Desc : 조직을 검색한다.
	 * @Method Name : retrieveOrgList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveOrgList(LGCOMData param);
	
	
}
