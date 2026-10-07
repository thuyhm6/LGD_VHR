<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00017.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : User Defined Table/Column을 관리하는 화면입니다.
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.userDefinedTableNColumn"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00017 = function() {
	var grid;
	var myForm = this;
	var srchForm = '.searchBlock form';
	/* Form Util 선언 */ 
	var formUtil = new FormUtil( myForm, srchForm );

    // 화면 레이아웃 정의
	myForm.setLayout( [ 
    	{ name : "searchBlock",       left : 0, right : 0, top : 0 },
    	{ name : "masterButtonBlock", left : 0, right : 0, top : "searchBlock",  width : 800, bottom : "detailGridBlock"},
    	{ name : "masterGridBlock",   left : 0, right : 0, top : "masterButtonBlock", width : 800, bottom : 0},
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
    code.add( "udtTypeList" , {codeTypeCode:'LGDVHR_PAY_UDT_TYPE_CODE'});
	code.add( "ynList"      , {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
	
	var valueset = new ValueSet("lgcom");
	valueset.add("dataTypeList", {valueSetId:'LGVPAY_UDT_DATA_TYPE_LIST', languageCode:SESSION_USER.languageCode});
	valueset.execute();
	    
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
				masterGrid.loadData("lgvhr", "lgvpay/LGVPAY00017/retrieveUserDefineTableList", formUtil.getValue() );
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
				mgrid.setValue(itemIndex, "dataValidationFlag", "N");
				mgrid.setCurrent({itemIndex:itemIndex, column:'tableName'});
				mgrid.setFocus();

				// column grid 초기화
				detailGrid.getDataProvider().clearRows();
				// User Define Column 목록 조회
				if ( itemIndex.itemIndex > -1 && !isNull(mgrid.getValue(itemIndex, "tableSeqNo")) ) {
					fncRetrieveUserDefineColumnList(mgrid.getValue(itemIndex, "tableSeqNo"));
				}
				break;
				
			case "delete1" :
				var mGrid = masterGrid.getGridBase();
				var itemIndex = mGrid.getCurrent().itemIndex;
				
				mGrid.deleteSelection(true);
				mGrid.setSelectOptions( {style : "rows"});
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
				if ( !fncValidateSaveTable() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					masterGrid.useProgress(true);
					masterGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00017/saveUserDefineTableList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;

			case "add2" :
				var dgrid = detailGrid.getGridBase();
				var tableSeqNo = fncRetrieveTableSeqNo();

				//Formula 가 없는 경우 행 추가 불가
				if($.trim(tableSeqNo) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.table'/>"/>');
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
				dgrid.setValue(currCell.itemIndex, 'tableSeqNo', tableSeqNo);
				dgrid.setCurrent({itemIndex:currCell.itemIndex, column:'userColumnName'});
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
				if ( !fncValidateSaveColumn() ) return ;
				
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					detailGrid.useProgress(true);
					detailGrid.saveChanges( "lgvhr", 'lgvpay/LGVPAY00017/saveUserDefineColumnList', function(data) {
						Message.alert('<lgcom:message code="note.saved"/>');
						// 저장 완료후 목록 재조회
						fncRetrieveUserDefineColumnList(fncRetrieveTableSeqNo());
					});
				});
				break;
		}
		event.stopPropagation();
	});
    
	/*** 내부 함수  ***/
	// User Define Column 목록 조회
	function fncRetrieveUserDefineColumnList(tableSeqNo) {
		detailGrid.loadData("lgvhr","lgvpay/LGVPAY00017/retrieveUserDefineColumnList", { tableSeqNo: $.trim(tableSeqNo) });
	}
	
	//tableSeqNo 조회
	function fncRetrieveTableSeqNo() {
		return masterGrid.getGridBase().getValue(masterGrid.getGridBase().getCurrent().itemIndex, 'tableSeqNo');
	}
    
	//User Define Table 저장 전 체크
	function fncValidateSaveTable() {
		var cgrid = masterGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		return true;
	}
    
	//User Define Column 저장 전 체크
	function fncValidateSaveColumn() {
		var cgrid = detailGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var tableSeqNo = fncRetrieveTableSeqNo();
		var sMsg = "";
		
		return true;
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
					{ fieldName:'tableSeqNo'           , dataType:'number'},
					{ fieldName:'tableName'            , dataType:'text'  },
					{ fieldName:'dataTypeCode'         , dataType:'text'  },
					{ fieldName:'detailDesc'           , dataType:'text'  },
					{ fieldName:'dataManagementWayCode', dataType:'text'  },
					{ fieldName:'dataValidationFlag'   , dataType:'text'  },
					{ fieldName:'rowExistsFlag'        , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookupsMultiLvl({ 
					udtTypeList  : code.get("udtTypeList") 
				  , dataTypeList : {data:valueset.get("dataTypeList"), keyField:["matchTypeCode", "code"]}
				  , ynList       : code.get("ynList") 
				});
		
				//컬럼 설정
				grid.setColumns([
					{
						name:'tableName',
						fieldName:'tableName',
						width:200,
						header: {text:'<lgcom:message code="label.pay.tableName"/>', required: true}
					},
					{
						name:'dataManagementWayCode',
						fieldName:'dataManagementWayCode',
						width:110,
						type: 'data',
						header: {text:'<lgcom:message code="label.pay.matchType"/>', required: true},
						styles: {textAlignment:'center'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'udtTypeList',
						lookupKeyFields: ['dataManagementWayCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					},
					{
						name:'detailDesc',
						fieldName:'detailDesc',
						width:200,
						header: {text:'<lgcom:message code="label.pay.rowTitle"/>'}
					},
					{
						name:'dataTypeCode',
						fieldName:'dataTypeCode',
						width:110,
						type: 'data',
						header: {text:'<lgcom:message code="DataType"/>', required: true},
						styles: {textAlignment:'center'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'dataTypeList',
						lookupKeyFields: ['dataManagementWayCode','dataTypeCode'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					},
					{
						name:'dataValidationFlag',
						fieldName:'dataValidationFlag',
						width:110,
						type: 'data',
						header: {text:'<lgcom:message code="ValidateFlag"/>', required: true},
						styles: {textAlignment:'center'},
						renderer: {showTooltip: true},
						lookupDisplay: true,
						lookupSourceId: 'ynList',
						lookupKeyFields: ['dataValidationFlag'],
						editor: {type:'dropDown',textReadOnly:true},
						editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
					}
				]);
		
				grid.setValidations([
					{criteria: "value['tableName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.tableName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['dataManagementWayCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.matchType'/>"/>',mode:'always',level:'error'}
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
					{ fieldName:'tableSeqNo'     , dataType:'number'},
					{ fieldName:'columnSeqNo'    , dataType:'number'},
					{ fieldName:'userColumnName' , dataType:'text'  },
					{ fieldName:'detailDesc'     , dataType:'text'  },
					{ fieldName:'valueExistsFlag', dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 콤보 셋팅
				grid.setLookups({ });
				//컬럼 설정
				grid.setColumns([
					{
						name:'userColumnName',
						fieldName:'userColumnName',
						width:300,
						header: {text:'<lgcom:message code="label.pay.columnKey"/>', required: true}
					},
					{
						name:'detailDesc',
						fieldName:'detailDesc',
						width:300,
						header: {text:'<lgcom:message code="Description"/>'}
					}
				]);

				// Validation Set		
				grid.setValidations([
					{criteria: "value['userColumnName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.columnKey'/>"/>',mode:'always',level:'error'}
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

		// detail 목록 조회
		var rowData = cgrid.getValues(cgrid.getCurrent().itemIndex);
		if ( cgrid.getCurrent().itemIndex > -1 && !isNull(rowData.tableSeqNo) ) {
			fncRetrieveUserDefineColumnList(rowData.tableSeqNo);
		}
	};
	//Match Type, Data Type, Validate Flag 선택 불가능한 값 체크
	masterGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- index : 클릭된 데이터 셀의 인덱스.
	                  - index.itemIndex : 그리드의 row index
	                  - index.dataRow : 조회한 데이터셋의 row index
	        - oldValue : 편집 전 셀의 데이터 값
	        - newValue : 편집 후 셀의 데이터 값
		--%>
	    //UDT Row 데이터가 있는 경우 Match Type, Data Type, Validate Flag 수정 불가, Table Name, Description 만 수정 가능. 삭제 가능.
	    
	    //Match Type 변경 시 Data Type 자동 변경 처리
	    if ( index.fieldName == "dataManagementWayCode" && nvl(cgrid.getValue(index.itemIndex, "rowExistsFlag")) != "Y" ) {
	    	var exists = cgrid.existsLookupData('dataTypeList',[newValue,cgrid.getValue(index.itemIndex,'dataTypeCode')]);
			if(!exists) {
				var dataTypeLookup = valueset.get('dataTypeList');
				var dataTypeCode = '';
				for(var i=0; i < dataTypeLookup.length; i++) {
					if($.trim(dataTypeLookup[i]['matchTypeCode']) == newValue) {
						dataTypeCode = $.trim(dataTypeLookup[i]['code']);
						break;
					}
				}
				cgrid.setValue(index.itemIndex,'dataTypeCode',dataTypeCode);
			}
		//수정불가 컬럼인 경우 
	    } else if ( ["dataManagementWayCode", "dataTypeCode", "dataValidationFlag"].indexOf(index.fieldName) > -1 && nvl(cgrid.getValue(index.itemIndex, "rowExistsFlag")) == "Y" ) {
			Message.alert("<lgcom:message code="note.pay.unChangeableUDT"/>");<%-- Row 데이터가 있는 경우 UDT 수정불가 --%>
			cgrid.cancel();//변경된 값 취소. onEditRowChanged 이벤트에서 cgrid.setValue 하는 경우 무한반복 실행오류때문에 cancel 함수로 변경함.
		}
	};
	masterGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	detailGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
}

LGVPAY00017.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00017();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.userDefinedTableNColumn"/></h2>
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
							<th><label><lgcom:message code="label.pay.tableName"/></label></th>
							<td><input type="text" class="form-control input-sm" name="tableName"/></td>
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
