/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTO0010Service.java
 * @Desc    : 포틀릿 근태 Summary 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 02.    javaranbo1    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatto0010.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTO0010Service.java
 * </PRE>
 * 
 * @author     javaranbo1
 * @Date	   2018. 01. 02. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATTO0010Service {
	
	/**
	 * Desc : 포틀릿에서 보여줄 근태 Summary 정보를 조회한다.
	 * @Method Name : retrievePortletATTSummary
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrievePortletATTSummary(LGCOMData param);

;}
