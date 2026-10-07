/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYUtil.java
 * @Desc    : 급여 공통 유틸
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 29.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.util;

import java.text.SimpleDateFormat;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.util.LGVPAYCOMMUtil.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2018. 01. 29.
 * @Version
 */
public class LGVPAYUtil {

	/**
	 * Desc : 날짜입력 형식 체크
	 * 
	 * @Method Name : validateDateFormat
	 * @param  param
	 * @throws Exception
	 */
	public static boolean validateDateFormat(String yyyymmdd) {
		boolean validateFlag = false;
		if ( NullUtil.isNone(yyyymmdd) ) {
			return false;
		} else {
			/*
			String sRegExp = "^(0[0-9]|1[0-9]|2[0-9]|3[0-1])\\/(0[0-9]|10|11|12)\\/[1-4][0-9]{3}$";
			validateFlag = yyyymmdd.matches(sRegExp);//날짜 기본 형식 체크(dd/MM/yyyy)
			
			if ( validateFlag ) {*/
				try {
					SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy"); 
					formatter.parse(yyyymmdd);
					validateFlag = true;
				} catch ( Exception e ) {
					validateFlag = false;
				}
			//}
		}
		return validateFlag;
	}

	/**
	 * Desc : 날짜 형식 변경
	 * 
	 * @Method Name : getFormattedDate
	 * @param  param
	 * @throws Exception
	 */
	public static String getFormattedDate(String yyyymmdd) {
		String ymd = "";
		try {
			SimpleDateFormat inFormatter = new SimpleDateFormat("dd/MM/yyyy");
			SimpleDateFormat outFormatter = new SimpleDateFormat("yyyyMMdd");
			
			ymd = outFormatter.format(inFormatter.parse(yyyymmdd));
			
		} catch ( Exception e ) {
			ymd = yyyymmdd;
		}
		return ymd;
	}
	
}
