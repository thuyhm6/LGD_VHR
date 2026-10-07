/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0009Service.java
 * @Desc    : Payroll Run Execution List
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 12.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0009.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0009.service.LGVPAYP0009Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.LGVPAYP0009.service.serviceImpl.LGVPAYP0009ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 12.
 * @Version
 */
@Service("LGVPAYP0009Service")
public class LGVPAYP0009ServiceImpl implements LGVPAYP0009Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0009ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Payroll Run Error List 를 조회한다.
     * @Method Name : retrieveRunErrorList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveRunErrorList(LGCOMData param) {
    	LOGGER.debug(this.getClass().getName() + ".retrieveRunErrorList().param=>" + param);
    	return this.commonDao.selectList("LGVPAYP0009.retrieveRunErrorList", param);
    }
}
