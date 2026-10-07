/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0012Service.java
 * @Desc    : Payment Master by Employee-Dependant Info
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
package com.lgd.lgvhr.lgvpay.lgvpayp0012.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpayp0012.service.LGVPAYP0012Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0012.service.serviceImpl.LGVPAYP0012ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 21.
 * @Version
 */
@Service("LGVPAYP0012Service")
public class LGVPAYP0012ServiceImpl implements LGVPAYP0012Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0012ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /**
     * Desc : Dependant Info를 조회한다.
     * @Method Name : retrieveDependantList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveDependantList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0012.retrieveDependantList", param);
    }
}
