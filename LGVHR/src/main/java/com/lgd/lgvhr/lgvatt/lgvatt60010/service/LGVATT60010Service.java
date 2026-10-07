package com.lgd.lgvhr.lgvatt.lgvatt60010.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60010.service.LGVATT60010Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT60010Service {

	/**
	 * Desc : retrieveWeekAttSummary
	 * @Method Name : retrieveWeekAttSummary
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveWeekAttSummary(LGCOMData param);
	
	
	/**
     * Desc : retrieveWeekDateFromTo
     * @Method Name : retrieveWeekDateFromTo
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public LGCOMData retrieveWeekDateFromTo(LGCOMData param);
	
	/**
	 * Desc : retrieveWeekAttSummary
	 * @Method Name : retrieveWeekAttSummary
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOrgList(LGCOMData param);
	
	
	   
}
