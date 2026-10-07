/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00021Service.java
 * @Desc    : 급여대상자 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    Sonsuyang    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00021.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvpay.lgvpay00021.service.lgvpay00021Service.java
 * </PRE>
 *
 * @Author    Sonsuyang
 * @Date      2017. 12. 05. 오후 15:44:32
 * @Version
 */
public interface LGVPAY00021Service {
	
	/**
	 * Desc : Calucation Set를 조회한다.
	 * @Method Name : retrieveCalcSetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalcSetList(LGCOMData param);
	
	/**
     * Desc : Calucation Set 저장 전 값 체크
     * @Method Name : validateSaveCalcSet
     * @param  param
     * @throws Exception
     */
    public boolean validateSaveCalcSet(LGCOMData param);
	
	/**
     * Desc : Calucation Set를 저장한다.
     * @Method Name : saveCalcSet
     * @param  param
     * @throws Exception
     */
    public void saveCalcSet(LGCOMData param);

}
