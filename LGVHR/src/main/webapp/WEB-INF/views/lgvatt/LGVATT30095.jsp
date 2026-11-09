<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT30095.jsp
    프로젝트명 : VHR LGD

    설 명 : T&A Check Report (Excel Download)
    작성자 : HMT
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>T&A Check Report</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT30095 = function(){
    var _this = this;
    var myForm = this;
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    var searchForm = new FormUtil(_this, '.search-wrap');

    var dateFrom = DateUtil.format(DateUtil.today().set('date',1), 'DD/MM/YYYY');
    var dateTo = DateUtil.format(DateUtil.today().add(1,'month').set('date',1).add(-1,'day'), 'DD/MM/YYYY');
    searchForm.setValue( {
    	atendanceStartDate : dateFrom,
        atendanceEndDate : dateTo
    });
    searchForm.setCalendar( { from : "atendanceStartDate", to : "atendanceEndDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );

    /* Layout Setting */
	myForm.setLayout( [
		{ name  : "searchBlock", left : 0, right : 0, top : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅
    myForm.searchConditionControl( true );
	// serachBlock combo
	var code = new CommonCode('lgcom');
	code.add('reportName', {codeTypeCode:'LGVHR_ATT_REPORT_CHECK'});
	code.execute();

	formUtil.initCombo('reportName', code.get('reportName'));

	/*** 이벤트 핸들러  ***/

	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
            // excel download
		    case "excelDown" :
		    	var param =  myForm.select(".searchBlock form").toJSON();

		    	if ( nvl(param.atendanceStartDate) == "" || nvl(param.atendanceEndDate) == "" ) {
		    		Message.alert("Please input Start Date and End Date.");
		    		return;
		    	}
		    	if ( nvl(param.reportName) == "" ) {
		    		Message.alert("Please select Report Name.");
		    		return;
		    	}

				Message.confirm( "<lgcom:message code='question.excelDownload' />", function(){
					var downloader = new Downloader( myForm );
				    downloader.excel( "lgvhr", "lgvatt/LGVATT30095/excelDownData", param );
				});
		    	break;
		}
	});
}

LGVATT30095.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT30095();
		form.init();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<div class="pageHeader">
		    <h2>T&amp;A Check Report</h2>
		</div>

		<div class="searchBlock">
		    <form class="form search-wrap">
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90"/>
							<col width="220"/>
							<col width="90" />
							<col width="250"/>
							<col width="*"  />
						</colgroup>
						<tbody>
			                <tr>
			                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.date"/></label></th>
			                    <td>
			                        <div class="form-inline">
	                                <input type="text" class="form-control input-sm input-require" name="atendanceStartDate" id="<c:out value="${ui_bizform_id}"/>_atendanceStartDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
	                                ~
	                                <input type="text" class="form-control input-sm input-require" name="atendanceEndDate" id="<c:out value="${ui_bizform_id}"/>_atendanceEndDate" placeholder="dd/mm/yyyy" style="width: 85px;" maxlength="10" onkeyup="return auto_date_format(event, this)" onkeypress="auto_date_format(event, this)">
	                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
	                            	</div>
		                        </td>

								<th><label class="required"><i class="asterisk">*</i>Report Name</label></th>
								<td><select class="form-control input-sm input-require" name="reportName"></select></td>

								<td></td>
			                </tr>
						</tbody>
					</table>
				</fieldset>
				<button class="btn btn-default btn-sm btn-search" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
		    </form>
		</div>
	</section>
</div>
</body>
</html>
