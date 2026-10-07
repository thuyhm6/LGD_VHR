/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50050Service.java
 * @Desc    : Korean Leader Part Info
 *
 * Copyright ⓒ 2023 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2023. 02. 21.  Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50050.service.serviceImpl;

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50050.service.LGVATT50050Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50050.controller.LGVATT50050Controller.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 02. 21. 09:40 AM
 * @Version
 */
@Service(value="LGVATT50050Service")
public class LGVATT50050ServiceImpl implements LGVATT50050Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50050ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
     * Desc : Save Korean Leader Info.
     * @Method Name : saveOtLevelManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveKoreanLeaderInfo(LGCOMData param) {
		LOGGER.debug("saveKoreanLeaderInfo param = " + param);

		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		//Delete
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			dItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50050.deleteKoreanLeaderInfo",dItem);
		}
		//Update
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			uItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50050.updateKoreanLeaderInfo",uItem);
		}
		//Insert
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50050.insertKoreanLeaderInfo",iItem);
		}
	}
    
    /**
     * Desc : select Korean Leader Info.
     * @Method Name : getKoreanLeaderInfo
     * @param  param
     * @throws 
     */
	@Override
	public List<LGCOMData> getKoreanLeaderInfo(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50050.getKoreanLeaderInfo", param);
	}

	@Override
	public void uploadExcelPartLeaderInfo(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
        
		this.commonDao.select("LGVATT50050.uploadExcelPartLeaderInfo",inputData);
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
	}

}
