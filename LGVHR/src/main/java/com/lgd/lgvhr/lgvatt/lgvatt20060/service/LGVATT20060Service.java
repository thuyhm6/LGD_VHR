package com.lgd.lgvhr.lgvatt.lgvatt20060.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20040.service.LGVATT20060Service.java
 * </PRE>
 *
 * @Author    Lee Hyung Jun
 * @Date      
 * @Version
 */
public interface LGVATT20060Service {

	/**
	 * Desc : retrieveLWResultList
	 * @Method Name : retrieveLWResultList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLWResultList(LGCOMData param);
	
	/**
	 * Desc : retrieveRequestDocBaseInfo
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param);
	
	/**
	 * Desc : requestLWResultList
	 * @Method Name : requestLWResultList
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	public void requestLWResultList(LGCOMData param);
	
	/**
	 * Desc : retrieveLWResultApprovalList
	 * @Method Name : retrieveLWResultApprovalList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLWResultApprovalList(LGCOMData param);
	
	/**
	 * Desc : saveRequestApprovalOrReject
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	public void saveRequestApprovalOrReject(LGCOMData param);
	
	/**
	 * Desc : isEnableAttendSubmit
	 * @Method Name : isEnableAttendSubmit
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData isEnableSubmitOrApproval(LGCOMData param);
	
	/**
	 * Desc : isEnableModify
	 * @Method Name : isEnableModify
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData isEnableModify(LGCOMData param);
	
	/**
	 * Desc : saveSelfReject
	 * @Method Name : saveSelfReject
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public void saveSelfReject(LGCOMData param);
}
