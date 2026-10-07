<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<html>
<title>DebugWin</title>
<meta charset="UTF-8">
<meta http-equive="Cache-Control" content="no-cache;no-store;no-save">
<meta http-equive="Expires" content="-1">
<meta http-equive="X-UA-Compatible" content="IE-EDGE">
<head>
<style type="TEXT/CSS">
#logView {
    position : absolute;
    top : 30px;
    left : 0px;
    right : 0px;
    bottom : 0px;
	font-size:12px;
    overflow: auto;
    border : 1px solid #C5C5C5;
}

.clear {
    position : absolute;
    top : 5px;
    left : 5px;
	font-size:12px;
    overflow: auto;
 }


</style>
</head>
<body>
<input class="clear" type="button" value="Clear" onClick="document.getElementById('logView').innerHTML = '';"><br/><br/>
<div id="logView"></div>
</body>
</html>