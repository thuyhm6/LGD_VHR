<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY10001.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여 시스템 어드민이 Global Value를 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.globalValue"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY10001 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",  left : 0, right : 0, top : 0 },
    	{ name : "button1Block", left : 0, right : 0, top : "searchBlock",  width : 600, bottom : "grid2Block"},
    	{ name : "grid1Block",   left : 0, right : 0, top : "button1Block", width : 600, bottom : 0},
    	{ name : "button2Block", left : "button1Block", right : 0, top : "searchBlock",  bottom : "grid2Block"},
    	{ name : "grid2Block",   left : "button1Block",   right : 0, top : "button2Block", bottom : 0}
    ]);
    
    // 그리드선언
	var grid1 = buildGrid(".LGVPAY10001_grid1");
	var grid2 = buildGrid(".LGVPAY10001_grid2");

    // 개인화조건
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR 
    
    // 코드 데이터 조회

    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    effectiveYyyymmdd: {required:true}
	    },
	    messages: {
	    	effectiveYyyymmdd: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='effectiveYyyymmdd'/>" />'}
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
					grid1.getGridBase().cancel();
					var param =  myForm.select(srchForm).toJSON();
					grid1.loadData("lgvhr", "lgvpay/LGVPAY10001/retrieveGlobalValueList", param );
					// Grid2 초기화
					grid2.getDataProvider().clearRows();
				}

				break;
				
			case "add1" :
				var cgrid = grid1.getGridBase();
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				var currCell = cgrid.getCurrent();
				cgrid.setValue(currCell.itemIndex,'payrollCalcVariableName', "");
				cgrid.setCurrent({column:'payrollCalcVariableName'});
				cgrid.setFocus();
				
				// 이력 목록 조회
				if(cgrid.getCurrent().itemIndex > -1) {
					var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
					retrieveGlobalValueHistoryList(grid2,rowData.payrollCalcVariableId);
				}
				break;
				
			case "delete1" :
				grid1.getGridBase().deleteSelection(true);
				grid1.getGridBase().setSelectOptions( {style : "rows"});
				break;

			case "save1" :
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( grid1.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				// 신규건인 경우 중복 체크
				var createdRows = fncArrangeMultiLineGrid(grid1.getGridBase(), "created");
				for (var i=0; i<createdRows.length; i++) {
					var result = fncCheckDuplicateGlobalValue(createdRows[i]["payrollCalcVariableName"]);
					//데이터가 있다 -> 중복이 있다의 의미
					if( result ){
						Message.error('<lgcom:message code="error.duplicateValue"/>');
						return ;
					}
				}
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					grid1.useProgress(true);
					grid1.saveChanges( "lgvhr", 'lgvpay/LGVPAY10001/saveGlobalValueList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;

			case "add2" :
				var cgrid = grid2.getGridBase();
				var egrid = grid1.getGridBase();
				var payrollCalcVariableId = egrid.getValue(egrid.getCurrent().itemIndex,'payrollCalcVariableId');

				//Global Value 가 없는 경우 행 추가 불가
				if($.trim(payrollCalcVariableId) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='payrollCalcVariableId'/>"/>');
					return;
				}
				
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}

				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				var currCell = cgrid.getCurrent();
				cgrid.setValue(currCell.itemIndex,'payrollCalcVariableId', payrollCalcVariableId);
				cgrid.setValue(currCell.itemIndex,'resultValue', "");
				cgrid.setValue(currCell.itemIndex,'effectiveStartYyyymmdd', "");
				cgrid.setValue(currCell.itemIndex,'effectiveEndYyyymmdd', DateUtil.format(DateUtil.parse("47121231", "YYYYMMDD"), "DD/MM/YYYY"));//종료일은 4712/12/31 기본값 셋팅
				cgrid.setFocus();
				break;
				
			case "delete2" :
				grid2.getGridBase().deleteSelection(true);
				grid2.getGridBase().setSelectOptions( {style : "rows"});
				break;

			case "save2" :
				try {
					grid2.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( grid2.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!grid2.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}

				/*
				//신규건인 경우 중복 체크
				var createdRows = fncArrangeMultiLineGrid(grid2.getGridBase(), "created");
				for (var i=0; i<createdRows.length; i++) {
					var result = fncCheckDuplicateGlobalValueHistory(createdRows[i]["payrollCalcVariableId"], createdRows[i]["effectiveStartYyyymmdd"]);
					//데이터가 있다 -> 중복이 있다의 의미
					if( result ){
						Message.error('<lgcom:message code="error.duplicateValue"/>');
						return ;
					}
				}*/
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					grid2.useProgress(true);
					grid2.saveChanges( "lgvhr", 'lgvpay/LGVPAY10001/saveGlobalValueHistoryList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						var egrid = grid2.getGridBase();
						var payrollCalcVariableId = egrid.getValue(egrid.getCurrent().itemIndex,'payrollCalcVariableId');
						retrieveGlobalValueHistoryList(grid2,payrollCalcVariableId);
					});
				});

				break;

		}
		event.stopPropagation();
	});
    
    // 그리드 초기화
	/*** 내부 함수  ***/
	// Global Value 이력 목록 조회
	function retrieveGlobalValueHistoryList(grid,payrollCalcVariableId) {
		var param = {
			payrollCalcVariableId: $.trim(payrollCalcVariableId)
		};
		grid.loadData("lgvhr","lgvpay/LGVPAY10001/retrieveGlobalValueHistoryList", param);
	}
    
    //Global Value 중복 체크
    function fncCheckDuplicateGlobalValue(payrollCalcVariableName) { 
		var rslt = false;
		myForm.transaction_sync( "lgvhr", "lgvpay/LGVPAY10001/retrieveGlobalValueDupChk", {payrollCalcVariableName:payrollCalcVariableName}, function(data){
			rslt = data.result;
		});
		return rslt;
    }
    
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".LGVPAY10001_grid1" :
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
							insertable: true,
							appendable: true,
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
					display: { fitStyle: 'evenFill' }
				});
		
				//필드 설정
				grid.setFields([
					{ fieldName:'payrollCalcVariableId'     , dataType:'text'  },
					{ fieldName:'payrollCalcVariableName'   , dataType:'text'  },
					{ fieldName:'detailDesc'                , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'payrollCalcVariableName',
						fieldName:'payrollCalcVariableName',
						width:150,
						header: {text:'<lgcom:message code="label.pay.globalValue"/>', required: true}
					},
					{
						name:'detailDesc',
						fieldName:'detailDesc',
						width:200,
						header: {text:'<lgcom:message code="Description"/>'}
					}
				]);
		
				grid.setValidations([
					{criteria: "value['payrollCalcVariableName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.globalValue'/>"/>',mode:'always',level:'error'}
				]);
				
				break;
			case ".LGVPAY10001_grid2" :
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
							insertable: true,
							appendable: true,
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
					{ fieldName:'payrollCalcVariableId'     , dataType:'text'  },
					{ fieldName:'resultValue'               , dataType:'text'  },
					{ fieldName:'effectiveStartYyyymmdd'    , dataType:'text'  },
					{ fieldName:'effectiveEndYyyymmdd'      , dataType:'text'  },
					{ fieldName:'oriEffectiveStartYyyymmdd' , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'resultValue',
						fieldName:'resultValue',
						width:300,
						header: {text:'<lgcom:message code="Value"/>', required: true}
					},
					{
						name:'effectiveStartYyyymmdd',
						fieldName:'effectiveStartYyyymmdd',
						width:130,
						header: {text:'<lgcom:message code="EffectiveStartDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					},
					{
						name:'effectiveEndYyyymmdd',
						fieldName:'effectiveEndYyyymmdd',
						width:130,
						header: {text:'<lgcom:message code="EffectEndDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					}
				]);

				// Validation Set		
				grid.setValidations([
					{criteria: "value['resultValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Value'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveStartYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectiveStartDate'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveEndYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectEndDate'/>"/>',mode:'always',level:'error'}
				]);				
				break;
		}
		grid.getGridBase().resetSize();
		return grid;
	}
	
	/* 그리드 이벤트 처리 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		if(grid2 && grid2.getGridBase()) grid2.getGridBase().cancel();
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
		
		// 신규행이 아니면 Global Value, Effective start date 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('payrollCalcVariableName','editable',false);
			myForm.select(".button1Block button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('payrollCalcVariableName','editable',true);
			myForm.select(".button1Block button[data-action='delete']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'payrollCalcVariableName','required');
		}
		// 이력 목록 조회
		if(cgrid.getCurrent().itemIndex > -1) {
			var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
			retrieveGlobalValueHistoryList(grid2,rowData.payrollCalcVariableId);
		}
	};

	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
		
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		var rstyle   = cgrid.addCellStyle('required',{background:'#ffffffaa'}, true);
		// 신규행이 아니면 Global Value, Effective start date 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('effectiveStartYyyymmdd','editable',true);
			cgrid.setColumnProperty('effectiveEndYyyymmdd','editable',true);
			myForm.select(".button2Block button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('effectiveStartYyyymmdd','editable',true);
			cgrid.setColumnProperty('effectiveEndYyyymmdd','editable',true);
			myForm.select(".button2Block button[data-action='delete']").removeAttr('disabled');
			//cgrid.setCellStyles(newRow,'resultValue','required');
			//cgrid.setCellStyles(newRow,'effectiveStartYyyymmdd','required');
		}
	};
	
	grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	grid2.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
}

LGVPAY10001.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY10001();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.globalValue"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120">
						<col width="200">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="label.pay.globalValue"/></label></th>
							<td><input type="text" class="form-control input-sm" name="payrollCalcVariableName"/></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		
		<%-- 마스터 그리드 버튼 --%>
		<div class="module-group text-right button1Block" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add1"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete1"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save1"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 마스터 그리드 --%>
		<div class="grid1Block grid-wrap">
			<div class="grid LGVPAY10001_grid1"></div>
		</div>
		<%-- 디테일 그리드 버튼 --%>
		<div class="module-group text-right button2Block" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete2"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save2" data-access="LGVPAY10001/saveGlobalValueHistoryList"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 디테일 그리드 --%>
		<div class="grid2Block grid-wrap">
			<div class="grid LGVPAY10001_grid2"></div>
		</div>
	</section>
</div>
</body>
</html>
