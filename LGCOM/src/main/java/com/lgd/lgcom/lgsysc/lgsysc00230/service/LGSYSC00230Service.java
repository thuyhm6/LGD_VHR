/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00230Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 8. 26.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00230.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00230.service.LGSYSC00230Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 26. 오후 1:46:58
 * @Version
 */
public interface LGSYSC00230Service {
	/**
	 *
	 * Desc : Super User 목록 조회
	 * @Method Name : retrieveReponsibilitySuperUserList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveReponsibilitySuperUserList(LGCOMData param);

	/**
	 * Desc : Responsibility 별 Super User 조회
	 * @Method Name : retrieveResponsibilitySuperUserAddress
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveResponsibilitySuperUserAddress(LGCOMData param);	
	
	/**
	 *
	 * Desc : Responsibility Super User 목록 저장
	 * @Method Name : saveResponsibilitySuperUserList
	 * @param  param
	 */
	public void saveResponsibilitySuperUserList(LGCOMData param);

	/**
	 *
	 * Desc : Responsibility 별 Super User 목록 조회
	 * @Method Name : retrieveResponsibilitySuperUserDetailList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveResponsibilitySuperUserDetailList(LGCOMData param);

	/**
	 *
	 * Desc : Responsibility Super User 대상자들에게 메일 발송
	 * @Method Name : saveResponsibilitySuperUserSendMailList
	 * @param  param
	 */
	public void saveResponsibilitySuperUserSendMailList(LGCOMData param);
}
