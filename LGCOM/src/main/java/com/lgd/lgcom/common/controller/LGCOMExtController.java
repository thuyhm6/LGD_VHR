/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGCOMExtController.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 28.    jhpark23    최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.common.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.lgd.lgcom.common.service.CommonService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

import devonframe.util.FileUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.common.controller.LGCOMExtController.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 6. 28. 오전 9:43:28
 * @Version   
 */
@Controller
public class LGCOMExtController extends BaseLGCOMController {

    private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGCOMExtController.class);

    @Value("domain_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String domain = null;

    @Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String env = null;

    @Value("common_directory_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String commonDirectory = null;

    @Value("common_directory_emro_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String commonDirectoryEmro = null;

    @Value("common_directory_hrm_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
    private String commonDirectoryHrm = null;    
    
    @Autowired
    private EhCacheCacheManager cacheManager;
    
    @Autowired
    private UserSessionService userSessionService;
    
    @Autowired
    CommonService commonService;
    
    @SuppressWarnings("unchecked")
    @RequestMapping(value = "/container")
    public String executeService(HttpServletRequest req, HttpServletResponse res, Model model, String redirect, String forward)
            throws LGCOMException, IOException{

    	String menuId = null;
    	/* URL 패턴을 /container?menuId=M_LGSYSC_1126 ,  /container/M_LGSYSC_1126  두 종류 모두 수용하기 위해 
    	 * 다음의 코드로 정리하였다. */
    	if( req.getRequestURI().contains("/container/") ) {
    		menuId = req.getRequestURI().split("/")[1];
    	} else {
    		menuId = req.getParameter("menuId");
    	}
    	
    	LOGGER.debug( "menuId : " + menuId );
        StringBuilder view = new StringBuilder();

        /**
         * 외부 시스템의 화면을 본 시스템에서 보여주기 위해 사용하는 main/container.jsp를 전달한다.
         * Request Param으로 전달받은 menuId는 AuthorizationInterceptor에서 권한체크를 수행한다.
         * */
        String securityCode = LGCOMUtils.getUUID();
        Set<String> securityCodeMap = (HashSet<String>)req.getSession().getAttribute(LGCOMConstants.AJAX_SECURITY);
        if (NullUtil.isNull(securityCodeMap)) {
            securityCodeMap = new HashSet<String>();
            req.getSession().setAttribute(LGCOMConstants.AJAX_SECURITY, securityCodeMap);
        }
        securityCodeMap.add(securityCode);

        req.setAttribute(LGCOMConstants.AJAX_SECURITY, securityCode);
        
        
        LGCOMData menuInfo = CacheUtils.getCacheValue(cacheManager, LGCOMConstants.MENU_CACHE, menuId);
        
        /* container.jsp 에서 해당 페이지를 부르기 위해 사용하는 정보로서, 
         * request 에 붙여 화면에 돌려보내주도록 한다.*/
        req.setAttribute("programId", menuInfo.getString("programId"));
        req.setAttribute("menuId", menuId );
        req.setAttribute("menuName", menuInfo.getString("menuName") );
        req.setAttribute("systemCode", menuInfo.getString("systemCode") );  
        req.setAttribute("programTypeCode", menuInfo.getString("programTypeCode") );  
        req.setAttribute("linkUrlAddr", menuInfo.getString("linkUrlAddr") );  
        
        /**
         * response header : date YYYYMMDD HH:24mi:SS
         */
        if( userSessionService.getSession(req) != null ) {
            String currentTimeString = LGCOMUtils.getCurrentTimeString( userSessionService.getSession(req).get("serverTimeDifferenceSeqs") );
            res.setHeader("serverTime", currentTimeString );
            req.setAttribute("serverTime", currentTimeString );        
        } 
        
        view = new StringBuilder();
        view.append("main/container");

        req.setAttribute("env", env);
        req.setAttribute("domain", LGCOMUtils.getValueFromProjectProperties(domain));
        req.setAttribute("model", model);

        LOGGER.debug(menuId + " >>>>>>>>>>>>>>>>> " + view.toString());

        return getReturnUrl(view.toString(), redirect, forward);
    }
    
    @SuppressWarnings("unchecked")
    @RequestMapping(value = "/approval")
    public String approvalService(HttpServletRequest req, HttpServletResponse res, Model model, String redirect, String forward)
            throws LGCOMException, IOException{

        StringBuilder view = new StringBuilder();

        /**
         * 외부 시스템의 화면을 본 시스템에서 보여주기 위해 사용하는 main/container.jsp를 전달한다.
         * Request Param으로 전달받은 menuId는 AuthorizationInterceptor에서 권한체크를 수행한다.
         * */
        String securityCode = LGCOMUtils.getUUID();
        Set<String> securityCodeMap = (HashSet<String>)req.getSession().getAttribute(LGCOMConstants.AJAX_SECURITY);
        if (NullUtil.isNull(securityCodeMap)) {
            securityCodeMap = new HashSet<String>();
            req.getSession().setAttribute(LGCOMConstants.AJAX_SECURITY, securityCodeMap);
        }
        securityCodeMap.add(securityCode);

        req.setAttribute(LGCOMConstants.AJAX_SECURITY, securityCode);
        /**
         * response header : date YYYYMMDD HH:24mi:SS
         */
        if( userSessionService.getSession(req) != null ) {
            String currentTimeString = LGCOMUtils.getCurrentTimeString( userSessionService.getSession(req).get("serverTimeDifferenceSeqs") );
            res.setHeader("serverTime", currentTimeString );
            req.setAttribute("serverTime", currentTimeString );        
        } 

        view = new StringBuilder();
        view.append("main/approval");

        req.setAttribute("env", env);
        req.setAttribute("domain", LGCOMUtils.getValueFromProjectProperties(domain));
        req.setAttribute("model", model);

        LOGGER.debug( "approval  >>>>>>>>>>>>>>>>> " + view.toString());

        return getReturnUrl(view.toString(), redirect, forward);
    }    
    
    @SuppressWarnings("unchecked")
    @RequestMapping(value = "/approvalRequest")
    public String approvalRequestService(HttpServletRequest req, HttpServletResponse res, Model model, String redirect, String forward) throws LGCOMException, IOException{

        StringBuilder view = new StringBuilder();

        /**
         * 외부 시스템의 화면을 본 시스템에서 보여주기 위해 사용하는 main/container.jsp를 전달한다.
         * Request Param으로 전달받은 menuId는 AuthorizationInterceptor에서 권한체크를 수행한다.
         * */
        String securityCode = LGCOMUtils.getUUID();
        Set<String> securityCodeMap = (HashSet<String>)req.getSession().getAttribute(LGCOMConstants.AJAX_SECURITY);
        if (NullUtil.isNull(securityCodeMap)) {
            securityCodeMap = new HashSet<String>();
            req.getSession().setAttribute(LGCOMConstants.AJAX_SECURITY, securityCodeMap);
        }
        securityCodeMap.add(securityCode);

        req.setAttribute(LGCOMConstants.AJAX_SECURITY, securityCode);
        /**
         * response header : date YYYYMMDD HH:24mi:SS
         */
        if( userSessionService.getSession(req) != null ) {
            String currentTimeString = LGCOMUtils.getCurrentTimeString( userSessionService.getSession(req).get("serverTimeDifferenceSeqs") );
            res.setHeader("serverTime", currentTimeString );
            req.setAttribute("serverTime", currentTimeString );        
        } 

        view = new StringBuilder();
        view.append("main/approvalRequest");

        req.setAttribute("env", env);
        req.setAttribute("domain", LGCOMUtils.getValueFromProjectProperties(domain));
        req.setAttribute("model", model);

        LOGGER.debug( "approvalRequest  >>>>>>>>>>>>>>>>> " + view.toString());

        return getReturnUrl(view.toString(), redirect, forward);
    } 

	@RequestMapping(value = "/download/common/mobile")
	public void mobildDownloadSupport(HttpServletRequest req, HttpServletResponse res, @RequestParam(required = true) String fileId, @RequestParam(required = true) String moduleCode) {

		LOGGER.debug( req.getRequestURI() );		
		
		LGCOMData inParam = new LGCOMData();
		inParam.set("fileId", fileId);

		StringBuilder fileFullPath = new StringBuilder();
		if ("EMRO".equalsIgnoreCase(moduleCode)) {
			inParam.set("source", moduleCode);
			fileFullPath.append(LGCOMUtils.getValueFromProjectProperties(commonDirectoryEmro));
		} else if ("HRM".equalsIgnoreCase(moduleCode)) {
			inParam.set("source", moduleCode);
			inParam.set("fileId", fileId);
			fileFullPath.append(LGCOMUtils.getValueFromProjectProperties(commonDirectoryHrm));
		} else {
			fileFullPath.append(LGCOMUtils.getValueFromProjectProperties(commonDirectory));
		}

		LGCOMData detail = commonService.retrieveAttachFileInfo(inParam);

		if (detail == null) {
			throw new LGCOMException("File information is invalid. File Id : " + fileId);
		}

		String fileName = StringUtils.trim(detail.getString("fileId"));
		try {
			fileName = new String(fileName.getBytes("UTF-8"), "8859_1");
		} catch (Exception ex) {
			LOGGER.error(ex.getMessage(), ex);
		}

		if ("HRM".equalsIgnoreCase(moduleCode)) {
			fileFullPath.append(fileName);
		} else {
			fileFullPath.append(detail.getString("moduleCode") + "/" + fileName);
		}

	    File file = new File(fileFullPath.toString());
	    FileInputStream fileInputStream = null;

	    try {
	    	res.reset();   
	    	res.setContentType("application/octet-stream");

	    	res.setHeader("Content-Transfer-Encoding", "binary;");
	    	res.setHeader("Pragma", "no-cache;");
	    	res.setHeader("Expires", "-1;");
	    	res.setHeader("Set-Cookie", "fileDownload=true;path=/");

	    	res.setHeader("Content-Disposition", "attachment; filename=\""+ FileUtil.encodeURLEncoding( detail.getString("fileName"), "UTF-8").replaceAll("\\+", " ") + "\"");
	        fileInputStream = new FileInputStream(file);
	        IOUtils.copy(fileInputStream, res.getOutputStream());
	    } catch (Exception ex) {
	        LOGGER.error(ex.getMessage(), ex);
	    } finally {    
	        IOUtils.closeQuietly(fileInputStream);
	    }		
		
	}
}
