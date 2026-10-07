/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT00100Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    H.W.JANG    PIC 조회 및 등록 록직
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt00100.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00100.service.LGVATT00100Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt00100.controller.LGVATT00100Controller.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 21. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT00100Service")
public class LGVATT00100ServiceImpl implements LGVATT00100Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00100ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 근태담당자 목록을 조회한다.
	 * @Method Name : retrieveOrgContactList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveOrgContactList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00100.retrieveOrgContactList",param);
	}
	
	/**
	 * Desc : 근태담당자로 지정 가능한 인원을 조회한다.
	 * @Method Name : retrieveOrgContactSelectList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveOrgContactCheck(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT00100.retrieveOrgContactCheck",param);
	}
	
	
	/**
     * Desc : 추가되고 삭제된 인원에 대해 저장한다.
     * @Method Name : saveContactList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })    
    public void saveContactList(LGCOMData param){
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData iItem = cList.get(a);
            	iItem.set("sessionUserId" ,((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
            	iItem.set("subsidiaryCode",((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
            	
            	LGCOMData chkPic = this.commonDao.select("LGVATT00100.retrieveOrgContactCheck",iItem);
            	
            	if(chkPic.getInt("chkCnt") > 0){
            		
            		throw new LGCOMException ( messageSourceAccessor.getMessage("error.duplicateValue"));
            	
            	}else{
	        		LOGGER.debug("iItem = " + iItem);
	            	this.commonDao.update("LGVATT00100.insertContatList",iItem);	
            	}
            	
            	
            }
        }
        
        /* 삭제건 저장 */
        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
        if(dList != null && dList.size() > 0) {
            for(int a=0; a < dList.size(); a++) {
            	LGCOMData dItem = dList.get(a);
            	this.commonDao.update("LGVATT00100.deleteConatacList",dItem);
            }
        }
        
    }
    
    public void insertOrgForPic(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
		commonDao.selectList("LGVATT00100.UploadExcelFile",inputData);
	}
    
    public void deletePermission(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
		commonDao.selectList("LGVATT00100.DeleteExcelFile",inputData);
	}
}
