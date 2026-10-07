<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"     uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : error420.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사용자 권한이 없을 때 보이는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<!-- error420.jsp  -->
<% String contextPath = "/lgcom";		// request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">

<c:set var="version" value="1.0.1"/>
<% if( request.getParameter("bizFormId") == null ) { %>
<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/bootstrap-3.3.6-dist/css/bootstrap.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/bootstrap-3.3.6-dist/css/non-responsive.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/font-awesome-4.6.3/css/font-awesome.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/bootstrap-3.3.6-dist/css/awesome-bootstrap-checkbox.css?version=${version}">

<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="/lgcom/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="/lgcom/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}">

<script src="<%=contextPath%>/static/ext/jquery-1.12.4.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/bootstrap-3.3.6-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/bootbox.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="<%=contextPath%>/static/ext/jquery-validate.bootstrap-tooltip.min.js?version=${version}"></script>

<%} %>
<style>
.errorPanel {
    margin: 100px auto 0;
    width : 360px;
    height : 354px;
}

.errorPanel .panel-heading {
    font-weight : bold;
    height : 40px;
    background-color : #f0f0f0;
}

.errorPanel .panel-body {
    text-align : center;
}

.errorPanel .errorMark {
    margin-top : 50px;
    font-size : 50px;
    color : #F34D78;
}

.errorPanel .errorLabel {
    margin-top : 5px;
    font-size : 14px;
    font-weight : bold;
}

.errorPanel .errorText {
    margin-top : 40px;
}

.errorPanel .closeWindow {
    margin-top : 60px;
}

.errorPanel .closeWindow .btn {
    padding-left : 15px;
    padding-right : 15px;
}

._content .errorPanel {
    margin:0px;
    position : absolute;
    top : 30px;
    left : calc( 50% - 179px );
}
</style>

</head>
<body>
<!--
	<div>
		<% if(request.getAttribute("resultMsg") != null) { %>
			<h1><lgcom:message code="${resultMsg}" /></h1>
			<input type="button" style="font-size:9pt;height:25;" value="Login again"  onClick="javascript:top.location.href='/lgcom/service/ssologin'" />
		<% } else { %>
			<h1><lgcom:message code="error.invalidAutho" /></h1>
		<% }%>
	</div>

 -->
        <section class="page-content">

				<div class="panel panel-default errorPanel">
				  <div class="panel-heading">Web</div>
				  <div class="panel-body">
				      <div><i class="fa fa-exclamation-triangle errorMark" aria-hidden="true"></i></div>
				      <div class="errorLabel">ERROR</div>
				  <% if(request.getAttribute("resultMsg") != null) { %>
                      <div class="errorText"><lgcom:message code="${resultMsg}" /></div>
                      <div class="closeWindow">
                          <button type="button" class="btn btn-darkgray btn-xs" onClick="javascript:top.location.href='/lgcom/service/ssologin'">Login again</button>
                      </div>
				  <% } else { %>
                      <div class="errorText">You do not have permission for this system.</div>
				  <% }%>
				  </div>
				</div>

        </section>
        <!-- /page-content -->


</body>
</html>