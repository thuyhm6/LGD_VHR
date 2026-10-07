<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY0021.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Payroll Calculation Set관리 
    작성자 : Sonsuyang
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<script type="text/javascript">
var LGVPAY00021 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'}	    
    });
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock" , left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent" , left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
    // 코드 데이터 조회
	// combo 목록 조회
	var code = new CommonCode("lgcom");
    code.add( "payRunTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
	code.add( "LGCOM_YN_FLAG", {codeTypeCode:'LGCOM_YN_FLAG'} );
	code.execute();
	// -- vanaa 03/11/2025
	var objectTypeCode = [
    	  { code: "LG", name: "LG Employee" },
    	  { code: "OS", name: "OS Employee" }
    	];
	
 	// 그리드 선언
	var grid = buildGrid('.calculationSetGrid');
 	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		
		switch( action ) {
		case 'search':
			grid.getGridBase().cancel();
			var param = srchFormUtil.getValue();
			if(validator.isValid()) {
				grid.loadData("lgvhr", "lgvpay/LGVPAY00021/retrieveCalcSetList", param, function(data) {
					
					if( grid.getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
						return;
					} else {
						fncSetEditableControlAll();
					}
				});
			} else {
				myForm.select(".searchBlock form input[name='calculationSetName']").focus();
			}
			break;
			
		case 'insert':
			var gridBase = grid.getGridBase();
			try {
				gridBase.commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			var curr = gridBase.getCurrent();
			var itemIndex = curr.itemIndex;
			
			if(itemIndex < 0) {
				gridBase.beginAppendRow();
			}else {
				gridBase.beginInsertRow(itemIndex);
			}
			gridBase.showEditor();
			gridBase.setFocus();
			
			break;
			
		case 'save':
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			}
			
			if(!grid.isChanged()) {
				Message.alert('<lgcom:message code="error.noChangedData"/>');
				return;
			}
			
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00021/saveCalcSet', function(data) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'delete':
			var selectData = grid.getGridBase().getSelectionData();//선택된 영역의 데이터 조회
			var execCount = 0, personExistsCount = 0, normalDelete = 0;
			
			for ( var i=0; i<selectData.length; i++ ) {
				//급여실행된 결과가 있는 경우 삭제 불가
				if ( nvl(selectData[i].execFlag) == "Y" ) {
					execCount++;
					Message.alert("<lgcom:message code="note.pay.deleteAlreadyRunResult"/>");
					return ;
					
				//대상자가 있는 경우 모두 삭제할 것인지 확인 메세지 처리
				} else if ( nvl(selectData[i].execFlag) != "Y" && Calc.real(nvl(selectData[i].setPersonCount+"", "0")) > 0 ) {
					personExistsCount++;
					
				} else {
					normalDelete++;
				}
			}//end-for
			
			//급여실행된 결과가 있는 경우 삭제 불가
			if ( execCount > 0 ) {
				Message.alert("<lgcom:message code="note.pay.deleteAlreadyRunResult"/>");
				return ;
				
			//대상자가 있는 경우 모두 삭제할 것인지 확인 메세지 처리
			} else if ( execCount == 0 && personExistsCount > 0 ) {
				Message.confirm('<lgcom:message code="question.pay.deleteCalcSetPerson"/>', function() {
					grid.getGridBase().deleteSelection(true);
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvpay/LGVPAY00021/saveCalcSet', function(data) {
						Message.alert('<lgcom:message code="note.Successfullydeleted"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				
			} else if ( personExistsCount == 0 && normalDelete > 0 ) {
				Message.confirm('<lgcom:message code="question.delete"/>', function() {
					grid.getGridBase().deleteSelection(true);
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvpay/LGVPAY00021/saveCalcSet', function(data) {
						Message.alert('<lgcom:message code="note.Successfullydeleted"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
			}
			
			break; 
			
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'payrollCalculationSetId'	 , dataType:'number'},
		    { fieldName: 'payrollCalculationSetName' , dataType:'text'  },
		    { fieldName: 'resignationFlag'           , dataType:'text'  },
		    { fieldName: 'payrollTypeCode'         	 , dataType:'text'  },
		    { fieldName: 'payrollTypeName'         	 , dataType:'text'  },
		    { fieldName: 'objectType'         	     , dataType:'text'  },	// -- vanaa 03/11/2025
		    { fieldName: 'autoCreationFlag'      	 , dataType:'text'  },
		    { fieldName: 'setPersonCount'            , dataType:'number'},
		    { fieldName: 'execFlag'                  , dataType:'text'  }
		]);
		// Lookup 설정
		//컬럼 콤보 셋팅
		grid.setLookupsMultiLvl({
			      "resignationFlag":code.get("LGCOM_YN_FLAG"),
			      "autoCreationFlag":code.get("LGCOM_YN_FLAG"),
			      "payRunTypeList":code.get("payRunTypeList"),
			      "objectTypeCodeList": objectTypeCode	// -- vanaa 03/11/2025
			      });
		//컬럼 설정
		grid.setColumns([
 				{
					name:'payrollCalculationSetName',
					fieldName:'payrollCalculationSetName',
					width:300,
					header: {text:'<lgcom:message code="label.pay.calculationSet" />', required : true},
					styles: {textAlignment:'near'},
					editable: true
				},
				{
					name:'resignationFlag',
					fieldName:'resignationFlag',
					width:130,
					header: {text:'<lgcom:message code="label.pay.resignationFlag" />', required : true},
					styles: {textAlignment:'center'},
					defaultValue: 'Y',
					lookupDisplay: true,
					lookupSourceId: 'resignationFlag',
					lookupKeyFields: ['resignationFlag'],
					editor: {type:'dropDown',textReadOnly:true},
					editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
				},
				{
					name:'payrollTypeCode',
					fieldName:'payrollTypeCode',
					width:130,
					header: {text:'<lgcom:message code="label.pay.payType" />', required : true},
					styles: {textAlignment:'near'},
					lookupDisplay: true,
					lookupSourceId: 'payRunTypeList',
					lookupKeyFields: ['payrollTypeCode'],
					editor: {type:'dropDown',textReadOnly:true},
					editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
				},
				//	-- vanaa 03/11/2025
				{
					name:'objectType',
					fieldName:'objectType',
					width:130,
					header: {text:'<lgcom:message code="label.pay.objectType" />', required : true},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: 'objectTypeCodeList',
					lookupKeyFields: ['objectType'],
					editor: {type:'dropDown',textReadOnly:true},
					editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
				},
				{
					name:'autoCreationFlag',
					fieldName:'autoCreationFlag',
					width:130,
					header: {text:'<lgcom:message code="label.pay.autoCreationFlag" />', required : true},
					styles: {textAlignment:'center'},
					lookupDisplay: true,
					lookupSourceId: 'autoCreationFlag',
					lookupKeyFields: ['autoCreationFlag'],
					editor: {type:'dropDown',textReadOnly:true},
					editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
				},
 				{
					name:'setPersonCount',
					fieldName:'setPersonCount',
					width:120,
					header: {text:'<lgcom:message code="label.pay.employeeCount" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0', background: "#e9e9e9"},
					editable: false
				},
 				{
					name:'execFlag',
					fieldName:'execFlag',
					width:80,
					header: {text:'<lgcom:message code="label.pay.run" />'},
					styles: {textAlignment:'center', background: "#e9e9e9"},
					editable: false
				}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
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

		// Context Menu Set
		grid.setContextMenu();
		
		grid.setValidations([
		    {criteria: "value['payrollCalculationSetName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>"/>',mode:'always',level:'error'},
		    {criteria: "value['resignationFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.resignationFlag'/>"/>',mode:'always',level:'error'},
			{criteria: "value['payrollTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>"/>',mode:'always',level:'error'},
		    {criteria: "value['autoCreationFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.autoCreationFlag'/>"/>',mode:'always',level:'error'},
		    {criteria: "value['objectType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.objectType'/>"/>',mode:'always',level:'error'}	// -- vanaa 03/11/2025
		]);

		return grid;
	}
	grid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	grid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	// 샐의 dataRow가 바뀔때(행 추가 이벤트 시)
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		<%--[PARAMETER]
		    - cgrid : grid.getGridBase()
		    - oldRow : 변경 전 데이터행의 dataRow
		    - newRow : 변경 후 데이터행의 dataRow
		    
		    *dataRow : 최초 조회한 데이터셋의 row index
		--%>
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';

		if ( !editable ) {
			fncSetEditableControl(cgrid, cgrid.getDataProvider(), newRow);
			
			if ( nvl(provider.getValue(newRow, "execFlag")) == "Y" ) {
				myForm.select("button[data-action='delete']").attr("disabled", "disabled");//삭제버튼 비활성화
			} else {
				myForm.select("button[data-action='delete']").removeAttr("disabled");//삭제버튼 활성화
			}
			
		} else {
			myForm.select("button[data-action='delete']").removeAttr("disabled");//삭제버튼 활성화
		}
	};
	
	grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
	//그리드의 현재행 데이터 조회
	function fncRetrieveCurrentData() {
		return fncRetrieveRowData(grid.getGridBase().getCurrent().itemIndex);
	}
	
	//특정행의 데이터 조회
	function fncRetrieveRowData( itemIndex ) {
		return grid.getGridBase().getValues(itemIndex);
	}
	
	//행전체 수정 가능여부 셋팅
	function fncSetEditableControlAll() {
		var cgrid = grid.getGridBase();
		var provider = grid.getDataProvider();
		
		for (var i=0; i<provider.getRowCount(); i++) {
			fncSetEditableControl(cgrid, provider, i);
		}
	}

	//그리드 행별 수정 가능여부 셋팅
	function fncSetEditableControl(cgrid, provider, dataRow) {
		<%-- [PARAMETER]
		     - cgrid : grid.getGridBase()
		     - provider : grid.getGridBase().getDataProvider()
		     - dataRow : 데이터셋 row index(dataRow)
		     - editFlag
		       - Y : 수정 가능. 행 추가시 수정 가능 여부 셋팅. 그외는 행별 수정/삭제가능여부 컬럼 값에 따라 수정 여부 셋팅
		       - N : 수정 불가능.
		--%>
		var fieldNames = provider.getOrgFieldNames();
		
		/*
		   - 수정
		     - payrollCalculationSetName : 항상 수정가능
		     - resignationFlag : 급여 실행 전이면 수정 가능.
		     - payrollTypeCode : 급여 실행 전이면 수정 가능.
		   - 삭제
		     - 급여 실행 전이면 삭제 가능.
		*/
		if ( dataRow > -1 && dataRow < provider.getRowCount() ) {
			//급여실행결과 있는 경우 수정/삭제 불가
			if ( nvl(provider.getValue(dataRow, "execFlag")) == "Y" ) {
				cgrid.setCellStyle(dataRow, "payrollCalculationSetName", "editableStyle", true);
				cgrid.setCellStyle(dataRow, "resignationFlag", "readOnlyStyle", true);
				cgrid.setCellStyle(dataRow, "payrollTypeCode", "readOnlyStyle", true);
				cgrid.setCellStyle(dataRow, "objectType", "readOnlyStyle", true); //-- vanaa 03/11/2025
				
			//Calculation Set 대상자가 있는 경우 
			} else if ( nvl(provider.getValue(dataRow, "execFlag")) != "Y" 
						&& Calc.real(nvl(provider.getValue(dataRow, "setPersonCount")+"", "0")) > 0 ) {
				cgrid.setCellStyle(dataRow, "payrollCalculationSetName", "editableStyle", true);
				cgrid.setCellStyle(dataRow, "resignationFlag", "editableStyle", true);
				cgrid.setCellStyle(dataRow, "payrollTypeCode", "editableStyle", true);
				cgrid.setCellStyle(dataRow, "objectType", "editableStyle", true); // -- vanaa 03/11/2025
			} 
		}<%-- //if --%>
	}
}

LGVPAY00021.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00021();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2> 
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="120"/>
						<col width="250"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><lgcom:message code="label.pay.calculationSet"/></label></th>
		                    <td><input type="text" class="form-control input-sm" name="calculationSetName" /></td>		                	
		                </tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">					
				
				<div class="btn-group">		
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVPAY00021/saveCalcSet"><lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid calculationSetGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
