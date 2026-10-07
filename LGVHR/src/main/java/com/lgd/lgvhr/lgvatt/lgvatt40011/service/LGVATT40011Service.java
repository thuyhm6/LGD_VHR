/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT40011Service.java
 * @Desc    : 일근태 실적 수정 팝업 (결재권자)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0  2018.01.03.   LHJ    	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt40011.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT40011.service.LGVATT40011Service.java
 * </PRE>
 * 
 * @author     LHJ
 * @Date	   2018.01.03.
 * @Version
 *
 */
public interface LGVATT40011Service {

	/**
	 * Desc : 수정이 필요한 일근태 정보를 조회한다.
	 * @Method Name : retrieveInitData
	 * @param  param
	 * @return List<LGCOMData>
	 */
    public List<LGCOMData> retrieveInitData(LGCOMData param);
    
    /**
	 * Desc : 수정이 필요한 일근태 정보를 조회한다.
	 * @Method Name : retrieveNonRequestorData
	 * @param  param
	 * @return List<LGCOMData>
	 */
    public List<LGCOMData> retrieveNonRequestorData(LGCOMData param);
    
    /**
	 * Desc : 실적 수정사항을 업데이트한다.
	 * @Method Name : updateAttendanceResult
	 * @param  param
	 * @return void
	 */
    public void updateAttendanceResult(LGCOMData param);
    
    /**
	 * Desc : 승인
	 * @Method Name : saveApproval
	 * @param  param
	 * @return void
	 */
    public void saveApproval(LGCOMData param);
}
