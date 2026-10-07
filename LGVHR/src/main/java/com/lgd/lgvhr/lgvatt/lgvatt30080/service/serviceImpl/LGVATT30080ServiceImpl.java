/**
 * 
 */
package com.lgd.lgvhr.lgvatt.lgvatt30080.service.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30080.service.LGVATT30080Service;

/**
 * SPECIAL OVERTIME 최종 confirm
 * 
 * @author LHJ
 *
 */
@Service("LGVATT30080Service")
public class LGVATT30080ServiceImpl implements LGVATT30080Service {

	static final LGCOMLogger logger = LGCOMLoggerFactory.getLogger(LGVATT30080ServiceImpl.class);
	
	@Autowired
	private CommonDao commonDao;
	
	/**
	 * Special OT 요청 리스트 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	@Override
	public List<LGCOMData> retrieveSpecialOtRequestList(LGCOMData param) throws LGCOMException {
		
		logger.debug("retrieveSpecialOtRequestList parameter : {} ", param);
		param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		param.set(LGCOMConstants.HTTP_SESSION_KEY, (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY));
		
		return commonDao.selectList("LGVATT30080.retrieveSpecialOtRequestList", param);
	}
	
	/**
	 * Special OT 최종 confirm
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void updateSpecialOTByHR(LGCOMData param) {
		logger.debug("updateSpecialOTByHR parameter : {} ", param);
		
		List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
		
		logger.debug("modifyList = " + modifyList);
    	
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
        	item.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
        	item.set("confirmType", param.get("actionType"));
        	item.set("applicationUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
    		
    		this.commonDao.update("LGVATT30080.updateSpecialOTByHR", item);
        }
	}

}
