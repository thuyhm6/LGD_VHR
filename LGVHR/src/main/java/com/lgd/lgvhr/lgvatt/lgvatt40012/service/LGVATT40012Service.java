/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40012Service.java
 * @Desc    : 사무직 일근태 조회하면 ( 팀장 하위 전체 )
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0  2018.01.18.   LHJ    	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt40012.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt40012.service.LGVATT40012Service.java
 * </PRE>
 * 
 * @author     LHJ
 * @Date	   2018.01.18.
 * @Version
 *
 */
public interface LGVATT40012Service {

	/**
	 * Desc : 사무직 일근태 정보를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 * @return List<LGCOMData>
	 */
    public List<LGCOMData> retrieveAttendanceData(LGCOMData param);
    
    /**
	 * Desc : 조회조건에 바인딩 되어야할 데이터들을 조회한다.
	 * @Method Name : retrieveSearchFormDataList
	 * @param  param
	 * @return LGCOMData
	 */
    public LGCOMData retrieveSearchFormDataList(LGCOMData param);
    
    /**
	 * Desc : 승인
	 * @Method Name : saveApproval
	 * @param  param
	 * @return void
	 */
    public void saveApproval(LGCOMData param);
    
    /**
	 * Desc : 반려
	 * @Method Name : saveReject
	 * @param  param
	 * @return void
	 */
    public void saveReject(LGCOMData param);
}
