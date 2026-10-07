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
package com.lgd.lgcom.lgsetc.lgsetc00050.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00050.service.LGSETC00050Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 6. 03. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00050Service")
public class LGSETC00050ServiceImpl implements LGSETC00050Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00050ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Parent Code 목록을 조회한다.
	 * @Method Name : retrieveParentCodeList 
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveParentCodeList(LGCOMData param){
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00050.retrieveParentCodeList",param);
	}
}
