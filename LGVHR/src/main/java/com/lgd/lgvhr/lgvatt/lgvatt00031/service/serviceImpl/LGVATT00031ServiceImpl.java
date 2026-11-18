/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT00031ServiceImpl.java
 * @Desc    : Pregnant EMP Management (임신 직원 관리)
 *            - OT_ALLOW_FLAG = 'N' 인 기간에는 LGVATT20011/20020/20040/20060 에서 OT 입력 불가
 *              (임신 : 25주차 시작일 ~ 종료일, 육아 : 시작일 ~ 종료일)
 *              (체크 : LGVATTCOMMService.validatePregnantOt)
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00031.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt00031.service.LGVATT00031Service;

@Service(value = "LGVATT00031Service")
public class LGVATT00031ServiceImpl implements LGVATT00031Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00031ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	@Override
	public List<LGCOMData> retrievePregnantEmp(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00031.retrievePregnantEmp", param);
	}

	@Override
	public List<LGCOMData> excelDownData(LGCOMData param) {

		int sessionId = LGCOMUtils.getRandomNumber();
		param.set("sessionId", sessionId);
		LOGGER.debug("param = " + param);
		int resultCnt = this.commonDao.insert("LGVATT00031.excelDownData", param);

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
	@Transactional(propagation = Propagation.REQUIRED)
	public void savePregnantEmp(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData) param.get(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData projectSession = (LGCOMData) param.get("LGVHR_PROJECT_SESSION");
		String applicationUserId = userSession.getString("applicationUserId");
		String subsidiaryCode = projectSession.getString("subsidiaryCode");

		List<LGCOMData> deleteList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_DELETE);
		List<LGCOMData> insertList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);

		// 기간 중복 체크 대상 사번
		Set<String> employeeSet = new HashSet<String>();

		for (LGCOMData item : LGCOMUtils.emptyIfNull(deleteList)) {
			item.set("subsidiaryCode", subsidiaryCode);
			this.commonDao.delete("LGVATT00031.deletePregnantEmp", item);
		}

		for (LGCOMData item : LGCOMUtils.emptyIfNull(insertList)) {
			validateItem(item);
			item.set("subsidiaryCode", subsidiaryCode);
			item.set("applicationUserId", applicationUserId);
			this.commonDao.update("LGVATT00031.mergePregnantEmp", item);
			employeeSet.add(item.getString("employeeNo"));
		}

		for (LGCOMData item : LGCOMUtils.emptyIfNull(updateList)) {
			validateItem(item);
			item.set("subsidiaryCode", subsidiaryCode);
			item.set("applicationUserId", applicationUserId);
			this.commonDao.update("LGVATT00031.mergePregnantEmp", item);
			employeeSet.add(item.getString("employeeNo"));
		}

		checkOverlapPeriod(subsidiaryCode, employeeSet);
	}

	@Override
	@SuppressWarnings("unchecked")
	@Transactional(propagation = Propagation.REQUIRED)
	public void createPregnantEmpUpload(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData) param.get(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData projectSession = (LGCOMData) param.get("LGVHR_PROJECT_SESSION");
		String subsidiaryCode = projectSession.getString("subsidiaryCode");

		LGCOMData inputData = new LGCOMData();
		inputData.set("sessionId", param.getString("sessionId"));
		inputData.set("applicationUserId", userSession.get("applicationUserId"));
		inputData.set("subsidiaryCode", subsidiaryCode);

		// 1. 업로드 데이터 검증 (오류가 있으면 전체 반영하지 않음)
		List<LGCOMData> errorList = this.commonDao.selectList("LGVATT00031.retrieveUploadErrorList", inputData);
		if (errorList != null && !errorList.isEmpty()) {
			StringBuilder sb = new StringBuilder("Upload data error:");
			int max = Math.min(errorList.size(), 10);
			for (int i = 0; i < max; i++) {
				LGCOMData error = errorList.get(i);
				sb.append("\n- Row ").append(error.getString("seqNo"))
				  .append(" [").append(error.getString("employeeNo")).append("] ")
				  .append(error.getString("errorMsg"));
			}
			if (errorList.size() > max) {
				sb.append("\n... (").append(errorList.size()).append(" errors)");
			}
			throw new LGCOMException(sb.toString());
		}

		// 2. 반영 (사번 + 시작일 기준 MERGE)
		this.commonDao.update("LGVATT00031.mergeUploadPregnantEmp", inputData);

		// 3. 기간 중복 체크
		Set<String> employeeSet = new HashSet<String>();
		for (LGCOMData emp : LGCOMUtils.emptyIfNull(
				(List<LGCOMData>) this.commonDao.selectList("LGVATT00031.retrieveUploadEmployeeList", inputData))) {
			employeeSet.add(emp.getString("employeeNo"));
		}
		checkOverlapPeriod(subsidiaryCode, employeeSet);
	}

	/**
	 * 필수값, 사번 존재여부, 시작일/종료일 체크
	 */
	private void validateItem(LGCOMData item) {
		String employeeNo = item.getString("employeeNo");
		String startDate = item.getString("effectiveStartDate");
		String endDate = item.getString("effectiveEndDate");

		// 종료일은 선택 (공백 = 무기한)
		if (isEmpty(employeeNo) || isEmpty(startDate)) {
			throw new LGCOMException("Employee No and Start Date are required.");
		}

		LGCOMData exists = this.commonDao.select("LGVATT00031.retrieveEmployeeExists", item);
		if (exists == null || exists.getInt("cnt") == 0) {
			throw new LGCOMException("Employee No does not exist : " + employeeNo);
		}

		boolean hasEndDate = !isEmpty(endDate);
		if (!hasEndDate) {
			item.set("effectiveEndDate", null);
		} else if (toYyyymmdd(endDate).compareTo(toYyyymmdd(startDate)) < 0) {
			throw new LGCOMException("End Date is earlier than Start Date : " + employeeNo + " (" + startDate + " ~ " + endDate + ")");
		}

		if (isEmpty(item.getString("otAllowFlag"))) {
			item.set("otAllowFlag", "N");
		}

		// 분류 (PREGNANT : 임신 / CHILD_CARE : 육아). 분류용이며 OT 제한 로직과 무관
		String empCategoryCode = item.getString("empCategoryCode");
		if (isEmpty(empCategoryCode)) {
			item.set("empCategoryCode", "PREGNANT");
		} else if (!"PREGNANT".equals(empCategoryCode) && !"CHILD_CARE".equals(empCategoryCode)) {
			throw new LGCOMException("Invalid Category : " + employeeNo + " (" + empCategoryCode + ")");
		}

		// 임신 25주차 시작일 : 임신(PREGNANT) 인 경우 필수.
		// OT 제한 기간 = 임신 : 25주차 시작일 ~ 종료일 / 육아(CHILD_CARE) : 시작일 ~ 종료일
		if (!"PREGNANT".equals(item.getString("empCategoryCode"))) {
			item.set("week25Date", null);
		} else {
			String week25Date = item.getString("week25Date");
			if (isEmpty(week25Date)) {
				throw new LGCOMException("Week 25 Date is required for Pregnant : " + employeeNo);
			}
			String week25Ymd = toYyyymmdd(week25Date);
			if (week25Ymd.compareTo(toYyyymmdd(startDate)) < 0
					|| (hasEndDate && week25Ymd.compareTo(toYyyymmdd(endDate)) > 0)) {
				throw new LGCOMException("Week 25 Date must be between Start Date and End Date : " + employeeNo
						+ " (" + startDate + " ~ " + (hasEndDate ? endDate : "") + ", Week 25 : " + week25Date + ")");
			}
		}
	}

	/**
	 * 동일 사번의 기간이 겹치는지 체크
	 */
	private void checkOverlapPeriod(String subsidiaryCode, Set<String> employeeSet) {
		for (String employeeNo : employeeSet) {
			LGCOMData checkParam = new LGCOMData();
			checkParam.set("subsidiaryCode", subsidiaryCode);
			checkParam.set("employeeNo", employeeNo);

			LGCOMData overlap = this.commonDao.select("LGVATT00031.retrieveOverlapPeriod", checkParam);
			if (overlap != null && !overlap.isEmpty()) {
				throw new LGCOMException("Period is overlapped : " + employeeNo + " ("
						+ overlap.getString("effectiveStartDate") + " ~ "
						+ (isEmpty(overlap.getString("effectiveEndDate")) ? "" : overlap.getString("effectiveEndDate")) + ")");
			}
		}
	}

	private boolean isEmpty(String value) {
		return value == null || value.trim().length() == 0;
	}

	// 'DD/MM/YYYY' -> 'YYYYMMDD'
	private String toYyyymmdd(String ddMmYyyy) {
		String[] parts = ddMmYyyy.split("/");
		if (parts.length != 3) {
			throw new LGCOMException("Invalid date (DD/MM/YYYY) : " + ddMmYyyy);
		}
		return parts[2] + parts[1] + parts[0];
	}
}
