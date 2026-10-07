/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0002Service.java
 * @Desc    : Payroll Run Execution List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 7.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0002.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0002.service.LGVPAYP0002Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0002.service.serviceImpl.LGVPAYP0002ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 4. 오전 10:46:01
 * @Version
 */
@Service("LGVPAYP0002Service")
public class LGVPAYP0002ServiceImpl implements LGVPAYP0002Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0002ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Execution List 를 조회한다.
     * @Method Name : retrieveExecutionList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveExecutionList(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrieveExecutionList().param=>" + param);
    	return this.commonDao.selectList("LGVPAYP0002.retrieveExecutionList", param);
    }
    
    /**
     * Desc : payrollCalculationExecId 로 payMonth, payType 조회(급여담당자용)
     * @Method Name : retrievePayrollCalculationExecIdData
     * @param param
     * @return boolean
     * @throws Exception
     */
    public LGCOMData retrievePayrollCalculationExecIdData(LGCOMData param) {
    	return this.commonDao.select("LGVPAYP0002.retrievePayrollCalculationExecIdData", param);
    }
}
