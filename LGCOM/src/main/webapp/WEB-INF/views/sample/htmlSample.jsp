<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : htmlSample.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : HTML Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>Sample</title>
<meta charset="utf-8"/>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="X-UA-Compatible" content="IE=8"/>
<%@ include file="/WEB-INF/views/framework/header.jsp" %>
<script type="text/javascript">
$(function() {
	var valueSet = new ValueSet('lgcom');
	valueSet.add('fabCode',{valueSetId : 'INVEST_AMT_FAB_CODE', investCheckNo : 'IMS1608170001', versionSeqs : '1'});
	valueSet.execute();
	console.log(valueSet.get('fabCode'));
});
</script>
</head>

<body>
<div style="position:absolute;top:0px;left:0px;width:100px;height:100px;border:1px solid #000;">
</div>
<button title="Text">aaaa</button>
</body>
</html>
