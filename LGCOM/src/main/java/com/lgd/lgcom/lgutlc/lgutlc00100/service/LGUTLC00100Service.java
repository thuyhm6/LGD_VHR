/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00100Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 7.13.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00100.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00100.service.LGUTLC00100Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 7.13. 오후 1:39:58
 * @Version
 */
public interface LGUTLC00100Service {
	/**
	 * Desc : Service Logging의 Summary 목록을 메뉴별 서비스별 Summary 목록 조회
	 * @Method Name : retrieveServiceLogSummaryList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveServiceLogSummaryList(LGCOMData param);

	/**
	 * Desc : Service Logging의 실행년월, 메뉴ID, 프로그램ID, 서비스명을 받아 실행 상세 목록 조회
	 * @Method Name : retrieveServiceLogDetailList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveServiceLogDetailList(LGCOMData param);
}
