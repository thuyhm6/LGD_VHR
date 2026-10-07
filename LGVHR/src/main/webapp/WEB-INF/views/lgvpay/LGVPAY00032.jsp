<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00032.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Employee Paid Leave Hours
    작성자 : HMT_20251201
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVPAY00032 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	var code = new CommonCode("lgcom");
    code.add("paidLeaveCodeList", {codeTypeCode:'LGVHR_ATTENDANCE_PL_DETAIL_CODE'});
    code.execute();
	
	//콤보 초기화
	srchFormUtil.initCombo("paidLeaveDetailCode", code.get("paidLeaveCodeList"), {selectAll:false});
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
	
   	transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		yyyymmList = data.result.yyyymmList;
    		
    		srchFormUtil.initCombo("payMonth", data.result.yyyymmList,   {selectAll:false});
    		srchFormUtil.setValue({payMonth: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });
 	// 그리드 선언
	var grid = buildGrid('.paidLeaveEmployeeHoursGrid');
	var gridView = grid.getGridBase();
	var provider = grid.getDataProvider();
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	/* this.addEvent('change',"select[name='payMonth']",function(event) {
		search();
	}); */
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		case 'search':
			search();
			break;
		case 'insert':
			var cgrid = grid.getGridBase();
			cgrid.commit();
			var curr = cgrid.getCurrent();
			
			if(curr.itemIndex < 0) {
				cgrid.beginAppendRow();
			}else {
				cgrid.beginInsertRow(curr.itemIndex);
			}
			
			break;
		case 'save':
			var grid1 = grid.getGridBase();
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			var param = {};
			var empMap = new Map();
			
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
		
			for(var i=0; i < grid1.getItemCount(); i++) {
				// 삭제건은 제외
				if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'deleted') continue;
				
				empMap.put(grid1.getValue(i,'employeeNo'),1);
			}
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00032/savePaidLeaveEmp', function(data) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'deleteAll':
			var grid1 = grid.getGridBase();
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			var param = {};
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( payMonth == '' ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			Message.confirm('<lgcom:message code="note.pay.deleteAll"/>', function() {
				myForm.showProgress();
				myForm.transaction('lgvhr','lgvpay/LGVPAY00032/deleteAllPaidLeaveInMonth',{payMonth : payMonth}, function(data, gridData ) {
					myForm.hideProgress();
					Message.alert('<lgcom:message code="note.successfullyDelete"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'delete':
			grid.getGridBase().deleteSelection(true);
			break;
			
		case 'directCSV':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgvhr", "LGVPAY00032.createDirectCSVDownloadData", srchFormUtil.getValue());
				});
			}
			break;
			
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = srchFormUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00032/createExcelExportData", param );
				});
			}
			break;
			 
		case 'excelUpload':
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			if( payMonth == '' ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			var uploader = new ExcelUploader("lgvhr", "LGVPAY00032", {});
                uploader.open(  processExcelUploadPostProcess );
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
	//사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	fncSearchEmpInfoInit();
    });
  	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 employeeNo 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('employeeNo','editable',false);
			cgrid.setColumnProperty('employeeNo','button','none');
			// 삭제버튼 활성화
			//myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('employeeNo','editable',true);
			cgrid.setColumnProperty('employeeNo','button','action');
			// 삭제버튼 비활성화
			//myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
	};
	//employeeNo 클릭 시 user검색 팝업호출
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		emplyoeePopup(itemIndex,column.name,gridRow.userId,gridRow.roleName);
	};
	//Search
	function search() {
		grid.getGridBase().cancel();
		var param = srchFormUtil.getValue();
		if(validator.isValid()) {
			grid.loadData("lgvhr", "lgvpay/LGVPAY00032/retrievePaidLeaveHours", param, function(data) {
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
			});
		}
	}
	//user 검색팝업
	function emplyoeePopup(rowIdx, colName, applicationUserId, keyword) {
		var cgrid = grid.getGridBase();
		myForm.popupInfo.userPopup = { searchMode : "single", fseYn:"N", flsaYn:"N"};
		var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
		popup.setSize( 1000, 528 );
		popup.open( function(){
			var array = myForm.popupInfo.userPopup.userData;
			if(array.length == 0) {
				return;
			}else{
				transaction('lgvhr','lgvpay/LGVPAY00032/retrieveEmployeeInfo',{'employeeNo':array[0].employeeNo}, function(data) {
					cgrid.setValue(rowIdx,'employeeNo',data.result.employeeNo);
					cgrid.setValue(rowIdx,'employeeName',data.result.employeeName);
					cgrid.setValue(rowIdx,'gradeCode',data.result.gradeCode);
					cgrid.setValue(rowIdx,'gradeTitle',data.result.gradeTitleName);
					cgrid.setValue(rowIdx,'organizationName',data.result.organizationName);
					cgrid.setValue(rowIdx,'empCategoryName',data.result.empCategoryName);
					cgrid.setValue(rowIdx,'workTypeName',data.result.workTypeName);
					cgrid.setValue(rowIdx,'dateHireSubsidiary',data.result.dateHireSubsidiary);
					cgrid.setValue(rowIdx,'dateRetire',data.result.dateRetire);
				});
			}
		});
	}
	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		param.payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVPAY00032/createPaidLeaveEmpUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	
	$("input[name=employeeNo]").keydown(function (key) {
		if(key.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'employeeNo'  				, dataType:'text'},
		    { fieldName: 'employeeName'         	, dataType:'text'},
		    { fieldName: 'employeeNameLocal'        , dataType:'text'},
		    { fieldName: 'paidLeaveDays'            , dataType:'number'},
		    { fieldName: 'paidLeaveHours'           , dataType:'number'},
		    { fieldName: 'perfectWorkDays'          , dataType:'number'},
		    { fieldName: 'perfectWorkHours'         , dataType:'number'},
		    { fieldName: 'extraHours'               , dataType:'number'},
		    { fieldName: 'baseSalary'               , dataType:'number'},
		    { fieldName: 'positionAllowance'        , dataType:'number'},
		    { fieldName: 'qualificationAllowance'   , dataType:'number'},
		    { fieldName: 'jobAllowance'             , dataType:'number'},
		    { fieldName: 'adjustmentAllowance1'     , dataType:'number'},
		    { fieldName: 'adjustmentAllowance2'     , dataType:'number'},
		    { fieldName: 'adjustmentAllowance3'     , dataType:'number'},
		    { fieldName: 'encouragementIncentiveBase' , dataType:'number'},
		    { fieldName: 'attendanceIncentiveBase'    , dataType:'number'},
		    { fieldName: 'busDeductAmount'            , dataType:'number'},
		    { fieldName: 'menstruationBase'           , dataType:'number'},
		    { fieldName: 'adjQualificationAmt'        , dataType:'number'},
		    { fieldName: 'qualificationAmount'        , dataType:'number'},
		    { fieldName: 'encouragementIncentive'     , dataType:'number'},
		    { fieldName: 'deductTransportPlDays'      , dataType:'number'},
		    { fieldName: 'deductTransportAmount'      , dataType:'number'},
		    { fieldName: 'actualExtraHourAmount'      , dataType:'number'},
		    { fieldName: 'deductAttIncentive'         , dataType:'number'},
		    { fieldName: 'deductAttIncentiveAmt'      , dataType:'number'},
		    { fieldName: 'menstruationAdjustment'     , dataType:'number'},
		    { fieldName: 'menstruationUpManual'       , dataType:'number'}
		]);
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
 				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:100,
					header: {text:'<lgcom:message code="label.pay.employeeNo" />', required : true},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'paidLeaveDays',
					fieldName:'paidLeaveDays',
					width:120,
					header: {text:'<lgcom:message code="label.pay.paidLeaveDays" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.paidLeaveDays" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'paidLeaveHours',
					fieldName:'paidLeaveHours',
					width:120,
					header: {text:'<lgcom:message code="label.pay.paidLeaveHours" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.paidLeaveHours" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'perfectWorkDays',
					fieldName:'perfectWorkDays',
					width:120,
					header: {text:'<lgcom:message code="label.pay.perfectWorkDays" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.perfectWorkDays" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'perfectWorkHours',
					fieldName:'perfectWorkHours',
					width:120,
					header: {text:'<lgcom:message code="label.pay.perfectWorkHours" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.perfectWorkHours" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'extraHours',
					fieldName:'extraHours',
					width:120,
					header: {text:'<lgcom:message code="label.pay.extraHours" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.extraHours" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'baseSalary',
					fieldName:'baseSalary',
					width:120,
					header: {text:'<lgcom:message code="label.pay.baseSalary" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.baseSalary" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'positionAllowance',
					fieldName:'positionAllowance',
					width:120,
					header: {text:'<lgcom:message code="label.pay.positionAllowance" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.positionAllowance" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'qualificationAllowance',
					fieldName:'qualificationAllowance',
					width:120,
					header: {text:'<lgcom:message code="label.pay.qualificationAllowance" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.qualificationAllowance" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'jobAllowance',
					fieldName:'jobAllowance',
					width:120,
					header: {text:'<lgcom:message code="label.pay.jobAllowance" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.jobAllowance" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'adjustmentAllowance1',
					fieldName:'adjustmentAllowance1',
					width:120,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance1" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance1" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'adjustmentAllowance2',
					fieldName:'adjustmentAllowance2',
					width:120,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance2" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance2" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'adjustmentAllowance3',
					fieldName:'adjustmentAllowance3',
					width:120,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance3" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.adjustmentAllowance3" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'encouragementIncentiveBase',
					fieldName:'encouragementIncentiveBase',
					width:120,
					header: {text:'<lgcom:message code="label.pay.encouragementIncentiveBase" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.encouragementIncentiveBase" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'attendanceIncentiveBase',
					fieldName:'attendanceIncentiveBase',
					width:120,
					header: {text:'<lgcom:message code="label.pay.attendanceIncentiveBase" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.attendanceIncentiveBase" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'busDeductAmount',
					fieldName:'busDeductAmount',
					width:120,
					header: {text:'<lgcom:message code="label.pay.busDeductAmount" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.busDeductAmount" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'adjQualificationAmt',
					fieldName:'adjQualificationAmt',
					width:120,
					header: {text:'<lgcom:message code="label.pay.adjQualificationAmt" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.adjQualificationAmt" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'qualificationAmount',
					fieldName:'qualificationAmount',
					width:120,
					header: {text:'<lgcom:message code="label.pay.qualificationAmount" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.qualificationAmount" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'encouragementIncentive',
					fieldName:'encouragementIncentive',
					width:120,
					header: {text:'<lgcom:message code="label.pay.encouragementIncentive" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.encouragementIncentive" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'deductTransportPlDays',
					fieldName:'deductTransportPlDays',
					width:120,
					header: {text:'<lgcom:message code="label.pay.deductTransportPlDays" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.deductTransportPlDays" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'deductTransportAmount',
					fieldName:'deductTransportAmount',
					width:120,
					header: {text:'<lgcom:message code="label.pay.deductTransportAmount" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.deductTransportAmount" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'actualExtraHourAmount',
					fieldName:'actualExtraHourAmount',
					width:120,
					header: {text:'<lgcom:message code="label.pay.actualExtraHourAmount" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.actualExtraHourAmount" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'deductAttIncentiveAmt',
					fieldName:'deductAttIncentiveAmt',
					width:120,
					header: {text:'<lgcom:message code="label.pay.deductAttIncentiveAmt" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.deductAttIncentiveAmt" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'menstruationAdjustment',
					fieldName:'menstruationAdjustment',
					width:120,
					header: {text:'<lgcom:message code="label.pay.menstruationAdjustment" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.menstruationAdjustment" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
				},
				{
					name:'menstruationUpManual',
					fieldName:'menstruationUpManual',
					width:120,
					header: {text:'<lgcom:message code="label.pay.menstruationUpManual" />'},
					styles: {textAlignment:'far', numberFormat: '#,##0'},
					editable : true,
					header: {text:'<lgcom:message code="label.pay.menstruationUpManual" />', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}, expression: "sum"}}
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
				},
				fixed: { colCount: 2 }
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
	gridView.onCellEdited = function(grid, itemIndex, dataRow, field){
		grid.commit();
	}
}


LGVPAY00032.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00032();
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
						<col width="50"/>
						<col width="100"/>
						<col width="150"/>
						<col width="160"/>
						<col width="150"/>
						<col width="160"/>
						<col width="160"/>
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><lgcom:message code="label.att.month"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                	<select class="form-control input-sm input-require" name="payMonth" id="payMonth"></select>
                            	</div>
		                    </td>
		                    <th><label class="required"><i class="asterisk">*</i><lgcom:message code="label.pay.payType" /></label></th>
		                	<td><select class="form-control input-sm input-require" name="paidLeaveDetailCode" ></select></td>
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
							<th>
								<label><lgcom:message code="label.pay.employeeName" /></label>
							</th>
							<td>
								<input type="text" class="form-control input-sm" name="employeeName">
							</td>
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
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid paidLeaveEmployeeHoursGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
