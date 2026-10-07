/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00140Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 26.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00140.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00140.service.LGSYSC00140Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 26. 오전 8:14:58
 * @Version
 */
public interface LGSYSC00140Service {
	/**
	 * Desc : Program 목록을 조회한다.
	 * @Method Name : retrieveProgramList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<?> retrieveProgramList(LGCOMData param);

	/**
	 * Desc : Program ID로 중복 체크를 한다.
	 * @Method Name : retrieveCheckDuplicatedProgramId
	 * @param  param
	 * @throws Exception
	 */
	public boolean retrieveCheckDuplicatedProgramId(LGCOMData param);

	/**
	 * Desc : Program 목록을 저장한다.
	 * @Method Name : saveProgramList
	 * @param  param
	 * @throws Exception
	 */
    public void saveProgramList(LGCOMData param);
    
    public List<LGCOMData> createExcelExportData(LGCOMData param);
    public void createProgramInfoFromUpload(LGCOMData param);

    public List<LGCOMData> retrieveCache(LGCOMData param);
    public void saveCache(LGCOMData param);
    public void removeCache(LGCOMData param);
    public void execBatch(LGCOMData param);
    
    public LGCOMData retrieveProgramListForReport(LGCOMData param);
}
