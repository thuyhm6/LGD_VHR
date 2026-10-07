package com.lgd.lgvhr.lgvpay.lgvpay00025.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00025.service.LGVPAY00025Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00025.service.serviceImpl.LGVPAY00025ServiceImpl.java
 * </PRE>
 *
 * @Author    HaMinhThuy
 * @Date      2022. 06. 01. 15:00:32
 * @Version
 */
@Service(value="LGVPAY00025Service")
public class LGVPAY00025ServiceImpl implements LGVPAY00025Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00025ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 급여대상자를 조회한다.
	 * @Method Name : retrieveEmailSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveEmailEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00025.retrieveEmailEmpList",param);
	}
	/**
	 * Desc : 기등록된 급여대상 SET을 조회한다.
	 * @Method Name : retrieveRegEmailEmpChk
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveRegEmailEmpChk(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00025.retrieveRegEmailEmpChk",param);
		
		return resultData;
	}
	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveEmailSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveEmailEmp(LGCOMData param) {
		LOGGER.debug("saveEmailSetEmp param = " + param);
		
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
			this.commonDao.delete("LGVPAY00025.deleteEmailEmp",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.update("LGVPAY00025.updateEmailEmp",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			//기등록된 사용자 체크
			resultData = (LGCOMData) this.commonDao.select("LGVPAY00025.retrieveRegEmailEmpChk",iItem);
			resultCnt = Integer.parseInt(resultData.getString("cnt"));
			
			if(resultCnt > 0) {
				throw new LGCOMException(messageSourceAccessor.getMessage("error.haveEmpNo"));
			}
			iItem.put("payMonth", parameter.getString("payMonth"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVPAY00025.insertEmailEmp",iItem);
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
        int resultCnt = this.commonDao.insert("LGVPAY00025.createExcelDownloadData",param);
        
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
     * @Method Name : createEmailEmpUpload
     * @param  param
     * @throws Exception
     */
    public void createEmailEmpUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("payMonth", param.getString("payMonth"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        
		this.commonDao.select("LGVPAY00025.createEmailEmpUpload",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : 엑셀업로드
     * @Method Name : createEmailEmpPrevious
     * @param  param
     * @throws Exception
     */
    public void createEmailEmpPrevious(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        
		this.commonDao.update("LGVPAY00025.createEmailEmpPrevious",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
    
    /**
     * Desc : Delete All Email In Month.
     * @Method Name : deleteAllEmailInMonth
     * @param  param
     * @throws Exception
     */
    public void deleteAllEmailInMonth(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        inputData.set("payMonth", param.getString("payMonth"));
        
		this.commonDao.update("LGVPAY00025.deleteAllEmailInMonth",inputData);
		
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
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00025.retrieveEmployeeInfo",param);
		
		return resultData;
	}

}
