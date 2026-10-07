package com.lgd.lgvhr.lgvatt.lgvatt20550.service.seviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt20550.service.LGVATT20550Service;

/**
 * @author HMS - HMS_20210703
 * Request for swap weekly holiday
 *
 */

@Service("LGVATT20550Service")
public class LGVATT20550ServiceImpl implements LGVATT20550Service{
static final LGCOMLogger logger = LGCOMLoggerFactory.getLogger(LGVATT20550ServiceImpl.class);
	
	@Autowired
	private CommonDao commonDao;
	
	@Override
	public List<LGCOMData> retrieveSwapRequestList(LGCOMData param) throws LGCOMException {
		
		logger.debug("retrieveSpecialOtRequestList parameter : {} ", param);
		param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		param.set(LGCOMConstants.HTTP_SESSION_KEY, (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY));
		
		return commonDao.selectList("LGVATT20550.retrieveSwapRequestList", param);
	}
}
