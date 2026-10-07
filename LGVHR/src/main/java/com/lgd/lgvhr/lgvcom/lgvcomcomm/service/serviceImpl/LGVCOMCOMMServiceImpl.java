/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGVCOMCOMMServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE            AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 11. 29.    LHJ    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcomcomm.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcomcomm.service.LGVCOMCOMMService;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcomcomm.service.serviceImpl.LGVCOMCOMMServiceImpl.java
 * </PRE>
 *
 * @Author    LHJ
 * @Date      2017. 11. 29.
 * @Version
 */
@Service("LGVCOMCOMMService")
public class LGVCOMCOMMServiceImpl implements LGVCOMCOMMService {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOMCOMMServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : retrieveTitleList
	 * @Method Name : retrieveTitleList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveTitleList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVCOMCOMM.retrieveTitleList", param);
	}
}
