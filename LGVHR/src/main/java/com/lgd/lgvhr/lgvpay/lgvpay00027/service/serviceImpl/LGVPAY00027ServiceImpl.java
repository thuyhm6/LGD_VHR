/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00027Service.java
 * @Desc    : Payroll Item List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 04.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00027.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00027.service.LGVPAY00027Service;
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00027.service.serviceImpl.LGVPAY00027ServiceImpl.java
 * </PRE>
 *
 * @Author limsujin
 * @Date 2018. 01. 04.
 * @Version
 */
@Service("LGVPAY00027Service")
public class LGVPAY00027ServiceImpl implements LGVPAY00027Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00027ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	@Resource(name = "messageSourceAccessor")
	protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Payroll Item List 를 조회한다.
	 * 
	 * @Method Name : retrievePayrollItemList
	 * @param param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAllowanceMappingList(LGCOMData param) {
		return this.commonDao.selectList("LGVPAY00027.retrieveAllowanceMappingList", param);
	}
	
	public boolean retrievegAllowanceMappingDuplicate(LGCOMData param) {
		LGCOMData gradeName = commonDao.select("LGVPAY00027.retrievegAllowanceMappingDuplicate", param);
		if (!NullUtil.isNull(gradeName)) {
			return true;
		}
		return false;
	}

	public boolean retrievegAllowanceMappingDuplicateUpdate(LGCOMData param) {
		LGCOMData gradeName = commonDao.select("LGVPAY00027.retrievegAllowanceMappingDuplicateUpdate", param);
		if (!NullUtil.isNull(gradeName)) {
			return true;
		}
		return false;
	}

	@SuppressWarnings("unchecked")
	@Transactional(propagation = Propagation.REQUIRED)
	public LGCOMData saveAllowanceMapping(LGCOMData param) {

		LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");

		/* 삭제건 처리 */
		List<LGCOMData> dList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_DELETE);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(dList)) {

			item.set(LGCOMConstants.HTTP_SESSION_KEY, userSession);
			item.set("LGVHR_PROJECT_SESSION", projectSession);

			// 급여항목 Use 전체 삭제
			commonDao.delete("LGVPAY00027.deleteAllowanceMapping", item);
		}

		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
			if (retrievegAllowanceMappingDuplicateUpdate(item)) {
				throw new LGCOMException(messageSourceAccessor.getMessage("error.duplicateValue"));
			} else {
				item.set(LGCOMConstants.HTTP_SESSION_KEY, userSession);
				item.set("LGVHR_PROJECT_SESSION", projectSession);

				LGCOMData allowanceId = commonDao.select("LGVPAY00027.retrievegAllowanceId", item);
				if (!NullUtil.isNull(allowanceId)) {
					item.set("allowanceId", allowanceId.getString("allowanceId"));
					commonDao.update("LGVPAY00027.updateAllowanceMapping", item);
				}
			}
		}

		/* 등록건 저장 */
		List<LGCOMData> cList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
			if (retrievegAllowanceMappingDuplicate(item)) {
				throw new LGCOMException(messageSourceAccessor.getMessage("error.duplicateValue"));
			} else {
				item.set(LGCOMConstants.HTTP_SESSION_KEY, userSession);
				item.set("LGVHR_PROJECT_SESSION", projectSession);

				LGCOMData idData = commonDao.select("LGVPAY00027.retrievegAllowanceMappingId");

				if (!NullUtil.isNull(idData)) {
					item.set("seqValue", idData.getString("seqValue"));
					commonDao.insert("LGVPAY00027.insertAllowanceMapping", item);
				} 
			}
		}
		return param;
	}
}
