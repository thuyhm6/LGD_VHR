/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00029ServiceImpl.java
 * @Desc    : Calculate Severance Allowance
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2025.10.10     HMT_20251010  Calculate Severance Allowance                
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00029.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00029.service.LGVPAY00029Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00029.service.serviceImpl.LGVPAY00029ServiceImpl.java
 * </PRE>
 *
 * @Author    thuyhm
 * @Date      2025. 10. 01.
 * @Version
 */
@Service("LGVPAY00029Service")
public class LGVPAY00029ServiceImpl implements LGVPAY00029Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00029ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    /**
	 * Desc : 급여대상자를 조회한다.
	 * @Method Name : retrieveOtherIncomeSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveSeveranceAllowanceList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00029.retrieveSeveranceAllowanceList",param);
	}
	/**
	 * Desc : 기등록된 급여대상 SET을 조회한다.
	 * @Method Name : retrieveRegSeveranceAllowanceChk
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveRegSeveranceAllowanceChk(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00029.retrieveRegSeveranceAllowanceChk",param);
		
		return resultData;
	}
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveOtherIncomeSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveSeveranceAllowance(LGCOMData param) {
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
			dItem.put("calculationSetId", parameter.getString("calculationSetId"));
			this.commonDao.delete("LGVPAY00029.deleteSeveranceAllowance",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("payMonth", parameter.getString("payMonth"));
			uItem.put("calculationSetId", parameter.getString("calculationSetId"));
			this.commonDao.update("LGVPAY00029.updateSeveranceAllowance",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			//기등록된 사용자 체크
			resultData = (LGCOMData) this.commonDao.select("LGVPAY00029.retrieveRegSeveranceAllowanceChk",iItem);
			resultCnt = Integer.parseInt(resultData.getString("cnt"));
			
			if(resultCnt > 0) {
				throw new LGCOMException(messageSourceAccessor.getMessage("error.haveEmpNo"));
			}
			iItem.put("payMonth", parameter.getString("payMonth"));
			iItem.put("calculationSetId", parameter.getString("calculationSetId"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00029.insertSeveranceAllowance",iItem);
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
        int resultCnt = this.commonDao.insert("LGVPAY00029.createExcelDownloadData",param);
        
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
     * @Method Name : createSeveranceAllowanceUpload
     * @param  param
     * @throws Exception
     */
    public void createSeveranceAllowanceUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        
		this.commonDao.select("LGVPAY00029.createSeveranceAllowanceUpload",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Delete All Severance Allowance In Month.
     * @Method Name : deleteAllSeveranceAllowanceInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllSeveranceAllowanceInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        
		this.commonDao.update("LGVPAY00029.deleteAllSeveranceAllowanceInMonth",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Apply All Severance Allowance In Month.
     * @Method Name : applyAllSeveranceAllowanceInMonth
     * @param  param
     * @throws Exception
     */
    public void applyAllSeveranceAllowanceInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        
		this.commonDao.update("LGVPAY00029.applyAllSeveranceAllowanceInMonth",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Calculate All Severance Allowance In Month.
     * @Method Name : saveCalculateSeveranceAllowance
     * @param  param
     * @throws Exception
     */
    public void saveCalculateSeveranceAllowance(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        
        this.commonDao.select("LGVPAY00029.saveCalculateSeveranceAllowance", inputData);
		
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
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00029.retrieveEmployeeInfo",param);
		
		return resultData;
	}
}
