<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00019.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : User Defined Table Value 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.userDefinedTableValue"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00019 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",      left : 0, right : 0, top : 0 },
    	{ name : "valueButtonBlock", left : 0, right : 0, top : "searchBlock", bottom : "valueGridBlock"},
    	{ name : "rowGridBlock",     left : 0, top : "valueButtonBlock", width : 850, bottom : 0},
    	{ name : "valueGridBlock",   left : "rowGridBlock", right : 0, top : "valueButtonBlock", bottom : 0}
    ]);

    // 개인화조건
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의
	myForm.popupInfo = {
		detailPopup : { row:'', col:'', detailData:[] }
	};

    // 그리드형 테이블 TR 
    // vanaa 03/11/2025
    var baseAmountTypeCode = [
	  { code: 1, name: "Base salary" },
	  { code: 2, name: "Regional minimum wage" }
	];

    
    // 코드 데이터 조회
	var valueset = new ValueSet("lgcom");
    valueset.add("udtTableList", {valueSetId : "LGVPAY_UDT_TABLE_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table List
    valueset.add("udtTableRowList", {valueSetId : "LGVPAY_UDT_TABLE_ROW_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table Row List
    valueset.add("udtTableColList", {valueSetId : "LGVPAY_UDT_TABLE_COL_LIST", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}", languageCode:SESSION_USER.languageCode} );//UDT Table Col List
	valueset.execute();
    
    //콤보값 셋팅
    formUtil.initCombo("tableSeqNo", valueset.get("udtTableList"), {selectEmpty:true});
    formUtil.initCombo("columnSeqNo", valueset.get("udtTableColList"), {selectEmpty:true, filter:"tableSeqNo"});
    formUtil.initCombo("sortOrderNo", valueset.get("udtTableRowList"), {selectAll:true, filter:"tableSeqNo"});
    
    // 그리드선언
	var rowGrid   = buildGrid(".rowGrid");
	var valueGrid = buildGrid(".valueGrid");
	var showColunm = false;	// -- vanaa 03/11/2025
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, srchForm );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	 	    tableSeqNo: {required:true}
 	      , columnSeqNo: {required:true}
	    },
	    messages: {
	    	tableSeqNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.tableName'/>" />'}
	      , columnSeqNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.columnKey'/>" />'}
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
					rowGrid.getGridBase().cancel();
					rowGrid.loadData("lgvhr", "lgvpay/LGVPAY00018/retrieveUserDefineTableRowList", formUtil.getValue(), function (data) {
						if ( data.result ) {
							$(myForm.select("button[data-action]")).each(function() {
								$(this).removeAttr("disabled");
							});
						}	
					});
					valueGrid.getDataProvider().clearRows();
				}
				break;
				
			case "add" :
				if ( validator.isValid() ) {
					var gridBase = valueGrid.getGridBase();
					try {
						gridBase.commit();
					} catch(e) {
						Message.alert(e.message);
						return;
					}
					
					if(gridBase.getCurrent().itemIndex < 0) {
						gridBase.beginAppendRow();
					} else {
						gridBase.beginInsertRow(gridBase.getCurrent().itemIndex);
					}
					var currCell = gridBase.getCurrent();
					var itemIndex = currCell.itemIndex;
					var rowData = fncRetrieveUserDefineTableRowData();
					gridBase.setValue(itemIndex, "tableSeqNo", formUtil.getValue("tableSeqNo"));
					gridBase.setValue(itemIndex, "columnSeqNo", formUtil.getValue("columnSeqNo"));
					gridBase.setValue(itemIndex, "rowNo", rowData.rowNo);
					gridBase.setValue(itemIndex, "effectiveEndYyyymmdd", DateUtil.format(DateUtil.parse("47121231", "YYYYMMDD"), "DD/MM/YYYY"));//종료일은 4712/12/31 기본값 셋팅
					gridBase.setCurrent({itemIndex:itemIndex, column:'tableCellValue'});
					// chỉ với loại là stop working mới set giá trị	-- vanaa 03/11/2025
					if(showColunm)
					{
						gridBase.setValue(itemIndex,'baseAmountType', "1"); // set giá trị mặc định ban đầu cho nó
					}
					gridBase.setFocus();
				}
				break;
				
			case "delete" :
				var gridBase = valueGrid.getGridBase();
				var itemIndex = gridBase.getCurrent().itemIndex;
				
				gridBase.deleteSelection(true);
				gridBase.setSelectOptions( {style : "rows"});
				break;

			case "save" :
				try {
					valueGrid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( valueGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!valueGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장 전 체크
				if ( !fncValidateSaveValue() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					valueGrid.useProgress(true);
					valueGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00019/saveUserDefineTableValueList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 Value 목록 재조회
						fncRetrieveUserDefineTableValueList(fncRetrieveUserDefineTableRowData());
					});
				});
				break;
		}
		event.stopPropagation();
	});
    
    //UDT Table명 변경 시 그리드 컬럼 조정
	myForm.addEvent( "change", ".searchBlock .form select" , function(event) {
		var item = $(event.target);
		
		switch($.trim(item.attr("name"))) {
			case "tableSeqNo":
				//그리드 초기화
				rowGrid.getGridBase().cancel();
				rowGrid.getDataProvider().clearRows();
				valueGrid.getGridBase().cancel();
				valueGrid.getDataProvider().clearRows();
				
				if ( !isNull(formUtil.getValue("tableSeqNo")) ) {//UDT Table Name있는 경우 Row Grid 컬럼 visible 수정, Row Grid 재조회
				// -- vanaa 03/11/2025
					var selectedTableName = ($("select[name='tableSeqNo'] option:selected").text() || "").toUpperCase();
					showColunm = (selectedTableName === "PL_SW_STOP_WORKING");
					// chỉ với loại là stop working mới hiển thị cột này
					if (showColunm) {
						valueGrid.getGridBase().setColumnProperty("baseAmountType", "header", "<lgcom:message code="label.pay.baseSalary"/>");
						valueGrid.getGridBase().setColumnProperty("baseAmountType", "visible", true);
					} else {
						valueGrid.getGridBase().setColumnProperty("baseAmountType", "header", "");
						valueGrid.getGridBase().setColumnProperty("baseAmountType", "visible", false);
					}
				// End -- vanaa 03/11/2025
					//클릭이벤트 호출
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				}
				break;
				
			case "columnSeqNo":
				//Value Grid 초기화
				valueGrid.getGridBase().cancel();
				valueGrid.getDataProvider().clearRows();
				
				//Row Grid 데이터가 없고, column key가 선택된 경우 Row Grid 데이터 조회
				if ( rowGrid.getDataProvider().getRowCount() == 0 && !isNull(formUtil.getValue("columnSeqNo")) ) {
					//클릭이벤트 호출
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
					
				//Row Grid 데이터가 있고, column key가 선택된 경우 Value Grid 만 재조회 한다.
				} else if ( rowGrid.getDataProvider().getRowCount() > 0 && !isNull(formUtil.getValue("columnSeqNo")) ) {
					fncRetrieveUserDefineTableValueList(fncRetrieveUserDefineTableRowData());
				}
				break;
			case "sortOrderNo":
				//클릭이벤트 호출
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				break;
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	//User Defind Table Value 목록 조회
	function fncRetrieveUserDefineTableValueList(rowData) {
		var param = {tableSeqNo:rowData.tableSeqNo, rowNo:rowData.rowNo, columnSeqNo:formUtil.getValue("columnSeqNo")};
		valueGrid.getGridBase().cancel();
		valueGrid.loadData("lgvhr", "lgvpay/LGVPAY00019/retrieveUserDefineTableValueList", param);
	}
	
	//User Defined Table Row 현재 행 데이터 조회
	function fncRetrieveUserDefineTableRowData(){
		return rowGrid.getGridBase().getValues(rowGrid.getGridBase().getCurrent().itemIndex);
	}
	
	//User Define Table Value 저장 전 체크
	function fncValidateSaveValue() {
		var cgrid = rowGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		return true;
	}
	
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".rowGrid" :
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
					{ fieldName:'effectiveStartYyyymmdd'    , dataType:'text'  },
					{ fieldName:'effectiveEndYyyymmdd'      , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({ });
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'sortOrderNo',
						fieldName:'sortOrderNo',
						width:80,
						header: {text:'<lgcom:message code="label.pay.rowSeq"/>'},
						styles: {textAlignment:'center'},
						editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#,##0'},
						editable: false
					},
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
						name:'effectiveStartYyyymmdd',
						fieldName:'effectiveStartYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectiveStartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'effectiveEndYyyymmdd',
						fieldName:'effectiveEndYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectEndDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					}
				]);
				break;

			case ".valueGrid" :
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
					{ fieldName:'tableSeqNo'                , dataType:'number'},
					{ fieldName:'rowNo'                     , dataType:'number'},
					{ fieldName:'columnSeqNo'               , dataType:'number'},
					{ fieldName:'tableCellId'               , dataType:'number'},
					{ fieldName:'tableCellValue'            , dataType:'text'  },
					{ fieldName:'baseAmountType'            , dataType:'text'  },	//-- vanaa 03/11/2025
					{ fieldName:'oriEffectiveStartYyyymmdd' , dataType:'text'  },
					{ fieldName:'effectiveStartYyyymmdd'    , dataType:'text'  },
					{ fieldName:'effectiveEndYyyymmdd'      , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				// -- start vanaa 03/11/2025
				grid.setLookups({
				  baseAmountTypeCode: baseAmountTypeCode
				});
				// end vanaa 03/11/2025
				//컬럼 설정
				grid.setColumns([
					{
						name:'tableCellValue',
						fieldName:'tableCellValue',
						width:220,
						header: {text:'<lgcom:message code="label.pay.value"/>', required: true}
					},
					// -- start vanaa 03/11/2025
					{
					  name: 'baseAmountType',
					  fieldName: 'baseAmountType',
					  width: 150,
					  header: { text: '<lgcom:message code="label.pay.baseSalary"/>'},
					  renderer: { showTooltip: true },
					  lookupDisplay: true,
					  lookupSourceId: 'baseAmountTypeCode', // ✅ trùng với setLookups bên trên
					  lookupKeyFields: ['baseAmountType'],
					  editor: { type: 'dropDown', textReadOnly: true },
					  editButtonVisibility: 'visible'
					},
					// -- end vanaa 03/11/2025
					{
						name:'effectiveStartYyyymmdd',
						fieldName:'effectiveStartYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectiveStartDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					},
					{
						name:'effectiveEndYyyymmdd',
						fieldName:'effectiveEndYyyymmdd',
						width:140,
						header: {text:'<lgcom:message code="EffectEndDate"/>', required: true},
						styles: {textAlignment:'center'},
						editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
					}
				]);
		
				grid.setValidations([
					{criteria: "value['tableCellValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.value'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveStartYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectiveStartDate'/>"/>',mode:'always',level:'error'},
					{criteria: "value['effectiveEndYyyymmdd'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EffectEndDate'/>"/>',mode:'always',level:'error'}
				]);
				
				break;
		}
		return grid;
	}
	/* 그리드 이벤트 처리 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	rowGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		valueGrid.getGridBase().cancel();
		valueGrid.getDataProvider().clearRows();
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';

		// Value 목록 조회
		var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
		if ( cgrid.getCurrent().itemIndex > -1 && !isNull(rowData.tableSeqNo) && !isNull(rowData.rowNo) && !isNull(formUtil.getValue("columnSeqNo")) ) {
			fncRetrieveUserDefineTableValueList(rowData);
		}
	};
	rowGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
}

LGVPAY00019.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00019();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.userDefinedTableValue"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="120">
						<col width="220">
						<col width="120">
						<col width="160">
						<col width="100">
						<col width="070">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.tableName"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="tableSeqNo" ></select></td>
							<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.columnKey"/></label></th>
		                	<td><select class="form-control input-sm input-require" name="columnSeqNo" ></select></td>
							<th><label><lgcom:message code="label.pay.rowSeq"/></label></th>
		                	<td><select class="form-control input-sm" name="sortOrderNo" ></select></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- User Defined Table Value 그리드 버튼 --%>
		<div class="module-group text-right valueButtonBlock" >
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add" disabled><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete" disabled><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" disabled><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- User Defined Table Row 그리드 --%>
		<div class="rowGridBlock grid-wrap">
			<div class="grid rowGrid"></div>
		</div>
		<%-- User Defined Table Value 그리드 --%>
		<div class="valueGridBlock grid-wrap">
			<div class="grid valueGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
