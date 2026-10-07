/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : ProjectSessionServiceImpl.java
 * @Desc    : 프로젝트에서 사용할 세션정보 생성하기 위해 데이터 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.common.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.ProjectSessionService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgvhr.common.service.serviceImpl.ProjectSessionServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date      2017. 10. 18. 오후 4:10:00
 * @Version
 */
@Service("projectSessionService")
public class ProjectSessionServiceImpl implements ProjectSessionService {
    static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(ProjectSessionServiceImpl.class);

    @Resource(name="commonDao")
    CommonDao commonDao;
    
	@Override
	public LGCOMData getProjectUserInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("Session.retrieveProjectSessionData", param);
	}
}
