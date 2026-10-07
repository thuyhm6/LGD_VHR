<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00034.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Annual Leave Summary
    작성자 : HMT_20260701
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVPAY00034 = function() {
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
	var grid = buildGrid('.alSummaryEmployeeGrid');
	var gridView = grid.getGridBase();
	var provider = grid.getDataProvider();
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
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
	    	var payMonth = $.trim(myForm.select(".searchBlock select[name='payMonth']").val());
	    	//var calculationSetId = $.trim(myForm.select(".searchBlock select[name='calculationSetId']").val());
	    	console.log(payMonth);
	    	console.log(isNull(srchFormUtil.getValue("calculationSetId")));
	    	if( payMonth == '' || isNull(srchFormUtil.getValue("calculationSetId"))) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
	    	fncCalculateAnnualLeave();
	    	break;
		case 'directCSV':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgvhr", "LGVPAY00034.createDirectCSVDownloadData", srchFormUtil.getValue());
				});
			}
			break;
			
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = srchFormUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00034/createExcelExportData", param );
				});
			}
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
	        		//search();
            	}
            });
            popupData.calculationData = [];
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
        	//fncSearchEmpInfoInit();
            
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
			grid.loadData("lgvhr", "lgvpay/LGVPAY00034/retrieveAlSummaryEmpList", param, function(data) {
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
			});
		}
	}
	//연차 계산 및 보정
	function fncCalculateAnnualLeave() {
		Message.confirm( "<lgcom:message code="question.pay.calculate"/>", function() {

			myForm.showProgress();
			myForm.transaction("lgvhr", "lgvpay/LGVPAY00034/caculateAnnualLeave", srchFormUtil.getValue(), function (data) {
				myForm.hideProgress();
				if ( data.result ) {
					if ( nvl(data.result.retCode) == 0 ) {
						Message.alert("<lgcom:message code="note.pay.successfullyProcessed"/>");
						//화면 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger("click");
					} else {
						Message.alert("<lgcom:message code="note.pay.failProcesse"/>");
					}
				}//if ( data.result ) 
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
				transaction('lgvhr','lgvpay/LGVPAY00034/retrieveEmployeeInfo',{'employeeNo':array[0].employeeNo}, function(data) {
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
                { fieldName: 'employeeNumber'            , dataType:'text'},
                { fieldName: 'employeeName'              , dataType:'text'},
                { fieldName: 'orgNameLocal'              , dataType:'text'},
                { fieldName: 'dateHireSubsidiary'        , dataType:'text'},
                { fieldName: 'timeAndAttendanceYyyymm'   , dataType:'text'},
                { fieldName: 'resignationDate'           , dataType:'text'},
                { fieldName: 'totalBasicCurrYear'        , dataType:'number'},
                { fieldName: 'totalCalibCurrYear'        , dataType:'number'},
                { fieldName: 'residualDecPrevYear'       , dataType:'number'},
                { fieldName: 'occurMonthlyDecPrevYear'   , dataType:'number'},
                { fieldName: 'alCreateCurrYear'          , dataType:'number'},
                { fieldName: 'm01PerfectDays'            , dataType:'number'},
                { fieldName: 'm01ActualDays'             , dataType:'number'},
                { fieldName: 'm01UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm01AlDays'                 , dataType:'number'},
                { fieldName: 'm02PerfectDays'            , dataType:'number'},
                { fieldName: 'm02ActualDays'             , dataType:'number'},
                { fieldName: 'm02UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm02AlDays'                 , dataType:'number'},
                { fieldName: 'm03PerfectDays'            , dataType:'number'},
                { fieldName: 'm03ActualDays'             , dataType:'number'},
                { fieldName: 'm03UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm03AlDays'                 , dataType:'number'},
                { fieldName: 'm04PerfectDays'            , dataType:'number'},
                { fieldName: 'm04ActualDays'             , dataType:'number'},
                { fieldName: 'm04UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm04AlDays'                 , dataType:'number'},
                { fieldName: 'm05PerfectDays'            , dataType:'number'},
                { fieldName: 'm05ActualDays'             , dataType:'number'},
                { fieldName: 'm05UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm05AlDays'                 , dataType:'number'},
                { fieldName: 'm06PerfectDays'            , dataType:'number'},
                { fieldName: 'm06ActualDays'             , dataType:'number'},
                { fieldName: 'm06UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm06AlDays'                 , dataType:'number'},
                { fieldName: 'm07PerfectDays'            , dataType:'number'},
                { fieldName: 'm07ActualDays'             , dataType:'number'},
                { fieldName: 'm07UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm07AlDays'                 , dataType:'number'},
                { fieldName: 'm08PerfectDays'            , dataType:'number'},
                { fieldName: 'm08ActualDays'             , dataType:'number'},
                { fieldName: 'm08UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm08AlDays'                 , dataType:'number'},
                { fieldName: 'm09PerfectDays'            , dataType:'number'},
                { fieldName: 'm09ActualDays'             , dataType:'number'},
                { fieldName: 'm09UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm09AlDays'                 , dataType:'number'},
                { fieldName: 'm10PerfectDays'            , dataType:'number'},
                { fieldName: 'm10ActualDays'             , dataType:'number'},
                { fieldName: 'm10UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm10AlDays'                 , dataType:'number'},
                { fieldName: 'm11PerfectDays'            , dataType:'number'},
                { fieldName: 'm11ActualDays'             , dataType:'number'},
                { fieldName: 'm11UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm11AlDays'                 , dataType:'number'},
                { fieldName: 'm12PerfectDays'            , dataType:'number'},
                { fieldName: 'm12ActualDays'             , dataType:'number'},
                { fieldName: 'm12UnpaidLeave'            , dataType:'number'},
                { fieldName: 'm12AlDays'                 , dataType:'number'},
                { fieldName: 'createThisYear'            , dataType:'number'},
                { fieldName: 'totalAnnualCurrYear'       , dataType:'number'},
                { fieldName: 'totalUseCurrYear'          , dataType:'number'},
                { fieldName: 'fullDays'                  , dataType:'number'},
                { fieldName: 'totalWorkingDays'          , dataType:'number'},
                { fieldName: 'totalUnpaidThisYear'       , dataType:'number'},
                { fieldName: 'alPayAdjust'               , dataType:'number'},
                { fieldName: 'alPayCount'                , dataType:'number'},
                { fieldName: 'remainDay'                 , dataType:'number'},
                { fieldName: 'salInfo'                   , dataType:'number'},
                { fieldName: 'prevPerfectDays'           , dataType:'number'},
                { fieldName: 'alPayAmount'               , dataType:'number'}
		]);
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
 				{
					name:'employeeNumber',
					fieldName:'employeeNumber',
					width:100,
					header: {text:'<lgcom:message code="label.pay.employeeNo" />', required : true},
					styles: {textAlignment:'center'},
					editable: false
				},
				{
					name:'employeeName',
					fieldName:'employeeName',
					width:200,
					header: {text:'<lgcom:message code="EmployeeEngName"/>'},
					renderer: {showTooltip:true},
					editable: false
				},
				{
					name:'orgNameLocal',
					fieldName:'orgNameLocal',
					width:300,
					header: {text:'<lgcom:message code="label.pay.organizationName" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'dateHireSubsidiary',
					fieldName:'dateHireSubsidiary',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.hireDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'timeAndAttendanceYyyymm',
					fieldName:'timeAndAttendanceYyyymm',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.calcStartDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'resignationDate',
					fieldName:'resignationDate',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.resignationDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name: 'totalBasicCurrYear',
					fieldName: 'totalBasicCurrYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalBasicCurrYear" />'}
				},
				{
					name: 'totalCalibCurrYear',
					fieldName: 'totalCalibCurrYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalCalibCurrYear" />'}
				},
				{
					name: 'residualDecPrevYear',
					fieldName: 'residualDecPrevYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.residualDecPrevYear" />'}
				},
				{
					name: 'occurMonthlyDecPrevYear',
					fieldName: 'occurMonthlyDecPrevYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.occurMonthlyDecPrevYear" />'}
				},
				{
					name: 'alCreateCurrYear',
					fieldName: 'alCreateCurrYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.alCreateCurrYear" />'}
				},
				{
					type:'group',
					name:'Jan',
					fieldName:'Jan',
					width:480,
					header:{
				         text:'<lgcom:message code="Jan" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm01PerfectDays',
								fieldName: 'm01PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm01ActualDays',
								fieldName: 'm01ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm01UnpaidLeave',
								fieldName: 'm01UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm01AlDays',
								fieldName: 'm01AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Feb',
					fieldName:'Feb',
					width:480,
					header:{
				         text:'<lgcom:message code="Feb" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm02PerfectDays',
								fieldName: 'm02PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm02ActualDays',
								fieldName: 'm02ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm02UnpaidLeave',
								fieldName: 'm02UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm02AlDays',
								fieldName: 'm02AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Mar',
					fieldName:'Mar',
					width:480,
					header:{
				         text:'<lgcom:message code="Mar" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm03PerfectDays',
								fieldName: 'm03PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm03ActualDays',
								fieldName: 'm03ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm03UnpaidLeave',
								fieldName: 'm03UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm03AlDays',
								fieldName: 'm03AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Apr',
					fieldName:'Apr',
					width:480,
					header:{
				         text:'<lgcom:message code="Apr" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm04PerfectDays',
								fieldName: 'm04PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm04ActualDays',
								fieldName: 'm04ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm04UnpaidLeave',
								fieldName: 'm04UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm04AlDays',
								fieldName: 'm04AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'May',
					fieldName:'May',
					width:480,
					header:{
				         text:'<lgcom:message code="May" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm05PerfectDays',
								fieldName: 'm05PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm05ActualDays',
								fieldName: 'm05ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm05UnpaidLeave',
								fieldName: 'm05UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm05AlDays',
								fieldName: 'm05AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Jun',
					fieldName:'Jun',
					width:480,
					header:{
				         text:'<lgcom:message code="Jun" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm06PerfectDays',
								fieldName: 'm06PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm06ActualDays',
								fieldName: 'm06ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm06UnpaidLeave',
								fieldName: 'm06UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm06AlDays',
								fieldName: 'm06AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Jul',
					fieldName:'Jul',
					width:480,
					header:{
				         text:'<lgcom:message code="Jul" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm07PerfectDays',
								fieldName: 'm07PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm07ActualDays',
								fieldName: 'm07ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm07UnpaidLeave',
								fieldName: 'm07UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm07AlDays',
								fieldName: 'm07AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Aug',
					fieldName:'Aug',
					width:480,
					header:{
				         text:'<lgcom:message code="Aug" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm08PerfectDays',
								fieldName: 'm08PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm08ActualDays',
								fieldName: 'm08ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm08UnpaidLeave',
								fieldName: 'm08UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm08AlDays',
								fieldName: 'm08AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Sep',
					fieldName:'Sep',
					width:480,
					header:{
				         text:'<lgcom:message code="Sep" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm09PerfectDays',
								fieldName: 'm09PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm09ActualDays',
								fieldName: 'm09ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm09UnpaidLeave',
								fieldName: 'm09UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm09AlDays',
								fieldName: 'm09AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Oct',
					fieldName:'Oct',
					width:480,
					header:{
				         text:'<lgcom:message code="Oct" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm10PerfectDays',
								fieldName: 'm10PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm10ActualDays',
								fieldName: 'm10ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm10UnpaidLeave',
								fieldName: 'm10UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm10AlDays',
								fieldName: 'm10AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Nov',
					fieldName:'Nov',
					width:480,
					header:{
				         text:'<lgcom:message code="Nov" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm11PerfectDays',
								fieldName: 'm11PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm11ActualDays',
								fieldName: 'm11ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm11UnpaidLeave',
								fieldName: 'm11UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm11AlDays',
								fieldName: 'm11AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				{
					type:'group',
					name:'Dec',
					fieldName:'Dec',
					width:480,
					header:{
				         text:'<lgcom:message code="Dec" />',
				         fixedHeight: 40
				    },
					orientation:'horizontal',
					columns: [
							{
								name: 'm12PerfectDays',
								fieldName: 'm12PerfectDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.PerfectDays" />'}
							},
							{
								name: 'm12ActualDays',
								fieldName: 'm12ActualDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.ActualDays" />'}
							},
							{
								name: 'm12UnpaidLeave',
								fieldName: 'm12UnpaidLeave',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.unpaidDays" />'}
							},
							{
								name: 'm12AlDays',
								fieldName: 'm12AlDays',
								width: 80,
								styles: {textAlignment: 'far', numberFormat: '#,##0'},
								editable: false,
								header: {text: '<lgcom:message code="label.pay.AlDays" />'}
							}
							]
				},
				
				{
					name: 'createThisYear',
					fieldName: 'createThisYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.createThisYear" />'}
				},
				{
					name: 'totalAnnualCurrYear',
					fieldName: 'totalAnnualCurrYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalAnnualCurrYear" />'}
				},
				{
					name: 'totalUseCurrYear',
					fieldName: 'totalUseCurrYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalUseCurrYear" />'}
				},
				{
					name: 'fullDays',
					fieldName: 'fullDays',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.yearFullDays" />'}
				},
				{
					name: 'totalWorkingDays',
					fieldName: 'totalWorkingDays',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalWorkingDays" />'}
				},
				{
					name: 'totalUnpaidThisYear',
					fieldName: 'totalUnpaidThisYear',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.totalUnpaidThisYear" />'}
				},
				{
					name: 'alPayAdjust',
					fieldName: 'alPayAdjust',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.alPayAdjust" />'}
				},
				{
					name: 'alPayCount',
					fieldName: 'alPayCount',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.alPayCount" />'}
				},
				{
					name: 'remainDay',
					fieldName: 'remainDay',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.remainDays" />'}
				},
				{
					name: 'salInfo',
					fieldName: 'salInfo',
					width: 80,
					styles: {textAlignment: 'far', numberFormat: '#,##0'},
					editable: false,
					header: {text: '<lgcom:message code="label.pay.salInfo" />'}
				},
				{
					name: 'prevPerfectDays',
					fieldName: 'prevPerfectDays',
					width: 80,
					editable: false,
					header: {text: '<lgcom:message code="label.pay.prevPerfectDays" />'}
				},
				{
					name: 'alPayAmount',
					fieldName: 'alPayAmount',
					width: 80,
					styles: {textAlignment: 'far', numberFormat: '#,##0'},
					editable: false,
					header: {text: '<lgcom:message code="label.pay.alPayAmount" />'}
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
                    height: 40,
                    heightFill: 'fixed'
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


LGVPAY00034.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00034();
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
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid alSummaryEmployeeGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
