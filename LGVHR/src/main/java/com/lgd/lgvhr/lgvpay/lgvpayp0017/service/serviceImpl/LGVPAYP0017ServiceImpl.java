/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0017Service.java
 * @Desc    : Payroll Item Detail List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 12.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0017.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0017.service.LGVPAYP0017Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0017.service.serviceImpl.LGVPAYP0017ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 12.
 * @Version
 */
@Service("LGVPAYP0017Service")
public class LGVPAYP0017ServiceImpl implements LGVPAYP0017Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0017ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Payroll Item Detail List 를 조회한다.
     * @Method Name : retrievePayrollItemDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemDetailList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0017.retrievePayrollItemDetailList", param);
    }
}
