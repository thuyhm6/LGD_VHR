/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00130ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 24.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00130.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00130.service.LGSYSC00130Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00130.service.serviceImpl.LGSYSC00130ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 24. 오후 5:04:58
 * @Version
 */
@Service("LGSYSC00130Service")
public class LGSYSC00130ServiceImpl implements LGSYSC00130Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00130ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Role 목록을 조회한다.
	 * @Method Name : retrieveRolePopupList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRolePopupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00130.retrieveRolePopupList",param);
	}
}
