/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00035Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 21.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00035.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00035.service.LGSETC00035Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00035.controller.LGSETC00035Controller.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 21. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00035Service")
public class LGSETC00035ServiceImpl implements LGSETC00035Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00035ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Value Set 목록을 조회한다.
	 * @Method Name : retrieveCodeValSetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeValSetList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00035.retrieveCodeValSetList",param);
	}
	
	/**
     * Desc : Value Set 정보를 저장한다.
     * @Method Name : saveMsgList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void saveCodeValSetList(LGCOMData param) {
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
                /* Duplecate check */
                LGCOMData map = this.commonDao.select("LGSETC00035.retrieveValueSetIdChk",item);
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
                this.commonDao.update("LGSETC00035.insertCodeValSetList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);        
        if(uList != null && uList.size() > 0) {
            for(int b=0; b < uList.size(); b++) {
            	LGCOMData item = uList.get(b);
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
                this.commonDao.update("LGSETC00035.updateCodeValSetList",item);
            }
        }
        /* 삭제건 저장 */
        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
        if(dList != null && dList.size() > 0) {
            for(int a=0; a < dList.size(); a++) {
            	LGCOMData item = dList.get(a);
                /* 세션 사용자 정보 세팅 */
                //item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                //this.commonDao.update("LGSETC00035.deleteCodeValSetList",item);
            }
        }        
    }
    
    /**
     * Desc : Value Set 중복체크를 한다.
     * @Method Name : retrieveValueSetIdChk
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveValueSetIdChk(LGCOMData param) {
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00035.retrieveValueSetIdChk",param);
    }
}
