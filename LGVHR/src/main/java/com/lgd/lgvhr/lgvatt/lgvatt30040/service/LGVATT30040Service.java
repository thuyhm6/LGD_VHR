package com.lgd.lgvhr.lgvatt.lgvatt30040.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt30040.service.LGVATT30040Service.java
 * </PRE>
 *
 * @Author    Ha Minh Thuy
 * @Date      
 * @Version
 */
public interface LGVATT30040Service {
	
	/**
	 * Desc : retrieveOtOverYearLimitList
	 * @Method Name : retrieveOtOverYearLimitList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOtOverYearLimitList(LGCOMData param);

}
