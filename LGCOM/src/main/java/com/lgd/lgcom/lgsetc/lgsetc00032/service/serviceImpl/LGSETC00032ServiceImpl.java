/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00010Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 03.    김치민    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00032.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00032.service.LGSETC00032Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 6. 03. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00032Service")
public class LGSETC00032ServiceImpl implements LGSETC00032Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00032ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
     * Desc : inventory organization id 목록을 조회한다.
     * @Method Name : retrieveInvOrgIdList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
	public List<LGCOMData> retrieveInvOrgIdList(LGCOMData param){
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00032.retrieveInvOrgIdList",param);
	}
	
	   /**
     * Desc : Company Name을 조회한다.
     * @Method Name : retrieveCompanyName
     * @param  param
     * @return String
     * @throws Exception
     */
    public LGCOMData retrieveCompanyName(LGCOMData param){
        LOGGER.debug("param = " + param);
        return this.commonDao.select("LGSETC00032.retrieveCompanyName",param);
    }
}
