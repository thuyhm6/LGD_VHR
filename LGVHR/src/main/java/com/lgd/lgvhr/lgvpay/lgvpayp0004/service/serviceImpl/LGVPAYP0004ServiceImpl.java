/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0004Service.java
 * @Desc    : Formula List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 04.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0004.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0004.service.LGVPAYP0004Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0004.service.serviceImpl.LGVPAYP0004ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 04.
 * @Version
 */
@Service("LGVPAYP0004Service")
public class LGVPAYP0004ServiceImpl implements LGVPAYP0004Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0004ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Execution List 를 조회한다.
     * @Method Name : retrieveFormulaList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveFormulaList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0004.retrieveFormulaList", param);
    }
}
