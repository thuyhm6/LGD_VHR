
/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT60030ServiceImpl.java
 * @Desc    : 근태 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt60030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt60030.service.LGVATT60030Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt60030.service.serviceImpl.LGVATT60030ServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 10. 18. 오후 3:48:12
 * @Version
 */
@Service("LGVATT60030Service")
public class LGVATT60030ServiceImpl implements LGVATT60030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT60030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;


	/**
	 * Desc : 월간 근태 리포트 추출
	 * @Method Name : createExcelMonthReport
	 * @param  param
	 * @return LGCOMData
	 */
	@Override
	public List<LGCOMData> retrieveWorkingLateList(LGCOMData param) {
        return this.commonDao.selectList("LGVATT60030.retrieveWorkingLateList", param);
	}
	
}