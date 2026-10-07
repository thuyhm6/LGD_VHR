/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT60020Service.java
 * @Desc    : 근태 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt60020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60020.service.LGVATT60020Service.java
 * </PRE>
 * 
 * @author     limsjin
 * @Date	   2017. 10. 18. 오후 3:41:12
 * @Version
 *
 */
public interface LGVATT60020Service {
	

	public List<LGCOMData> createExcelMonthReport(LGCOMData param);

;}
