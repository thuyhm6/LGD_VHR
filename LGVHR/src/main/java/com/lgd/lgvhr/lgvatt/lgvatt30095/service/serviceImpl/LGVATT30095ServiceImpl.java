package com.lgd.lgvhr.lgvatt.lgvatt30095.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30095.service.LGVATT30095Service;

@Service(value="LGVATT30095Service")
public class LGVATT30095ServiceImpl implements LGVATT30095Service{

	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30095ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : excelDownData
	 * @Method Name : excelDownData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData excelDownData(LGCOMData param) {

		int sessionId = LGCOMUtils.getRandomNumber();
		param.set("sessionId", sessionId);
		LOGGER.debug("param = " + param);

		int resultCnt = 0;
		// 리포트 종류별 Excel 데이터 생성
		if ( "OVERTIME_VIOLATIONS".equals(param.getString("reportName")) ) {
			resultCnt = this.commonDao.insert("LGVATT30095.excelDownOvertimeViolations", param);
		}

		LGCOMData result = new LGCOMData();
		result.set("resultCnt", resultCnt);
		result.set("sessionId", sessionId);
		return result;

	}

}
