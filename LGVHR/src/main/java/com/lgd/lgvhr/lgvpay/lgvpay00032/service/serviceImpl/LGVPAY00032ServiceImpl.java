package com.lgd.lgvhr.lgvpay.lgvpay00032.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00032.service.LGVPAY00032Service;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00032ServiceImpl.java
 * @Desc    : Paid Leave Payment Calculation (PL_SW / PL_PLP)
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List
 * 	1. 1	2026.10.26     HMT           Rebuild : calculation by rate setup (LGVPAY00033)
 *------------------------------------------------------------------------------
 */
@Service(value="LGVPAY00032Service")
public class LGVPAY00032ServiceImpl implements LGVPAY00032Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00032ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 월 계산결과 조회 (사번 / PL 코드 / Tier)
	 * @Method Name : retrievePaidLeaveHours
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveHours(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00032.retrievePaidLeaveHours",param);
	}

	/**
	 * Desc : 일별 상세 조회
	 * @Method Name : retrievePaidLeaveDaily
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveDaily(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00032.retrievePaidLeaveDaily",param);
	}

	/**
	 * Desc : Paid Leave 지급액 계산 (lgvpay_paid_leave_pkg.calculate_paid_leave)
	 * @Method Name : saveCalculatePaidLeave
	 * @param  param
	 * @throws Exception
	 */
	public void saveCalculatePaidLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData inputData      = new LGCOMData();
		LGCOMData userSession    = (LGCOMData)param.get("USER_SESSION");
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");

		inputData.set("subsidiaryCode", projectSession.getString("subsidiaryCode"));
		inputData.set("payMonth", param.getString("payMonth"));
		inputData.set("paidLeaveDetailCode", param.getString("paidLeaveDetailCode"));
		inputData.set("employeeNo", param.getString("employeeNo"));
		inputData.set("applicationUserId", userSession.getString("applicationUserId"));

		this.commonDao.select("LGVPAY00032.saveCalculatePaidLeave",inputData);

		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}

	/**
     * Desc : 엑셀 다운로드
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVPAY00032.createExcelDownloadData",param);

        List<LGCOMData> list = LGCOMData.createList();

        try {
        	LGCOMData result = new LGCOMData();
            result.set("resultCnt", resultCnt);
            result.set("sessionId", sessionId);

            list.add(result);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }

        return list;
    }
}
