/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00100ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 7.13.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00100.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00100.service.LGUTLC00100Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00100.service.serviceImpl.LGUTLC00100ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 7.13. 오후 1:39:58
 * @Version
 */
@Service("LGUTLC00100Service")
public class LGUTLC00100ServiceImpl implements LGUTLC00100Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00100ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Service Logging의 Summary 목록을 메뉴별 서비스별 Summary 목록 조회
	 * @Method Name : retrieveServiceLogSummaryList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveServiceLogSummaryList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00100.retrieveServiceLogSummaryList",param);
	}

	/**
	 * Desc : Service Logging의 실행년월, 메뉴ID, 프로그램ID, 서비스명을 받아 실행 상세 목록 조회
	 * @Method Name : retrieveServiceLogDetailList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveServiceLogDetailList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00100.retrieveServiceLogDetailList",param);
	}
}
