/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0018ServiceImpl.java
 * @Desc    : Print by Employee PaySlip
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 03. 14.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0018.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0018.service.LGVPAYP0018Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0018.service.serviceImpl.LGVPAYP0018ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 03. 14.
 * @Version
 */
@Service("LGVPAYP0018Service")
public class LGVPAYP0018ServiceImpl implements LGVPAYP0018Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0018ServiceImpl.class);

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
    	return this.commonDao.selectList("LGVPAYP0018.retrievePayrollRunEmpList", param);
    }
}
