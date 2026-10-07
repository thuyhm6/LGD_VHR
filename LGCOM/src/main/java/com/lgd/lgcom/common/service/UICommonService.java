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

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.ApprovalService.java
 * </PRE>
 *
 * @Author    soncs
 * @Date      2016. 8. 19. 오전 8:55:01
 * @Version
 */
public interface UICommonService {

	 public LGCOMData retrieveGridConfig (LGCOMData param);

	 public void saveGridConfig (LGCOMData param);

	 public void deleteGridConfig (LGCOMData param);

	 public List<LGCOMData> retrieveKeywordList( LGCOMData param );

	 public void saveKeywordList( LGCOMData param );

	 public void deleteKeywordList( LGCOMData param );

	 public List<?> retrieveSearchCondition(LGCOMData param);

	 public void insertSearchCondition(LGCOMData param);

	 public void deleteSearchCondition(LGCOMData param);

	 public List<LGCOMData> retriveMenuItemFromCache( LGCOMData param);

	 public List<LGCOMData> retrievePopupNoticeList(LGCOMData param);

	/**
	 * Desc : 요청서의 안내탭 내용을 조회한다.
	 * @Method Name : retrieveGridConfig
	 * @param param
	 * @return
	 */
	public LGCOMData retrieveRequestFormInfomationFromManual(LGCOMData param);
	
	public LGCOMData checkValidBiMatrixMenuId(LGCOMData param);
}
