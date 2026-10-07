/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00009ServiceImpl.java
 * @Desc    : Payment Master All Employee
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 26.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00009.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00009.service.LGVPAY00009Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00009.service.serviceImpl.LGVPAY00009ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 26.
 * @Version
 */
@Service("LGVPAY00009Service")
public class LGVPAY00009ServiceImpl implements LGVPAY00009Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00009ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 임직원 급여관련 정보를 조회한다.
	 * @Method Name : retrievePaymentMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaymentMasterList(LGCOMData param) {
		return commonDao.selectList("LGVPAY00009.retrievePaymentMasterList", param);
    }

}
