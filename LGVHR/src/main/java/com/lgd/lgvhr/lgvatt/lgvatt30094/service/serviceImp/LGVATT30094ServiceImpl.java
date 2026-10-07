package com.lgd.lgvhr.lgvatt.lgvatt30094.service.serviceImp;

/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50040Service.java
 * @Desc    : Setup OT level
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2021. 03. 17.    HMS    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */

import java.util.List;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt30094.service.LGVATT30094Service;;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50040.controller.LGVATT50040Controller.java
 * </PRE>
 *
 * @Author    HMS
 * @Date      2021. 03. 17. 11:06 AM
 * @Version
 */
@Service(value="LGVATT30094Service")
public class LGVATT30094ServiceImpl implements LGVATT30094Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT30094ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveOtLevel
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveShiftChangeHistory(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT30094.retrieveShiftChangeHistory",param);
	}
}
