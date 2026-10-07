package com.lgd.lgvhr.lgvatt.lgvattc0012.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattc0012.service.LGVATTC0012Service.java
 * </PRE>
 *
 * @Author    javaranbo1
 * @Date      
 * @Version
 */
public interface LGVATTC0012Service {

	/**
	 * Desc :  Part Leader 를 하위 조직의 PIC 로 반영한다. (Hourly)
	 * @Method Name : executeApplyAttContractPl
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeApplyAttContractPl(LGCOMData param);
}
