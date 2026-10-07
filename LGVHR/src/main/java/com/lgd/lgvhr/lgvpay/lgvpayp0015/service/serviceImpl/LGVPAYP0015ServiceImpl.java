/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0015Service.java
 * @Desc    : Payment Master by Employee-Assignment History
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 21.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgvhr.lgvpay.lgvpayp0015.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0015.service.LGVPAYP0015Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0015.service.serviceImpl.LGVPAYP0015ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 21.
 * @Version
 */
@Service("LGVPAYP0015Service")
public class LGVPAYP0015ServiceImpl implements LGVPAYP0015Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0015ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Contract Info를 조회한다.
     * @Method Name : retrieveAssignmentHistoryList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveAssignmentHistoryList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0015.retrieveAssignmentHistoryList", param);
    }
}
