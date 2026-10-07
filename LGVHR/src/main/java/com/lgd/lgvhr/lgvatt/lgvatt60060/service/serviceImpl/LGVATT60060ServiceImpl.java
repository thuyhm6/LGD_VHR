/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT60060ServiceImpl.java
 * @Desc    : 근태 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt60060.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt60060.service.LGVATT60060Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60060.service.serviceImpl.LGVATT60060ServiceImpl.java
 * </PRE>
 *
 * @Author sangnv
 * @Date 2017. 10. 18. 오후 3:48:12
 * @Version
 */
@Service("LGVATT60060Service")
public class LGVATT60060ServiceImpl implements LGVATT60060Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT60060ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 월간 근태 리포트 추출
	 * 
	 * @Method Name : createExcelMonthReport
	 * @param param
	 * @return LGCOMData
	 */
	@Override
	public List<LGCOMData> createExcelActualPlan(LGCOMData param) {
		List<LGCOMData> list = LGCOMData.createList();

		LOGGER.debug("param = " + param);

		List<LGCOMData> reportParam = param.getList("report");

		for (LGCOMData data : reportParam) {
			int sessionId = LGCOMUtils.getRandomNumber();

			data.set("sessionId", sessionId);
			data.set("sessionUserId", ((LGCOMData) param.get("USER_SESSION")).getString("applicationUserId"));
			data.set("subsidiaryCode", ((LGCOMData) param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
			data.set("toDateActual", param.getString("toDateActual"));
			data.set("fromDateActual", param.getString("fromDateActual"));
			data.set("toDatePlan", param.getString("toDatePlan"));
			data.set("fromDatePlan", param.getString("fromDatePlan"));
			int resultCnt = 0;
			if ("Actual".equals(data.getString("sheetName").replaceAll(" ", ""))) {
				resultCnt = this.commonDao.insert("LGVATT60060.createExcelActualAttendance", data);
			} else if ("Plan".equals(data.getString("sheetName").replaceAll(" ", ""))) {
				resultCnt = this.commonDao.insert("LGVATT60060.createExcelPlanAttendance", data);
			}

			try {
				LGCOMData result = new LGCOMData();

				String strSess = String.valueOf(sessionId);
				Double doubleSessionId = Double.parseDouble(strSess);
				LOGGER.debug("doubleSessionId : {}", doubleSessionId);
				LOGGER.debug("doubleSessionId : {}", Double.valueOf(strSess).doubleValue());
				result.set("resultCnt", resultCnt);
				result.set("sessionId", Double.valueOf(strSess).doubleValue());
				result.set("sheetName", data.getString("sheetName"));
				list.add(result);
			} catch (Exception e) {
				LOGGER.error(e.getMessage(), e);
			}

		}
		return list;
	}

}
