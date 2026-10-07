<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>
<%---------------------------------------------------------
    파일명 : error400.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사용자 인증 정보가 없을 때 보이는 화면입니다. ( 따라서 특별한 내용없이 즉시 로그인 화면으로 이동합니다. )
    작성자 : wcfw
-------------------------------------------------------------%>
<!-- error400.jsp  -->
<!DOCTYPE html>
<html lang="ko">
<head>
<title>HTTP Error - 4xx</title>
<%
    String contextPath = "/lgcom";		// request.getContextPath();
    String url = request.getRequestURL().toString().split("/")[2];
    /* WebSocket URL */
    String wsPort = url.split(":")[1];
    if( !"local".equals( request.getAttribute("env") ) ) {
        wsPort = "9007";
    }

    String securityCode = (String)request.getAttribute("PAGE_SECURITY_CODE");
    out.println("<script>");
    out.println("    var CONTEXT_PATH       = \""+ request.getContextPath().replaceAll("/", "") +"\";");
    out.println("    var PAGE_SECURITY_CODE = \"" + securityCode + "\";" );
    out.println("    var SSL_SUPPORT =  'N'; ");
   // out.println("    var SERVER_URL  =  'http://" + request.getAttribute("domain") + "'; ");
    out.println("    var SERVER_URL  =  'http://" + url + "'; ");
   // out.println("    var WS_URL  =  'ws://" + url.split(":")[0] + ":" + wsPort  + "'; ");

    out.println("    var SYSTEM_ENV = '" + request.getAttribute("env") + "';");
    out.println("    var DEBUG_MODE = '" + request.getParameter("debug") + "';");
    out.println("</script>");


    //Prod 와 그 외를 구별하기 위한 코드
    String env = (String)request.getAttribute("env");
    if( !"prod".equals( env ) ) {
    	env = "dev";
    }

    /**
       /container 등에서 호출 한 경우에는 _external_parameter_ 가 존재하는데,
       이 페이지에 도착했다는 것은 다음의 경우를 이야기 한다.

       1. req-header 에 iv-user 항목이 없는경우 : 개발서버, 로컬 인 경우
       2. 1번의 상황에서 서버에 로그인이 돼 있지 않은 경우

       따라서 이 페이지에서는 로그인 정보가 없는 경우이므로 사용자에게 입력을 받는 폼으로 보내야 한다.
       아래와 같은 url 정책을 적용한다.
    */

    String targetUrl = "";
    if( "prod".equals( env ) ) {
    	targetUrl = "/lgcom/login";
    } else {
    	if( request.getSession().getAttribute("_external_parameter_") == null ) {
    		targetUrl = "/lgcom/service/login";
    	} else {
    		targetUrl = "/lgcom/service/ssologin";
    	}
    }

    String systemCode = "";
    if( request.getParameter("systemCode") != null ) {
    	systemCode = request.getParameter("systemCode");
    }

%>
<c:set var="version" value="1.0.1"/>

<link rel="stylesheet" type="text/css"	href="<%=contextPath%>/static/ext/bootstrap-3.3.6-dist/css/bootstrap.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=contextPath%>/static/ext/font-awesome-4.6.3/css/font-awesome.min.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="<%=contextPath%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.css?version=${version}">

<link rel="stylesheet" type="text/css"	href="<%=contextPath%>/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=contextPath%>/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="<%=contextPath%>/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}">

<link rel="stylesheet" type="text/css"  href="<%=contextPath%>/static/css/framework_main_small.css?version=${version}">

<script src="<%=contextPath%>/static/ext/jquery-1.12.4.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/bootstrap-3.3.6-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/bootbox.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/jquery-validate.bootstrap-tooltip.min.js?version=${version}"></script>

<script src="<%=contextPath%>/static/js/framework_lib.js?version=${version}"></script>

</head>

<body>
<script type="text/javascript">
var message = '<lgcom:message code="error.needLogin" />';

if( "<%=systemCode%>" != "" ) {
	document.location.href = SERVER_URL + "<%=targetUrl%>?systemCode=<%=systemCode%>" ;
} else {
	if(typeof Message == "undefined" ){
	    document.location.href = SERVER_URL + "<%=targetUrl%>" ;
	} else {
		Message.confirm( message, function(){
			document.location.href = SERVER_URL + "<%=targetUrl%>" ;
	    });
	}
}
</script>
</body>
</html>