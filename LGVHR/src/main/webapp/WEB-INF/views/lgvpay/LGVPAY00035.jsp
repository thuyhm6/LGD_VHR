<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00035.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 급여담당자가 Payroll 관련 작업을 Run/Rollback/Retry 등을 하고 진행내역을 확인하는 화면입니다.
            (LGVPAY00008 기반, 급여유형 MTH_OS 전용)
    작성자 : 임수진
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title><lgcom:message code="label.pay.payrollRun"/></title>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<style type="text/css">
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVPAY00035 = function() {
	var myForm = this;
	// 본 화면에서 처리하는 급여유형 (Outsourcing 월급여)
	var PAYROLL_TYPE_CODE = "MTH_OS";
	// Form Util 선언
	var srchFormUtil = new FormUtil( myForm, ".searchBlock form" );
	
    // 화면 레이아웃 정의
	myForm.setLayout( [
		{ name : "searchBlock",        left : 0, right : 0, top : 0 },
		{ name : "buttonControlBlock", left : 0, right : 0, top : "searchBlock"       , bottom : "runGridBlock" },
		{ name : "runGridBlock",       left : 0, right : 0, top : "buttonControlBlock", height : 245 },
		{ name : "buttonEmpBlock",     left : 0, right : 0, top : "runGridBlock"      , bottom : "runEmpGridBlock" },
	    { name : "runEmpGridBlock",    left : 0, right : 0, top : "buttonEmpBlock"    , bottom : 0 }
	]);

    // 그리드선언
	var runGrid = buildGrid(".runGrid");
	var runEmpGrid = buildGrid(".runEmpGrid");

    // 개인화조건
    
    // 조회조건 저장 처리
    myForm.searchConditionControl( true );
    
    // 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		calculationPopup	 : { popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[] },
		payrollRunPopup		 : { payrollCalcPeriodValue:'', payrollTypeCode:'', payrollTypeName:'', calculationSetId:'', calculationSetName:'', runData:[] },
		retroPayrollRunPopup : { payrollCalcPeriodValue:'', payrollTypeCode:'', payrollTypeName:'', calculationSetId:'', calculationSetName:'', retroactiveStartMonth:'', retroactiveEndMonth:'', runData:[] },
		errorDetailPopup 	 : { payrollCalculationExecId:'', employeeNo:'', searchFlag:'' }
    };

    // 그리드형 테이블 TR
    
    // 코드 데이터 조회
    var code = new CommonCode("lgcom");
    code.add("payRunTypeList", {codeTypeCode:'LGVHR_PAY_RUN_TYPE'});
    code.execute();
	
	//콤보 초기화
	srchFormUtil.initCombo("payrollTypeCode", code.get("payRunTypeList"), {selectAll:false});
	//LGVPAY00035 : MTH_OS 급여유형만 처리
	myForm.select("select[name='payrollTypeCode'] option").not("[value='" + PAYROLL_TYPE_CODE + "']").remove();
	srchFormUtil.setValue({ payrollTypeCode : PAYROLL_TYPE_CODE });

    // 날짜 팝업창
    
    // 필수항목 체크
   	var validator = new Validator( myForm, ".searchBlock form" );

    validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	payrollCalcPeriodValue : { required : true, monthYear : true },
	    	payrollTypeCode        : { required : true },
	    	calculationSetName     : { emptyCalculationSet : true }
	    },
	    messages: {
	    	payrollCalcPeriodValue : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { monthYear           : '<lgcom:message code="error.incorrectFormat" />'},
	    	payrollTypeCode        : { required            : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payType'/>" />'},
	    	calculationSetName     : { emptyCalculationSet : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.calculationSet'/>" />'}
	    }
    });
    
    //calculation set 입력값에 대한 validation 추가
    validator.addMethod( "emptyCalculationSet", function ( value, element ) {
    	var result = true;
    	if ( isNull(value) || isNull(srchFormUtil.getValue("calculationSetId")) ) {
    		result = false;
    	}
    	return result;
    });

    // 일반함수	
	//검색조건 기본값 셋팅
	//srchFormUtil.setValue({ payrollCalcPeriodValue : DateUtil.today("MM/YYYY") });
    
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
				
			// 급여대상자 SET 조회 팝업
		    case "openPopupCalSet" :
	            var popupData = myForm.popupInfo.calculationPopup;
	            popupData.popupKind    = "";
	            popupData.confirmKind  = "";
	            popupData.calculationSetName = srchFormUtil.getValue("payrollCalcPeriodValue");
	            srchFormUtil.setValue({calculationSetId : '', calculationSetName : ''});

	            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
	            popup.setSize(800,494);
	            popup.open( function(){
	            	if ( popupData.calculationData != undefined && popupData.calculationData.length > 0 ) {
	            		var selectData = popupData.calculationData[0];
		            	srchFormUtil.setValue({calculationSetId   : selectData.calculationSetId, 
		            		                   calculationSetName : selectData.calculationSetName});
		            	//검색조건 값이 있는 경우 데이터 조회
		        		fncSearchData();
	            	}
	            });
	            popupData.calculationData = [];
	            break;
	            
		    case "run" :
		    	//급여실행
		    	if ( validator.isValid() ) {
		            var popupData = myForm.popupInfo.payrollRunPopup;
		            popupData.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
		            popupData.payrollTypeCode        = srchFormUtil.getValue("payrollTypeCode");
		            popupData.payrollTypeName        = myForm.select("select[name='payrollTypeCode'] option:selected").text();
		            popupData.calculationSetId       = srchFormUtil.getValue("calculationSetId");
		            popupData.calculationSetName     = srchFormUtil.getValue("calculationSetName");

		            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1024', '<lgcom:message code="label.pay.payrollRun"/>' );
		            popup.setSize(500,250);
		            popup.open( function(){
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
		            });
		    	}
		    	break;
		    	
		    case "retroPayRun" :
		    	// 소급급여
		    	if ( validator.isValid() ) {
		            var popupData = myForm.popupInfo.retroPayrollRunPopup;
		            popupData.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
		            popupData.payrollTypeCode        = srchFormUtil.getValue("payrollTypeCode");
		            popupData.payrollTypeName        = myForm.select("select[name='payrollTypeCode'] option:selected").text();
		            popupData.calculationSetId       = srchFormUtil.getValue("calculationSetId");
		            popupData.calculationSetName     = srchFormUtil.getValue("calculationSetName");
		            
		            var payMonthLastDay = DateUtil.getLastDay(srchFormUtil.getValue("payrollCalcPeriodValue").substring(3, 7), srchFormUtil.getValue("payrollCalcPeriodValue").substring(0, 2));
		            var strPayMonthLastDay = payMonthLastDay + "/" + srchFormUtil.getValue("payrollCalcPeriodValue").substring(0, 2) + "/" + srchFormUtil.getValue("payrollCalcPeriodValue").substring(3, 7);
		            var lastMonth = DateUtil.addDays(DateUtil.parse(strPayMonthLastDay, "DD/MM/YYYY"), -31, "MM/YYYY");
		            
		            popupData.retroactiveStartMonth	 = lastMonth;
		            popupData.retroactiveEndMonth	 = lastMonth;
		            
		            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1048', '<lgcom:message code="label.pay.retroactivePayrollRun"/>' );
		            popup.setSize(500,250);
		            popup.open( function(){
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
		            });
		    	}
		    	break;
	            
		    case "rollback" :
		    	//급여롤백
		    	fncPayrollRunRollback();
		    	break;
	            
		    case "confirm" :
		    	//급여실행 확정
		    	fncConfirm();
		    	break;
	            
		    case "cancelConfirm" :
		    	//급여실행 확정취소
		    	fncCancelConfirm();
		    	break;
		    	
		    case "retry" :
		    	//건별 재실행
		    	fncPayrollRunRetry();
		    	break;
	            
		    case "rollbackEmployee" :
		    	//건별 급여롤백
		    	fncPayrollRunRollbackEmployee();
		    	break;
	            
		    case "paySlip" :
				//급여명세서 화면으로 이동
		    	fncMovePage();
		    	break;
	            
		    case "errorDetail" :
				//에러내역 조회
		    	fncPopupRunErrorDetail();
		    	break;
		    
		    case "empSearch" : 
		    	//detail 그리드 사번 검색
		    	//개인별 run결과 그리드 조회
		    	fncRetrievePayrollRunEmpList();
		    	break;
		}
		event.stopPropagation();
	});
	myForm.addEvent ( "keyup","input[name='detailEmployeeNo']",function(event) {
		//var val = $.trim($(this).val());
		if ( event.keyCode == 13 ) {//enter key
	    	//개인별 run결과 그리드 조회
	    	fncRetrievePayrollRunEmpList();
		}
	});
	function fncSearchData() {
		if ( !isNull(srchFormUtil.getValue("payrollCalcPeriodValue")) && !isNull(srchFormUtil.getValue("payrollTypeCode")) && !isNull(srchFormUtil.getValue("calculationSetId")) ) { 
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
					{ fieldName:'payrollCalcPeriodValue'   , dataType:'text'  },
					{ fieldName:'payrollCalculationSetId'  , dataType:'text'  },
					{ fieldName:'payrollCalculationSetName', dataType:'text'  },
					{ fieldName:'payrollTypeCode'	       , dataType:'text'  },
					{ fieldName:'payrollTypeName'          , dataType:'text'  },
					{ fieldName:'basisDate'                , dataType:'text'  },
					{ fieldName:'employeeCount'            , dataType:'number'},
					{ fieldName:'totalCount'               , dataType:'number'},
					{ fieldName:'normalCount'              , dataType:'number'},
					{ fieldName:'errorCount'               , dataType:'number'},
					{ fieldName:'creationDate'             , dataType:'text'  },
					{ fieldName:'createdBy'                , dataType:'text'  },
					{ fieldName:'confirmFlag'              , dataType:'text'  },
					{ fieldName:'retroactiveFlag'          , dataType:'text'  },
					{ fieldName:'retroactiveStartMonth'    , dataType:'text'  },
					{ fieldName:'retroactiveEndMonth'      , dataType:'text'  },
					{ fieldName:'addingUpTaxationFlag'     , dataType:'text'  },
					{ fieldName:'addupTaxationStartYyyymm' , dataType:'text'  }
				]);
				// Grid Column Set
				grid.setColumns([
					{
						name:'payrollCalculationExecId',
						fieldName:'payrollCalculationExecId',
						width:90,
						header: {text:'<lgcom:message code="label.pay.executionId"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'payrollCalcPeriodValue',
						fieldName:'payrollCalcPeriodValue',
						width:90,
						header: {text:'<lgcom:message code="label.pay.payMonthShort"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'payrollTypeName',
						fieldName:'payrollTypeName',
						width:110,
						header: {text:'<lgcom:message code="label.pay.payType"/>'},
						editable: false
					},
					{
						name:'payrollCalculationSetName',
						fieldName:'payrollCalculationSetName',
						width:160,
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
						name:'employeeCount',
						fieldName:'employeeCount',
						width:65,
						header: {text:'<lgcom:message code="label.pay.employeeCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'totalCount',
						fieldName:'totalCount',
						width:55,
						header: {text:'<lgcom:message code="label.pay.totalCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'normalCount',
						fieldName:'normalCount',
						width:55,
						header: {text:'<lgcom:message code="label.pay.normalCount"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: false
					},
					{
						name:'errorCount',
						fieldName:'errorCount',
						width:45,
						header: {text:'<lgcom:message code="label.pay.errorCount"/>'},
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
					},
					{
						name:'confirmFlag',
						fieldName:'confirmFlag',
						width:50,
						header: {text:'<lgcom:message code="label.pay.confirmResult"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'retroactiveFlag',
						fieldName:'retroactiveFlag',
						width:70,
						header: {text:'<lgcom:message code="label.pay.retroactiveFlag"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'retroactiveStartMonth',
						fieldName:'retroactiveStartMonth',
						width:115,
						header: {text:'<lgcom:message code="label.pay.retroactiveStartMonth"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'retroactiveEndMonth',
						fieldName:'retroactiveEndMonth',
						width:115,
						header: {text:'<lgcom:message code="label.pay.retroactiveEndMonth"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'addingUpTaxationFlag',
						fieldName:'addingUpTaxationFlag',
						width:70,
						header: {text:'<lgcom:message code="label.pay.addingUpPITFlag"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'addupTaxationStartYyyymm',
						fieldName:'addupTaxationStartYyyymm',
						width:95,
						header: {text:'<lgcom:message code="label.pay.addingUpPITStartMonth"/>'},
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
						checkBar: {visible:true, exclusive:true/*, checkableExpression: "(values['confirmFlag'] = 'N')"*/},
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
				
			case ".runEmpGrid" :
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				// Grid Option Set
				grid.setOptions({
					grid: {
						hideDeletedRows: true,
						indicator: {visible:false},
						panel: {visible:false},
						stateBar: {visible:false},
						checkBar: {visible:true, exclusive:true},
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
				// Grid Field Set
				grid.setFields([
					{ fieldName:'payrollCalculationExecId' , dataType:'text'  },
					{ fieldName:'employeeNo'               , dataType:'text'  },
					{ fieldName:'employeeName'             , dataType:'text'  },
					{ fieldName:'organizationName'         , dataType:'text'  },
					{ fieldName:'hireDate'                 , dataType:'text'  },
					{ fieldName:'resignationDate'          , dataType:'text'  },
					{ fieldName:'errorFlag'                , dataType:'text'  }
				]);
				// Grid Column Set
				grid.setColumns([
					{
						name:'payrollCalculationExecId',
						fieldName:'payrollCalculationExecId',
						width:90,
						header: {text:'<lgcom:message code="label.pay.executionId"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'employeeNo',
						fieldName:'employeeNo',
						width:100,
						header: {text:'<lgcom:message code="label.pay.employeeNo"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'employeeName',
						fieldName:'employeeName',
						width:200,
						header: {text:'<lgcom:message code="label.pay.employeeName"/>'},
						editable: false
					},
					{
						name:'organizationName',
						fieldName:'organizationName',
						width:300,
						header: {text:'<lgcom:message code="label.pay.organizationName"/>'},
						editable: false
					},
					{
						name:'hireDate',
						fieldName:'hireDate',
						width:120,
						header: {text:'<lgcom:message code="label.pay.hireDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'resignationDate',
						fieldName:'resignationDate',
						width:120,
						header: {text:'<lgcom:message code="label.pay.resignationDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'errorFlag',
						fieldName:'errorFlag',
						width:120,
						header: {text:'<lgcom:message code="errorFlag"/>'},
						styles: {textAlignment:'center'},
						editable: false
					}
				]);
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
	    	//confirmFlag=Y이면 롤백, confirm 버튼 비활성화, cancelConfirm 버튼 활성화
	    	if ( cgrid.getValue(itemIndex, "confirmFlag") == "Y" ) {
		    	myForm.select("button[data-action='rollback']").attr("disabled", "disabled");
		    	myForm.select("button[data-action='confirm']").attr("disabled", "disabled");
		    	myForm.select("button[data-action='cancelConfirm']").removeAttr("disabled");
	    	} else {
	    		if ( cgrid.getValue(itemIndex, "retroactiveFlag") == "Y" ) {
			    	myForm.select("button[data-action='rollback']").removeAttr("disabled");
			    	myForm.select("button[data-action='confirm']").attr("disabled", "disabled");
			    	myForm.select("button[data-action='cancelConfirm']").attr("disabled", "disabled");
	    		} else {
			    	myForm.select("button[data-action='rollback']").removeAttr("disabled");
			    	myForm.select("button[data-action='confirm']").removeAttr("disabled");
			    	myForm.select("button[data-action='cancelConfirm']").attr("disabled", "disabled");
	    		}
	    	}
	    	//사번조건 초기화
	    	myForm.select("input[name='detailEmployeeNo']").val("");
	    	//개인별 run결과 그리드 조회
	    	fncRetrievePayrollRunEmpList(itemIndex);
	    } else {//그외 비활성화 
	    	myForm.select("button[data-action='rollback']").attr("disabled", "disabled");
	    	myForm.select("button[data-action='confirm']").attr("disabled", "disabled");
	    	myForm.select("button[data-action='cancelConfirm']").attr("disabled", "disabled");
			// 대상자 상세 그리드 초기화
			runEmpGrid.getDataProvider().clearRows();
			// 대상자 상세 그리드 버튼 비활성화
			myForm.select("input[name='detailEmployeeNo']").attr("disabled", "disabled");
			myForm.select("button[data-action='empSearch']").attr("disabled", "disabled");
			myForm.select("button[data-action='retry']").attr("disabled", "disabled");
			myForm.select("button[data-action='rollbackEmployee']").attr("disabled", "disabled");
			myForm.select("button[data-action='paySlip']").attr("disabled", "disabled");
			myForm.select("button[data-action='errorDetail']").attr("disabled", "disabled");
	    }
	};
	//개인별 run결과 그리드에서 checkbar 선택한 경우 처리
	runEmpGrid.getGridBase().onItemChecked = function (cgrid, itemIndex, checked) {
		var list = fncArrangeMultiLineGridSelected(runGrid);
		var sConfirmFlag = "";
		var sRetroactiveFlag = "";
		
		if ( list != undefined && list.length == 1 ) {
			sConfirmFlag = nvl(list[0].confirmFlag);
		}
		
		if ( list != undefined && list.length == 1 ) {
			sRetroactiveFlag = nvl(list[0].retroactiveFlag);
		}
		
		//checkbar 선택이고, 에러여부가 Y인 경우 Error Detail 버튼 활성화, PaySlip 버튼 비활성화
	    if ( checked ) {
	    	if ( cgrid.getValue(itemIndex, "errorFlag") == "Y" ) {
	    		myForm.select("button[data-action='errorDetail']").removeAttr("disabled");
	    		myForm.select("button[data-action='paySlip']").attr("disabled", "disabled");
	    		
	    	} else {//그외 비활성화 
	    		if( sRetroactiveFlag == "Y" ) {
			    	myForm.select("button[data-action='errorDetail']").attr("disabled", "disabled");
		    		myForm.select("button[data-action='paySlip']").attr("disabled", "disabled");
	    		} else {
			    	myForm.select("button[data-action='errorDetail']").attr("disabled", "disabled");
		    		myForm.select("button[data-action='paySlip']").removeAttr("disabled");
	    		}
		    }
	    	
	    	if ( sConfirmFlag == "Y" ) {//확정된 경우 retry, rolllbackEmployee 버튼 비활성화
		    	myForm.select("button[data-action='retry']").attr("disabled", "disabled");
		    	myForm.select("button[data-action='rollbackEmployee']").attr("disabled", "disabled");
	    	} else {
		    	myForm.select("button[data-action='retry']").removeAttr("disabled");
		    	myForm.select("button[data-action='rollbackEmployee']").removeAttr("disabled");
	    	}
	    	
	    } else {//그외 비활성화 
	    	myForm.select("button[data-action='retry']").attr("disabled", "disabled");
	    	myForm.select("button[data-action='rollbackEmployee']").attr("disabled", "disabled");
	    	
	    	myForm.select("button[data-action='errorDetail']").attr("disabled", "disabled");
    		myForm.select("button[data-action='paySlip']").attr("disabled", "disabled");
	    }
	};
	//Run 그리드 선택 값 체크
	function fncValidateRunRow() {
		var list = fncArrangeMultiLineGridSelected(runGrid);
        		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return false;
			
		} else if ( list.length > 1 ) {
			Message.alert("<lgcom:message code="note.com.oneSelect"/>");
			return false;
		}
		return true;
	}
	//급여롤백
	function fncPayrollRunRollback() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		
        if ( list != undefined && list.length == 1 ) {
        	var rowData = list[0];
        	var rollbackQuery = "lgvpay/LGVPAY00035/updatePayrollRunRollback";

	    	var cfmMsg = "";
	    	cfmMsg  = "<lgcom:message code="question.pay.rollback"/>" + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.executionId"/> : "         + nvl(rowData.payrollCalculationExecId) + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.calculationSetName" /> : " + nvl(rowData.payrollCalculationSetName);
	    	
	    	if ( nvl(rowData.retroactiveFlag, "N") == "Y" ) {
	    		rollbackQuery = "lgvpay/LGVPAY00035/updateRetroactivePayrollRunRollback";
	    	}
	    	
			Message.confirm( cfmMsg, function() {
				var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId)
						    , calculationSetId         : nvl(rowData.payrollCalculationSetId)
						    };
				myForm.showProgress();
				myForm.transaction("lgvhr", rollbackQuery, param, function (data) {
					myForm.hideProgress();
					if ( data.result ) {
						if ( nvl(data.result.errcode) == 0 ) {
							Message.alert("<lgcom:message code="note.pay.rollback"/>");
							//화면 재조회
							myForm.select(".searchBlock button[data-action='search']").trigger("click");
						} else {
							Message.alert("<lgcom:message code="note.pay.failRollback"/>");
						}
					}<%-- //if ( data.result ) { --%>
				});<%-- //myForm.transaction --%>
			}, function (data) { myForm.hideProgress(); });<%-- //Message.confirm --%>
		}
	}
    //확정
    function fncConfirm() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		
        if ( list != undefined && list.length == 1 ) {
        	var rowData = list[0];
        	
        	if ( nvl(rowData.confirmFlag, "N") == "N" ) {
        		Message.confirm( "<lgcom:message code="question.confirm"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId) };

    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00035/updateConfirmPayrollCalculationExec", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.pay.confirm"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="note.pay.failConfirm"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        	}
        }
    }
    //확정취소
    function fncCancelConfirm() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		
        if ( list != undefined && list.length == 1 ) {
        	var rowData = list[0];
        	
        	if ( nvl(rowData.confirmFlag, "N") == "Y" ) {
        		Message.confirm( "<lgcom:message code="question.release"/>", function() {
        			var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId) };

    				myForm.showProgress();
	        		myForm.transaction("lgvhr", "lgvpay/LGVPAY00035/updateCanceleConfirmPayrollCalculationExec", param, function (data) {
	        			myForm.hideProgress();
	        			Message.alert("<lgcom:message code="note.pay.cancelConfirm"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
	        		}, function (data) {
	        			myForm.hideProgress();
	        			if ( isNull(data.text) ) {//메세지가 없는 경우만 출력
	        				Message.alert("<lgcom:message code="note.pay.failcancelConfirm"/>");
	        			}
	        		});<%-- myForm.transaction --%>
        		});<%-- //Message.confirm --%>
        	}
        }
    }
	//Run 대상자 그리드 선택 값 체크
	function fncValidateRunEmpRow() {
		var list = fncArrangeMultiLineGridSelected(runEmpGrid);
        		
		//선택된 행이 있는지 체크
		if ( !list || list.length == 0 ) {
			Message.alert("<lgcom:message code="note.noselected"/>");
			return false;
			
		} else if ( list.length > 1 ) {
			Message.alert("<lgcom:message code="note.com.oneSelect"/>");
			return false;
		}
		return true;
	}
	//급여건별재실행
	function fncPayrollRunRetry() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;
        //그리드 선택값 체크
        if ( !fncValidateRunEmpRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		var empList = fncArrangeMultiLineGridSelected(runEmpGrid);
		
        if ( list != undefined && list.length == 1 && empList != undefined && empList.length == 1 ) {
        	var rowData = list[0];
        	var empData = empList[0];
        	var retryQuery = "lgvpay/LGVPAY00035/updatePayrollRunRetry";

	    	var cfmMsg = "";
	    	cfmMsg  = "<lgcom:message code="question.pay.retry"/>" + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.executionId"/> : "         + nvl(rowData.payrollCalculationExecId) + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.calculationSetName" /> : " + nvl(rowData.payrollCalculationSetName) + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.employeeNo" /> : "         + nvl(empData.employeeNo);
	    	
	    	if ( nvl(rowData.retroactiveFlag, "N") == "Y" ) {
	    		retryQuery = "lgvpay/LGVPAY00035/updateRetroactivePayrollRunRetry";
	    	}
	    	
			Message.confirm( cfmMsg, function() {
				var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId)
						    , calculationSetId         : nvl(rowData.payrollCalculationSetId)
						    , employeeNo               : nvl(empData.employeeNo)
						    , retroactiveStartMonth    : nvl(rowData.retroactiveStartMonth)
						    , retroactiveEndMonth      : nvl(rowData.retroactiveEndMonth)
						    };
				myForm.showProgress();
				myForm.transaction("lgvhr", retryQuery, param, function (data) {
        			myForm.hideProgress();
					if ( data.result ) {
						if ( nvl(data.result.errcode) == 0 ) {
							Message.alert("<lgcom:message code="note.pay.retry"/>");
							//화면 재조회
					    	//개인별 run결과 그리드 조회
					    	fncRetrievePayrollRunEmpList();
						} else {
							Message.alert("<lgcom:message code="note.pay.failRetry"/>");
						}
					}<%-- //if ( data.result ) { --%>
				}, function (data) {myForm.hideProgress();});<%-- //myForm.transaction --%>
			});<%-- //Message.confirm --%>
		}
	}
	//급여 건별 롤백
	function fncPayrollRunRollbackEmployee() {
        //그리드 선택값 체크
        if ( !fncValidateRunRow() ) return ;

        //그리드 선택값 체크
        if ( !fncValidateRunEmpRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runGrid);
		var empList = fncArrangeMultiLineGridSelected(runEmpGrid);
		var rollbackForEmpQuery = "lgvpay/LGVPAY00035/updatePayrollRunRollbackEmployee";
		
        if ( list != undefined && list.length == 1 && empList != undefined && empList.length == 1 ) {
        	var rowData = list[0];
        	var empData = empList[0];

	    	var cfmMsg = "";
	    	cfmMsg  = "<lgcom:message code="question.pay.rollback"/>" + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.executionId"/> : "         + nvl(rowData.payrollCalculationExecId) + "<br/>";
	    	cfmMsg += "<lgcom:message code="label.pay.calculationSetName" /> : " + nvl(rowData.payrollCalculationSetName) + "<br/>";
		    cfmMsg += "<lgcom:message code="label.pay.employeeNo" /> : "         + nvl(empData.employeeNo);
	    	
		    if ( nvl(rowData.retroactiveFlag, "N") == "Y" ) {
		    	rollbackForEmpQuery = "lgvpay/LGVPAY00035/updateRetroactivePayrollRunRollbackEmployee";
	    	}
		    
			Message.confirm( cfmMsg, function() {
				var param = { payrollCalculationExecId : nvl(rowData.payrollCalculationExecId)
						    , calculationSetId         : nvl(rowData.payrollCalculationSetId)
						    , employeeNo               : nvl(empData.employeeNo) /* 건별 롤백인 경우만 사번 파라메터 전달 */
						    };
				myForm.showProgress();
				myForm.transaction("lgvhr", rollbackForEmpQuery, param, function (data) {
        			myForm.hideProgress();
					if ( data.result ) {
						if ( nvl(data.result.errcode) == 0 ) {
							Message.alert("<lgcom:message code="note.pay.rollback"/>");
							//화면 재조회
					    	//개인별 run결과 그리드 조회
					    	fncRetrievePayrollRunEmpList();
						} else {
							Message.alert("<lgcom:message code="note.pay.failRollback"/>");
						}
					}<%-- //if ( data.result ) { --%>
				}, function(data) {myForm.hideProgress();});<%-- //myForm.transaction --%>
			});<%-- //Message.confirm --%>
		}
	}
	//급여명세서 화면으로 이동
	function fncMovePage() {
        //그리드 선택값 체크
        if ( !fncValidateRunEmpRow() ) return ;

		var list = fncArrangeMultiLineGridSelected(runEmpGrid);
		
        if ( list != undefined && list.length == 1 ) {
    		var nav = new Navigate( "lgvhr", "M_LGVPAY_1004" );
    		nav.addParam("payrollCalculationExecId", list[0].payrollCalculationExecId);
    		nav.addParam("employeeNo", list[0].employeeNo);
    		nav.addParam("authGroup", 'MASTER');
    		
    		nav.goPageInNewTab();
        }
	}
	//에러내용 조회 팝업 호출
	function fncPopupRunErrorDetail() {
        var popupData = myForm.popupInfo.errorDetailPopup;
        //그리드 선택값 체크
        if ( !fncValidateRunEmpRow() ) return ;
        
		var list = fncArrangeMultiLineGridSelected(runEmpGrid);
		
		//에러여부가 Y인 경우만 조회
		if ( list != undefined && list.length == 1 ) {
			if ( nvl(list[0].errorFlag) == "Y" ) {
		        popupData.payrollCalculationExecId = nvl(list[0].payrollCalculationExecId);
		        popupData.employeeNo = nvl(list[0].employeeNo);
		        popupData.searchFlag = "Y";
		
		        var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1021', '<lgcom:message code="label.pay.errorDetail"/>' );
		        popup.setSize(800,494);
		        popup.open();
			}
		}
	}
	
	//Run List 조회
	function fncRetrievePayrollRunList() {
		runGrid.getGridBase().cancel();
		// 대상자 상세 그리드 초기화
		runEmpGrid.getDataProvider().clearRows();
		// 대상자 상세 그리드 버튼 비활성화
		myForm.select("input[name='detailEmployeeNo']").attr("disabled", "disabled");
		myForm.select("button[data-action='empSearch']").attr("disabled", "disabled");
		myForm.select("button[data-action='retry']").attr("disabled", "disabled");
		myForm.select("button[data-action='rollbackEmployee']").attr("disabled", "disabled");
		myForm.select("button[data-action='paySlip']").attr("disabled", "disabled");
		myForm.select("button[data-action='errorDetail']").attr("disabled", "disabled");
		//데이터조회
		runGrid.loadData("lgvhr", "lgvpay/LGVPAY00035/retrievePayrollRunList", srchFormUtil.getValue(), function (data) { 
			if ( data.result ) {
				myForm.select("button[data-action='run']").removeAttr("disabled");
				myForm.select("button[data-action='retroPayRun']").removeAttr("disabled");
			}
		});
	}
	//Run Emp List 조회
	function fncRetrievePayrollRunEmpList( rowIndex ) {
		var sPayrollCalculationExecId = "", sConfirmFlag = "";
		
		if ( !isNull(rowIndex) && rowIndex > -1 ) {
			var rgrid = runGrid.getGridBase();//master grid
			sPayrollCalculationExecId = nvl(rgrid.getValue(rowIndex, "payrollCalculationExecId"));
			sConfirmFlag = nvl(rgrid.getValue(rowIndex, "confirmFlag"));
			
			//index있는 경우는 master grid 에서 선택한 경우이므로 상세의 사번 조건을 초기화한다.
			myForm.select("input[name='detailEmployeeNo']").val("");
			
		} else if ( isNull(rowIndex) ) {//index없는 경우 checkbar 선택된 행 값으로 셋팅 
			var list = fncArrangeMultiLineGridSelected(runGrid);

			if ( list != undefined && list.length == 1 ) {
				sPayrollCalculationExecId = nvl(list[0].payrollCalculationExecId);
				sConfirmFlag = nvl(list[0].confirmFlag);
			}
		}
		
		var param = { payrollCalculationExecId : sPayrollCalculationExecId
				    , detailEmployeeNo         : myForm.select("input[name='detailEmployeeNo']").val() };

		//confirm result=Y인 경우 retry, rollback by employee 버튼 비활성화
		myForm.select("button[data-action='retry']").attr("disabled", "disabled");
		myForm.select("button[data-action='rollbackEmployee']").attr("disabled", "disabled");
		
		myForm.select("input[name='detailEmployeeNo']").attr("disabled", "disabled");
		myForm.select("button[data-action='empSearch']").attr("disabled", "disabled");
		
		runEmpGrid.loadData("lgvhr", "lgvpay/LGVPAY00035/retrievePayrollRunEmpList", param, function(data) {
			myForm.select("input[name='detailEmployeeNo']").removeAttr('disabled');
			myForm.select("button[data-action='empSearch']").removeAttr('disabled');
		});
	}
}

LGVPAY00035.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVPAY00035();
		form.init();		
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="label.pay.payrollRun"/></h2>
		</div>
		<div class="searchBlock">
			<form class="form search-wrap" method="post">
				<table class="table" >
					<colgroup>
						<col width="180"></col>
						<col width="070"></col>
						<col width="100"></col>
						<col width="180"></col>
						<col width="140"></col>
						<col width="250"></col>
						<col width="*"></col>
					</colgroup>
					<tbody>
						<tr>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payMonth" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="payrollCalcPeriodValue" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><select class="form-control input-sm input-require" name="payrollTypeCode" ></select></td>
		                	<th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.calculationSet" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="calculationSetId" />
	                                <input class="form-control input-sm input-require" name="calculationSetName" type="text" data-action="emptyAndPopup" readonly />
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupCalSet">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
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
					<button class="btn btn-darkgray btn-sm" type="button" data-action="retroPayRun" disabled><lgcom:message code="button.pay.retroPayRun"/></button>
					<button class="btn btn-darkgray btn-sm" type="button" data-action="run" disabled><lgcom:message code="button.pay.run"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="rollback" disabled><lgcom:message code="button.pay.rollback"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" data-action="confirm" disabled><lgcom:message code="Confirm"/></button>
					<button class="btn btn-default btn-sm" type="button" data-action="cancelConfirm" disabled><lgcom:message code="button.pay.cancelConfirm"/></button>
				</div>
			</div>
		</div>
		<%-- //buttonControlBlock --%>

		<div class="runGridBlock grid-wrap">
			<div class="grid runGrid"></div>
		</div>
		
		<div class="buttonEmpBlock module-group text-right">
			<div class="btn-toolbar">
				<div class="btn-group">
					<div class="form-inline">
						<div class="form-group">
							<input class="form-control input-sm" name="detailEmployeeNo" type="text"  placeholder="<lgcom:message code="label.pay.employeeNo"/>" disabled />
							<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="empSearch" disabled><lgcom:message code="search" /></button>
						</div>
						<div class="form-group">
							<button class="btn btn-darkgray btn-sm" type="button" data-action="retry" disabled><lgcom:message code="button.pay.retry"/></button>
							<button class="btn btn-gray btn-sm" type="button" data-action="rollbackEmployee" disabled><lgcom:message code="button.pay.rollbackByEmployee"/></button>
						</div>
					</div>
				</div>
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" data-action="paySlip" disabled><lgcom:message code="button.pay.paySlip"/></button>
					<button class="btn btn-default btn-sm" type="button" data-action="errorDetail" disabled><lgcom:message code="button.pay.errorDetail"/></button>
				</div>
			</div>
		</div>
		<%-- //buttonEmpBlock --%>

		<div class="runEmpGridBlock grid-wrap">
			<div class="grid runEmpGrid"></div>
		</div>
		
	</section>
</div>
</body>
</html>
