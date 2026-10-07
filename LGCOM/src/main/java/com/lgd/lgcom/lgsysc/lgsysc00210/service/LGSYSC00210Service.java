/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00210Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 23.  jhlee    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00210.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00210.service.LGSYSC00210Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
public interface LGSYSC00210Service {
	/**
	 * Desc : 사용자의 메뉴 목록을 인출한다.
	 * @Method Name : retrieveMenuList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMenuList(LGCOMData param);

	public List<LGCOMData> retrieveMenuInfo(LGCOMData param);

	public List<LGCOMData>  retrieveWidgetNumbers(LGCOMData param);

	public List<LGCOMData>  retrieveWidgetSystemList(LGCOMData param);

	public List<LGCOMData>  retrieveSystemContactUserList(LGCOMData param);

	public void updateUserThemeCode(LGCOMData param);

	public void insertUserPopupHistory(LGCOMData param);

	public void deleteUserPopupHistory(LGCOMData param);

	public List<LGCOMData> selectAttachmentListByFileGroupId(LGCOMData param);

	public void deleteAttachFileInfo( LGCOMData inParam );

	public void updateAttachFileInfo( LGCOMData inParam );

	public void deleteAttachFilesByFileGroupId( LGCOMData inParam );

	public List<LGCOMData>  retrieveExcelUploadErrorCount (LGCOMData param);

	public List<LGCOMData>  retrieveExcelUploadErrorList (LGCOMData param);

	public LGCOMData createExcelExportData(LGCOMData param);

	/**
	 * Desc :  Intro 차트를 위한 데이타 조회
	 * @Method Name : retrieveChartWidgetNumbers
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveChartWidgetNumbers(LGCOMData param);
}
