/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00203ServiceImpl.java
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
package com.lgd.lgcom.lgsmpc.lgsmpc00204.service.serviceImpl;

import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsmpc.lgsmpc00204.service.LGSMPC00204Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsmpc.lgsmpc00200.service.serviceImpl.LGSMPC00200ServiceImpl.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 07. 14. 오후 1:39:58
 * @Version
 */
@Service("LGSMPC00204Service")
public class LGSMPC00204ServiceImpl implements LGSMPC00204Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSMPC00204ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    /** 
     * 
     * @param param
     * @return
     * @throws SQLException
     * @see
     */
    public List<LGCOMData> retrieveCalendarEventList(LGCOMData param) {
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGUTLC00204.retrieveCalendarEventList", param);

    }

    @Override
    public void insertCalendarEventList(LGCOMData param){
       
        LOGGER.debug("param = " + param);
        List<LGCOMData> list = (List<LGCOMData>)param.get("events");
        
        for( LGCOMData item : LGCOMUtils.emptyIfNull(list) ) {
            item.set("USER_SESSION", param.get("USER_SESSION")); 
            this.commonDao.insert("LGUTLC00204.insertCalendarEventList", item);
        }
    }
    
    public void deleteCalendarEventList(LGCOMData param) {
        LOGGER.debug("param = " + param);
        this.commonDao.delete("LGUTLC00204.deleteCalendarEventList", param);
    }      
    
}
