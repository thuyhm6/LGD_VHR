package com.lgd.lgvhr.lgvatt.lgvatt00010.service.serviceImpl;

import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00010.service.LGVATT00010Service;

@Service(value="LGVATT00010Service")
public class LGVATT00010ServiceImpl implements LGVATT00010Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00010ServiceImpl.class);
	
	/*@Resource(name="tnxManager")
    protected CompositeDataSourceTransactionManager tnxManager;*/

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : retrieveIdCardHis
	 * @Method Name : retrieveIdCardHis
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveIdCardHis(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00010.retrieveIdCardHis",param);
	}
	
	/**
	 * Desc : excelDownData
	 * @Method Name : excelDownData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
    public LGCOMData excelDownData(LGCOMData param) {
        
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVATT00010.excelDownData",param);
        
        LGCOMData result = new LGCOMData();
        result.set("resultCnt", resultCnt);
        result.set("sessionId", sessionId);
        return result;
        
    }
}
