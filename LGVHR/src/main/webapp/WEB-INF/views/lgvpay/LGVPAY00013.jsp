<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00013.jsp
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
var LGVPAY00013 = function() {
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
    
    // 팝업 데이터 정의
	myForm.popupInfo = {
		formulaPopup     : { popupKind:'', confirmKind:'', row:'', col:'', formulaName:'', searchFlag:'', formulaData:[] }
	  , codePopup        : { popupKind:'', confirmKind:'', row:'', col:'', codeTypeCode:'', commonCode:'', commonCodeName:'', searchFlag:'', codeData:[] }
	  , payrollItemPopup : { popupKind:'', confirmKind:'', row:'', col:'', payrollItemId:'', inquiryName:'', effectiveDate:'', searchFlag:'', payrollItemData:[] }
	  , detailPopup      : { popupKind:'', confirmKind:'', payrollItemId:'' }
	  , propertyPopup    : { popupKind:'', confirmKind:'', payrollItemId:'' }
	  , usePopup         : { popupKind:'', confirmKind:'', payrollItemId:'' }
	};

    // 그리드형 테이블 TR

    // 코드 데이터 조회
	var valueset = new ValueSet("lgcom");
	valueset.add("classificationList", { valueSetId : "LGVPAY_PAY_ITEM_CLASSIFICATION_CODE_LIST", languageCode:SESSION_USER.languageCode });
	valueset.execute();
	
	var aggrItemList = {};
	myForm.transaction_sync("lgvhr", "lgvpay/LGVPAY00013/retrieveAggrItemList", {}, function(data) { 
		if ( data.result ) {
			aggrItemList = data.result;
		}
	});
	
    // 그리드선언
	var listGrid = buildGrid(".listGrid");
	
	// 콤보 초기화
	srchFormUtil.initCombo("payItemClassificationCode", valueset.get("classificationList"), {selectAll:true});
    
    // 날짜 팝업창
    srchFormUtil.setCalendar( { from : "effectiveDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    // 초기값 셋팅
    srchFormUtil.setValue( { effectiveDate : DateUtil.today("DD/MM/YYYY") } );
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	effectiveDate : {required:true}
	    },
	    messages: {
	    	effectiveDate : {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.effectiveDate'/>" />'}
	    }
    });

    // 일반함수	
    
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
				gridBase.setValue(currCell.itemIndex,'payrollItemName', "");
				gridBase.setValue(currCell.itemIndex,'endDate', DateUtil.format(DateUtil.parse("47121231", "YYYYMMDD"), "DD/MM/YYYY"));
				gridBase.setCurrent({column:'payrollItemName'});
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
				
				// 입력값 체크
				if ( !fncValidateSave() ) return ;
				
				Message.confirm( "<lgcom:message code="question.save" />", function () {
					listGrid.useProgress(true);
					listGrid.saveChanges("lgvhr", "lgvpay/LGVPAY00013/savePayrollItem", function(data) {
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
		    //detail popup
		    case "detail" :
		    	fncPopupPayrollItemDetail(gridBase);
		    	break;
		    //property popup
		    case "property" :
		    	fncPopupPayrollItemProperty(gridBase);
		    	break;
		    //use popup
		    case "use" :
		    	fncPopupPayrollItemUse(gridBase);
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
		if ( !isNull(srchFormUtil.getValue("effectiveDate")) ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Context Menu Set
		grid.setContextMenu();
		// Grid Field Set
		grid.setFields([
			{ fieldName:'payrollItemId'              , dataType:'text'  },
			{ fieldName:'payrollItemName'            , dataType:'text'  },
			{ fieldName:'inquiryName'                , dataType:'text'  },
			{ fieldName:'detailDesc'                 , dataType:'text'  },
			{ fieldName:'payItemClassificationCode'	 , dataType:'text'  },
			{ fieldName:'payItemClassificationName'  , dataType:'text'  },
			{ fieldName:'priority'                   , dataType:'number'},
			{ fieldName:'payrollCalculationFormulaId', dataType:'text'  },
			{ fieldName:'payrollCalcFormulaValue'    , dataType:'text'  },
			//{ fieldName:'payrollCalFormulaOsId'		 , dataType:'text'  },
			//{ fieldName:'payrollCalcFormulaValueOs'  , dataType:'text'  },
			{ fieldName:'isLgd'   					 , dataType:'text'  }, // is LGD -- vanaa 03/11/2025
			{ fieldName:'isOs'   					 , dataType:'text'  }, // is OS -- vanaa 03/11/2025
			{ fieldName:'paySlipDisplayTypeCode'     , dataType:'text'  },
			{ fieldName:'paySlipDisplayTypeName'     , dataType:'text'  },
			{ fieldName:'paySlipSortOrderNo'         , dataType:'number'},
			{ fieldName:'parentPayrollItemId'        , dataType:'text'  },
			{ fieldName:'parentPayrollItemName'      , dataType:'text'  },
			{ fieldName:'retroactiveFlag'         	 , dataType:'text'  },
			{ fieldName:'retroPayAggrItemCode'       , dataType:'text'  },
			{ fieldName:'retroPayAggrItemName'       , dataType:'text'  },
			{ fieldName:'owAccountGroupCode'         , dataType:'text'  },
			{ fieldName:'lwAccountGroupCode'         , dataType:'text'  },
			{ fieldName:'owAccountGroupName'         , dataType:'text'  },
			{ fieldName:'lwAccountGroupName'         , dataType:'text'  },
			{ fieldName:'startDate'                  , dataType:'text'  },
			{ fieldName:'endDate'                    , dataType:'text'  },
			{ fieldName:'delUptPossibleFlag'         , dataType:'text'  }
		]);
		//컬럼 콤보 셋팅
		grid.setLookups({
			classificationCode : valueset.get("classificationList"),
			ynFlagCode         : [ {code : "Y", name : "Y"}, {code : "N", name : "N"} ],
			aggrItemCode	   : aggrItemList,
			ynFlagOs         : [ {code : "Y", name : "Y"}, {code : "N", name : "N"} ], // vanaa 03/11/2025
		});
		
		// Grid Column Set
		grid.setColumns([
			{
				name:'payrollItemName',
				fieldName:'payrollItemName',
				width:150,
				header: {text:'<lgcom:message code="label.pay.payrollItemName"/>', required: true},
				renderer: {showTooltip: true}
			},
			{
				name:'inquiryName',
				fieldName:'inquiryName',
				width:150,
				header: {text:'<lgcom:message code="label.pay.inquiryName"/>', required: true},
				renderer: {showTooltip: true}
			},
			{
				name:'detailDesc',
				fieldName:'detailDesc',
				width:150,
				header: {text:'<lgcom:message code="Description"/>', required: true},
				renderer: {showTooltip: true}
			},
			{
				name:'payItemClassificationCode',
				fieldName:'payItemClassificationCode',
				width:150,
				header: {text:'<lgcom:message code="label.pay.classification"/>', required: true},
				renderer: {showTooltip: true},
				lookupDisplay: true,
				lookupSourceId: 'classificationCode',
				lookupKeyFields: ['payItemClassificationCode'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'priority',
				fieldName:'priority',
				width:70,
				header: {text:'<lgcom:message code="label.pay.priority"/>', required: true},
				styles: {textAlignment:'far'},
				editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#,##0'}
			},
			{
				name:'payrollCalcFormulaValue',
				fieldName:'payrollCalcFormulaValue',
				width:200,
				header: {text:'<lgcom:message code="label.pay.formula"/>'},
				renderer: {showTooltip: true},
				button: 'action',
				buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			},
			//{
			//	name:'payrollCalcFormulaValueOs',
			//	fieldName:'payrollCalcFormulaValueOs',
			//	width:200,
			//	header: {text:'<lgcom:message code="label.pay.formula_os"/>'},
			//	renderer: {showTooltip: true},
			//	button: 'action',
			//	buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			//},
			{
				name:'isLgd',
				fieldName:'isLgd',
				width:130,
				header: {text:'<lgcom:message code="label.pay.isLgd" />', required : false},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ynFlagOs',
				lookupKeyFields: ['isLgd'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'isOs',
				fieldName:'isOs',
				width:130,
				header: {text:'<lgcom:message code="label.pay.isOs" />', required : false},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ynFlagOs',
				lookupKeyFields: ['isOs'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 dropdown 버튼 보임 */
			},
			{
				name:'paySlipDisplayTypeName',
				fieldName:'paySlipDisplayTypeName',
				width:150,
				header: {text:'<lgcom:message code="label.pay.paySlipDisplayType"/>'},
				renderer: {showTooltip: true},
				button: 'action',
				buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			},
			{
				name:'paySlipSortOrderNo',
				fieldName:'paySlipSortOrderNo',
				width:80,
				header: {text:'<lgcom:message code="label.pay.paySlipSortOrderNo"/>'},
				styles: {textAlignment:'far'},
				editor: {type:'number', 'textAlignment': 'far', 'editFormat': '#,##0'}
			},
			{
				name:'parentPayrollItemName',
				fieldName:'parentPayrollItemName',
				width:180,
				header: {text:'<lgcom:message code="label.pay.parentPayrollItem"/>'},
				renderer: {showTooltip: true},
				button: 'action',
				buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			},
			{
				name:'retroactiveFlag',
				fieldName:'retroactiveFlag',
				width:70,
				header: {text:'<lgcom:message code="label.pay.retroactiveFlag"/>', required: true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'ynFlagCode',
				lookupKeyFields: ['retroactiveFlag'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible',
				renderer: {showTooltip: true}
			},
			{
				name:'retroPayAggrItemCode',
				fieldName:'retroPayAggrItemCode',
				width:120,
				header: {text:'<lgcom:message code="label.pay.retroPayAggrItem"/>'},
				lookupDisplay: true,
				lookupSourceId: 'aggrItemCode',
				lookupKeyFields: ['retroPayAggrItemCode'],
				editor: {type:'dropDown',textReadOnly:true},
				editButtonVisibility: 'visible',
				renderer: {showTooltip: true}
			},
			{
				name:'owAccountGroupName',
				fieldName:'owAccountGroupName',
				width:180,
				header: {text:'<lgcom:message code="label.pay.owAccountGr"/>'},
				renderer: {showTooltip: true},
				button: 'action',
				buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			},
			{
				name:'lwAccountGroupName',
				fieldName:'lwAccountGroupName',
				width:180,
				header: {text:'<lgcom:message code="label.pay.lwAccountGr"/>'},
				renderer: {showTooltip: true},
				button: 'action',
				buttonVisibility: 'visible' /* 포커스 있는 경우만 검색 버튼 보임 */
			},
			{
				name:'startDate',
				fieldName:'startDate',
				width:100,
				header: {text:'<lgcom:message code="StartDate"/>', required: true},
				styles: {textAlignment:'center'},
				editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
			},
			{
				name:'endDate',
				fieldName:'endDate',
				width:100,
				header: {text:'<lgcom:message code="EndDate"/>', required: true},
				styles: {textAlignment:'center'},
				editor: {type:'date',datetimeFormat:'dd/MM/yyyy', maxLength:10},
				editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
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

		// Validation Set		
		grid.setValidations([
			{criteria: "value['payrollItemName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payrollItemName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['inquiryName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.inquiryName'/>"/>',mode:'always',level:'error'},
			{criteria: "value['detailDesc'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Description'/>"/>',mode:'always',level:'error'},
			{criteria: "value['payItemClassificationCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.classification'/>"/>',mode:'always',level:'error'},
			{criteria: "value['priority'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.priority'/>"/>',mode:'always',level:'error'},
			{criteria: "value['startDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='StartDate'/>"/>',mode:'always',level:'error'},
			{criteria: "value['endDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EndDate'/>"/>',mode:'always',level:'error'}
		]);		
		return grid;
	}
	listGrid.getGridBase().addCellStyle("readOnlyStyle", {editable:false, background:"#e9e9e9"}, true);/* 수정불가능한 경우 배경색을 구분해서 보여줘야 함 */
	listGrid.getGridBase().addCellStyle("editableStyle", {editable:true, background:"#FFFFFF"}, true);/* 사용자가 입력하는 경우 사용할 스타일. 수정 가능해야하고, 배경색도 수정 가능한 상태로 보여줘야 함 */
	// 행 변경 시 이벤트
	listGrid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created' || provider.getValue(newRow, "delUptPossibleFlag") == 'Y';
		
		//셀 수정 여부 셋팅
		fncSetEditableControl(cgrid, provider, newRow, (editable?"Y":""));
		
		//Detail, Property, Use 버튼 활성화 처리
		if ( newRow < 0 || provider.getRowState(newRow) === 'created' || isNull(provider.getValue(newRow, "payrollItemId")) ) {//선택된 행이 없거나, 신규행인 경우(신규행은 급여항목ID없음) detail 버튼 disable
			myForm.select("button[data-action='detail']").attr("disabled", "disabled");
			myForm.select("button[data-action='property']").attr("disabled", "disabled");
			myForm.select("button[data-action='use']").attr("disabled", "disabled");
		} else {
			myForm.select("button[data-action='detail']").removeAttr("disabled");
			myForm.select("button[data-action='property']").removeAttr("disabled");
			myForm.select("button[data-action='use']").removeAttr("disabled");
		}
	};
	//코드 팝업에서 선택된 값 세팅 시 필요한 code, name 컬럼 정의
	var popupColumns = { 
			payrollCalcFormulaValue : { popupType:'FORMULA'    , code:'payrollCalculationFormulaId', name:'payrollCalcFormulaValue'}
	      , parentPayrollItemName   : { popupType:'PAYROLLITEM', code:'parentPayrollItemId'        , name:'parentPayrollItemName'}
	      , paySlipDisplayTypeName  : { popupType:'CODE', codeTypeCode:'LGDVH_PAY_SLIP_INQ_2ND_TYPE_CODE', code:'paySlipDisplayTypeCode', name:'paySlipDisplayTypeName'}
          , owAccountGroupName      : { popupType:'CODE', codeTypeCode:'LGDVH_PAY_ITEM_ACC_GROUP_CODE'   , code:'owAccountGroupCode'    , name:'owAccountGroupName'}
          , lwAccountGroupName      : { popupType:'CODE', codeTypeCode:'LGDVH_PAY_ITEM_ACC_GROUP_CODE'   , code:'lwAccountGroupCode'    , name:'lwAccountGroupName'}
	};
	//그리드 팝업버튼 클릭시 이벤트
	listGrid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		
		if ( column.name == "payrollCalcFormulaValue" ) {//formula
			fncPopupFormula(cgrid, itemIndex, column.name);
		}
		else if ( column.name == "payrollCalcFormulaValueOs" ) {//formula
			fncPopupFormulaOs(cgrid, itemIndex, "payrollCalcFormulaValue");
		}else if ( column.name == "parentPayrollItemName" ) {//parent payroll item
			fncPopupPayrollItem(cgrid, itemIndex, column.name);
		} else if ( popupColumns[column.name] ) {//공통코드
			fncPopupCommonCode(cgrid, itemIndex, column.name);
		}
	};
	listGrid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	}
	// 입력한 값이 셀에 반영될 때 이벤트
	listGrid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		<%--[PARAMETER]
	    	- cgrid : grid.getGridBase()
	    	- index : 클릭된 데이터 셀의 인덱스.
	                  - index.itemIndex : 그리드의 row index.gridBase에서 사용.
	                  - index.dataRow : 조회한 데이터셋의 row index. dataProvider에서 사용.
	        - oldValue : 편집 전 셀의 데이터 값
	        - newValue : 편집 후 셀의 데이터 값
		--%>
	    //입력 셀 값을 지운 경우 팝업에서 선택한 코드와 명칭 모두 지우도록 처리
	    if ( isNull(newValue) && nvl(cgrid.getColumnProperty(index.fieldName, "button")) == "action" ) {	    	
	    	cgrid.setValue(index.itemIndex, popupColumns[index.fieldName]["code"], "");
	    	cgrid.setValue(index.itemIndex, popupColumns[index.fieldName]["name"], "");
	    }
	}
	//formula popup호출
	function fncPopupFormula(cgrid, itemIndex, colName) {
		var popupData = myForm.popupInfo.formulaPopup;

		popupData.row         = itemIndex;
		popupData.col         = colName;
		popupData.formulaName = cgrid.getValue(itemIndex, colName);
		popupData.searchFlag  = "Y";
		popupData.formulaData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1032','<lgcom:message code="label.pay.formula"/>');
		popup.setSize(512,412);
		popup.open(function() {
			if ( popupData.formulaData != undefined && popupData.formulaData.length > 0 ) {
				var selectData = popupData.formulaData[0];
				cgrid.setValue(popupData.row, "payrollCalcFormulaValue"    , selectData.payrollCalcFormulaValue);
				cgrid.setValue(popupData.row, "payrollCalculationFormulaId", selectData.payrollCalculationFormulaId);
				cgrid.commit();
			}
		});
	}
	
	function fncPopupFormulaOs(cgrid, itemIndex, colName) {
		debugger;
		var popupData = myForm.popupInfo.formulaPopup;

		popupData.row         = itemIndex;
		popupData.col         = colName;
		popupData.formulaName = cgrid.getValue(itemIndex, colName);
		popupData.searchFlag  = "Y";
		popupData.formulaData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1032','<lgcom:message code="label.pay.formula"/>');
		popup.setSize(512,412);
		popup.open(function() {
			if ( popupData.formulaData != undefined && popupData.formulaData.length > 0 ) {
				var selectData = popupData.formulaData[0];
				cgrid.setValue(popupData.row, "payrollCalcFormulaValueOS", selectData.payrollCalcFormulaValue);
				cgrid.setValue(popupData.row, "payrollCalFormulaOsId", selectData.payrollCalculationFormulaId);
				cgrid.commit();
			}
		});
	}
	//code popup호출
	function fncPopupCommonCode(cgrid, itemIndex, colName) {
		var popupData = myForm.popupInfo.codePopup;

		popupData.row            = itemIndex;
		popupData.col            = colName;
		popupData.commonCodeName = cgrid.getValue(itemIndex, colName);
		popupData.codeTypeCode   = popupColumns[colName]["codeTypeCode"];
		popupData.searchFlag     = "Y";
		popupData.codeData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1033', cgrid.getColumnProperty(colName, "header").text);
		popup.setSize(512,412);
		popup.open(function() {
			if ( popupData.codeData != undefined && popupData.codeData.length > 0 ) {
				var selectData = popupData.codeData[0];
				cgrid.setValue(popupData.row, popupColumns[colName]["code"], selectData.commonCode);
				cgrid.setValue(popupData.row, popupColumns[colName]["name"], selectData.commonCodeName);
				cgrid.commit();
			}
		});
	}
	//parent payroll item popup호출
	function fncPopupPayrollItem(cgrid, itemIndex, colName) {
		var popupData = myForm.popupInfo.payrollItemPopup;

		popupData.row             = itemIndex;
		popupData.col             = colName;
		popupData.inquiryName     = cgrid.getValue(itemIndex, colName);
		popupData.effectiveDate   = srchFormUtil.getValue("effectiveDate");
		popupData.searchFlag      = "Y";
		popupData.payrollItemData = [];

		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1031','<lgcom:message code="label.pay.payrollItem"/>');
		popup.setSize(812, 412);
		popup.open(function() {
			if ( popupData.payrollItemData != undefined && popupData.payrollItemData.length > 0 ) {
				var selectData = popupData.payrollItemData[0];
				cgrid.setValue(popupData.row, "parentPayrollItemId"  , selectData.payrollItemId);
				cgrid.setValue(popupData.row, "parentPayrollItemName", selectData.inquiryName);
				cgrid.commit();
			}
		});
	}
	//parent payroll item Detail popup호출
	function fncPopupPayrollItemDetail(gridBase) {
		//detail 버튼 비활성화 아닌 경우 처리
		if ( myForm.select("button[data-action='detail']").attr("disabled") != "disabled" ) {
			var itemIndex = gridBase.getCurrent().itemIndex;
			if ( isNull(gridBase.getValue(itemIndex, "payrollItemId")) ) {//급여항목ID가 없는 경우
				Message.alert("<lgcom:message code="note.noselected"/>");
			} else {
				var popupData = myForm.popupInfo.detailPopup;
				popupData.payrollItemId = gridBase.getValue(itemIndex, "payrollItemId");
				
				var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1034','<lgcom:message code="label.pay.detail"/>');
				popup.setSize(512, 400);
				popup.open(function() {
					myForm.select("button[data-action='detail']").attr("disabled", "disabled");
				});
			}
		}
	}
	//parent payroll item Property popup호출
	function fncPopupPayrollItemProperty(gridBase) {
		//property 버튼 비활성화 아닌 경우 처리
		if ( myForm.select("button[data-action='property']").attr("disabled") != "disabled" ) {
			var itemIndex = gridBase.getCurrent().itemIndex;
			if ( isNull(gridBase.getValue(itemIndex, "payrollItemId")) ) {//급여항목ID가 없는 경우
				Message.alert("<lgcom:message code="note.noselected"/>");
			} else {
				var popupData = myForm.popupInfo.propertyPopup;
				popupData.payrollItemId = gridBase.getValue(itemIndex, "payrollItemId");
		
				var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1035', '<lgcom:message code="label.pay.property"/>');
				popup.setSize(512, 400);
				popup.open(function() {
					myForm.select("button[data-action='property']").attr("disabled", "disabled");
				});
			}
		}
	}
	//parent payroll item Use popup호출
	function fncPopupPayrollItemUse(gridBase) {
		//use 버튼 비활성화 아닌 경우 처리
		if ( myForm.select("button[data-action='use']").attr("disabled") != "disabled" ) {
			var itemIndex = gridBase.getCurrent().itemIndex;
			if ( isNull(gridBase.getValue(itemIndex, "payrollItemId")) ) {//급여항목ID가 없는 경우
				Message.alert("<lgcom:message code="note.noselected"/>");
			} else {
				var popupData = myForm.popupInfo.usePopup;
				popupData.payrollItemId = gridBase.getValue(itemIndex, "payrollItemId");
		
				var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1036', '<lgcom:message code="label.pay.use"/>');
				popup.setSize(512, 400);
				popup.open(function() {
					myForm.select("button[data-action='use']").attr("disabled", "disabled");
				});
			}
		}
	}
	//저장전 입력값 체크
	function fncValidateSave() {
		var cgrid = listGrid.getGridBase();
		var provider = cgrid.getDataProvider();
		
		//신규 또는 수정 건 체크
		var rowIdxs = provider.getStateRows("created").concat(provider.getStateRows("updated"));//dataRow배열값
		if ( rowIdxs ) {
			for ( var i=0; i<rowIdxs.length; i++ ) {
				var rowData = provider.getJsonRow(rowIdxs[i]);

				//건별 체크
				// 팝업 컬럼인 경우 code값 없이 name만 있는 경우 오류
				for ( var key in popupColumns ) {
					if ( (isNull(rowData[popupColumns[key]["code"]]) && !isNull(rowData[popupColumns[key]["name"]])) ) {
						var args = cgrid.getColumnProperty(key, 'header').text;
						Message.alert("<lgcom:message code="error.mustSelected" arguments='"+args+"' />");
						cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:key});
						cgrid.setFocus();
						return false;
					}	
				}<%-- //for --%>
				
				//시작일 체크
				if ( !fncValidateDateFormat(rowData.startDate) ) {
					Message.alert("<lgcom:message code="error.incorrectFormat" />");
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"startDate"});
					cgrid.setFocus();
					return false;
				}
				
				//종료일 체크
				if ( !fncValidateDateFormat(rowData.endDate) ) {
					Message.alert("<lgcom:message code="error.incorrectFormat" />");
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"endDate"});
					cgrid.setFocus();
					return false;
				}
				
				//시작일, 종료일 체크
				if ( DateUtil.parse(rowData.startDate, "DD/MM/YYYY") > DateUtil.parse(rowData.endDate, "DD/MM/YYYY") ) {
					Message.alert("<lgcom:message code="error.DataRangePickerFromDate" />");
					cgrid.setCurrent({itemIndex: cgrid.getItemIndex(rowIdxs[i]), column:"startDate"});
					cgrid.setFocus();
					return false;
				}
				
			}<%-- //for --%>
		}<%-- //if --%>
		
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
		var arrExceptColumns = ["inquiryName", "detailDesc", "paySlipDisplayTypeCode", "paySlipDisplayTypeName", "paySlipSortOrderNo"
		                      , "parentPayrollItemId", "parentPayrollItemName", "owAccountGroupCode", "owAccountGroupName", 
		                      , "lwAccountGroupCode", "lwAccountGroupName", "endDate", "retroactiveFlag", "retroPayAggrItemCode"];//상시 수정가능 컬럼명
		
		if ( dataRow > -1 && dataRow < provider.getRowCount() ) {
			//수정, 삭제 가능여부에 따라 수정 또는 조회 스타일 셋팅
			editFlag = (nvl(editFlag, "N") == "Y" || nvl(provider.getValue(dataRow, "delUptPossibleFlag"), "N") == "Y")?"Y":"N";
			
			for ( var i=0; i<fieldNames.length; i++ ) {
				if(fieldNames[i] == "isOs"){
					continue;
				}
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
				/*
				//button=action인 경우만 수정 가능여부에 따라 button보여줄지 설정한다.
				if ( nvl(cgrid.getColumnProperty(fieldNames[i], "button")) == "action" ) {
					cgrid.setColumnProperty(fieldNames[i], "buttonVisibility", editFlag=="Y"?'visible':'hidden');
				}*/
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
		listGrid.loadData("lgvhr", "lgvpay/LGVPAY00013/retrievePayrollItemList", srchFormUtil.getValue(), function (data) {
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

LGVPAY00013.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00013();
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
		                	<th><label><lgcom:message code="label.pay.payrollItemName" /></label></th>
							<td><input type="text" class="form-control input-sm" name="payrollItemName" /></td>
		                	<th><label><lgcom:message code="label.pay.inquiryName" /></label></th>
							<td><input type="text" class="form-control input-sm" name="inquiryName" /></td>
		                	<td></td>
		                </tr>
						<tr>
		                	<th><label><lgcom:message code="label.pay.classification" /></label></th>
		                	<td><select class="form-control input-sm" name="payItemClassificationCode" ></select></td>
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
		<%-- //searchBlock --%>
		
		<div class="buttonControlBlock module-group text-right">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-gray btn-sm" type="button" role="button" data-action="detail" disable><lgcom:message code="Detail"/></button>
					<button class="btn btn-gray btn-sm" type="button" role="button" data-action="property" disable><lgcom:message code="button.pay.property"/></button>
					<button class="btn btn-gray btn-sm" type="button" role="button" data-action="use" disable><lgcom:message code="button.pay.use"/></button>
				</div>
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
