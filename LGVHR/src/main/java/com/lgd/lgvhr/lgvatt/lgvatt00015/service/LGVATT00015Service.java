package com.lgd.lgvhr.lgvatt.lgvatt00015.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT00015Service {
	/**
	 * Desc : Retrieve Other Income Emp List.
	 * @Method Name : retrieveRequestOsKpiMasterList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRequestOsKpiMasterList(LGCOMData param);
	
	/**
     * Desc : Save Other Income Emp.
     * @Method Name : saveRequestOsKpiMaster
     * @param  param
     * @throws Exception
     */
    public void saveRequestOsKpiMaster(LGCOMData param);
    
    /**
     * Desc : Create Other Income Emp Upload.
     * @Method Name : createRequestOsKpiMasterUpload
     * @param  param
     * @throws Exception
     */
    public void createRequestOsKpiMasterUpload(LGCOMData param);

}
