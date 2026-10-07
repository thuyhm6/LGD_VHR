/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00005ServiceImpl.java
 * @Desc    : 급여대상자 관리
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
package com.lgd.lgvhr.lgvpay.lgvpay00005.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00005.service.LGVPAY00005Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00005.controller.LGVPAY00005Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAY00005Service")
public class LGVPAY00005ServiceImpl implements LGVPAY00005Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00005ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 급여대상자를 조회한다.
	 * @Method Name : retrieveCalSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalSetEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00005.retrieveCalSetEmpList",param);
	}
	/**
	 * Desc : 기등록된 급여대상 SET을 조회한다.
	 * @Method Name : retrieveRegCalEmpChk
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveRegCalEmpChk(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00005.retrieveRegCalEmpChk",param);
		
		return resultData;
	}
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveCalSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveCalSetEmp(LGCOMData param) {
		LOGGER.debug("saveCalSetEmp param = " + param);
		
		LGCOMData resultData = new LGCOMData();
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		int resultCnt = 0;
		
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			
			dItem.put("calculationSetId", parameter.getString("calculationSetId"));
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.delete("LGVPAY00005.deleteCalEmp",dItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("calculationSetId", parameter.getString("calculationSetId"));
			//기등록된 사용자 체크
			resultData = (LGCOMData) this.commonDao.select("LGVPAY00005.retrieveRegCalEmpChk",iItem);
			resultCnt = Integer.parseInt(resultData.getString("cnt"));
			
			if(resultCnt > 0) {
				throw new LGCOMException(messageSourceAccessor.getMessage("error.haveEmpNo"));
			}
			
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00005.insertCalEmp",iItem);
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
        int resultCnt = this.commonDao.insert("LGVPAY00005.createExcelDownloadData",param);
        
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
     * @Method Name : createCalEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createCalEmpUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("calculationSetId", param.getString("calculationSetId"));
        
		this.commonDao.select("LGVPAY00005.createCalEmpUpload",inputData);
		
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
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00005.retrieveEmployeeInfo",param);
		
		return resultData;
	}
}
