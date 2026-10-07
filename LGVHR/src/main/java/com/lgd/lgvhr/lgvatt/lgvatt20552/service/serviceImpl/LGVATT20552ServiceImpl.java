package com.lgd.lgvhr.lgvatt.lgvatt20552.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt20552.service.LGVATT20552Service;

/**
 * @author HMS - HMS_20210703
 * Swap weekly holiday master
 *
 */

@Service(value="LGVATT20552Service")
public class LGVATT20552ServiceImpl implements LGVATT20552Service{
static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20552ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveSwapMaster
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveSwapMaster(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20552.retrieveSwapMaster",param);
	}
	
	/**
     * Desc : Save overtime level manage.
     * @Method Name : saveSwapMasterManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveSwapMasterManage(LGCOMData param) {
    	LOGGER.debug("saveSwapMasterManage parameter : {} ", param);
		
		List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
		
		LOGGER.debug("modifyList = " + modifyList);
    	
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
        	item.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
        	item.set("confirmType", param.get("actionType"));
        	item.set("applicationUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
			item.set("swapType", param.get("actionType"));
			item.set("confirmType", param.get("actionType"));
    		
    		this.commonDao.update("LGVATT20552.updateSwapHolidayByHR",item);
			
			this.commonDao.select("LGVATT20552.applyAttSwapWhMaster", item);
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
		
		resultData = (LGCOMData) this.commonDao.select("LGVATT20552.retrieveEmployeeInfo",param);
		
		return resultData;
	}
	
	@Override
	public LGCOMData checkLockDate(LGCOMData param) throws LGCOMException {
		// TODO Auto-generated method stub
		return this.commonDao.select("LGVATT20552.checkLockDate", param);
	}
}
