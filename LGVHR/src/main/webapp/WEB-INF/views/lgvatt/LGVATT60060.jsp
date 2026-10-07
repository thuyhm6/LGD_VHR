<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld"%>
<%---------------------------------------------------------
    파일명 : LGVATT60060.jsp

   Copyright(c) 2024 LG CNS,  All rights reserved..

    설 명 : 급여실적 일괄다운로드
    작성자 : sangnv
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp"%>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT60060 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );

   	var validator = new Validator( myForm, srchForm );
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" }
   	        	]);
   	srchFormUtil.setValue( {
    	fromDate : DateUtil.format(DateUtil.today().add(-1,'month'), 'DD/MM/YYYY'),
    	toDate : DateUtil.today("DD/MM/YYYY")
    });

   	srchFormUtil.setCalendar( { from : "fromDate", to : "toDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
   	
   	srchFormUtil.setValue( {
    	fromDate2 : DateUtil.format(DateUtil.today().add(-1,'month'), 'DD/MM/YYYY'),
    	toDate2 : DateUtil.today("DD/MM/YYYY")
    });

   	srchFormUtil.setCalendar( { from : "fromDate2", to : "toDate2", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
   	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		case 'directCSV':
			Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
				
				var options = {
						multiSheet: true
				};
				var downloader = new Downloader( myForm, options );
				// 임시로 처리 하는거임
				var param = {
						toDateActual : srchFormUtil.getValue('toDate'),
						fromDateActual : srchFormUtil.getValue('fromDate'),
						toDatePlan : srchFormUtil.getValue('toDate2'),
						fromDatePlan : srchFormUtil.getValue('fromDate2'),
						report : [
									{
										sheetName : 'Actual'
									},
									{
										sheetName : 'Plan'
									}
								]
				};
				downloader.excel("lgvhr", "lgvatt/LGVATT60060/createExcelActualPlan", param );
			}, function(){
				
			});
			break;
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
}

LGVATT60060.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT60060();
		form.init();
	});
});
</script>
</head>

<body>
	<div class="mdi-container">
		<section class="page-content">
			<div class="pageHeader">
				<h2></h2>
			</div>
			<div class="searchBlock">
				<form class="form search-wrap">
					<table class="table">
						<colgroup>
							<col width="120"></col>
							<col width="110"></col>
							<col width="160"></col>
							<col width="200"></col>
							<col width="100"></col>
							<col width="200"></col>
						</colgroup>
						<tbody>
							<tr>
								<th><label class="required"><i class="asterisk">*</i>
									<lgcom:message code="label.att.actualDate" /></label></th>
								<td>
									<div class="form-inline ">
										<input type="text" class="form-control input-sm input-require"
											name="fromDate" id="fromDate" placeholder="dd/mm/yyyy"
											readonly> ~ <input type="text"
											class="form-control input-sm input-require" name="toDate"
											id="toDate" placeholder="dd/mm/yyyy" readonly>
										<button type="button" id="setSingleDateSample"
											class="btn btn-ico" aria-label="calendar">
											<span class="ico ico-calendar" aria-hidden="true"></span>
										</button>
									</div>
								</td>

								<th><label class="required"><i class="asterisk">*</i>
									<lgcom:message code="label.att.planDate" /></label></th>
								<td>
									<div class="form-inline ">
										<input type="text" class="form-control input-sm input-require"
											name="fromDate2" id="fromDate2" placeholder="dd/mm/yyyy"
											readonly> ~ <input type="text"
											class="form-control input-sm input-require" name="toDate2"
											id="toDate2" placeholder="dd/mm/yyyy" readonly>
										<button type="button" id="setSingleDateSample"
											class="btn btn-ico" aria-label="calendar">
											<span class="ico ico-calendar" aria-hidden="true"></span>
										</button>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
					<%-- <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button> --%>
				</form>
			</div>
			<%-- 그리드 버튼 영역 --%>
			<div class="gridControls module-group text-right">
				<div class="btn-toolbar">
					<div class="btn-group">
						<button type="button" class="btn btn-default btn-sm"
							data-action="directCSV">
							<span class="ico ico-excel-down" aria-hidden="true"></span>
							DirectCSV
						</button>
					</div>
				</div>
			</div>
		</section>
	</div>
</body>
</html>
