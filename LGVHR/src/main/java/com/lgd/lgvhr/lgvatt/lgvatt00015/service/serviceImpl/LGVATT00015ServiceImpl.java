package com.lgd.lgvhr.lgvatt.lgvatt00015.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt00015.service.LGVATT00015Service;

@Service(value="LGVATT00015Service")
public class LGVATT00015ServiceImpl implements LGVATT00015Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00015ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Retrieve Other Income Set Emp List.
	 * @Method Name : retrieveRequestOsKpiMasterList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRequestOsKpiMasterList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00015.retrieveRequestOsKpiMasterList",param);
	}

	
	/**
     * Desc : 급여대상자를 저장한다.
     * @Method Name : saveOtherIncomeSetEmp
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveRequestOsKpiMaster(LGCOMData param) {
		LOGGER.debug("saveOtherIncomeSetEmp param = " + param);
		
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			dItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.delete("LGVATT00015.deleteRequestOsKpiMaster",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			uItem.put("payMonth", parameter.getString("payMonth"));
			this.commonDao.update("LGVATT00015.updateRequestOsKpiMaster",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			//기등록된 사용자 체크
			iItem.put("payMonth", parameter.getString("payMonth"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			this.commonDao.update("LGVATT00015.insertRequestOsKpiMaster",iItem);
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
        int resultCnt = this.commonDao.insert("LGVATT00015.createExcelDownloadData",param);
        
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
     * @Method Name : createRequestOsKpiMasterUpload
     * @param  param
     * @throws Exception
     */
    public void createRequestOsKpiMasterUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("timeAndAttendanceYyyymm", param.getString("timeAndAttendanceYyyymm"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        
		this.commonDao.select("LGVATT00015.createRequestOsKpiMasterUpload",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}
}
