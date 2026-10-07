/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00240ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 2. 22.  	forain  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00240.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00230.service.serviceImpl.LGSYSC00230ServiceImpl;
import com.lgd.lgcom.lgsysc.lgsysc00240.service.LGSYSC00240Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00240.service.serviceImpl.LGSYSC00240ServiceImpl.java
 * </PRE>
 *
 * @Author forain
 * @Date 2017. 2. 22. 오후 5:06:23
 * @Version
 */
@Service(value = "LGSYSC00240Service")
public class LGSYSC00240ServiceImpl implements LGSYSC00240Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00230ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 *
	 * Desc : 결자자에 의해 지정된 검토자 목록을 저장한다.
	 * 
	 * @Method Name : insertRequestReviewers
	 * @param param
	 */
	public void insertRequestReviewers(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData userSession = (LGCOMData) param.get(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData dataRow = (LGCOMData) param.get("dataRow");
		List<LGCOMData> insertList = (List<LGCOMData>) dataRow.get(LGCOMConstants.STATUS_INSERT);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(insertList)) {
			item.set("sessUserName", userSession.getString("userName"));
			item.set("inspectionComment", param.getString("comment"));
			this.commonDao.insert("LGSYSC00240.insertRequestReviewers", item);
			if (!"OK".equals(item.getString("errorCode"))) {
				throw new LGCOMException(item.getString("errorMsg"));
			}
		}
		List<LGCOMData> updateList = (List<LGCOMData>) dataRow.get(LGCOMConstants.STATUS_UPDATE);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(updateList)) {
			item.set("sessUserName", userSession.getString("userName"));
			item.set("inspectionComment", param.getString("comment"));
			this.commonDao.insert("LGSYSC00240.insertRequestReviewers", item);
			if (!"OK".equals(item.getString("errorCode"))) {
				throw new LGCOMException(item.getString("errorMsg"));
			}
		}
	}

	/**
	 * Desc : 결재자의 검토요청내용 및 검토자의 검토의견을 조회한다.
	 * 
	 * @Method Name : retrieveReviewRequestData
	 * @param param
	 * @return
	 */
	public LGCOMData retrieveReviewRequestData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGSYSC00240.retrieveReviewRequestData", param);
	}

	/**
	 * Desc : 검토자의 검토의견을 저장한다.
	 * 
	 * @Method Name : updateRequestReviewData
	 * @param param
	 */
	public void updateRequestReviewData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.update("LGSYSC00240.updateRequestReviewData", param);
		if (!"OK".equals(param.getString("errorCode"))) {
			throw new LGCOMException(param.getString("errorMsg"));
		}
	}
}
