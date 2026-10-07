package com.lgd.lgvhr.lgvpay.lgvpay00031.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

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
 * @Desc    : Retrieve Paid Leave Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.12.01     HMT_20251201  Retrieve Paid Leave Employee List    
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
	 * Desc : Retrieve Paid Leave Set Emp List.
	 * @Method Name : retrievePaidLeaveSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaidLeaveEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00031.retrievePaidLeaveEmpList",param);
	}

	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : savePaidLeaveSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void savePaidLeaveEmp(LGCOMData param) {
		LOGGER.debug("savePaidLeaveSetEmp param = " + param);
		
		LGCOMData resultData = new LGCOMData();
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		int resultCnt = 0;
		
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			dItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.delete("LGVPAY00031.deletePaidLeaveEmp",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.update("LGVPAY00031.updatePaidLeaveEmp",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			//기등록된 사용자 체크
			iItem.put("payMonth", parameter.getString("payMonth"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00031.insertPaidLeaveEmp",iItem);
		}
	}
    
    /**
     * Desc : 급여대상자 리스트 엑셀 다운로드
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
     * Desc : 엑셀업로드
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
     * Desc : Calculate Attendance Paid Leave.
     * @Method Name : saveCalculateAttendancePL
     * @param  param
     * @throws Exception
     */
    public void saveCalculateAttendancePL(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("paidLeaveDetailCode", param.getString("paidLeaveDetailCode"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        
        this.commonDao.update("LGVPAY00031.saveCalculateAttendancePLPlan", inputData);
        this.commonDao.update("LGVPAY00031.saveCalculateAttendancePLActual", inputData);
        
        this.commonDao.update("LGVPAY00031.saveCalculatePLDetail", inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Delete All PaidLeave In Month.
     * @Method Name : deleteAllPaidLeaveInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllPaidLeaveInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        
		this.commonDao.update("LGVPAY00031.deleteAllPaidLeaveInMonth",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    /**
	 * Desc : 행추가된 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployeeInfo
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveEmployeeInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00031.retrieveEmployeeInfo",param);
		
		return resultData;
	}
}
