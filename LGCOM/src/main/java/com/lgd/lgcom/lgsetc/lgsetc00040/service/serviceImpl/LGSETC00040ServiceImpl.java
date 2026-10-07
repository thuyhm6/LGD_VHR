/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00010Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 03.    김치민    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00040.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00040.service.LGSETC00040Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 6. 03. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00040Service")
public class LGSETC00040ServiceImpl implements LGSETC00040Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00040ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 팝업의 Code Type 목록을 조회한다.
	 * @Method Name : retrieveCodeTypePopupList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeTypePopupList(LGCOMData param){
        param.set("USER_SESSION", param.get("USER_SESSION"));
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00040.retrieveCodeTypePopupList",param);
	}
}
