package com.lgd.lgvhr.lgvatt.lgvatt00030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt00030.service.LGVATT00030Service;

/**
 *  HMT_20221108 Add Employee Shift Group Info Interface
 * @Author    Ha Minh Thuy
 * @Date      
 * @Version
 */

@Service(value="LGVATT00030Service")
public class LGVATT00030ServiceImpl implements LGVATT00030Service{
	
protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT00030ServiceImpl.class);
	
	/*@Resource(name="tnxManager")
    protected CompositeDataSourceTransactionManager tnxManager;*/

	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : retrieveMonthlyAttList
	 * @Method Name : retrieveMonthlyAttList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveMonthlyEmpGroupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT00030.retrieveMonthlyEmpGroupList", param);
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
        int resultCnt = this.commonDao.insert("LGVATT00030.createExcelDownloadData",param);
        
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
