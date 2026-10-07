<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : loginForm.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 로그인 정보를 입력받는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>

<c:set var="version" value="1.0.1"/>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
  
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>Login Page</title>
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.7-dist/css/bootstrap.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.7-dist/css/awesome-bootstrap-checkbox.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/font-awesome-4.7.0/css/font-awesome.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="<%=request.getContextPath()%>/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.css?version=${version}">
<!-- <link rel="icon" href="favicon.ico"> -->
<%
    out.println("<script>");
    out.println("    var CONTEXT_PATH       = \""+ request.getContextPath().replaceAll("/", "") +"\";");
    out.println("    var SERVER_URL  =  'http://' + document.location.host; ");
    out.println("    var SYSTEM_ENV = '" + request.getAttribute("env") + "';");
	out.println("    var SESSION_INTERVAL = " + session.getMaxInactiveInterval() + ";");
	out.println("    var Param = { debug : 'N' };");    
    
	java.util.Enumeration<String> em = request.getParameterNames();
	while( em.hasMoreElements() ) {
		String key = em.nextElement();
		out.println("    Param[\""+ key +"\"] = \""+ request.getParameter(key)+"\";");
	}
	
    out.println("</script>");
%> 

<script src="<%=request.getContextPath()%>/static/ext/jquery-3.2.1.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootstrap-3.3.7-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/bootbox.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/moment.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/ext/lgduxp/js/lgd-uxp-ui.js?version=${version}"></script>

<% if( "prod".equals( request.getAttribute("env")+"" )  ){ %>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs-lic.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs.1.1.22.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs-api.1.1.22.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/jszip.min.js?version=${version}"></script>
<% } else { %>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs-lic.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs_eval.1.1.22.min.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs-api.1.1.22.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/jszip.min.js?version=${version}"></script>
<% }%>

<script src="<%=request.getContextPath()%>/static/js/framework_lib.js?version=${version}"></script>
<script src="<%=request.getContextPath()%>/static/js/framework.js?version=${version}"></script>
<!-- LGD UXP UI 공통 스크립트 -->
<script src="<%=request.getContextPath()%>/static/ext/daterangepicker/js/jquery.daterangepicker.js?version=${version}"></script>

<script>
trace( document.location );
</script>

<!-- Session Info Variables -->
<%
    java.util.Map<String,Object> user = (java.util.Map<String,Object>)session.getAttribute("USER_SESSION");

    if( user != null ) {
    	out.println(" <script>" );
    	out.println(" var SESSION_USER = { applicationUserId : '" + user.get("applicationUserId") +
    	                              "',  systemCode : '" + user.get("systemCode") +
    	                              "',  employeeId : '" + user.get("employeeId") +
    	                              "' , userName : '" + user.get("userName") +
    	                              "' , fullNameLocal : '" + user.get("fullNameLocal") +
    	                              "' , languageCode : '" + user.get("languageCode") +
    	                              "'};");
    	out.println(" </script>" );
    }
%>
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


</head>

<body>
<!-- <%=session.getAttribute("targetSystemCode")%> -->
<jsp:include page="/WEB-INF/views/login/loginAllowFilter.jsp">
	<jsp:param name="type" value="login"/>
</jsp:include>

<!--

	<div class="container">
		<div class="row" style="height: 200px;"></div>
		<div class="row">
			<div class="col-md-4"></div>
			<div class="col-md-4">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Login</h3>
					</div>
					<div class="panel-body">

						<form id="loginForm"  class="form-horizontal">
							<div class="form-group">
								<label for="inputEmail3" class="col-sm-4 control-label">User Name</label>
								<div class="col-sm-8">
									<input type="text" name="userName" class="form-control" />
								</div>
							</div>
							<div class="form-group">
								<label for="inputPassword3" class="col-sm-4 control-label">Password</label>
								<div class="col-sm-8">
									<input type="password" name="password" class="form-control"  />
								</div>
							</div>
							<div class="form-group">
								<div class="col-sm-offset-8 col-sm-4">
									<button type="submit" class="btn btn-primary">Sign in</button>
								</div>
							</div>
						</form>


					</div>
				</div>
			</div>
			<div class="col-md-4"></div>
		</div>
	</div>

-->
		<section class="page-content">

			<div class="content">
				<!-- /nav-tabs -->
				
				<form id="loginForm" class="form-signin" autocomplete="off">
				    <div class="form-box">
				        <div class="heading">
				            <h2 class="form-signin-heading">WCFW</h2>
				            <p></p>
				        </div>
				        <!-- /heading -->
					    <div class="form-group">
					    	<label for="inputEmail" class="sr-only">아이디</label>
					        <input type="text" id="inputEmail" name="userName" class="form-control" placeholder="User Name">
					    </div>
				       	<!-- /form-group -->
				        <div class="form-group">
				            <label for="inputPassword" class="sr-only">비밀번호</label>
				            <input type="password" id="inputPassword" name="password" class="form-control" placeholder="Password">
				        </div>
				        <!-- /form-group -->
				        <button class="btn btn-lg btn-lgd btn-block" type="submit">Sign In</button>
				        <div class="bottom">
				            <div class="checkbox checkbox-uxp checkbox-inline">
				                <input type="checkbox" id="saveID" value="remember-me">
				                <label for="saveID">아이디저장</label>
				            </div>
				            <div class="find">
				                <a href=""><span class="fa fa-lock"></span> 아이디/비밀번호 저장</a>
				            </div>
				        </div>
				        <!-- /bottom -->
				    </div>
				    <footer>
				        <p class="logo">LG Display</p>
				    </footer>
				</form>
				<!-- /form-signin -->
	
			</div>
			<!-- /content -->
		</section>
		<!-- /page-content -->


<script>
//<![CDATA[
/* Event handler triggered just after page ready. */
$(document).ready(function(){
	fnc_initPage();

	/* General Event Handlers */
	$(document).on("click", "button[type='submit']", function( event ){

		if(fnc_validate("#loginForm")){
			transaction( CONTEXT_PATH, "login", $("#loginForm").toJSON() , function( data ){
				var nav = new Navigate( "lgcom" , "main" );
				nav.goGet();
			} );
		}

		event.preventDefault();
	});

	$("#loginForm").submit(function(){
		return false;
	});

});

/* Javascript function definitions for this pages */
function fnc_initPage(){

}

function fnc_validate(selector){

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
