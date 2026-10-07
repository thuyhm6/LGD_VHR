package com.lgd.lgvhr.lgvatt.lgvatt00010.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt00010.service.LGVATT00010Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT00010Service {

	/**
	 * Desc : retrieveIdCardHis
	 * @Method Name : retrieveIdCardHis
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveIdCardHis(LGCOMData param);
	
	/**
	 * Desc : excelDownData
	 * @Method Name : excelDownData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData excelDownData(LGCOMData param);
}
