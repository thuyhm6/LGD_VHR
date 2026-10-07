package com.lgd.lgvhr.lgvatt.lgvattc0008.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattc0008.service.LGVATTC0008Service.java
 * </PRE>
 *
 * @Author    javaranbo1
 * @Date      
 * @Version
 */
public interface LGVATTC0008Service {

	/**
	 * Desc : LW 계획근태 및 OW 장기근태계획 실적근태 반영 (Daily)
	 * @Method Name : executeApplyAttResultFrPlan
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeApplyAttResultFrPlan(LGCOMData param);
}
