package com.lgd.lgvhr.lgvatt.lgvatt00011.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt00011.service.LGVATT00011Service;

@Service(value = "LGVATT00011Service")
public class LGVATT00011ServiceImpl implements LGVATT00011Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00011ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	@Override
	public List<LGCOMData> retrieveOSEmpIdCard(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00011.retrieveOSEmpIdCard", param);
	}

	@Override
	public List<LGCOMData> excelDownData(LGCOMData param) {

		int sessionId = LGCOMUtils.getRandomNumber();
		param.set("sessionId", sessionId);
		LOGGER.debug("param = " + param);
		int resultCnt = this.commonDao.insert("LGVATT00011.excelDownData", param);

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

	@Override
	@SuppressWarnings("unchecked")
	public void saveOSEmpIdCard(LGCOMData param) {
		LOGGER.debug("param = " + param);

		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");

		List<LGCOMData> insertList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);

		for (LGCOMData item : insertList) {
			item.set("applicationUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGVATT00011.mergeOSEmpIdCard", item);
		}

		for (LGCOMData item : updateList) {
			item.set("applicationUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGVATT00011.mergeOSEmpIdCard", item);
		}

	}
	
    public void createEmpIdCardUpload(LGCOMData param) {
        LOGGER.debug("param = " + param);
        
        LGCOMData inputData = new LGCOMData();
        LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
        
        inputData.set("sessionId", param.getString("sessionId"));
        inputData.set("applicationUserId", userSession.get("applicationUserId"));
		
		if(inputData.getString("errorCode") != null) {
			throw new LGCOMException( inputData.getString("errorMsg") );
		}
		commonDao.select("LGVATT00011.UploadExcelFile",inputData);

	}

	@Override
	public List<LGCOMData> retrieveVendorList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00011.retrieveVendorList", param);
	}
    
}
