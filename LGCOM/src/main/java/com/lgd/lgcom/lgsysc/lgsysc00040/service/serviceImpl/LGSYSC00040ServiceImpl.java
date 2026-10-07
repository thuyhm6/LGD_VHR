/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00040ServiceImpl.java
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
package com.lgd.lgcom.lgsysc.lgsysc00040.service.serviceImpl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00040.service.LGSYSC00040Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00040.service.serviceImpl.LGSYSC00040ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 25. 오전 10:30:01
 * @Version
 */
@Service("LGSYSC00040Service")
public class LGSYSC00040ServiceImpl implements LGSYSC00040Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00040ServiceImpl.class);

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
		return this.commonDao.selectList("LGSYSC00040.retrieveUserPopupList",param);
	}

	/**
	 * Desc : Popup에서 기선택된 사용자 목록을 조회한다.
	 * @Method Name : retrieveUserPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePreSelectedUserPopupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// User ID 값을 받아서 다시 처리한다.
		String keyValue = param.getString("keyValue");
		if(!NullUtil.isNone(keyValue)) {
			List<String> keyValues = new ArrayList<String>();
			String[] keyValueAddr = keyValue.split(",");
			for(int i=0; i < keyValueAddr.length; i++) {
				keyValues.add(keyValueAddr[i]);
			}
			param.set("keyValues",keyValues);
		}
		return this.commonDao.selectList("LGSYSC00040.retrievePreSelectedUserPopupList",param);
	}
}
