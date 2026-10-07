<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00014.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여 계산식을 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.formulaManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00014 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",       left : 0, right : 0, top : 0 },
    	{ name : "masterButtonBlock", left : 0, right : 0, top : "searchBlock",  width : 500, bottom : "detailGridBlock"},
    	{ name : "masterGridBlock",   left : 0, right : 0, top : "masterButtonBlock", width : 500, bottom : 0},
    	{ name : "detailButtonBlock", left : "masterButtonBlock", right : 0, top : "searchBlock",  bottom : "detailGridBlock"},
    	{ name : "detailGridBlock",   left : "masterButtonBlock", right : 0, top : "detailButtonBlock", bottom : 0}
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
	var code = new CommonCode("lgcom");
    code.add( "parameterTypeList", {codeTypeCode:'LGDVHR_PAY_PARAMETER_TYPE_CODE'});
    code.add( "dataTypeList", {codeTypeCode:'LGDVHR_PAY_DATA_TYPE_CODE'});
	code.execute();
    
    // 그리드선언
	var masterGrid = buildGrid(".masterGrid");
	var detailGrid = buildGrid(".detailGrid");

    // 날짜 팝업창
    
    // 필수항목 체크

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
				masterGrid.getGridBase().cancel();
				masterGrid.loadData("lgvhr", "lgvpay/LGVPAY00014/retrieveFormulaList", formUtil.getValue() );
				// detail grid 초기화
				detailGrid.getDataProvider().clearRows();
				break;
				
			case "add1" :
				var mgrid = masterGrid.getGridBase();
				try {
					mgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if(mgrid.getCurrent().itemIndex < 0) {
					mgrid.beginAppendRow();
				} else {
					mgrid.beginInsertRow(mgrid.getCurrent().itemIndex);
				}
				var currCell = mgrid.getCurrent();
				var itemIndex = currCell.itemIndex;
				mgrid.setCurrent({column:'payrollCalcFormulaValue'});
				mgrid.setFocus();

				// detail grid 초기화
				detailGrid.getDataProvider().clearRows();
				// detail 목록 조회
				if ( itemIndex.itemIndex > -1 && !isNull(mgrid.getValue(itemIndex, "payrollCalculationFormulaId")) ) {
					fncRetrieveFormulaDetailList(mgrid.getValue(itemIndex, "payrollCalculationFormulaId"));
				}
				break;
				
			case "delete1" :
				var mGrid = masterGrid.getGridBase();
				var itemIndex = mGrid.getCurrent().itemIndex;
				if ( nvl(mGrid.getValue(itemIndex, "deleteEnableFlag"), "N") == "N" ) {//급여항목에 이미 등록된 경우 삭제 불가
					Message.alert("<lgcom:message code="note.pay.deleteAlreadyExistsPayrollItem" />");
					return ;
				} else {
					mGrid.deleteSelection(true);
					mGrid.setSelectOptions( {style : "rows"});
				}
				break;

			case "save1" :
				try {
					masterGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( masterGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!masterGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장 전 체크
				if ( !fncValidateSaveFormula() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					masterGrid.useProgress(true);
					masterGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00014/saveFormulaList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;

			case "add2" :
				var dgrid = detailGrid.getGridBase();
				var payrollCalculationFormulaId = fncRetrievePayrollCalcFormulaId();

				//Formula 가 없는 경우 행 추가 불가
				if($.trim(payrollCalculationFormulaId) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.formulaProgram'/>"/>');
					return;
				}
				
				try {
					dgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}

				if(dgrid.getCurrent().itemIndex < 0) {
					dgrid.beginAppendRow();
				} else {
					dgrid.beginInsertRow(dgrid.getCurrent().itemIndex);
				} 
				var currCell = dgrid.getCurrent();
				dgrid.setValue(currCell.itemIndex, 'payrollCalculationFormulaId', payrollCalculationFormulaId);
				dgrid.setFocus();
				break;
				
			case "delete2" :
				detailGrid.getGridBase().deleteSelection(true);
				detailGrid.getGridBase().setSelectOptions( {style : "rows"});
				break;

			case "save2" :
				try {
					detailGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( detailGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!detailGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장전 체크
				if ( !fncValidateSaveFormulaDetail() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					detailGrid.useProgress(true);
					detailGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00014/saveFormulaDetailList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						fncRetrieveFormulaDetailList(fncRetrievePayrollCalcFormulaId());
					});
				});
				break;
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	// Formula Detail 목록 조회
	function fncRetrieveFormulaDetailList(payrollCalculationFormulaId) {
		detailGrid.loadData("lgvhr","lgvpay/LGVPAY00014/retrieveFormulaDetailList", { payrollCalculationFormulaId: $.trim(payrollCalculationFormulaId) });
	}
	
	//payrollCalculationFormulaId 조회
	function fncRetrievePayrollCalcFormulaId() {
		return masterGrid.getGridBase().getValue(masterGrid.getGridBase().getCurrent().itemIndex, 'payrollCalculationFormulaId');
	}
    
	//Formula 저장 전 체크
	function fncValidateSaveFormula() {
		var cgrid = masterGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		return true;
	}
    
	//Formula Detail 저장 전 체크
	function fncValidateSaveFormulaDetail() {
		var cgrid = detailGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var payrollCalucaltionFormulaId = fncRetrievePayrollCalcFormulaId();
		var sMsg = "";
		
		//신규 건 또는 수정건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		for ( var i=0; i<rowIdxs.length; i++ ) {
			var rowData = provider.getJsonRow(rowIdxs[i]);
			//out 변수인 경우 payrollItemId, payrollItemDetailDetailId 필수 체크
			if ( nvl(rowData.parameterIoTypeCode) == "OUT" 
					&& (isNull(rowData.payrollItemId) || isNull(rowData.payrollItemDetailDetailId)) ) {
				Message.alert("<lgcom:message code="note.pay.emptyPayrollItemOrPayrollItemDetail" />");
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"payrollItemDetailName"});
				cgrid.setFocus();
				return false;
			}
		}
		return true;
	}

	//parent payroll item Detail popup호출
	function fncPopupPayrollItemDetail(itemIndex, colName) {
		var popupData = myForm.popupInfo.detailPopup;
		popupData.row        = itemIndex;
		popupData.col        = colName;
		popupData.detailData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1038','<lgcom:message code="label.pay.payrollItemDetail"/>');
		popup.setSize(812, 512);
		popup.open(function() {
			if ( popupData.detailData != undefined && popupData.detailData.length > 0 ) {
				var selectData = popupData.detailData[0];
				detailGrid.getGridBase().setValue(popupData.row, "payrollItemId"            , selectData.payrollItemId);
				detailGrid.getGridBase().setValue(popupData.row, "payrollItemName"          , selectData.inquiryName);
				detailGrid.getGridBase().setValue(popupData.row, "payrollItemDetailDetailId", selectData.payrollItemDetailDetailId);
				detailGrid.getGridBase().setValue(popupData.row, "payrollItemDetailName"    , selectData.additionalInputValue);
				detailGrid.getGridBase().setValue(popupData.row, "payCalcRsltDetailTypeCode", selectData.payCalcRsltDetailTypeCode);
				detailGrid.getGridBase().commit();
			}
		});
	}
	
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".masterGrid" :
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
					{ fieldName:'payrollCalculationFormulaId', dataType:'number'},
					{ fieldName:'payrollCalcFormulaValue'    , dataType:'text'  },
					{ fieldName:'deleteEnableFlag'           , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'payrollCalcFormulaValue',
						fieldName:'payrollCalcFormulaValue',
						width:420,
						header: {text:'<lgcom:message code="label.pay.formulaProgram"/>', required: true}
					}
				]);
		
				grid.setValidations([
					{criteria: "value['payrollCalcFormulaValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.formulaProgram'/>"/>',mode:'always',level:'error'}
				]);
				
				break;
			case ".detailGrid" :
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
					{ fieldName:'payrollCalculationFormulaId', dataType:'number'},
					{ fieldName:'sortOrderNo'                , dataType:'number'},
					{ fieldName:'oriSortOrderNo'             , dataType:'number'},
					{ fieldName:'parameterIoTypeCode'        , dataType:'text'  },
					{ fieldName:'parameterIoTypeName'        , dataType:'text'  },
					{ fieldName:'parameterValue'             , dataType:'text'  },
					{ fieldName:'dataTypeCode'               , dataType:'text'  },
					{ fieldName:'dataTypeName'               , dataType:'text'  },
					{ fieldName:'payrollItemId'              , dataType:'number'},
					{ fieldName:'payrollItemName'            , dataType:'text'  },
					{ fieldName:'payrollItemDetailDetailId'  , dataType:'number'},
					{ fieldName:'payrollItemDetailName'      , dataType:'text'  },
					{ fieldName:'payCalcRsltDetailTypeCode'  , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({
					parameterTypeList : code.get("parameterTypeList")
				  , dataTypeList : code.get("dataTypeList")
				});
				//컬럼 설정
				grid.setColumns([
					{
						name:'sortOrderNo',
						fieldName:'sortOrderNo',
						width:60,
						header: {text:'<lgcom:message code="SortOrder"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#,##0'}
					},
					{
						name:'parameterIoTypeCode',
						fieldName:'parameterIoTypeCode',
						width:80,
						type: 'data',
						header: {text:'<lgcom:message code="label.pay.parameterType"/>', required: true},
						styles: {textAlignment:'center'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'parameterTypeList',
						lookupKeyFields: ['parameterIoTypeCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					},
					{
						name:'parameterValue',
						fieldName:'parameterValue',
						width:270,
						header: {text:'<lgcom:message code="ParameterName"/>', required: true},
						renderer: {showTooltip: true},
					},
					{
						name:'dataTypeCode',
						fieldName:'dataTypeCode',
						width:90,
						type: 'data',
						header: {text:'<lgcom:message code="DataType"/>', required: true},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'dataTypeList',
						lookupKeyFields: ['dataTypeCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					},
					{
						name:'payrollItemName',
						fieldName:'payrollItemName',
						width:270,
						header: {text:'<lgcom:message code="label.pay.payrollItemName"/>'},
						renderer: {showTooltip: true},
						editable: false
					},
					{
						name:'payrollItemDetailName',
						fieldName:'payrollItemDetailName',
						width:300,
						header: {text:'<lgcom:message code="label.pay.payrollItemDetailName"/>', required: true},
						renderer: {showTooltip: true},
						button: 'action',
						buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
					}
				]);

				// Validation Set		
				grid.setValidations([
					{criteria: "value['sortOrderNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='SortOrder'/>"/>',mode:'always',level:'error'},
					{criteria: "value['parameterIoTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.parameterType'/>"/>',mode:'always',level:'error'},
					{criteria: "value['parameterValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ParameterName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['dataTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='DataType'/>"/>',mode:'always',level:'error'}
				]);				
				break;
		}
		return grid;
	}
	/* 그리드 이벤트 처리 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	masterGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		detailGrid.getGridBase().cancel();
		detailGrid.getDataProvider().clearRows();
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		
		// 신규행이 아니면 Formula 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('payrollCalcFormulaValue','editable',false);
			myForm.select(".masterButtonBlock button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('payrollCalcFormulaValue','editable',true);
			myForm.select(".masterButtonBlock button[data-action='delete']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'payrollCalcFormulaValue','required');
		}
		// detail 목록 조회
		var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
		if ( cgrid.getCurrent().itemIndex > -1 && !isNull(rowData.payrollCalculationFormulaId) ) {
			fncRetrieveFormulaDetailList(rowData.payrollCalculationFormulaId);
		}
	};
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	detailGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
	};
	//그리드 팝업버튼 클릭시 이벤트
	detailGrid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		
		fncPopupPayrollItemDetail(itemIndex, column.name);
	};
	//입력값이 셀에 반영될 때 이벤트
	detailGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		//급여항목Detail명 삭제 또는 변경 시 급여항목Detail ID, 급여항목명, 급여항목ID 값 모두 삭제 처리함.
		if ( index.fieldName == "payrollItemDetailName" 
				&& (isNull(newValue) || nvl(oldValue) != nvl(newValue) ) ) {
			cgrid.setValue(index.itemIndex, "payrollItemId", null);
			cgrid.setValue(index.itemIndex, "payrollItemName", "");
			cgrid.setValue(index.itemIndex, "payrollItemDetailDetailId", null);
			cgrid.setValue(index.itemIndex, "payrollItemDetailName", newValue);
			cgrid.setValue(index.itemIndex, "payCalcRsltDetailTypeCode", "");
			cgrid.commit();
		}
	};
	masterGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	detailGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
}

LGVPAY00014.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00014();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.formulaManagement"/></h2>
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
							<th><label><lgcom:message code="label.pay.formulaProgram"/></label></th>
							<td><input type="text" class="form-control input-sm" name="payrollCalcFormulaValue"/></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 마스터 그리드 버튼 --%>
		<div class="module-group text-right masterButtonBlock" >
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
		<div class="masterGridBlock grid-wrap">
			<div class="grid masterGrid"></div>
		</div>
		<%-- 디테일 그리드 버튼 --%>
		<div class="module-group text-right detailButtonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete2"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save2"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- 디테일 그리드 --%>
		<div class="detailGridBlock grid-wrap">
			<div class="grid detailGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
