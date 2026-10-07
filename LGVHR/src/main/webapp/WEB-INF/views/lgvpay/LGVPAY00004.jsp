<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00004.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 급여항목별 개인조회, 수정
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<script type="text/javascript">
var LGVPAY00004 = function() {
	var myForm = this;
    var _this = this;
    var date = new Date();
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollItemName: {required:true},
	    	payrollCalcPeriodValue : { required : true, monthYear : true }
	    },
	    messages: {
	    	payrollItemName: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payrollItem'/>" />'},
	    	payrollCalcPeriodValue : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear : '<lgcom:message code="error.incorrectFormat" />'}
	    }
    });
  
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
	
 	// 그리드 선언
	var grid = buildGrid('.payItemIndividualGrid');
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	//그리드 가변 컬럼 헤더명 초기화
	clearGridHeader();
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		payrollItemPopup   : {popupKind:'', confirmKind:'', payrollCalcPeriodValue:'', payRollItemId:'', payRollItemName:'', payrollItemData:[]},
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	//검색조건 기본값 셋팅
	srchFormUtil.setValue({ payrollCalcPeriodValue : DateUtil.today("MM/YYYY") });
	
	myForm.addEvent( "change", ".searchBlock .form input[name=payrollCalcPeriodValue]" , function(event){
		grid.clear();
	});	
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		var payrollItemId = srchFormUtil.getValue("payrollItemId");
		var payMonth = srchFormUtil.getValue("payrollCalcPeriodValue");
		var payrollItemName = srchFormUtil.getValue("payrollItemName");
		
		switch( action ) {
		case 'search':
			grid.getGridBase().cancel();
			var param = srchFormUtil.getValue();
			var payrollApplyFlagYn = false;
			if(validator.isValid()) {
				myForm.select("button[data-action='deleteAll']").prop("disabled", true);
				clearGridHeader();
				grid.loadData("lgvhr", "lgvatt/LGVPAY00004/retrieveIndividualPayItemList", srchFormUtil.getValue(), function(data) {
					if( data.result.length > 0 ) {
						//payrollApplyFlag == Y인 경우만 Delete All 비활성화
						if ( nvl(data.result[0].payrollApplyFlag) == "Y" ) {
							myForm.select("button[data-action='deleteAll']").prop("disabled", true);
						} else {
							myForm.select("button[data-action='deleteAll']").prop("disabled", false);
						}
						
						for ( var i=1; i<=10; i++ ) {
							if ( nvl(data.result[0]["inputType"+i]) == "A" || nvl(data.result[0]["inputType"+i]) == "N" ) {//숫자컬럼인 경우
								//숫자 컬럼 보임
								grid.getGridBase().setColumnProperty("inputValue"+i, "header", { text: data.result[0]["inputName"+i] });
								grid.getGridBase().setColumnProperty("inputValue"+i, "visible", true);
								
								//문자 컬럼 숨김
								grid.getGridBase().setColumnProperty("inputValueTxt"+i, "header", { text:" "});
								grid.getGridBase().setColumnProperty("inputValueTxt"+i, "visible", false);
							} else {
								//숫자 컬럼 숨김
								grid.getGridBase().setColumnProperty("inputValueTxt"+i, "header", { text:" "});
								grid.getGridBase().setColumnProperty("inputValue"+i, "visible", false);
								
								//문자 컬럼 보임
								grid.getGridBase().setColumnProperty("inputValueTxt"+i, "header", { text: data.result[0]["inputName"+i] });
								grid.getGridBase().setColumnProperty("inputValueTxt"+i, "visible", true);
							}
						}
					}else{
						if( grid.getRowCount() == 0 ) {
							Message.alert('<lgcom:message code="note.nodata"/>');
						}
					}
				});
			}
			
			break;
		case 'save':
			var grid1 = grid.getGridBase();
			var param = {};
			var empMap = new Map();
			var isDupFlag = false;
			
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			if(!grid.isChanged()) {
				Message.alert('<lgcom:message code="error.noChangedData"/>');
				return;
			}
			
			//var gridArr = fncArrangeMultiLineGridAll(grid);
			//param["empList"] = gridArr;
		
			if(isNull(payrollItemId)) {
				Message.alert('<lgcom:message code="note.pay.searchCalSet"/>');
				return;
			}
			var isValid = true;
			for(var i=0; i < grid1.getItemCount(); i++) {
				if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'updated') {
					var startDateArr = grid1.getValue(i,'applyStartDate').split('/');
					var endDateArr = grid1.getValue(i,'applyEndDate').split('/');
					
					var startDateCompare = new Date(startDateArr[2], parseInt(startDateArr[1])-1, startDateArr[0]);
					var endDateCompare = new Date(endDateArr[2], parseInt(endDateArr[1])-1, endDateArr[0]);

					if(startDateCompare.getTime() > endDateCompare.getTime()) {
						isValid = false;
					}
				}
			}
			if(!isValid) {
				Message.alert('<lgcom:message code="note.pay.checkApplyDate"/>');
				return;
			}else{
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvpay/LGVPAY00004/saveIndividualPayItem', function(data, gridData ) {
						Message.alert('<lgcom:message code="note.saved"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
			}
			
		break;	
		case 'deleteAll':
			var param = srchFormUtil.getValue();
			if(validator.isValid()) {
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}else{
					Message.confirm('<lgcom:message code="note.pay.allDelete" arguments="'+payMonth+','+payrollItemName+'"/>',function() {
						myForm.transaction("lgvhr", "lgvatt/LGVPAY00004/saveAllIndividualPayItem", param, function( data ){
							Message.alert('<lgcom:message code="note.deleted"/>');
							myForm.select(".searchBlock button[data-action='search']").trigger('click');
						});
					}); 
				}
			}
			
			break;	
		case 'delete':
			grid.getGridBase().deleteSelection(true);
			break; 
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					
					//조회된 데이터가 없을경우 업로드를 하기위하여 엑셀로 기본틀만 다운로드 받게함.
					if( grid.getRowCount() == 0 ) {
						var downloader = new Downloader( myForm );
						downloader.excel( "lgvhr", "lgvpay/LGVPAY00004/createExcelDownloadHeadData", srchFormUtil.getValue());
					}else{
							var downloader = new Downloader( myForm );
							downloader.excel( "lgvhr", "lgvpay/LGVPAY00004/createExcelExportData", srchFormUtil.getValue());
					}
				}); 
			}
		break;
		case 'excelUpload':
			if(validator.isValid()) {
				var uploader = new ExcelUploader("lgvhr", "LGVPAY00004", {});
                uploader.open(  processExcelUploadPostProcess );
			}
			
			break;
		//payrollItem 검색팝업
	    case "openPopupPayrollItem" :
            var _popup = _this.popupInfo.payrollItemPopup;
            _popup.popupKind    = "";
            _popup.confirmKind  = "";
            _popup.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
            
            grid.clear(); 
        	srchFormUtil.setValue({payrollItemId : '', payrollItemName : ''});
        	
            var popup = new Popup( _this,'lgvhr', 'M_LGVPAY_1020', '<lgcom:message code="label.pay.payrollItem"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({payrollItemId  :_popup.payrollItemData[0].payrollItemId});
            	srchFormUtil.setValue({payrollItemName   :_popup.payrollItemData[0].inquiryName});
            });
            _popup.payrollItemData = [];
        break;
     	// 유저 검색 팝업
	    case "openPopupApprover" :
            console.log("openPopupApprover");
            var _popup = _this.popupInfo.userPopup;
            _popup.searchMode   = "single";
            _popup.popupKind    = "";
            _popup.confirmKind  = "";
            _popup.employeeNo = srchFormUtil.getValue("employeeNo");
            _popup.employeeName = srchFormUtil.getValue("employeeName");
            _popup.fseYn = "N";
            _popup.flsaYn = "N";
        	fncSearchEmpInfoInit();

            var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
            	srchFormUtil.setValue({employeeName   :_popup.userData[0].employeeName});
            });
            _popup.userData = [];
            break;
			
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});

	//applyEndDate 수정
	grid.getGridBase().onDataCellClicked = function(cgrid, index) {
		var current = cgrid.getCurrent();
		if (current == undefined ) { return; }
		var gridRow = cgrid.getValues(current.itemIndex);
		
		//Recuring = ‘Y’인 항목만 applyEndDate 수정가능하게 함
		if(gridRow.payrollApplyFlag == "Y") {
			cgrid.setColumnProperty('applyEndDate','editable',true);
			//myForm.select("button[data-action='deleteAll']").prop("disabled", true);
		}else{
			cgrid.setColumnProperty('applyEndDate','editable',false);
			//myForm.select("button[data-action='deleteAll']").prop("disabled", false);
		}
	}
	//수정한 값이 퇴직일자이후이면 퇴직일자로 입력하게 하고 그외에는 제한 없음
	grid.getGridBase().onCellEdited = function(cgrid, itemIndex, dataRow, colIndex) {
		if($.trim(cgrid.getValue(itemIndex,'dateRetire')) != "") {
			var dateRetireVal = cgrid.getValue(itemIndex,'dateRetire').split("/");
			var applyEndDateVal = cgrid.getValue(itemIndex,'applyEndDate').split("/");
			
			var dateRetireCompare = new Date(dateRetireVal[2], parseInt(dateRetireVal[1])-1, dateRetireVal[0]);
			var applyEndDateCompare = new Date(applyEndDateVal[2], parseInt(applyEndDateVal[1])-1, applyEndDateVal[0]);
			
			if(dateRetireCompare.getTime() < applyEndDateCompare.getTime()) {
				cgrid.setValue(itemIndex, 'applyEndDate', cgrid.getValue(itemIndex,'dateRetire'));
			}
		}
	};
	function clearGridHeader() {
		for ( var i=1; i<=10; i++ ) {
			grid.getGridBase().setColumnProperty("inputValue"+i, "header", { text: " "});
			grid.getGridBase().setColumnProperty("inputValueTxt"+i, "header", { text: " "});	
		}
	}
	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		param.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
		param.payrollItemId = srchFormUtil.getValue("payrollItemId");
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVPAY00004/createIndividualPayItemUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	$("input[name=employeeNo]").keydown(function (key) {
		if(key.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
	//사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	//fncSearchEmpInfoInit();
    });
	myForm.addEvent ( "change",".searchBlock form input[name='employeeNo'], input[name='employeeName']",function(event) {
		//myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		var item = $(event.target);
		switch ( $.trim(item.attr("name")) ) {
			case "employeeNo" :
				//사번이 변경된 경우 성명 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") || isNull(srchFormUtil.getValue("employeeNo")) ) {
					srchFormUtil.setValue({employeeName:""});
				}
			
				//검색조건 사번이 있는 경우 임직원 검색 팝업 호출
				if ( !isNull(srchFormUtil.getValue("employeeNo")) ) {
					//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				}
				break;
			case "employeeName" :
				//성명이 변경된 경우 사번 초기화 처리
				if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") || isNull(srchFormUtil.getValue("employeeName")) ) {
					srchFormUtil.setValue({employeeNo:""});
				}
			
				//검색조건 성명이 있는 경우 임직원 검색 팝업 호출
				if ( !isNull(srchFormUtil.getValue("employeeName")) ) {
					//fncPopupEmployeeSearch();//사번 또는 성명 값 변경되는 경우 임직원 검색
				}
				break;
		}
		event.stopPropagation();
	});
	myForm.addEvent ( "keyup",".searchBlock form input[name='employeeNo'], input[name='employeeName']",function(event) {
		if ( event.keyCode == 13 ) {//enter key
			switch ( $.trim($(event.target).attr("name")) ) {
			case "employeeNo":
				if ( srchFormUtil.getPreviousValue("employeeNo") != srchFormUtil.getValue("employeeNo") ) {
					srchFormUtil.setValue("employeeName", "");
				}
				break;
			case "employeeName":
				if ( srchFormUtil.getPreviousValue("employeeName") != srchFormUtil.getValue("employeeName") ) {
					srchFormUtil.setValue("employeeNo", "");
				}
				break;
			}
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
		event.stopPropagation();
	});
	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'payrollItemPaymentPlanId' , dataType:'text'},
		    { fieldName: 'payrollItemId' 		, dataType:'text'},
		    { fieldName: 'employeeNo'  			, dataType:'text'},
		    { fieldName: 'employeeName'         , dataType:'text'},
		    { fieldName: 'organization'         , dataType:'text'},
		    { fieldName: 'applyStartDate'    	, dataType:'text'},
		    { fieldName: 'applyEndDate'         , dataType:'text'},
		    { fieldName: 'retroactiveFlag'      , dataType:'text'},
		    { fieldName: 'payrollApplyFlag'     , dataType:'text'},
		    { fieldName: 'dateRetire'     		, dataType:'text'},
		    { fieldName: 'inputId1'         	, dataType:'text'},
		    { fieldName: 'inputName1'         	, dataType:'text'},
		    { fieldName: 'inputValue1'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt1'      	, dataType:'text'},
		    { fieldName: 'inputId2'         	, dataType:'text'},
		    { fieldName: 'inputName2'         	, dataType:'text'},
		    { fieldName: 'inputValue2'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt2'      	, dataType:'text'},
		    { fieldName: 'inputId3'         	, dataType:'text'},
		    { fieldName: 'inputName3'         	, dataType:'text'},
		    { fieldName: 'inputValue3'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt3'      	, dataType:'text'},
		    { fieldName: 'inputId4'         	, dataType:'text'},
		    { fieldName: 'inputName4'         	, dataType:'text'},
		    { fieldName: 'inputValue4'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt4'      	, dataType:'text'},
		    { fieldName: 'inputId5'         	, dataType:'text'},
		    { fieldName: 'inputName5'         	, dataType:'text'},
		    { fieldName: 'inputValue5'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt5'      	, dataType:'text'},
		    { fieldName: 'inputId6'         	, dataType:'text'},
		    { fieldName: 'inputName6'         	, dataType:'text'},
		    { fieldName: 'inputValue6'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt6'      	, dataType:'text'},
		    { fieldName: 'inputId7'         	, dataType:'text'},
		    { fieldName: 'inputName7'         	, dataType:'text'},
		    { fieldName: 'inputValue7'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt7'      	, dataType:'text'},
		    { fieldName: 'inputId8'         	, dataType:'text'},
		    { fieldName: 'inputName8'         	, dataType:'text'},
		    { fieldName: 'inputValue8'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt8'      	, dataType:'text'},
		    { fieldName: 'inputId9'         	, dataType:'text'},
		    { fieldName: 'inputName9'         	, dataType:'text'},
		    { fieldName: 'inputValue9'         	, dataType:'number'},
		    { fieldName: 'inputValueTxt9'      	, dataType:'text'},
		    { fieldName: 'inputId10'         	, dataType:'text'},
		    { fieldName: 'inputName10'         	, dataType:'text'},
		    { fieldName: 'inputValue10'         , dataType:'number'},
		    { fieldName: 'inputValueTxt10'     	, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
 				{
					name:'payrollItemPaymentPlanId',
					fieldName:'payrollItemPaymentPlanId',
					width:0,
					header: {text:''},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'payrollItemId',
					fieldName:'payrollItemId',
					width:0,
					header: {text:''},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:100,
					header: {text:'<lgcom:message code="label.pay.employeeNo" />'},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'employeeName',
					fieldName:'employeeName',
					width:200,
					header: {text:'<lgcom:message code="label.pay.employeeName" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'organization',
					fieldName:'organization',
					width:250,
					header: {text:'<lgcom:message code="label.pay.organization"/>'},
					styles: {textAlignment:'near'},
					editable : false
				},	
				{
					name:'applyStartDate',
					fieldName:'applyStartDate',
					width:100,
					header: {text:'<lgcom:message code="label.pay.applyStartDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'applyEndDate',
					fieldName:'applyEndDate',
					width:100,
					header: {text:'<lgcom:message code="label.pay.applyEndDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date', datetimeFormat:'dd/MM/yyyy', maxLength:10},
					/*editable : false,*/
					editButtonVisibility: 'visible' /* 포커스 있는 경우만 날짜 버튼 보임 */
				},	
				{
					name:'retroactiveFlag',
					fieldName:'retroactiveFlag',
					width:70,
					header: {text:'<lgcom:message code="label.pay.retroactiveFlag" />'},
					styles: {textAlignment:'center'},
					editable : false,
				},
				{
					name:'payrollApplyFlag',
					fieldName:'payrollApplyFlag',
					width:0,
					header: {text:'<lgcom:message code="label.pay.recurringYn" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'dateRetire',
					fieldName:'dateRetire',
					width:0,
					header: {text:''},
					styles: {textAlignment:'center'},
					editable : false
				},
				{name:'inputId1', fieldName:'inputId1', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue1', fieldName:'inputValue1', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt1', fieldName:'inputValueTxt1', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId2', fieldName:'inputId2', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue2', fieldName:'inputValue2', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt2', fieldName:'inputValueTxt2', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId3', fieldName:'inputId3', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue3', fieldName:'inputValue3', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt3', fieldName:'inputValueTxt3', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId4', fieldName:'inputId4', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue4', fieldName:'inputValue4', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt4', fieldName:'inputValueTxt4', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId5', fieldName:'inputId5', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue5', fieldName:'inputValue5', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt5', fieldName:'inputValueTxt5', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId6', fieldName:'inputId6', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue6', fieldName:'inputValue6', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt6', fieldName:'inputValueTxt6', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId7', fieldName:'inputId7', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue7', fieldName:'inputValue7', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt7', fieldName:'inputValueTxt7', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId8', fieldName:'inputId8', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue8', fieldName:'inputValue8', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},	
				{name:'inputValueTxt8', fieldName:'inputValueTxt8', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId9', fieldName:'inputId9', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue9', fieldName:'inputValue9', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt9', fieldName:'inputValueTxt9', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false},
				{name:'inputId10', fieldName:'inputId10', width:0, type: 'data', header: {text:''}, styles: {textAlignment:'center'}, editable : false},		
				{name:'inputValue10', fieldName:'inputValue10', width:100, type: 'data', header: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}, styles: {textAlignment:'far', numberFormat: '#,###'}, editable : false},
				{name:'inputValueTxt10', fieldName:'inputValueTxt10', width:100, type: 'data', header: {text:''}, styles: {textAlignment:'near'}, editable : false, visible:false}
		]);

		//옵션 설정
		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				/* 상단 합계 표시 */
				header: {summary: {visible: true, 
					               styles: {background: "#e9e9e9",
					            	        borderLeft : "#dfdfdf,1",
					            	        borderRight : "#dfdfdf,1",
					            	        borderTop : "#dfdfdf,1",
					        				borderBottom : "#dfdfdf, 1",
					        				fontSize : 12,
					        				fontBold : "false",
					        				paddingLeft : 5,
					        				paddingRight : 5
					            	       }
				                    },
			             height:30
			            },
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
                sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
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

		return grid;
	}
}

LGVPAY00004.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00004();
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
						<col width="180"/>
						<col width="120"/>
						<col width="150"/>
						<col width="250"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.payMonth"/></label></th>
		                    <td>
		                		<div class="input-group input-group-sm input-search">
	                                <input type="text" class="form-control input-sm input-require size_70" name="payrollCalcPeriodValue" data-action="change" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" />
	                            </div>
		                	</td>
		                	<th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.payrollItem"/></label></th> 
		                    <td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="payrollItemId" />
	                                <input type="text" class="form-control input-sm input-require" name="payrollItemName" readonly/>
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupPayrollItem">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                </tr>
		                <tr>
		                	<th><label><lgcom:message code="label.pay.employeeNo" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text" data-action="emptyAndPopup">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
							<th><label><lgcom:message code="label.pay.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>
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
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
			     </div>
				<div class="btn-group">
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload"><span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				</div>
				<div class="btn-group">		
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="deleteAll" disabled><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="Delete All"/></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVPAY00004/saveIndividualPayItem"><lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid payItemIndividualGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
