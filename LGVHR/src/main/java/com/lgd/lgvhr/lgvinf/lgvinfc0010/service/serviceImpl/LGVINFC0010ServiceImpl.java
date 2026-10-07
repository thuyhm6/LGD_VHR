/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVINFC0010Service.java
 * @Desc    : 사용자 기본권한 설정 Batch 프로그램
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1.0     2017.11.13  김재현      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvinf.lgvinfc0010.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvinf.lgvinfc0010.service.LGVINFC0010Service;

@Service(value="LGVINFC0010Service")
public class LGVINFC0010ServiceImpl implements LGVINFC0010Service, CommonBatchService {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVINFC0010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		return executeUserRoleInterface(param);
	}

	/**
	 * Desc : 
	 * @Method Name : executeUserRoleInterface
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public LGCOMData executeUserRoleInterface(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData ldata = commonDao.select("LGVINFC0010.executeUserRoleInterface", param );		
		return ldata;
	}
	
	
	

}
