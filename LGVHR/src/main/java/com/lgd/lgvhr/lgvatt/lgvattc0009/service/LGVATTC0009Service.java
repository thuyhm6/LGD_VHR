package com.lgd.lgvhr.lgvatt.lgvattc0009.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattc0009.service.LGVATTC0009Service.java
 * </PRE>
 *
 * @Author    javaranbo1
 * @Date      
 * @Version
 */
public interface LGVATTC0009Service {

	/**
	 * Desc : 미승인 일근태 처리 (Daily)
	 * @Method Name : executeApplyNotApprovedAttReq
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeApplyNotApprovedAttReq(LGCOMData param);
}
