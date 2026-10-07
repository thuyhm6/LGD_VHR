/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTCOMMService.java
 * @Desc    : 조직 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    H.W.JANG    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvattp0001.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattp0001.service.LGVATTP0001Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGATTP0001on.service.serviceImpl.LGATTP0001ServiceImpl.java
 * </PRE>
 *
 * @Author    JHW
 * @Date	  2017. 12. 02. 오후 3:48:12
 * @Version
 */
@Service("LGVATTP0001Service")
public class LGVATTP0001ServiceImpl implements LGVATTP0001Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTP0001ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 조직을 검색한다
	 * @Method Name : retrieveOrgList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveOrgList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATTP0001.retrieveOrgList",param);
	}

	
}
