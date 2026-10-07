/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50030Service.java
 * @Desc    : 연간휴가 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 04.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50030.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50030.service.LGVATT50030Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
public interface LGVATT50030Service {
	/**
	 * Desc : 연간휴가를 조회한다.
	 * @Method Name : retrieveAttendanceLeave
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceLeave(LGCOMData param);
	
	/**
	 * Desc : 근태년월 목록을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymm
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymm(LGCOMData param);
	
	/**
	 * Desc : 조회된 결과를 엑셀로 다운로드
	 * @Method Name : excelDownData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData excelDownData(LGCOMData param);

}
