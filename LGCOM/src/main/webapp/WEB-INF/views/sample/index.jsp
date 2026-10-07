<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : index.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : index Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>Sample</title>
<meta charset="utf-8"/>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>
<style type="text/css">
html, body {height:100%;}
body {padding:0px;margin:0px;}
.container {clear:both;width:100%;height:100%;display:block;}
.container ul#menu {float:left;width:200px;height:calc(100% - 20px);padding:10px 0px 10px 0px;margin:0px;border-right:2px solid #666;overflow-x:hidden;overflow-y:auto;}
.container ul#menu li {padding:5px 3px;margin-bottom:5px;}
.container ul#menu li a:link,
.container ul#menu li a:active,
.container ul#menu li a:visited {font-size:11pt;color:#666;text-decoration:none;display:block;}
.container ul#menu li a:hover {color:#ff9b00;}
.container iframe#view {float:right;width:calc(100% - 210px);height:100%;border:none;}
</style>
<script src="<c:url value="/static/ext/jquery-1.12.4.min.js"/>"></script>
<script type="text/javascript">
$(function() {
	$('ul#menu li a[data-path]').click(function() {
		$('#view').attr('src','<c:url value="/service/sample/'+$.trim($(this).data('path'))+'"/>');
	});
});
</script>
</head>

<body>
<div class="container">
	<ul id="menu">
		<li><a href="#" data-path="realGrid">Grid Sample</a></li>
		<li><a href="#" data-path="chartSample">Chart Sample</a></li>
		<li><a href="#" data-path="htmlSample">HTML Sample</a></li>
	</ul>
	<iframe id="view" frameborder="no" scrolling="auto"></iframe>
</div>
</body>
</html>
