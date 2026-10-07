/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSETC00070Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 1.    hicho    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsetc.lgsetc00070.service.serviceImpl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00070.service.LGSETC00070Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00070.controller.LGSETC00070Controller.java
 * </PRE>
 *
 * @Author    hicho
 * @Date      2016. 6. 1. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00070Service")
public class LGSETC00070ServiceImpl implements LGSETC00070Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00070ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 라벨 목록을 조회한다.
	 * @Method Name : retrieveMsgList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLabelList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00070.retrieveLabelList",param);
	}
	
	   /**
     * Desc : 라벨 정보를 저장한다.
     * @Method Name : saveLabelList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void saveLabelList(LGCOMData param) {
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
                /* Duplecate check */
            	LGCOMData map = this.commonDao.select("LGSETC00070.retrieveLabelIdChk",item);
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00070.insertLabelList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);        
        if(uList != null && uList.size() > 0) {
            for(int b=0; b < uList.size(); b++) {
            	LGCOMData item = uList.get(b);
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00070.updateLabelList",item);
            }
        }
        /* 삭제건 저장 */
        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
        if(dList != null && dList.size() > 0) {
            for(int a=0; a < dList.size(); a++) {
            	LGCOMData item = dList.get(a);
                /* 세션 사용자 정보 세팅 */
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00070.deleteLabelList",item);
            }
        }
        
    }
    
    /**
     * Desc : 라벨ID 목록을 조회한다.
     * @Method Name : retrieveLabelIdList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveLabelIdList(LGCOMData param) {
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00070.retrieveLabelIdList",param);
    }
    
    /**
     * Desc : 라벨ID 중복체크를 한다.
     * @Method Name : retrieveLabelIdChk
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveLabelIdChk(LGCOMData param) {
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00070.retrieveLabelIdChk",param);
    }
}
