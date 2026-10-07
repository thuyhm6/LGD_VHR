<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00029.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Upload Severance Allowance
    작성자 : HMT_20251010
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVPAY00029 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	
   	
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
	var grid = buildGrid('.severanceAllowanceGrid');
	var gridView = grid.getGridBase();
	var provider = grid.getDataProvider();
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	var confirmFlagList = [ {code: 'Y', name: 'Confirmed'}, {code: 'N', name: 'Not Yet'}, {code: 'R', name: 'Rejected'} ];
	
/* 	this.addEvent('change',"select[name='payMonth']",function(event) {
		search();
	}); */
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''},
        calculationPopup : { popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[] }
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
		case "calculate" :
		    //연차 계산 및 보정
		    fncCalculateSeveranceAllowance();
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
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00029/saveSeveranceAllowance', function(data) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'deleteAll':
			var grid1 = grid.getGridBase();
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			var calculationSetId = srchFormUtil.getValue("calculationSetId");
			var param = {};
			param.payMonth = payMonth;
			param.calculationSetId = calculationSetId;
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( payMonth == '' || calculationSetId == '') {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			Message.confirm('<lgcom:message code="note.pay.deleteAll"/>', function() {
				myForm.showProgress();
				myForm.transaction('lgvhr','lgvpay/LGVPAY00029/deleteAllSeveranceAllowanceInMonth',param, function(data, gridData ) {
					myForm.hideProgress();
					Message.alert('<lgcom:message code="note.successfullyDelete"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'applyAll':
			var grid1 = grid.getGridBase();
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			var calculationSetId = srchFormUtil.getValue("calculationSetId");
			console.log(calculationSetId);
			var param = {};
			param.payMonth = payMonth;
			param.calculationSetId = calculationSetId;
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( payMonth == '' || calculationSetId == '') {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			Message.confirm('<lgcom:message code="ApplyAll"/>', function() {
				myForm.showProgress();
				myForm.transaction('lgvhr','lgvpay/LGVPAY00029/applyAllSeveranceAllowanceInMonth',param, function(data, gridData ) {
					myForm.hideProgress();
					Message.alert('<lgcom:message code="note.successfullyDelete"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
			// 급여대상자 SET 조회 팝업
	    case "openPopupCalSet" :
            var popupData = myForm.popupInfo.calculationPopup;
            popupData.popupKind    = "";
            popupData.confirmKind  = "";
            var payMonth = srchFormUtil.getValue("payMonth");
            var year = payMonth.substring(0, 4); 
            var month = payMonth.substring(4, 6); 
            popupData.calculationSetName = month + "/" + year;
            srchFormUtil.setValue({calculationSetId : '', calculationSetName : ''});

            var popup = new Popup( myForm,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	if ( popupData.calculationData != undefined && popupData.calculationData.length > 0 ) {
            		var selectData = popupData.calculationData[0];
	            	srchFormUtil.setValue({calculationSetId   : selectData.calculationSetId, 
	            		                   calculationSetName : selectData.calculationSetName});
	            	myForm.select("button[data-action='calculate']").removeAttr("disabled");
					myForm.select("button[data-action='deleteAll']").removeAttr("disabled");
					myForm.select("button[data-action='applyAll']").removeAttr("disabled");
					myForm.select("button[data-action='excelUpload']").removeAttr("disabled");
	            	//검색조건 값이 있는 경우 데이터 조회
	        		search();
            	}
            });
            popupData.calculationData = [];
            break;
			
		case 'delete':
			grid.getGridBase().deleteSelection(true);
			break;
			
		case 'directCSV':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgvhr", "LGVPAY00029.createDirectCSVDownloadData", srchFormUtil.getValue());
				});
			}
			break;
			
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = srchFormUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00029/createExcelExportData", param );
				});
			}
			break;
			 
		case 'excelUpload':
			var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
			var calculationSetId = srchFormUtil.getValue("calculationSetId");
			if( payMonth == '' || calculationSetId == '') {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			var uploader = new ExcelUploader("lgvhr", "LGVPAY00029", {});
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
			grid.loadData("lgvhr", "lgvpay/LGVPAY00029/retrieveSeveranceAllowanceList", param, function(data) {
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
			});
		}
	}
	
	//연차 계산 및 보정
	function fncCalculateSeveranceAllowance() {
		Message.confirm( "<lgcom:message code="question.pay.calculate"/>", function() {

			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvpay/LGVPAY00029/saveCalculateSeveranceAllowance", srchFormUtil.getValue(), function (data) {
				myForm.hideProgress();
				Message.alert('<lgcom:message code="note.successfullyDelete"/>');
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
			}, function (data) { myForm.hideProgress(); });//myForm.transaction
		});//Message.confirm
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
				transaction('lgvhr','lgvpay/LGVPAY00029/retrieveEmployeeInfo',{'employeeNo':array[0].employeeNo}, function(data) {
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
		param.calculationSetId = srchFormUtil.getValue("calculationSetId");
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVPAY00029/createSeveranceAllowanceUpload',param, function(data) {
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
		    { fieldName: 'employeeNo'               , dataType:'text'},
			{ fieldName: 'employeeName'             , dataType:'text'},
			{ fieldName: 'organizationName'         , dataType:'text'},
			{ fieldName: 'gradeCode'                , dataType:'text'},
			{ fieldName: 'startDate'                , dataType:'text'},
			{ fieldName: 'probationStartDate'       , dataType:'text'},
			{ fieldName: 'probationEndDate'         , dataType:'text'},
			{ fieldName: 'maternityTimes'           , dataType:'number'},
			{ fieldName: 'severanceAllowanceId'     , dataType:'text'},
			{ fieldName: 'paymentyyyymm'            , dataType:'text'},
			{ fieldName: 'period1stFrom'            , dataType:'text'},
			{ fieldName: 'period1stTo'              , dataType:'text'},
			{ fieldName: 'period2ndFrom'            , dataType:'text'},
			{ fieldName: 'period2ndTo'              , dataType:'text'},
			{ fieldName: 'period3rdFrom'            , dataType:'text'},
			{ fieldName: 'period3rdTo'              , dataType:'text'},
			{ fieldName: 'period4thFrom'            , dataType:'text'},
			{ fieldName: 'period4thTo'              , dataType:'text'},
			{ fieldName: 'resignationDate'          , dataType:'text'},
			{ fieldName: 'workingYears'             , dataType:'number'},
			{ fieldName: 'flagYn'                   , dataType:'text'},
			{ fieldName: 'salary1st'                , dataType:'number'},
			{ fieldName: 'salary2nd'                , dataType:'number'},
			{ fieldName: 'salary3rd'                , dataType:'number'},
			{ fieldName: 'salary4th'                , dataType:'number'},
			{ fieldName: 'salary5th'                , dataType:'number'},
			{ fieldName: 'salary6th'                , dataType:'number'},
			{ fieldName: 'averageSalary'            , dataType:'number'},
			{ fieldName: 'periodForCal'             , dataType:'text'},
			{ fieldName: 'payment'                  , dataType:'number'},
			{ fieldName: 'accOrgCode'               , dataType:'text'},
			{ fieldName: 'bankAccountNumber'        , dataType:'text'},
			{ fieldName: 'bankName'                 , dataType:'text'},
			{ fieldName: 'leavingReason'            , dataType:'text'},
			{ fieldName: 'maternity1Day'            , dataType:'number'},
			{ fieldName: 'maternity2Day'            , dataType:'number'},
			{ fieldName: 'maternity3Day'            , dataType:'number'},
			{ fieldName: 'maternity4Day'            , dataType:'number'},
			{ fieldName: 'probationDay'             , dataType:'number'},
			{ fieldName: 'adjustDay'                , dataType:'number'},
			{ fieldName: 'totalDay'                 , dataType:'number'},
			{ fieldName: 'paidMonth'                , dataType:'number'},
			{ fieldName: 'note'                     , dataType:'text'},
			{ fieldName: 'confirmFlag'              , dataType:'text'}
		]);
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
					{	name:'confirmFlag',
						fieldName:'confirmFlag',
						width:70,
						header: {text:'<lgcom:message code="label.att.confirmFlag"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: 'confirmFlagList',
						lookupKeyFields: ['confirmFlag'],
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
						width:150,
						header: {text:'<lgcom:message code="label.pay.employeeName"/>'},
						editable: false
					},
					{
						name:'empCategoryName',
						fieldName:'empCategoryName',
						width:150,
						type: 'data',
						header: {text:'<lgcom:message code="label.pay.empCategory" />'},
						styles: {textAlignment:'center'},
						editable : false
					},
					{
						name:'gradeCode',
						fieldName:'gradeCode',
						width:100,
						header: {text:'<lgcom:message code="label.pay.grade"/>'},
						styles: {textAlignment:'center'},
						editable : false
					},
					{
						name:'organizationName',
						fieldName:'organizationName',
						width:300,
						header: {text:'<lgcom:message code="label.pay.organizationName" />'},
						styles: {textAlignment:'near'},
						editable : false
					},
					{
						name:'startDate',
						fieldName:'startDate',
						width:90,
						header: {text:'<lgcom:message code="StartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'probationStartDate',
						fieldName:'probationStartDate',
						width:80,
						header: {text:'<lgcom:message code="label.pay.probationStartDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'probationEndDate',
						fieldName:'probationEndDate',
						width:80,
						header: {text:'<lgcom:message code="label.pay.probationEndDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'maternityTimes',
						fieldName:'maternityTimes',
						width:110,
						header: {text:'<lgcom:message code="label.pay.accmulationFromLastYear"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						type:'group',
						name:'Maternity Period',
						fieldName:'Maternity Period',
						width:180,
						header:{
					         text:'Maternity Period',
					         fixedHeight: 80
					    },
						orientation:'horizontal',
						columns: [
						            {	name:'period1stFrom',   
						            	fieldName:'period1stFrom',  
						            	width:90, 
						            	header: {text:'<lgcom:message code="From" />'}, 
						            	editable: true,
						            	styles: {textAlignment:'center'}
						            },
						            {	name:'period1stTo', 
						            	fieldName:'period1stTo',
						            	width:90,
						            	header: 'To',  
						            	editable: true,
						            	styles: {textAlignment:'near'}
						            }
						         ]
					},
					{
						type:'group',
						name:'Maternity Period',
						fieldName:'Maternity Period',
						width:180,
						header:{
					         text:'Maternity Period',
					         fixedHeight: 80
					    },
						orientation:'horizontal',
						columns: [
						            {	name:'period2ndFrom',   
						            	fieldName:'period2ndFrom',  
						            	width:90, 
						            	header: {text:'<lgcom:message code="From" />'}, 
						            	editable: true,
						            	styles: {textAlignment:'center'}
						            },
						            {	name:'period2ndTo', 
						            	fieldName:'period2ndTo',
						            	width:90,
						            	header: 'To',  
						            	editable: true,
						            	styles: {textAlignment:'near'}
						            }
						         ]
					},
					{
						type:'group',
						name:'Maternity Period',
						fieldName:'Maternity Period',
						width:180,
						header:{
					         text:'Maternity Period',
					         fixedHeight: 80
					    },
						orientation:'horizontal',
						columns: [
						            {	name:'period3rdFrom',   
						            	fieldName:'period3rdFrom',  
						            	width:90, 
						            	header: {text:'<lgcom:message code="From" />'}, 
						            	editable: true,
						            	styles: {textAlignment:'center'}
						            },
						            {	name:'period3rdTo', 
						            	fieldName:'period3rdTo',
						            	width:90,
						            	header: 'To',  
						            	editable: true,
						            	styles: {textAlignment:'near'}
						            }
						         ]
					},
					{
						type:'group',
						name:'Maternity Period',
						fieldName:'Maternity Period',
						width:180,
						header:{
					         text:'Maternity Period',
					         fixedHeight: 80
					    },
						orientation:'horizontal',
						columns: [
						            {	name:'period4thFrom',   
						            	fieldName:'period4thFrom',  
						            	width:90, 
						            	header: {text:'<lgcom:message code="From" />'}, 
						            	editable: true,
						            	styles: {textAlignment:'center'}
						            },
						            {	name:'period4thTo', 
						            	fieldName:'period4thTo',
						            	width:90,
						            	header: 'To',  
						            	editable: true,
						            	styles: {textAlignment:'near'}
						            }
						         ]
					},
					{
						name:'resignationDate',
						fieldName:'resignationDate',
						width:90,
						header: {text:'<lgcom:message code="label.pay.resignationDate"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'workingYears',
						fieldName:'workingYears',
						width:50,
						header: {text:'<lgcom:message code="label.pay.workingYears"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'flagYn',
						fieldName:'flagYn',
						width:50,
						header: {text:'<lgcom:message code="label.pay.flagYn"/>'},
						styles: {textAlignment:'center'},
						editable: true
					},
					{
						name:'salary1st',
						fieldName:'salary1st',
						width:110,
						header: {text:'<lgcom:message code="label.pay.salary1st"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'salary2nd',
						fieldName:'salary2nd',
						width:120,
						header: {text:'<lgcom:message code="label.pay.salary2nd"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'salary3rd',
						fieldName:'salary3rd',
						width:110,
						header: {text:'<lgcom:message code="label.pay.salary3rd"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'salary4th',
						fieldName:'salary4th',
						width:120,
						header: {text:'<lgcom:message code="label.pay.salary4th"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'salary5th',
						fieldName:'salary5th',
						width:90,
						header: {text:'<lgcom:message code="label.pay.salary5th"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0'},
						editable: true
					},
					{
						name:'salary6th',
						fieldName:'salary6th',
						width:100,
						header: {text:'<lgcom:message code="label.pay.salary6th"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'averageSalary',
						fieldName:'averageSalary',
						width:100,
						header: {text:'<lgcom:message code="label.pay.averageSalary"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'periodForCal',
						fieldName:'periodForCal',
						width:50,
						header: {text:'<lgcom:message code="label.pay.periodForCal"/>'},
						styles: {textAlignment:'center'},
						editable: true
					},
					{
						name:'payment',
						fieldName:'payment',
						width:100,
						header: {text:'<lgcom:message code="label.pay.payment"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'accOrgCode',
						fieldName:'accOrgCode',
						width:90,
						header: {text:'<lgcom:message code="label.pay.organization"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'bankAccountNumber',
						fieldName:'bankAccountNumber',
						width:90,
						header: {text:'<lgcom:message code="label.pay.accountNumber"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'bankName',
						fieldName:'bankName',
						width:90,
						header: {text:'<lgcom:message code="label.pay.bankName"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'leavingReason',
						fieldName:'leavingReason',
						width:90,
						header: {text:'<lgcom:message code="label.pay.leavingReason"/>'},
						styles: {textAlignment:'center'},
						editable: true
					},
					{
						name:'maternity1Day',
						fieldName:'maternity1Day',
						width:50,
						header: {text:'<lgcom:message code="label.pay.maternity1Day"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'maternity2Day',
						fieldName:'maternity2Day',
						width:50,
						header: {text:'<lgcom:message code="label.pay.maternity2Day"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'maternity3Day',
						fieldName:'maternity3Day',
						width:50,
						header: {text:'<lgcom:message code="label.pay.maternity3Day"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'maternity4Day',
						fieldName:'maternity4Day',
						width:50,
						header: {text:'<lgcom:message code="label.pay.maternity4Day"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'probationDay',
						fieldName:'probationDay',
						width:50,
						header: {text:'<lgcom:message code="label.pay.probationDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'adjDays',
						fieldName:'adjDays',
						width:50,
						header: {text:'<lgcom:message code="label.pay.adjDays"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'totalDay',
						fieldName:'totalDay',
						width:50,
						header: {text:'<lgcom:message code="label.pay.totalDay"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editor: {type:'number'},
						editable: true
					},
					{
						name:'paidMonth',
						fieldName:'paidMonth',
						width:50,
						header: {text:'<lgcom:message code="label.pay.paidMonth"/>'},
						styles: {textAlignment:'far', numberFormat: '#,##0.0'},
						editable: true
					},
					{
						name:'note',
						fieldName:'note',
						width:140,
						header: {text:'<lgcom:message code="label.pay.note"/>'},
						styles: {textAlignment:'center'},
						editable: true
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
					height: 40
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


LGVPAY00029.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00029();
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
					<button class="btn btn-gray btn-sm" type="button" data-action="calculate" disabled><lgcom:message code="button.pay.calculate"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> 
					<lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> 
					<lgcom:message code="Delete"/></button>
					<button class="btn btn-gray btn-sm" type="button" data-action="LGVPAY00029/saveSeveranceAllowance"><lgcom:message code="Save"/></button>
				</div>
				<div class="btn-group">	
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
				<div class="btn-group">
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload" disabled><span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="deleteAll" data-access="LGVPAY00029/deleteAllSeveranceAllowanceInMonth" disabled>
					<span class="fa fa-minus" aria-hidden="true"></span><lgcom:message code="Delete All"/></button>	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="applyAll" data-access="LGVPAY00029/applyAllSeveranceAllowanceInMonth" disabled>
					<span aria-hidden="true"></span><lgcom:message code="ApplyAll"/></button>			
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid severanceAllowanceGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
