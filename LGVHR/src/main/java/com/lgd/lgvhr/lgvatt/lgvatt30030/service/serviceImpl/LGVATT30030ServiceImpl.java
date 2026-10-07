package com.lgd.lgvhr.lgvatt.lgvatt30030.service.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30030.service.LGVATT30030Service;

@Service("LGVATT30030Service")
public class LGVATT30030ServiceImpl implements LGVATT30030Service{

static final LGCOMLogger logger = LGCOMLoggerFactory.getLogger(LGVATT30030ServiceImpl.class);
	
	@Autowired
	private CommonDao commonDao;
	
	@Override
	public List<LGCOMData> retrieveOtLevelRequestList(LGCOMData param) throws LGCOMException {
		
		logger.debug("retrieveSpecialOtRequestList parameter : {} ", param);
		param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		param.set(LGCOMConstants.HTTP_SESSION_KEY, (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY));
		
		return commonDao.selectList("LGVATT30030.retrieveOtLevelRequestList", param);
	}
}
