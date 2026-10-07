package com.lgd.lgvhr.lgvatt.lgvatt20040.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20040.service.LGVATT20040Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT20040Service {

	/**
	 * Desc : retrieveLWAttList
	 * @Method Name : retrieveLWAttList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLWAttList(LGCOMData param);
	
	/**
     * Desc : 근태 입력 정보을 임시 저장한다.
     * @Method Name : updateLWAttPlanList
     * @param  param
     * @throws Exception
     */
    public void updateLWAttPlanActualList(LGCOMData param);
    
    /**
	 * Desc : isEnableAttendInput
	 * @Method Name : isEnableAttendInput
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData isEnableAttendInput(LGCOMData param);
	
	/**
	 * Desc : isillegalAtt
	 * @Method Name : isillegalAtt
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData isillegalAtt(LGCOMData param);
}
