<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : loginForm.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 운영 SSO 로그인 정보를 입력받는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>

<c:set var="version" value="1.0.1"/>

<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>Login Page</title>

<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.6-dist/css/bootstrap.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/font-awesome-4.6.3/css/font-awesome.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.css?version=${version}">

<style>
html, body {
	position : fixed;
	top : 0px;
	right : 0px;
	left : 0px;
	bottom : 0px;
	background-color: #ddd;
}
</style>

<%
	String url = request.getRequestURL().toString().split("/")[2];

	/* scs Reverse Proxy 대응 코드 */
	String scsHost = request.getHeader("x-forwarded-host");
	boolean scs = false;
	if( scsHost != null && scsHost.trim().startsWith("scs") ){ 
		   scs = true;
	}

    String debugMode = "N";
    if( "Y".equals( request.getParameter("debug") ) ) {
    	debugMode = "Y";
    }	
	
	String securityCode = (String)request.getAttribute("PAGE_SECURITY_CODE");
	out.println("<script>");
	out.println("\tvar CONTEXT_PATH       = \""+ request.getContextPath().replaceAll("/", "") +"\";");
	out.println("\tvar PAGE_SECURITY_CODE = \"" + securityCode + "\";" );
	out.println("\tvar SSL_SUPPORT =  'N'; ");

    if( scs ) {
    	out.println("    var SERVER_URL  =  'http://" + scsHost + ":3001'; ");
    } else {
    	out.println("    var SERVER_URL  =  'http://" + url + "'; ");
    }
	
	out.println("    var SYSTEM_ENV = '" + request.getAttribute("env") + "';");
	out.println("    var DEBUG_MODE = '" + debugMode  + "';");	
	out.println("</script>");
%>

<script src="<%=request.getContextPath()%>/static/ext/jquery-1.12.4.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.6-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootbox.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/moment.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/lgduxp/js/lgd-uxp-ui.js?version=${version}"></script>

<% if( "prod".equals( request.getAttribute("env")+"" )  ){ %>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs.1.1.20.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/realgridjs-api.1.1.20.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/prod/jszip.min.js?version=${version}"></script>  
<% } else { 
       if( url.contains("bizweb") ) {
%>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs_eval.1.1.21.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/realgridjs-api.1.1.21.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/dev/jszip.min.js?version=${version}"></script>   
<%     } else { %>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs-lic.js?version=${version}"></script> 
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs_eval.1.1.20.min.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/realgridjs-api.1.1.20.js?version=${version}"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/static/ext/realgrid/devip/jszip.min.js?version=${version}"></script>
 <% }
}%>


<script src="<%=request.getContextPath()%>/static/js/framework_lib.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/js/framework.js?version=${version}"></script>
<!-- LGD UXP UI 공통 스크립트 -->
<script src="<%=request.getContextPath()%>/static/ext/daterangepicker/js/jquery.daterangepicker.js?version=${version}"></script>

<!-- Session Info Variables -->
<%
	java.util.Map user = (java.util.Map)session.getAttribute("USER_SESSION");
	if( user != null ) {
		out.println("<script>");
		out.println("\tvar SESSION_USER = {");
		out.println("\t                       applicationUserId : '" + user.get("applicationUserId") + "',");
		out.println("\t                       systemCode : '" + user.get("systemCode") + "',");
		out.println("\t                       employeeId : '" + user.get("employeeId") + "',");
		out.println("\t                       userName : '" + user.get("userName") + "',");
		out.println("\t                       fullNameLocal : '" + user.get("fullNameLocal") + "',");
		out.println("\t                       languageCode : '" + user.get("languageCode") + "'");
		out.println("\t};");
		out.println("</script>");
	}
%>
</head>

<body>
<jsp:include page="/WEB-INF/views/login/loginAllowFilter.jsp">
	<jsp:param name="type" value="sso"/>
</jsp:include>
<section class="page-content">
	<div class="content">
		<!-- /nav-tabs -->
		<form id="loginForm" class="form-signin" autocomplete="off" method="POST" action="<%=request.getContextPath()%>/login">
			<div class="heading">
				<h2 class="form-signin-heading">SSO login</h2>
				<p></p>
			</div>
			<!-- /heading -->
			<div class="form-group">
				<label for="inputEmail" class="sr-only"></label>
				<input type="text" name="iv-user" class="form-control" placeholder="SSO Name" />
			</div>
			<!-- /form-group -->
			<div class="form-group">
				<label for="inputPassword" class="sr-only"></label>
				<input type="password" name="password" class="form-control" placeholder="Password" />
			</div>
			<!-- /form-group -->
			<button class="btn btn-lg btn-lgd btn-block" type="submit">Sign In</button>
		</form>
		<!-- /form-signin -->
	</div>
	<!-- /content -->
</section>
<!-- /page-content -->

<script>
//<![CDATA[
/* Event handler triggered just after page ready. */
$(document).ready(function() {
	fnc_initPage();
});

/* Javascript function definitions for this pages */
function fnc_initPage() {
}

function fnc_validate(selector) {
	var rules = {
		rules : {
			userName : { required : true },
			password : { required : true }
		},
		messages : {
			userName : { required : '<lgcom:message code="note.requiredInput" />'},
			password : { required : '<lgcom:message code="note.requiredInput" />'}
		}
	};
	var target = $(selector);
	var validator = target.validate(rules);

	if( target.valid() ) {
		return true;
	} else {
		validator.focusInvalid();
		return false;
	}
}
<%@ include file="/WEB-INF/views/framework/commonMessage.jsp" %>
//]]>
</script>
</body>
</html>
