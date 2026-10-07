/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00200ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 07. 14.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsmpc.lgsmpc00200.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.service.MailService;
import com.lgd.lgcom.common.util.HttpUtil;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsmpc.lgsmpc00200.service.LGUTLC00200Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00200.service.serviceImpl.LGUTLC00200ServiceImpl.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 07. 14. 오후 1:39:58
 * @Version
 */
@Service("LGSMPC00200Service")
public class LGUTLC00200ServiceImpl implements LGUTLC00200Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00200ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Autowired
	private MailService mailService;
	
	@Autowired
	private BatchService batchService;

    /**
     * Desc : Summary 목록을 조회한다.
     * @Method Name : retrieveSummaryList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public void sendExecuteRequest(LGCOMData param) {
		LOGGER.debug("sendExecuteRequest LGCOMData param : "  + param );
		LGCOMData result = batchService.executeBatch( param );
		LOGGER.debug("sendExecuteRequest : "  + result );
    }

	public LGCOMData sendMailTest(LGCOMData param) {
		return mailService.sendMailTest( param );
    }
	
}
