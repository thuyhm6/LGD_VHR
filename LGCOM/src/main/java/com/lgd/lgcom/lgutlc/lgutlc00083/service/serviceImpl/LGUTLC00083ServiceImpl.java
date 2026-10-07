/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00080ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 8.  3.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00083.service.serviceImpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00080.service.LGUTLC00080Service;
import com.lgd.lgcom.lgutlc.lgutlc00083.service.LGUTLC00083Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00083.service.serviceImpl.LGUTLC00083ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 3. 오전 9:00:58
 * @Version
 */
@Service(value="LGUTLC00083Service")
public class LGUTLC00083ServiceImpl implements LGUTLC00083Service , CommonBatchService {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00083ServiceImpl.class);

	@Autowired
	LGUTLC00080Service service;

	
	/* 이 클래스를 Batch 작업으로 등록하기 위해 필수로 구현해야 하는 메소드  CommonBatchService 에 정의 돼 있으며, 
	 * 여기에서 구현한다. */
	@Override
	public LGCOMData execute(LGCOMData parameter) {
		return service.saveDynamicQueryResultListNewBatch(parameter);
	}
}
