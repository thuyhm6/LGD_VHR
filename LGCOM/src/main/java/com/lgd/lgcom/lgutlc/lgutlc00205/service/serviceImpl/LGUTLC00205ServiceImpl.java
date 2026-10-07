/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00205Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 5. 10.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00205.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.dao.DynamicDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00205.service.LGUTLC00205Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00205.service.serviceImpl.LGUTLC00205ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2017. 5. 10. 오후 4:35:58
 * @Version
 */
@Service("LGUTLC00205Service")
public class LGUTLC00205ServiceImpl implements LGUTLC00205Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00205ServiceImpl.class);

	@Resource
	DynamicDao dao;

	/**
	* Desc : Custom Query를 받아 수행하고 결과를 반환한다.
	* @Method Name : saveExecuteCustomQuery
	* @param  param
	* @return List<LGCOMData>
	* @throws Exception
	*/
	public LGCOMData saveExecuteCustomQuery(LGCOMData param) {
		LOGGER.debug("param = " + param);
		String executeQuery = LGCOMUtils.nvl(param.getString("executeQuery")).trim();
		String executeType = executeQuery.substring(0,6).toUpperCase();
		LOGGER.debug("executeQuery = " + executeQuery);
		LOGGER.debug("executeType = " + executeType);
		
		LGCOMData result = new LGCOMData();
		if("SELECT".equalsIgnoreCase(executeType)) {
			result = this.dao.selectListWithMeta(executeQuery);
			result.set("executeType","R");
		} else {
			result.set("executeCount",this.dao.update(executeQuery));
			result.set("executeType","U");
		}
		LOGGER.debug("result = " + result);
		return result;
	}
}
