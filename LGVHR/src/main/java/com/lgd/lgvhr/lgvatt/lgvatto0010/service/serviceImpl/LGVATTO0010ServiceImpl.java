/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTO0010ServiceImpl.java
 * @Desc    : 포틀릿 근태 Summary 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 02.    javaranbo1    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatto0010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatto0010.service.LGVATTO0010Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatto0010.service.serviceImpl.LGVATTO0010ServiceImpl.java
 * </PRE>
 *
 * @Author    javaranbo1
 * @Date	  2018. 01. 02. 오후 3:48:12
 * @Version
 */
@Service("LGVATTO0010Service")
public class LGVATTO0010ServiceImpl implements LGVATTO0010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTO0010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 포틀릿에서 보여줄 근태 Summary 정보를 조회한다.
	 * @Method Name : retrievePortletATTSummary
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrievePortletATTSummary(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATTO0010.retrievePortletATTSummary",param);
	}
}
