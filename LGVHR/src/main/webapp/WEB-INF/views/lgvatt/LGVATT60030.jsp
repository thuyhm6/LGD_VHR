<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT60030.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여시스템담당자가 급여의 모든 항목을 관리하는 화면입니다.
            신규 항목 생성 시 항목의 정의나 속성을 변경할 때 해당 화면을 사용한다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.att.payrollItemManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT60030 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	 
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "gridBlock" },
	    { name : "gridBlock",          left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);

   	srchFormUtil.setValue({effectiveDate:DateUtil.today("DD/MM/YYYY")});
   	srchFormUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    myForm.searchConditionControl( true );
    
    // 그리드선언
	var listGrid = buildGrid(".listGrid");
	
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]", function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		var gridBase = listGrid.getGridBase();
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					gridBase.cancel();
					//데이터 조회
					fncRetrievePayrollItemyList();
				}
				break;
			case 'directCSV':
				if(validator.isValid()) {
					var searchDate = srchFormUtil.getValue();
					srchFormUtil.setValue("searchDate", searchDate);
					
					Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
						var downloader = new Downloader( myForm );
						var param = srchFormUtil.getValue();
						param = $.extend(param, {languageCode:SESSION_USER.languageCode});
						downloader.csvDirectDownload("lgvhr", "LGVATT60030.createDirectCSVDownloadData", param);
					});
				}
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit', '.searchBlock form', function(event) {
		event.preventDefault();
	});
	
	/*** 내부 함수  ***/
	function fncSearchData() {
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
	}
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Context Menu Set
		grid.setContextMenu();
		// Grid Field Set
		grid.setFields([             
			{ fieldName:'employeeNo'             , dataType:'text'  },
			{ fieldName:'englishName'       , dataType:'text'  },
			{ fieldName:'logInDate'            , dataType:'text'  },
			{ fieldName:'shiftTypeCode'            , dataType:'text'  },
			{ fieldName:'aDayOfTheWeekCode'        , dataType:'text'  },
			{ fieldName:'inOutTypeNo'             , dataType:'text'  },
			{ fieldName:'actualWorkStartTime'   , dataType:'text'  },
			{ fieldName:'leavingOfficeTime'   , dataType:'text'  }
		]);
		//컬럼 콤보 셋팅
		grid.setLookups({
		});
		// Grid Column Set
		grid.setColumns([
    		{
   				name:'employeeNo',
   				fieldName:'employeeNo',
   				width:100,
   				header: {text:'<lgcom:message code="label.att.employeeNo"/>'},
   				editable: false
   			},
    		{
   				name:'englishName',
   				fieldName:'englishName',
				width:100,
   				header: {text:'<lgcom:message code="label.att.englishName"/>'},
   				editable: false
   			},
			{
				name:'inOutTypeNo',
				fieldName:'inOutTypeNo',
				width:100,
				header: {text:'<lgcom:message code="label.att.inOutTypeNo"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'logInDate',
				fieldName:'logInDate',
				width:150,
				header: {text:'<lgcom:message code="label.att.logInDate"/>', required: true},
			},
			{
				name:'shiftTypeCode',
				fieldName:'shiftTypeCode',
				width:100,
				header: {text:'<lgcom:message code="label.att.shiftTypeCode"/>', required: true},
			},
			{
				name:'aDayOfTheWeekCode',
				fieldName:'aDayOfTheWeekCode',
				width:100,
				header: {text:'<lgcom:message code="label.att.aDayOfTheWeekCode"/>', required: true},
			},
			{
				name:'actualWorkStartTime',
				fieldName:'actualWorkStartTime',
				width:100,
				header: {text:'<lgcom:message code="label.att.actualWorkStartTime"/>'},
				editable: false
			},
			{
				name:'leavingOfficeTime',
				fieldName:'leavingOfficeTime',
				width:100,
				header: {text:'<lgcom:message code="label.att.leavingOfficeTime"/>'},
				editable: false
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				select: 'block',
				paste    : { enabled: false }, /*paste 기능막기 */
				sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
	            sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {height: 30},
				fixed : {colCount : 4, resizable:true}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'none' }
		});
	
		return grid;
	}

	listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}

	function fncRetrievePayrollItemyList() {
		var cgrid = listGrid.getGridBase(); 
		cgrid.cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVATT60030/retrieveWorkingLateList", srchFormUtil.getValue(), function (data) {
		});
	}
}

LGVATT60030.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT60030();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.payrollItemManagement"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="150"></col>
						<col width="180"></col>
						<col width="140"></col>
						<col width="180"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.att.effectiveDate" /></label></th>
							<td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require size_80" name="effectiveDate" placeholder="dd/mm/yyyy" readonly />
								    <button type="button" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
							</td>
							
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
<div class="gridControls module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">	
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
			</div>			
		</div>		
			</form>
		</div>		
		
		<div class="gridBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
				

	</section>
</div>
</body>
</html>