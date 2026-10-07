/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpayp0003ServiceImpl.java
 * @Desc    : Payroll Item 조회 팝업
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 12.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0003.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0003.service.LGVPAYP0003Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0003.controller.LGVPAYP0003Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 12. 오후 16:33:32
 * @Version
 */
@Service(value="LGVPAYP0003Service")
public class LGVPAYP0003ServiceImpl implements LGVPAYP0003Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0003ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Payroll Item를 조회한다.
	 * @Method Name : retrievePayrollItemList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePayrollItemList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAYP0003.retrievePayrollItemList",param);
	}
}
