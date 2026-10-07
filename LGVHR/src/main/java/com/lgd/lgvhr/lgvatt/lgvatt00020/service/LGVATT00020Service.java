package com.lgd.lgvhr.lgvatt.lgvatt00020.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt00020.service.LGVATT00020Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT00020Service {

	/**
	 * Desc : retrieveAttList
	 * @Method Name : retrieveAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttList(LGCOMData param);
}
