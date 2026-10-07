<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00027.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여시스템담당자가 급여의 모든 항목을 관리하는 화면입니다.
            신규 항목 생성 시 항목의 정의나 속성을 변경할 때 해당 화면을 사용한다.
    작성자 : 임수진	
-------------------------------------------------------------%>
<html lang="ko"> 
<head>
<title><lgcom:message code="label.pay.payrollItemManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00027 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "gridBlock" },
	    { name : "gridBlock",          left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );

    // 코드 데이터 조회
	var valueset = new ValueSet("lgcom");
    valueset.add("allowanceTableColList", {valueSetId : "LGVPAY_PAY_ITEM_TABLE_LIST"} );//UDT Table Col List
	valueset.execute();
    
    //콤보값 셋팅
    srchFormUtil.initCombo("allowanceName", valueset.get("allowanceTableColList"), {selectEmpty:true});

    
    
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
				
			case "add" :
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
				gridBase.setValue(currCell.itemIndex,'allowanceName', "");
				gridBase.setCurrent({column:'allowanceName'});
				gridBase.setFocus();
				
				//추가된 행에 대한 편집모드 설정
				fncSetEditableControl(gridBase, gridBase.getDataProvider(), currCell.dataRow, "Y");
				break;
				
			case "delete" :
				gridBase.deleteSelection(true);
				gridBase.setSelectOptions( {style : "rows"});
				break;
	            
			// 저장
		    case "save" :
				try {
					gridBase.commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				if( listGrid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}

				// 변경건이 있는지 체크
				if(!listGrid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				Message.confirm( "<lgcom:message code="question.save" />", function () {
					listGrid.useProgress(true);
					listGrid.saveChanges("lgvhr", "lgvpay/LGVPAY00027/saveAllowanceMapping", function(data) {
						if ( data.result ) {
							if ( isNull(data.result.errCode) ) {//정상인 경우
								Message.alert("<lgcom:message code="note.saved"/>");
								//데이터 재조회
								fncSearchData();
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
			{ fieldName:'seqValue'             , dataType:'text'  },
			{ fieldName:'subsidiaryCode'       , dataType:'text'  },
			{ fieldName:'gradeName'            , dataType:'text'  },
/* 			{ fieldName:'payrollItemId'        , dataType:'text'  }, */
			{ fieldName:'allowanceName'        , dataType:'text'  },
			{ fieldName:'lastUpdateDate'       , dataType:'text'  },
			{ fieldName:'userName'             , dataType:'text'  },
			{ fieldName:'delUptPossibleFlag'   , dataType:'text'  }
		]);
		//컬럼 콤보 셋팅
		grid.setLookups({
			allowanceCode : valueset.get("allowanceTableColList")
		});
		// Grid Column Set
		grid.setColumns([
    		{
   				name:'seqValue',
   				fieldName:'seqValue',
   				header: {text:'<lgcom:message code="label.pay.seqValue"/>'},
   				editable: false
   			},
    		{
   				name:'subsidiaryCode',
   				fieldName:'subsidiaryCode',
				width:150,
   				header: {text:'<lgcom:message code="label.pay.subsidiaryCode"/>'},
   				editable: false
   			},
			{
				name:'gradeName',
				fieldName:'gradeName',
				width:150,
				header: {text:'<lgcom:message code="label.pay.gradeName"/>', required: true},
				renderer: {showTooltip: true},
				lookupDisplay: true,
				values: ["E16","E19","G09","G10","G11","G15","G21","G31","G41","G42","G43","G51","G52","L10","L11","L21","L31","L32","L33","L34","T41","T42","T43"],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'allowanceName',
				fieldName:'allowanceName',
				width:380,
				header: {text:'<lgcom:message code="label.pay.allowanceName"/>', required: true},
				renderer: {showTooltip: true},
				lookupDisplay: true,
				lookupSourceId: 'allowanceCode',
				lookupKeyFields: ['allowanceName'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'lastUpdateDate',
				fieldName:'lastUpdateDate',
				width:180,
				header: {text:'<lgcom:message code="label.pay.lastUpdateDate"/>'},
				editable: false
			},
			{
				name:'userName',
				fieldName:'userName',
				width:180,
				header: {text:'<lgcom:message code="label.pay.userName"/>'},
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
			//수정, 삭제 가능여부에 따라 수정 또는 조회 스타일 셋팅
			editFlag = (nvl(editFlag, "N") == "Y" || nvl(provider.getValue(dataRow, "delUptPossibleFlag"), "N") == "Y")?"Y":"N";
			
			for ( var i=0; i<fieldNames.length; i++ ) {
				//수정 가능행인 경우 또는 상시 수정가능 컬럼명
				if ( editFlag == "Y" || arrExceptColumns.indexOf(fieldNames[i]) > -1 ) {
					cgrid.setCellStyle(dataRow, fieldNames[i], "editableStyle", true);
					//button=action인 경우만 수정 가능여부에 따라 button보여줄지 설정한다.
					if ( nvl(cgrid.getColumnProperty(fieldNames[i], "button")) == "action" ) {
						cgrid.setColumnProperty(fieldNames[i], "buttonVisibility", 'visible');
					}
				} else {
					cgrid.setCellStyle(dataRow, fieldNames[i], "readOnlyStyle", true);
					//button=action인 경우만 수정 가능여부에 따라 button보여줄지 설정한다.
					if ( nvl(cgrid.getColumnProperty(fieldNames[i], "button")) == "action" ) {
						cgrid.setColumnProperty(fieldNames[i], "buttonVisibility", 'hidden');
					}
				}
			}<%-- //for --%>
			
		//행 추가인 경우(첫행 추가이면 dataRow -1임) 팝업 항목인 경우 버튼 보이도록 함.
		} else if ( nvl(editFlag, "N") == "Y" && (dataRow < 0 || provider.getRowState(dataRow) == "created") ) { 
			for ( var i=0; i<fieldNames.length; i++ ) {
				//button=action인 경우만 수정 가능여부에 따라 button보여줄지 설정한다.
				if ( nvl(cgrid.getColumnProperty(fieldNames[i], "button")) == "action" ) {
					cgrid.setColumnProperty(fieldNames[i], "buttonVisibility", editFlag=="Y"?'visible':'hidden');
				}
			}<%-- //for --%>
		}<%-- //if --%>
	}
	//데이터 조회
	function fncRetrievePayrollItemyList() {
		var cgrid = listGrid.getGridBase(); 
		cgrid.cancel();
		listGrid.loadData("lgvhr", "lgvpay/LGVPAY00027/retrieveAllowanceMappingList", srchFormUtil.getValue(), function (data) {
			//저장 버튼 활성화
			myForm.select("button[data-action='save']").removeAttr("disabled");
			if ( data.result ) {
				for ( var i=0; i<data.result.length; i++ ) {
					fncSetEditableControl(cgrid, cgrid.getDataProvider(), i, "");
				}
			}
		});
	}
}

LGVPAY00027.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00027();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.payrollItemManagement"/></h2>
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
							<th><label class="text"><lgcom:message code="label.pay.gradeName"/></label></th>
		                	<td><input class="form-control input-sm input-require" name=gradeName type="text"></input></td>
		                	<th><label><lgcom:message code="label.pay.allowanceName" /></label></th>
							<td><select class="form-control input-sm input-require" name=allowanceName ></select></td>
		                	<td></td>
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- //searchBlock --%>
		
		<div class="buttonControlBlock module-group text-right">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="add"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>
		<%-- //buttonControlBlock --%>
		
		<div class="gridBlock grid-wrap">
			<div class="grid listGrid"></div>
		</div>
				
	</section>
</div>
</body>
</html>
