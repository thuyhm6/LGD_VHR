<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
    파일명 : loginAllowFilter.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 로그인 정보를 입력받는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<%
	java.util.List<String> allowAddr = new java.util.ArrayList<String>();
	allowAddr.add("10.118.177.124"); //송성근총괄
	allowAddr.add("10.118.185.93");//이종훈B

	String clientAddr = request.getRemoteAddr();
	if("localhost".equals(clientAddr) || "127.0.0.1".equals(clientAddr)) {
		clientAddr = java.net.InetAddress.getLocalHost().getHostAddress();
	}
	boolean isAllowAddr = false;
	for(String addr: allowAddr) {
		if(clientAddr.equals(addr)) {
			isAllowAddr = true;
			break;
		}
	}
	if(isAllowAddr) {
%>
<style type="text/css">
.logon_panel {position:absolute;top:0px;right:0px;/*width:300px;*/}
.logon_table {width:100%;border-spacing:2px;border-collapse:collapse;}
.logon_table>thead>tr>th {padding:1px;border:1px solid #000;text-align:center;}
.logon_table>tbody>tr>td {padding:1px;border:1px solid #000;text-align:center;}
.radio label {padding-left:10px;}
</style>
<script type="text/javascript">
$(function() {
	$('.logon_table tbody tr').mouseover(function() {
		$(this).css('background-color','#fff');
		$(this).css('cursor','pointer');
	}).mouseout(function() {
		$(this).css('background-color','');
	}).click(function() {
		var uId = $.trim($(this).find('td:nth-child(4)').html());
		var uPw = $.trim($(this).find('td:nth-child(4)').attr('passwd'));
<%if("sso".equalsIgnoreCase(request.getParameter("type"))){%>
		$("#loginForm input[name='iv-user']").val(uId);
<%}else if("login".equalsIgnoreCase(request.getParameter("type"))){%>
		$("#loginForm input[name='userName']").val(uId);
<%}%>
		$("#loginForm input[name='password']").val(uPw);
		$("#loginForm button.btn").trigger('click');
	});
});
</script>
<div class="logon_panel">
<%if("sso".equalsIgnoreCase(request.getParameter("type"))){%>
	<table class="logon_table table">
		<colgroup>
			<col width="60"/>
			<col width="60"/>
			<col width="80"/>
			<col width="80"/>
		</colgroup>
		<thead>
			<tr>
				<th>System</th>
				<th>Module</th>
				<th>Name</th>
				<th>Emp No.</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>LGCOM</td>
				<td></td>
				<td>송성근</td>
				<td passwd="x030807">sskeun</td>
			</tr>
		</tbody>
	</table>
<%}else if("login".equalsIgnoreCase(request.getParameter("type"))){%>
	<table class="logon_table">
		<colgroup>
			<col width="60"/>
			<col width="60"/>
			<col width="80"/>
			<col width="80"/>
		</colgroup>
		<thead>
			<tr>
				<th>System</th>
				<th>Module</th>
				<th>Name</th>
				<th>Emp No.</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>LGCOM</td>
				<td></td>
				<td>송성근</td>
				<td passwd="x030807">x030807</td>
			</tr>
		</tbody>
	</table>
<%}%>
</div>
<%}%>
