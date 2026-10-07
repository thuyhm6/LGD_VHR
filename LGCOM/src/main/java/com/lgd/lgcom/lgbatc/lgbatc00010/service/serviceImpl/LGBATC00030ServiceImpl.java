/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00010Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 03.    김치민    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgbatc.lgbatc00010.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgbatc.lgbatc00010.service.LGBATC00030Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 * @param <LGBATC00010ServiceImpl>
 *
 * @Author    이종훈
 * @Date      2019. 09. 21. 오전 9:00:58
 * @Version
 */
@Service(value="LGBATC00030Service")
public class LGBATC00030ServiceImpl implements LGBATC00030Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGBATC00030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return commonDao.select("LGBATC00030.processServiceLog", param );
	}

}
