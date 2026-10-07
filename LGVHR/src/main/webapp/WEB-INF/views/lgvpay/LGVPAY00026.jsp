<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00026.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Send PaySlip By Email.
    작성자 : HaMinhThuy	
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Send PaySlip</title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
.module-group .form-group .input-group .input-group-btn {
	display:table-cell;/* 버튼영역에서 검색 box 사용하기 위한 스타일 */
}
.module-group .fa-search {
    font-size: 14px;/* 검색버튼 크기 셋팅 */
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00026 = function() {
	var myForm = this;
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	myForm.select("button[data-action='printAllNoLine']").hide();
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "runGridBlock" },
		{ name : "runGridBlock",       left : 0, right : 0, top : "buttonControlBlock", bottom : 0 }
	]);

    // 그리드선언
	var runGrid = buildGrid(".runGrid");

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		sendByEmployeePopup : { payrollCalcPeriodValue:'', payrollCalculationExecIdList:[] , payMonthList:[] , payMonthNameList:[]},
		calculationPopup : { popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[] }
    };

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
	
	// 콤보 초기화
	
    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalcPeriodValue : { required : true, monthYear : true }
	    },
	    messages: {
	    	payrollCalcPeriodValue : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear           : '<lgcom:message code="error.incorrectFormat" />'}
	    }
    });

    // 일반함수	
    
    // Event 처리
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}                                                                                                                                                                                                                                             
		var action = $.trim(item.data('action'));
		switch( action ){
			case "search" :
				if ( validator.isValid() ) {
					fncRetrievePayrollRunList();
				}
				break;
	            
		    case "sendAll" :
		    	//급여명세서 일괄 출력
		    	fncSendAll();
		    	break;
		    	
		    case "createPDFAll" :
		    	fncCreatePDFAll();
		    	break;
		    
		    case "createPDFBySet" :
		    	fncCreatePDFBySet();
		    	break;
		    	
		    case "deletePDFAll" :
		    	fncDeletePDFAll();
		    	break;

		    case "sendByEmployee" :
		    	fncPopupSendByEmployee();
		    	break;
		    	
			// 급여대상자 SET 조회 팝업
		    case "openPopupCalSet" :
	            var popupData = myForm.popupInfo.calculationPopup;
	            popupData.popupKind    = "";
	            popupData.confirmKind  = "";
	            popupData.calculationSetName = srchFormUtil.getValue("payrollCalcPeriodValue");

	            myForm.select(".buttonControlBlock input[name='calculationSetId']").val("");
	            myForm.select(".buttonControlBlock input[name='calculationSetName']").val("");

	            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
	            popup.setSize(800,494);
	            popup.open( function(){
	            	if ( popupData.calculationData != undefined && popupData.calculationData.length > 0 ) {
	            		var selectData = popupData.calculationData[0];
		            	myForm.select(".buttonControlBlock input[name='calculationSetId']").val(selectData.calculationSetId);
		            	myForm.select(".buttonControlBlock input[name='calculationSetName']").val(selectData.calculationSetName);
	            	}
	            });
	            popupData.calculationData = [];
	            break;
		    	
		    case "sendBySet" :
		    	//재출력 대상자 전체 명세서 출력
		    	fncSendBySet();
		    	break;
	            
		    case "printAllNoLine" :
		    	//급여명세서 데이터만 출력. title 없음.
		    	fncPrintAllOnly();
		    	break;
		    	
		}
		event.stopPropagation();
	});
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("payrollCalcPeriodValue")) ) { 
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		}
	}
	/*** 내부 함수  ***/
	function buildGrid(gridId) {
		var grid;
		switch ( gridId ) {
			case ".runGrid" :
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				// Context Menu Set
				grid.setContextMenu();
				// Grid Field Set
				grid.setFields([
					{ fieldName:'payrollCalculationExecId' , dataType:'text'  },
					{ fieldName:'payMonth'                 , dataType:'text'  },
					{ fieldName:'payrollCalcPeriodValue'   , dataType:'text'  },
					{ fieldName:'payrollCalculationSetId'  , dataType:'text'  },
					{ fieldName:'payrollCalculationSetName', dataType:'text'  },
					{ fieldName:'payrollTypeCode'	       , dataType:'text'  },
					{ fieldName:'payrollTypeName'          , dataType:'text'  },
					{ fieldName:'basisDate'                , dataType:'text'  },
					{ fieldName:'normalCount'              , dataType:'number'},
					{ fieldName:'emailCount'               , dataType:'number'},
					{ fieldName:'createPayslipCount'       , dataType:'number'},
					{ fieldName:'sendEmailCount'           , dataType:'number'},
					{ fieldName:'creationDate'             , dataType:'text'  },
					{ fieldName:'createdBy'                , dataType:'text'  }
				]);
				// Grid Column Set
				grid.setColumns([
					{
						name:'payrollCalculationExecId',
						fieldName:'payrollCalculationExecId',
						width:120,
						header: {text:'<lgcom:message code="label.pay.executionId"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'payMonth',
						fieldName:'payMonth',
						width:0,
						header: {text:'<lgcom:message code="label.pay.payMonthShort"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'payrollCalcPeriodValue',
						fieldName:'payrollCalcPeriodValue',
						width:100,
						header: {text:'<lgcom:message code="label.pay.payMonthShort"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'payrollTypeName',
						fieldName:'payrollTypeName',
						width:120,
						header: {text:'<lgcom:message code="label.pay.payType"/>'},
						editable: false
					},
					{
						name:'payrollCalculationSetName',
						fieldName:'payrollCalculationSetName',
						width:200,
						header: {text:'<lgcom:message code="label.pay.calculationSetName"/>'},
						editable: false
					},
					{
						name:'basisDate',
						fieldName:'basisDate',
						width:100,
						header: {text:'<lgcom:message code="label.pay.basisDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'normalCount',
						fieldName:'normalCount',
						width:100,
						header: {text:'<lgcom:message code="label.pay.normalCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'emailCount',
						fieldName:'emailCount',
						width:100,
						header: {text:'<lgcom:message code="label.pay.emailCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'createPayslipCount',
						fieldName:'createPayslipCount',
						width:100,
						header: {text:'<lgcom:message code="label.pay.createdPaySlipCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'sendEmailCount',
						fieldName:'sendEmailCount',
						width:100,
						header: {text:'<lgcom:message code="label.pay.sentEmailCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'creationDate',
						fieldName:'creationDate',
						width:140,
						header: {text:'<lgcom:message code="CreationDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'createdBy',
						fieldName:'createdBy',
						width:90,
						header: {text:'<lgcom:message code="CreatedBy"/>'},
						styles: {textAlignment:'center'},
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
						checkBar: {visible:true/*, exclusive:true*/},
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
				break;
		}
		return grid;
	}
	//run결과 그리드에서 checkbar 선택한 경우 처리
	runGrid.getGridBase().onItemChecked = function (cgrid, itemIndex, checked) {
		<%--{PARAMETER]
		    - cgrid : grid.getGridBase()
		    - itemIndex : 그리드 행 index
		    - checked : 체크되었으면 true, 체크해제이면 false 
		--%>
	    if ( checked ) {//checkbar 선택된 경우

	    } else {//그외 비활성화 

	    }
	};
	//Run 그리드 선택 값 체크
	function fncValidateRunRow() {
		var list = fncArrangeMultiLineGridSelected(runGrid);
        		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return false;
		}
		return true;
	}
	//확정된 Run List 조회
	function fncRetrievePayrollRunList() {
		runGrid.getGridBase().cancel();
		myForm.select("button[data-action='createPDFAll']").attr("disabled", "disabled");
		myForm.select("button[data-action='deletePDFAll']").attr("disabled", "disabled");
		myForm.select("button[data-action='sendAll']").attr("disabled", "disabled");
		myForm.select("button[data-action='printAllNoLine']").attr("disabled", "disabled");
		myForm.select("button[data-action='sendByEmployee']").attr("disabled", "disabled");
		myForm.select("button[data-action='sendBySet']").attr("disabled", "disabled");
		myForm.select("button[data-action='createPDFBySet']").attr("disabled", "disabled");

        myForm.select(".buttonControlBlock input[name='calculationSetId']").val("");
        myForm.select(".buttonControlBlock input[name='calculationSetName']").val("");
        myForm.select(".buttonControlBlock input[name='calculationSetName']").attr("disabled", "disabled");
        myForm.select(".buttonControlBlock button[data-action='openPopupCalSet']").attr("disabled", "disabled");
		
		//데이터조회
		runGrid.loadData("lgvhr", "lgvpay/LGVPAY00026/retrievePayrollRunList", srchFormUtil.getValue(), function (data) {

			if ( data.result && data.result.length > 0 ) {
				myForm.select("button[data-action='createPDFAll']").removeAttr("disabled");
				myForm.select("button[data-action='deletePDFAll']").removeAttr("disabled");
				myForm.select("button[data-action='sendAll']").removeAttr("disabled");
				myForm.select("button[data-action='printAllNoLine']").removeAttr("disabled");
				myForm.select("button[data-action='sendByEmployee']").removeAttr("disabled");
				myForm.select("button[data-action='sendBySet']").removeAttr("disabled");
				myForm.select("button[data-action='createPDFBySet']").removeAttr("disabled");
		        myForm.select(".buttonControlBlock input[name='calculationSetName']").removeAttr("disabled");
		        myForm.select(".buttonControlBlock button[data-action='openPopupCalSet']").removeAttr("disabled");
			}
		});
	}
	//Create PaySlip PDF to All Emplooyee
	function fncCreatePDFAll() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		var payrollCalculationExecIdList = fncArrangeFieldMultiLineGridSelected(runGrid, "payrollCalculationExecId");
        if ( list != undefined  ) {
        	var rowData = list[0];
        	
        		Message.confirm( "<lgcom:message code="note.createConfirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId)
        					    , payrollCalculationExecIdList: payrollCalculationExecIdList
        					    , payMonthName             : nvl(rowData.payrollCalcPeriodValue)     
        					    , payMonth                 : nvl(rowData.payMonth)
        					    , createFlag               : 'N'};

    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00026/createPaySlip", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.successfullyCreate"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="note.pay.failCreate"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        }
    }
	
	//Create PaySlip PDF to All Emplooyee
	function fncCreatePDFBySet() {

        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;
        var list = fncArrangeMultiLineGridSelected(runGrid);
		//if ( list.length > 1 ) return ;
        
        //Calculation Set 유무 체크. (명세서 재 출력 대상자를 Calculation Set으로 등록하기 때문에 Set Id가 반드시 있어야 함.)
        if ( isNull(myForm.select(".buttonControlBlock input[name='calculationSetId']").val()) ) {
        	Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />');
        	return ;
        }
        var payrollCalculationExecIdList = fncArrangeFieldMultiLineGridSelected(runGrid, "payrollCalculationExecId");
        var calculationSetId = myForm.select(".buttonControlBlock input[name='calculationSetId']").val();
        var payrollCalculationExecId = payrollCalculationExecIdList[0];

        if ( list != undefined ) {
        	var rowData = list[0];
        	
        		Message.confirm( "<lgcom:message code="note.createConfirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId) 
        					    , payrollCalculationExecIdList : payrollCalculationExecIdList
        					    , payMonth                 : nvl(rowData.payMonth)
        					    , payMonthName             : nvl(rowData.payrollCalcPeriodValue)
        					    , calculationSetId         : nvl(calculationSetId)};
        			
    				myForm.showProgress();
    				myForm.transaction("lgvhr", "lgvpay/LGVPAY00026/createPaySlip", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.successfullyCreate"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="note.pay.failCreate"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        }
	}
	
	//Detete PaySlip PDF to All Emplooyee
	function fncDeletePDFAll() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		
        if ( list != undefined ) {
        	var rowData = list[0];
        	
        		Message.confirm( "<lgcom:message code="note.deleteConfirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId) };

    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00026/deletePaySlip", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.successfullyDelete"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="note.deleteFail"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        }
    }
	
	//Send PaySlip to All Emplooyee
	function fncSendAll() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		
        if ( list != undefined ) {
        	var rowData = list[0];
        	
        		Message.confirm( "<lgcom:message code="note.sendConfirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId)
        					     ,payMonthName : nvl(rowData.payrollCalcPeriodValue)
        					     ,payMonth : nvl(rowData.payMonth)
        					     ,payrollTypeName : nvl(rowData.payrollTypeName)
        					     ,sendFlag               : 'N'};

    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00026/sendPayslipByEmail", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.successfullySent"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="error.sendMail"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        }
    }
	
	//급여 실행 대상자 조회 popup호출
	function fncPopupSendByEmployee(cgrid, itemIndex, colName) {

        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;
        
		var popupData = myForm.popupInfo.sendByEmployeePopup;
		var list = fncArrangeMultiLineGridSelected(runGrid);
		//if ( list.length > 1 ) return ;

		popupData.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
		popupData.payrollCalculationExecIdList = fncArrangeFieldMultiLineGridSelected(runGrid, "payrollCalculationExecId");
		popupData.payMonthNameList = fncArrangeFieldMultiLineGridSelected(runGrid, "payrollCalcPeriodValue");
		popupData.payMonthList = fncArrangeFieldMultiLineGridSelected(runGrid, "payMonth");
		
		var popup = new Popup(myForm, "lgvhr", 'M_LGVPAY_1053','<lgcom:message code="button.pay.sendByEmployee"/>');
		popup.setSize(912,512);
		popup.open(function() {
			//화면 재조회
			myForm.select(".searchBlock button[data-action='search']").trigger("click");
		});
	}
	
	function fncSendBySet() {

        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;
        var list = fncArrangeMultiLineGridSelected(runGrid);
		//if ( list.length > 1 ) return ;
        
        //Calculation Set 유무 체크. (명세서 재 출력 대상자를 Calculation Set으로 등록하기 때문에 Set Id가 반드시 있어야 함.)
        if ( isNull(myForm.select(".buttonControlBlock input[name='calculationSetId']").val()) ) {
        	Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />');
        	return ;
        }
        var payrollCalculationExecIdList = fncArrangeFieldMultiLineGridSelected(runGrid, "payrollCalculationExecId");
        var calculationSetId = myForm.select(".buttonControlBlock input[name='calculationSetId']").val();
        var payrollCalculationExecId = payrollCalculationExecIdList[0];

        if ( list != undefined ) {
        	var rowData = list[0];
        	
        		Message.confirm( "<lgcom:message code="note.sendConfirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId) 
                            , payMonth : nvl(rowData.payMonth)    
                            , payMonthName : nvl(rowData.payrollCalcPeriodValue)
                            , calculationSetId         : nvl(calculationSetId)};
        			
    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00026/sendPayslipByEmail", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.successfullySent"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="error.sendMail"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        }
	}
	
}

LGVPAY00026.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00026();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2>Send PaySlip</h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="180"></col>
						<col width="070"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payMonth" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="payrollCalcPeriodValue" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
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
					<button class="btn btn-gray btn-sm" type="button" data-action="createPDFAll" disabled><lgcom:message code="CreatePaySlipFile"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="sendAll" disabled><lgcom:message code="SendMail"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="printAllNoLine" disabled><lgcom:message code="button.pay.printAll"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="sendByEmployee" disabled><lgcom:message code="button.pay.sendByEmployee"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="deletePDFAll" disabled><lgcom:message code="DeletePaySlipFile"/></button>
				</div>
				<div class="btn-group">
					
					<div class="form-inline">
						<div class="form-group">

	                		<div class="input-group input-group-sm input-search">
	                			<input type="hidden" name="calculationSetId" />
                                <input class="form-control input-sm" name="calculationSetName" type="text" data-action="emptyAndPopup" readonly disabled placeholder="<lgcom:message code="label.pay.calculationSet"/>" />
                                <span class="input-group-btn">
                                    <button class="btn btn-default ico-lgd " type="button" data-action="openPopupCalSet" disabled>
                                        <span class="fa fa-search" aria-hidden="true"></span>
                                    </button>
                                </span>
                            </div>

	                    </div>
	                </div>
				
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" data-action="createPDFBySet" disabled><lgcom:message code="button.pay.createPaySlipBySet"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="sendBySet" disabled><lgcom:message code="button.pay.sendBySet"/></button>
				</div>
			</div>
		</div>
		<%-- //buttonControlBlock --%>

		<div class="runGridBlock grid-wrap">
			<div class="grid runGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
