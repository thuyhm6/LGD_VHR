package com.lgd.lgvhr.lgvpay.lgvpay00031.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00031.service.LGVPAY00031Service;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00031ServiceImpl.java
 * @Desc    : Paid Leave Registration (PL_SW / PL_PLP) - Upload / Apply to T&A
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List
 * 	1. 1	2026.10.26     HMT           Rebuild : fix save/upload/apply, overlap check
 *------------------------------------------------------------------------------
 */
@Service(value="LGVPAY00031Service")
public class LGVPAY00031ServiceImpl implements LGVPAY00031Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00031ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Paid Leave 등록자 조회
	 * @Method Name : retrievePaidLeaveEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00031.retrievePaidLeaveEmpList",param);
	}

	/**
     * Desc : Paid Leave 등록자 저장 (기간 중복 체크)
     * @Method Name : savePaidLeaveEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
    @Transactional(propagation=Propagation.REQUIRED)
	public void savePaidLeaveEmp(LGCOMData param) {
		LOGGER.debug("savePaidLeaveEmp param = " + param);

		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData parameter   = (LGCOMData)param.get("parameter");

		String payMonth            = parameter.getString("payMonth");
		String paidLeaveDetailCode = parameter.getString("paidLeaveDetailCode");

		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			this.commonDao.delete("LGVPAY00031.deletePaidLeaveEmp",dItem);
		}
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("paidLeaveDetailCode", paidLeaveDetailCode);
			checkOverlap(uItem);
			this.commonDao.update("LGVPAY00031.updatePaidLeaveEmp",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			iItem.put("payMonth", payMonth);
			iItem.put("paidLeaveDetailCode", paidLeaveDetailCode);
			iItem.put("paidLeaveId", "");
			checkOverlap(iItem);
			this.commonDao.insert("LGVPAY00031.insertPaidLeaveEmp",iItem);
		}
	}

    /**
     * Desc : 같은 사번 + PL 코드의 기간 중복 체크
     * @Method Name : checkOverlap
     * @param  item
     */
    private void checkOverlap(LGCOMData item) {
    	LGCOMData result = (LGCOMData)this.commonDao.select("LGVPAY00031.retrieveOverlapCount", item);
    	if(result != null && Integer.parseInt(String.valueOf(result.get("overlapCnt"))) > 0) {
    		throw new LGCOMException("[" + item.getString("employeeNo") + "] "
    				+ item.getString("startDate") + " ~ " + item.getString("endDate")
    				+ " : Period overlaps an existing registration.");
    	}
    }

    /**
     * Desc : Paid Leave 등록자 엑셀 다운로드
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVPAY00031.createExcelDownloadData",param);

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

    /**
     * Desc : 엑셀업로드 (lgvpay_paid_leave_pkg.upload_paid_leave_emp)
     * @Method Name : createPaidLeaveEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createPaidLeaveEmpUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);

        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");

        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("paidLeaveDetailCode", param.getString("paidLeaveDetailCode"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));

		this.commonDao.select("LGVPAY00031.createPaidLeaveEmpUpload",inputData);

		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}

    /**
     * Desc : 등록 기간을 근태 계획/실적에 PL + 상세코드로 반영
     * @Method Name : saveCalculateAttendancePL
     * @param  param
     * @throws Exception
     */
    @Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveCalculateAttendancePL(LGCOMData param) {
        LOGGER.debug("param = " + param);

        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");

        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("paidLeaveDetailCode", param.getString("paidLeaveDetailCode"));

        int planCnt   = this.commonDao.update("LGVPAY00031.saveCalculateAttendancePLPlan", inputData);
        int actualCnt = this.commonDao.update("LGVPAY00031.saveCalculateAttendancePLActual", inputData);

        LGCOMData result = new LGCOMData();
        result.set("planCnt", planCnt);
        result.set("actualCnt", actualCnt);
        return result;
	}

    /**
     * Desc : 월 + PL 코드의 등록자 전체 삭제
     * @Method Name : deleteAllPaidLeaveInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllPaidLeaveInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);

        LGCOMData inputData = new LGCOMData();
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("paidLeaveDetailCode", param.getString("paidLeaveDetailCode"));

		this.commonDao.delete("LGVPAY00031.deleteAllPaidLeaveInMonth",inputData);
	}

    /**
	 * Desc : 행추가된 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployeeInfo
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveEmployeeInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return (LGCOMData) this.commonDao.select("LGVPAY00031.retrieveEmployeeInfo",param);
	}
}
