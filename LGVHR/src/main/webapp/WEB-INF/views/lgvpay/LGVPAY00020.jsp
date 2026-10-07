<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00020.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : User Defined Table Value Summary 조회하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.userDefindTableValueSummary"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00020 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock", left : 0, right : 0, top : 0 },
    	{ name : "buttonBlock", left : 0, right : 0, top : "searchBlock", bottom : "gridBlock"},
    	{ name : "gridBlock",   left : 0, right : 0, top : "buttonBlock", bottom : 0}
    ]);

    // 개인화조건
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의
	myForm.popupInfo = {
		detailPopup : { row:'', col:'', detailData:[] }
	};

    // 그리드형 테이블 TR 
    
    // 코드 데이터 조회
	var valueset = new ValueSet("lgcom");
    valueset.add("udtTableList", {valueSetId : "LGVPAY_UDT_TABLE_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table List
    valueset.add("udtTableColList", {valueSetId : "LGVPAY_UDT_TABLE_COL_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table Col List
	valueset.execute();
    
    //콤보값 셋팅
    formUtil.initCombo("tableSeqNo", valueset.get("udtTableList"), {selectEmpty:true});
    formUtil.initCombo("columnSeqNo", valueset.get("udtTableColList"), {selectEmpty:true, filter:"tableSeqNo"});
    formUtil.setValue({effectiveDate:DateUtil.today("DD/MM/YYYY")});
    
    // 그리드선언
	var listGrid = buildGrid(".listGrid");

    // 날짜 팝업창
    formUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    tableSeqNo: {required:true}
 	      , columnSeqNo: {required:true}
 	      , effectiveDate: {required:true}
	    },
	    messages: {
	    	tableSeqNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.tableName'/>" />'}
	      , columnSeqNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.columnKey'/>" />'}
	      , effectiveDate : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.effectiveDate'/>" />'}
	    }
    });

    // 일반함수

    // Event 처리
	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					listGrid.getGridBase().cancel();
					listGrid.loadData("lgvhr", "lgvpay/LGVPAY00020/retrieveUserDefineTableValueSummaryList", formUtil.getValue());
				}
				break;
		}
		event.stopPropagation();
	});
    
    //UDT Table명 변경 시 그리드 컬럼 조정
	myForm.addEvent( "change", ".searchBlock .form select" , function(event) {
		var item = $(event.target);
		
		switch($.trim(item.attr("name"))) {
			case "tableSeqNo":
				//Grid 초기화
				listGrid.getDataProvider().clearRows();
				
				if ( !isNull(formUtil.getValue("tableSeqNo")) ) {//UDT Table Name있는 경우 Row Grid 컬럼 visible 수정, Row Grid 재조회
					
					//Match Type=M(Match) 인 경우 lowerBound header Title 변경, upperBound 숨김
					if ( valueset.get("udtTableList").findIndex(function(item) {return (item.code == formUtil.getValue("tableSeqNo") && item.dataManagementWayCode == "M") }) > -1 ) {
						listGrid.getGridBase().setColumnProperty("lowerLimitCriticalValue", "header", "<lgcom:message code="label.pay.exact"/>");
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "header", {text:" "});
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "visible", false);
					} else {
						listGrid.getGridBase().setColumnProperty("lowerLimitCriticalValue", "header", "<lgcom:message code="label.pay.lowerBound"/>");
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "header", {text:"<lgcom:message code="label.pay.upperBound"/>"});
						listGrid.getGridBase().setColumnProperty("upperLimitCriticalValue", "visible", true);
					}

					//클릭이벤트 호출
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				}
				break;
				
			case "columnSeqNo":
				//Grid 초기화
				listGrid.getDataProvider().clearRows();

				//클릭이벤트 호출
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				break;
				
			case "effectiveDate":
				//Grid 초기화
				listGrid.getDataProvider().clearRows();
				
				//클릭이벤트 호출
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				break;
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".listGrid" :
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:false},
						stateBar: {visible:true},
						footer: {visible:false},
						select: 'block',
						paste    : { enabled: false }, /*paste 기능막기 */
						sorting  : { enabled: false }, /*Sorting 기능을 막는다.*/
		                sortMode : "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: true,
							deletable: true
						},
						header: {
							height: 30
						}
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
		
				//필드 설정
				grid.setFields([
					{ fieldName:'tableSeqNo'                , dataType:'number'},
					{ fieldName:'tableName'                 , dataType:'text'  },
					{ fieldName:'rowNo'                     , dataType:'number'},
					{ fieldName:'sortOrderNo'               , dataType:'number'},
					{ fieldName:'lowerLimitCriticalValue'   , dataType:'text'  },
					{ fieldName:'upperLimitCriticalValue'   , dataType:'text'  },
					{ fieldName:'tableCellId'               , dataType:'number'},
					{ fieldName:'tableCellValue'            , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({ });
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'lowerLimitCriticalValue',
						fieldName:'lowerLimitCriticalValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.lowerBound"/>'},
						editable: false
					},
					{
						name:'upperLimitCriticalValue',
						fieldName:'upperLimitCriticalValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.upperBound"/>'},
						editable: false
					},
					{
						name:'tableCellValue',
						fieldName:'tableCellValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.value"/>'},
						editable: false
					},
				]);
				break;
		}
		return grid;
	}
	/* 그리드 이벤트 처리 */
}

LGVPAY00020.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00020();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.userDefindTableValueSummary"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120">
						<col width="220">
						<col width="120">
						<col width="160">
						<col width="120">
						<col width="070">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.tableName"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="tableSeqNo" ></select></td>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.columnKey"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="columnSeqNo" ></select></td>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.effectiveDate" /></label></th>
							<td>
								<span class="form-inline">
								    <input type="text" class="form-control input-sm input-require size_80" name="effectiveDate" placeholder="dd/mm/yyyy" readonly />
								    <button type="button" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
								</span>
							</td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- User Defined Table Value Summary 그리드 버튼 --%>
		<div class="module-group text-right buttonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
				</div>
			</div>
		</div>
		<%-- User Defined Table Row 그리드 --%>
		<div class="gridBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
