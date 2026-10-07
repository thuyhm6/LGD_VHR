/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00004ServiceImpl.java
 * @Desc    : 급여항목별 개인조회, 수정
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00004.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00004.service.LGVPAY00004Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00004.controller.LGVPAY00004Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAY00004Service")
public class LGVPAY00004ServiceImpl implements LGVPAY00004Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00004ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 개인별 급여항목을 조회한다.
	 * @Method Name : retrieveCalSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveIndividualPayItemList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00004.retrieveIndividualPayItemList",param);
	}
	
	/**
     * Desc : 개인별 급여항목을 저장한다.
     * @Method Name : saveIndividualPayItem
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveIndividualPayItem(LGCOMData param) {
		LOGGER.debug("saveIndividualPayItem param = " + param);
		
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		String[] applyEndDateSplit = null;
		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			this.commonDao.delete("LGVPAY00004.deleteIndividualPayItem",dItem);
		}
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			
			if(uItem.getString("applyEndDate").length() > 0 && uItem.getString("applyEndDate") != null) {
				applyEndDateSplit = uItem.getString("applyEndDate").split("/");
				uItem.set("applyEndDate", applyEndDateSplit[2]+applyEndDateSplit[1]+applyEndDateSplit[0]);
			}
			
			this.commonDao.update("LGVPAY00004.updateIndividualPayItem",uItem);
		}
	}
    /**
     * Desc : 개인별 급여항목을 일괄삭제한다.
     * @Method Name : deleteIndividualPayItem
     * @param  param
     * @throws Exception
     */
	public void saveAllIndividualPayItem(LGCOMData param) {
    	LGCOMData resultDate = new LGCOMData();
    	
    	resultDate = (LGCOMData) this.commonDao.select("LGVPAY00004.retrieveStartEndDate",param);
    	
    	if(!"".equals(resultDate.getString("startYyyymmdd")) || !"".equals(resultDate.getString("endYyyymmdd"))) {
    		param.set("startYyyymmdd", resultDate.getString("startYyyymmdd"));
    		param.set("endYyyymmdd", resultDate.getString("endYyyymmdd"));
    	}
    	this.commonDao.delete("LGVPAY00004.deleteAllIndividualPayItem",param);
    }
	/**
	 * Desc : 엑셀 Head 다운로드 count
	 * @Method Name : retrieveCSVDownloadDataCount
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveDownloadCount(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		LGCOMData cntData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00004.retrieveDownloadCount",param);
		
		if(resultData == null) {
			cntData.set("cnt", 0);
		}else{
			cntData.set("cnt", resultData.get("cnt"));
		}
		
		return cntData;
	}
	/**
     * Desc : 개인별 급여항목 리스트 엑셀 다운로드
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelDownloadHeadData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
		
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVPAY00004.createExcelDownloadHeadData",param);
        
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
     * Desc : 개인별 급여항목 리스트 엑셀 다운로드
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);

        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVPAY00004.createExcelDownloadData",param);
        
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
     * @Method Name : createIndividualPayItemUpload
     * @param  param
     * @throws Exception
     */
    public void createIndividualPayItemUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        LGCOMData resultDate = new LGCOMData();
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
        resultDate = (LGCOMData) this.commonDao.select("LGVPAY00004.retrievePayrollCalculationPeriodId",param);
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("payrollItemId", param.getString("payrollItemId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payrollCalculationPeriodId", resultDate.getString("payrollCalculationPeriodId"));
        
		this.commonDao.select("LGVPAY00004.createIndividualPayItemUpload",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
}
