/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpayp0001ServiceImpl.java
 * @Desc    : 급여대상자 SET 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0001.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0001.service.LGVPAYP0001Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0001.controller.LGVPAYP0001Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAYP0001Service")
public class LGVPAYP0001ServiceImpl implements LGVPAYP0001Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0001ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 급여대상자 SET 을 조회한다.
	 * @Method Name : retrieveCalculationSet
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalculationSetList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAYP0001.retrieveCalculationSetList",param);
	}
}
