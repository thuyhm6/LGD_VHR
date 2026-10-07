/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00010ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 8.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00010.service.LGUTLC00010Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00010.service.serviceImpl.LGUTLC00010ServiceImpl.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 8. 오후 4:35:58
 * @Version
 */
@Service("LGUTLC00010Service")
public class LGUTLC00010ServiceImpl implements LGUTLC00010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 로깅 목록을 조회한다.
	 * @Method Name : retrieveLoggingList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLoggingList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00010.retrieveLoggingList",param);
	}
}
