/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00407ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 5.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00407.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00407.service.LGUTLC00407Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00401.service.serviceImpl.LGUTLC00401ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date       2016. 10. 5. 오후 1:39:20
 * @Version 
 */
@Service("LGUTLC00407Service")
public class LGUTLC00407ServiceImpl implements LGUTLC00407Service{
    static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00407ServiceImpl.class);

    @Resource(name="commonDao")
    CommonDao commonDao;
    
    /**
     * Desc : Role 목록을 조회한다.
     * @Method Name : retrieveRoleList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveSystemContactUserList(LGCOMData param){
        LOGGER.debug("param = " + param);

        return this.commonDao.selectList("LGUTLC00407.retrieveSystemContactUserList",param);
    }
    
  
}

