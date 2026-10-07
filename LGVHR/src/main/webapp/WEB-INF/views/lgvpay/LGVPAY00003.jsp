<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00003.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 개인별 항목 관리
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvcom.js"></script>
<script type="text/javascript">
var LGVPAY00003 = function() {
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
	    	employeeNo: {required:true},
	    	employeeName: {required:true},
	    	payrollCalcPeriodValue : { required : true, invalidPayMonth : true }
	    },
	    messages: {
	    	employeeNo: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.employeeNo'/>" />'},
	    	employeeName: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.employeeName'/>" />'},
	    	payrollCalcPeriodValue : { required : '<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payMonth'/>" />'},
	    	payrollCalcPeriodValue : { invalidPayMonth : '<lgcom:message code="error.incorrectFormat" />'}
	    }
    });
  	//Pay Month 입력값에 대한 validation 추가 
    validator.addMethod( "invalidPayMonth", function( value, element ){
    	var re = /(0[1-9]|10|11|12)\/20[0-9]{2}$/;
    	
    	// valid if optional and empty OR if it passes the regex test
    	return (this.optional(element) && value=="") || re.test(value);
    });
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
 	// 그리드 선언
	var grid = buildGrid('.payRollItemByEmployeeGrid');
 	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		payrollItemPopup   : {popupKind:'', confirmKind:'', payrollCalcPeriodValue:'', payRollItemId:'', payRollItemName:'', payrollItemData:[]},
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };

	//검색조건 기본값 셋팅
	srchFormUtil.setValue({ payrollCalcPeriodValue : DateUtil.today("MM/YYYY") });
	
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
				//해당월에 퇴직자인지 여부 조회
				transaction_sync("lgvhr", "lgvpay/LGVPAY00003/retrieveRetireData", srchFormUtil.getValue(), function(data) {
					if ( data.result ) {
						if ( nvl(data.result.retireFlag) == "Y" ) {//퇴직자인 경우
							Message.alert("<lgcom:message code="note.pay.retireEmployee" arguments='"+nvl(data.result.retireDate)+"'/>");
							//버튼 비활성화
							myForm.select("button[data-action='insert']").attr("disabled", "disabled");
							myForm.select("button[data-action='delete']").attr("disabled", "disabled");
							myForm.select("button[data-action='save']").attr("disabled", "disabled");
							return ;
							
						} else {
							//버튼 활성화
							myForm.select("button[data-action='insert']").removeAttr("disabled");
							myForm.select("button[data-action='delete']").removeAttr("disabled");
							myForm.select("button[data-action='save']").removeAttr("disabled");
							
							grid.loadData("lgvhr", "lgvpay/LGVPAY00003/retrievePayRollItemEntByEmpList", param, function(data) {
								
								if( grid.getRowCount() == 0 ) {
									Message.alert('<lgcom:message code="note.nodata"/>');
									return;
								};
							});
						}
					
					}
				});
			}
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

			var isValid = false;
			var j=1;
			for(var i=0; i < grid1.getItemCount(); i++) {
				
				// 삭제건은 제외
				if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'deleted') {
					isValid = true;//삭제 건만 있는 경우 true 처리 하지 않으면 날짜 체크에 걸림.
					continue;
				}
				
				//등록일때 적용시작일자와 종료일자 날짜 체크
				if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'created') {

						var startDateArr = grid1.getValue(i,'applyStartDate').split('/');
						var endDateArr = grid1.getValue(i,'applyEndDate').split('/');
						
						var startDateCompare = new Date(startDateArr[2], parseInt(startDateArr[1])-1, startDateArr[0]);
						var endDateCompare = new Date(endDateArr[2], parseInt(endDateArr[1])-1, endDateArr[0]);
						
						if(startDateCompare.getTime() < endDateCompare.getTime()) {
							isValid = true;
						} else {
							isValid = false;
						}

				}else{
					if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'updated') {
						if(grid1.getValue(i,'inputYn'+j) == "Y") {
							if(grid1.getValue(i,'inputValue'+j) == "undefined" || grid1.getValue(i,'inputValue'+j) == null) {
								grid1.setValue(i, 'inputValue'+j, '');
							}
						}
					}

					isValid = true;
				}

				//동일item 입력체크 alert
				//apply_start_date, apply_end_date 가 겹치는 경우만 중복으로 봄.
				var rowData = grid1.getValues(i);
				for ( var dupIndex=(i+1); dupIndex<grid1.getItemCount(); dupIndex++ ) {
					if (   i != dupIndex
						&& grid1.getValue(dupIndex, "payrollItemId") == nvl(rowData.payrollItemId)
						&& (/* 시작일이 이전 데이터의 시작일과 종료일 사이에 있는 경우 또는 종료일이 이전 데이터의 시작일과 종료일 사이에 있는 경우 */ 
							   (DateUtil.parse(grid1.getValue(dupIndex, "applyStartDate"), "DD/MM/YYYY") >= DateUtil.parse(nvl(rowData.applyStartDate), "DD/MM/YYYY") && DateUtil.parse(grid1.getValue(dupIndex, "applyStartDate"), "DD/MM/YYYY") <= DateUtil.parse(nvl(rowData.applyEndDate), "DD/MM/YYYY"))
							|| (DateUtil.parse(grid1.getValue(dupIndex, "applyEndDate")  , "DD/MM/YYYY") >= DateUtil.parse(nvl(rowData.applyStartDate), "DD/MM/YYYY") && DateUtil.parse(grid1.getValue(dupIndex, "applyEndDate")  , "DD/MM/YYYY") <= DateUtil.parse(nvl(rowData.applyEndDate), "DD/MM/YYYY"))
							)
						) {
						myForm.transaction_sync('lgvhr','lgvpay/LGVPAY00003/retreiveMutiFlagCheck',{'payrollItemId':rowData["payrollItemId"]}, function(data) {
							if ( nvl(data.result.payrollApplyFlag) == "N" ) {//중복허용 안됨.
								Message.alert("<lgcom:message code="error.dupPayrollItemName" arguments="\"+nvl(rowData.payrollItemName)+\""/>");
								isDupFlag = true;
								return;
							}
						});
					}
				}
				/* 기존 로직 주석
				if(empMap.containsKey(grid1.getValue(i,'payrollItemName'))) {
					dupPayrollItemName = grid1.getValue(i,'payrollItemName');
					dupPayrollItemId = grid1.getValue(i,'payrollItemId');
					isDupFlag = true;
					continue;
				}
				empMap.put(grid1.getValue(i,'payrollItemName'),1);
				*/
				j++;
			}<%-- //for --%>

			if(!isValid) {
				Message.alert('<lgcom:message code="note.pay.checkApplyDate"/>');
				return;
			}
			
			//multiFlag가 N이면 동일 item내역 중복등록 불가처리
			if(!isDupFlag) {
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvpay/LGVPAY00003/savePayrollItem', function(data, gridData ) {
						Message.alert('<lgcom:message code="note.saved"/>');
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
			}
		break;	
		case 'delete':
			grid.getGridBase().deleteSelection(true);
			break; 
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
            _popup.userData = [];
        	fncSearchEmpInfoInit();
        	
            var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({ employeeNo   :_popup.userData[0].employeeNo
            		                  , employeeName :_popup.userData[0].employeeName
            		                  });
            	
            	//데이터 조회
            	myForm.select(".searchBlock button[data-action='search']").trigger("click");
            });
            break;
			
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	//payMonth 검색조건 수정 시 alert
	myForm.addEvent( "change", ".searchBlock .form input[name=payrollCalcPeriodValue]" , function(event){
		var cgrid = grid.getGridBase();
		cgrid.commit();
		var itemIndexs = cgrid.getDataProvider().getStateRows("created");
		
		if(itemIndexs.length > 0) {
			Message.alert('<lgcom:message code="note.pay.noChangeValue" arguments="PayMonth"/>');
			var nav = new Navigate( myForm, "lgvhr", "M_LGVPAY_1009" );
	        nav.goPageInCurrentDiv(false);
		}
	});	

	//employeeNo 검색조건 수정 시 alert
	myForm.addEvent( "change", ".searchBlock .form input[name=employeeNo]" , function(event){
		var cgrid = grid.getGridBase();
		cgrid.commit();
		var itemIndexs = cgrid.getDataProvider().getStateRows("created");
		
		if(itemIndexs.length > 0) {
			Message.alert('<lgcom:message code="note.pay.noChangeValue" arguments="employeeNo"/>');
			var nav = new Navigate( myForm, "lgvhr", "M_LGVPAY_1009" );
	        nav.goPageInCurrentDiv(false);
		}
	});	
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 employeeNo 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('payrollItemName','editable',false);
			cgrid.setColumnProperty('payrollItemName','button','none');
			//recurring=Y인 경우 apply_start_date 수정 가능. 그외는 수정 불가
			cgrid.setColumnProperty('applyStartDate','editable', nvl(provider.getValue(newRow, "payrollApplyFlag")) == "Y"?true:false);
			// 삭제버튼 활성화
			//myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('payrollItemName','editable',true);
			cgrid.setColumnProperty('payrollItemName','button','action');
			//recurring=Y인 경우 apply_start_date 수정 가능. 그외는 수정 불가
			//cgrid.setColumnProperty('applyStartDate','editable', nvl(provider.getValue(newRow, "payrollApplyFlag")) == "Y"?true:false);
			// 삭제버튼 비활성화
			//myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
		
		
	};
	//Detail id값이 없으면 value값 입력못하게 처리
	grid.getGridBase().onDataCellDblClicked = function(cgrid, index) {
		var current = cgrid.getCurrent();
		if (current == undefined ) { return; }
		var gridRow = cgrid.getValues(current.itemIndex);
		
		if(gridRow.inputValueId1 == undefined) {
			cgrid.setColumnProperty('inputValue1','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue1','editable',true);
		}
		if(gridRow.inputValueId2 == undefined) {
			cgrid.setColumnProperty('inputValue2','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue2','editable',true);
		}
		if(gridRow.inputValueId3 == undefined) {
			cgrid.setColumnProperty('inputValue3','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue3','editable',true);
		}
		if(gridRow.inputValueId4 == undefined) {
			cgrid.setColumnProperty('inputValue4','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue4','editable',true);
		}
		if(gridRow.inputValueId5 == undefined) {
			cgrid.setColumnProperty('inputValue5','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue5','editable',true);
		}
		if(gridRow.inputValueId6 == undefined) {
			cgrid.setColumnProperty('inputValue6','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue6','editable',true);
		}
		if(gridRow.inputValueId7 == undefined) {
			cgrid.setColumnProperty('inputValue7','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue7','editable',true);
		}
		if(gridRow.inputValueId8 == undefined) {
			cgrid.setColumnProperty('inputValue8','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue8','editable',true);
		}
		if(gridRow.inputValueId9 == undefined) {
			cgrid.setColumnProperty('inputValue9','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue9','editable',true);
		}
		if(gridRow.inputValueId10 == undefined) {
			cgrid.setColumnProperty('inputValue10','editable',false);
		}else{
			cgrid.setColumnProperty('inputValue10','editable',true);
		}
		
		//Recuring = ‘Y’인 항목만 applyEndDate 수정가능하게 함
		if(gridRow.payrollApplyFlag == "Y") {
			cgrid.setColumnProperty('applyEndDate','editable',true);
		}
	};
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
	/* 셀에 값이 입력된 경우 숫자이면 숫자포맷으로 보이도록 값 수정 */
	grid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		if ( index.fieldName.indexOf("inputValue") > -1 ) {
			var valIdx = index.fieldName.replaceAll("inputValue", "");
			if ( cgrid.getValue(index.itemIndex, "inputType"+valIdx) == "A" && !isNull(newValue) ) {//금액 인 경우 콤마 표시
				cgrid.setValue(index.itemIndex, "inputValue"+valIdx, fncCurrencyFormat(newValue));
				cgrid.commit();
			} else if ( cgrid.getValue(index.itemIndex, "inputType"+valIdx) == "N" && !isNull(newValue) ) {//숫자값 인 경우 콤마 표시
				cgrid.setValue(index.itemIndex, "inputValue"+valIdx, fncNumberFormat(newValue));
				cgrid.commit();
			}
		}
	};
	//employeeNo 클릭 시 user검색 팝업호출
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		payrollItemPopup(itemIndex,column.name,gridRow.userId,gridRow.roleName);
	};
	//조회조건 사번 입력 후 엔터키 누르면 사번 검색창 오픈
	$("input[name=employeeNo]").keydown(function (key) {
		if(key.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
	//사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	fncSearchEmpInfoInit();
    });
	myForm.addEvent ( "change",".searchBlock form input[name='employeeNo'], input[name='employeeName']",function(event) {
		myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
	});
	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	//payrollItem 검색팝업
	function payrollItemPopup(rowIdx, colName, applicationUserId, keyword) {
		var cgrid = grid.getGridBase();
		var _popup = _this.popupInfo.payrollItemPopup;
		_popup.payrollCalcPeriodValue = srchFormUtil.getValue("payrollCalcPeriodValue");
		
		var popup = new Popup( _this,'lgvhr', 'M_LGVPAY_1020', '<lgcom:message code="label.pay.payrollItem"/>' );
        popup.setSize(900, 528);
        popup.open( function(){
			cgrid.setValue(rowIdx,'payrollItemId',_popup.payrollItemData[0].payrollItemId);
			cgrid.setValue(rowIdx,'payrollItemName',_popup.payrollItemData[0].inquiryName);
			var array = myForm.popupInfo.userPopup.userData;
			if(_popup.payrollItemData.length > 0) {
				transaction('lgvhr','lgvpay/LGVPAY00003/retreiveDetailValue',{'payrollItemId':_popup.payrollItemData[0].payrollItemId}, function(data) {
					cgrid.setValue(rowIdx,'employeeNo',srchFormUtil.getValue("employeeNo"));
					cgrid.setValue(rowIdx,'inputValueId1',data.result.inputValueId1);
					cgrid.setValue(rowIdx,'inputName1',data.result.inputName1);
					cgrid.setValue(rowIdx,'inputType1',data.result.inputType1);
					cgrid.setValue(rowIdx,'inputTypeName1',data.result.inputTypeName1);
					cgrid.setValue(rowIdx,'inputValue1','');
					cgrid.setValue(rowIdx,'inputYn1',data.result.inputYn1);
					cgrid.setValue(rowIdx,'inputValueId2',data.result.inputValueId2);
					cgrid.setValue(rowIdx,'inputName2',data.result.inputName2);
					cgrid.setValue(rowIdx,'inputType2',data.result.inputType2);
					cgrid.setValue(rowIdx,'inputTypeName2',data.result.inputTypeName2);
					cgrid.setValue(rowIdx,'inputValue2','');
					cgrid.setValue(rowIdx,'inputYn2',data.result.inputYn2);
					cgrid.setValue(rowIdx,'inputValueId3',data.result.inputValueId3);
					cgrid.setValue(rowIdx,'inputName3',data.result.inputName3);
					cgrid.setValue(rowIdx,'inputType3',data.result.inputType3);
					cgrid.setValue(rowIdx,'inputTypeName3',data.result.inputTypeName3);
					cgrid.setValue(rowIdx,'inputValue3','');
					cgrid.setValue(rowIdx,'inputYn3',data.result.inputYn3);
					cgrid.setValue(rowIdx,'inputValueId4',data.result.inputValueId4);
					cgrid.setValue(rowIdx,'inputName4',data.result.inputName4);
					cgrid.setValue(rowIdx,'inputType4',data.result.inputType4);
					cgrid.setValue(rowIdx,'inputTypeName4',data.result.inputTypeName4);
					cgrid.setValue(rowIdx,'inputValue4','');
					cgrid.setValue(rowIdx,'inputYn4',data.result.inputYn4);
					cgrid.setValue(rowIdx,'inputValueId5',data.result.inputValueId5);
					cgrid.setValue(rowIdx,'inputName5',data.result.inputName5);
					cgrid.setValue(rowIdx,'inputType5',data.result.inputType5);
					cgrid.setValue(rowIdx,'inputTypeName5',data.result.inputTypeName5);
					cgrid.setValue(rowIdx,'inputValue5','');
					cgrid.setValue(rowIdx,'inputYn5',data.result.inputYn5);
					cgrid.setValue(rowIdx,'inputValueId6',data.result.inputValueId6);
					cgrid.setValue(rowIdx,'inputName6',data.result.inputName6);
					cgrid.setValue(rowIdx,'inputType6',data.result.inputType6);
					cgrid.setValue(rowIdx,'inputTypeName6',data.result.inputTypeName6);
					cgrid.setValue(rowIdx,'inputValue6','');
					cgrid.setValue(rowIdx,'inputYn6',data.result.inputYn6);
					cgrid.setValue(rowIdx,'inputValueId7',data.result.inputValueId7);
					cgrid.setValue(rowIdx,'inputName7',data.result.inputName7);
					cgrid.setValue(rowIdx,'inputType7',data.result.inputType7);
					cgrid.setValue(rowIdx,'inputTypeName7',data.result.inputTypeName7);
					cgrid.setValue(rowIdx,'inputValue7','');
					cgrid.setValue(rowIdx,'inputYn7',data.result.inputYn7);
					cgrid.setValue(rowIdx,'inputValueId8',data.result.inputValueId8);
					cgrid.setValue(rowIdx,'inputName8',data.result.inputName8);
					cgrid.setValue(rowIdx,'inputType8',data.result.inputType8);
					cgrid.setValue(rowIdx,'inputTypeName8',data.result.inputTypeName8);
					cgrid.setValue(rowIdx,'inputValue8','');
					cgrid.setValue(rowIdx,'inputYn8',data.result.inputYn8);
					cgrid.setValue(rowIdx,'inputValueId9',data.result.inputValueId9);
					cgrid.setValue(rowIdx,'inputName9',data.result.inputName9);
					cgrid.setValue(rowIdx,'inputType9',data.result.inputType9);
					cgrid.setValue(rowIdx,'inputTypeName9',data.result.inputTypeName9);
					cgrid.setValue(rowIdx,'inputValue9','');
					cgrid.setValue(rowIdx,'inputYn9',data.result.inputYn9);
					cgrid.setValue(rowIdx,'inputValueId10',data.result.inputValueId10);
					cgrid.setValue(rowIdx,'inputName10',data.result.inputName10);
					cgrid.setValue(rowIdx,'inputType10',data.result.inputType10);
					cgrid.setValue(rowIdx,'inputTypeName10',data.result.inputTypeName10);
					cgrid.setValue(rowIdx,'inputValue10','');
					cgrid.setValue(rowIdx,'inputYn10',data.result.inputYn10);
				});
				transaction('lgvhr','lgvpay/LGVPAY00003/retrievePayrollApplyFlag',{'payrollItemId':_popup.payrollItemData[0].payrollItemId}, function(data) {
					cgrid.setValue(rowIdx,'payrollApplyFlag',data.result.payrollApplyFlag);
					cgrid.setColumnProperty('applyStartDate','editable', (nvl(data.result.payrollApplyFlag) == "Y")?true:false);
					
					var payrollApplyFlag = data.result.payrollApplyFlag;
					var payMonthVal = srchFormUtil.getValue("payrollCalcPeriodValue").split("/");
					
					var searchPayYear = payMonthVal[1];
					var searchPayMonth = payMonthVal[0];
					
					var startDate = searchPayYear+searchPayMonth+"01";
					var lastDay = (new Date(searchPayYear, searchPayMonth, 0)).getDate();
					var endDate = searchPayYear+"-"+searchPayMonth+"-"+lastDay;
					var employeeNo = srchFormUtil.getValue("employeeNo");
					
					//applyStartDate와 applyEndDate 조회
					transaction('lgvhr','lgvpay/LGVPAY00003/retrieveApplyDate',{'startDate':startDate, 'endDate':endDate, 'employeeNo':employeeNo}, function(data) {
						var applyStartDate = data.result.startDate;
						var applyEndDate;
						
						cgrid.setValue(rowIdx,'dateRetire',data.result.dateRetire);
						cgrid.setValue(rowIdx,'applyStartDate',data.result.startDate);
						
						/*
						1) payrollApplyFlag = 'Y' 이고 퇴직일이 있으면 퇴직일로 입력 
						2) payrollApplyFlag = 'N' 이고 퇴직일이 있으면 least(퇴직일, 급여기산종료일) 
						3) payrollApplyFlag = 'Y' 이고 퇴직일이 없으면 4712/12/31
						4) payrollApplyFlag = 'N' 이고 퇴직일이 없으면 급여기산 종료일
						*/
						
						if(payrollApplyFlag == "Y") {
							applyEndDate = data.result.recurringYdate.split("-");
						}else{
							applyEndDate = data.result.recurringNdate.split("-");
						}
						cgrid.setValue(rowIdx,'applyEndDate',applyEndDate[2]+"/"+applyEndDate[1]+"/"+applyEndDate[0]);
						cgrid.setValue(rowIdx,'beforeApplyEndDate',applyEndDate[0]+applyEndDate[1]+applyEndDate[2]);
					}); 
				});
				
			}
        });
        _popup.payrollItemData = [];
	}
	
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName: 'payrollItemPaymentPlanId', dataType:'text'},
		    { fieldName: 'payrollItemId'           , dataType:'text'},
		    { fieldName: 'payrollItemName' 	       , dataType:'text'},
		    { fieldName: 'dateRetire' 		       , dataType:'text'},
		    { fieldName: 'payrollApplyFlag'        , dataType:'text'},
		    { fieldName: 'applyStartDate'          , dataType:'text'},
		    { fieldName: 'applyEndDate'    	       , dataType:'text'},
		    { fieldName: 'retroactiveFlag'    	   , dataType:'text'},
		    { fieldName: 'beforeApplyStartDate'    , dataType:'text'},
		    { fieldName: 'beforeApplyEndDate'      , dataType:'text'},
		    { fieldName: 'employeeNo'              , dataType:'text'},
		    { fieldName: 'inputValueId1'           , dataType:'text'},
		    { fieldName: 'inputName1'    	       , dataType:'text'},
		    { fieldName: 'inputType1'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName1'          , dataType:'text'},
		    { fieldName: 'beforeValue1'    	       , dataType:'text'},
		    { fieldName: 'inputValue1'    	       , dataType:'text'},
		    { fieldName: 'inputYn1'    		       , dataType:'text'},
		    { fieldName: 'inputValueId2'           , dataType:'text'},
		    { fieldName: 'inputName2'    	       , dataType:'text'},
		    { fieldName: 'inputType2'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName2'          , dataType:'text'},
		    { fieldName: 'beforeValue2'    	       , dataType:'text'},
		    { fieldName: 'inputValue2'    	       , dataType:'text'},
		    { fieldName: 'inputYn2'    		       , dataType:'text'},
		    { fieldName: 'inputValueId3'           , dataType:'text'},
		    { fieldName: 'inputName3'    	       , dataType:'text'},
		    { fieldName: 'inputType3'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName3'          , dataType:'text'},
		    { fieldName: 'beforeValue3'    	       , dataType:'text'},
		    { fieldName: 'inputValue3'    	       , dataType:'text'},
		    { fieldName: 'inputYn3'    		       , dataType:'text'},
		    { fieldName: 'inputValueId4'           , dataType:'text'},
		    { fieldName: 'inputName4'    	       , dataType:'text'},
		    { fieldName: 'inputType4'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName4'          , dataType:'text'},
		    { fieldName: 'beforeValue4'    	       , dataType:'text'},
		    { fieldName: 'inputValue4'    	       , dataType:'text'},
		    { fieldName: 'inputYn4'    		       , dataType:'text'},
		    { fieldName: 'inputValueId5'           , dataType:'text'},
		    { fieldName: 'inputName5'    	       , dataType:'text'},
		    { fieldName: 'inputType5'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName5'          , dataType:'text'},
		    { fieldName: 'beforeValue5'    	       , dataType:'text'},
		    { fieldName: 'inputValue5'    	       , dataType:'text'},
		    { fieldName: 'inputYn5'    		       , dataType:'text'},
		    { fieldName: 'inputValueId6'           , dataType:'text'},
		    { fieldName: 'inputName6'    	       , dataType:'text'},
		    { fieldName: 'inputType6'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName6'          , dataType:'text'},
		    { fieldName: 'beforeValue6'    	       , dataType:'text'},
		    { fieldName: 'inputValue6'    	       , dataType:'text'},
		    { fieldName: 'inputYn6'    		       , dataType:'text'},
		    { fieldName: 'inputValueId7'           , dataType:'text'},
		    { fieldName: 'inputName7'    	       , dataType:'text'},
		    { fieldName: 'inputType7'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName7'          , dataType:'text'},
		    { fieldName: 'beforeValue7'    	       , dataType:'text'},
		    { fieldName: 'inputValue7'    	       , dataType:'text'},
		    { fieldName: 'inputYn7'    		       , dataType:'text'},
		    { fieldName: 'inputValueId8'           , dataType:'text'},
		    { fieldName: 'inputName8'    	       , dataType:'text'},
		    { fieldName: 'inputType8'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName8'          , dataType:'text'},
		    { fieldName: 'beforeValue8'    	       , dataType:'text'},
		    { fieldName: 'inputValue8'    	       , dataType:'text'},
		    { fieldName: 'inputYn8'    		       , dataType:'text'},
		    { fieldName: 'inputValueId9'           , dataType:'text'},
		    { fieldName: 'inputName9'    	       , dataType:'text'},
		    { fieldName: 'inputType9'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName9'          , dataType:'text'},
		    { fieldName: 'beforeValue9'    	       , dataType:'text'},
		    { fieldName: 'inputValue9'    	       , dataType:'text'},
		    { fieldName: 'inputYn9'    		       , dataType:'text'},
		    { fieldName: 'inputValueId10'          , dataType:'text'},
		    { fieldName: 'inputName10'    	       , dataType:'text'},
		    { fieldName: 'inputType10'    	       , dataType:'text'},
		    { fieldName: 'inputTypeName10'         , dataType:'text'},
		    { fieldName: 'beforeValue10'   	       , dataType:'text'},
		    { fieldName: 'inputValue10'    	       , dataType:'text'},
		    { fieldName: 'inputYn10'    	       , dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
				{
					name:'payrollItemName',
					fieldName:'payrollItemName',
					width:200,
					header: {text:'<lgcom:message code="label.pay.payrollItemName" />'},
					styles: {textAlignment:'near'},
					button: 'action',
					editable: false
				},
				{
					name:'payrollApplyFlag',
					fieldName:'payrollApplyFlag',
					width:120,
					header: {text:'<lgcom:message code="label.pay.recurringYn" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'applyStartDate', 
					fieldName:'applyStartDate',
					width:120,
					header: {text:'<lgcom:message code="label.pay.applyStartDate"/>'},
					styles: {textAlignment:'center'},
					editButtonVisibility:'visible', /* 셀 포커스 될때만 달력 버튼 보여줌 */
					editor: {type:'date', textReadOnly : true, datetimeFormat:'dd/MM/yyyy'},
					editable : false
				},		
				{
					name:'applyEndDate',
					fieldName:'applyEndDate',
					width:120,
					header: {text:'<lgcom:message code="label.pay.applyEndDate" />'},
					styles: {textAlignment:'center'},
					editor: {type:'date',textReadOnly : true, datetimeFormat:'dd/MM/yyyy'},
					editable : false
				},		
				{
					name:'retroactiveFlag',
					fieldName:'retroactiveFlag',
					width:70,
					header: {text:'<lgcom:message code="label.pay.retroactiveFlag" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					type:'group',
					name:'detail1',
					fieldName:'detail1',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail1" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName1',   
					            	fieldName:'inputName1',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName1', 
					            	fieldName:'inputTypeName1',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue1',
					            	fieldName:'inputValue1',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType1']='A') or (values['inputType1']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail2',
					fieldName:'detail2',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail2" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName2',   
					            	fieldName:'inputName2',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName2', 
					            	fieldName:'inputTypeName2',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue2',
					            	fieldName:'inputValue2',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType2']='A') or (values['inputType2']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail3',
					fieldName:'detail3',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail3" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName3',   
					            	fieldName:'inputName3',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName3', 
					            	fieldName:'inputTypeName3',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue3',
					            	fieldName:'inputValue3',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType3']='A') or (values['inputType3']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail4',
					fieldName:'detail4',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail4" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName4',   
					            	fieldName:'inputName4',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName4', 
					            	fieldName:'inputTypeName4',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue4',
					            	fieldName:'inputValue4',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType4']='A') or (values['inputType4']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail5',
					fieldName:'detail5',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail5" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName5',   
					            	fieldName:'inputName5',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName5', 
					            	fieldName:'inputTypeName5',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue5',
					            	fieldName:'inputValue5',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType5']='A') or (values['inputType5']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail6',
					fieldName:'detail6',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail6" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName6',   
					            	fieldName:'inputName6',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName6', 
					            	fieldName:'inputTypeName6',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue6',
					            	fieldName:'inputValue6',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType6']='A') or (values['inputType6']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail7',
					fieldName:'detail7',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail7" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName7',   
					            	fieldName:'inputName7',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName7', 
					            	fieldName:'inputTypeName7',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue7',
					            	fieldName:'inputValue7',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType7']='A') or (values['inputType7']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail8',
					fieldName:'detail8',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail8" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName8',   
					            	fieldName:'inputName8',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName8', 
					            	fieldName:'inputTypeName8',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue8',
					            	fieldName:'inputValue8',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType8']='A') or (values['inputType8']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail9',
					fieldName:'detail9',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail9" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName9',   
					            	fieldName:'inputName9',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName9', 
					            	fieldName:'inputTypeName9',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue9',
					            	fieldName:'inputValue9',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType9']='A') or (values['inputType9']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				},	
				{
					type:'group',
					name:'detail10',
					fieldName:'detail10',
					width:300,
					header:{
				         text:'<lgcom:message code="label.pay.detail10" />',
				         fixedHeight: 60
				    },
					orientation:'horizontal',
					columns: [
					            {	name:'inputName10',   
					            	fieldName:'inputName10',  
					            	width:100, 
					            	header: {text:'<lgcom:message code="label.pay.name" />'}, 
					            	editable: false,
					            	styles: {textAlignment:'center'}
					            },
					            {	name:'inputTypeName10', 
					            	fieldName:'inputTypeName10',
					            	width:100,
					            	header: {text:'<lgcom:message code="label.pay.type" />'},  
					            	editable: false,
					            	styles: {textAlignment:'near'}
					            },
					            {	name:'inputValue10',
					            	fieldName:'inputValue10',
					            	width:100,  
									header: {text:'<lgcom:message code="label.pay.value" />'},
									editable: true,
									dynamicStyles:[{criteria:"(values['inputType10']='A') or (values['inputType10']='N')", styles:{textAlignment:'far'}}]
								}
					         ]
				}
		]);
		//그리드 필수값 체크 
		grid.setValidations([
			{criteria: "value['applyEndDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.applyEndDate'/>"/>',mode:'always',level:'error'},
			{criteria: "value['payrollItemName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.pay.payrollItemName'/>"/>',mode:'always',level:'error'}
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
				header:{
			         height: 50
			    },
			    fixed: { colCount: 5 }
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

LGVPAY00003.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00003();
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
						<col width="120"></col>
						<col width="110"></col>
						<col width="090"></col>
						<col width="200"></col>
						<col width="180"></col>
						<col width="070"></col>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                	<th><i class="asterisk">*</i><lgcom:message code="label.pay.employeeNo" /></label></th>
							<td>
		                		<div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm input-require" name="employeeNo" type="text" data-action="emptyAndPopup">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
							<th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.att.employeeName" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="employeeName" data-action="emptyAndPopup"></td>
							<th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.payMonth" /></label></th>
							<td><input type="text" class="form-control input-sm input-require" name="payrollCalcPeriodValue" data-action="change" maxlength="7" placeholder="<lgcom:message code="placeholder.pay.mmyyyy"/>" /></td>
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
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert" disabled><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete" disabled><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVPAY00003/savePayrollItem" disabled><lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
		<div class="gridContent grid-wrap">
			<div class="grid payRollItemByEmployeeGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
