package com.lgd.lgvhr.lgvatt.lgvattc0010.service;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattc0010.service.LGVATTC0010Service.java
 * </PRE>
 *
 * @Author    javaranbo1
 * @Date      
 * @Version
 */
public interface LGVATTC0010Service {

	/**
	 * Desc : LW 일근태 정보 결재자 메일발송 (Daily)
	 * @Method Name : executeSendApproverLWAttInfo
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData executeSendApproverLWAttInfo(LGCOMData param);
}
