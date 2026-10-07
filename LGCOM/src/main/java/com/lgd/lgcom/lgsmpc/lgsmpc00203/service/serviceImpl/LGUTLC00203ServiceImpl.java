/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSMPC00203ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 07. 14.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsmpc.lgsmpc00203.service.serviceImpl;

import java.sql.SQLException;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsmpc.lgsmpc00203.service.LGUTLC00203Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgsmpc00200.service.serviceImpl.LGSMPC00200ServiceImpl.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 07. 14. 오후 1:39:58
 * @Version
 */
@Service("LGSMPC00203Service")
public class LGUTLC00203ServiceImpl implements LGUTLC00203Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00203ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /** 
     * 
     * @param param
     * @return
     * @throws SQLException
     * @see com.lgd.lgcom.lgsmpc.lgsmpc00203.service.LGUTLC00203Service#createTempTable(java.lang.Object)
     */
    public LGCOMData createTempTable(LGCOMData param) {
        
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGUTLC00203.createTempTable",param);
        
        LGCOMData result = new LGCOMData();
        result.set("resultCnt", resultCnt);
        result.set("sessionId", sessionId);
        return result;
        
    }
}
