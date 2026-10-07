package com.lgd.lgvhr.lgvatt.lgvatt30050.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30060.service.LGVATT30050Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT30050Service {

	/**
	 * Desc : retrieveMonthlyAttList
	 * @Method Name : retrieveMonthlyAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMonthlyEmpLevelList(LGCOMData param);
}
