package com.lgd.lgvhr.lgvpay.lgvpayp0021.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * com.lgd.lgcom.lgvpay.lgvpayp0021.service.LGVPAYP0021Service.java
 * Send PaySlip By Employee Popup
 * @Author    HaMinhThuy
 * @Date      2022.06.25. 15:35:32
 * @Version
 */
public interface LGVPAYP0021Service {
	/**
     * Desc : 확정된 Payroll Run별 대상자 리스트를 조회한다. 
     * @Method Name : retrievePayrollRunEmpList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunEmpList(LGCOMData param);

}
