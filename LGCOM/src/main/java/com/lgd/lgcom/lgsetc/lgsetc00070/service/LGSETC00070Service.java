/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00070Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 1.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00070.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00070.service.LGSETC00070Service.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 1. 오전 9:00:58
 * @Version
 */
public interface LGSETC00070Service {
	/**
	 * Desc : 라벨 목록을 조회한다.
	 * @Method Name : retrieveLabelList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLabelList(LGCOMData param);

    /**
     * Desc : 라벨 정보을 저장한다.
     * @Method Name : saveLabelList
     * @param  param
     * @throws Exception
     */
    public void saveLabelList(LGCOMData param);
    
    /**
     * Desc : 라벨ID 목록을 조회한다.
     * @Method Name : retrieveLabelList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveLabelIdList(LGCOMData param);
    
    /**
     * Desc : 라벨ID 중복체크를 한다.
     * @Method Name : retrieveLabelIdChk
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveLabelIdChk(LGCOMData param);
}
