/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50010Service.java
 * @Desc    : 근태마감일 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50010.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50010.service.LGVATT50010Service.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
public interface LGVATT50010Service {
	/**
	 * Desc : 근태마감일을 조회한다.
	 * @Method Name : retrieveAttendanceClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceClose(LGCOMData param);
	
	/**
	 * Desc : 근태년월 목록을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymm
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymm(LGCOMData param);
	
	/**
     * Desc : 근태마감일을 저장한다.
     * @Method Name : saveAttendanceClose
     * @param  param
     * @throws Exception
     */
    public void saveAttendanceClose(LGCOMData param);
    
    /**
     * Desc : 근태마감일을 승인한다.
     * @Method Name : saveAttendanceClose
     * @param  param
     * @throws Exception
     */
    public void saveConfirmAttendanceClose(LGCOMData param);

}
