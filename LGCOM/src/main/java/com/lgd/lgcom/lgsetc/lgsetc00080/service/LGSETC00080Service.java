/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00080Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 4.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00080.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00080.service.LGSETC00080Service.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 4. 오전 8:41:12
 * @Version
 */
public interface LGSETC00080Service {
	/**
	 *
	 * Desc : 주어진 조건에 따라 Profile Master 목록을 조회한다.
	 * @Method Name : retrieveProfileMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveProfileMasterList(LGCOMData param);

	/**
	 *
	 * Desc : 화면에서 입력된 Profile Master 목록을 저장한다.
	 * @Method Name : saveProfileMasterList
	 * @param param
	 */
	public void saveProfileMasterList(LGCOMData param);

	/**
	 *
	 * Desc : 선택된 Profile Master에 따라 Profile 상세목록을 조회한다.
	 * @Method Name : retrieveProfileSetupList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveProfileSetupList(LGCOMData param);

	/**
	 *
	 * Desc : Profile 상세내용 목록을 저장한다.
	 * @Method Name : saveProfileSetupList
	 * @param param
	 */
	public void saveProfileSetupList(LGCOMData param);

	/**
	 *
	 * Desc : Profile 내용을 관리자 권한으로 삭제한다.
	 * @Method Name : deleteProfileForce
	 * @param param
	 */
	public void deleteProfileForce(LGCOMData param);
}
