<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYP0006.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Payroll Item Detail List를 조회 및 관리하는 팝업 화면입니다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.detail"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAYP0006 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	var detailPopData = myForm.getParent().popupInfo.detailPopup;
	
	//팝업으로서의 이 화면은 여러 화면에서 사용하는 것으로, 팝업 윈도우의 크기를 아래와 같이 고정하였다.
	myForm.select(".contentBlock").parents("._div_popup_holder_").css({"width": "512px", "height":"400px"});
	
    // 화면 레이아웃 정의(달력 그린 후 레이아웃 지정하기 위해 마지막에 수행함.)
	myForm.setLayout( [
		{ name : "contentBlock", left : 0, right : 0, top : 0, bottom : "controlBlock" },
	    { name : "controlBlock", left : 0, right : 0, bottom : 0 }
	]);

    // 개인화조건
    
    // 조회조건 저장 처리
    //myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	var code = new CommonCode("lgcom");
    code.add( "detailTypeList", {codeTypeCode:'LGDVH_PAY_ITEM_DETAIL_TYPE_CODE'});
	code.execute();
	
	//수정/삭제 가능여부 조회하기 위해 급여항목ID로 데이터 조회함.
	var itemData = {};
	myForm.transaction_sync("lgvhr", "lgvpay/LGVPAY00013/retrievePayrollItemData", {payrollItemId:nvl(detailPopData.payrollItemId)}, function (data) {
		itemData = data.result;
	});
	
    // 그리드선언
	var listGrid = buildGrid(".listGrid");
	
    // 날짜 팝업창
    
    // 필수항목 체크
    
    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}

		var cgrid = listGrid.getGridBase();
		var action = $.trim(item.data('action'));
		switch( action ){
			case "add" :
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}

				//최대 10건까지만 입력 가능함.
				var limitRowCount = 10;
				if ( (fncRetrieveRowCount()+1) > limitRowCount ) {//현재 건수와 추가할 건수 포함하여 10건 초과인 경우
					
					Message.alert("<lgcom:message code="error.tenrows" arguments='"+limitRowCount+"' />");
					return ;
					
				} else {//10건 이하인 경우 행추가 가능
					
					if(cgrid.getCurrent().itemIndex < 0) {
						cgrid.beginAppendRow();
					} else {
						cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
					}
					var currCell = cgrid.getCurrent();
					cgrid.setCurrent({column:'detailName'});
					cgrid.setFocus();
					
				}
				break;
				
			case "delete" :
				//행 수정 불가능한 경우(수정가능여부=N 또는 null) 삭제 불가 메세지 처리
				if ( nvl(cgrid.getValue(cgrid.getCurrent().itemIndex, "editEnableFlag"), "Y") == "N" ) {
					Message.alert("<lgcom:message code="note.pay.payValueCannotDelete" />");
					return ;
				} else {
					cgrid.deleteSelection(true);
					cgrid.setSelectOptions( {style : "rows"});
				}
				break;
	            
			// 저장
		    case "save" :
				try {
					cgrid.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( listGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};

				// 변경건이 있는지 체크
				if(!listGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				//저장 전 체크
				if ( !fncValidateSave() )  return ;
				
				Message.confirm( "<lgcom:message code="question.save" />", function () {
					listGrid.useProgress(true);
					listGrid.saveChanges("lgvhr", "lgvpay/LGVPAYP0006/saveDetail", function(data) {
						if ( data.result ) {
							if ( isNull(data.result.errCode) ) {//정상인 경우
								Message.alert("<lgcom:message code="note.saved"/>");
								//데이터 재조회
								fncRetrievePayrollItemDetailList();
							} else {//실패인 경우
								Message.alert("<lgcom:message code="note.pay.failProcess"/>");
							}
						}
					});<%-- //listGrid.saveChanges --%>
					
				});<%-- //Message.confirm --%>
				break;
		}
		event.stopPropagation();
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'detailId'      , dataType:'number'},
			{ fieldName:'detailName'    , dataType:'text'  },
			{ fieldName:'detailTypeCode', dataType:'text'  },
			{ fieldName:'detailTypeName', dataType:'text'  },
			{ fieldName:'sortOrderNo'   , dataType:'number'},
			{ fieldName:'editEnableFlag', dataType:'text'  }
		]);
		// Grid Column Combo Setting
		grid.setLookups({
		    detailTypeList : code.get("detailTypeList")
		});
		// Grid Column Set
		grid.setColumns([
			{
				name:'detailName',
				fieldName:'detailName',
				width:200,
				header: {text:'<lgcom:message code="label.pay.detailName"/>', required: true},
				renderer: {showTooltip: true}
			},
			{
				name:'detailTypeCode',
				fieldName:'detailTypeCode',
				width:130,
				header: {text:'<lgcom:message code="label.pay.detailType"/>', required: true},
				renderer: {showTooltip: true},
				lookupDisplay: true,
				lookupSourceId: 'detailTypeList',
				lookupKeyFields: ['detailTypeCode'],
				editor: {type:'dropdown', textReadOnly: true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'sortOrderNo',
				fieldName:'sortOrderNo',
				width:90,
				header: {text:'<lgcom:message code="SortOrder"/>'},
				styles: {textAlignment:'far'},
				editor: {type:'number', textAlignment:'far', editFormat: '#,##0'}
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
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
		//Validation Set
		grid.setValidations([
		    {criteria: "value['detailName'] is not empty", message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.detailName'/>"/>',mode:'always',level:'error'}
		   ,{criteria: "value['detailTypeCode'] is not empty", message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.detailType'/>"/>',mode:'always',level:'error'}
		]);
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	listGrid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	listGrid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	// 행 변경 시 이벤트
	listGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		// 신규건 또는 화면수정 가능여부가 Y인 경우
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created' || fncRetrieveEditFlag() == "Y";
		
		if ( newRow > -1 && provider.getRowState(newRow) != 'created' ) {//신규행 아닌 경우만 edit style 적용
			fncSetEditableControl(cgrid, provider, newRow, editable?"Y":"");
		}
	};
	// 입력값이 셀에 반영될 때 이벤트
	listGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- index : 클릭된 데이터 셀의 인덱스.
	                  - index.itemIndex : 그리드의 row index.gridBase에서 사용.
	                  - index.dataRow : 조회한 데이터셋의 row index. dataProvider에서 사용.
	        - oldValue : 편집 전 셀의 데이터 값
	        - newValue : 편집 후 셀의 데이터 값
		--%>
	    	/*
		if ( index.column  == "detailName" && newValue == "PAY_VALUE") {
			Message.alert("<lgcom:message code="note.pay.payValueCannotRegister"/>");
		} */
	}
	//입력값 validation
    listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//저장 전 체크
	function fncValidateSave() {
		var cgrid = listGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var sMsg = "";
		
		//신규 또는 수정 건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		for ( var i=0; i<rowIdxs.length; i++ ) {
			var rowData = provider.getJsonRow(rowIdxs[i]);
			//PAY_VALUE 입력 불가 체크
			if ( rowData.detailName == "PAY_VALUE" ) {
				if ( provider.getRowState(rowIdxs[i]) == "updated" ) {//수정인 경우
					sMsg = "<lgcom:message code="note.pay.payValueCannotModify" />";
				} else {//신규인 경우
					sMsg = "<lgcom:message code="note.pay.payValueCannotRegister" />";
				}
				Message.alert(sMsg);
				cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"detailName"});
				cgrid.setFocus();
				return false;
			}
		}
		
		//최대 10건까지만 입력 가능함.
		var limitRowCount = 10;
		if ( fncRetrieveRowCount() > limitRowCount ) {
			Message.alert("<lgcom:message code="error.tenrows" arguments='"+limitRowCount+"' />");
			return false;
		}
		
		return true;
	}
	//전체 건수(입력 가능한 최대 건수 체크하기 위함)
	function fncRetrieveRowCount() {
		var cgrid = listGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		var totalRow = provider.getRowCount();//전체행개수
		var createRow = provider.getRowStateCount("created");//신규건
		var deleteRow = provider.getRowStateCount("deleted");//삭제건
		
		//return totalRow + createRow - deleteRow;
		return totalRow;
		
	}
	//데이터 전체에 대한 수정 가능여부 셋팅
	function fncSetEditableControlAll(cgrid, provider, editFlag) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		--%>	
		for (var i=0; i<provider.getRowCount(); i++) {
			fncSetEditableControl(cgrid, provider, i, editFlag);
		}
	}
	//행별 수정 가능여부 셋팅
	function fncSetEditableControl(cgrid, provider, dataRow, editFlag) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - dataRow : 데이터셋 row index(dataRow)
		     - editFlag
		       - Y : 수정 가능. 행 추가시 수정 가능 여부 셋팅. 그외는 행별 수정/삭제가능여부 컬럼 값에 따라 수정 여부 셋팅
		       - N : 수정 불가능. 
		--%>
		var fieldNames = provider.getOrgFieldNames();
		
		if ( dataRow > -1 && dataRow < provider.getRowCount() ) {
			var editableStyle = "readOnlyStyle";
			//수정, 삭제 가능여부에 따라 수정 또는 조회 스타일 셋팅
			if ( nvl(editFlag, "N") == "Y" )  {//수강 가능한 상태라도 행별 수정 가능여부에 따라 스타일 셋팅.(PAY_VALUE는 항상 수정 불가능함)
				editableStyle = (nvl(provider.getValue(dataRow, "editEnableFlag")) == "Y")?"editableStyle":"readOnlyStyle";
			}
			for ( var i=0; i<fieldNames.length; i++ ) {
				cgrid.setCellStyle(dataRow, fieldNames[i], editableStyle, true);
			}<%-- //for --%>
		}<%-- //if --%>
	}
	//화면 수정 가능여부 
	function fncRetrieveEditFlag() {
		//급여항목 수정, 삭제 가능한 경우만 Detail 항목 변경 가능함.
		return ( typeof(itemData) == "object" && nvl(itemData.delUptPossibleFlag) == "Y")?"Y":"N";
	}
	//데이터 조회
	function fncRetrievePayrollItemDetailList() {
		var cgrid = listGrid.getGridBase();
		listGrid.getGridBase().cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVPAYP0006/retrievePayrollItemDetailList", {payrollItemId:nvl(detailPopData.payrollItemId)}, function(data) {

			//급여항목 수정, 삭제 가능한 경우만 Detail 항목 변경 가능함.
			var editFlag = fncRetrieveEditFlag();
			
			//그리드 셀별 수정여부 셋팅
			fncSetEditableControlAll(cgrid, cgrid.getDataProvider(), editFlag);
			//버튼 활성화 셋팅
			if ( editFlag == "Y" ) {//버튼활성화
				myForm.select("button[data-action='add']").removeAttr("disabled");
				myForm.select("button[data-action='delete']").removeAttr("disabled");
				myForm.select("button[data-action='save']").removeAttr("disabled");
			} else {//버튼 비활성화
				myForm.select("button[data-action='add']").attr("disabled", "disabled");
				myForm.select("button[data-action='delete']").attr("disabled", "disabled");
				myForm.select("button[data-action='save']").attr("disabled", "disabled");
			}
		});
	}
	
	//데이터 조회
	fncRetrievePayrollItemDetailList();
}

LGVPAYP0006.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAYP0006();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.detail"/></h2>
		</div>

		<div class="contentBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>

		<div class="controlBlock modal-footer module-group">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add" disabled><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete" disabled><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" disabled><lgcom:message code="Save"/></button>
				</div>
			</div>
		</div>
		
	</section>
</div>
</body>
</html>
