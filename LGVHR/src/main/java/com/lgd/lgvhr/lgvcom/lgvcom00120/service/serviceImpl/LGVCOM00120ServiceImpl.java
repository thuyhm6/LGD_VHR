/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGVCOM00110ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2023 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0  2023. 3. 2.   Kim Biho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcom00120.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcom00120.service.LGVCOM00120Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00120.service.serviceImpl.LGVCOM00120ServiceImpl.java
 * </PRE>
 *
 * @Author    Kim Biho
 * @Date      2023. 3. 2. 오전 8:44:01
 * @Version   First Version
 */
@Service("LGVCOM00120Service")
public class LGVCOM00120ServiceImpl implements LGVCOM00120Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOM00120ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Popup에서 주어진 조건에 따라 부서 섹션 목록을 조회한다.
	 * @Method Name : basicPartPopupList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> basicPartPopupList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		param.put("subsidiary_code",projectSession.getString("subsidiaryCode"));
		return this.commonDao.selectList("LGVCOM00120.basicPartPopupList",param);
	}
}
