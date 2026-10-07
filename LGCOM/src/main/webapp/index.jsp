<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%---------------------------------------------------------
    파일명 : index.jsp
    프로젝트명 : LGD WCFW Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 초기화면 
    작성자 : wcfw
-------------------------------------------------------------%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<title>WCFW Index</title>
<script type="text/javascript">
window.onload = function(){
	if( '<%=System.getProperty("env")%>' == 'prod'  ) {
		document.location.href ="/lgcom/login";
	} else {
		document.location.href ="/lgcom/service/login";
	}
}
</script>
</head>
</html>