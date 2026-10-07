/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGVCOM00100ServiceImpl.java
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
package com.lgd.lgvhr.lgvcom.lgvcom00100.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcom00100.service.LGVCOM00100Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.LGVCOM00100.service.serviceImpl.LGVCOM00100ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 10:30:01
 * @Version
 */
@Service("LGVCOM00100Service")
public class LGVCOM00100ServiceImpl implements LGVCOM00100Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOM00100ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Popup에서 주어진 조건에 따라 사용자 목록을 조회한다.
	 * @Method Name : retrieveUserPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserPopupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVCOM00100.retrieveUserPopupList",param);
	}
}
