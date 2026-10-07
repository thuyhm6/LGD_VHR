/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00020ServiceImpl.java
 * @Desc    : User Defined Table Value Summary
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 02. 02.    limsujin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00020.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00020.service.LGVPAY00020Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00020.service.serviceImpl.LGVPAY00020ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 02. 02. 
 * @Version
 */
@Service("LGVPAY00020Service")
public class LGVPAY00020ServiceImpl implements LGVPAY00020Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00020ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

    /**
     * Desc : User Defined Table Value Summary 목록을 조회한다. 
     * @Method Name : retrieveUserDefineTableValueSummaryList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineTableValueSummaryList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00020.retrieveUserDefineTableValueSummaryList", param);
    }
}
