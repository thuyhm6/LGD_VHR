package com.lgd.lgvhr.lgvatt.lgvatt20552.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * @author HMS - HMS_20210703
 * Swap weekly holiday master
 *
 */
public interface LGVATT20552Service {
	/**
	 * Desc : Search overtime level.
	 * @Method Name : retrieveOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveSwapMaster(LGCOMData param);
	
	/**
	 * Desc : Search code type.
	 * @Method Name : retrieveHolidayNameList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */

    public void saveSwapMasterManage(LGCOMData param);
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);
    
    public LGCOMData checkLockDate(LGCOMData param) throws LGCOMException;
}
