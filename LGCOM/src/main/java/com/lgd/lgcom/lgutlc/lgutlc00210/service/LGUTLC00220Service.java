/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00200Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 07. 14.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00210.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00210.service.lgutlc00210Service.java
 * </PRE>
 *
 * @Author    jhlee
 * @Date      2016. 09. 18. 오후 1:39:58
 * @Version
 */
public interface LGUTLC00220Service {
	/**
	 * Desc : Batch Sechedule 목록을 조회한다.
	 * @Method Name : retrieveBatchScheduleList
	 * @param  param
	 * @return PagingList<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBatchScheduleList(LGCOMData param);
	
	/**
	 * Desc : Batch Sechedule 목록을 저장 한다.
	 * @Method Name : saveBatchScheduleList
	 * @param  param
	 * @return PagingList<?>
	 * @throws Exception
	 */
	public void saveBatchScheduleList(LGCOMData param);
}
