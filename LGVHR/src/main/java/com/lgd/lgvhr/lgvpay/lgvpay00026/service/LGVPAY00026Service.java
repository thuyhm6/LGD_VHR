package com.lgd.lgvhr.lgvpay.lgvpay00026.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * com.lgd.lgcom.lgvpay.lgvpay00026.service.LGVPAY00026Service.java
 * Send PaySlip By Employee
 * @Author    HaMinhThuy
 * @Date      2022.06.25. 15:35:32
 * @Version
 */
public interface LGVPAY00026Service {
	/**
     * Desc : 확정된 Payroll Run 리스트 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunList(LGCOMData param);
    
    public LGCOMData sendPayslipByEmail(LGCOMData param);
    
    public LGCOMData createPaySlip(LGCOMData param);
    
    public LGCOMData deletePaySlip(LGCOMData param);

}
