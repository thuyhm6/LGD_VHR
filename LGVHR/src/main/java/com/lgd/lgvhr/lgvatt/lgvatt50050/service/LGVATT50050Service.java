/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50040Service.java
 * @Desc    : Setup OT level
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2023. 02. 20.  Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50050.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgvatt.lgvatt50050.service.LGVATT50050Service.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 02. 20. 05:58 PM
 * @Version
 */

public interface LGVATT50050Service {
	/**
	 * Desc : Save Korean Leader Info .
	 * @Method Name : saveKoreanLeaderInfo
	 * @param  param
	 * @return void
	 * @throws 
	 */

    public void saveKoreanLeaderInfo(LGCOMData param);
    
    /**
	 * Desc : search Korean Leader Info .
	 * @Method Name : getKoreanLeaderInfo
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws 
	 */
    public List<LGCOMData> getKoreanLeaderInfo(LGCOMData param);
    
    /**
	 * Desc : PartLeader ExcelUpload .
	 * @Method Name : uploadExcelPartLeaderInfo
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws 
	 */
    public void uploadExcelPartLeaderInfo(LGCOMData param);
}
