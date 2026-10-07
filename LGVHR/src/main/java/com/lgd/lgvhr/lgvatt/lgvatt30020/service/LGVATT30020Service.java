package com.lgd.lgvhr.lgvatt.lgvatt30020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30020.service.LGVATT30020Service.java
 * </PRE>
 *
 * @Author    Ha Minh Thuy
 * @Date      
 * @Version
 */

public interface LGVATT30020Service {
	
	/**
	 * Desc : retrieveYearOtTotalList
	 * @Method Name : retrieveYearOtTotalList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveYearOtTotalList(LGCOMData param);

}
