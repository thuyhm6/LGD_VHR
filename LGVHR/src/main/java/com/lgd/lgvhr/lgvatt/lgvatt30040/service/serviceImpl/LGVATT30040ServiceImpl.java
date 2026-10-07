package com.lgd.lgvhr.lgvatt.lgvatt30040.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30040.service.LGVATT30040Service;

@Service(value="LGVATT30040Service")
public class LGVATT30040ServiceImpl implements LGVATT30040Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30040ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : retrieveOtOverYearLimitList
	 * @Method Name : retrieveOtOverYearLimitList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveOtOverYearLimitList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT30040.retrieveOtOverYearLimitList", param);
	}
	
	/**
     * Desc : HMT_20221108 Add Download Excel Function 
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVATT30040.createExcelDownloadData",param);
        
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

}
