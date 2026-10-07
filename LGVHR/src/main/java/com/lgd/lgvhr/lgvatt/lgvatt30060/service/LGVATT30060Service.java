package com.lgd.lgvhr.lgvatt.lgvatt30060.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30060.service.LGVATT30060Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT30060Service {

	/**
	 * Desc : retrieveMonthlyAttList
	 * @Method Name : retrieveMonthlyAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMonthlyAttList(LGCOMData param);
}
