package com.lgd.lgvhr.lgvpay.lgvpay00025.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * com.lgd.lgcom.lgvpay.lgvpay00025.service.LGVPAY00025Service.java
 *
 * @Author    HaMinhThuy
 * @Date      2022. 06. 01. 15:00:32
 * @Version
 */
public interface LGVPAY00025Service {
	/**
	 * Desc : 급여대상자를 조회한다.
	 * @Method Name : retrieveCalSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveEmailEmpList(LGCOMData param);
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveCalSetEmp
     * @param  param
     * @throws Exception
     */
    public void saveEmailEmp(LGCOMData param);
    
    /**
     * Desc : 기등록된 급여대상 SET을 조회한다.
     * @Method Name : retrieveRegCalEmpChk
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRegEmailEmpChk(LGCOMData param);
    
    /**
     * Desc : 엑셀업로드.
     * @Method Name : createEmailEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createEmailEmpUpload(LGCOMData param);
    
    /**
     * Desc : 엑셀업로드.
     * @Method Name : createEmailEmpPrevious
     * @param  param
     * @throws Exception
     */
    public void createEmailEmpPrevious(LGCOMData param);
    
    /**
     * Desc : Delete All Email In Month.
     * @Method Name : deleteAllEmailInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllEmailInMonth(LGCOMData param);
    
    /**
     * Desc : 행추가된 사용자 정보를 조회한다.
     * @Method Name : retrieveEmployeeInfo
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveEmployeeInfo(LGCOMData param);

}
