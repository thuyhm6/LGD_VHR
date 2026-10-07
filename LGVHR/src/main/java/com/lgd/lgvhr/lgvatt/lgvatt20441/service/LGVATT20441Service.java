/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt20441Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20441.service;

import java.io.IOException;
import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt20441.service.LGVATT20441Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
public interface LGVATT20441Service {
	/**
	 * Desc : 장기근태 세부내역을 조회한다.
	 * @Method Name : retrieveMutiplanDetail
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveMutiplanDetail(LGCOMData param);
	
	/**
	 * Desc : 장기근태 결제승인 또는 반려처리
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  param
	 * @return void
	 * @throws IOException 
	 * @throws Exception
	 */
	public LGCOMData saveRequestApprovalOrReject(LGCOMData param) throws IOException;
	
	/**
	 * Desc : 결제담당자 또는 자신이 결제취소
	 * @Method Name : saveSelfReject
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData saveSelfReject(LGCOMData param);
}
