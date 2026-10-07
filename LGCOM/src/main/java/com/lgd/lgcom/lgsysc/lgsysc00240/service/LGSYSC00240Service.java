/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00240Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 2. 22.  	forain  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00240.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00240.service.LGSYSC00240Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2017. 2. 22. 오후 5:06:06
 * @Version
 */
public interface LGSYSC00240Service {
	/**
	 * Desc : 결자자에 의해 지정된 검토자 목록을 저장한다.
	 * @Method Name : insertRequestReviewers
	 * @param  param
	 */
	public void insertRequestReviewers(LGCOMData param);

	/**
	 * Desc : 결재자의 검토요청내용 및 검토자의 검토의견을 조회한다.
	 * @Method Name : retrieveReviewRequestData
	 * @param param
	 * @return
	 */
	public LGCOMData retrieveReviewRequestData(LGCOMData param);

	/**
	 * Desc : 검토자의 검토의견을 저장한다.
	 * @Method Name : updateRequestReviewData
	 * @param param
	 */
	public void updateRequestReviewData(LGCOMData param);
}
