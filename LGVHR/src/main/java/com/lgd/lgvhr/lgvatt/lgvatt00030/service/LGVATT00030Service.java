package com.lgd.lgvhr.lgvatt.lgvatt00030.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt00030.service.LGVATT00030Service.java
 * </PRE>
 *  HMT_20221108 Add Employee Shift Group Info Interface
 * @Author    Ha Minh Thuy
 * @Date      
 * @Version
 */
public interface LGVATT00030Service {

	/**
	 * Desc : retrieveMonthlyAttList
	 * @Method Name : retrieveMonthlyAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMonthlyEmpGroupList(LGCOMData param);
}
