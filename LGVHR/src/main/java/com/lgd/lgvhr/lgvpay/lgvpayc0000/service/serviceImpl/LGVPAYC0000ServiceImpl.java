/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYC0000Service.java
 * @Desc    : 급여 Batch Service 등록 
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
package com.lgd.lgvhr.lgvpay.lgvpayc0000.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayc0000.service.LGVPAYC0000Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayc0000.service.LGVPAYC0000ServiceImpl.java
 * </PRE>
 *
 * @Author    손수양
 * @Date      2017. 11. 21. 오후 1:39:58
 * @Version
 */
@Service("LGVPAYC0000Service")
public class LGVPAYC0000ServiceImpl implements LGVPAYC0000Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYC0000ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Autowired
	private BatchService batchService;

    /**
     * Desc : Batch Service를 호출한다. PAY에서 사용할 BATCH Service를 호출한다.
     * @Method Name : sendExecuteRequest
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public void sendExecuteRequest(LGCOMData param) {
		LOGGER.debug("sendExecuteRequest LGCOMData param : "  + param );		
		LGCOMData result = batchService.executeBatch( param );
		LOGGER.debug("sendExecuteRequest : "  + result );
    }
	
	
}
