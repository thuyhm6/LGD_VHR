package com.lgd.lgvhr.lgvpay.lgvpay00030.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00030.service.LGVPAY00030Service;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00030ServiceImpl.java
 * @Desc    : Retrieve Other Income Employee List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.10.10     HMT_20251010  Retrieve Other Income Employee List    
 *------------------------------------------------------------------------------
 */
@Service(value="LGVPAY00030Service")
public class LGVPAY00030ServiceImpl implements LGVPAY00030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Retrieve Other Income Set Emp List.
	 * @Method Name : retrieveOtherIncomeSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOtherIncomeEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00030.retrieveOtherIncomeEmpList",param);
	}

	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveOtherIncomeSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveOtherIncomeEmp(LGCOMData param) {
		LOGGER.debug("saveOtherIncomeSetEmp param = " + param);
		
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
			this.commonDao.delete("LGVPAY00030.deleteOtherIncomeEmp",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.update("LGVPAY00030.updateOtherIncomeEmp",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			//기등록된 사용자 체크
			iItem.put("payMonth", parameter.getString("payMonth"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00030.insertOtherIncomeEmp",iItem);
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
        int resultCnt = this.commonDao.insert("LGVPAY00030.createExcelDownloadData",param);
        
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
     * @Method Name : createOtherIncomeEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createOtherIncomeEmpUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        
		this.commonDao.select("LGVPAY00030.createOtherIncomeEmpUpload",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Delete All OtherIncome In Month.
     * @Method Name : deleteAllOtherIncomeInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllOtherIncomeInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        
		this.commonDao.update("LGVPAY00030.deleteAllOtherIncomeInMonth",inputData);
		
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
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00030.retrieveEmployeeInfo",param);
		
		return resultData;
	}
}
