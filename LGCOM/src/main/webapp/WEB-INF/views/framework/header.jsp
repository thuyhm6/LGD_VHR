<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.util.*" %>
<%@ page import="com.lgd.lgcom.common.util.*" %>
<%@ page import="com.lgd.lgcom.framework.model.*" %>
<%@ page import="com.google.gson.Gson" %>
<%---------------------------------------------------------
    파일명 : header.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : javascript include
    작성자 : wcfw
-------------------------------------------------------------%>
<%
	String url = request.getRequestURL().toString().split("/")[2];

	String env = (String)request.getAttribute("env");
	if( !"prod".equals( env ) ) {
		env = "dev";
	}
	out.println("<script>");
	out.println("    var CONTEXT_PATH = \""+ request.getContextPath().replaceAll("/", "") +"\";");
	out.println("    var SERVER_URL  =  'http://" + url + "'; ");	
	//out.println("    var WS_URL       = 'ws://' + document.location.host; ");
	out.println("    var SYSTEM_ENV   = '" + request.getAttribute("env") + "';");
	out.println("    var SESSION_INTERVAL = " + session.getMaxInactiveInterval() + ";");
	out.println("    var Param = { debug : 'N' };");
	
	java.util.Enumeration<String> em = request.getParameterNames();
	while( em.hasMoreElements() ) {
		String key = em.nextElement();
		out.println("    Param[\""+ key +"\"] = \""+ request.getParameter(key)+"\";");
	}
	
	out.println("</script>");
%>

<c:set var="version" value="1.1.6"/>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/bootstrap-3.3.7-dist/css/bootstrap.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/bootstrap-3.3.7-dist/css/non-responsive.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/font-awesome-4.7.0/css/font-awesome.min.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/bootstrap-3.3.7-dist/css/awesome-bootstrap-checkbox.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/multiselect/jquery.multiselect.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/monthPicker/MonthPicker.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/jquery-ui-1.12.1/jquery-ui.min.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/jquery-ui-1.12.1/jquery-ui.theme.min.css?version=${version}">

<!-- <link rel="icon" href="${contextPath}/favicon.ico"> -->
<link href="${contextPath}/static/ext/daterangepicker/css/daterangepicker.css?version=${version}" rel="stylesheet">
<link href="${contextPath}/static/ext/codehighlight/styles/atom-one-light.css?version=${version}" rel="stylesheet">

<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/lgduxp/css/lgd-uxp-common.css?version=${version}">
<link rel="stylesheet" type="text/css"	href="${contextPath}/static/ext/lgduxp/css/lgd-uxp-style.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/lgduxp/css/lgd-uxp-helper.css?version=${version}">
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/fileupload-master/css/uploadfile.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/fileupload-master/css/uploadfile.custom.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/fullcalendar-3.0.0/fullcalendar.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/jquery.growl.js/stylesheets/jquery.growl.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/jstree/css/style.min.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/ext/syntaxhighlighter_3.0.83/styles/shCore.css?version=${version}"/>
<link rel="stylesheet" type="text/css"  href="${contextPath}/static/css/wcfw_common.css?version=${version}"/>

<script src="${contextPath}/static/ext/jquery-1.12.4.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/jquery-ui-1.12.1/jquery-ui.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/bootstrap-3.3.7-dist/js/bootstrap.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/bootbox.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/velocity.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/moment.min.js?version=${version}"></script>

<script src="${contextPath}/static/ext/date.js?version=${version}"></script>
<script src="${contextPath}/static/ext/validator/jquery.validate.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/jquery-validate.bootstrap-tooltip.min.js?version=${version}"></script>

<script src="${contextPath}/static/ext/cleave.js/dist/cleave-custom.js?version=${version}"></script>
<script src="${contextPath}/static/ext/Highcharts-5.0.0/js/highcharts.js?version=${version}"></script>
<script src="${contextPath}/static/ext/Highcharts-5.0.0/js/highcharts-more.js?version=${version}"></script>
<script src="${contextPath}/static/ext/Highcharts-5.0.0/js/modules/exporting.js?version=${version}"></script>

<script src="${contextPath}/static/ext/multiselect/src/jquery.multiselect_lgd_custom.js?version=${version}"></script>
<script src="${contextPath}/static/ext/multiselect/src/jquery.multiselect.filter_lgd_custom.js?version=${version}"></script>
<script src="${contextPath}/static/ext/monthPicker/MonthPicker.js?version=${version}"></script>

<script src="${contextPath}/static/ext/ajaxdownloader/jquery.fileDownload.js?version=${version}"></script>
<script src="${contextPath}/static/ext/ajaxdownloader/ajaxdownloader.min.js?version=${version}"></script>
<script src="${contextPath}/static/ext/codehighlight/highlight.pack.js?version=${version}"></script>

<script src="${contextPath}/static/ext/jqueryfileupload-9.19.1/js/vendor/jquery.ui.widget.js"></script>
<script src="${contextPath}/static/ext/jqueryfileupload-9.19.1/js/jquery.iframe-transport.js"></script>
<script src="${contextPath}/static/ext/jqueryfileupload-9.19.1/js/jquery.fileupload.js"></script>
<script src="${contextPath}/static/ext/prettyFloat.js-master/prettyFloat.min.js"></script>

<script src="${contextPath}/static/ext/jquery.growl.js/javascripts/jquery.growl.js"></script>
<script src="${contextPath}/static/ext/fullcalendar-3.0.0/fullcalendar.min.js"></script>
<script src="${contextPath}/static/ext/jstree/js/3.3.4/jstree.min.js?version=${version}"></script>

<script src="${contextPath}/static/ext/weblink-js/aes.js?version=${version}"></script>
<script async src="${contextPath}/static/ext/weblink-js/pbkdf2.js?version=${version}"></script>
<script async src="${contextPath}/static/ext/weblink-js/AesUtil.js?version=${version}"></script>
<script src="${contextPath}/static/ext/ckeditor_4.6.1/ckeditor.js"></script>

<% if( "prod".equals( request.getAttribute("env")+"" )  ){ %>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs-lic.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs.1.1.22.min.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/realgridjs-api.1.1.22.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/prod/jszip.min.js?version=${version}"></script>
<% } else { %>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs-lic.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs_eval.1.1.22.min.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/realgridjs-api.1.1.22.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/realgrid/dev/jszip.min.js?version=${version}"></script>
<% }%>

<%-- <link rel="stylesheet" type="text/css"	href="${contextPath}/static/css/base.css?version=${version}">
<link id="dimension" rel="stylesheet" type="text/css"	href="${contextPath}/static/css/dimension_small.css?version=${version}"> --%>


<script src="${contextPath}/static/ext/lgduxp/js/lgd-uxp-chart.js?version=${version}"></script>
<script src="${contextPath}/static/ext/lgduxp/js/lgd-uxp-ui.js?version=${version}"></script>
<script src="${contextPath}/static/js/currency.js?version=${version}"></script>
<script src="${contextPath}/static/js/framework_lib.js?version=${version}"></script>
<script src="${contextPath}/static/js/framework.js?version=${version}"></script>

<!-- LGD UXP UI 공통 스크립트 -->
<script src="${contextPath}/static/ext/daterangepicker/js/jquery.daterangepicker.js?version=${version}"></script>

<script type="text/javascript" src="${contextPath}/static/ext/crosseditor/js/namo_scripteditor.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/fileupload-master/js/jquery.form.js?version=${version}"></script>
<script type="text/javascript" src="${contextPath}/static/ext/fileupload-master/js/jquery.uploadfile.js?version=${version}"></script>


<!-- Session Info Variables -->
<%
	LGCOMMap user = LGCOMUtils.convertLGCOMMap(session.getAttribute("USER_SESSION"));

	if( user != null ) {
		out.println("<script>");
		out.println("var SESSION_USER = {");
		out.println("    applicationUserId : '" + user.get("applicationUserId") + "', ");
		out.println("    systemCode : '" + user.get("systemCode") + "', ");
		out.println("    employeeId : '" + user.get("employeeId") + "', ");
		out.println("    ssoId : '" + user.get("ssoId") + "', ");
		out.println("    mailAddr : '" + user.get("mailAddr") + "', ");
		out.println("    userName : '" + user.get("userName") + "', ");
		out.println("    titleName : '" + user.get("titleName") + "', ");
		out.println("    fullNameLocal : '" + user.get("fullNameLocal") + "', ");
		out.println("    languageCode : '" + user.get("languageCode") + "', ");
		out.println("    screenDesignThemeId : '" + user.get("screenDesignThemeId") + "', ");
		out.println("    defaultOrgShortCode : '" + user.get("defaultOrgShortCode") + "', ");
		out.println("    defaultOrgId : " + user.get("defaultOrgId") + ", ");
		out.println("    ouUseFlag : '" + user.get("ouUseFlag") + "', ");
		out.println("    departmentCode : '" + user.get("departmentCode") + "', ");
		out.println("    organizationName : '" + user.get("organizationName") + "', ");
		out.println("    serverTimeDifferenceSeqs : " + user.get("serverTimeDifferenceSeqs"));
		out.println("};");
		out.println("</script>");

		List<LGCOMMap> list = LGCOMUtils.convertLGCOMMapList(user.get("roleList"));
		out.println("<script>" );
		out.println("var USER_ROLE_LIST = ");
		Gson gson = new Gson();
		out.print( gson.toJson( list ) );
		out.print(";");
		out.println("</script>");
	}
%>

