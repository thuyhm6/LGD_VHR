/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0014ServiceImpl.java
 * @Desc    : Retroactive Payroll Run ( 소급 급여 실행하기 위한 프로그램, 사번 구간을 넘김)
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2018.10.10  이형준      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayc0014.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayc0014.service.LGVPAYC0014Service;

/**
 * @param <LGVPAYC0014ServiceImpl>
 *
 * @Author    이형준 
 * @Date      2018. 10. 10. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAYC0014Service")
public class LGVPAYC0014ServiceImpl implements LGVPAYC0014Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYC0014ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeRetroactivePayrollRun(param);
	}

	/**
	 * Desc : 사번, 급여기간, 대상자세트를 넘겨서 소급 급여를 실행하는 프로그램 
	 * @Method Name : executeRetroactivePayrollRun
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeRetroactivePayrollRun(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return commonDao.select("LGVPAYC0014.executeRetroactivePayrollRun", param );
	}
}
