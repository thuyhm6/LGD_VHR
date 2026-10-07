
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT60050ServiceImpl.java
 *
 * Copyright ⓒ 2024 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2024. 02. 20.    sangnv
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt60050.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt60050.service.LGVATT60050Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60050.service.serviceImpl.LGVATT60050ServiceImpl.java
 * </PRE>
 *
 * @Author    sangnv
 * @Date	  2024. 02. 20
 * @Version
 */
@Service("LGVATT60050Service")
public class LGVATT60050ServiceImpl implements LGVATT60050Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT60050ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Override
	public List<LGCOMData> retrieveHalfdayWorkingList(LGCOMData param) {
        return this.commonDao.selectList("LGVATT60050.retrieveHalfdayWorkingList", param);
	}
	
	@SuppressWarnings("unchecked")
	@Transactional(propagation = Propagation.REQUIRED)
	public LGCOMData saveAttendance(LGCOMData param) {

		LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
		LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");

		/* 수정건 저장 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);
		for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
				item.set(LGCOMConstants.HTTP_SESSION_KEY, userSession);
				item.set("LGVHR_PROJECT_SESSION", projectSession);
				commonDao.update("LGVATT60050.updateAttendance", item);
		}
		return param;
	}
	
}