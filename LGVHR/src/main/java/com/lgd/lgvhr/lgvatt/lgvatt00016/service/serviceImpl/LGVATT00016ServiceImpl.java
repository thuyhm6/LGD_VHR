package com.lgd.lgvhr.lgvatt.lgvatt00016.service.serviceImpl;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;

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
import com.lgd.lgvhr.lgvatt.lgvatt00016.service.LGVATT00016Service;

@Service(value = "LGVATT00016Service")
public class LGVATT00016ServiceImpl implements LGVATT00016Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00016ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	@Override
	public List<LGCOMData> retrieveAnnualLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00016.retrieveAnnualLeave", param);
	}

	@Override
	public List<LGCOMData> excelDownData(LGCOMData param) {

		int sessionId = LGCOMUtils.getRandomNumber();
		param.set("sessionId", sessionId);
		LOGGER.debug("param = " + param);
		int resultCnt = this.commonDao.insert("LGVATT00016.excelDownData", param);

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

	@Override
	@SuppressWarnings("unchecked")
	public void saveAnnualLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");

		List<LGCOMData> deleteList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_DELETE);
		List<LGCOMData> insertList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);

		for (LGCOMData item : LGCOMUtils.emptyIfNull(deleteList)) {
			item.set("applicationUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGVATT00016.deleteAnnualLeave", item);
		}

		for (LGCOMData item : insertList) {
			item.set("applicationUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGVATT00016.mergeAnnualLeave", item);
		}

		for (LGCOMData item : updateList) {
			item.set("applicationUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGVATT00016.mergeAnnualLeave", item);
		}

	}

	@Override
	@Transactional(propagation=Propagation.REQUIRED)
	@SuppressWarnings("unchecked")
	public void recalculateAnnualLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");
		String applicationUserId = userSession.getString("applicationUserId");

		List<LGCOMData> modifyList = (List<LGCOMData>) param.get("modifyList");

		// 같은 employee_no + 대상월(targetYyyymm)은 1회만 가산 (emp_type이 다른 여러 건이 함께 체크되어도 중복 가산 방지)
		Set<String> creditedTargets = new HashSet<String>();

		for (LGCOMData item : LGCOMUtils.emptyIfNull(modifyList)) {
			item.set("applicationUserId", applicationUserId);

			// TB_ATT_EMP_ANNUAL_M.annual_leave_days 재계산 (이미 값이 있으면 0건 처리되고 SKIP)
			int updatedCnt = this.commonDao.update("LGVATT00016.recalculateAnnualLeave", item);
			if (updatedCnt == 0) {
				continue;
			}

			String effectiveEndDate = item.getString("effectiveEndDate");
			if (effectiveEndDate == null || effectiveEndDate.isEmpty()) {
				// effective_end_date가 없으면 대상월을 정할 수 없어 calibration 가산은 건너뜀
				continue;
			}

			String targetYyyymm = resolveTargetYyyymm(item.getString("effectiveStartDate"), effectiveEndDate);
			String dedupKey = item.getString("employeeNo") + "|" + targetYyyymm;

			if (creditedTargets.add(dedupKey)) {
				item.set("targetYyyymm", targetYyyymm);
				item.set("prevYyyymm", previousYyyymm(targetYyyymm));

				// 재계산된 annual_leave_days를 TB_ATT_ANNUAL_LEAVE_N.residual_annual_leave_days(대상월)에 가산
				this.commonDao.update("LGVATT00016.creditResidualAnnualLeaveDays", item);

				// 재계산된 annual_leave_days를 TB_ATT_ANNUAL_LEAVE_N.annual_calibration_days(대상월의 전월)에 가산
				this.commonDao.update("LGVATT00016.creditAnnualCalibrationDays", item);
			}
		}
	}

	/**
	 * effective_start_date의 YYYYMM. 단, effective_end_date 연도의 1월보다 이전이면 effective_end_date 연도의 1월을 반환
	 */
	private String resolveTargetYyyymm(String effectiveStartDate, String effectiveEndDate) {
		String startYyyymm = toYyyymm(effectiveStartDate);
		String endYearJan = toYyyy(effectiveEndDate) + "01";

		return startYyyymm.compareTo(endYearJan) < 0 ? endYearJan : startYyyymm;
	}

	// 'YYYYMM'의 전월 'YYYYMM' (1월이면 전년도 12월)
	private String previousYyyymm(String yyyymm) {
		int year = Integer.parseInt(yyyymm.substring(0, 4));
		int month = Integer.parseInt(yyyymm.substring(4, 6));

		month -= 1;
		if (month == 0) {
			month = 12;
			year -= 1;
		}

		return String.format("%04d%02d", year, month);
	}

	// 'DD/MM/YYYY' -> 'YYYYMM'
	private String toYyyymm(String ddMmYyyy) {
		String[] parts = ddMmYyyy.split("/");
		return parts[2] + parts[1];
	}

	// 'DD/MM/YYYY' -> 'YYYY'
	private String toYyyy(String ddMmYyyy) {
		String[] parts = ddMmYyyy.split("/");
		return parts[2];
	}

	@Override
	public List<LGCOMData> retrieveEmpTypeNameList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00016.retrieveEmpTypeNameList", param);
	}

    public void createAnnualLeaveUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);

        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");

        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));

		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
		commonDao.select("LGVATT00016.UploadExcelFile",inputData);

	}

}
