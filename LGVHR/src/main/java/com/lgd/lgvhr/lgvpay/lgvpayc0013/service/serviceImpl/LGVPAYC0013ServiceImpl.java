/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0013ServiceImpl.java
 * @Desc    : Payroll Run ( 급여 실행하기 위한 프로그램, 사번 구간을 넘김)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2017.11.21  손수양      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayc0013.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayc0013.service.LGVPAYC0013Service;

/**
 * @param <LGVPAYC0013ServiceImpl>
 *
 * @Author    손수양 
 * @Date      2017. 11. 21. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAYC0013Service")
public class LGVPAYC0013ServiceImpl implements LGVPAYC0013Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYC0013ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executePayrollRun(param);
	}

	/**
	 * Desc : 사번, 급여기간, 대상자세트를 넘겨서 급여를 실행하는 프로그램 
	 * @Method Name : executePayrollRun
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executePayrollRun(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return commonDao.select("LGVPAYC0013.executePayrollRun", param );
	}
}
