<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT20040.jsp
    프로젝트명 : LGD BizWeb

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Line Worker Attendance Registration
    작성자 : 이형준S
    HMT_20210319     Add Popup - Alarming working hours
    HMT_20210410     Add month ot total with month ot limit
    HMT_20210717     Swap weekly holiday (Add employeeNo)
    HMT_20220705     Add timeAttendInputReasonDesc column
    HMS_20260601     Add 2A, 2B Working shift
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Line Worker Attendance Registration</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT20040 = function(){
    var grid1;
    var _this = this;
    var myForm = this;
    
    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [ 
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( false );
    
    //날짜 설정
	var $date = myForm.select(".searchBlock input[name='attDate']");
	$date.val(setYesterday(DateUtil.today("DD/MM/YYYY")));
    
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    formUtil.setCalendar( { from : "attDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
    
    var popupAlarm = new Popup(myForm,'lgvhr','M_LGVATT_1062','<lgcom:message code="label.att.workingHourCompliance"/>' ); //HMT_20210319
    popupAlarm.setSize( 800, 300 );
    popupAlarm.open( function(){
    }, function(){
    });
  	
	// grid combo
	var code = new CommonCode('lgcom');
	code.add('dinnerChkFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('dayNightFlag',{codeTypeCode:'LGVHR_DAY_NIGHT_FLAG'});
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.add('gradeTitle', {codeTypeCode:'IF_VIETNAM_GRADE_TITLE'});
	code.add('regularFlag', {codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	
	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.add('attCode', {valueSetId : 'LGVATT_ATTEND_DETAIL'});
	valueSet.add('attTypeName', {valueSetId : 'LGVATT_ATTEND_TYPE_UPDATE_ENABLE'});
	valueSet.add("attendanceDetailCodeList", {valueSetId : "LGVATT_ATTEND_DETAIL_CODE", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueSet.add("attDays", {valueSetId : "LGVATT_ATT_DAYS", subsidiaryCode :"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}"} );
	valueSet.execute(); 
	
	formUtil.initCombo('orgName', valueSet.get('orgName'), { selectAll: true });
	formUtil.initCombo('shiftCode', code.get('shiftCode'), { selectAll: false });
	formUtil.initCombo('regularFlag', code.get('regularFlag'), { selectAll: false });
	
	//출근시간리스트 조회(평일인 경우 8시, 20시만 선택가능하고, 휴일인 경우 모든시간 선택가능하도록 하기 위해 휴일여부Y,N인 출근시간을 모두 조회한다.)
	var workStartTimeList = {};
	myForm.transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/retrieveWorkStartTimeList", {}, function(data) { 
		if ( data.result ) {
			workStartTimeList = data.result;
		}
	});
	
   	grid1 = buildGrid("LGVATT20040_grid1");
   	
   	var controlColumns = {         
    	deductionColumn : [ "deductionLateness", "deductionLeavingEarly", "deductionGoingOut" ]
    };
   	
    grid1.getGridBase().addCellStyles([
   		{
   			id: "unableEdit",
   			background: '#e9e9e9',
   			editable: false
   		},
   		{
   			id: "enableEdit",
   			background: 'none',
   			editable: true
   		},
		{
			id: "illegalAtt",
			foreground: '#F34D78'
		}
   	]);
    
    grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};
	
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	/*** 이벤트 핸들러  ***/
	
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid1.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();
				
				/////////// 근태 입력 마감시간 체크 ///////////
				myForm.showProgress();
				myForm.transaction("lgvhr", "lgvatt/LGVATT20040/isEnableAttendInput", param, function( data ){
					myForm.hideProgress();
					
					if( data.result.inputFlag == 'N' ) {
						Message.alert('<lgcom:message code="note.att.closedInputTime"/>');
						myForm.select('#btnAttSave').prop("disabled", true);
					} else {
						myForm.select('#btnAttSave').prop("disabled", false);
					}
					
				});
				//////////////////////////////////////////////////////////
				
				myForm.showProgress();
				grid1.loadData('lgvhr','lgvatt/LGVATT20040/retrieveLWAttList', param, function(data){
					
					//////// 시스템 자동설정된 근태코드 editable false ///////
					for(var i=0; i<data.result.length; i++) {
						
						if(data.result[i]["attendDays"] == 0) {
							grid1.getGridBase().setCellStyles(i, controlColumns.deductionColumn, "unableEdit");
						}
						
						if(data.result[i]["illegalInTimeFlag"] == 'Y') {
							grid1.getGridBase().setCellStyle(i, "actualInTime", "illegalAtt", true);
							if(data.result[i]["actualAttendanceDetail"] == "NW") {
								grid1.getDataProvider().setValue(i, "actualAttendDetailReason", "NW_LTN");
							}
						}
						
						if(data.result[i]["illegalOutTimeFlag"] == 'Y') {
							grid1.getGridBase().setCellStyle(i, "actualOutTime", "illegalAtt", true);
						}
						
						if(data.result[i]["planUpdateEnable"] == 'N') {
							grid1.getGridBase().setCellStyle(i, "planAttendanceType", "unableEdit", true);
							grid1.getGridBase().setCellStyle(i, "planAttendanceDetail", "unableEdit", true);
							grid1.getGridBase().setCellStyle(i, "planAttendDetailReason", "unableEdit", true);
						}
						
						if(data.result[i]["actualUpdateEnable"] == 'N') {
							grid1.getGridBase().setCellStyle(i, "actualAttendanceType", "unableEdit", true);
							grid1.getGridBase().setCellStyle(i, "actualAttendanceDetail", "unableEdit", true);
							grid1.getGridBase().setCellStyle(i, "actualAttendDetailReason", "unableEdit", true);
						}

						if( data.result[i]["actualShiftCode"] != '1A' ) {
							grid1.getGridBase().setCellStyle(i, "actualDinnerChk", "unableEdit", true);
						}
						/* HMS_20260601 2A,2B working start*/
						if( data.result[i]["actualShiftCode"] == '2A' || data.result[i]["actualShiftCode"] == '2B' ) {
							grid1.getGridBase().setCellStyle(i, "actualOT", "unableEdit", true);
							grid1.getGridBase().setCellStyle(i, "actualOtHours", "unableEdit", true); //HMT_20260831
							grid1.getGridBase().setCellStyle(i, "actualOtMinutes", "unableEdit", true); //HMT_20260831
							grid1.getGridBase().setCellStyle(i, "actualDinnerChk", "unableEdit", true);
						}
						if( data.result[i]["planShiftCode"] == '2A' || data.result[i]["planShiftCode"] == '2B' ) {
							grid1.getGridBase().setCellStyle(i, "planOT", "unableEdit", true);
						}
						/* HMS_20260601 2A,2B working end*/
					}
					//////////////////////////////////////////////////////////
					
					grid1.getGridBase().setColumnProperty("plan", "header", {text: '<lgcom:message code="label.att.plan" /> ( ' + setTomorrow($date.val()) + ' )'});
					grid1.getGridBase().setColumnProperty("actual", "header", {text: '<lgcom:message code="label.att.actual" /> ( ' + $date.val() + ' )'});
					if( grid1.getDataProvider().getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
					} else {
						if(grid1.getDataProvider().getRowCount() > 0){
				    		var index = {itemIndex: 0};
							grid1.getGridBase().setCurrent(index);
				    	}
					}
					myForm.hideProgress();
				} );
				
				break;
			// 유저 검색 팝업
		    case "openPopupApprover" :
                console.log("openPopupApprover");
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "PIC";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");
                _popup.employeeName = formUtil.getValue("employeeName");
                _popup.attDate = formUtil.getValue("attDate");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                    formUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                    formUtil.setValue({orgName   :_popup.userData[0].organizationId});
                    formUtil.setValue({shiftCode   :_popup.userData[0].shiftType});
                });
                _popup.userData = [];
                break;
			// 근태 저장
		    case "save" :
		    	var param =  myForm.select(".searchBlock form").toJSON();
		    	
		    	myForm.showProgress();
				myForm.transaction("lgvhr", "lgvatt/LGVATT20040/isEnableAttendInput", param, function( data ){
					myForm.hideProgress();
					
					if( data.result.inputFlag == 'N' ) {
						Message.alert('<lgcom:message code="note.att.closedInputTime"/>');
						myForm.select('#btnAttSave').prop("disabled", true);
					} else {
						
						myForm.select('#btnAttSave').prop("disabled", false);
						
						try {
							grid1.getGridBase().commit();
						} catch(e) {
							Message.alert(e.message);
							return;
						}
						
						Message.confirm('<lgcom:message code="question.save"/>', function() {
							myForm.showProgress();
							
							var checkedRows = grid1.getGridBase().getCheckedRows(true);
							
							if( checkedRows.length > 0 ) {
								
								var param = {};
								var arr = [];
								
								for(var i=0; i<checkedRows.length; i++) {
									arr.push(grid1.getDataProvider().getJsonRow(checkedRows[i]));
								}
								
								param["modifyList"] = arr;
								//param["actionType"] = 'save';
								
								myForm.transaction("lgvhr", "lgvatt/LGVATT20040/updateLWAttPlanActualList", param, function( data ){
									myForm.hideProgress();
									Message.alert( '<lgcom:message code="note.completed" />' );
									// 저장 완료후 목록 재조회
									myForm.select(".searchBlock button[data-action='search']").trigger('click');
								});
							} else {
								myForm.hideProgress();
								Message.alert('<lgcom:message code="error.noChangedData"/>');
							}
								
						});
						
					}
				});		    	
				
		    	break;
		    	
		    case "planApplyAll" :
		    	grid1.getGridBase().commit();
		    	var checkedRows = grid1.getGridBase().getCheckedRows(true);
		    	if( checkedRows.length == 0 ) {
		    		Message.alert('<lgcom:message code="note.att.nonCheck"/>');
		    		return;
		    	}
		    	
		    	for(var a=0; a<checkedRows.length; a++) {
		    		var i=checkedRows[a];
		    		if( grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planAttendanceDetail') == grid1.getDataProvider().getValue(i, 'planAttendanceDetail')) {
		    			if( grid1.getDataProvider().getValue(i, 'planAttendanceType') != "SA" 
		    					|| grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planAttendanceType') != "SA" ) {
			    			grid1.getDataProvider().setValue(i,'planAttendanceType', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planAttendanceType'));
			    			grid1.getDataProvider().setValue(i,'planAttendanceDetail', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planAttendanceDetail'));
			    			grid1.getDataProvider().setValue(i,'planAttendDetailReason', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planAttendDetailReason'));
		    			}
			    		grid1.getDataProvider().setValue(i,'planOT', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'planOT'));
		    		}
		    	}
		    	break;
		    	
		    case "actualApplyAll" :
		    	grid1.getGridBase().commit();
		    	var checkedRows = grid1.getGridBase().getCheckedRows(true);
		    	if( checkedRows.length == 0 ) {
		    		Message.alert('<lgcom:message code="note.att.nonCheck"/>');
		    		return;
		    	}
		    	
		    	for(var a=0; a<checkedRows.length; a++) {
		    		var i=checkedRows[a];
		    		/* HMS_20260601 2A,2B working start*/
			    	if(grid1.getDataProvider().getValue(i, 'actualShiftCode') == '2A' || grid1.getDataProvider().getValue(i, 'actualShiftCode') == '2B') {
		    			Message.alert('<lgcom:message code="note.att.2A2BCheck"/>');
		    			//grid1.getDataProvider().setValue(i,'actualStartTm', '');
		    			return false;
			    	}
			    	/* HMS_20260601 2A,2B working end*/
		    		if( grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualAttendanceDetail') == grid1.getDataProvider().getValue(i, 'actualAttendanceDetail')) {
		    			if( grid1.getDataProvider().getValue(i, 'actualAttendanceType') != "SA"
		    				&& grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualAttendanceType') != "SA" ) {
		    				grid1.getDataProvider().setValue(i,'actualAttendanceType', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualAttendanceType'));
				    		grid1.getDataProvider().setValue(i,'actualAttendanceDetail', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualAttendanceDetail'));
				    		grid1.getDataProvider().setValue(i,'actualAttendDetailReason', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualAttendDetailReason'));
		    			}
		    			grid1.getDataProvider().setValue(i,'timeAttendInputReasonDesc', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'timeAttendInputReasonDesc'));
			    		grid1.getDataProvider().setValue(i,'actualDinnerChk', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualDinnerChk'));
			    		grid1.getDataProvider().setValue(i,'actualStartTm', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualStartTm'));
			    		grid1.getDataProvider().setValue(i,'deductionLateness', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'deductionLateness'));
			    		grid1.getDataProvider().setValue(i,'deductionLeavingEarly', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'deductionLeavingEarly'));
			    		grid1.getDataProvider().setValue(i,'deductionGoingOut', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'deductionGoingOut'));
			    		grid1.getDataProvider().setValue(i,'actualOtHours', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualOtHours')); //HMT_20260831

			    		//HMT_20260831 Start: nếu actualAttendanceDetail (sau khi áp dụng) không phải WH/PH thì actualOtMinutes chỉ được nhận giá trị 30
			    		var actualAttDetailApplied = grid1.getDataProvider().getValue(i, 'actualAttendanceDetail');
			    		if( actualAttDetailApplied == 'WH' || actualAttDetailApplied == 'PH' ) {
			    			grid1.getDataProvider().setValue(i,'actualOtMinutes', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualOtMinutes')); //HMT_20260831
			    		} else {
			    			var sourceOtMinutes = Number(grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualOtMinutes')) || 0;
					    	if( sourceOtMinutes != 0 && sourceOtMinutes != 30 ) {
					    		Message.alert('<lgcom:message code="note.att.WHPHCheckMinuties"/>');
					    		return;
					    	} else {
					    		grid1.getDataProvider().setValue(i,'actualOtMinutes', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualOtMinutes'));
					    	}
			    		}
			    		//HMT_20260831 End

			    		//HMT_20260831: tính lại actualOT theo actualOtHours/actualOtMinutes thực tế của dòng i thay vì copy nguyên actualOT của dòng nguồn,
			    		//vì actualOtMinutes có thể không được áp dụng như trên
			    		var appliedOtHours = Number(grid1.getDataProvider().getValue(i, 'actualOtHours')) || 0;
			    		var appliedOtMinutes = Number(grid1.getDataProvider().getValue(i, 'actualOtMinutes')) || 0;
			    		grid1.getDataProvider().setValue(i,'actualOT', Math.round((appliedOtHours + appliedOtMinutes / 60) * 10) / 10);
			    		grid1.getDataProvider().setValue(i,'weekday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'weekday'));
			    		grid1.getDataProvider().setValue(i,'weekdayHoliday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'weekdayHoliday'));
			    		grid1.getDataProvider().setValue(i,'publicHoliday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'publicHoliday'));
			    		grid1.getDataProvider().setValue(i,'atNightWeekday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'atNightWeekday'));
			    		grid1.getDataProvider().setValue(i,'atNightWeekdayAfterOT', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'atNightWeekdayAfterOT'));
			    		grid1.getDataProvider().setValue(i,'atNightWeekdayHoliday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'atNightWeekdayHoliday'));
			    		grid1.getDataProvider().setValue(i,'atNightPublicHoliday', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'atNightPublicHoliday'));
			    		grid1.getDataProvider().setValue(i,'nightNormal', grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'nightNormal'));
			    		
			    		if(grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualInTime') != null && 
			    			grid1.getGridBase().getValue(grid1.getGridBase().getCurrent().itemIndex, 'actualOutTime') != null ) {
				    		isillegalAtt(grid1.getGridBase(), grid1.getGridBase().getItemIndex(i), i);
			    		}
		    		}
		    	}
		    	break;
		}
	});
	
	this.addEvent( "change", "input[data-action]" , function(event){
        var action = $(event.target).data("action");
        switch( action ){
            case "emptyAndPopup" :
                $(event.target).prev("input[type=hidden]").val(""); // 코드값 비우기
                if($(event.target).val() != ""){
                    $("body").one("focusout", function(e){
                        $(event.target).next("span").children("button").trigger('click');
                    });
                }
                break;
        }
    });
	
	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
	
    grid1.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
    	
    	cgrid.checkItem(index.itemIndex, true, false);
    	
		if(index.column == 'planAttendanceType') {
			var exists = cgrid.existsLookupData('planAttendanceDetail',[newValue,cgrid.getValue(index.itemIndex,'planAttendanceDetail')]);
			if(!exists) {
				var attendCodeLookup = valueSet.get('attCode');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendTypeName']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}
				cgrid.setValue(index.itemIndex,'planAttendanceDetail',attendCode);
				
				exists = cgrid.existsLookupData('planAttendDetailReason',[cgrid.getValue(index.itemIndex,'planAttendanceDetail'), cgrid.getValue(index.itemIndex,'planAttendDetailReason')]);
				if(!exists) {
					var detailReasonLookup = valueSet.get('attendanceDetailCodeList');
					var detailReasonCode = '';
					for(var i=0; i < detailReasonLookup.length; i++) {
						if($.trim(detailReasonLookup[i]['attendanceCode']) == cgrid.getValue(index.itemIndex,'planAttendanceDetail')) {
							detailReasonCode = $.trim(detailReasonLookup[i]['code']);
							break;
						}
					}
					
					if( cgrid.getValue(index.itemIndex,'planAttendanceDetail') == 'NW') {
						cgrid.setValue(index.itemIndex,'planAttendDetailReason', 'NW_NRM');
					} else {
						cgrid.setValue(index.itemIndex,'planAttendDetailReason',detailReasonCode);
					}
				}
			}
		} else if(index.column == 'actualAttendanceType') {
			var exists = cgrid.existsLookupData('actualAttendanceDetail',[newValue,cgrid.getValue(index.itemIndex,'actualAttendanceDetail')]);
			if(!exists) {
				var attendCodeLookup = valueSet.get('attCode');
				var attDaysLookup = valueSet.get('attDays');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendTypeName']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}
				for(var i=0; i < attDaysLookup.length; i++) {
					if($.trim(attDaysLookup[i]['timeAndAttendanceCode']) == attendCode) {
						cgrid.setValue(index.itemIndex, 'deductionLateness', 0);
						cgrid.setValue(index.itemIndex, 'deductionLeavingEarly', 0);
						cgrid.setValue(index.itemIndex, 'deductionGoingOut', 0);
						if($.trim(attDaysLookup[i]['code']) == 0) {
							cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "unableEdit");
						} else {
							cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
						}
						break;
					}
				}
				
				cgrid.setValue(index.itemIndex,'actualAttendanceDetail',attendCode);
				
				exists = cgrid.existsLookupData('actualAttendDetailReason',[cgrid.getValue(index.itemIndex,'actualAttendanceDetail'), cgrid.getValue(index.itemIndex,'actualAttendDetailReason')]);
				if(!exists) {
					var detailReasonLookup = valueSet.get('attendanceDetailCodeList');
					var detailReasonCode = '';
					for(var i=0; i < detailReasonLookup.length; i++) {
						if($.trim(detailReasonLookup[i]['attendanceCode']) == cgrid.getValue(index.itemIndex,'actualAttendanceDetail')) {
							detailReasonCode = $.trim(detailReasonLookup[i]['code']);
							break;
						}
					}
					
					if( cgrid.getValue(index.itemIndex,'actualAttendanceDetail') == 'NW') {
						cgrid.setValue(index.itemIndex,'actualAttendDetailReason', 'NW_NRM');
					} else {
						cgrid.setValue(index.itemIndex,'actualAttendDetailReason',detailReasonCode);
					}
				}
				
				cgrid.setValue(index.itemIndex, "actualOT", 0);
			}
		} else if(index.column == 'planAttendanceDetail') {
			var exists = cgrid.existsLookupData('planAttendDetailReason',[newValue,cgrid.getValue(index.itemIndex,'planAttendDetailReason')]);
			if(!exists) {
				var attendCodeLookup = valueSet.get('attendanceDetailCodeList');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendanceCode']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}
				
				if( newValue == 'NW') {
					cgrid.setValue(index.itemIndex,'planAttendDetailReason', 'NW_NRM');
				} else {
					cgrid.setValue(index.itemIndex,'planAttendDetailReason',attendCode);
				}
			}
		} else if(index.column == 'actualAttendanceDetail') {
			var attDaysLookup = valueSet.get('attDays');
			for(var i=0; i < attDaysLookup.length; i++) {
				if($.trim(attDaysLookup[i]['timeAndAttendanceCode']) == newValue) {
					cgrid.setValue(index.itemIndex, 'deductionLateness', 0);
					cgrid.setValue(index.itemIndex, 'deductionLeavingEarly', 0);
					cgrid.setValue(index.itemIndex, 'deductionGoingOut', 0);
					if($.trim(attDaysLookup[i]['code']) == 0) {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "unableEdit");
					} else {
						cgrid.setCellStyles(index.dataRow, controlColumns.deductionColumn, "enableEdit");
					}
					break;
				}
			}
			var exists = cgrid.existsLookupData('actualAttendDetailReason',[newValue,cgrid.getValue(index.itemIndex,'actualAttendDetailReason')]);
			if(!exists) {
				var attendCodeLookup = valueSet.get('attendanceDetailCodeList');
				var attendCode = '';
				for(var i=0; i < attendCodeLookup.length; i++) {
					if($.trim(attendCodeLookup[i]['attendanceCode']) == newValue) {
						attendCode = $.trim(attendCodeLookup[i]['code']);
						break;
					}
				}

				if( newValue == 'NW') {
					cgrid.setValue(index.itemIndex,'actualAttendDetailReason', 'NW_NRM');
				} else {
					cgrid.setValue(index.itemIndex,'actualAttendDetailReason',attendCode);
				}

				cgrid.setValue(index.itemIndex, "actualOT", 0);
			}
		}
	};
	
	grid1.getGridBase().onCellEdited = function (cgrid, itemIndex, dataRow, field) {
		cgrid.commit();
		var dsResult = cgrid.getDataProvider();
	    var fieldName = dsResult.getOrgFieldName(field);

		////////////문자 및 범위 밖 숫자 입력시 벨리데이션 ////////////////
	    if( fieldName == "actualOT" || fieldName == "planOT"  || fieldName == "deductionLateness" || 
	    		fieldName == "deductionLeavingEarly" || fieldName == "deductionGoingOut" ) {
	    	
	    	if( fieldName == "actualOT" ) {
	    		if( dsResult.getValue(dataRow, fieldName) % 0.5 != 0 ) {
	    			Message.alert('<lgcom:message code="note.att.otInputFault"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	}
	    	
	    	if( fieldName == "planOT" ) {
	    		if( dsResult.getValue(dataRow, fieldName) % 0.5 != 0 ) {
	    			Message.alert('<lgcom:message code="note.att.otInputFault"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	}
	    	
	    	if( fieldName == "deductionLateness") {
	    		if( dsResult.getValue(dataRow, fieldName) % 0.5 != 0 ) {
	    			Message.alert('<lgcom:message code="note.att.latenessInputFault"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	}
	    	
	    	if( fieldName == "deductionLeavingEarly") {
	    		if( dsResult.getValue(dataRow, fieldName) % 0.5 != 0 ) {
	    			Message.alert('<lgcom:message code="note.att.leavingEarlyInputFault"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	}
	    	
	    	if( fieldName == "deductionGoingOut") {
	    		if( dsResult.getValue(dataRow, fieldName) % 0.5 != 0 ) {
	    			Message.alert('<lgcom:message code="note.att.goingOutInputFault"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	}
	    	
	    	if(dsResult.getValue(dataRow, fieldName) < 0 || isNaN(dsResult.getValue(dataRow, fieldName))) {
	    		dsResult.setValue(dataRow, fieldName, 0);
	    	} 
	    	
	    	if( dsResult.getValue(dataRow, fieldName) > 24) {
	    		dsResult.setValue(dataRow, fieldName, 24);
	    	}
	    }
	    /////////////////////////////////////////////////////////////////////

	    ////////////actualOtHours, actualOtMinutes 입력값 검증 (HMT_20260831)////////////
	    if( fieldName == "actualOtMinutes" ) {
	    	var attType = dsResult.getValue(dataRow, "actualAttendanceDetail");
	    	var otMinutesVal = dsResult.getValue(dataRow, fieldName);

	    	if( attType != 'WH' && attType != 'PH' ) {
	    		if( Number(otMinutesVal) != 0 && Number(otMinutesVal) != 30 ) {
	    			Message.alert('<lgcom:message code="note.att.WHPHCheckMinuties"/>');
	    			dsResult.setValue(dataRow, fieldName, 0);
	    		}
	    	} else if( Number(otMinutesVal) != 0 && ( isNaN(otMinutesVal) || otMinutesVal % 1 != 0 || otMinutesVal < 1 || otMinutesVal > 59 ) ) {
	    		Message.alert('<lgcom:message code="note.att.CheckOTMinuties"/>');
	    		dsResult.setValue(dataRow, fieldName, 0);
	    	}
	    }

	    if( fieldName == "actualOtHours" ) {
	    	var otHoursVal = dsResult.getValue(dataRow, fieldName);

	    	if( Number(otHoursVal) != 0 && ( isNaN(otHoursVal) || otHoursVal % 1 != 0 || otHoursVal < 1 || otHoursVal > 23 ) ) {
	    		Message.alert('<lgcom:message code="note.att.CheckOTHours"/>');
	    		dsResult.setValue(dataRow, fieldName, 0);
	    	}
	    }
	    /////////////////////////////////////////////////////////////////////////////
	    cgrid.commit();

	    if( fieldName == "actualAttendanceType" || fieldName == "actualAttendanceDetail" || fieldName == "actualAttendDetailReason" || fieldName == "actualDinnerChk" ||
	    		fieldName == "actualOT" || fieldName == "actualOtHours" || fieldName == "actualOtMinutes" || fieldName == "deductionLateness" || fieldName == "deductionLeavingEarly" || fieldName == "deductionGoingOut" ||
	    		fieldName == "actualStartTm" ) {

	    	var otHours = Number(dsResult.getValue(dataRow,"actualOtHours")) || 0; //HMT_20260831
	    	var otMinutes = Number(dsResult.getValue(dataRow,"actualOtMinutes")) || 0; //HMT_20260831
	    	var otActual = Math.round((otHours + otMinutes / 60) * 10) / 10; //HMT_20260831
	    	dsResult.setValue(dataRow, "actualOT", otActual);

	    	dsResult.setValue(dataRow, "isEditOt", "Y");
	    	fncCalculateOT(dsResult, dataRow);
	    	fncCompareOtTotal(dsResult, dataRow);//HMT_20210410
	    }
	    
	    if(fieldName == "actualStartTm") {
	    	isillegalAtt(cgrid, itemIndex, dataRow);
	    }
	};
	
	grid1.getGridBase().onShowHeaderTooltip = function ( grid, column, value ) {
		if(column.fieldName == "weekday") {
			return '<lgcom:message code="label.att.actualOTWeekDay" />';
		} else if(column.fieldName == "weekdayHoliday") {
			return '<lgcom:message code="label.att.actualOTWeekDayHoliday" />';
		} else if(column.fieldName == "publicHoliday") {
			return '<lgcom:message code="label.att.actualOTPublicHoliday" />';
		} else if(column.fieldName == "atNightWeekday") {
			return '<lgcom:message code="label.att.actualOTNightWeekDay" />';
		} else if(column.fieldName == "atNightWeekdayAfterOT") {
			return '<lgcom:message code="label.att.actualOTNightWeekDayAfterOT" />';
		} else if(column.fieldName == "atNightWeekdayHoliday") {
			return '<lgcom:message code="label.att.actualOTNightWeekDayHoliday" />';
		} else if(column.fieldName == "atNightPublicHoliday") {
			return '<lgcom:message code="label.att.actualOTNightPublicHoliday" />';
		} else if(column.fieldName == "nightNormal") {
			return '<lgcom:message code="label.att.nightNormal" />';
		} else {
			return null;
		}
	};

	
	/*** 내부 함수  ***/
	
	//내일 날짜 구하기
	function setTomorrow(date){
		var selectDate = date.split("/");
		var changeDate = new Date();
		
		changeDate.setFullYear(selectDate[2], selectDate[1]-1, selectDate[0]-1+2);
		
		var y = changeDate.getFullYear();
		var m = changeDate.getMonth() + 1;
		var d = changeDate.getDate();
		if(m < 10)    { m = "0" + m; }
		if(d < 10)    { d = "0" + d; }
		
		var resultDate = d + '/' + m + '/' + y;
		return resultDate;
	}
	
	//어제 날짜 구하기
	function setYesterday(date){
		var selectDate = date.split("/");
		var changeDate = new Date();
		
		changeDate.setFullYear(selectDate[2], selectDate[1]-1, selectDate[0]-1);
		
		var y = changeDate.getFullYear();
		var m = changeDate.getMonth() + 1;
		var d = changeDate.getDate();
		if(m < 10)    { m = "0" + m; }
		if(d < 10)    { d = "0" + d; }
		
		var resultDate = d + '/' + m + '/' + y;
		return resultDate;
	}
	
	// intime, outtime 적색표시
	function isillegalAtt(cgrid, rowIndex, dataRow) {
		var param = {shiftCode     		:cgrid.getValue(rowIndex,"actualShiftCode"),
			         workStartTm   		:cgrid.getValue(rowIndex,"actualStartTm"),
			         attendDate			:cgrid.getValue(rowIndex,"actualDate"),
			         checkIn       		:cgrid.getValue(rowIndex,"actualInTime"),
			         checkOut      		:cgrid.getValue(rowIndex,"actualOutTime")
			        };
		//OT자동 계산
		transaction("lgvhr", "lgvatt/LGVATT20040/isillegalAtt", param, function(data) {
			if ( data.result ) {
				
				if(data.result.illegalInTimeFlag == 'Y') {
					cgrid.setCellStyle(dataRow, "actualInTime", "illegalAtt", true);
					if( cgrid.getValue(rowIndex,"actualAttendanceDetail") == "NW" ) {
						cgrid.setValue(rowIndex,"actualAttendDetailReason", "NW_LTN");
					}
				} else {
					cgrid.setCellStyle(dataRow, "actualInTime", { foreground: 'none' }, true);
					if( cgrid.getValue(rowIndex,"actualAttendanceDetail") == "NW" ) {
						cgrid.setValue(rowIndex,"actualAttendDetailReason", "NW_NRM");
					}
				}
				
				if(data.result.illegalOutTimeFlag == 'Y') {
					cgrid.setCellStyle(dataRow, "actualOutTime", "illegalAtt", true);
				} else {
					cgrid.setCellStyle(dataRow, "actualOutTime", { foreground: 'none' }, true);
				}
			}
		});
	}
	
	//OT재계산
	function fncCalculateOT(cgrid, rowIndex) {
		var param = {subsidiaryCode    			:"${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}",
			         employeeNo     			:cgrid.getValue(rowIndex,"employeeNo"), //HMT_20210717
			         attendanceYyyymmdd			:cgrid.getValue(rowIndex,"actualDate"),
			         attendanceCode    			:cgrid.getValue(rowIndex,"actualAttendanceDetail"),
			         shiftTypeCode     			:cgrid.getValue(rowIndex,"actualShiftCode"),
			         dayNightFlag      			:cgrid.getValue(rowIndex,"actualDayNight"),
			         dinnerFlag        			:cgrid.getValue(rowIndex,"actualDinnerChk"),
			         workingStartTime  			:cgrid.getValue(rowIndex,"actualStartTm"),
			         lateness          			:cgrid.getValue(rowIndex,"deductionLateness").toString(),
			         leavingEarly      			:cgrid.getValue(rowIndex,"deductionLeavingEarly").toString(),
			         goingOut          			:cgrid.getValue(rowIndex,"deductionGoingOut").toString(),
			         overtimeSumHours  			:cgrid.getValue(rowIndex,"actualOT").toString()
			        };
		//OT자동 계산
		transaction_sync("lgvhr", "lgvatt/LGVATTCOMM/processCalculateOT", param, function(data) {
			
			//OT자동 계산값 셋팅
			cgrid.setValue(rowIndex, "weekday", data.result.ot150);
			cgrid.setValue(rowIndex, "weekdayHoliday", data.result.ot200);
			cgrid.setValue(rowIndex, "publicHoliday", data.result.ot300);
			cgrid.setValue(rowIndex, "atNightWeekday", data.result.nt200);
			cgrid.setValue(rowIndex, "atNightWeekdayAfterOT", data.result.nt210);
			cgrid.setValue(rowIndex, "atNightWeekdayHoliday", data.result.nt270);
			cgrid.setValue(rowIndex, "atNightPublicHoliday", data.result.nt390);
			cgrid.setValue(rowIndex, "nightNormal", data.result.nt30);
		});
	}
	//Compare month ot total with month ot limit HMT_20210410 Start
	function fncCompareOtTotal(cgrid, rowIndex) {
    	var monthOtTotal     = cgrid.getValue(rowIndex, "monthTotalOvertime");
    	var monthOtLimit     = cgrid.getValue(rowIndex, "overtimeLimit"); 
    	var overtimeSumHours = cgrid.getValue(rowIndex, "weekday") + cgrid.getValue(rowIndex, "weekdayHoliday") + cgrid.getValue(rowIndex, "publicHoliday") + 
                               cgrid.getValue(rowIndex, "atNightWeekday") + cgrid.getValue(rowIndex, "atNightWeekdayAfterOT") + cgrid.getValue(rowIndex, "atNightWeekdayHoliday") + 
                               cgrid.getValue(rowIndex, "atNightPublicHoliday");
    	
		if ( overtimeSumHours + monthOtTotal > monthOtLimit ) {
			cgrid.setValue(rowIndex, "actualOT", 0);
			cgrid.setValue(rowIndex, "weekday", 0);
			cgrid.setValue(rowIndex, "weekdayHoliday", 0);
			cgrid.setValue(rowIndex, "publicHoliday", 0);
			cgrid.setValue(rowIndex, "atNightWeekday", 0);
			cgrid.setValue(rowIndex, "atNightWeekdayAfterOT", 0);
			cgrid.setValue(rowIndex, "atNightWeekdayHoliday", 0);
			cgrid.setValue(rowIndex, "atNightPublicHoliday", 0);
			cgrid.setValue(rowIndex, "nightNormal", 0);
			Message.alert("<lgcom:message code="note.att.OtExceedLevel"/>" + "! " + monthOtTotal + " + "+overtimeSumHours+" > " + monthOtLimit);
			myForm.hideProgress();
			return ;
		}
	}
	//HMT_20210410 End
	
    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT20040_grid1':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true, {rowSize:3000});
				var editFalseColor = '#e9e9e9';
				
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:true},
						stateBar: {visible:false},
						footer: {visible:false},
						paste: { enabled: false},
						sortMode: "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: true,
							deletable: true
						},
						header:{
					         height: 85,
					         heightFill: 'fixed',
					         showTooltip: true
					    },
					    fixed: { colCount: 1 }
					},
					dataProvider: {
						insertable: true,
						updatable: true,
						deletable: true,
						softDeleting: true,
						deleteCreated: true
					}
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'employee'     					, dataType:'text'  },
							{ fieldName:'employeeNo'	        		, dataType:'text'  },
							{ fieldName:'employeeName' 	        		, dataType:'text'  },
							{ fieldName:'employeeGrade' 	        	, dataType:'text'  },
							
							{ fieldName:'plan'     						, dataType:'text'  },
							{ fieldName:'planAttendance'        		, dataType:'text'  },
							{ fieldName:'planAttendanceType'    		, dataType:'text'  },
							{ fieldName:'planAttendanceDetail' 			, dataType:'text'  },
							{ fieldName:'planAttendDetailReason' 		, dataType:'text'  },
							{ fieldName:'planShiftCode'         		, dataType:'text'  },
							{ fieldName:'planDayNight'         			, dataType:'text'  },
							{ fieldName:'planOT'         				, dataType:'number'},
							{ fieldName:'planDate'         				, dataType:'text'  },
							
							{ fieldName:'actual'     					, dataType:'text'  },
							{ fieldName:'actualDate'         			, dataType:'text'  },
							{ fieldName:'actualAttendance'      		, dataType:'text'  },
							{ fieldName:'actualAttendanceType' 			, dataType:'text'  },
							{ fieldName:'actualAttendanceDetail'		, dataType:'text'  },
							{ fieldName:'actualAttendDetailReason'		, dataType:'text'  },
							{ fieldName:'actualShiftCode'         		, dataType:'text'  },
							{ fieldName:'actualDayNight'         		, dataType:'text'  },
							{ fieldName:'actualDinnerChk'         		, dataType:'text'  },
							{ fieldName:'actualStartTm'         		, dataType:'text'  },
							{ fieldName:'actualInTime'         			, dataType:'text'  },
							{ fieldName:'actualOutTime'         		, dataType:'text'  },
							{ fieldName:'actualOtHours'	        		, dataType:'number'  }, //HMT_20260831
							{ fieldName:'actualOtMinutes'    			, dataType:'number'  }, //HMT_20260831
							{ fieldName:'actualOT'	        			, dataType:'number'},
							{ fieldName:'timeAttendInputReasonDesc'     , dataType:'text'  },//HMT_20220705
							{ fieldName:'monthTotalOvertime'            , dataType:'number'},//HMT_20210410
							{ fieldName:'overtimeLimit'                 , dataType:'number'},//HMT_20210410
							{ fieldName:'weekday' 	    				, dataType:'number'},
							{ fieldName:'weekdayHoliday'				, dataType:'number'},
							{ fieldName:'publicHoliday'    				, dataType:'number'},
							{ fieldName:'atNight'     					, dataType:'text'  },
							{ fieldName:'atNightWeekday'	       		, dataType:'number'},
							{ fieldName:'atNightWeekdayAfterOT' 		, dataType:'number'},
							{ fieldName:'atNightWeekdayHoliday'   		, dataType:'number'},
							{ fieldName:'atNightPublicHoliday'    		, dataType:'number'},
							{ fieldName:'night'     					, dataType:'text'  },
							{ fieldName:'nightNormal'	        		, dataType:'number'},
							{ fieldName:'deduction' 	    			, dataType:'text'  },
							{ fieldName:'deductionLateness'        		, dataType:'number'},
							{ fieldName:'deductionLeavingEarly'    		, dataType:'number'},
							{ fieldName:'deductionGoingOut'     		, dataType:'number'},
							{ fieldName:'specialBonus'	        		, dataType:'number'},
							{ fieldName:'helpCall'        				, dataType:'number'},
							
							{ fieldName:'planUpdateEnable'	        	, dataType:'text'  },
							{ fieldName:'actualUpdateEnable'        	, dataType:'text'  },
							{ fieldName:'planHolidayFlag'	        	, dataType:'text'  },
							{ fieldName:'actualHolidayFlag'        		, dataType:'text'  },
							{ fieldName:'originalAttCode'        		, dataType:'text'  },
							{ fieldName:'illegalInTimeFlag'        		, dataType:'text'  },
							{ fieldName:'illegalOutTimeFlag'        	, dataType:'text'  },
							{ fieldName:'isEditOt'        				, dataType:'text'  }
						]
				);

				grid.setLookupsMultiLvl({
					 			'employeeGrade':code.get("gradeTitle"), 
					 			'planShiftCode':code.get("shiftCode"),
					 			'actualShiftCode':code.get("shiftCode"),
					 			'planDayNight':code.get("dayNightFlag"),
					 			'actualDayNight':code.get("dayNightFlag"),
					 			'actualDinnerChk':code.get("dinnerChkFlag"),
					 			'planAttendanceType':{data:valueSet.get('attTypeName'), keyField:['updateEnable', 'code']},
					 			'actualAttendanceType':{data:valueSet.get('attTypeName'), keyField:['updateEnable', 'code']},
					 			'planAttendanceDetail': {data:valueSet.get('attCode'), keyField:['updateEnable', 'attendTypeName', 'code']},
								'actualAttendanceDetail': {data:valueSet.get('attCode'), keyField:['updateEnable', 'attendTypeName', 'code']},
								'planAttendDetailReason':{data:valueSet.get("attendanceDetailCodeList"), keyField:["attendanceCode", "code"]},
								'actualAttendDetailReason':{data:valueSet.get("attendanceDetailCodeList"), keyField:["attendanceCode", "code"]},
								'actualStartTm':{data:workStartTimeList, keyField:["holidayFlag", "code"]}
					 		}); 
				
				//컬럼 설정
				grid.setColumns(
						[
							{
								type:'group',
								name:'employee',
								fieldName:'employee',
								width:230,
								header:{
							         text:'<lgcom:message code="label.att.employee" />',
							         fixedHeight: 40
							    },
								orientation:'horizontal',
								columns: [
								            {	name:'employeeNo',    
								            	fieldName:'employeeNo',    
								            	width:70,  
								            	header: {text:'<lgcom:message code="label.att.id" />'},	 
								            	editable: false, 
								            	styles: {textAlignment:'near', background: editFalseColor }
								            },
								            {	name:'employeeName',  
								            	fieldName:'employeeName',  
								            	width:100, 
								            	header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
								            	editable: false, 
								            	styles: {textAlignment:'near', background: editFalseColor }
								            },
								            {	name:'employeeGrade', 
								            	fieldName:'employeeGrade', 
								            	width:60,  
								            	lookupDisplay: true,
												lookupSourceId: 'employeeGrade',
												lookupKeyFields: ['employeeGrade'], 
												header: {text:'<lgcom:message code="label.att.jobTitle" />'},
												editable: false,
												styles: {textAlignment:'near', background: editFalseColor }
											}
								         ]
							},
							{
								type:'group',
								name:'actual',
								fieldName:'actual',
								width:1075,
								header:{
							         text:'<lgcom:message code="label.att.actual" />',
							         styles: {background: '#c8c8c8'},
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [

											{	name:'actualShiftCode',
												fieldName:'actualShiftCode',
												width:40,
												header: {text:'<lgcom:message code="label.att.actualShiftCode" />', styles: {background: '#c8c8c8'}}, 
												lookupDisplay: true,
												lookupSourceId: 'actualShiftCode',
												lookupKeyFields: ['actualShiftCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: false,
												styles: {textAlignment:'near', background: editFalseColor }
											},
											{	name:'actualDayNight',
												fieldName:'actualDayNight', 
												width:35,  
												header: {text:'<lgcom:message code="label.att.actualDayNight" />', styles: {background: '#c8c8c8'}}, 
												lookupDisplay: true,
												lookupSourceId: 'actualDayNight',
												lookupKeyFields: ['actualDayNight'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: false,
												styles: {textAlignment:'near', background: editFalseColor }
											},
											{	name:'actualInTime', 
												fieldName:'actualInTime', 
												width:40,  
												header: {text:'<lgcom:message code="label.att.inTime" />', styles: {background: '#c8c8c8'}},
												editable: false, 
												styles: {textAlignment:'near', background: editFalseColor }
											},
											{	name:'actualOutTime',
												fieldName:'actualOutTime',
												width:40, 
												header: {text:'<lgcom:message code="label.att.outTime" />', styles: {background: '#c8c8c8'}},
												editable: false, 
												styles: {textAlignment:'near', background: editFalseColor }
											},
								            {
												type:'group',
												name:'actualAttendance',
												fieldName:'actualAttendance',
												width:220,
												header:{
											         text:'<lgcom:message code="label.att.actualAttendance" />',
 											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'actualAttendanceType',
												            	fieldName:'actualAttendanceType',
												            	width:60,
												            	header: {text:'<lgcom:message code="label.att.actualAttendanceType" />', styles: {background: '#c8c8c8'}},
												            	lookupDisplay: true,
																lookupSourceId: 'actualAttendanceType',
																lookupKeyFields: ['actualUpdateEnable', 'actualAttendanceType'],
																editor: {type:'dropDown',textReadOnly:true}, 
																editable: true, 
																styles: {textAlignment:'near' }
															},
												            {	name:'actualAttendanceDetail',      
																fieldName:'actualAttendanceDetail',       
																width:80,  
																header: {text:'<lgcom:message code="label.att.actualAttendanceDetail" />', styles: {background: '#c8c8c8'}},
																lookupDisplay: true,
																lookupSourceId: 'actualAttendanceDetail',
																lookupKeyFields: ['actualUpdateEnable', 'actualAttendanceType', 'actualAttendanceDetail'],
																editor: {type:'dropDown',textReadOnly:true}, 
																editable: true, 
																styles: {textAlignment:'near' }
															},
															{	name:'actualAttendDetailReason',      
																fieldName:'actualAttendDetailReason',       
																width:80,  
																header: {text:'<lgcom:message code="label.att.timeAttendDetailCode" />', styles: {background: '#c8c8c8'}}, 
																lookupDisplay: true,
																lookupSourceId: 'actualAttendDetailReason',
																lookupKeyFields: ['actualAttendanceDetail', 'actualAttendDetailReason'],
																editor: {type:'dropDown',textReadOnly:true},
																editable: true,
																styles: {textAlignment:'near' }
															}
												         ]
											},
											{	name:'actualStartTm', 
												fieldName:'actualStartTm', 
												width:55, 
												header: {text:'<lgcom:message code="label.att.actualStartTm" />', styles: {background: '#c8c8c8'}},
												lookupDisplay: true,
												lookupSourceId: 'actualStartTm',
												lookupKeyFields: ['actualHolidayFlag', 'actualStartTm'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: true, 
												styles: {textAlignment:'center' }
											},
											{
												type:'group',
												name:'deduction',
												fieldName:'deduction',
												width:150,
												header:{
											         text:'<lgcom:message code="label.att.deduction" />',
											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'deductionLateness',   
												            	fieldName:'deductionLateness',  
												            	width:50,
												            	header: {text:'<lgcom:message code="label.att.deductionLateness" />', fixedHeight: 45, styles: {background: '#c8c8c8'}}, 	
												            	editable: true, 
												            	styles: {textAlignment:'far', numberFormat: '#0.0' }
												            },
												            {	name:'deductionLeavingEarly',
												            	fieldName:'deductionLeavingEarly',
												            	width:50,  
												            	header: {text:'<lgcom:message code="label.att.deductionLeavingEarly" />', fixedHeight: 45, styles: {background: '#c8c8c8'}}, editable: true,
												            	editable: true, 
												            	styles: {textAlignment:'far', numberFormat: '#0.0' }
												            },
												            {	name:'deductionGoingOut', 	
												            	fieldName:'deductionGoingOut',  	
												            	width:50,  
												            	header: {text:'<lgcom:message code="label.att.deductionGoingOut" />', fixedHeight: 45, styles: {background: '#c8c8c8'}}, 
												            	editable: true,
												            	styles: {textAlignment:'far', numberFormat: '#0.0' }
												            }
												         ]
											},
											//HMT_20260831 Start
											{
												type:'group',
												name:'deduction',
												fieldName:'deduction',
												width:150,
												header:{
											         text:'<lgcom:message code="label.att.totalOT" />',
											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'actualOtHours',
												            	fieldName:'actualOtHours',
												            	width:50,
												            	header: {text:'<lgcom:message code="label.pay.hour" />', fixedHeight: 45, styles: {background: '#c8c8c8'}},
												            	editable: true, styles: {textAlignment:'far', numberFormat: '#0.0' }
												            },
												            {	name:'actualOtMinutes',
												            	fieldName:'actualOtMinutes',
												            	width:50,
												            	header: {text:'<lgcom:message code="label.pay.minutes" />', fixedHeight: 45, styles: {background: '#c8c8c8'}}, editable: true,
												            	styles: {textAlignment:'far', numberFormat: '#0.0' }
												            },
												            {	name:'actualOT',
																fieldName:'actualOT',
																width:40,
																header: {text:'<lgcom:message code="label.att.totalOT" />', styles: {background: '#c8c8c8'},showTooltip: true},
																styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0'},
																editable: false
															},
												         ]
											},
											//HMT_20260831 End
											//HMT_20220705 Start
											{	name:'timeAttendInputReasonDesc',
												fieldName:'timeAttendInputReasonDesc',
												width:120,
												header: {text:'<lgcom:message code="label.att.timeAttendInputReasonDesc"/>', styles: {background: '#c8c8c8'}},
												editable: true,
												styles: {textAlignment:'near'},
												editable: true
											},
											//HMT_20220705 End
											{	name:'actualDinnerChk',
												fieldName:'actualDinnerChk',
												width:40, 
												header: {text:'<lgcom:message code="label.att.actualDinnerChk" />', styles: {background: '#c8c8c8'}}, 
												lookupDisplay: true,
												lookupSourceId: 'actualDinnerChk',
												lookupKeyFields: ['actualDinnerChk'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: true,
												styles: {textAlignment:'near' }
											},
											//HMT_20210410 Start
											{	name:'monthTotalOvertime',
												fieldName:'monthTotalOvertime',
												width:40,
												header: {text:'<lgcom:message code="label.att.monthTotalOT"/>', styles: {background: '#c8c8c8'}, showTooltip: true},
												styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0'},
												editable: false
											},
											{	name:'overtimeLimit',
												fieldName:'overtimeLimit',
												width:40,
												header: {text:'<lgcom:message code="label.att.monthOtLimit"/>', styles: {background: '#c8c8c8'}, showTooltip: true},
												styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0'},
												editable: false
											},
											//HMT_20210410 End
											{
												type:'group',
												name:'night',
												fieldName:'night',
												width:40,
												header:{
											         text:'<lgcom:message code="label.att.night" />',
											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'nightNormal', 
												            	fieldName:'nightNormal', 
												            	width:40,
												            	header: {text:'<lgcom:message code="label.att.nightNormal2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true },
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            }
												         ]
											},
											{
												type:'group',
												name:'actualOT',
												fieldName:'actualOT',
												width:120,
												header:{
											         text:'<lgcom:message code="label.att.actualOT" />',
											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'weekday',        
												            	fieldName:'weekday',        
												            	width:40, header: {text:'<lgcom:message code="label.att.actualOTWeekDay2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false,
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            },
												            {	name:'weekdayHoliday', 
												            	fieldName:'weekdayHoliday',  
												            	width:40, 
												            	header: {text:'<lgcom:message code="label.att.actualOTWeekDayHoliday2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            },
												            {	name:'publicHoliday',  
												            	fieldName:'publicHoliday', 
												            	width:40, 
												            	header: {text:'<lgcom:message code="label.att.actualOTPublicHoliday2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            }
												         ]
											},
											{
												type:'group',
												name:'atNight',
												fieldName:'atNight',
												width:160,
												header:{
											         text:'<lgcom:message code="label.att.actualOTNight" />',
											         styles: {background: '#c8c8c8'},
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'atNightWeekday',     
												            	fieldName:'atNightWeekday',   
												            	width:40, 
												            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDay2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false,
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            },
												            {	name:'atNightWeekdayAfterOT', 
												            	fieldName:'atNightWeekdayAfterOT',  
												            	width:40, 
												            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayAfterOT2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            },
												            {	name:'atNightWeekdayHoliday', 
												            	fieldName:'atNightWeekdayHoliday', 
												            	width:40,  
												            	header: {text:'<lgcom:message code="label.att.actualOTNightWeekDayHoliday2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true}, 
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            },
												            {	name:'atNightPublicHoliday',  
												            	fieldName:'atNightPublicHoliday',  
												            	width:40, 
												            	header: {text:'<lgcom:message code="label.att.actualOTNightPublicHoliday2" />', fixedHeight: 45, styles: {background: '#c8c8c8'}, showTooltip: true},
												            	editable: false, 
												            	styles: {textAlignment:'far', background: editFalseColor, numberFormat: '#0.0' }
												            }
												         ]
											},
											{ name:'specialBonus',  fieldName:'specialBonus',   width:60,  header: {text:'<lgcom:message code="label.att.specialBonus" />'}, visible: false, editable: true, styles: {textAlignment:'far' }},
											{ name:'helpCall',  	fieldName:'helpCall',   	width:60,  header: {text:'<lgcom:message code="label.att.helpCall" />'}, visible: false, editable: true, styles: {textAlignment:'far' }},
											{ name:'actualUpdateEnable',  	fieldName:'actualUpdateEnable',   	width:60,  header: {text:'actualUpdateEnable'}, visible: false, editable: false, styles: {textAlignment:'near' }},
											{ name:'actualHolidayFlag',  	fieldName:'actualHolidayFlag',   	width:60,  header: {text:'actualHolidayFlag'}, visible: false, editable: false, styles: {textAlignment:'near' }},
											{ name:'originalAttCode',  	fieldName:'originalAttCode',   	width:60,  header: {text:'originalAttCode'}, visible: false, editable: false, styles: {textAlignment:'near' }}
										]
							},
							{
								type:'group',
								name:'plan',
								fieldName:'plan',
								width:340,
								header:{
							         text:'<lgcom:message code="label.att.plan" />',
							         fixedHeight: 20
							    },
								orientation:'horizontal',
								columns: [
											{	name:'planShiftCode',
												fieldName:'planShiftCode',
												width:40,
												header: {text:'<lgcom:message code="label.att.planShiftCode" />'}, 
												lookupDisplay: true,
												lookupSourceId: 'planShiftCode',
												lookupKeyFields: ['planShiftCode'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: false,
												styles: {textAlignment:'near', background: editFalseColor }
											},
											{	name:'planDayNight',
												fieldName:'planDayNight',
												width:40,
												header: {text:'<lgcom:message code="label.att.planDayNight" />'}, 
												lookupDisplay: true,
												lookupSourceId: 'planDayNight',
												lookupKeyFields: ['planDayNight'],
												editor: {type:'dropDown',textReadOnly:true},
												editable: false,
												styles: {textAlignment:'near', background: editFalseColor }
											},
								            {
												type:'group',
												name:'planAttendance',
												fieldName:'planAttendance',
												width:220,
												header:{
											         text:'<lgcom:message code="label.att.planAttendance" />',
											         fixedHeight: 20
											    },
												orientation:'horizontal',
												columns: [
												            {	name:'planAttendanceType',
												            	fieldName:'planAttendanceType',
												            	width:60,
												            	header: {text:'<lgcom:message code="label.att.attendCategory" />'}, 
												            	lookupDisplay: true,
																lookupSourceId: 'planAttendanceType',
																lookupKeyFields: ['planUpdateEnable', 'planAttendanceType'],
																editor: {type:'dropDown',textReadOnly:true},
																editable: true,
																styles: {textAlignment:'near' }
															},
												            {	name:'planAttendanceDetail',
																fieldName:'planAttendanceDetail',
																width:80,
																header: {text:'<lgcom:message code="label.att.planAttendanceType" />'}, 
																lookupDisplay: true,
																lookupSourceId: 'planAttendanceDetail',
																lookupKeyFields: ['planUpdateEnable', 'planAttendanceType', 'planAttendanceDetail'],
																editor: {type:'dropDown',textReadOnly:true},
																editable: true,
																styles: {textAlignment:'near' }
															},
															{	name:'planAttendDetailReason',
																fieldName:'planAttendDetailReason',
																width:80,
																header: {text:'<lgcom:message code="label.att.planAttendanceDetail" />'}, 
																lookupDisplay: true,
																lookupSourceId: 'planAttendDetailReason',
																lookupKeyFields: ['planAttendanceDetail', 'planAttendDetailReason'],
																editor: {type:'dropDown',textReadOnly:true},
																editable: true,
																styles: {textAlignment:'near' }
															}
												         ]
											},
								            {	name:'planOT',
												fieldName:'planOT',
												width:40,
												header: {text:'<lgcom:message code="label.att.totalOT" />'},
												editable: true,
												styles: {textAlignment:'far', numberFormat: '#0.0' }
											}					           
								         ]
							},
							{ name:'planUpdateEnable',  fieldName:'planUpdateEnable', width:60,  header: {text:'planUpdateEnable'}, visible: false, editable: false, styles: {textAlignment:'near' }},
							{ name:'planHolidayFlag',  fieldName:'planHolidayFlag', width:60,  header: {text:'planHolidayFlag'}, visible: false, editable: false, styles: {textAlignment:'near' }},
							{ name:'isEditOt',  fieldName:'isEditOt', width:60,  header: {text:'isEditOt'}, visible: false, editable: false, styles: {textAlignment:'near' }},
							{	name:'actualDate', 
								fieldName:'actualDate', 
								width:40,  
								header: {text:'<lgcom:message code="label.att.date" />', styles: {background: '#c8c8c8'}},
								editable: false, 
								visible: false,
								styles: {textAlignment:'near', background: editFalseColor }
							}
						]
				);
				break;
		}
		return grid;
	}
	
	//그리드에 값 세팅하는 함수
	function setValue(grid, field, val) {
	    var row = 0;
	    var current = grid.getGridBase().getCurrent();
	    if (current) {
	        row = Math.max(0, current.dataRow);
	    }
	    grid.getDataProvider().setValue(row,field,val);
	}
}


LGVATT20040.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT20040();
		form.init();
		//form.loadCompleted();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<div class="pageHeader">
		    <h2>Line Worker Attendance Registration</h2>
		</div>
	
		<div class="searchBlock">
		    <form class="form search-wrap">
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="90" />
							<col width="90"/>
							<col width="100" />
							<col width="200"/>
							<col width="90" />
							<col width="100" />
							<col width="*"  />
						</colgroup>
						<tbody>
			                <tr>
			                    <th><label><i class="asterisk">*</i><lgcom:message code="label.att.date" /></label></th>
			                    <td>
									<span class="form-inline">
									    <input type="text" class="form-control input-sm input-require" name="attDate" placeholder="dd/mm/yyyy" readonly>
									    <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
									        <span class="ico ico-calendar" aria-hidden="true"></span>
									    </button>
									</span>  
			                    </td>
										
								<th><label><i class="asterisk">*</i><lgcom:message code="label.att.organization" /></label></th>
								<td><select class="form-control input-sm input-require" name="orgName"></select></td>
								
								<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
								
			                </tr>
			                <tr>
			                
			                	<th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
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
								
								<th><label><lgcom:message code="label.att.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>
								
								<th><label><lgcom:message code="label.att.regularFlag" /></label></th>
								<td><select class="form-control input-sm" name="regularFlag"></select></td>
			                </tr>
						</tbody>
					</table>
				</fieldset>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		    </form>
		</div>
		
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls gridControls1 module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" role="button" data-action="actualApplyAll">Apply Actual for Selected</button>
					<button class="btn btn-default btn-sm" type="button" role="button" data-action="planApplyAll">Apply Plan for Selected</button>
					<button id="btnAttSave" class="btn btn-gray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="Save"/></button>
		 		</div>
	        </div>	
	    </div>
		
		<div class="content content1 grid-wrap" >
		    <div id="LGVATT20040_grid1" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>