/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00100ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE          AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 11. csseo       최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00110.service.serviceImpl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00110.service.LGUTLC00110Service;

import devonframe.util.NullUtil;


/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00110.service.serviceImpl.LGUTLC00110ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date      2016. 10. 11. 오후 3:40:16
 * @Version
 */
@Service("LGUTLC00110Service")
public class LGUTLC00110ServiceImpl implements LGUTLC00110Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00110ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Master 조회
	 * @Method Name : retrieveMasterList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveKeywordLogList(LGCOMData param) {
	    // User ID 값을 받아서 다시 처리한다.
	    String userId = param.getString("userId");
	    if(!NullUtil.isNone(userId)) {
	        List<String> userIds = new ArrayList<String>();
	        String[] userIdArr = userId.split(",");
	        for(int i=0; i < userIdArr.length; i++) {
	            userIds.add(userIdArr[i]);
	        }
            param.set("userIds",userIds);
	    }
        LOGGER.debug("param = " + param);
	    return this.commonDao.selectList("LGUTLC00110.retrieveKeywordLogList",param);
	}
}
