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
package com.lgd.lgcom.lgsetc.lgsetc00010.service.serviceImpl;

import java.util.List;
import java.util.Map;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00010.service.LGSETC00010Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 6. 03. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00010Service")
public class LGSETC00010ServiceImpl implements LGSETC00010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Code Type 목록을 조회한다.
	 * @Method Name : retrieveCodeTypeList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeTypeList(LGCOMData param){
		LOGGER.debug("param = " + param);
		
		List<LGCOMData> list = (List<LGCOMData>)param.get("AA");
		
		
		
		return this.commonDao.selectList("LGSETC00010.retrieveCodeTypeList",param);
	}
	
	/**
     * Desc :  Code Type Code 중복체크 한다.
     * @Method Name : retrieveCodeTypeCode
     * @param  param
     * @throws Exception
     */
    public boolean retrieveCodeTypeCode(LGCOMData param){
        LOGGER.debug("param = " + param);
        boolean result = false;
        LGCOMData temp = this.commonDao.select("LGSETC00010.retrieveCodeTypeCode", param);
        int count = temp.getInt("cnt");
        LOGGER.debug("result = " + temp);
        if(count > 0){
            result = true;
        }else{
            result = false;
        }
        return result;
    }
    
    /**
     * Desc :  Role Code By CodeTypeCode 중복체크 한다.
     * @Method Name : retrieveRoleByCodeTypeCode
     * @param  param
     * @throws Exception
     */
    public boolean retrieveRoleByCodeTypeCode(LGCOMData param){
        LOGGER.debug("param = " + param);
        boolean result = false;
        LGCOMData temp = this.commonDao.select("LGSETC00010.retrieveRoleByCodeTypeCode", param);
        int count = temp.getInt("cnt");
        LOGGER.debug("result = " + temp);
        if(count > 0){
            result = true;
        }else{
            result = false;
        }
        return result;
    }
    
	/**
     * Desc : Code Type에 대한 role목록을 조회한다.
     * @Method Name : retrieveCodeTypeRoleList
     * @param  param
     * @return List<?>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCodeTypeRoleList(LGCOMData param){
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00010.retrieveCodeTypeRoleList",param);
    }
	/**
     * Desc : Code Type 목록을 저장한다.
     * @Method Name : saveCodeTypeList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })    
    public void saveCodeTypeList(LGCOMData param){
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
                /* Check duplicate */
                LGCOMData map = this.commonDao.select("LGSETC00010.retrieveCodeTypeCode",item);
                
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
                this.commonDao.update("LGSETC00010.insertCodeTypeList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);     
        
        for( LGCOMData item : LGCOMUtils.emptyIfNull( uList ) ) {
            item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
            this.commonDao.update("LGSETC00010.updateCodeTypeList",item);
        }
//        /* 삭제건 저장 */
//        List<?> dList = (List<?>)param.get(LGCOMConstants.STATUS_DELETE);
//        if(dList != null && dList.size() > 0) {
//            for(int a=0; a < dList.size(); a++) {
//                Map<String,Object> item = (Map<String,Object>)dList.get(a);
//                /* 세션 사용자 정보 세팅 */
//                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
//                this.commonDao.update("LGSETC00060.deleteMsgList",item);
//            }
//        }
        
    }
    
    /**
     * Desc : Code Type에 대한 role목록을 저장한다.
     * @Method Name : saveCodeTypeRoleList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })    
    public void saveCodeTypeRoleList(LGCOMData param){
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
            	
                /* Check duplicate */
                LGCOMData map = this.commonDao.select("LGSETC00010.retrieveRoleByCodeTypeCode",item);
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00010.insertCodeTypeRoleList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);    
        
        if(uList != null && uList.size() > 0) {
            for(int b=0; b < uList.size(); b++) {
            	LGCOMData item = (LGCOMData)uList.get(b);
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00010.updateCodeTypeRoleList",item);
            }
        }
        /* 삭제건 저장 */
        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
        if(dList != null && dList.size() > 0) {
            for(int a=0; a < dList.size(); a++) {
            	LGCOMData item = dList.get(a);
                /* 세션 사용자 정보 세팅 */
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).get("applicationUserId"));
                this.commonDao.update("LGSETC00010.deleteCodeTypeRoleList",item);
            }
        }
        
    }
}
