/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20440Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20440.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt20440.service.LGVATT20440Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20440.controller.LGVATT20440Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT20440Service")
public class LGVATT20440ServiceImpl implements LGVATT20440Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20440ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : retrieveMutiplanList 목록을 조회한다.
	 * @Method Name : retrieveMutiplanList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMutiplanList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
		param.set("applicationUserId", userSession.get("applicationUserId"));
		return this.commonDao.selectList("LGVATT20440.retrieveMutiplanList",param);
	}
	
	/**
	 * Desc : 해외주재원 여부를 조회한다.
	 * @Method Name : retrieveFseYn
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveFseYn(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		
		resultData = (LGCOMData) this.commonDao.select("LGVATT20440.retrieveFseYn",param);
		
		return resultData;
	}
}
