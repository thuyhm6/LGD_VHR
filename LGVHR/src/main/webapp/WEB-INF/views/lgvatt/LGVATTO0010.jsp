<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATTO0010.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원의 월근태 Summary 를 Let's Portlet에서 조회하는 화면입니다.
    작성자 : 박귀희	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="T&A Summary"/></title>

<style type="text/css">

.actualTable > tbody > tr > th, 
.leaveTable  > tbody > tr > th { 
	background-color: #f8f8f8; 
	border-color: #c5c5c5; 
	border-style: solid solid solid solid; 
	border-width: 1px 1px 1px 1px; 
	text-align: center;
	font-weight: normal; 
	font-size: 11px; 
	padding: 2px 2px; 
	line-height: 150%;
}

.actualTable > tbody > tr > th.title, 
.leaveTable  > tbody > tr > th.title { 
	background-color: #e1e1e1; 
	border-color: #c5c5c5;
	text-align: left; 
	font-weight: normal; 
	font-size: 11px; 
	padding: 4px 5px;
	line-height: 16px;
}

.actualTable > tbody > tr > th span.lgd_red,
.leaveTable  > tbody > tr > th span.lgd_red {
	color: #f04e7d; 
}
.actualTable > tbody > tr > td, 
.leaveTable  > tbody > tr > td {
	border-color: #c5c5c5; 
	border-style: solid solid solid solid; 
	border-width: 1px 1px 1px 1px; 
	text-align: center; 
	padding: 2px 2px; 
	line-height: 150%;
}
</style>

<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

<script type="text/javascript">
var LGVATTO0010 = function() {
	var myForm = this;

	// Form Util 선언
	var actualFormUtil = new FormUtil( myForm, ".actualBlock" );
	var leaveFormUtil = new FormUtil( myForm, ".leaveBlock" );
	
	var timer;
	
	//계획/실적근태 및 근태 summary, 휴가 summary 조회
	function fncRetrieveAttendancePlanNResultList() {
		myForm.showProgress();
		transaction_sync("lgvhr", "lgvatt/LGVATTO0010/retrievePortletATTSummary", {}, function(data) {
			myForm.hideProgress();

			actualFormUtil.setValue(data.result);
			leaveFormUtil.setValue(data.result);
		});
	}
 
	//summary 영역 높이 조정
	function fncChangePosition() {
		var actualBlock = myForm.select(".actualBlock");
		var leaveBlock = myForm.select(".leaveBlock");

		actualBlock.css('top', 0);
		actualBlock.css('left', 0);
		actualBlock.css('right', 0);
		actualBlock.css('width', 300);
		
		leaveBlock.css('top', (Number(actualBlock.position().top) + Number(actualBlock.height()) + 10));
		leaveBlock.css('left', 0);
		leaveBlock.css('right', 0);
		leaveBlock.css('width', 300);

		$('._pageTitleWrapper').hide();

		var minHeight = Number(parseInt($('._pageTitleWrapper').css('height'), 10))	// 타이틀 높이 (px 제거)
					  + Number(leaveBlock.position().top)	// Actual 높이
					  + Number(leaveBlock.height())			// Leave 높이
					  + 10
					  ;

		$('main').css('height', minHeight);
		$('main').css('top', 0);
		$('main').css('left', 0);
		$('main ._contents').css('height', minHeight);

		$('main ._contents').css('top', 0);
		$('main ._contents').css('bottom', 0);
		$('main ._contents').css('left', 0);
		$('main ._contents').css('right', 0);
		$('main ._contents').css('min-height', minHeight);
	}

	//계획/실적근태 및 근태 summary, 휴가 summary 조회
	fncRetrieveAttendancePlanNResultList();

    // 화면 레이아웃 정의

	//summary 영역 위치 조정
	fncChangePosition();

	// BizWeb Timeout 방지위해, 일정시간마다 Refresh
	timer = setTimeout(function() { location.reload(); }, 1000*60*15);  // 1초 * 60 * 15 = 15분마다
}

LGVATTO0010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATTO0010();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">

 		<%-- Actual Summary 정보 --%>
		<div class="row actualBlock">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr><td align="right"><label><lgcom:message code="label.att.portletActualUnit"/></label></td></tr>  <%-- (unit: Hr) --%>
			</table>
			<table class="table table-condensed actualTable" summary="Actual Info">
				<colgroup>
					<col width="20%"></col>
					<col width="13%"></col>
					<col width="20%"></col>
					<col width="13%"></col>
					<col width="20%"></col>
					<col width="13%"></col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row" colspan="6" class="title"><label><lgcom:message code="label.att.portletActualTitle"/></label></th>  <%-- Actual <span class='lgd_red'>(Applied to your salary)<br>&nbsp;* If it is not correct,<br>&nbsp;&nbsp;Check your data in attendance system.</span> --%>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="label.att.portletActualNormalWork"/></label></th>  <%-- Normal<br>Work --%>
						<td colspan="5"><span name="normalWorkingHours"></span> (<span name="normalWorkingDays"></span> Days)</td>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="label.att.portletActualOTWeekday"/></label></th>  <%-- O/T<br>(Weekday) --%>
						<td><span name="otWeekdayHours"></span></td>
						<th scope="row"><label><lgcom:message code="label.att.portletActualOTHoliday"/></label></th>  <%-- O/T<br>(Holiday) --%>
						<td><span name="otHolidayHours"></span></td>
						<th scope="row"><label><lgcom:message code="label.att.portletActualOTPublic"/></label></th>  <%-- O/T<br>(Public) --%>
						<td><span name="otPublicHours"></span></td>
					</tr>
					<tr>
						<th scope="row"><label><lgcom:message code="label.att.portletActualLate"/></label></th>  <%-- Lateness<br>(-) --%>
						<td><span name="latenessHours"></span></td>
						<th scope="row"><label><lgcom:message code="label.att.portletActualLeavingEarly"/></label></th>  <%-- Leaving<br>early(-) --%>
						<td><span name="leavingEarlyHours"></span></td>
						<th scope="row"><label><lgcom:message code="label.att.portletActualGoingOut"/></label></th>  <%-- Going<br>Out(-) --%>
						<td><span name="goingOutHours"></span></td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //actual Block --%>
		
		<div class="row leaveBlock"><br>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr><td align="right"><label><lgcom:message code="label.att.portletLeaveUnit"/></label></td></tr>  <%-- (unit: Day) --%>
			</table>
			<table class="table table-condensed leaveTable" summary="leave Info">
				<colgroup>
					<col width="25%"></col>
					<col width="25%"></col>
					<col width="25%"></col>
					<col width="25%"></col>
				</colgroup>
				<tbody>
					<tr>
						<th scope="col" colspan="4" class="title"><label><lgcom:message code="label.att.portletLeaveTitle"/></label></th>  <%-- Annual Leave --%>
					</tr>
					<tr>
						<th scope="col"><label><lgcom:message code="label.att.portletLeaveTotal"/></label></th>  <%-- TOTAL --%>
						<th scope="col"><label><lgcom:message code="label.att.portletLeaveUsed"/></label></th>  <%-- Used --%>
						<th scope="col"><label><lgcom:message code="label.att.portletLeaveUnused"/></label></th>  <%-- Unused --%>
						<th scope="col"><label><lgcom:message code="label.att.portletLeaveUsedRate"/></label></th>  <%-- Used rate(%) --%>
					</tr>
					<tr>
						<td><span name="totalAnnualDays"></span></td>
						<td><span name="totalUsedDays"></span></td>
						<td><span name="totalUnusedDays"></span></td>
						<td><span name="totalUsedRate"></span></td>
					</tr>
				</tbody>
			</table>
		</div>
		<%-- //leaveBlock --%>
	</section>
</div>
</body>
</html>
