/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00080Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00080.service.serviceImpl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00080.service.LGSYSC00080Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00080.service.serviceImpl.LGSYSC00080ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 11:22:58
 * @Version
 */
@Service("LGSYSC00080Service")
public class LGSYSC00080ServiceImpl implements LGSYSC00080Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00080ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 사용자가 등록한 화면의 Condition 목록을 조회한다.
	 * @Method Name : retrieveConditionList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveConditionList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00080.retrieveConditionList",param);
	}

	/**
	 * Desc : 사용자가 등록한 화면의 Condition 목록을 삭제한다.
	 * @Method Name : deleteConditionList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	public void deleteConditionList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 삭제건 */
		List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
			item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
			this.commonDao.update("LGSYSC00080.deleteConditionList",item);
		}
	}
}
