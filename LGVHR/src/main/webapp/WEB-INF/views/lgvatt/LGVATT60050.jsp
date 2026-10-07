<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT60050.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2024 LG CNS,  All rights reserved.

-------------------------------------------------------------%>
<html lang="ko"> 
<head>
<title><lgcom:message code="label.att.HalfdayManagement"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT60050 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "gridBlock" },
	    { name : "gridBlock",          left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);
    
    // 조회조건 저장 처리
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
					fncRetrieveHalfdayWorkingList();
				}
				break;
			case 'save':
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
					listGrid.saveChanges("lgvhr", "lgvpay/LGVATT60050/saveAttendance", function(data) {
						if ( data.result ) {
							if ( isNull(data.result.errCode) ) {//정상인 경우
								Message.alert("<lgcom:message code="note.saved"/>");
								//데이터 재조회
								fncSearchData();
							} else {//실패인 경우
								Message.alert("Fail Process!");
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
			{ fieldName:'dayOfMonth'             , dataType:'text'  },
			{ fieldName:'shiftCode'       , dataType:'text'  },
			{ fieldName:'employeeNo'            , dataType:'text'  },
 			{ fieldName:'dayOfWeek'        , dataType:'text'  },
			{ fieldName:'attendanceCode'        , dataType:'text'  },
			{ fieldName:'workHours'       , dataType:'text'  },
			{ fieldName:'attendDetailCode'             , dataType:'text'  },
			{ fieldName:'reasonDesc'   , dataType:'text'  }
		]);
		//컬럼 콤보 셋팅
		grid.setLookups({
		});
		// Grid Column Set
		grid.setColumns([
    		{
   				name:'dayOfmonth',
   				fieldName:'dayOfmonth',
   				header: {text:'<lgcom:message code="label.att.date"/>'},
   				styles: {background: "#e9e9e9"},
   				editable: false
   			},
    		{
   				name:'shiftCode',
   				fieldName:'shiftCode',
				width:150,
   				header: {text:'<lgcom:message code="label.att.shiftCode"/>'},
   				styles: {background: "#e9e9e9"},
   				editable: false
   			},
			{
				name:'employeeNo',
				fieldName:'employeeNo',
				width:150,
				header: {text:'<lgcom:message code="label.att.employeeNo"/>'},
   				styles: {background: "#e9e9e9"},
				editable: false
			},
			{
				name:'dayOfWeek',
				fieldName:'dayOfWeek',
				width:150,
				header: {text:'<lgcom:message code="label.att.dayOfWeek"/>', required: true},
   				styles: {background: "#e9e9e9"},
				editable: false
			},
			{
				name:'attendanceCode',
				fieldName:'attendanceCode',
				width:180,
				header: {text:'<lgcom:message code="label.att.attendanceCode"/>'},
				styles: {background: "#e9e9e9"},
				editable: false
			},
			{
				name:'workHours',
				fieldName:'workHours',
				width:180,
				header: {text:'<lgcom:message code="label.att.workHours"/>'},
			},
			{
				name:'attendDetailCode',
				fieldName:'attendDetailCode',
				width:180,
				header: {text:'<lgcom:message code="label.att.attendDetailCode"/>'},
			},
			{
				name:'reasonDesc',
				fieldName:'reasonDesc',
				width:180,
				header: {text:'<lgcom:message code="label.att.reasonDesc"/>'},
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
				hideDeletedRows: true,
				indicator: {visible:false},
				panel: {visible:false},
				stateBar: {visible:false},
				checkBar: {visible:false/*, exclusive:true*/},
				footer: {visible:false},
	            sortMode : "explicit",
				edit: {
					insertable: false, /* INSERT 키 또는 방향키로 행삽입 불가능 */
					appendable: false, /* INSERT 키 또는 방향키로 행추가 불가능 */
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
		// Context Menu Set
		grid.setContextMenu();
		
		grid.setValidations([
			 					{criteria: "value['attendanceCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.attendanceCode'/>"/>',mode:'always',level:'error'},
			 					{criteria: "value['workHours'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.workHours'/>"/>',mode:'always',level:'error'},
			 				]);
		return grid;
	}

	listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	//Run 그리드 선택 값 체크
	function fncValidateRunRow() {
		var list = fncArrangeMultiLineGridSelected(listGrid);
        		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return false;
		}
		return true;
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
	function fncRetrieveHalfdayWorkingList() {
		var cgrid = listGrid.getGridBase(); 
		cgrid.cancel();
		listGrid.loadData("lgvhr", "lgvatt/LGVATT60050/retrieveHalfdayWorkingList", srchFormUtil.getValue(), function (data) {
			if ( data.result ) {
				for ( var i=0; i<data.result.length; i++ ) {
					fncSetEditableControl(cgrid, cgrid.getDataProvider(), i, "");
				}
			}
		});
	}
}

LGVATT60050.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT60050();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.att.HalfdayManagement"/></h2>
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
		                	<th><label><lgcom:message code="label.att.Month" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="monthSearch" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
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
