package com.lgd.lgvhr.lgvpay.lgvpayp0021.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0021.service.LGVPAYP0021Service;

/**
 * com.lgd.lgcom.lgvpay.lgvpayp0021.service.serviceImpl.LGVPAYP0021ServiceImpl.java
 * Send PaySlip By Employee Popup
 * @Author    HaMinhThuy
 * @Date      2022.06.25. 15:35:32
 * @Version
 */
@Service("LGVPAYP0021Service")
public class LGVPAYP0021ServiceImpl implements LGVPAYP0021Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0021ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
     * Desc : 확정된 Payroll Run별 대상자 리스트를 조회한다. 
     * @Method Name : retrievePayrollRunEmpList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunEmpList(LGCOMData param) {
    	LOGGER.debug("param===>" + param);
    	return this.commonDao.selectList("LGVPAYP0021.retrievePayrollRunEmpList", param);
    }

}
