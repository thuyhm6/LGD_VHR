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
package com.lgd.lgcom.lgsetc.lgsetc00030.service.serviceImpl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsetc.lgsetc00030.service.LGSETC00030Service;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00010.controller.LGSETC00010Controller.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 6. 03. 오전 9:00:58
 * @Version
 */
@Service(value="LGSETC00030Service")
public class LGSETC00030ServiceImpl implements LGSETC00030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSETC00030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Code Value 목록을 조회한다.
	 * @Method Name : retrieveCodeValueList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCodeValueList(LGCOMData param){
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSETC00030.retrieveCodeValueList",param);
	}

	/**
     * Desc : Code의 다국어 목록을 조회한다.
     * @Method Name : retrieveCodeLangList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCodeLangList(LGCOMData param){
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00030.retrieveCodeLangList",param);
    }

    /**
     * Desc : combo 박스의 목록을 조회한다.
     * @Method Name : retrieveGridComboList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public List<LGCOMData> retrieveGridComboList(LGCOMData param){
        LOGGER.debug("param = " + param);
        List compList = this.commonDao.selectList("LGSETC00030.retrieveCompanyIdList",param);
        //List invList = this.commonDao.selectList("LGSETC00030.retrieveOrgIdList",param);
        List ynList = this.commonDao.selectList("Common.retrieveCommonCodeList",param);
        List result = new ArrayList();
        result.add(compList);
        //result.add(invList);
        result.add(ynList);
        return result;
        //return this.commonDao.selectList("LGSETC00030.retrieveCompanyIdList",param);
    }

    /**
     * Desc : Company Id 목록을 조회한다.
     * @Method Name : retrieveCompanyIdList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveCompanyIdList(LGCOMData param){
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00030.retrieveCompanyIdList",param);
    }

    /**
     * Desc : Oraganization Id 목록을 조회한다.
     * @Method Name : retrieveOrgIdList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveOrgIdList(LGCOMData param){
        LOGGER.debug("param = " + param);
        return this.commonDao.selectList("LGSETC00030.retrieveOrgIdList",param);
    }

    /**
     * Desc : Code Value의 중복체크를 한다.
     * @Method Name : retrieveCodeValDupChk
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public boolean retrieveCodeValDupChk(LGCOMData param){
        LOGGER.debug("param = " + param);
        boolean result = false;
        LGCOMData temp = this.commonDao.select("LGSETC00030.retrieveCodeValDupChk", param);
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
     * Desc : Code Value Multi Language의 중복체크를 한다.
     * @Method Name : retrieveLangCodeDupChk
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public boolean retrieveLangCodeDupChk(LGCOMData param){
        LOGGER.debug("param = " + param);
        boolean result = false;
        LGCOMData temp = this.commonDao.select("LGSETC00030.retrieveLangCodeDupChk", param);
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
     * Desc : Code Value 목록을 저장한다.
     * @Method Name : saveCodeValueList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void saveCodeValueList(LGCOMData param){
    	Set<String> codeTypeCodeSet = new HashSet<String>();
        LOGGER.debug("param = " + param);
        
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
                /* Check duplicate */
                LGCOMData map = this.commonDao.select("LGSETC00030.retrieveCodeValDupChk",item);
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                if(item.get("companyId")==null || "".equals(item.get("companyId"))){
                    item.set("companyId", "0");
                }
                if(item.get("inventoryOrganizationId")==null || "".equals(item.get("inventoryOrganizationId"))){
                    item.set("inventoryOrganizationId", "0");
                }
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                //item.set("codeTypeCode",((Map)param.get("parameter")).get("codeTypeCode"));
                
                codeTypeCodeSet.add( item.get("codeTypeCode") + "" );                
                this.commonDao.update("LGSETC00030.insertCodeValueList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
        LOGGER.debug(uList);
        if(uList != null && uList.size() > 0) {
            for(int b=0; b < uList.size(); b++) {
            	LGCOMData item = uList.get(b);
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                codeTypeCodeSet.add( item.get("codeTypeCode") + "" );
                this.commonDao.update("LGSETC00030.updateCodeValueList",item);
            }
        }
        
        //processCache( codeTypeCodeSet );
    }

    /**
     * Desc : Code의 다국어 목록을 저장한다.
     * @Method Name : saveCodeLangList
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void saveCodeLangList(LGCOMData param){
    	Set<String> codeTypeCodeSet = new HashSet<String>();    	
    	
        LOGGER.debug("param = " + param);
        /* 등록건 저장 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        if(cList != null && cList.size() > 0) {
            for(int a=0; a < cList.size(); a++) {
            	LGCOMData item = cList.get(a);
                /* Check duplicate */
                LGCOMData map = this.commonDao.select("LGSETC00030.retrieveLangCodeDupChk",item);
                if(map.getInt("cnt") > 0) {
                    throw new LGCOMException("error.duplicateValue");
                }
                item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
                
                codeTypeCodeSet.add( item.get("codeTypeCode") + "" );
                this.commonDao.update("LGSETC00030.insertCodeLangList",item);
            }
        }
        /* 수정건 저장 */
        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
        if(uList != null && uList.size() > 0) {
            for(int b=0; b < uList.size(); b++) {
            	LGCOMData item = uList.get(b);
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                
                codeTypeCodeSet.add( item.get("codeTypeCode") + "" );
                this.commonDao.update("LGSETC00030.updateCodeLangList",item);
            }
        }
        /* 삭제건 저장 */
        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
        if(dList != null && dList.size() > 0) {
            for(int a=0; a < dList.size(); a++) {
            	LGCOMData item = dList.get(a);
                /* 세션 사용자 정보 세팅 */
                item.set("sessionUserId",((Map)param.get("USER_SESSION")).get("applicationUserId"));
                
                codeTypeCodeSet.add( item.get("codeTypeCode") + "" );
                this.commonDao.update("LGSETC00030.deleteCodeLangList",item);
            }
        }
        
        //processCache( codeTypeCodeSet );        
    }
    
    
    protected void processCache( Set<String> itemsSet ) {
		CacheManager cacheManager = CacheManager.create();
		Cache cache = cacheManager.getCache( LGCOMConstants.COMMON_CODE_CACHE );
		
    	Iterator <String> it = itemsSet.iterator();
    	while( it.hasNext() ) {
    		String codeTypeCode = it.next();
LOGGER.debug( "" );    		
    		cache.remove( codeTypeCode );
    	}
    }
}
