<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="net.sf.ehcache.*, java.util.*, com.lgd.lgcom.framework.model.LGCOMData" %>
<%---------------------------------------------------------
    파일명 : profile.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : profile
    작성자 : wcfw
-------------------------------------------------------------%>
var Profile = 
<%
    Map sessionUser = (Map)session.getAttribute("USER_SESSION");

	CacheManager cacheManager = CacheManager.create();
    Cache siteProfile = cacheManager.getCache("profileCacheSite");
    Cache systemProfile = cacheManager.getCache("profileCacheSystem");
    Cache userProfile = cacheManager.getCache("profileCacheUser");

    LGCOMData profile = new LGCOMData();
    Iterator<String> keys = siteProfile.getKeys().iterator();
    
    while( keys.hasNext() ) {
        String key = keys.next();
        profile.set( key.split("\\|")[0],  siteProfile.get(key).getObjectValue() + "" );
    }

    keys = systemProfile.getKeys().iterator();
    while( keys.hasNext() ) {
        String key = keys.next();
        if( key.endsWith( "|" + sessionUser.get("systemCode") ) ) {
        	profile.set( key.split("\\|")[0],  systemProfile.get(key).getObjectValue() + "" );        	
        }
    } 

    keys = userProfile.getKeys().iterator();
    while( keys.hasNext() ) {
        String key = keys.next();
        if( key.endsWith( "|" + sessionUser.get("applicationUserId") ) ) {
        	profile.set( key.split("\\|")[0],  userProfile.get(key).getObjectValue() + "" );            
        }
    }    
     
    out.println( profile.toJson() );
    
    if( "Y".equals( profile.get("USE_SMALL_LAYOUT") + "" ) ) {
    	request.setAttribute("USE_SMALL_LAYOUT", "page-sm" );
    } else {
    	request.setAttribute("USE_SMALL_LAYOUT", "" );
    }
%>
	