/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : RegionService.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.RegionService.java
 * </PRE>
 *
 * @Author    soncs
 * @Date      2016. 8. 19. 오전 8:55:01
 * @Version
 */
public interface RegionService {
	/**
	 * Desc : ssoId로 사용자 정보, Region 목록, Operation Unit 목록을 조회한다.
	 * @Method Name : retrieveRegionInitData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRegionInitData(LGCOMData param);

	/**
	 * Desc : 선택된 Region 과 Operation Unit 정보를 저장한다.
	 * @Method Name : saveSelectedRegionAndOrgUnit
	 * @param  param
	 */
	public void saveSelectedRegionAndOrgUnit(LGCOMData param);

	/**
	 * Desc : Region & OU 선택결과로 선정된 application user id로 사용자 세션을 생성한다.
	 * @Method Name : createSSOUserSession
	 * @param  param
	 */
	public void createSSOUserSession(LGCOMData param);
}
