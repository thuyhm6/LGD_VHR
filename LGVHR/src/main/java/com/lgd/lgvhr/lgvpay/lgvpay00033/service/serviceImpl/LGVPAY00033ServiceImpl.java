package com.lgd.lgvhr.lgvpay.lgvpay00033.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00033.service.LGVPAY00033Service;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00033ServiceImpl.java
 * @Desc    : Paid Leave Payment Rate Setup (PL_SW / PL_PLP)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Perfect Actual
 * 	1. 1	2026.10.26     HMT           Rebuild : payment rate setup / payroll item mapping
 *------------------------------------------------------------------------------
 */
@Service(value="LGVPAY00033Service")
public class LGVPAY00033ServiceImpl implements LGVPAY00033Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00033ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 지급률 조회
	 * @Method Name : retrievePlRateList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrievePlRateList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00033.retrievePlRateList",param);
	}

	/**
	 * Desc : 지급률 저장 (저장 후 구간/기간 중복 검증)
	 * @Method Name : savePlRate
	 * @param  param
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void savePlRate(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession    = (LGCOMData)param.get("USER_SESSION");
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		String subsidiaryCode    = projectSession.getString("subsidiaryCode");

		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			this.commonDao.delete("LGVPAY00033.deletePlRate",dItem);
		}
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00033.updatePlRate",uItem);
		}
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			iItem.put("subsidiaryCode", subsidiaryCode);
			this.commonDao.insert("LGVPAY00033.insertPlRate",iItem);
		}

		//구간/기간 중복 검증
		LGCOMData check = new LGCOMData();
		check.set("subsidiaryCode", subsidiaryCode);
		LGCOMData conflict = (LGCOMData)this.commonDao.select("LGVPAY00033.retrievePlRateConflict", check);
		if(conflict != null) {
			throw new LGCOMException("[" + conflict.getString("paidLeaveDetailCode") + " / " + conflict.getString("empCategoryCode")
					+ "] Tier " + conflict.getString("tierNoA") + " and Tier " + conflict.getString("tierNoB")
					+ " overlap (days range and effective period) from " + conflict.getString("conflictDate") + ".");
		}
	}

	/**
	 * Desc : 급여항목 매핑 조회
	 * @Method Name : retrievePlItemMapList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrievePlItemMapList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00033.retrievePlItemMapList",param);
	}

	/**
	 * Desc : 급여항목 매핑 저장
	 * @Method Name : savePlItemMap
	 * @param  param
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void savePlItemMap(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession    = (LGCOMData)param.get("USER_SESSION");
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");

		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			this.commonDao.delete("LGVPAY00033.deletePlItemMap",dItem);
		}
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00033.updatePlItemMap",uItem);
		}
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			this.commonDao.insert("LGVPAY00033.insertPlItemMap",iItem);
		}
	}

	/**
	 * Desc : 급여항목 콤보
	 * @Method Name : retrievePayrollItemList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrievePayrollItemList(LGCOMData param) {
		return this.commonDao.selectList("LGVPAY00033.retrievePayrollItemList",param);
	}
}
